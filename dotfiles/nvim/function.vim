"completion.vim
" ------------------------------------------------------------
" function utility
" ------------------------------------------------------------
function! GetNextString(length)
    let l:str = ""
    for i in range(0,a:length-1)
        let l:str = l:str . getline(".")[col(".")-1+i]
    endfor
    return l:str
endfunction

function! GetPrevString(length)
    let l:str = ""
    for i in range(0,a:length-1)
        let l:str = getline(".")[col(".")-2-i] . l:str
    endfor
    return l:str
endfunction

function! IsAlphabet(char) abort
     let l:charIsAlphabet = (a:char =~ "\a")
     return (l:charIsAlphabet)
endfunction

function! IsFullWidth(char) abort
     let l:charIsFullWidth = (a:char =~ "[^\x01-\x7E]")
     return (l:charIsFullWidth)
endfunction

function! IsNum(char) abort
     let l:charIsNum = (a:char >= "0" && a:char <= "9")
     return (l:charIsNum)
endfunction

function! IsInsideParentheses(prevChar,nextChar) abort
     let l:cursorIsInsideParentheses1 = (a:prevChar == "{" && a:nextChar == "}")
     let l:cursorIsInsideParentheses2 = (a:prevChar == "[" && a:nextChar == "]")
     let l:cursorIsInsideParentheses3 = (a:prevChar == "(" && a:nextChar == ")")
     return (l:cursorIsInsideParentheses1 || l:cursorIsInsideParentheses2 || l:cursorIsInsideParentheses3)
endfunction

function! IsInsideQuotes(prevChar,nextChar) abort
     let l:cursorIsInsideQuotes1 = (a:prevChar == "\"" && a:nextChar == "\"")
     let l:cursorIsInsideQuotes2 = (a:prevChar == "\'" && a:nextChar == "\'")
     return (l:cursorIsInsideQuotes1 || l:cursorIsInsideQuotes2)
endfunction

" ------------------------------------------------------------
" completion setting
" ------------------------------------------------------------
function! InputParentheses(parenthesis) abort
    let l:nextChar = GetNextString(1)
    let l:prevChar = GetPrevString(1)
    let l:parentheses = { "{": "}", "[": "]", "(": ")" }

    let l:nextCharIsEmpty = (l:nextChar == "")
    let l:nextCharIsCloseParenthesis = (l:nextChar == "}" || l:nextChar == "]" || l:nextChar == ")")
    let l:nextCharIsSpace = (l:nextChar == " ")

    if l:nextCharIsEmpty || l:nextCharIsCloseParenthesis || l:nextCharIsSpace || IsInsideQuotes(l:prevChar, l:nextChar)
        return a:parenthesis.parentheses[a:parenthesis]."\<LEFT>"
    else
        return a:parenthesis
    endif
endfunction

function! InputClosingParenthesis(parenthesis) abort
    let l:nextChar = GetNextString(1)
    if l:nextChar == a:parenthesis
        return "\<RIGHT>"
    else
        return a:parenthesis
    endif
endfunction

function! InputQuot(quot) abort
    let l:nextChar = GetNextString(1)
    let l:prevChar = GetPrevString(1)
    let l:cursorIsInsideQuotes = (l:prevChar == a:quot && l:nextChar == a:quot)
    let l:cursorIsInsideParentheses = IsInsideParentheses(prevChar, nextChar)
    let l:nextCharIsEmpty = (l:nextChar == "")
    let l:nextCharIsClosingParenthesis = (l:nextChar == "}") || (l:nextChar == "]") || (l:nextChar == ")")
    let l:prevCharIsAlphabet = IsAlphabet(l:prevChar)
    let l:prevCharIsFullWidth = IsFullWidth(l:prevChar)
    let l:prevCharIsNum = IsNum(l:prevChar)

    if l:cursorIsInsideQuotes
        return "\<RIGHT>"
    elseif l:prevCharIsAlphabet || l:prevCharIsNum || l:prevCharIsFullWidth || l:cursorIsInsideParentheses
        return a:quot.a:quot."\<LEFT>"
    else
        return a:quot
    endif
endfunction

