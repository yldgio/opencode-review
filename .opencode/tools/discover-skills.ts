import { tool } from "@opencode-ai/plugin"

/**
 * Default repositories to search for skills (in order of preference)
 */
const DEFAULT_REPOS = [
  "yldgio/codereview-skills",
  "github/awesome-copilot",
  "vercel/agent-skills",
  "anthropics/skills"
]

/**
 * Mapping from detected stack names to skill names
 */
const STACK_TO_SKILL: Record<string, string> = {
  "Next.js": "nextjs",
  "React": "react",
  "Angular": "angular",
  "NestJS": "nestjs",
  "FastAPI": "fastapi",
  ".NET": "dotnet",
  "Docker": "docker",
  "GitHub Actions": "github-actions",
  "Azure DevOps": "azure-devops",
  "Bicep": "bicep",
  "Terraform": "terraform"
}

interface SkillResult {
  stack: string
  skill: string
  repo: string
  description?: string
}

interface DiscoveryResult {
  found: SkillResult[]
  notFound: string[]
  errors: string[]
}

/**
 * Fetch with retry and exponential backoff
 */
async function fetchWithRetry(
  url: string,
  headers: Record<string, string>,
  maxRetries = 3,
  baseDelayMs = 1000
): Promise<Response> {
  let lastError: Error | null = null
  
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const response = await fetch(url, { headers })
      
      // If rate limited, wait and retry
      if (response.status === 403 || response.status === 429) {
        const retryAfter = response.headers.get("Retry-After")
        const delay = retryAfter 
          ? parseInt(retryAfter, 10) * 1000 
          : baseDelayMs * Math.pow(2, attempt)
        
        if (attempt < maxRetries - 1) {
          await new Promise(resolve => setTimeout(resolve, delay))
          continue
        }
      }
      
      return response
    } catch (error) {
      lastError = error as Error
      if (attempt < maxRetries - 1) {
        await new Promise(resolve => setTimeout(resolve, baseDelayMs * Math.pow(2, attempt)))
      }
    }
  }
  
  throw lastError || new Error("Max retries exceeded")
}

/**
 * Check if a skill exists in a repository and extract description
 */
async function checkSkillInRepo(
  owner: string,
  repo: string,
  skillName: string,
  headers: Record<string, string>
): Promise<{ exists: boolean; description?: string }> {
  // Try common skill directory structures
  const paths = [
    `skills/${skillName}`,
    `skills/${skillName}/SKILL.md`,
    `${skillName}`,
    `${skillName}/SKILL.md`
  ]
  
  for (const path of paths) {
    const url = `https://api.github.com/repos/${owner}/${repo}/contents/${path}`
    
    try {
      const response = await fetchWithRetry(url, headers)
      
      if (response.status === 200) {
        const data = await response.json()
        
        // If it's a directory, look for SKILL.md inside
        if (Array.isArray(data)) {
          const skillMd = data.find((f: { name: string }) => 
            f.name.toLowerCase() === "skill.md" || f.name.toLowerCase() === "readme.md"
          )
          
          if (skillMd) {
            const description = await extractDescription(skillMd.download_url, headers)
            return { exists: true, description }
          }
          return { exists: true }
        }
        
        // If it's a file (SKILL.md), extract description
        if (data.download_url) {
          const description = await extractDescription(data.download_url, headers)
          return { exists: true, description }
        }
        
        return { exists: true }
      }
    } catch {
      // Continue to next path
    }
  }
  
  return { exists: false }
}

/**
 * Extract description from SKILL.md content
 */
