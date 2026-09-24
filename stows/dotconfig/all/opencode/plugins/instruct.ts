import type { Plugin } from "@opencode-ai/plugin"
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

export const instruct_plugin: Plugin = async () => {
    const instructions = loadInstructions()
    if (!instructions) return {}

    return {
        "experimental.chat.system.transform": async (_input, output) => {
            if (output.system.length > 0) {
                output.system[output.system.length - 1] += "\n\n" + instructions
            } else {
                output.system.push(instructions)
            }
        },
    }
}
