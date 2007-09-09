" SQLUtilities:   Variety of tools for writing SQL
"   Author:	      David Fishburn <fishburn@ianywhere.com>
"   Date:	      Nov 23, 2002
"   Last Changed: Sun 09 Sep 2007 10:26:40 PM Eastern Daylight Time
"   Version:	  2.0.0
"   Script:	      http://www.vim.org/script.php?script_id=492
"   License:      GPL (http://www.gnu.org/licenses/gpl.html)
"
"   Dependencies:
"        Align.vim - Version 15 (as a minimum)
"                  - Author: Charles E. Campbell, Jr.
"                  - http://www.vim.org/script.php?script_id=294
"   Documentation:
"        :h SQLUtilities.txt 
"

" Prevent duplicate loading
if exists("g:loaded_sqlutilities") || &cp
    finish
endif
let g:loaded_sqlutilities = 200

if !exists('g:sqlutil_align_where')
    let g:sqlutil_align_where = 1
endif

if !exists('g:sqlutil_align_comma')
    let g:sqlutil_align_comma = 0
endif

if !exists('g:sqlutil_wrap_expressions')
    let g:sqlutil_wrap_expressions = 0
endif

if !exists('g:sqlutil_align_first_word')
    let g:sqlutil_align_first_word = 1
endif

if !exists('g:sqlutil_cmd_terminator')
    let g:sqlutil_cmd_terminator = ';'
endif

if !exists('g:sqlutil_stmt_keywords')
    let g:sqlutil_stmt_keywords = 'select,insert,update,delete,with,merge'
endif

if !exists('g:sqlutil_keyword_case')
    " This controls whether keywords should be made
    " upper or lower case.
    " The default is to leave in current case.
    let g:sqlutil_keyword_case = ''
endif

if !exists('g:sqlutil_use_tbl_alias')
    " If this is set to 1, when you run SQLU_CreateColumnList
    " and you do not specify a 3rd parameter, you will be
    " prompted for the alias name to append to the column list.
    "
    " The default for the alias are the initials for the table:
    "     some_thing_with_under_bars -> stwub
    "     somethingwithout           -> s
    "
    " The default is no asking
    "   d - use by default
    "   a - ask (prompt)
    "   n - no
    let g:sqlutil_use_tbl_alias = 'a'
endif

if !exists('g:sqlutil_col_list_terminators')
    " You can override which keywords will determine
    " when a column list finishes:
    "        CREATE TABLE customer (
    "        	id	INT DEFAULT AUTOINCREMENT,
    "        	last_modified TIMESTAMP NULL,
    "        	first_name     	VARCHAR(30) NOT NULL,
    "        	last_name	VARCHAR(60) NOT NULL,
    "        	balance	        NUMERIC(10,2),
    "        	PRIMARY KEY( id )
    "        );
    " So in the above example, when "primary" is reached, we
    " know the column list is complete.
    "     PRIMARY KEY
    "     foreign keys
    "     indicies
    "     check contraints
    "     table contraints
    "     foreign keys
    " 
    let g:sqlutil_col_list_terminators = 
                \ 'primary\s\+key.*(' .
                \ ',references' .
                \ ',match' .
                \ ',unique' .
                \ ',check' .
                \ ',constraint' .
                \ ',\%(not\s\+null\s\+\)\?foreign'
endif

" Public Interface:
command! -range=% -nargs=* SQLUFormatStmts <line1>,<line2> 
            \ call SQLUtilities#SQLU_FormatStmts(<q-args>)
command! -range -nargs=* SQLUFormatter <line1>,<line2> 
            \ call SQLUtilities#SQLU_Formatter(<q-args>)
command!        -nargs=* SQLUCreateColumnList  
            \ call SQLU_CreateColumnList(<f-args>)
command!        -nargs=* SQLUGetColumnDef 
            \ call SQLU_GetColumnDef(<f-args>)
command!        -nargs=* SQLUGetColumnDataType 
            \ call SQLU_GetColumnDef(expand("<cword>"), 1)
command!        -nargs=* SQLUCreateProcedure 
            \ call SQLU_CreateProcedure(<f-args>)

if !exists("g:sqlutil_load_default_maps")
    let g:sqlutil_load_default_maps = 1
endif 

if(g:sqlutil_load_default_maps == 1)
    if !hasmapto('<Plug>SQLUFormatStmts')
        nmap <unique> <Leader>sfr <Plug>SQLUFormatStmts
        vmap <unique> <Leader>sfr <Plug>SQLUFormatStmts
    endif 
    if !hasmapto('<Plug>SQLUFormatter')
        nmap <unique> <Leader>sfs <Plug>SQLUFormatter
        vmap <unique> <Leader>sfs <Plug>SQLUFormatter
        nmap <unique> <Leader>sf <Plug>SQLUFormatter
        vmap <unique> <Leader>sf <Plug>SQLUFormatter
    endif 
    if !hasmapto('<Plug>SQLUCreateColumnList')
        nmap <unique> <Leader>scl <Plug>SQLUCreateColumnList
    endif 
    if !hasmapto('<Plug>SQLUGetColumnDef')
        nmap <unique> <Leader>scd <Plug>SQLUGetColumnDef
    endif 
    if !hasmapto('<Plug>SQLUGetColumnDataType')
        nmap <unique> <Leader>scdt <Plug>SQLUGetColumnDataType
    endif 
    if !hasmapto('<Plug>SQLUCreateProcedure')
        nmap <unique> <Leader>scp <Plug>SQLUCreateProcedure
    endif 
