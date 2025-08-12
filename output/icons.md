```
print "=== UNICODE CHARACTER PRINTABILITY TEST ==="

;; Test uNICODE Status Indicators:
print "^/STATUS INDICATORS (MOST PRINTABLE):"
print "✅ PASSED - Green check mark"
print "❌ ERROR / FAILED - Red X mark"
print "⚠️  CAUTION / WARNING - Warning triangle (uses two trailing spaces due to known problem)"

print "^/TEST USUALLY PROBLEMATIC TERMINAL CHARACTERS:"
print ["🎉 Complete Success: " "🎉"]
print ["📊 Chart/Stats: " "📊"]
print ["📋 Clipboard: " "📋"]
print ["🔧 Tool/Wrench/Utility: " "🔧"]
print ["⚡ Lightning/Quick: " "⚡"]
print ["🎯 Target/Goal/Match/Hit: " "🎯"]
print ["📝 Note/Document: " "📝"]
print ["💡 Idea/Hint: " "💡"]
print ["🚀 Rocket/Launch: " "🚀"]
print ["🔍 Search/Magnify: " "🔍"]
print ["⏱️ Timer/Performance: " "⏱️"]
print ["📚 Enhanced/Available: " "📚"]

print "^/TEST ADDITIONAL STATUS CHARACTERS:"
print ["🔄 Processing/Retry: " "🔄"]
print ["⏳ Waiting/Loading: " "⏳"]
print ["🛑 Stop/Terminate: " "🛑"]
print ["🚨 Alert/Critical: " "🚨"]
print ["🔥 Critical Error: " "🔥"]
print ["🚫 Unavailable/Disabled: " "🚫"]
print ["✨ New/Initialized: " "✨"]
print ["💤 Sleep/Idle: " "💤"]
print ""

print "^/TEST FILE & DATA CHARACTERS:"
print ["💾 Save/Storage: " "💾"]
print ["📂 Folder/Directory: " "📂"]
print ["📄 Document/File: " "📄"]
print ["📁 Closed Folder: " "📁"]
print ["📊 Chart/Graph: " "📊"]
print ["📈 Trending Up: " "📈"]
print ["📉 Trending Down: " "📉"]
print ""

print "^/TEST NETWORK & CONNECTIVITY:"
print ["🌐 Network/Internet: " "🌐"]
print ["📶 Signal/Connectivity: " "📶"]
print ["⬆️ Upload/Export: " "⬆️"]
print ["⬇️ Download/Import: " "⬇️"]
print ["🔗 Link/Connection: " "🔗"]
print ""

print "^/TEST USER & SECURITY:"
print ["👤 User/Authentication: " "👤"]
print ["🔒 Secure/Locked/Protected: " "🔒"]
print ["🔓 Unlocked/Open: " "🔓"]
print ["🔑 Key/Access: " "🔑"]
print ""

print "^/TEST BASIC TEXT CHARACTERS:"
print ["• Bullet point: " "•"]
print ["→ Arrow right: " "→"]
print ["← Arrow left: " "←"]
print ["↑ Arrow up: " "↑"]
print ["↓ Arrow down: " "↓"]
print ["✓ Check mark: " "✓"]
print ["✗ X mark: " "✗"]
print ["★ Star filled: " "★"]
print ["☆ Star empty: " "☆"]
print ""

print "^/TEST MATHEMATICAL & TECHNICAL:"
print ["∞ Infinity: " "∞"]
print ["± Plus/Minus: " "±"]
print ["≈ Approximately: " "≈"]
print ["≠ Not equal: " "≠"]
print ["≤ Less/Equal: " "≤"]
print ["≥ Greater/Equal: " "≥"]
print ["° Degree: " "°"]
print ["µ Micro: " "µ"]
print ""

print "TEST BOX DRAWING CHARACTERS:"
print ["┌ Top left: " "┌"]
print ["┐ Top right: " "┐"]
print ["└ Bottom left: " "└"]
print ["┘ Bottom right: " "┘"]
print ["│ Vertical: " "│"]
print ["─ Horizontal: " "─"]
print ["├ Left T: " "├"]
print ["┤ Right T: " "┤"]
print ["┬ Top T: " "┬"]
print ["┴ Bottom T: " "┴"]
print ["┼ Cross: " "┼"]
print ""

print "TEST CONTEXT USAGE EXAMPLES:"
print "✅ PASSED: All tests completed successfully"
print "❌ FAILED: 3 critical violations found"
print "⚠️  WARNING: Consider reviewing this code"
print "🔍 Scanning directory for violations..."
print "📊 Processed 42 files in 1.2 seconds"
print "🔧 Running validation tools..."
print "💡 TIP: Use quick check for faster validation"
print "🚀 Ready for deployment!"
print ""

print " Likely printable: ✅ ❌ ⚠️  ★ ☆ ⚡ ⏱️ ⏳ ⬆️ ⬇️ ✨∞ ± ≈ ≠ ≤ ≥ ° µ  ┌ ┐ └ ┘ │ ─ ├ ┤ ┬ ┴ ┼"
print " Likely unprintable: 🎉 📊 📋 🔧 🎯 📝 💡 🚀 🔍 🔄 🛑 🚨 🔥 🚫 💤 💾 📂 📄 📁 📈 📉 🌐 📶 🔗 👤 🔒 🔓 🔑 📚"

print "=== DEMO COMPLETE ==="
print "Examine the above output to see which characters display correctly"
```
---

