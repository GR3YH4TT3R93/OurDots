![image](https://github.com/user-attachments/assets/2610cc4a-41f4-4bf7-8c80-0405aafd2033)

# Our Dotfiles

A 🔋 included [SwayFX](https://github.com/WillPower3309/swayfx) config primarily written for Arch (with your contribution it can support your distro too!)

A few of OurDotfiles features:

- SwayFX (Sway with Eye Candy!)
- Neovim (with 🔋 included IDE-like config)
- Rofi
- Wezterm (with included oh-my-zsh + Powerline10k theme)
- Yazi (Set as your default file manager with the help of [xdg-desktop-portal-termfilechooser](https://github.com/GermainZ/xdg-desktop-portal-termfilechooser)!)
- i3status-rs
- tmux
- btrfs snapshotting (If you're using btrfs, it will automagically set up [Snapper](https://wiki.archlinux.org/title/Snapper) as well as [grub-btrfs](https://github.com/Antynea/grub-btrfs) and [snap-pac](https://github.com/wesbarnett/snap-pac) for easier recovery from borked updates!)
- shared games folder (on seperate subvolume for improved space savings while gaming and utilizing snapshots!)

## Clone Dotfiles As Bare Repo

## THE NEXT LINE AUTOMATICALLY RUNS THE [INSTALLER](https://github.com/GR3YH4TT3R93/OurDots/blob/main/.config/scripts/install.sh) PLEASE READ BEFORE RUNNING

    curl -sSL https://raw.githubusercontent.com/GR3YH4TT3R93/OurDots/main/.config/scripts/install.sh | bash

## Clone Dotfiles as Normal Repo

    git clone --recurse-submodules https://github.com/GR3YH4TT3R93/OurDots.git ~/

## Run Install Script

    ~/.config/scripts/install.sh

## For both methods set new remote

    # bare:
    b remote set-url https://your.git.fork/repo

    # regular:
    git init
    git config --local status.showUntrackedFiles no
    git remote add origin https://your.git.fork/repo

## Install Nvim Plugins

    e # open editor

# 📚 Usage

Use `ESC` or `CTRL-[` to enter `Normal mode`.

But some people may like the custom escape key such as `jj`, `jk` and so on,
if you want to custom the escape key, you can learn more from [here](#custom-escape-key).

## History

- `ctrl-p` : Previous command in history
- `ctrl-n` : Next command in history
- `/` : Search backward in history
- `n` : Repeat the last `/`

## Mode indicators

`Normal mode` is indicated with block style cursor, and `Insert mode` with
beam style cursor by default.

## Vim edition

In `Normal mode` you can use `vv` to edit current command line in an editor
(e.g. `vi`/`vim`/`nvim`...), because it is bound to the `Visual mode`.

You can change the editor by `ZVM_VI_EDITOR` option, by default it is
`$EDITOR`.

## Movement

- `$` : To the end of the line
- `^` : To the first non-blank character of the line
- `0` : To the first character of the line
- `w` : [count] words forward
- `W` : [count] WORDS forward
- `e` : Forward to the end of word [count] inclusive
- `E` : Forward to the end of WORD [count] inclusive
- `b` : [count] words backward
- `B` : [count] WORDS backward
- `t{char}` : Till before [count]'th occurrence of {char} to the right
- `T{char}` : Till before [count]'th occurrence of {char} to the left
- `f{char}` : To [count]'th occurrence of {char} to the right
- `F{char}` : To [count]'th occurrence of {char} to the left
- `;` : Repeat latest f, t, F or T [count] times
- `,` : Repeat latest f, t, F or T in opposite direction

## Insertion

- `i` : Insert text before the cursor
- `I` : Insert text before the first character in the line
- `a` : Append text after the cursor
- `A` : Append text at the end of the line
- `o` : Insert new command line below the current one
- `O` : Insert new command line above the current one

## Surround

There are 2 kinds of keybinding mode for surround operating, default is
`classic` mode, you can choose the mode by setting `ZVM_VI_SURROUND_BINDKEY`
option.

1. `classic` mode (verb->s->surround)

- `S"` : Add `"` for visual selection
- `ys"` : Add `"` for visual selection
- `cs"'` : Change `"` to `'`
- `ds"` : Delete `"`

2. `s-prefix` mode (s->verb->surround)

- `sa"` : Add `"` for visual selection
- `sd"` : Delete `"`
- `sr"'` : Change `"` to `'`

Note that key sequences must be pressed in fairly quick succession to avoid a timeout. You may extend this timeout with the [`ZVM_KEYTIMEOUT` option](#readkey-engine).

#### How to select surround text object?

- `vi"` : Select the text object inside the quotes
- `va(` : Select the text object including the brackets

Then you can do any operation for the selection:

1. Add surrounds for text object

- `vi"` -> `S[` or `sa[` => `"object"` -> `"[object]"`
- `va"` -> `S[` or `sa[` => `"object"` -> `["object"]`

2. Delete/Yank/Change text object

- `di(` or `vi(` -> `d`
- `ca(` or `va(` -> `c`
- `yi(` or `vi(` -> `y`

## Increment and Decrement

In normal mode, typing `ctrl-a` will increase to the next keyword, and typing
`ctrl-x` will decrease to the next keyword. The keyword can be at the cursor,
or to the right of the cursor (on the same line). The keyword could be as
below:

- Number (Decimal, Hexadecimal, Binary...)
- Boolean (True or False, Yes or No, On or Off...)
- Weekday (Sunday, Monday, Tuesday, Wednesday...)
- Month (January, February, March, April, May...)
- Operator (&&, ||, ++, --, ==, !==, and, or...)
- ...

For example:

1. Increment

- `9` => `10`
- `aa99bb` => `aa100bb`
- `aa100bc` => `aa101bc`
- `0xDe` => `0xdf`
- `0Xdf` => `0Xe0`
- `0b101` => `0b110`
- `0B11` => `0B101`
- `true` => `false`
- `yes` => `no`
- `on` => `off`
- `T` => `F`
- `Fri` => `Sat`
- `Oct` => `Nov`
- `Monday` => `Tuesday`
- `January` => `February`
- `+` => `-`
- `++` => `--`
- `==` => `!=`
- `!==` => `===`
- `&&` => `||`
- `and` => `or`
- ...

2. Decrement:

- `100` => `99`
- `aa100bb` => `aa99bb`
- `0` => `-1`
- `0xdE0` => `0xDDF`
- `0xffFf0` => `0xfffef`
- `0xfffF0` => `0xFFFEF`
- `0x0` => `0xffffffffffffffff`
- `0Xf` => `0Xe`
- `0b100` => `0b010`
- `0B100` => `0B011`
- `True` => `False`
- `On` => `Off`
- `Sun` => `Sat`
- `Jan` => `Dec`
- `Monday` => `Sunday`
- `August` => `July`
- `/` => `*`
- `++` => `--`
- `==` => `!=`
- `!==` => `===`
- `||` => `&&`
- `or` => `and`
- ...
