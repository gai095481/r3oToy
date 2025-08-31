```
print "=== UNICODE CHARACTER PRINTABILITY TEST ==="

;; Test uNICODE Status Indicators:
print "^/STATUS INDICATORS (MOST PRINTABLE):"
print "✅ PASSED - Green check mark"
print "❌ ERROR / FAILED - Red X mark"
print "⚠️  CAUTION / WARNING - Warning triangle (uses two trailing spaces due to known problem)"
print ["🚧 Road block/Construction: " "🚧"]
print ["✨ New/Initialized/Think: " "✨"]
print ["⏳ Waiting/Loading: " "⏳"]
print ["⚡ Lightning/Quick: " "⚡"]
print ["⏱️ Benchmark/Clock/Profiler/Speed/Timer/Performance: " "⏱️"]
print ["❓ Question/Help/Absent/Missing/Predicate/Unknown: " "❓"]
print ["✏️ Edit/Modify/Write: " "✏️"]
print ["💥 Burst/Explode/Shatter: " "💥"]


print "^/TEST USUALLY PROBLEMATIC TERMINAL CHARACTERS:"
print ["🎉 Complete Success: " "🎉"]
print ["📊 Chart/Stats: " "📊"]
print ["📋 Clipboard: " "📋"]
print ["🔧 Tool/Wrench/Utility: " "🔧"]
print ["🎯 Target/Goal/Match/Hit: " "🎯"]
print ["📝 Note/Document: " "📝"]
print ["💡 Idea/Hint/Sugeestion/Tip: " "💡"]
print ["🚀 Rocket/Launch: " "🚀"]
print ["🔍 Find/Examine/Inspect/Locate/Scan/Search/Magnify: " "🔍"]
print ["📚 Enhanced/Available: " "📚"]

print "^/TEST ADDITIONAL STATUS CHARACTERS:"
print ["🔄 Process/Retry/Running/Redo/Update/Refresh: " "🔄"]
print ["🛑 Halt/Kill/Stop/Terminate: " "🛑"]
print ["🚨 Alert/Alarm/Attention/Important/Intrusion: " "🚨"]
print ["🔥 Crisis: " "🔥"]
print ["🚫 Banned/Blocked/Unavailable/Disabled/Prohibited: " "🚫"]
print ["💤 Sleep/Hibernate/Idle/Standby: " "💤"]
 
print "^/TEST FILE & DATA CHARACTERS:"
print ["💾 Copy/Backup/Save/Storage: " "💾"]
print ["🏷️ Label/Tag: " "🏷️"]
print ["📂 Folder/Directory: " "📂"]
print ["📄 Document/File: " "📄"]
print ["📁 Closed Folder: " "📁"]
print ["📊 Chart/Graph: " "📊"]
print ["📈 Trending Up: " "📈"]
print ["📉 Trending Down: " "📉"]

print "^/TEST NETWORK & CONNECTIVITY:"
print ["🌐 Network/Internet: " "🌐"]
print ["📶 Signal/Connectivity: " "📶"]
print ["⬆️ Up/Upload/Export: " "⬆️"]
print ["⬇️ Down/Download/Import/Install: " "⬇️"]
print ["🔗 Link/Connection: " "🔗"]

print "^/TEST USER & SECURITY:"
print ["👤 User/Authentication: " "👤"]
print ["🔒 Secure/Locked/Protected: " "🔒"]
print ["🔓 Unlocked/Open: " "🔓"]
print ["🔑 Key/Access: " "🔑"]

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

print "^/TEST MATHEMATICAL & TECHNICAL:"
print ["∞ Infinity: " "∞"]
print ["± Plus/Minus: " "±"]
print ["≈ Approximately: " "≈"]
print ["≠ Not equal: " "≠"]
print ["≤ Less/Equal: " "≤"]
print ["≥ Greater/Equal: " "≥"]
print ["° Degree: " "°"]
print ["µ Micro: " "µ"]

print "^/TEST BOX DRAWING CHARACTERS:"
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

print "^/TEST CONTEXT USAGE EXAMPLES:"
print "✅ PASSED: All tests completed successfully"
print "❌ FAILED: 3 critical violations found"
print "⚠️  WARNING: Consider reviewing this code"
print "🔍 Scanning directory for violations..."
print "📊 Processed 42 files in 1.2 seconds"
print "🔧 Running validation tools..."
print "💡 TIP: Use quick check for faster validation"
print "🚀 Ready for deployment!"

print "^/Likely printable: ✅ ❌ ⚠️  ★ ☆ ⚡ ⏱️ ⏳ ⬆️ ⬇️ ✨ ✏️❓∞ ± ≈ ≠ ≤ ≥ ° µ  ┌ ┐ └ ┘ │ ─ ├ ┤ ┬ ┴ ┼"
print "Likely unprintable: 🎉 📊 📋 🔧 🎯 📝 💡 🚀 🔍 🔄 🛑 🚨 🔥 🚫 💤 💾 📂 📄 📁 📈 📉 🌐 📶 🔗 👤 🔒 🔓 🔑 📚 📏 🏷️"

print "=== Unicode printability DEMO COMPLETE ==="
print "Examine the above output to see which characters display correctly."
```

