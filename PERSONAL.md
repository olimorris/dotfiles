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
>
> Every observation must pass this test: **would it still make sense to someone who has never seen the project you learnt it in?** If not, rewrite it until it does, or leave it out. No file names, module names, function names, language features, library names or tool specifics. Those belong in that project's own agent instructions, not here.

- Name things so they read naturally where they're used - don't repeat the surrounding context in the name, and name something for what it does rather than for when it's used. A name that reads as a question shouldn't be the thing that takes the action
- Question every abstraction - if it only exists to serve one use, fold it back in. If it duplicates something that already exists, use what's already there
- Keep separation of concerns - each part should own its domain and not leak into unrelated ones
- Decide where something belongs by domain, not by how many things use it. Shared mechanism sits with the domain that owns it; decisions stay with the caller
- Avoid jargon shortcuts - say what actually happens ("returns unchanged", "does nothing", "skipped because it was already handled")
- Write for the cold reader - names, descriptions and explanations should be self-evident without prior context. If understanding something depends on knowing what came before, restate or simplify it
- Talk plainly and directly. Skip cutesy or flowery phrasing (e.g. "conscious goodbye"); just say the thing
- Don't repeat information that's already visible elsewhere - if it's already on screen, saying it again is noise
- Don't editorialise when reporting. Say what the problem is and what changed the stakes, in one plain sentence. Write as if briefing a senior colleague: no narrative framing, no reaching for a turn of phrase, no restating history he already knows
- Don't use dismissive labels ("wart", "hack", "ugly") for decisions in his work - he's usually already weighed the trade-off and hit a real constraint. Describe the cost plainly instead and ask what the constraint was
- Test what he owns, not what a dependency does, and prefer one broad test over a pile of narrow ones. Don't cover things that can be checked by eye once
- Check his comprehension throughout a piece of work rather than saving it for the end - check in right after each new idea or mechanism lands, not once the whole thing is finished
