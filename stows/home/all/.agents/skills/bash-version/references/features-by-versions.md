# Notable changes in released bash versions

| **Feature** | **Added in version** | **Copied from / Inspired by** |
| --- | --- | --- |
| ${ CMDS;} | 5.3 (2025) | ksh93 |
| ${\|CMDS;} | 5.3 (2025) | mksh |
| GLOBSORT (variable) | 5.3 (2025) | zsh's o/O glob qualifiers |
| local BASH_REMATCH | 5.3 (2025) |  |
| compgen -V | 5.3 (2025) | native |
| read -E | 5.3 (2025) |  |
| array_expand_once (shopt) | 5.3 (2025) |  |
| printf %#Q %#q (${var@Q} quoting) | 5.3 (2025) | zsh's q, qq, qqq, qqqq, q+, q- parameter expansion flags |
| printf %l.*s %lc (character aware %s %c) | 5.3 (2025) | zsh's default for %s, ksh93's %Ls/%Lc |
| READLINE_ARGUMENT (variable) | 5.2 (2022) | zsh's NUMERIC variable |
| varredir_close (shopt) | 5.2 (2022) |  |
| printf %Q | 5.2 (2022) |  |
| noexpand_translations (shopt) | 5.2 (2022) |  |
| ${var@k} | 5.2 (2022) | zsh's ${(kv)var} |
| ${var/$pat/&}, patsub_replacement (shopt) | 5.2 (2022) | ksh93's \0, zsh's $MATCH |
| globskipdots (shopt) | 5.2 (2022) |  |
| BASH_REMATCH is no longer readonly | 5.1 (2020) |  |
| PROMPT_COMMAND may be an array | 5.1 (2020) | zsh's precmd_functions array |
| SRANDOM (variable) | 5.1 (2020) |  |
| wait -p varname | 5.1 (2020) |  |
| declare -I | 5.1 (2020) | NetBSD sh (default behaviour in ash) |
| ${var@U}, ${var@u}, ${var@L}, ${var@K} | 5.1 (2020) | zsh's U, L, C, kv parameter expansion flags, zsh/tcsh's :u, :l modifiers |
| assoc=(key1 value1 key2 value2) assoc+=(key value) | 5.1 (2020) |  |
| BASH_ARGV0 (variable) | 5.0 (2019) |  |
| EPOCHSECONDS, EPOCHREALTIME (variables) | 5.0 (2019) | zsh (2003, 2011) |
| wait -f | 5.0 (2019) |  |
| history -d allows negative offsets | 5.0 (2019) |  |
| assoc_expand_once (shopt) | 5.0 (2019) |  |
| localvar_inherit (shopt) | 5.0 (2019) |  |
| --pretty-print (invocation option) | 5.0 (2019) | native |
| PS0 (variable) | 4.4 (2016) | native |
| [loadable builtin](/BashLoadableBuiltins) deployment infrastructure | 4.4 (2016) | ksh93 (1993) |
| mapfile/readarray -d | 4.4 (2016) | native |
| --help for builtins | 4.4 (2016) | ksh93 (2001, possibly earlier) |
| ${var@a}, ${var@A}, ${var@E}, ${var@P}, ${var@Q} | 4.4 (2016) | mksh (2012) for the syntax, zsh (1990s) for the feature |
| local - | 4.4 (2016) | Almquist shell (1989) |
| $! and wait for process substitutions | 4.4 (2016) | native |
| wait -n | 4.3 (2014) | native |
| test -R | 4.3 (2014) | ksh93 (1993) |
| test -v 'array[element]' (bug fix) | 4.3 (2014) | ksh93 (1993) |
| declare/typeset -n and associated changes to ${!ref} and for..in | 4.3 (2014) | ksh93 (1993) |
| array[-idx] (in assignments, read, unset, etc) | 4.3 (2014) | zsh (1990s) |
| printf %(fmt)T uses -1 as default argument instead of 0 | 4.3 (2011) | ksh93 (1999) |
| quotes in the replacement part of ${var/pat/"$rep"} are no longer literal | 4.3 (2011) |  |
| \uXXXX and \UXXXXXXXX | 4.2 (2011) | zsh (2001) |
| declare -g | 4.2 (2011) | zsh (1990s) (Broken. bash implements this as -G in 5.3+ as an undocumented feature which is incompatible with the older undocumented -G alias. ksh93's -g is similar to bash's but we might need to change it.) |
| test -v | 4.2 (2011) | ksh93 (2009) |
| printf %(fmt)T | 4.2 (2011) | ksh93 (1999) |
| ${array[-idx]} and ${var:start:-len} | 4.2 (2011) | zsh (1990s) and native |
| lastpipe (shopt) | 4.2 (2011) | ksh (1980s) default behaviour there |
| read -N | 4.1 (2010) | ksh93 (2003) |
| {var}> or {var}< etc. (FD variable assignment) | 4.1 (2010) | developed jointly with ksh93 and zsh |
| syslog history (compile option) | 4.1 (2010) | native |
| complete -D (allowing dynamically loaded completions) | 4.1 (2010) |  |
| BASH_XTRACEFD (variable) | 4.1 (2010) | native |
| ${@:offset[:length]} includes $0 | 4.0 (2009) | ksh |
| ;& and ;;& fall-throughs for case | 4.0 (2009) | ksh93 (1993) |
| associative arrays | 4.0 (2009) | ksh93 (1993) |
| &>> and \|& | 4.0 (2009) | native and csh (1970s) |
| command_not_found_handle (function) | 4.0 (2009) | native |
| compopt (builtin) | 4.0 (2009) |  |
| coproc (keyword) | 4.0 (2009) | ksh (1980s), zsh (1990) for the coproc keyword |
| globstar (shopt) | 4.0 (2009) | zsh (1992), ksh93 (2005) for the name of the option |
| mapfile/readarray (builtin) | 4.0 (2009) | native |
| ${var,} ${var,,} ${var^} ${var^^} | 4.0 (2009) | native |
| {009..012} (leading zeros in brace expansions) | 4.0 (2009) | zsh (1995) |
| {x..y..incr} | 4.0 (2009) | ksh93 (2005) |
| read -t 0 (test input availability) | 4.0 (2009) |  |
| read -t 0.5 | 4.0 (2009) | zsh (2003) |
| read -i | 4.0 (2009) | zsh (vared) (1990s) |
| x+=string array+=(string) | 3.1 (2005) | ksh93 (2000) |
| printf -v var | 3.1 (2005) | native |
| nocasematch (shopt) | 3.1 (2005) | native |
| {x..y} | 3.0 (2004) | zsh (1995) |
| ${!array[@]} | 3.0 (2004) | ksh93 (1993) |
| [[ =~ | 3.0 (2004) | native |
| BASH_REMATCH | 3.0 (2004) | native |
| RETURN (trap) | 3.0 (2004) | native |
| pipefail (option) | 3.0 (2004) | ksh93 |
| failglob (shopt) | 3.0 (2004) | native |
| printf %q produces $'...' | 2.05b (2002) | ksh93 (1993) |
| [n]>&word- and [n]<&word- | 2.05b (2002) | ksh93 |
| <<< | 2.05b (2002) | zsh (1991) |
| printf %n | 2.05a (2001) | ksh93 |
| i++ | 2.04 (2000) | ksh93 (1993) |
| for ((;;)) | 2.04 (2000) | ksh93 (1993) |
| /dev/fd/N, /dev/tcp/host/port, etc. | 2.04 (2000) | ksh93 (1993) |
| read -t, -n, -d and -s | 2.04 (2000) | ksh93 (1993) |
| a=(*.txt) file expansion | 2.03 (1999) | ksh93 (1993) |
| extglob (shopt) | 2.02 (1998) | ksh (1980s) |
| [[ | 2.02 (1998) | ksh (1980s) |
| printf (builtin) | 2.02 (1998) | ksh (1980s) |
| $(< filename) | 2.02 (1998) | ksh (1980s) |
| ** (exponentiation) | 2.02 (1998) | zsh (1994) |
| \xXX | 2.02 (1998) | zsh (1994 or earlier) |
| (( )) | 2.0 (1996) | ksh (1980s) |
| arrays | 2.0 (1996) | csh (1979), zsh (1991) for array=(assignment) syntax |
| $'...' (new quoting syntax) | 2.0 (1996) | ksh93 (1993) |
