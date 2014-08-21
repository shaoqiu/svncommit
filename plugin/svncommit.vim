
" Create a command to directly call the new search type
command! -nargs=? SVNCommit call svncommit#commit(<q-args>)
