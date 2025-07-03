import { AgentTool, IAgentToolExecutionContext } from "src/vs/platform/ai/common/tools/agentToolsService";

export interface PMLogTaskArgs {
    project_id: string;
    task_title: string;
    task_description?: string;
    status?: string;
    assignee?: string; // Future use
    epic_id?: string;   // Future use
}

export class PMLogTaskTool extends AgentTool {
    // Simple in-memory store for logged tasks for conceptual testing across agent calls if needed.
    // In a real scenario, this would be a service or database.
    public static loggedTasks: Array<PMLogTaskArgs & { log_time: string }> = [];

    constructor() {
        super(
            "pm.logTask",
            "Logs a new task with details. Initially logs to console; future versions might integrate with a task management system.",
            [
                { name: "project_id", type: "string", description: "Identifier for the project this task belongs to (e.g., project path or a dedicated project ID).", required: true },
                { name: "task_title", type: "string", description: "The title or name of the task.", required: true },
                { name: "task_description", type: "string", description: "A more detailed description of the task.", required: false },
                { name: "status", type: "string", description: "The current status of the task (e.g., 'todo', 'in-progress', 'done'). Defaults to 'todo'.", required: false },
                { name: "assignee", type: "string", description: "Optional: Who is assigned to this task.", required: false },
                { name: "epic_id", type: "string", description: "Optional: ID of an epic this task belongs to.", required: false },
            ],
            async (context: IAgentToolExecutionContext, args: PMLogTaskArgs) => {
                const {
                    project_id,
                    task_title,
                    task_description = "",
                    status = "todo",
                    assignee = "unassigned",
                    epic_id = "none"
                } = args;

                if (!project_id || !task_title) {
                    throw new Error("project_id and task_title parameters are required for pm.logTask.");
                }

                const logTime = new Date().toISOString();
                const taskDataForLog = {
                    project_id,
                    task_title,
                    task_description,
                    status,
                    assignee,
                    epic_id,
                    log_time: logTime
                };

                // For conceptual testing & simple persistence during a session
                PMLogTaskTool.loggedTasks.push(taskDataForLog);

                const logMessage = `[TASK LOGGED] Project: ${project_id} | Title: "${task_title}" | Status: ${status} | Assignee: ${assignee} | Epic: ${epic_id} | Description: ${task_description || 'N/A'}`;

                context.sendProgress(`pm.logTask: ${logMessage}`); // Use context.sendProgress for agent-facing logs
                console.log(`PMLogTaskTool: ${logMessage}`);       // Also console.log for general dev visibility

                return {
                    success: true,
                    message: "Task logged successfully.",
                    logged_task_details: taskDataForLog
                };
            }
        );
    }
}
