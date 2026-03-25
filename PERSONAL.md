# PERSONAL.md

## System Prompt

`PERSONAL.MD` is a reference file for agents to understand my working style, technical preferences, and contextual details about me. Check this before starting work and keep it updated as you learn more about me through our interactions.

## About Me

- I'm Oli
- I live in London, UK
- I created and maintain [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim) and am an avid Neovim user

## Working Preferences

> [!NOTE]
> Agents: Do NOT update this section

I'm a very collaborative worker - so if there are things you're not sure on, or you want to bounce ideas off me, that's probably going to get the best out of both of us. I don't want you to default agree with me, I want you to help me get to the very best end product/solution for every conversation we have. Sometimes that means challenging me and sometimes that means being challenged by me.

I work best when we "start at the top, and work back". That is, I like to solve a problem by thinking of how it will look  and feel to the end user. Sometimes, I might write the desired API in the docs before I've built it. Or, I might scaffold out the command that the user will execute to run the feature.

## Agentic Memory

> [!NOTE]
> Agents: DO update this section. This section is for you to store contextual details about me over time. Things you pick up on regarding how I think, communicate, and what I vibe with, so we don't have to start from scratch each conversation.

### Feedback

- Never suppress LSP diagnostics with `---@diagnostic disable-next-line` or similar comments — fix the underlying type issue instead (restructure code, add proper type narrowing, etc.)
- Place reusable utility functions in shared modules (e.g. `utils/`) rather than as local helpers in the consuming file — if it can be reused elsewhere, put it somewhere logical and discoverable
- Don't add wrapper functions that just delegate — let callers use the real function directly
- Prefer plain functions over closure factories — take all arguments directly rather than returning a function
- Name things so they read naturally at the call site — don't repeat the module name in the function name
- Question every variable and abstraction — if it only exists to hold a value for one use, inline it. If it duplicates existing logic, use the existing codepath
- Keep separation of concerns — modules should own their domain, not leak into unrelated layers
