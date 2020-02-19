let g:gzmappings = {}
let g:gzmappings.n = { }
let g:gzmappings.i = { }
let g:gzmappings.c = { }
let g:gzmappings.o = { }

let g:gzmappings.vc = { }
let g:gzmappings.vl = { }
let g:gzmappings.vb = { }

" Compile a command to sleep for &timeoutlen seconds
execute printf("command! Sleep sleep %d m", &timeoutlen) 
function! Getchars()
    " Read chars until no chars are available within &timeoutlen seconds
    let l:keys = nr2char(getchar())  " Get an initial character
    while 1                          " Keep reading chars
        if getchar(1) == 0           " If no chars queued up, wait for timeoutlen
            :Sleep
            if !getchar(1)           " If waited and still no chars, exit
                break
            endif
        endif

        let l:keys .= nr2char(getchar())
    endwhile
    return l:keys
endfunction

function! GetGZMapping(mode, key)
    " Resolve a mapping to a set of keystrokes or an expression.
    " let l:mode = ModeToVisualMap(a:mode)
    let l:mode = get({ 'v' : 'vc', 'V' : 'vl', "\<C-v>" : 'vb' }, a:mode, a:mode)
    let l:map = g:gzmappings[l:mode]
    if (has_key(l:map, a:key))
        let l:map = l:map[a:key]
        if l:map.expr 
            return [eval(l:map.rhs), 0]
        else
            return [l:map.rhs, l:map.rec]
        endif
    endif
    return [a:key, 0]
endfunction

function! GZMap(recmode, mode, options)
    let l:options = copy(a:options)
    let l:mapping = { 'rec': a:recmode, 'expr': 0, 'rhs': '' }

    " Check and consume expr mapping
    if l:options[0] == '<expr>'
        let l:mapping.expr = 1
        let l:options = l:options[1:]
    endif

    let l:trigger = eval('"'. escape(l:options[0], '\"<') .'"')
    let l:keys = join(l:options[1:])
    let l:mapping.rhs = eval('"'. escape(l:keys, '\"<') .'"')
    if a:mode == 'v'
        let g:gzmappings['vc'][l:trigger] = l:mapping
        let g:gzmappings['vb'][l:trigger] = l:mapping
        let g:gzmappings['vl'][l:trigger] = l:mapping
    else
        let g:gzmappings[a:mode][l:trigger] = l:mapping
    endif
endfunction

function! GZ(opmode)
    let l:keypress = Getchars()
    if (l:keypress == "\<Esc>")
        return l:keypress
    endif

    let [l:keystream, l:recmode] = GetGZMapping((a:opmode ? 'o' : mode()), l:keypress)
    echo l:keystream
    call feedkeys(l:keystream, (l:recmode ? 'm' : 'n'))
    return ""
endfunction

if exists('g:gz')
    " Call GZ() whenever the key(s) <g:gz> are pressed in succession.
    execute printf("nmap  <expr> %s GZ(0)", eval('"'.escape(g:gz, '\">').'"'))
    execute printf("vmap  <expr> %s GZ(0)", eval('"'.escape(g:gz, '\">').'"'))
    execute printf("map! <expr> %s GZ(0)", eval('"'.escape(g:gz, '\">').'"'))

    " Map op-pending separately to avoid using clobbering with mode()
    execute printf("omap <expr> %s GZ(1)", eval('"'.escape(g:gz, '\">').'"'))
else
    nmap  <expr> gz GZ(0)
    vmap  <expr> gz GZ(0)
    map!  <expr> gz GZ(0)

    " Map op-pending separately to avoid using clobbering with mode()
    omap  <expr> gz GZ(1)
endif

" Define commands for <gz> mappings
" Build commands for normal, visual, operator, and replace modes.
for mode in ['n', 'i', 'c', 'v', 'vc', 'vl', 'vb', 'o']
    execute printf("command! -nargs=+ Gz%smap call GZMap(1, '%s', [<f-args>])", mode, mode)
    execute printf("command! -nargs=+ Gz%snoremap call GZMap(0, '%s', [<f-args>])", mode, mode)
endfor
