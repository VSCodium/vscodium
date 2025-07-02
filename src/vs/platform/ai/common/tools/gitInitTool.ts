import { AgentTool, IAgentToolExecutionContext } from "src/vs/platform/ai/common/tools/agentToolsService";
import * as path from 'path'; // For path validation if needed

export class GitInitTool extends AgentTool {
    constructor() {
        super(
            "git.init",
            "Initializes a new Git repository in the specified directory.",
            [
                { name: "directory_path", type: "string", description: "The absolute path to the directory where 'git init' should be run. This directory must exist.", required: true }
            ],
            async (context: IAgentToolExecutionContext, args: { directory_path: string }) => {
                const { directory_path } = args;

                if (!directory_path) {
                    throw new Error("directory_path parameter is required.");
                }

                // In a real VS Code extension, ensure directory_path is safe and valid.
                // For now, assume it's a path provided by another tool or a trusted source.

                context.sendProgress(`Initializing Git repository in ${directory_path}...`);

                try {
                    // The executeTerminalCommand should handle existence of directory_path or git itself
                    const result = await context.executeTerminalCommand("git", ["init"], { cwd: directory_path });

                    if (result.exitCode === 0) {
                        context.sendProgress(`Git repository initialized successfully in ${directory_path}. Output: ${result.stdout}`);
                        return { success: true, message: `Git repository initialized in ${directory_path}.`, output: result.stdout };
                    } else {
                        const errorMessage = `Failed to initialize Git repository in ${directory_path}. Exit code: ${result.exitCode}. Stderr: ${result.stderr}. Stdout: ${result.stdout}`;
                        context.sendProgress(errorMessage);
                        console.error(errorMessage);
                        throw new Error(errorMessage);
                    }
                } catch (error: any) {
                    const errorMessage = `Error executing 'git init' in ${directory_path}: ${error.message}`;
                    context.sendProgress(errorMessage);
                    console.error(errorMessage);
                    throw new Error(errorMessage);
                }
            }
        );
    }
}
