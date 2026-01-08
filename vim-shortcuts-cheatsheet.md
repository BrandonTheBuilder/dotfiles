# Vim Shortcuts (Leader: `Space`)

## LSP (CoC.nvim)
`gd` Definition | `gy` Type def | `gi` Implementation | `gr` References | `K` Docs | `<leader>rn` Rename | `<leader>d` Diagnostics | `<leader>cf` Format | `Ctrl-n` Complete | `Tab`/`Shift-Tab` Navigate completions

## File Navigation (FZF)
`<leader>f` Files | `<leader>b` Buffers | `<leader>g` Grep | `<leader>l` Lines | `<leader>h` History
*In FZF:* `Ctrl-j/k` navigate, `Enter` select, `Esc` cancel

## Comments (vim-commentary)
`gcc` Toggle line | `gc{motion}` Comment motion | `gc` (visual) Comment selection

## Surround (vim-surround)
`ys{motion}{char}` Add | `cs{old}{new}` Change | `ds{char}` Delete | `S{char}` (visual) Surround
*Chars:* `"'` `` ` `` `(){}[]` `t` (tag)

## Custom
`<leader>w` Save | `<leader>q` Quit | `<leader>/` Clear highlight

## Navigation
`0` Start | `^` First char | `$` End | `gg` Top | `G` Bottom | `{}` Paragraph | `Ctrl-u/d` Half page | `*` Search word | `%` Match bracket

## Text Objects (use with d/c/y/v)
`iw` inner word | `aw` around word | `i"'` `` ` `` inside quotes | `a"'` `` ` `` around quotes | `i({[` inside brackets | `a({[` around brackets | `ip` inner paragraph | `ap` around paragraph
