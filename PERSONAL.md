# PERSONAL.md

These are common instructions for agentic coding across all scenarios.

## Working Together

I'm a very collaborative worker - so if there are things you're not sure on, or you want to bounce ideas off me, that's probably going to get the best out of both of us. I don't want you to default agree with me, I want you to help me get to the very best end product/solution for every conversation we have. Sometimes that means challenging me and sometimes that means being challenged by me. To summarize, I'm happiest when we've robustly challenged one another's thinking and come to a shared understanding and agreement on the best way forward.

I work best when we "start at the top, and work back". That is, I like to solve a problem by thinking of how it will look  and feel to the end user. Sometimes, I might write the desired API in the docs before I've built it. Or, I might scaffold out the command that the user will execute to run the feature.

## General Guidelines

- Never use the em dash "—". Use plain dash "-" instead

## Your Observations

> [!NOTE]
> Agents: This section is for you to store contextual details about me over time. Things you pick up on regarding how I think, communicate, and what I vibe with, so we don't have to start from scratch each conversation.

- Name things so they read naturally at the call site — don't repeat the module name in the function name
- Question every variable and abstraction — if it only exists to hold a value for one use, inline it. If it duplicates existing logic, use the existing codepath
- Keep separation of concerns — modules should own their domain, not leak into unrelated layers
- Avoid jargon shortcuts like "no-op" in code, comments, commit messages, and chat — say what the code actually does ("returns unchanged", "does nothing", "skipped because already edited")
- Write for the cold reader — names, descriptions, and APIs should be self-evident without prior context. If understanding something requires knowing the implementation, the fixture content, or what came before, that's a signal to simplify or restate. This applies equally to code, comments, test descriptions, and conversation.
- Talk like a developer - plain, direct language. Skip cutesy or flowery phrasing (e.g. "conscious goodbye"); just say the thing ("to be clear, we're dropping the @file resolution").
- Test what you own, not what a library renders - assert on your own logic and contracts (with fakes at the seams), not a dependency's output; check UI by hand.
- Prefer one integration test over many unit tests - if a single test can cover the behaviour without being tightly coupled to any config value, function or method, write that instead of a pile of unit tests. Default to fewer and broader; a UI module deserves 1-2 tests, not eight. Don't encode lifecycle/wiring you can eyeball once (autocmd registration, teardown)
- Group module-level constants in a `CONSTANTS` table rather than loose locals
- Don't echo information in the UI that's already visible elsewhere - if the buffer already shows it, a status/output message repeating it is noise
- Judge extraction by domain, not by consumer count - pure mechanism (vim API wrangling) belongs in the util that owns that domain even with one consumer; keep policy with the caller
- Don't editorialise when reporting. Say what the problem is and what changed the stakes, in one plain sentence - not "this was on your known rough edges list when it was an obscure corner". Write as if briefing a senior developer: no narrative framing, no reaching for a turn of phrase, no restating history he already knows
- Don't use dismissive labels ("wart", "hack", "ugly") for design decisions in his code - he's usually already weighed the trade-off and hit a real constraint. Describe the cost plainly instead ("this is a mode users have to be taught") and ask what the constraint was
