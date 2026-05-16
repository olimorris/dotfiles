# PERSONAL.md

## About

`PERSONAL.MD` is a reference file for agents to understand my working style, technical preferences, and contextual details about me. Check this before starting work and keep it updated as you learn more about me through our interactions.

## Me

- I'm Oli
- I live in London, UK
- I created and maintain [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim) and am an avid Neovim user

## Working preferences

> [!NOTE]
> Agents: Do NOT update this section

I'm a very collaborative worker - so if there are things you're not sure on, or you want to bounce ideas off me, that's probably going to get the best out of both of us. I don't want you to default agree with me, I want you to help me get to the very best end product/solution for every conversation we have. Sometimes that means challenging me and sometimes that means being challenged by me. To summarize, I'm happiest when we've robustly challenged one another's thinking and come to a shared understanding and agreement on the best way forward.

I work best when we "start at the top, and work back". That is, I like to solve a problem by thinking of how it will look  and feel to the end user. Sometimes, I might write the desired API in the docs before I've built it. Or, I might scaffold out the command that the user will execute to run the feature.

## Agentic memory

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
- Always sort table properties in alphabetical order
- Run make commands directly (e.g. `make test`), not `cd /path && make test`
- Avoid jargon shortcuts like "no-op" in code, comments, commit messages, and chat — say what the code actually does ("returns unchanged", "does nothing", "skipped because already edited")
- Tests prefer inline data over semantic helpers — write message tables, adapter structs, etc. directly in each test rather than building factories like `tagged_user(tag, content)` or `fake_chat(messages)`. Tests can be long, clunky, repetitive; readability beats conciseness because the reader shouldn't have to investigate a helper to understand what's being tested
- Test comments: present tense, active voice, concise — no em-dashes, no "should be" prefixes, drop trailing narration that just describes the next assertion. Keep intent comments that explain *why* you're asserting
- Use the project's canonical vocabulary in naming — in CodeCompanion that's "chat"/"messages", not "conversation". Constants name their unit (`min_token_savings = 10000`, not `clear_at_least`). Pick domain-specific verbs over generic ones (`compaction.compact()` over `compaction.apply()`); avoid verbs with hidden connotations (`commit` suggests stack/Git semantics — prefer `update_*` for one-shot replacements). When two functions form a semantic pair, name them symmetrically (`messages_to_summarize` ↔ `messages_to_retain`)
