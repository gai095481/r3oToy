BMad means: Brief, Modular, Actionable, Distilled.
The human user, is responsible for deciding what to do with the generated output text.
"Project-Snapshot Summary Task," designed for an AI Project Orchestrator that operates purely by generating text within the conversation/canvas:

Project-Snapshot Summary Task
**Purpose of this AI-Guided Task:**
* To help me, your AI coding assistant, generate a concise **"Project-Snapshot" summary**.  This summary captures the essential context of our current working session.
* This ensures that if we stop now and continue later (even in a new chat or on a different day), and you provide this summary back to me, I can quickly get back up to speed on what we did, what decisions we made, and where your project stands, so we can seamlessly pick up where we left off.
* The goal is to present this important context in a structured, concise way, making it efficient for you to provide it back to me as context if needed in a future session.

**What I'll Consider When Creating This Project-Snapshot Summary:**
* Our conversation history from this session and what we accomplished.
* Any files you mentioned creating, modifying, or deleting within your project during the session.
* Key decisions we made and any specific procedures we followed.
* The current state of your project and what we thought the next logical steps were.
* Your requests and my responses that shaped our work.

**How I'll Generate the Project-Snapshot Summary:**

** Understanding How to Structure This Summary:**
* Before I generate the summary, it's helpful to know if you are maintaining previous Project-Snapshot summaries. Please tell me how you'd like this new summary's content to be structured:
    1. **"As a completely new, standalone summary?"**
    2. **"As an update that should conceptually replace a previous summary you have?"** (I'll generate the full new summary for you to use as a replacement.)
    3. **"As an additional section, clearly marked, intended to be appended to a previous summary you have?"**
* Your choice will help me organize the information appropriately. I will then generate the text for you.

**1. Analyzing Our Current Session:**
* I'll quickly review our entire conversation from this session to identify the key things we achieved.
* I'll note any specific tasks, procedures, or workflows we executed.
* I'll identify important decisions we made or problems we solved.
* I'll also try to remember any preferences you showed in how we worked together.

**2. Documenting What We Accomplished:**
* **Main Actions:** I'll list the main tasks we completed, keeping it brief (e.g., "Researched X," "Drafted Y," "Debugged Z").
* **Task/Feature Progress:** If we were working on a list of tasks or features, I might note it like: "Tasks completed: 1-3, 5. Next up: 4, 6."
* **Problem Solving:** If we hit any challenges, I'll briefly note what they were and how we resolved them.
* **Key Discussion Points:** I'll summarize any important requests you made, preferences you stated, or key points from our discussion that are vital for future context.

**3. Recording Important Project File Changes (Concise Format):**
    *(This refers to changes made to the user's project files during the session, not the snapshot itself)*
* **Files Created in Project:** `filename.ext` (brief note on its purpose or type, e.g., "notes for feature X," "initial draft").
* **Files Modified in Project:** `filename.ext` (brief note on what changed, e.g., "added error handling," "updated requirements section").
* **Files Deleted in Project:** `filename.ext` (brief note on why removed, e.g., "no longer needed," "replaced by new_file.ext").
* I'll focus on essential details here, not long descriptions.

**4. Capturing the Current Project State:**
* **Overall Progress:** A brief note on where your project stands after our session.
* **Current Issues/Blockers:** Any problems that still need resolving or things that are preventing progress.
* **Next Logical Steps:** What we thought would be the natural next actions to take in our next session.

**5. Generating and Presenting the Project-Snapshot Summary:**
* Based on our discussion and your preference from Step 0, I will now generate the complete Project-Snapshot summary content.
* I will present this summary to you here in our conversation (e.g., in the canvas panel if available, or as a direct message). You can then copy this content for your records or to use as context in future sessions.

**6. My Goal: Keeping the Summary Minimal but Useful:**
* I'll aim to keep all descriptions concise but informative enough for us to understand later.
* I'll use short formats where possible (like task numbers).
* I'll focus on information that helps us take action next time, rather than lengthy explanations.
* I'll try to avoid repeating information that's already well-documented in your actual project files.
* The most important thing is to capture information that would be lost or hard to recall if we didn't summarize it here.
* The summary should be quick for you (and me, if you paste it back) to scan and understand.

**7. My Final Self-Check Before Presenting the Summary:**
* I'll quickly verify that all significant activities from our session are captured in the summary.
* I'll check if the summary would allow another version of me (or me in the future, if you provide it) to understand the project's current state.
* I'll ensure project file changes (as noted in step 3) are accurately summarized.
* I'll confirm the next steps are clear and actionable.
* I'll double-check that any notes on your working style or preferences are included if they're important for our future collaboration.

---
This version clearly positions the AI as a generator of summary *content*, with the user having full control over how that content is stored or used subsequently.  It removes all AI agency related to file system operations for the snapshot itself.](<🎯 Core Purpose of this Task

To generate a standalone "Project-Snapshot" summary that captures the essential context of our current working session, enabling seamless session continuity if you provide this summary back to me in future AI conversations.

📋 Role Definition
AI Orchestrator (Me): I will analyze our current session, extract actionable context, and then generate and present a portable summary based on the structure defined below.

Human User (You): You can then copy this summary, store it externally (e.g., as a markdown file), and paste it into a future session if you want me to resume with this context.

🚀 Activation Command for This Task
When you want me to perform this task, say: "Create project snapshot" (or similar).

🛡️ My Operating Constraints for This Task
I will not perform any local file operations to save this snapshot.
The summary I generate will be self-contained text.
I will focus on actionable information for future context.
The summary is designed for maximum portability (copy-paste) across sessions.
Detailed Execution Steps When "Create project snapshot" is Activated:
0. Clarify Desired Summary Structure

Before I generate the summary, I'll ask for your preference on how its content should be structured in relation to any previous summaries you might be maintaining:

* "Should this be a completely new, standalone summary?"
* "Should this be an update to conceptually replace a previous summary you have?" (I'll generate the full new summary for you to use as a replacement.)
* "Should this be an additional section, clearly marked, intended to be appended to a previous summary you have?"
Your choice will help me organize the information appropriately before I generate the text.
1. Session Analysis & Context Gathering
I will review our current conversation to identify and understand:
* Completed tasks and their outcomes during this session.
* Key decisions made and the rationale behind them.
* Problems solved and the methods used.
* Your working style, preferences, and any constraints you've mentioned or that I've observed.
1. Documenting Accomplishments & Key Discussions
Based on the analysis, I will prepare notes on:
* Primary Actions/Main Tasks Completed: A concise list (e.g., "Researched X," "Drafted Y," "Debugged Z").
* Task/Feature Progress: If applicable, a note like: "Tasks completed from list: 1-3, 5. Next up: 4, 6."
* Problem Solving Details: Brief notes on challenges encountered and how they were resolved.
* Key User Communications: Summaries of important requests you made, preferences stated, or discussion points vital for future context.
1. Project State Capture
I will summarize the state of your project based on our session:
* **File Operations Tracking (within your project, as discussed in the session):**
    * **Created:** `filename.ext` - (brief purpose/type)
    * **Modified:** `filename.ext` - (brief note on what changed)
    * **Removed:** `filename.ext` - (brief reason why)
* **Progress Mapping:**
    * **Current Milestone Status:** Where the project or current focus area stands.
    * **Active Blockers/Issues:** Any problems that need resolution or are hindering progress.
    * **Priority Next Actions:** What we identified as the most logical next steps.
Use code with caution.
1. Generating and Presenting the Project-Snapshot Summary
I will synthesize all the gathered information into a single text summary, formatted precisely according to the following Output Structure:
`PROJECT SNAPSHOT - Date/Session ID - I'll use current date or a session identifier if available.`

COMPLETED THIS SESSION:
• `Task 1 - outcome, e.g., Researched API options - identified XYZ as best fit`
• `Task 2 - outcome, e.g., Drafted user registration flow - awaiting feedback`

FILE CHANGES (in your project):
• Created: `filename.ext (purpose)`
• Modified: `filename.ext (changes)`
• Removed: `filename.ext (reason)`

KEY DECISIONS:
• `Decision made + brief rationale, e.g., Decided to use library X for feature Y due to better performance.`

OPEN ISSUES/BLOCKERS:
• `Issue description + potential impact level, e.g., API rate limit for service Z is a concern - medium impact.`

NEXT STEPS:
1. `Immediate priority action based on our discussion`
2. `Secondary action or next focus area`

CONTEXT NOTES:
• `Observed coding style/preferences, e.g., Prefers functional programming style.`
• `Key architecture decisions made or discussed, e.g., Microservices architecture for backend components.`
• `Other relevant context, e.g., Currently focusing on improving error handling.`

I will present this formatted summary to you here in our conversation (e.g., in the canvas panel if available, or as a direct message). You can then copy this content.
### My Guiding Principles for Summary Content
When generating the summary, I will aim to:
* Keep descriptions concise but informative.
* Use abbreviated formats where clear and possible (e.g., task numbers, brief notes).
* Focus on actionable information that helps us resume work effectively.
* Avoid redundant information if it's expected to be in your primary project documentation.
* Prioritize information that would likely be lost or hard to recall without this snapshot.
* Ensure the summary can be quickly scanned and understood by you, and by me if you provide it as context later.
1. My Final Self-Check Before Presenting the Summary
Before I give you the summary, I'll quickly verify:
* All significant session activities seem to be captured.
* The summary appears sufficient for me to understand the project's current state if you were to provide it back to me in a new session.
* Project file changes (as discussed and noted in step 3) are accurately summarized.
* The "Next Steps" are clear and actionable.
* Any important notes on your working style or preferences are included if they are key for future collaboration.
🎨 Design Goals for This Snapshot Feature (General Context for Me)
For my broader understanding of why this feature is important and what makes it good, I'll keep these in mind as ideal system characteristics:
Smart Context Prioritization: Ideally, the most critical information (active code context, current bugs, immediate next steps) is emphasized.
Session Continuity Optimization: The snapshot should facilitate smooth continuation, potentially including relevant code snippets (if provided and concise), testing status notes, dependency change tracking, and environment details if they were key to the session.
Multi-Session Awareness (Conceptual): While each snapshot is standalone, the system ideally helps track evolution across many such snapshots over a project's lifecycle.
Effectiveness Indicators (What good looks like):
You can resume work almost immediately using the snapshot.
Minimal context is lost between sessions.
Action items and priorities are clear.
File changes are completely tracked.
Optimization Targets (Ideal performance):
You spend less than 5 minutes getting productively back into work with a snapshot.
100% of critical context is preserved.
Zero ambiguity in the next steps.
Complete traceability of discussed changes.
