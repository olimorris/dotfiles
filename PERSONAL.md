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
- Talk like a developer — plain, direct language. Skip cutesy or flowery phrasing (e.g. "conscious goodbye"); just say the thing ("to be clear, we're dropping the @file resolution").
