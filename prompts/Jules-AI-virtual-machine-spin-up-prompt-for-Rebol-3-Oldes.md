"Jules, please install Rebol/Bulk version 3.19.0 for Linux x86-64. You should perform the following actions:

1. **Download the specific bulk binary:**
   - Target file: `rebol3-bulk-linux-x64.gz`
   - Download URL: `https://github.com/Oldes/Rebol3/releases/download/3.19.0/rebol3-bulk-linux-x64.gz`
   - You can use a command like `curl -LJO <URL>` to download it.
2. **Extract the executable:**
   - You can use `gunzip rebol3-bulk-linux-x64.gz` to decompress the downloaded file. This will result in an executable typically named `rebol3-bulk-linux-x64`.
3. **Prepare the executable:**
   - Rename the extracted file to `rebol3-bulk` (e.g., `mv rebol3-bulk-linux-x64 rebol3-bulk`).
   - Make it executable: `chmod +x rebol3-bulk`.
4. **Verify the installation:**
   - Run `./rebol3-bulk -v`.
   - Confirm that the output shows 'Rebol/Bulk 3.19.0'."

IMPORTANT: This MUST be the very first instruction to Jules AI, otherwise Jules AI says it cannot do this installation.

---

Jules AI, your task is to debug execute the following DevOps cycle a Rebol 3 script. You will use the installed Rebol/Bulk environment VM.

Input:

The user will paste the targeted Rebol script into your chat window.
Process:

Initial Run & Full Output Capture:

I will execute the provided script using rebol3-bulk.
I will capture and present the complete, verbatim output (stdout, stderr, errors, test results, traces).
Iterative Debugging and Fix Cycle (Loop until all tests pass, max attempts reached or concluded no progress can be made):

Analyze Failures: Based on the latest output:

I will identify the first ❌ FAILED test or runtime ERROR.
I will compare 'Expected' vs. 'Actual' values for failed tests.
I will note any unhandled exceptions or incomplete execution markers.

Troubleshoot & Hypothesize:

I will pinpoint the relevant code section in the provided script for the primary failure.
I will formulate a hypothesis for the root cause (e.g., logic error, incorrect Rebol semantic usage, scoping issue).

Apply Corrective Action:

I will modify the provided script with the minimal changes necessary to address the hypothesized cause.
I will annotate each fix with a ;; FIXED: [brief reason for change]. comment directly above or next to the changed code.
I will prioritize fixes that are least likely to negatively impact already passing tests.

Re-execute & Capture: I will run the modified script using rebol3-bulk and capture the full output again.

Report After Each Iteration: I will provide:
A brief summary of the primary failure analyzed in this iteration.
The hypothesis for the fix.
A diff or clear description of the code changes made.
The full output of the script run after applying the fix.

Termination Conditions:

Success: The script completes, and all tests pass (no "❌" or "FAILED" markers in the output, and any explicit completion messages are present).
Pause: If all tests are not passing after [suggest a number, e.g., 5-7] iterations, or if I determine I cannot make further progress,
I will stop and report the current state of the script, the outstanding issues, and my analysis.  I will request your assistance at this point.