function! InputCR() abort
    let l:nextChar = GetNextString(1)
    let l:prevChar = GetPrevString(1)
    let l:cursorIsInsideParentheses = IsInsideParentheses(l:prevChar, l:nextChar)

    if cursorIsInsideParentheses
        return "\<CR>\t"
    else
        return "\<CR>"
    endif
endfunction

function! InputSpace() abort
    let l:nextChar = GetNextString(1)
    let l:prevChar = GetPrevString(1)
    let l:cursorIsInsideParentheses = IsInsideParentheses(l:prevChar,l:nextChar)

    if l:cursorIsInsideParentheses
        return "\<Space>\<Space>\<LEFT>"
    else
        return "\<Space>"
    endif
endfunction

function! InputBS() abort
    let l:nextChar = GetNextString(1)
    let l:prevChar = GetPrevString(1)
    let l:nextTwoString = GetNextString(2)
    let l:prevTwoString = GetPrevString(2)

    let l:cursorIsInsideParentheses = IsInsideParentheses(l:prevChar,l:nextChar)

    let l:cursorIsInsideSpace1 = (l:prevTwoString == "{ " && l:nextTwoString == " }")
    let l:cursorIsInsideSpace2 = (l:prevTwoString == "[ " && l:nextTwoString == " ]")
    let l:cursorIsInsideSpace3 = (l:prevTwoString == "( " && l:nextTwoString == " )")
    let l:cursorIsInsideSpace = (l:cursorIsInsideSpace1 || l:cursorIsInsideSpace2 || l:cursorIsInsideSpace3)

    let l:existsQuot = (l:prevChar == "'" && l:nextChar == "'")
    let l:existsDoubleQuot = (l:prevChar == "\"" && l:nextChar == "\"")

    if l:cursorIsInsideParentheses || l:cursorIsInsideSpace || l:existsQuot || l:existsDoubleQuot
        return "\<BS>\<RIGHT>\<BS>"
    else
        return "\<BS>"
    endif
endfunction

inoremap <expr> { InputParentheses("{")
inoremap <expr> [ InputParentheses("[")
inoremap <expr> ( InputParentheses("(")

inoremap <expr> } InputClosingParenthesis("}")
inoremap <expr> ] InputClosingParenthesis("]")
inoremap <expr> ) InputClosingParenthesis(")")

inoremap <expr> ' InputQuot("\'")
inoremap <expr> " InputQuot("\"")
"inoremap <expr> <CR> InputCR()
inoremap <expr> <SPACE> InputSpace()
inoremap <expr> <BS> InputBS()


function! s:get_syn_id(transparent)
  let synid = synID(line("."), col("."), 1)
  if a:transparent
    return synIDtrans(synid)
  else
    return synid
  endif
endfunction
function! s:get_syn_attr(synid)
  let name = synIDattr(a:synid, "name")
  let ctermfg = synIDattr(a:synid, "fg", "cterm")
  let ctermbg = synIDattr(a:synid, "bg", "cterm")
  let guifg = synIDattr(a:synid, "fg", "gui")
  let guibg = synIDattr(a:synid, "bg", "gui")
  return {
        \ "name": name,
        \ "ctermfg": ctermfg,
        \ "ctermbg": ctermbg,
        \ "guifg": guifg,
        \ "guibg": guibg}
endfunction
function! s:get_syn_info()
  let baseSyn = s:get_syn_attr(s:get_syn_id(0))
  echo "name: " . baseSyn.name .
        \ " ctermfg: " . baseSyn.ctermfg .
        \ " ctermbg: " . baseSyn.ctermbg .
        \ " guifg: " . baseSyn.guifg .
        \ " guibg: " . baseSyn.guibg
  let linkedSyn = s:get_syn_attr(s:get_syn_id(1))
  echo "link to"
  echo "name: " . linkedSyn.name .
        \ " ctermfg: " . linkedSyn.ctermfg .
        \ " ctermbg: " . linkedSyn.ctermbg .
        \ " guifg: " . linkedSyn.guifg .
        \ " guibg: " . linkedSyn.guibg
endfunction
command! SyntaxInfo call s:get_syn_info()