A Unicode printability test reveals important insights:

✅ TERMINAL-COMPATIBLE CHARACTERS (PowerShell and Linux BASH):

Status indicators: ✅ ❌ ⚠️ (our approved set)
Simple symbols: • → ← ↑ ↓ ✓ ✗ ★ ☆ ⚡ ⏱️ ⏳ ⬆️ ⬇️ ✨
Mathematical: ∞ ± ≈ ≠ ≤ ≥ ° µ
Box drawing: ┌ ┐ └ ┘ │ ─ ├ ┤ ┬ ┴ ┼


❌ TERMINAL-INCOMPATIBLE (Display as �):

Most emoji characters: 🎉 📊 📋 🔧 🎯 📝 💡 🚀 🔍 🔄 🛑 🚨 🔥 🚫 💤 💾 📂 📄 📁 📈 📉 🌐 📶 🔗 👤 🔒 🔓 🔑 📚
Key Findings:

~40% compatibility rate - Most Unicode characters don't display properly in terminal.
Emoji characters are problematic - Almost all show as � replacement character.
Simple symbols work well - Basic arrows, bullets, stars display correctly.
Our current approach is correct - Using only ✅ ❌ ⚠️ for status indicators.


```rebol

print "🔍 find / search"
print "✏️ edit / modify"
print "📏 access / analyze / scan / read"
print "✅ PASSED"
🔄 Processing/Retrying/Running/Redo/Updating/Refreshing:
⏳ Waiting/Loading:
💾 Copy/Backup/Save/Storage
📄 Document/File:
📶 Signal/Connectivity:
❓ Question/Help/Absent/Unknown
🛑 Halt/Kill/Stop/Terminate:
👤 User/Authentication
🔥 Critical/Fatal Error
💡 Hint/Idea/Suggest:
⏱️ Benchmark/Performance/Speed/Time:
🚨 Alert/Intrusion:
⬆️ Upload/Export
⬇️ Download/Import/Install:
🚫 Blocked/Unavailable/Disabled/Prohibited
✨ New/Initialize/Think:
💤 Sleep/Idle/Standby:

## Best Practices
- Consistency: Use the same icon for identical concepts (e.g., always ❌ for failures).
- Accessibility: Pair icons with text (e.g., ✅ PASSED not just ✅).
- Context: Choose universally recognizable symbols (e.g., 📂 for folders is clearer than 📁).
- Sparingly: Overuse reduces impact – reserve for key statuses.
