import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "Install skills from a GitHub repository. Checks for Node.js/npm before installing.",
  args: {
    repo: tool.schema.string().describe("GitHub repo - shorthand 'owner/repo' or full URL 'https://github.com/owner/repo'"),
    skills: tool.schema.union([
      tool.schema.string().describe("Single skill name"),
      tool.schema.array(tool.schema.string()).describe("Array of skill names"),
    ]).describe("Skill name(s) to install (e.g., 'nextjs' or ['nextjs', 'react'])"),
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

    // Install each skill
    const results: string[] = []
    for (const skill of skills) {
      try {
        const result = await Bun.$`npx skills add ${repoUrl} --skill ${skill}`.text()
        results.push(`- ${skill}: OK`)
      } catch (error) {
        results.push(`- ${skill}: FAILED (${error})`)
      }
    }

    return `Installed ${skills.length} skill(s) from ${args.repo}:\n${results.join("\n")}`
  },
})
