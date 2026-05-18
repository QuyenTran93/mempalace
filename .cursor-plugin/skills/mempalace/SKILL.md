---
name: mempalace
description: MemPalace — searchable memory palace (MCP). Use when the user asks about past conversations, people, projects, decisions, "what did we decide", "last time", mining, searching memories, or palace setup. Always call mempalace_search or mempalace_kg_query before answering from memory — never guess.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# MemPalace

A searchable memory palace for AI — mine projects and conversations, then search them semantically.

## Prerequisites

Ensure `mempalace` is installed:

```bash
mempalace --version
```

If not installed (uv recommended):

```bash
uv tool install mempalace   # or: pip install mempalace
```

## Usage

MemPalace provides dynamic instructions via the CLI. To get instructions for any operation:

```bash
mempalace instructions <command>
```

Where `<command>` is one of: `help`, `init`, `mine`, `search`, `status`.

Run the appropriate instructions command, then follow the returned instructions step by step.