async function extractDescription(
  downloadUrl: string,
  headers: Record<string, string>
): Promise<string | undefined> {
  try {
    const response = await fetch(downloadUrl, { headers })
    if (response.status !== 200) return undefined
    
    const content = await response.text()
    
    // Try to extract first paragraph or description from frontmatter
    const lines = content.split("\n")
    
    // Check for YAML frontmatter
    if (lines[0]?.trim() === "---") {
      const endIndex = lines.findIndex((line, i) => i > 0 && line.trim() === "---")
      if (endIndex > 0) {
        const frontmatter = lines.slice(1, endIndex).join("\n")
        const descMatch = frontmatter.match(/description:\s*["']?(.+?)["']?\s*$/m)
        if (descMatch) {
          return descMatch[1].trim()
        }
      }
    }
    
    // Otherwise, get first non-empty, non-heading line
    for (const line of lines) {
      const trimmed = line.trim()
      if (trimmed && !trimmed.startsWith("#") && !trimmed.startsWith("---")) {
        return trimmed.slice(0, 100) + (trimmed.length > 100 ? "..." : "")
      }
    }
    
    return undefined
  } catch {
    return undefined
  }
}

/**
 * Parse repo string into owner and repo name
 */
function parseRepo(repoString: string): { owner: string; repo: string } | null {
  // Handle full URL
  if (repoString.startsWith("https://")) {
    const match = repoString.match(/github\.com\/([^/]+)\/([^/]+)/)
    if (match) {
      return { owner: match[1], repo: match[2].replace(/\.git$/, "") }
    }
    return null
  }
  
  // Handle shorthand owner/repo
  const parts = repoString.split("/")
  if (parts.length === 2) {
    return { owner: parts[0], repo: parts[1] }
  }
  
  return null
}

export default tool({
  description: "Discover which skills are available for detected tech stacks in remote GitHub repositories",
  args: {
    stacks: tool.schema.array(tool.schema.string())
      .describe("Detected stack names (e.g., ['Next.js', 'React', 'Docker'])"),
    repos: tool.schema.array(tool.schema.string()).optional()
      .describe("Override repository list (default: uses SKILL_REPOS env or built-in list)"),
  },
  async execute(args) {
    const result: DiscoveryResult = {
      found: [],
      notFound: [],
      errors: []
    }
    
    // Determine which repos to search
    let reposToSearch: string[]
    if (args.repos && args.repos.length > 0) {
      reposToSearch = args.repos
    } else if (process.env.SKILL_REPOS) {
      reposToSearch = process.env.SKILL_REPOS.split(",").map(r => r.trim()).filter(Boolean)
    } else {
      reposToSearch = DEFAULT_REPOS
    }
    
    // Build headers (with optional auth)
    const headers: Record<string, string> = {
      "Accept": "application/vnd.github.v3+json",
      "User-Agent": "opencode-discover-skills"
    }
    
    if (process.env.GITHUB_TOKEN) {
      headers["Authorization"] = `Bearer ${process.env.GITHUB_TOKEN}`
    }
    
    // Process each stack
    for (const stack of args.stacks) {
      const skillName = STACK_TO_SKILL[stack] || stack.toLowerCase().replace(/[^a-z0-9]/g, "-")
      let found = false
      
      // Search repos in order
      for (const repoString of reposToSearch) {
        const parsed = parseRepo(repoString)
        if (!parsed) {
          result.errors.push(`Invalid repo format: ${repoString}`)
          continue
        }
        
        try {
          const checkResult = await checkSkillInRepo(
            parsed.owner,
            parsed.repo,
            skillName,
            headers
          )
          
          if (checkResult.exists) {
            result.found.push({
              stack,
              skill: skillName,
              repo: repoString,
              description: checkResult.description
            })
            found = true
            break // Stop at first repo that has the skill
          }
        } catch (error) {
          result.errors.push(`Error checking ${repoString} for ${skillName}: ${error}`)
        }
      }
      
      if (!found) {
        result.notFound.push(stack)
      }
    }
    
    // Format output
    const output: string[] = []
    
    output.push("## Skill Discovery Results\n")
    
    if (result.found.length > 0) {
      output.push("**Found:**")
      for (const skill of result.found) {
        const desc = skill.description ? ` - "${skill.description}"` : ""
        output.push(`- ${skill.skill}: found in ${skill.repo}${desc}`)
      }
      output.push("")
    }
    
    if (result.notFound.length > 0) {
      output.push("**Not Found:**")
      for (const stack of result.notFound) {
        const skillName = STACK_TO_SKILL[stack] || stack.toLowerCase().replace(/[^a-z0-9]/g, "-")
        output.push(`- ${skillName} (${stack}): NOT FOUND (checked: ${reposToSearch.join(", ")})`)
      }
      output.push("")
    }
    
    if (result.errors.length > 0) {
      output.push("**Errors:**")
      for (const error of result.errors) {
        output.push(`- ${error}`)
      }
      output.push("")
    }
    
    output.push(`**Summary:** ${result.found.length} found, ${result.notFound.length} not found, ${result.errors.length} errors`)
    
    // Also return structured JSON for programmatic use
    output.push("\n```json")
    output.push(JSON.stringify(result, null, 2))
    output.push("```")
    
    return output.join("\n")
  },
})
