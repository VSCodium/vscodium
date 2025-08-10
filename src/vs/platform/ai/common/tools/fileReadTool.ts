import { AgentTool, IAgentToolExecutionContext } from "src/vs/platform/ai/common/tools/agentToolsService";
import * as path from 'path';
import * as fs from 'fs'; // In a real VS Code extension, use workspace.fs or similar.

export class FileReadTool extends AgentTool {
    constructor() {
        super(
            "file.read",
            "Reads the content of a file at a specified path. Path must be relative to the project root or an absolute path within the project.",
            [
                { name: "file_path", type: "string", description: "The path to the file to read. If relative, it's resolved against the project root. If absolute, it must be within the project root.", required: true }
            ],
            async (context: IAgentToolExecutionContext, args: { file_path: string }) => {
                const { file_path } = args;

                if (!file_path) {
                    throw new Error("file_path parameter is required.");
                }

                if (!context.projectRootPath) {
                    throw new Error("Project root path is not set in the execution context. Cannot read file.");
                }

                let absoluteFilePath = file_path;
                if (!path.isAbsolute(file_path)) {
                    absoluteFilePath = path.join(context.projectRootPath, file_path);
                }

                // Security check: Ensure the path is within the project root.
                const relativePathFromRoot = path.relative(context.projectRootPath, absoluteFilePath);
                if (relativePathFromRoot.startsWith('..') || path.isAbsolute(relativePathFromRoot)) {
                    const message = `Error: Attempted to read file outside of project root. Project: ${context.projectRootPath}, Target: ${absoluteFilePath}`;
                    context.sendProgress(message);
                    console.error(message);
                    throw new Error("File path is outside the allowed project directory.");
                }

                context.sendProgress(`Attempting to read file: ${absoluteFilePath}`);

                try {
                    if (!fs.existsSync(absoluteFilePath)) {
                        const errorMsg = `File not found: ${absoluteFilePath}`;
                        context.sendProgress(errorMsg);
                        throw new Error(errorMsg);
                    }

                    const content = fs.readFileSync(absoluteFilePath, 'utf8');
                    const successMsg = `File read successfully: ${absoluteFilePath}`;
                    context.sendProgress(successMsg);
                    return {
                        success: true,
                        message: successMsg,
                        file_path: absoluteFilePath,
                        content: content
                    };
                } catch (error: any) {
                    const errorMsg = `Error reading file ${absoluteFilePath}: ${error.message}`;
                    context.sendProgress(errorMsg);
                    console.error(errorMsg, error);
                    throw new Error(errorMsg);
                }
            }
        );
    }
}
