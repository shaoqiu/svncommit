
if exists("g:loaded_svncommit") || &cp
	finish
endif
let g:loaded_svncommit = 1

scriptencoding utf-8

function! svncommit#commit(arg)
	let output = system('svn st -q | grep -v ^!')
	let s:status = split(output, '\n')
	call s:InitWindow()
endfunction

function! s:InitWindow()
	"create windows 
	exe 'tabnew __Comments__'
	exe 'silent keepalt botright split __Status__'

	"set window arrtrbute 
	call s:InitCommentsWindow()
	call s:InitStatusWindow()

	"show data
	call s:ShowComments()
	call s:ShowStatus()

	"move focus to staus window
	call s:GotoStatusWindow()
endfunction

function! s:SetWindowAttribute()
    setlocal noreadonly " in case the "view" mode is used
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal noswapfile
    setlocal nobuflisted
    setlocal nolist
    setlocal nowrap
    setlocal winfixwidth
    setlocal textwidth=0
    setlocal nospell
endfunction

function! s:InitCommentsWindow()
	call s:GotoCommentsWindow()
	call s:SetWindowAttribute()
	exe 'resize 1'
    nnoremap <buffer> <cr> :call <SID>DoCommit()<cr>
endfunction

function! s:DoCommit()
	let comment = getline('.')
	"call g:VimDebug('commit:' . comment)

	call s:GotoStatusWindow()
	let lineCount = line('$')
	"call g:VimDebug('lineCount:' . lineCount)
	let files = ''
	for index in range(0, lineCount)
		let l = getline(index)
		if strpart(l, 0, 1) == '+'
			let file = strpart(l, 2, len(l))
			let file = g:StringTrim(file)
			let files = files . ' ' . file
		endif
	endfor
	"call g:VimDebug('commit files:' . files)

	if comment == ''
		echo 'comment can not be empty!'
		return 
	endif

	if files == ''
		echo 'commit file list is empty!'
		return 
	endif

	let commit = '!svn commit -m "' .comment .'" ' .files
	call g:VimDebug('commit command:' . commit)
	exe commit
	exe 'qa'
endfunction

function! s:InitStatusWindow()
	call s:GotoStatusWindow()
	call s:SetWindowAttribute()
	"key map
	let pcmd = "nn \<buffer> \<silent> \<k%s> :\<c-u>cal \<SID>%s(\"%s\")\<cr>"
	let cmd = substitute(pcmd, 'k%s', 'char-%d', '')
	let pfunc = 'OnKey'
	"a, s, u
	for each in [97, 115, 117]
		exe printf(cmd, each, pfunc, escape(nr2char(each), '"|\'))
	endfo
	
    nnoremap <buffer> <cr> :call <SID>ShowDiff()<cr>
endfunction

function! s:ToggleFileSelected()
	let l = getline('.')
	if strpart(l, 0, 1) == '+'
		call setline('.', strpart(l, 1, len(l)))
	else
		call setline('.', '+' .l)
	endif
endfunction

function! s:SelectAll()
	let lineCount = line('$')
	for index in range(0, lineCount)
		let l = getline(index)
		if strpart(l, 0, 1) != '+'
			call setline(index, '+' .l)
		endif
	endfor
endfunction

function! s:UnSelectAll()
	let lineCount = line('$')
	for index in range(0, lineCount)
		let l = getline(index)
		if strpart(l, 0, 1) == '+'
			call setline(index, strpart(l, 1, len(l)))
		endif
	endfor
endfunction

function! s:OnKey(char)
	if a:char == 'a'
		call s:ToggleFileSelected()
	endif
	if a:char == 's'
		call s:SelectAll()
	endif
	if a:char == 'u'
		call s:UnSelectAll()
	endif
endfunction

function! s:GotoStatusWindow()
	exe '2wincmd k'
	exe 'wincmd j'
endfunction

function! s:GotoCommentsWindow()
	exe "2wincmd k"
endfunction

function! s:ShowComments()
	"goto comments window
	call s:GotoCommentsWindow()
	"clear window
	exe '0,$ delete'
endfunction

function! s:ShowStatus()
	call s:GotoStatusWindow()
	exe '0,$ delete'
	let i = 1
	for statu in s:status
		call setline(i, statu)
		let i = i+1
	endfor
endfunction

function! s:ShowDiff()
	let line = getline('.')
	let path = strpart(line, 2, len(line))
	let file = g:StringTrim(path)

	let pwd = system('pwd')
	let path = strpart(pwd, 0, len(pwd) - 1) . '/' .file
	"call svn diff
	let diffcmd = '!svn diff ' . path
	"call g:VimDebug('diff cmd = ' .diffcmd)
	exec diffcmd
endfunction