endif 

if exists("g:loaded_sqlutilities_global_maps")
    vunmap <unique> <script> <Plug>SQLUFormatStmts
    nunmap <unique> <script> <Plug>SQLUFormatStmts
    vunmap <unique> <script> <Plug>SQLUFormatter
    nunmap <unique> <script> <Plug>SQLUFormatter
    nunmap <unique> <script> <Plug>SQLUCreateColumnList
    nunmap <unique> <script> <Plug>SQLUGetColumnDef
    nunmap <unique> <script> <Plug>SQLUGetColumnDataType
    nunmap <unique> <script> <Plug>SQLUCreateProcedure
endif

" Global Maps:
vmap <unique> <script> <Plug>SQLUFormatStmts       :SQLUFormatStmts v<CR>
nmap <unique> <script> <Plug>SQLUFormatStmts       :SQLUFormatStmts n<CR>
vmap <unique> <script> <Plug>SQLUFormatter         :SQLUFormatter v<CR>
nmap <unique> <script> <Plug>SQLUFormatter         :SQLUFormatter n<CR>
nmap <unique> <script> <Plug>SQLUCreateColumnList  :SQLUCreateColumnList<CR>
nmap <unique> <script> <Plug>SQLUGetColumnDef      :SQLUGetColumnDef<CR>
nmap <unique> <script> <Plug>SQLUGetColumnDataType :SQLUGetColumnDataType<CR>
nmap <unique> <script> <Plug>SQLUCreateProcedure   :SQLUCreateProcedure<CR>
let g:loaded_sqlutilities_global_maps = 1

if has("menu")
    vnoremenu <script> Plugin.SQLUtil.Format\ Range\ Stmts :SQLUFormatStmts<CR>
    noremenu  <script> Plugin.SQLUtil.Format\ Range\ Stmts :SQLUFormatStmts<CR>
    vnoremenu <script> Plugin.SQLUtil.Format\ Statement :SQLUFormatter<CR>
    noremenu  <script> Plugin.SQLUtil.Format\ Statement :SQLUFormatter<CR>
    noremenu  <script> Plugin.SQLUtil.Create\ Procedure :SQLUCreateProcedure<CR>
    inoremenu <script> Plugin.SQLUtil.Create\ Procedure  
                \ <C-O>:SQLUCreateProcedure<CR>
    noremenu  <script> Plugin.SQLUtil.Create\ Column\ List   
                \ :SQLUCreateColumnList<CR>
    inoremenu <script> Plugin.SQLUtil.Create\ Column\ List 
                \ <C-O>:SQLUCreateColumnList<CR>
    noremenu  <script> Plugin.SQLUtil.Column\ Definition 
                \ :SQLUGetColumnDef<CR>
    inoremenu <script> Plugin.SQLUtil.Column\ Definition 
                \ <C-O>:SQLUGetColumnDef<CR>
endif

" Puts a command separate list of columns given a table name
" Will search through the file looking for the create table command
" It assumes that each column is on a separate line
" It places the column list in unnamed buffer
function! SQLU_CreateColumnList(...)
    if(a:0 > 1) 
        call SQLUtilities#SQLU_CreateColumnList(a:1, a:2)
    elseif(a:0 > 0) 
        call SQLUtilities#SQLU_CreateColumnList(a:1)
    else
        call SQLUtilities#SQLU_CreateColumnList()
    endif
endfunction


" Strip the datatype from a column definition line
function! SQLU_GetColumnDatatype( line, need_type )
    return SQLUtilities#SQLU_GetColumnDatatype(a:line, a:need_type)
endfunction


" Puts a comma separated list of columns given a table name
" Will search through the file looking for the create table command
" It assumes that each column is on a separate line
" It places the column list in unnamed buffer
function! SQLU_GetColumnDef( ... )
    if(a:0 > 1) 
        return SQLUtilities#SQLU_GetColumnDef(a:1, a:2)
    elseif(a:0 > 0) 
        return SQLUtilities#SQLU_GetColumnDef(a:1)
    else
        return SQLUtilities#SQLU_GetColumnDef()
    endif
endfunction



" Creates a procedure defintion into the unnamed buffer for the 
" table that the cursor is currently under.
function! SQLU_CreateProcedure(...)
    if(a:0 > 0) 
        return SQLUtilities#SQLU_CreateProcedure(a:1)
    else
        return SQLUtilities#SQLU_CreateProcedure()
    endif
endfunction



" Compares two strings, and will remove all names from the first 
" parameter, if the same name exists in the second column name.
" The 2 parameters take comma separated lists
function! SQLU_RemoveMatchingColumns( full_col_list, dup_col_list )
    return SQLUtilities#SQLU_RemoveMatchingColumns( a:full_col_list, a:dup_col_list )
endfunction

" vim:fdm=marker:nowrap:ts=4:expandtab:ff=unix:
