" SQLUtilities:   Variety of tools for writing SQL
"   Author:	  David Fishburn <fishburn@sybase.com>
"   Date:	  Nov 23, 2002
"   Last Changed: Tue Feb 04 2003 9:20:51 PM
"   Version:	  1.1
"   Script:	  http://www.vim.org/script.php?script_id=492
"
"   Dependencies:
"        Align.vim - Version 15
"                  - Author: Charles E. Campbell, Jr.
"                  - http://www.vim.org/script.php?script_id=294
"
"   Functions:
"   [range]SQLFormatter(..list..)
"
"        Formats SQL statements into a easily readable form.
"        Breaks keywords onto new lines.
"        Forces column lists to be split over as many lines as
"        necessary to fit the current textwidth of the buffer,
"        so that lines do not wrap.
"        If parantheses are unbalanced (ie a subselect) it will
"        indent everything within the unbalanced paranthesis.
"        Works for SELECT, INSERT, UPDATE, DELETE statements.
"
"        Examples:
"
"     Original:
"     SELECT m.MSG_ID, m.PRIORITY_ID FROM MESSAGES m JOIN PRIORITY_CD P
"     WHERE m.to_person_id = ?  AND p.NAME         = 'PRI_EMERGENCY'
"     AND p.JOB      = 'Plumber' AND m.status_id    < (
"     SELECT s.STATUS_ID FROM MSG_STATUS_CD s 
"     WHERE s.NAME         = 'MSG_READ' ) ORDER BY m.msg_id desc
"
"     Formatted:
"     SELECT m.MSG_ID, m.PRIORITY_ID
"       FROM MESSAGES m
"       JOIN PRIORITY_CD P
"      WHERE m.to_person_id = ?
"        AND p.NAME         = 'PRI_EMERGENCY'
"        AND p.JOB          = 'Plumber'
"        AND m.status_id    < (
"             SELECT s.STATUS_ID
"               FROM MSG_STATUS_CD s
"              WHERE s.NAME         = 'MSG_READ' )
"      ORDER BY m.msg_id desc
"
"     Original:
"     UPDATE "SERVICE_REQUEST" SET "BUILDING_ID" = ?, "UNIT_ID" = ?, 
"     "REASON_ID" = ?, "PERSON_ID" = ?, "PRIORITY_ID" = ?, "STATUS_ID" = ?, 
"     "CREATED" = ?, "REQUESTED" = ?, "ARRIVED" = ?  WHERE "REQUEST_ID" = ?
"
"     Formatted:
"     UPDATE "SERVICE_REQUEST"
"        SET "BUILDING_ID" = ?,
"            "UNIT_ID" = ?,
"            "REASON_ID" = ?,
"            "PERSON_ID" = ?,
"            "PRIORITY_ID" = ?,
"            "STATUS_ID" = ?,
"            "CREATED" = ?,
"            "REQUESTED" = ?,
"            "ARRIVED" = ?,
"      WHERE "REQUEST_ID"  = ?
"
"     Original:
"     INSERT INTO "MESSAGES" ( "MSG_ID", "TO_PERSON_ID", 
"     "FROM_PERSON_ID", "REQUEST_ID", "CREATED", "PRIORITY_ID", 
"     "MSG_TYPE_ID", "STATUS_ID", "READ_WHEN", "TIMEOUT", 
"     "MSG_TXT", "RESEND_COUNT" ) VALUES ( ?, ?, ?, 
"     ?, ?, ?, ?, ?, ?, ?, ?, ? )
"
"     Formatted:
"     INSERT 
"       INTO "MESSAGES" ( "MSG_ID", "TO_PERSON_ID",
"            "FROM_PERSON_ID", "REQUEST_ID", "CREATED",
"            "PRIORITY_ID", "MSG_TYPE_ID", "STATUS_ID",
"            "READ_WHEN", "TIMEOUT", "MSG_TXT", "RESEND_COUNT" )
"     VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )
"
"
"   Functions:
"   CreateColumnList( optional parameter )
"
"        Assumes either the current file, or any other open buffer, 
"        has a CREATE TABLE statement in a format similar to this:
"        CREATE TABLE customer (
"        	id	INT DEFAULT AUTOINCREMENT,
"        	last_modified TIMESTAMP NULL,
"        	first_name     	VARCHAR(30) NOT NULL,
"        	last_name	VARCHAR(60) NOT NULL,
"        	balance	        NUMERIC(10,2),
"        	PRIMARY KEY( id )
"        );
"        If you place the cursor on the word customer, then the 
"        unnamed buffer (also displayed by an echo statement) will 
"        contain:
"        id, last_modified, first_name, last_name, balance
"
"        Optionally, it will replace the word with the above and place
"        the word in the unnamed buffer.  Calling the function with
"        a parameter enables this feature.
"
"        This also uses the g:sqlutil_cmd_terminator to determine when
"        the create table statement ends if none of the following terms
"        are found before the final );
"               primary,reference,unique,check,foreign
"        sqlutil_cmd defaults to ";"
"
"
"   Functions:
"   GetColumnDef( optional parameter )
"
"        Assumes either the current file, or any other open buffer, 
"        has a CREATE TABLE statement in a format similar to this:
"        CREATE TABLE customer (
"        	id	INT DEFAULT AUTOINCREMENT,
"        	last_modified TIMESTAMP NULL,
"        	first_name     	VARCHAR(30) NOT NULL,
"        	last_name	VARCHAR(60) NOT NULL,
"        	balance	        NUMERIC(10,2),
"        	PRIMARY KEY( id )
"        );
"        If you place the cursor on the word first_name, then the 
"        column definition will be placed in the unnamed buffer (and also
"        displayed by an echo statement).
"        VARCHAR(30) NOT NULL        
"
"        Optionally, it will replace the word with the above and place
"        the word in the unnamed buffer.  Calling the function with
"        a parameter enables this feature.
"
"
"   Functions:
"   CreateProcedure()
"
"        Assumes either the current file, or any other open buffer, 
"        has a CREATE TABLE statement in a format similar to this:
"        CREATE TABLE customer (
"        	id	INT DEFAULT AUTOINCREMENT,
"        	last_modified TIMESTAMP NULL,
"        	first_name     	VARCHAR(30) NOT NULL,
"        	last_name	VARCHAR(60) NOT NULL,
"        	balance	        NUMERIC(10,2),
"        	PRIMARY KEY( id )
"        );
"        By calling CreateProcedure while on the name of a table
"        the unnamed buffer will contain the create procedure statement
"        for insert, update, delete and select statements.
"        Once pasted into the buffer, unneeded functionality can be 
"        removed.
"
"
"
"   Commands:
"   [range]SQLFormatter ..list..    
"                        : Reformats the SQL statements over the specified 
"                          range.  Statement will lined up given the 
"                          existing indent of the first word.
"   CreateColumnList     : Creates a comma separated list of column names
"                          for the table name under the cursor, assuming
"                          the table definition exists in any open 
"                          buffer.  The column list is placed in the unnamed
"                          buffer.
"                          This also uses the g:sqlutil_cmd_terminator
"                          This routine can optionally take 2 parameters
"                          CreateColumnList T1 
"                              Creates a column list for T1
"                          CreateColumnList T1 1
"                              Creates a column list for T1 but only for
"                              the primary keys for that table.
"   GetColumnDef         : Displays the column definition of the column name
"                          under the cursor.  It assumes the CREATE TABLE
"                          statement is in an open buffer.
"   CreateProcedure      : Creates a stored procedure to perform standard
"                          operations against the table that the cursor
"                          is currently under.
"                          
"
"   
"   Suggested Mappings:
"       vmap <silent>sf   <Esc>:SQLFormatter<CR>
"       nmap <silent>scl       :CreateColumnList<CR>
"       nmap <silent>scd       :GetColumnDef<CR>
"       nmap <silent>scp       :CreateProcedure<CR>
"
"       mnemonic explanation
"       s - sql
"         f  - format
"         cl - column list
"         cd - column definition
"         cp - create procedure
"
"       To prevent the default mappings from being created, place the 
"       following in your _vimrc:
"           let g:sqlutil_load_default_maps = 0
"
"   TODO:
"     1. Nothing yet
"
"
"   History:
"     1  : Nov 13, 2002 : Initial version
"     2  : Nov 30, 2002 : Create procedure uses shiftwidth for indent
"                         Save/restore previous search
" ---------------------------------------------------------------------