---

A Unicode printability test reveals important insights:

✅ TERMINAL-COMPATIBLE CHARACTERS (PowerShell and Linux BASH):

Status indicators: ✅ ❌ ⚠️ (our approved set)
Simple symbols: • → ← ↑ ↓ ✓ ✗ ★ ☆ ⚡ ⏱️ ⏳ ⬆️ ⬇️ ✨
Mathematical: ∞ ± ≈ ≠ ≤ ≥ ° µ
Box drawing: ┌ ┐ └ ┘ │ ─ ├ ┤ ┬ ┴ ┼


❌ TERMINAL-INCOMPATIBLE (Display as �):

Most emoji characters: 🎉 📊 📋 🔧 🎯 📝 💡 🚀 🔍 🔄 🛑 🚨 🔥 🚫 💤 💾 📂 📄 📁 📈 📉 🌐 📶 🔗 👤 🔒 🔓 🔑 📚 ✏️ 📏 🏷️❓
Key Findings:

~40% compatibility rate - Most Unicode characters don't display properly in terminal.
Emoji characters are problematic - Almost all show as � replacement character.
Simple symbols work well - Basic arrows, bullets, stars display correctly.
Our current approach is correct - Using only ✅ ❌ ⚠️ for status indicators.

## Best Practices
- Consistency: Use the same icon for identical concepts (e.g., always ❌ for failures).
- Accessibility: Pair icons with text (e.g., ✅ PASSED not just ✅).
- Context: Choose universally recognizable symbols (e.g., 📂 for folders is clearer than 📁).
- Sparingly: Overuse reduces impact, reserve for key statuses.

---
The provided information accurately describes a known Unicode rendering issue with the ⚠️ (warning sign) emoji, particularly in terminal and console environments. Below, I outline the key aspects of the issue, confirming their validity based on established technical details and documented reports.

### Composition and Unicode Details
The ⚠️ character is indeed a composite emoji, formed by the base character U+26A0 (WARNING SIGN) combined with U+FE0F (VARIATION SELECTOR-16), which specifies an emoji-style presentation rather than a text-style glyph. This composition is standard in Unicode to enable colorful, graphical rendering of the symbol.

### Inconsistent Width and Spacing
Different systems, fonts, terminals, and applications handle the width and spacing of this emoji inconsistently. In monospace environments like terminals, Unicode characters are expected to align based on fixed-width cells. However:
- The ⚠️ emoji is classified as having an East Asian Width of "Wide" (occupying two character cells in some contexts), but rendering engines may treat it as a single-width character or fail to account for its composite nature.
- This leads to alignment and spacing problems, such as overlapping text or irregular gaps in console output.
- Variations arise from differences in terminal emulators (e.g., iTerm2, GNOME Terminal, or Vim-integrated terminals), font support, and operating system Unicode handling. For instance, terminals may disagree on the emoji's width, causing misalignment in scripts or command-line interfaces.

### Behavior in Copy/Paste Scenarios
The observation that copy/paste operations resolve the issue is correct. Text editors and modern applications often employ more sophisticated rendering engines (e.g., those supporting full Unicode emoji sequences) that consistently handle the character's width and composition. In contrast, terminals prioritize monospace text and may lack robust emoji support, leading to the discrepancies noted.

### Alignment with Described Screenshot Evidence
Assuming the screenshot illustrates correct rendering for ✅ (CHECK MARK BUTTON, U+2705) in "PASSED" and ❌ (CROSS MARK, U+274C) in "FAILED," but irregular spacing for ⚠️ in "WARNING," this aligns with reported patterns. The ✅ and ❌ emojis are typically single-width or more consistently handled in terminals, while ⚠️ frequently exhibits the width inconsistency described.

This issue is not isolated to ⚠️ but affects various emojis in terminal contexts, though the warning sign is commonly cited due to its use in error messaging and scripts. If additional details from a specific screenshot or environment are available, further analysis could refine this confirmation.

The yellow dot Unicode character is not a viable option to replace the warning triangle sign:
```
=== Unicode Character Display Test ===
Testing yellow dot character:
Yellow dot:  �
Testing other status indicators:
Green check:  ✅
Red X:  ❌
Warning triangle:  ⚠️
Testing in validation context:
� WARNING: This is a warning message
✅ PASSED: This is a success message
❌ FAILED: This is a failure message
=== Test Complete ===
```
