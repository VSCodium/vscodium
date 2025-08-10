import { AgentTool, IAgentToolExecutionContext } from "src/vs/platform/ai/common/tools/agentToolsService";
import * as path from 'path';
import * as fs from 'fs'; // In a real VS Code extension, use workspace.fs or similar.
import { v4 as uuidv4 } from 'uuid'; // For generating unique task IDs

const TASKS_FILENAME = "PROJECT_TASKS.json";

export interface Task {
    id: string;
    title: string;
    description?: string;
    status?: string;
    assignee?: string;
    epic_id?: string;
    created_at: string;
    updated_at: string;
    // Future fields: priority, due_date, sub_tasks_ids, comments etc.
}

export interface PMUpsertTaskArgs {
    project_id: string; // Expected to be the project_path
    task_id?: string;    // If provided, it's an update, otherwise create
    task_title: string;
    task_description?: string;
    status?: string;
    assignee?: string;
    epic_id?: string;
}

export class PMUpsertTaskTool extends AgentTool {
    constructor() {
        super(
            "pm.upsertTask", // Renamed tool
            "Creates a new task or updates an existing one in the project's task list file (PROJECT_TASKS.json).",
            [
                { name: "project_id", type: "string", description: "Identifier for the project (typically the project_path). PROJECT_TASKS.json will be managed here.", required: true },
                { name: "task_id", type: "string", description: "Optional: The ID of the task to update. If not provided, a new task will be created.", required: false },
                { name: "task_title", type: "string", description: "The title or name of the task.", required: true },
                { name: "task_description", type: "string", description: "A more detailed description of the task.", required: false },
                { name: "status", type: "string", description: "The current status of the task (e.g., 'todo', 'in-progress', 'done'). Defaults to 'todo'.", required: false },
                { name: "assignee", type: "string", description: "Optional: Who is assigned to this task. Defaults to 'unassigned'.", required: false },
                { name: "epic_id", type: "string", description: "Optional: ID of an epic this task belongs to.", required: false },
            ],
            async (context: IAgentToolExecutionContext, args: PMUpsertTaskArgs) => {
                const {
                    project_id, // This is the project_path
                    task_id,
                    task_title,
                    task_description = "",
                    status = "todo",
                    assignee = "unassigned",
                    epic_id = undefined // Explicitly undefined if not provided
                } = args;

                if (!project_id || !task_title) {
                    throw new Error("project_id and task_title parameters are required for pm.upsertTask.");
                }

                if (!context.projectRootPath || project_id !== context.projectRootPath) {
                    // Ensure project_id from args matches the context's projectRootPath for security/consistency
                    // Or, simply rely on context.projectRootPath and remove project_id from args if they are always the same.
                    // For now, we'll assume project_id is the authoritative path passed by the agent, matching context.projectRootPath.
                    const msg = `Project ID/Path mismatch or not set in context. Args PID: ${project_id}, Context Path: ${context.projectRootPath}`;
                    context.sendProgress(msg);
                    console.error(msg);
                    throw new Error(msg);
                }

                const tasksFilePath = path.join(context.projectRootPath, TASKS_FILENAME);
                context.sendProgress(`Upserting task in file: ${tasksFilePath}`);

                let tasks: Task[] = [];
                try {
                    if (fs.existsSync(tasksFilePath)) {
                        const fileContent = fs.readFileSync(tasksFilePath, 'utf8');
                        if (fileContent.trim() === "") {
                            tasks = []; // Handle empty file
                        } else {
                            tasks = JSON.parse(fileContent) as Task[];
                            if (!Array.isArray(tasks)) throw new Error("Tasks file does not contain a valid JSON array.");
                        }
                        context.sendProgress(`Read existing tasks file. Found ${tasks.length} tasks.`);
                    } else {
                        context.sendProgress(`Tasks file not found at ${tasksFilePath}. Will create a new one.`);
                    }
                } catch (e: any) {
                    const errorMsg = `Error reading or parsing ${tasksFilePath}: ${e.message}. Initializing with empty task list.`;
                    context.sendProgress(errorMsg);
                    console.warn(errorMsg); // Warn instead of error, to allow overwriting a corrupted file.
                    tasks = [];
                }

                const now = new Date().toISOString();
                let targetTask: Task | undefined;
                let taskIndex = -1;

                if (task_id) {
                    taskIndex = tasks.findIndex(t => t.id === task_id);
                    if (taskIndex !== -1) {
                        targetTask = tasks[taskIndex];
                    }
                }

                if (targetTask && taskIndex !== -1) { // Update existing task
                    context.sendProgress(`Updating existing task (ID: ${task_id}): "${task_title}"`);
                    targetTask.title = task_title;
                    targetTask.description = task_description || targetTask.description;
                    targetTask.status = status || targetTask.status;
                    targetTask.assignee = assignee || targetTask.assignee;
                    targetTask.epic_id = epic_id || targetTask.epic_id;
                    targetTask.updated_at = now;
                    tasks[taskIndex] = targetTask;
                } else { // Create new task
                    if (task_id) {
                        context.sendProgress(`Task ID ${task_id} provided but not found. Creating a new task instead.`);
                    }
                    const newTaskId = task_id || uuidv4(); // Use provided ID if specified for creation, otherwise generate
                    context.sendProgress(`Creating new task (ID: ${newTaskId}): "${task_title}"`);
                    targetTask = {
                        id: newTaskId,
                        title: task_title,
                        description: task_description,
                        status: status,
                        assignee: assignee,
                        epic_id: epic_id,
                        created_at: now,
                        updated_at: now,
                    };
                    tasks.push(targetTask);
                }

                try {
                    fs.writeFileSync(tasksFilePath, JSON.stringify(tasks, null, 2), 'utf8');
                    const successMsg = `Tasks file updated successfully at ${tasksFilePath}. Total tasks: ${tasks.length}.`;
                    context.sendProgress(successMsg);
                    console.log(`PMUpsertTaskTool: ${successMsg}`);
                    return {
                        success: true,
                        message: `Task '${targetTask.title}' (ID: ${targetTask.id}) ${taskIndex !== -1 && task_id ? 'updated' : 'created'} successfully.`,
                        task: targetTask
                    };
                } catch (e: any) {
                    const errorMsg = `Error writing tasks file ${tasksFilePath}: ${e.message}`;
                    context.sendProgress(errorMsg);
                    console.error(errorMsg, e);
                    throw new Error(errorMsg);
                }
            }
        );
    }
}
