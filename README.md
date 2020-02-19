# ＧＺ．ＶＩＭ

gz.vim is a very small plugin designed to give a sub-mode/pseudo-operator
similar to the behaviour of the `<g>` or `<z>` keys. It's kind of like using
`<Leader>`, except it will wait for at least one keypress (like `<g>` or `<z>`),
even if you have `timeoutlen` set. For instance, if you use a very short
|ttimeout| value like I do then mapping using `<g>` as a pseudo-leader alà 

```vim
    nnoremap g<key> ...
```

won't work in quite the way you want it to. Mapping keys within the
submode can be achieved using the commands

```vim
    :Gzn[nore]map [<expr>] {lhs} {rhs} mapmode-n 
    :Gzi[nore]map [<expr>] {lhs} {rhs} mapmode-i 
    :Gzc[nore]map [<expr>] {lhs} {rhs} mapmode-c 
    :Gzo[nore]map [<expr>] {lhs} {rhs} mapmode-o 

    :Gzv[nore]map  [<expr>] {lhs} {rhs} mapmode-x (visual)       
    :Gzvc[nore]map [<expr>] {lhs} {rhs} mapmode-x (visual char)  
    :Gzvl[nore]map [<expr>] {lhs} {rhs} mapmode-x (visual line)  
    :Gzvb[nore]map [<expr>] {lhs} {rhs} mapmode-x (visual block) 
```

This behaves in much the same way as normal mappings: When entering gz-mode
from another mode, that mode is recorded. The {lhs}s specified for that mode
then apply. The `<expr>` modifier can be used to make the {rhs} of the mapping
be evaluated and the resulting string treated as a set of keypresses as if the
user typed them. If the keys are not mapped, the default behaviour for that
mode applies. e.g. gzd becomes d when in normal, visual, etc. The 'nore'
variants for each command behave the same way as the variants of commands
(like `nmap`) you might be familiar with.

The Gzvmap command variants allow for mapping keys independently in each
variant of visual mode. Thus, the same key combination can mean different
things based on vim being in visual block (`blockwise-visual`), visual line
(`linewise-visual`) and regular visual (`characterwise-visual`) modes. If this
behaviour is undesired, you can just specify `Gzv[nore]map` to map in all
variants alike.

The leader used to enter gz-mode can be set using the `g:gz` global variable

```vim
    let g:gz = "gz"
```

This should be chosen with care however, as the same key combination is mapped
for use to enter gz-mode regardless of the previous mode. This means for
insert mode and command mode, the key sequence should be something you won't
type often (or ideally, at all). `<gz>` was chosen because it almost never appears in
English, and because it is a multiple character sequence.

Multiple keys can now be mapped e.g.

```vim
    Gzcnoremap jk ...
```

This respects the |timeoutlen| option. This means that at least one key will
be read on entering gz-mode, but any subsequent keys will only be read if
hit in quick successions. This allows

```vim
    Gzcnoremap <key1><key2> ...
```

to be handled differently from

```vim
    Gzcnoremap <key1> ...
    Gzcnoremap <key2> ...
```


TODO:

* ~~Operator pending mappings cannot work. This is due to the behaviour of `mode()`, as executing `mode()` requires changing the mode from operator pending. Thus, we cannot dispatch keypresses based on being in this mode~~

* ~~Currently the {lhs} of a mapping can only be one character. This is due to the behaviour of `getchar()`, meaning only one character worth of input is read, rather than waiting for additional keypresses within the time limit of `ttimeout`~~
