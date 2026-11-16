# 02 · The setup questions (one batch)

**What and why:** find out what the user works on and how they want the AI to work, in one go, so the rest of the
setup fits them. Their answers become the first entries in their decision log (step 5) and the rules every session
follows.

Ask all of this **in one message**, numbered, with your recommended answer in brackets where there is one. Tell them
"defaults" is a fine answer for anything they don't care about. Keep it readable: short lines, plain words.

## The questions

**A. About you**

1. What name should go in the notes? (A first name or a handle is fine.)
2. How comfortable are you with: the command line, Git, Docker? (new / some / comfortable, for each)
3. Should I explain things as we go? [yes, briefly]

**B. Your work**

4. What kinds of work do you do? (Pick any.) Websites or web apps · WordPress / WooCommerce · Shopify or another
   hosted store · mobile apps (Android / iOS / Flutter / React Native) · games, 3D or characters (Unity, Unreal,
   Godot, Blender, Character Creator…) · video or audio · desktop software · data, scripts or AI/ML · custom work for
   clients · something else.
5. Which projects should we set up now? For each: a name, what it is, and where its code lives today (nowhere yet /
   a folder on this computer / GitHub / only on a server or host). Which one first? [the one you work on most]
6. Is anything **live** (a website, store, app or service people use right now)? For each: how changes reach it today
   (by hand, FTP, a host panel, Git, an app store), and who besides you can change it.
7. Is any of it a client's? (Then their data and their say come first, and we keep each client apart.)

**C. How the AI should work.** These are the rules the original workflow runs on, in its owner's words. Keep them as
they are, change the wording, or drop any. Whatever you choose is quoted, with today's date, in your rulebook.

8. "Work autonomously and keep going. Never stop to wait for me while anything else can be done." [keep]
9. "When you hit a decision only I can make: add it to OWNER-QUESTIONS.md (number, date, the question in plain
   words, why it matters, what waits on it, your recommended default), commit it, and move on to other work. Batch
   questions; don't drip them." [keep]
10. "When I answer, record the answer as a decision (next D-number), mark the question answered, and act on it right
    away." [keep]
11. "Report to me only at milestones: a deploy, a serious bug, or a batch of new questions. Keep it plain and short."
    [keep, or say how often you want updates]
12. "Never guess. Check facts, or ask; say plainly what is not checked." [keep]
13. "Everything that can be tested locally is tested locally, not on GitHub, unless it's something only GitHub does."
    [keep]
14. "Fix bugs in the code. Don't ask me to work around a code defect with configuration." [keep]
15. "Testing is never cut short to ship sooner." [keep]
16. For live systems: "Live changes only through rehearsed workflows: rehearse on a local copy first, dry run first,
    backup first, and only with my go for that change." [keep, if anything is live]
17. Anything else you always want, or never want? (Examples: "never touch the billing settings", "always show me a
    screenshot of UI changes", "no new dependencies without asking".)

**D. Tools and accounts** (details come in later steps; just a quick yes/no now)

18. GitHub: do you have an account? Should projects get a **private** GitHub copy for backup and phone access? Should
    GitHub ever run releases or deploys? [private backup yes; releases later, when one is near]
19. Codex: do you have a ChatGPT plan with Codex, and do you want it as a second worker? [only if you already pay for
    it; Claude alone is enough to start]
20. Other tools you'll want connected (video editor, game engine, design tool, store admin, hosting, any service):
    list whatever comes to mind. [we go through these properly in step 12]

**E. Your computer** (I'll recommend numbers from step 1's report)

21. How much of the computer may Docker use? [Windows: about half the RAM and 60% of the processor threads, set in
    `.wslconfig`. Mac: Docker Desktop's Resources settings.]
22. How many Docker jobs may run at once, and how much memory each? [from the RAM: 1 job under 16 GB, 2–3 at 16 GB,
    4–5 at 32 GB+; 4 GB per container]
23. If Codex joins: how should Docker jobs be split between Claude and Codex? [half each; when one is idle the other
    may use more; a slot that frees up goes to whichever agent is waiting; no racing]

**F. Names and folders**

24. Name and email for Git commits? [the name you want public; for the email, GitHub's private "noreply" address, so
    your real email never appears in public commit history: step 4 shows how to find it]
25. Where should projects live? [Windows `C:\Users\<you>\GitHub\`, Mac/Linux `~/GitHub/`]
26. Where should local-only data live: test results, builds, copies of live sites? It never goes into Git.
    [`C:\Users\<you>\Dev-local\` or `~/Dev-local/`]
27. Adopt the universal phase and versioning rule? It numbers work as phases (`1.4.2.1`, `1.4.2.2`), fixes as
    letters (`1.4.2.2a`) and carries itself into every handoff between agents. The full text is in
    `templates/UNIVERSAL-PHASE-VERSIONING-AND-HANDOFF-RULE.md`. [yes]

## After they answer

1. Read the clock. Write every answer into `my-setup/PROGRESS.md` under "Answers", with the date and time. Quote
   their own words for anything in section C, and for any rule they wrote themselves.
2. If an answer is unclear, ask about that one only, once, and carry on with what is clear.
3. Summarize back in five lines or fewer: what you'll install, what you'll set up first, which rules they chose.
4. Mark step 2 done.

The answers become decisions `D-001`, `D-002`, … in step 5. Don't invent answers they didn't give; where they said
"defaults", record "default accepted" and the default's text.