" Prevent duplicate loading
if exists("g:loaded_sqlutilities") || &cp
    finish
endif
let g:loaded_sqlutilities = 1

if !exists('g:sqlutil_cmd_terminator')
    let g:sqlutil_cmd_terminator = ';'
endif

" Public Interface:
com! -range -nargs=* SQLFormatter 
            \          <line1>,<line2>call <SID>SQLFormatter(<f-args>)
com!        -nargs=* CreateColumnList call CreateColumnList(<f-args>)
com!        -nargs=* GetColumnDef     call GetColumnDef(<f-args>)
com!        -nargs=* CreateProcedure  call CreateProcedure(<f-args>)

if !exists("g:sqlutil_load_default_maps")
    let g:sqlutil_load_default_maps = 1
endif 

if(g:sqlutil_load_default_maps == 1)
    if !hasmapto('<Plug>SQLFormatter')
        vmap <unique> <Leader>sf <Plug>SQLFormatter
    endif 
    if !hasmapto('<Plug>CreateColumnList')
        map <unique> <Leader>scl <Plug>CreateColumnList
    endif 
    if !hasmapto('<Plug>GetColumnDef')
        map <unique> <Leader>scd <Plug>GetColumnDef
    endif 
    if !hasmapto('<Plug>CreateProcedure')
        map <unique> <Leader>scp <Plug>CreateProcedure
    endif 
endif 

" Global Maps:
vmap <unique> <script> <Plug>SQLFormatter      :<C-U>SQLFormatter<CR>
nmap <unique> <script> <Plug>CreateColumnList  :CreateColumnList<CR>
nmap <unique> <script> <Plug>GetColumnDef      :GetColumnDef<CR>
nmap <unique> <script> <Plug>CreateProcedure   :CreateProcedure<CR>

