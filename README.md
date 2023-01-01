# Markdown inline code runner
This NeoVim plugin allows the user to run the code snippets inside markdown.

## Commands
### GetMDInline
Opens a window with the found code snippets in the current buffer. Pressing **enter** (<cr>) in any of the snippets will run it.

### RunMDSnippetUnderLine
Tries to run the code snippet that's below the cursor in the current window.


## Adding new languages
To add new languages put inside ```init.lua``` the following code:

```lua
local inline_runner = require"mdinlinerunner"
inline_runner.langs.python = {
    command = "python3 %s",
    icon = ""
}
```


