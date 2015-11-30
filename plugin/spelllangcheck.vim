" Vim global plugin for choosing spelllang automatically
" Last Change:	August 2014
" Maintainer:	Robert Künnemann <robert@kunnemann.de>
" License:	VIM License
" Configuration: populate the following list. In case the smallest element of
" let g:spelllangcheck_list = [ 'de', 'fr', 'en' ]
" spelling mistake is ambiguous, the earliest in the list is chosen.

if exists("g:loaded_spelllangcheck")
  finish
endif
let g:loaded_spelllangcheck = 1

let g:spelllangcheck_list = [ 'de', 'fr', 'en' ]

function! <SID>CountSpellingMistakes(lang)
    let &spelllang = a:lang
    let mycount=0
    mark `
    normal gg
    while 1
        " count spelling mistakes per line
        " count how often until spellbadword returns the zerostring
        while spellbadword() != ['','']
            let mycount=mycount+1
        if line("w$") == line(".")
            break
        else
            " go to next line
            normal +
        endif
    endwhile
    normal ``
    return mycount
endfunction

function! <SID>GuessSpelllang()
    let minimum = 100000
    let selection = 0 
    for i in range(len(g:spelllangcheck_list))
        " count spelling errors
        let mycount = <SID>CountSpellingMistakes(g:spelllangcheck_list[i])
        if mycount < minimum
            let minimum=mycount
            let selection = i
        endif
    endfor
    return selection
endfunction

function! <SID>CountWords() 
  let lnum = 0
  let n = 0
  while lnum <= line('$')
    let n = n + len(split(getline(lnum)))
    let lnum = lnum + 1
  endwhile
  return n
endfunction

function! <SID>SetSpell()
    if &spell==1
        if (line('$') > 20 && exists("s:old_lc"))
            if abs(line('$') - s:old_lc) > line('$') / 10
                let sel = <SID>GuessSpelllang()
                let &spelllang = g:spelllangcheck_list[sel]
                let s:old_lc=line('$')
                let s:old_wc=<SID>CountWords()
            endif
        else
            let wc=<SID>CountWords()
            if exists("s:old_wc")
                if abs (s:old_wc - wc) > wc / 10
                    let sel = <SID>GuessSpelllang()
                    let &spelllang = g:spelllangcheck_list[sel]
                endif 
            else
                let sel = <SID>GuessSpelllang()
                let &spelllang = g:spelllangcheck_list[sel]
            endif
                let s:old_lc=line('$')
                let s:old_wc=wc
        endif
    else
        echo "'spell' disabled..."
    endif
endfunction

 if !exists(":SetSpelllang")
   command -nargs=0  SetSpelllang  :call <SID>SetSpell()
 endif

" think we can have * if it is called in a filetype plugin
" autocmd! InsertLeave *.txt :SetSpelllang
