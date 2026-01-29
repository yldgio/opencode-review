import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "Install skills from a GitHub repository. Default: global installation (shared across projects). Use projectLevel=true for project-specific installation.",
  args: {
    repo: tool.schema.string().describe("GitHub repo - shorthand 'owner/repo' or full URL 'https://github.com/owner/repo'"),
    skills: tool.schema.union([
      tool.schema.string().describe("Single skill name"),
      tool.schema.array(tool.schema.string()).describe("Array of skill names"),
    ]).describe("Skill name(s) to install (e.g., 'nextjs' or ['nextjs', 'react'])"),
    projectLevel: tool.schema.boolean().optional().describe("Install to project (.opencode/rules/) instead of global (~/.config/opencode/rules/). Default: false (global)"),
  },
  async execute(args) {
    // Check Node.js
    try {
      await Bun.$`node --version`.quiet()
    } catch {
      return "Error: Node.js is not installed. Please install Node.js first."
    }

    // Check npm
    try {
      await Bun.$`npm --version`.quiet()
    } catch {
      return "Error: npm is not installed. Please install npm first."
    }

    // Normalize repo to full URL
    const repoUrl = args.repo.startsWith("https://")
      ? args.repo
      : `https://github.com/${args.repo}`

    // Normalize skills to array
    const skills = Array.isArray(args.skills) ? args.skills : [args.skills]
    
    // Build skill flags: --skill skill1 --skill skill2
    const skillFlags = skills.flatMap(s => ["--skill", s])
    
    // Determine scope flags
    const scopeFlags = args.projectLevel ? [] : ["-g"]

    // Install skills (non-interactive with -y flag, -a opencode for OpenCode agent)
    const results: string[] = []
    try {
      const result = await Bun.$`npx skills add ${repoUrl} ${scopeFlags} -a opencode -y ${skillFlags}`.text()
      for (const skill of skills) {
        results.push(`- ${skill}: OK`)
      }
    } catch (error) {
      for (const skill of skills) {
        results.push(`- ${skill}: FAILED (${error})`)
      }
    }

    const scope = args.projectLevel ? "project" : "global"
    return `Installed ${skills.length} skill(s) from ${args.repo} (${scope}):\n${results.join("\n")}`
  },
})
