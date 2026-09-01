// designx.ts — Plugin OpenCode para hooks do designx
// Invoca os mesmos scripts de .claude/hooks/designx/

import { execSync } from "child_process";
import { existsSync } from "fs";

const HOOKS_DIR = ".claude/hooks/designx";

function runHook(script: string, env: Record<string, string> = {}): { stdout: string; stderr: string; exitCode: number } {
  const path = `${HOOKS_DIR}/${script}`;
  if (!existsSync(path)) return { stdout: "", stderr: "", exitCode: 0 };

  try {
    const stdout = execSync(`bash ${path}`, {
      encoding: "utf-8",
      env: { ...process.env, ...env },
      timeout: 200,
    });
    return { stdout, stderr: "", exitCode: 0 };
  } catch (err: any) {
    return {
      stdout: err.stdout ?? "",
      stderr: err.stderr ?? "",
      exitCode: err.status ?? 1,
    };
  }
}

export default {
  "tool.execute.before"(input: any) {
    const { tool, args } = input;

    // PreToolUse: Bash → designx-cartografa
    if (tool === "Bash") {
      const result = runHook("designx-cartografa.sh");
      if (result.exitCode === 2) {
        throw new Error(result.stderr);
      }
    }
  },

  "tool.execute.after"(input: any) {
    const { tool, args } = input;

    // PostToolUse: Write/Edit → designx-audit
    if (tool === "Write" || tool === "Edit") {
      const filePath = args?.filePath ?? "";
      const result = runHook("designx-audit.sh", { DESIGNX_FILE: filePath });
      if (result.stderr) {
        // Anexar aviso ao resultado, prefixado para o modelo nao confundir
        return {
          hookSpecificOutput: {
            hookEventName: "PostToolUse",
            additionalContext: `[designx/hooks — aviso, a acao NAO foi bloqueada] ${result.stderr}`,
          },
        };
      }
    }
  },
};
