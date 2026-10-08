import { Plugin } from "@opencode/plugin"
import { readFileSync, readdirSync } from "node:fs"
import { resolve } from "node:path"

const INSTRUCTIONS_DIR = resolve(import.meta.dir, "../instructions")

function loadInstructions(): string {
    return readdirSync(INSTRUCTIONS_DIR)
        .filter((f) => f.endsWith(".md"))
        .map((f) => {
            try {
                return readFileSync(resolve(INSTRUCTIONS_DIR, f), "utf-8").trim()
            } catch {
                return null
            }
        })
        .filter(Boolean)
        .join("\n\n")
}

export default Plugin.define({
    id: "instruct",
    async setup(ctx) {
        const instructions = loadInstructions()
        if (!instructions) return

        await ctx.session.hook("context", (event) => {
            const last = event.system[event.system.length - 1]
            if (last) {
                last.text += "\n\n" + instructions
            } else {
                event.system.push({ type: "text", text: instructions })
            }
        })
    },
})
