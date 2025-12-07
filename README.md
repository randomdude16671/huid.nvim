# huid.nvim

> [!NOTE]
> **This project is very early stage, and will accept contributions happily, feel free to submit PRs or create issues!**

A platform-agnostic issue tracker built for [Neovim](https://neovim.io/), inspired by [Tsoding](https://github.com/tsoding/)'s Emacs plugin.

---

# Commands

All commands currently available:

- ConvertTodo: Convert a `TODO` comment into a `TASK(<HUID>)` comment.
- PickTasks: INCOMPLETE. DO NOT USE (please).
- NewTask: Make a new task

---

# Installation

> [!NOTE]
> **SETUP IS REQUIRED!!**

## Installation with Lazy.nvim

```lua
{
  "randomdude16671/huid.nvim",
  lazy = true, -- optimize
  cmd = { "ConvertTodo", "NewTask" } -- will add PickTasks and other functions after completion
  opts = {},
}
```

---
