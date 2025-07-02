import { AgentTool, IAgentToolExecutionContext } from "src/vs/platform/ai/common/tools/agentToolsService";
import * as path from 'path';
import * as fs from 'fs'; // In a real VS Code extension, use workspace.fs or similar.

export class FileWriteTool extends AgentTool {
    constructor() {
        super(
            "file.write",
            "Writes or overwrites a file with the given content at a specified path. Path must be relative to the project root or an absolute path within the project.",
            [
                { name: "file_path", type: "string", description: "The path to the file. If relative, it's resolved against the project root. If absolute, it must be within the project root.", required: true },
                { name: "content", type: "string", description: "The content to write to the file.", required: true }
            ],
            async (context: IAgentToolExecutionContext, args: { file_path: string; content: string }) => {
                const { file_path, content } = args;

                if (!file_path || content === undefined || content === null) {
                    throw new Error("file_path and content parameters are required.");
                }

                if (!context.projectRootPath) {
                    throw new Error("Project root path is not set in the execution context. Cannot write file.");
                }

                let absoluteFilePath = file_path;
                if (!path.isAbsolute(file_path)) {
                    absoluteFilePath = path.join(context.projectRootPath, file_path);
                }

                // Security check: Ensure the path is within the project root.
                const relativePathFromRoot = path.relative(context.projectRootPath, absoluteFilePath);
                if (relativePathFromRoot.startsWith('..') || path.isAbsolute(relativePathFromRoot)) {
                    const message = `Error: Attempted to write file outside of project root. Project: ${context.projectRootPath}, Target: ${absoluteFilePath}`;
                    context.sendProgress(message);
                    console.error(message);
                    throw new Error("File path is outside the allowed project directory.");
                }

                context.sendProgress(`Attempting to write file: ${absoluteFilePath}`);

                try {
                    // Ensure directory exists
                    const dirName = path.dirname(absoluteFilePath);
                    if (!fs.existsSync(dirName)) {
                        fs.mkdirSync(dirName, { recursive: true });
                        context.sendProgress(`Created directory: ${dirName}`);
                    }

                    fs.writeFileSync(absoluteFilePath, content, 'utf8');
                    const successMsg = `File written successfully: ${absoluteFilePath}`;
                    context.sendProgress(successMsg);
                    return {
                        success: true,
                        message: successMsg,
                        file_path: absoluteFilePath // Return the absolute path
                    };
                } catch (error: any) {
                    const errorMsg = `Error writing file ${absoluteFilePath}: ${error.message}`;
                    context.sendProgress(errorMsg);
                    console.error(errorMsg, error);
                    throw new Error(errorMsg);
                }
            }
        );
    }
}