if has("gui_running") && has("menu")
    vnoremenu <script> Plugin.SQLUtil.Format\ Statement  :SQLFormatter<CR>
    noremenu  <script> Plugin.SQLUtil.Format\ Statement  :SQLFormatter<CR>
    noremenu  <script> Plugin.SQLUtil.Create\ Procedure  :CreateProcedure<CR>
    inoremenu <script> Plugin.SQLUtil.Create\ Procedure  
                \ <C-O>:CreateProcedure<CR>
    noremenu  <script> Plugin.SQLUtil.Create\ Column\ List   
                \ :CreateColumnList<CR>
    inoremenu <script> Plugin.SQLUtil.Create\ Column\ List 
                \ <C-O>:CreateColumnList<CR>
    noremenu  <script> Plugin.SQLUtil.Column\ Definition :GetColumnDef<CR>
    inoremenu <script> Plugin.SQLUtil.Column\ Definition 
                \ <C-O>:GetColumnDef<CR>
endif

" SQLFormatter: align selected text based on alignment pattern(s)
function! s:SQLFormatter(...) range
    " call Decho("SQLFormatter() {")
    call s:WrapperStart()
    " Store pervious value of highlight search
    let hlsearch = &hlsearch
    let &hlsearch = 0

    " save previous search string
    let saveSearch = @/ 
    
    call s:ReformatStatement()
    call s:IndentSubqueries()
    call s:WrapLongLines()

    " Restore default value
    let &hlsearch = hlsearch
    call s:WrapperEnd()

    " restore previous search string
    let @/ = saveSearch
    
    " Position cursor at start of block
    '<
endfunction


" This function will return a count of unmatched parenthesis
" ie ( this ( funtion ) - will return 1 in this case
function! s:CountUnbalancedParan( line, paran_to_check )
    let l = a:line
    let lp = substitute(l, '[^(]', '', 'g')
    let l = a:line
    let rp = substitute(l, '[^)]', '', 'g')

    if a:paran_to_check =~ ')'
        " echom 'CountUnbalancedParan ) returning: ' 
        " \ . (strlen(rp) - strlen(lp))
        return (strlen(rp) - strlen(lp))
    elseif a:paran_to_check =~ '('
        " echom 'CountUnbalancedParan ( returning: ' 
        " \ . (strlen(lp) - strlen(rp))
        return (strlen(lp) - strlen(rp))
    else
        " echom 'CountUnbalancedParan unknown paran to check: ' . 
        " \ a:paran_to_check
        return 0
    endif
endfunction

" Unindent commands based on previous indent level
function! s:IndentFrom( start_line, end_line, nest_level )
    let linenum = a:start_line
    while linenum <= a:end_line
        let line = getline(linenum)
        if line =~ '[()]'
            let unbal_left  = s:CountUnbalancedParan( line, '(' )
            let unbal_right = s:CountUnbalancedParan( line, ')' )
            if unbal_left > 0
                " There is a open left paranethesis increase indent
                let indent_to = s:IndentFrom( linenum+1, 
                            \ a:end_line, a:nest_level+1 )
                " Decho( "IndentFrom: " . a:start_line+1 . 
                " \ " , ".indent_to." line: " . line )
                silent exec linenum+1 . "," . indent_to . ">>"

                let linenum = indent_to

            elseif unbal_right > 0
                " Decho 'linenum: ' . linenum . ' ) un: ' . 
                " \ strlen(num_unmatched_right) . '  line: ' . line
                return linenum
            endif
        endif

        let linenum = linenum + 1
    endwhile

    " Never found matching close parenthesis
    " return end of range
    return linenum
endfunction

function! s:WrapperStart()
    let b:curline     = line(".")
    let b:curcol      = virtcol(".")
    let b:keepsearch  = @/
    let b:keepline_my = line("'y")
    let b:keepcol_my  = virtcol("'y")
    let b:keepline_mz = line("'z")
    let b:keepcol_mz  = virtcol("'z")
    norm! '>
    put =''
    norm! mz'<
    put! = ''
    let b:ch= &ch
    set ch=2
    norm! my
    norm! 'zk
endfunction

" WE: wrapper end (internal)   Removes guard lines,
"     restores marks y and z, and restores search pattern
function! s:WrapperEnd()
    norm! 'yjkdd'zdd
    exe "set ch=".b:ch
    unlet b:ch
    let @/= b:keepsearch
    if b:keepline_my != 0
        exe "norm! ".b:keepline_my."G".b:keepcol_my."\<bar>"
    endif
    if b:keepline_mz != 0
        exe "norm! ".b:keepline_mz."G".b:keepcol_mz."\<bar>"
    endif
    exe 'norm! '.b:curline.'G'.b:curcol."\<bar>"
    unlet b:keepline_my b:keepcol_my
    unlet b:keepline_mz b:keepcol_mz
    unlet b:curline     b:curcol
endfunction

" Reformats the statements 
" 1. Keywords (FROM, WHERE, AND, ... ) " are on new lines
" 2. Keywords are right justified
" 3. Operators are lined up
" Example
" 
function! s:ReformatStatement()
    " call Decho("'<=".line("'<").":".col("'<")."  '>=".
    " \ line("'>").":".col("'>"))
    " Join block of text into 1 line
    silent 'y+1,'z-1j
    " Reformat the commas, to remove any spaces before them
    silent 'y+1,'z-1s/\s*,/,/ge
    " And add a space following them, this allows the line to be
    " split using gqq
    silent 'y+1,'z-1s/,\(\w\)/, \1/ge
    " Go to the start of the block
    silent 'y+1
    " force each keyword onto a newline
    let sql_keywords =  'create\|drop\|call\|select\|update\|set\|' .
                \ 'into\|from\|join\|on\|where\|and\|or\|order\|group\|' .
                \ 'having\|for\|insert\|values\|union\|subscrib\|' .
                \ 'intersect\|except'
    silent exec "'y+1,'z-1".'s/\(^\s*\)\@<!\<\('.
                \ sql_keywords.
                \ '\)\>/\r\2/gei'
    " Ensure keywords at the beginning of a line have a space after them
    " This will ensure the Align program lines them up correctly
    silent 'y+1,'z-1s/^\([a-zA-Z0-9_]*\)(/\1 (/e
    " Delete any non empty lines
    " 'y+1,'z-1g/^\s*$/d


    " AlignPush

    " Using the Align.vim plugin, reformat the lines
    " so that the keywords are RIGHT justified
    AlignCtrl default

    " Replace the space after the first word on each line with 
    " -@- to align on this later
    silent 'y+1,'z-1s/^\(\s*\)\([a-zA-Z0-9_]*\) /\1\2-@-

    call s:SplitUnbalParan()

    " Align these based on the special charater
    " and the column names are LEFT justified
    AlignCtrl Ip0P0rl:
    silent 'y+1,'z-1Align -@-
    silent 'y+1,'z-1s/-@-/ /

    " Now align the operators 
    " and the operators are CENTER justified
    AlignCtrl default
    AlignCtrl g [!><=]
    AlignCtrl Wp1P1l
    silent 'y+1,'z-1Align [!><=]=\=

    " Reset back to defaults
    AlignCtrl default

    " Reset the alignment to what it was prior to 
    " this function
    " AlignPop

endfunction

" Check through the selected text for open ( and
" indent if necessary
function! s:IndentSubqueries()
    " 
    " list is broken over as many lines as necessary and lined up with
    " the other columns
    let linenum = line("'y+1")

    let org_textwidth = &textwidth
    if &textwidth == 0 
        let &textwidth = 80
    endif

    " call Decho(" Before IndentFrom 'y+1=".line("'<").
    " \ ":".col("'<")."  'z-1=".line("'>").":".col("'>"))
    " Recursively call IndentFrom to indent nested subqueries
    let indent_to = s:IndentFrom( line("'y+1"), line("'z-1"), 0 )
    " call Decho(" After IndentFrom 'y+1=".line("'<").
    " \ ":".col("'<")."  'z-1=".line("'>").":".col("'>"))

    let &textwidth = org_textwidth
endfunction

" For certain keyword lines (SELECT, ORDER BY, GROUP BY, ...)
" Ensure the lines fit in the textwidth (or default 80), wrap
" the lines where necessary and left justify the column names
function! s:WrapLongLines()
    " Check if this is a SELECT statement, if so, ensure the column
    " list is broken over as many lines as necessary and lined up with
    " the other columns
    let linenum = line("'y+1")

    let org_textwidth = &textwidth
    if &textwidth == 0 
        let &textwidth = 80
    endif

    " call Decho(" Before column splitter 'y+1=".line("'<").
    " \ ":".col("'<")."  'z-1=".line("'>").":".col("'>"))
    while linenum <= (line("'z-1"))
        let line = getline(linenum)
        let sql_keywords = '^\s*\(select\|set\|into\|from\|values'.
                    \ '\|order\|group\|having\)'
        if line =~? sql_keywords
            " Set the textwidth to current value
            " minus an adjustment for select and set
            " minus any indent value this may have
            let &textwidth = &textwidth - 10 - indent(".")

            if strlen( line ) > &textwidth
                " Decho 'linenum: ' . linenum . ' strlen: ' .
                " \ strlen(line) . ' textwidth: ' . &textwidth .
                " \ '  line: ' . line
                " go to the current line
                exec linenum 
                " Mark the start of the wide line
                exec "normal mb"
                " Create a special marker for Align.vim
                " to line up the columns with
                silent exec linenum . ',' . linenum . 's/\(\w\) /\1-@-'
                " Mark the next line
                exec "normal jmek"

                " If the line begins with SET then force each
                " column on a newline, instead of breaking them apart
                " this will ensure that the col_name = ... is on the
                " same line
                if line =~? '^\s*\<set\>'
                    silent 'b,'e-1s/,/,\r/ge
                endif

                exec linenum
                " Reformat the line based on the textwidth
                silent exec "normal gqq"

                " Reformat the commas
                silent 'b,'e-1s/\s*,/,/ge
                " Add a space after the comma
                silent 'b,'e-1s/,\(\w\)/, \1/ge

                " Append the special marker to the beginning of the line
                " for Align.vim
                silent exec "'b+,'e-" . 's/\s*\(.*\)/-@-\1'
                AlignCtrl Ip0P0rl:
                silent 'b,'e-Align -@-
                silent 'b,'e-s/-@-/ /
                AlignCtrl default

                let linenum = line("'e") - 1
            endif
        endif
        let &textwidth = org_textwidth
        if &textwidth == 0 
            let &textwidth = 80
        endif
        let linenum = linenum + 1
    endwhile

endfunction

" Finds unbalanced paranthesis and put each one on a new line
function! s:SplitUnbalParan()
    let linenum = line("'y+1")
    while linenum <= (line("'z-1"))
        let line = getline(linenum)
        if line =~ '[()]'
            if line =~ '('
                let num_unmatched_left = s:CountUnbalancedParan( line, '(' )
                exec linenum+1 . 'ke'
                while( num_unmatched_left > 0 )
                    " Create a special marker for Align.vim
                    " to line up the columns with
                    " Find the FIRST occurrence of ( and replace
                    " it with a new line and -@-(
                    " call Decho( " l: " .linenum." left: ".
                    " \ num_unmatched_left." line: ".getline(linenum).
                    " \ " ol: ".line )
                    " silent exec linenum . ',' . linenum . 's/(/(\r-@-'
                    silent exec linenum . ',' . linenum .
                                \ 's/\((.*\)(/\1\r-@-(/e'
                    let num_unmatched_left = num_unmatched_left - 1
                endwhile
                " Since newlines were added, continue on the next
                " line before the substitution command
                let linenum = line("'e")
                continue
            endif
            if line =~ ')'
                let num_unmatched_right  = s:CountUnbalancedParan( line, ')' )
                exec linenum+1 . 'ke'
                while( num_unmatched_right > 1 )
                    " Create a special marker for Align.vim
                    " to line up the columns with
                    " Find the LAST occurrence of ) and replace
                    " it with a new line and -@-)
                    silent exec linenum . ',' . linenum . 's/.*\zs)/\r-@-)/e'
                    " silent exec linenum . ',' . linenum . 's/\zs)/\r-@-)/e'
                    let num_unmatched_right = num_unmatched_right - 1
                endwhile
                " Since newlines were added, continue on the next
                " line before the substitution command
                let linenum = line("'e")
                continue
            endif
        endif

        let linenum = linenum + 1
    endwhile

    return 
endfunction


" Puts a command separate list of columns given a table name
" Will search through the file looking for the create table command
" It assumes that each column is on a separate line
" It places the column list in unnamed buffer
function! CreateColumnList(...)

    " Mark the current line to return to
    let curline     = line(".")
    let curcol      = virtcol(".")
    let curbuf      = bufnr(expand("<abuf>"))
    let found       = 0

    if(a:0 > 0) 
        let table_name  = a:1
    else
        let table_name  = expand("<cword>")
    endif

    if(a:0 > 1) 
        let only_primary_key = 1
    else
        let only_primary_key = 0
    endif

    " save previous search string
    let saveSearch = @/
    let saveZ      = @z
    let columns    = ""
    
    " ignore case
    if( only_primary_key == 0 )
        let srch_table = '\c^[ \t]*create.*table.*\<'.table_name.'\>'
    else
        let srch_table = '\c^[ \t]*\(create\|alter\).*table.*\<'.
                    \ table_name.'\>'
    endif

    " Loop through all currenly open buffers to look for the 
    " CREATE TABLE statement, if found build the column list
    " or display a message saying the table wasn't found
    " I am assuming a create table statement is of this format
    " CREATE TABLE "cons"."sync_params" (
    "   "id"                            integer NOT NULL,
    "   "last_sync"                     timestamp NULL,
    "   "sync_required"                 char(1) NOT NULL DEFAULT 'N',
    "   "retries"                       smallint NOT NULL ,
    "   PRIMARY KEY ("id")
    " );
    while( 1==1 )
        " Mark the current line to return to
        let buf_curline     = line(".")
        let buf_curcol      = virtcol(".")
        " From the top of the file
        let cmd = 'silent normal! gg'."\n"
        exe cmd
        if( search( srch_table, "W" ) ) > 0
            if( only_primary_key == 0 )
                " Get the list of all columns for the table
                " let cmd = 'silent normal! /'.srch_create_table."\n"
                " exe cmd
                " Find the opening ( that starts the column list
                " and move down one line
                let cmd = 'normal! /('."\n".'j'
                " Visually select until the following keyword are the beginning
                " of the line, this should be at the bottom of the column list
                " Backup up one line so this line is not included
                exe cmd
                " Start visually selecting columns
                let cmd = 'silent normal! V'."\n"
                let cmd = cmd . '/^[ \t]*' " ignore spaces and tabs at start
                            " Stop visually selecting until the 
                            " following keywords
                let cmd = cmd . '\(' 
                            " Closing ) followed by cmd terminator
                let cmd = cmd . ')\?\s*'.g:sqlutil_cmd_terminator
                let cmd = cmd . '\|primary' " PRIMARY KEY
                let cmd = cmd . '\|reference' " foreign keys
                let cmd = cmd . '\|unique' " indicies
                let cmd = cmd . '\|check' " check contraints
                let cmd = cmd . '\|foreign' " foreign keys
                let cmd = cmd . '\)' " end of criteria
                let cmd = cmd . '/-' "back up one line
                let cmd = cmd . "\n\<ESC>" " hit enter to complete the command
                " Decho cmd
                exe cmd
                noh
                let found = 1
                let start_line = line("'<")
                let end_line = line("'>")
                
                while start_line <= end_line
                    let line = getline(start_line)
                    " Decho line
                    " Strip out the column name
                    let columns = columns .
                                \ substitute( line, 
                                \ '^[ \t"]*\(\w\+\).*,\?\(.*\)', '\1', "g" )
                    " Decho columns
                    if start_line < end_line
                        let columns = columns . ", "
                    endif
                    let start_line = start_line + 1
                endwhile
            else
                " Find the primary key statement
                if( search( '\cPRIMARY KEY[\n\s]*', "W" ) ) > 0
                    exe 'silent! norm! /(/e+1'."\n".'v/)/e-1'."\n".'"zy'
                    let columns = @z
                    " Strip newlines characters
                    let columns = substitute( columns, 
                                \ "[\n]", '', "g" )
                    " Strip everything but the column list
                    let columns = substitute( columns, 
                                \ '\s*\(.*\)\s*', '\1', "g" )
                    " Remove double quotes
                    let columns = substitute( columns, '"', '', "g" )
                    let columns = substitute( columns, ',\s*', ', ', "g" )
                    let columns = substitute( columns, '^\s*', '', "g" )
                    let columns = substitute( columns, '\s*$', '', "g" )
                    let found = 1
                endif
                noh
            endif

        endif

        " Return to previous location
        exe 'norm! '.buf_curline.'G'.buf_curcol."\<bar>"

        if found == 1
            break
        endif
        
        if &hidden == 0
            echom "Cannot search other buffers with set nohidden"
            break
        endif

        " Switch buffers to check to see if the create table
        " statement exists
        exec "bnext"
        if bufnr(expand("<abuf>")) == curbuf
            break
        endif
    endwhile
    
    exec "buffer " . curbuf

    " Return to previous location
    exe 'norm! '.curline.'G'.curcol."\<bar>"

    " restore previous search
    let @/ = saveSearch
    let @z = saveZ

    redraw

    if found == 0
        let @@ = ""
        echo "CreateColumnList - Table: " . table_name . " was not found"
        return ""
    endif 

    if &clipboard == 'unnamed'
        let @* = columns 
    else
        let @@ = columns 
    endif

    " If a parameter has been passed, this means replace the 
    " current word, with the column list
    " if (a:0 > 0) && (found == 1)
        " exec "silent normal! viwp"
        " if &clipboard == 'unnamed'
            " let @* = table_name 
        " else
            " let @@ = table_name 
        " endif
        " echo "Paste register: " . table_name
    " else
        echo "Paste register: " . columns
    " endif

    return columns

endfunction


" Strip the datatype from a column definition line
function! GetColumnDatatype( line )

    let pattern = '\c^\s*'  " case insensitve, white space at start of line
    let pattern = pattern . '\S\+\s\+' " non white space (name with quotes)
    let pattern = pattern . '\(.\{-}\)' " match anything, but as little
                                        " as possible - column datatype
    let pattern = pattern . '\(\s\+' " exclude spaces
    let pattern = pattern . '\(' " stop matching the datatype at
                                 " the following keywords
    let pattern = pattern . '\(NOT\s\+\)\=NULL' " NOT NULL or NULL
    let pattern = pattern . '\|DEFAULT.*'  " column DEFAULT
    let pattern = pattern . '\)' " end of keywords
    let pattern = pattern . '\)\=,\=$' " Optional comma at the end of line

    let datatype = substitute( a:line, pattern, '\1', '')

    return datatype
endfunction


" Puts a command separate list of columns given a table name
" Will search through the file looking for the create table command
" It assumes that each column is on a separate line
" It places the column list in unnamed buffer
function! GetColumnDef( ... )

    " Mark the current line to return to
    let curline     = line(".")
    let curcol      = virtcol(".")
    let curbuf      = bufnr(expand("<abuf>"))
    let found       = 0
    
    if(a:0 > 0) 
        let table_name  = a:1
    else
        let table_name  = expand("<cword>")
    endif

    let srch_column_name = '^[ \t]*["]\?\<' . table_name . '\>'
    let column_def = ""

    " Loop through all currenly open buffers to look for the 
    " CREATE TABLE statement, if found build the column list
    " or display a message saying the table wasn't found
    " I am assuming a create table statement is of this format
    " CREATE TABLE "cons"."sync_params" (
    "   "id"                            integer NOT NULL,
    "   "last_sync"                     timestamp NULL,
    "   "sync_required"                 char(1) NOT NULL DEFAULT 'N',
    "   "retries"                       smallint NOT NULL ,
    "   PRIMARY KEY ("id")
    " );
    while( 1==1 )
        " Mark the current line to return to
        let buf_curline     = line(".")
        let buf_curcol      = virtcol(".")

        if( search( srch_column_name, "w" ) ) > 0
            " From the top of the file
            let cmd = 'silent normal! gg'."\n"
            " Find the create table statement
            let cmd = cmd . '/'.srch_column_name."\n"
            " Visually select until the following keyword are the beginning
            " of the line, this should be at the bottom of the column list
            " Backup up one line so this line is not included
            let cmd = cmd . 'V'."\n\<ESC>"
            " Decho cmd
            exe cmd
            noh
            let found = 1
            
            let line = getline("'<")
            " Decho line
            let column_def = GetColumnDatatype( line )

        endif

        " Return to previous location
        exe 'norm! '.buf_curline.'G'.buf_curcol."\<bar>"

        if found == 1
            break
        endif
        
        if &hidden == 0
            echom "Cannot search other buffers with set nohidden"
            break
        endif

        " Switch buffers to check to see if the create table
        " statement exists
        exec "bnext"
        if bufnr(expand("<abuf>")) == curbuf
            break
        endif
    endwhile
    
    exec "buffer " . curbuf

    " Return to previous location
    exe 'norm! '.curline.'G'.curcol."\<bar>"

    if found == 0
        let @@ = ""
        echo "Column: " . table_name . " was not found"
        return ""
    endif 

    if &clipboard == 'unnamed'
        let @* = column_def 
    else
        let @@ = column_def 
    endif

    " If a parameter has been passed, this means replace the 
    " current word, with the column list
    " if (a:0 > 0) && (found == 1)
        " exec "silent normal! viwp"
        " if &clipboard == 'unnamed'
            " let @* = table_name 
        " else
            " let @@ = table_name 
        " endif
        " echo "Paste register: " . table_name
    " else
        echo "Paste register: " . column_def
    " endif

    return column_def

endfunction



" Creates a procedure defintion into the unnamed buffer for the 
" table that the cursor is currently under.
function! CreateProcedure()

    " Mark the current line to return to
    let curline     = line(".")
    let curcol      = virtcol(".")
    let curbuf      = bufnr(expand("<abuf>"))
    let found       = 0
    " save previous search string
    let saveSearch=@/ 
    

    if(a:0 > 0) 
        let table_name  = a:1
    else
        let table_name  = expand("<cword>")
    endif

    let i = 0
    let indent_spaces = ''
    while( i < &shiftwidth )
        let indent_spaces = indent_spaces . ' '
        let i = i + 1
    endwhile
    
    " ignore case
    let srch_create_table = '\c^[ \t]*create.*table.*\<' . table_name . '\>'
    let procedure_def = "CREATE PROCEDURE sp_" . table_name . "(\n"

    let column_list = CreateColumnList(table_name)
    if strlen(column_list) == 0
        echo "Table: " . table_name . " was not found"
        " restore previous search string
        let @/ = saveSearch
    
        return
    endif
    let pk_column_list = CreateColumnList(table_name, 'primary_keys')


    " Loop through all currenly open buffers to look for the 
    " CREATE TABLE statement, if found build the column list
    " or display a message saying the table wasn't found
    " I am assuming a create table statement is of this format
    " CREATE TABLE "cons"."sync_params" (
    "   "id"                            integer NOT NULL,
    "   "last_sync"                     timestamp NULL,
    "   "sync_required"                 char(1) NOT NULL DEFAULT 'N',
    "   "retries"                       smallint NOT NULL ,
    "   PRIMARY KEY ("id")
    " );
    while( 1==1 )
        " Mark the current line to return to
        let buf_curline     = line(".")
        let buf_curcol      = virtcol(".")

        if( search( srch_create_table, "w" ) ) > 0
            " From the top of the file
            let cmd = 'silent normal! gg'."\n"
            " Find the create table statement
            let cmd = cmd . '/'.srch_create_table."\n"
            " Find the opening ( that starts the column list
            " and move down one line
            let cmd = cmd . '/('."\n".'j'
            " Visually select until the following keyword are the beginning
            " of the line, this should be at the bottom of the column list
            " Start visually selecting columns
            let cmd = 'silent normal! V'."\n"
            let cmd = cmd . '/^[ \t]*' " ignore spaces and tabs at start
                        " Stop visually selecting until the 
                        " following keywords
            let cmd = cmd . '\(' 
                        " Closing ) followed by cmd terminator
            let cmd = cmd . ')\?\s*'.g:sqlutil_cmd_terminator
            let cmd = cmd . '\|primary' " PRIMARY KEY
            let cmd = cmd . '\|reference' " foreign keys
            let cmd = cmd . '\|unique' " indicies
            let cmd = cmd . '\|check' " check contraints
            let cmd = cmd . '\|foreign' " foreign keys
            let cmd = cmd . '\)' " end of criteria
            let cmd = cmd . '/-' "back up one line
            let cmd = cmd . "\n\<ESC>" " hit enter to complete the command
            " Decho cmd
            exe cmd
            noh
            let found = 1
            let start_line = line("'<")
            let end_line = line("'>")
            
            " Build comma separated list of input parameters
            while start_line <= end_line
                let line = getline(start_line)
                " Decho line
                let column_name = substitute( line, 
                            \ '[ \t"]*\(\<\w*\>\).*', '\1', "g" )
                let column_def = GetColumnDatatype( line )
                let procedure_def = procedure_def . 
                            \ indent_spaces .
                            \ "IN @" . column_name .
                            \ ' ' . column_def
                if start_line < end_line
                    let procedure_def = procedure_def .  ",\n"
                else
                    let procedure_def = procedure_def .  " )\n"
                endif
                let start_line = start_line + 1
            endwhile

            let procedure_def = procedure_def . "RESULT( " 

            let start_line = line("'<")
            let end_line = line("'>")
            
            " Build comma separated list of datatypes
            while start_line <= end_line
                let line = getline(start_line)
                " Decho line
                let column_def = GetColumnDatatype( line )
                " Decho column
                let procedure_def = procedure_def . column_def
                if start_line < end_line
                    let procedure_def = procedure_def .  ", "
                else
                    let procedure_def = procedure_def .  " )\n"
                endif
                let start_line = start_line + 1
            endwhile

            let procedure_def = procedure_def . "BEGIN\n\n" 
            
            " Create a sample SELECT statement
            let procedure_def = procedure_def . 
                        \ indent_spaces .
                        \ "SELECT " . column_list . "\n" .
                        \ indent_spaces .
                        \ "  FROM " . table_name . "\n"
            let where_clause = indent_spaces . 
                        \ substitute( column_list, 
                        \ '^\(\<\w*\>\)\(.*\)', " WHERE \\1 = \@\\1\\2", "g" )
            let where_clause = 
                        \ substitute( where_clause, 
                        \ ', \(\<\w*\>\)', 
                        \ "\n" . indent_spaces . "   AND \\1 = @\\1", "g" )
            let procedure_def = procedure_def . where_clause . ";\n\n"

            " Create a sample INSERT statement
            let procedure_def = procedure_def . 
                        \ indent_spaces . 
                        \ "INSERT INTO " . table_name . "( " .
                        \ column_list .
                        \ " )\n"
            let procedure_def = procedure_def . 
                        \ indent_spaces .
                        \ "VALUES( " .
                        \ substitute( column_list, '\(\<\w*\>\)', '@\1', "g" ).
                        \ " );\n\n"

            " Create a sample UPDATE statement
            let procedure_def = procedure_def . 
                        \ indent_spaces .
                        \ "UPDATE " . table_name . "\n" 
            echom 'column_list: '.column_list
            echom 'pk_column_list: '.pk_column_list
            let no_pk_column_list = 
                        \ strpart( column_list, strlen(pk_column_list) )
            " Check for the special case where there is no 
            " primary key for the table (ie ,\? \? )
            let set_clause = 
                        \ indent_spaces .
                        \ substitute( no_pk_column_list, 
                        \ ',\? \?\(\<\w*\>\)', 
                        \ "   SET \\1 = \@\\1", "" )
            let set_clause = 
                        \ substitute( set_clause, 
                        \ ', \(\<\w*\>\)', 
                        \ ",\n" . indent_spaces . "       \\1 = @\\1", "g" )
            " Check for the special case where there is no 
            " primary key for the table
            if strlen(pk_column_list) > 0
                let where_clause = 
                            \ indent_spaces .
                            \ substitute( pk_column_list, 
                            \ '^\(\<\w*\>\)', " WHERE \\1 = \@\\1", "" ) 
                let where_clause = 
                            \ substitute( where_clause, 
                            \ ', \(\<\w*\>\)', 
                            \ "\n" . indent_spaces . "   AND \\1 = @\\1", "g" )
            else
                " If there is no primary key for the table place
                " all columns in the WHERE clause
                let where_clause = 
                            \ indent_spaces .
                            \ substitute( column_list, 
                            \ '^\(\<\w*\>\)', " WHERE \\1 = \@\\1", "" ) 
                let where_clause = 
                            \ substitute( where_clause, 
                            \ ', \(\<\w*\>\)', 
                            \ "\n" . indent_spaces . "   AND \\1 = @\\1", "g" )
            endif
            let procedure_def = procedure_def . set_clause . "\n" 
            let procedure_def = procedure_def . where_clause .  ";\n\n"

            " Create a sample DELETE statement
            let procedure_def = procedure_def . 
                        \ indent_spaces .
                        \ "DELETE FROM " . table_name . "\n" 
            let procedure_def = procedure_def . where_clause . ";\n\n"

            let procedure_def = procedure_def . "END;\n\n" 
            
        endif

        " Return to previous location
        exe 'norm! '.buf_curline.'G'.buf_curcol."\<bar>"

        if found == 1
            break
        endif
        
        if &hidden == 0
            echom "Cannot search other buffers with set nohidden"
            break
        endif

        " Switch buffers to check to see if the create table
        " statement exists
        exec "bnext"
        if bufnr(expand("<abuf>")) == curbuf
            break
        endif
    endwhile
    
    exec "buffer " . curbuf

    " restore previous search string
    let @/ = saveSearch
    
    " Return to previous location
    exe 'norm! '.curline.'G'.curcol."\<bar>"

    if found == 0
        let @@ = ""
        echo "Table: " . table_name . " was not found"
        return ""
    endif 

    echo 'Procedure: sp_' . table_name . ' in unnamed buffer'
    if &clipboard == 'unnamed'
        let @* = procedure_def 
    else
        let @@ = procedure_def 
    endif

    return ""

endfunction

