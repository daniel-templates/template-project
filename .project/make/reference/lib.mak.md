# lib.mak


## User-Configurable Values

```
# Line Formatting ===================== type: [line]
line.indent        ?= $s$s
info.prefix        ?= $e
warning.prefix     ?= >>
error.prefix       ?= >>

# Type Formatting ===================== type: [line]
command.prefix     ?= $(line.indent)$x$s
```

## Automatic Variables

```
[path]    $@       $(@D)       $(@F)       Target File Path
[path]    $%       $(%D)       $(%F)       Archive-Target Member
[path]    $<       $(<D)       $(<F)       First Prereq
[paths]   $+       $(+D)       $(+F)       All Normal Prereqs
[paths]   $^       $(^D)       $(^F)       All Normal Prereqs (No Duplicates)
[paths]   $?       $(?D)       $(?F)       All Normal Prereqs Newer Than Target
[paths]   $|                               All Order-Only Prereqs
[path]    $*       $(*D)       $(*F)       Stem of implicit/static-pattern match
```


## Constants

### Symbols, Special Characters, Escape Sequences

```
 Value              Variable Containing Value       Variable Containing
                    (Long)             (Short)         Escaped Value
-----------------------------------------------------------------------
 't'         <--    $(true)
 ''          <--    $(false)             $e      <--    $(xe)
 ''          <--    $(empty)             $e      <--    $(xe)
 {space}     <--    $(char.space)        $s      <--    $(xs)
 {tab}       <--    $(char.tab)          $t      <--    $(xt)
 {lf}        <--    $(char.linefeed)     $n      <--    $(xn)
 {indent}    <--    $(line.indent)       $i      <--    $(xi)
 {lf}{space} <--                        $(ns)
 '`'         <--    $(char.grave)
 '~'         <--    $(char.tilde)        $h      <--    $(xh)
 '!'         <--    $(char.excl)
 '@'         <--    $(char.commat)
 '#'         <--    $(char.num)          $g      <--    $(xg)
 '$'         <--    $(char.dollar)       $x      <--    $(xx)
 '%'         <--    $(char.percnt)       $p      <--    $(xp)
 '^'         <--    $(char.hat)
 '&'         <--    $(char.amp)
 '*'         <--    $(char.ast)          $w
 '('         <--    $(char.lparen)       $l      <--    $(xl)
 ')'         <--    $(char.rparen)       $r      <--    $(xr)
 '-'         <--    $(char.hyphen)
 '_'         <--    $(char.lowbar)
 '='         <--    $(char.equals)
 '+'         <--    $(char.plus)
 '['         <--    $(char.lsqb)         $u      <--    $(xu)
 ']'         <--    $(char.rsqb)         $v      <--    $(xv)
 '{'         <--    $(char.lcub)         $j      <--    $(xj)
 '}'         <--    $(char.rcub)         $k      <--    $(xk)
 '\'         <--    $(char.bsol)         $b      <--    $(xb)
 '\ '        <--                        $(bs)    <--    $(xbs)
 '\\'        <--                        $(bb)    <--    $(xbb)
 '\%'        <--                        $(bp)    <--    $(xbp)
 '\['        <--                        $(bu)    <--    $(xbu)
 '\]'        <--                        $(bv)    <--    $(xbv)
 '\#'        <--                        $(bg)    <--    $(xbg)
 '|'         <--    $(char.verbar)
 ';'         <--    $(char.semi)
 ':'         <--    $(char.colon)
 '''         <--    $(char.apos)
 '"'         <--    $(char.quot)
 ','         <--    $(char.comma)        $c      <--    $(xc)
 '.'         <--    $(char.period)
 '<'         <--    $(char.lt)
 '>'         <--    $(char.gt)
 '/'         <--    $(char.sol)          $f      <--    $(xf)
 '?'         <--    $(char.quest)        $q
```

### Character Sets

```
$(char.lowers)    --> 'a b c d e f g h i j k l m n o p q r s t u v w x y z'
$(char.uppers)    --> 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z'
$(char.digits)    --> '0 1 2 3 4 5 6 7 8 9'
$(char.symbols)   --> '` ~ ! @ \# $$ % ^ & * ( ) - _ = + [ ] { } \ | ; : ' " , . < > / ?'
$(char.nonws)     --> $(char.lowers) $(char.uppers) $(char.digits) $(char.symbols)
$(char.alphanums) --> $(char.lowers) $(char.uppers) $(char.digits)
$(char.letters)   --> $(char.lowers) $(char.uppers)
```

### Character Namespaces

```
$(char.vars.symbols) --> 'char.grave char.tilde char.excl char.commat char.num
  char.dollar char.percnt char.hat char.amp char.ast char.lparen char.rparen
  char.hyphen char.lowbar char.equals char.plus char.lsqb char.rsqb char.lcub
  char.rcub char.bsol char.verbar char.semi char.colon char.apos char.quot
  char.comma char.period char.lt char.gt char.sol char.quest'
$(char.vars.ws) --> 'char.space char.tab char.linefeed'
```

## Functions

### Make Built-Ins

```
info            (Built-In)   [empty]   <-- $(info [str:message])
warning         (Built-In)   [empty]   <-- $(warning [str:message])
error           (Built-In)   [empty]   <-- $(error [str:message])
value           (Built-In)   [dynamic] <-- $(value [var])
origin          (Built-In)   {origin}  <-- $(origin [var])
flavor          (Built-In)   {flavor}  <-- $(flavor [var])
if              (Built-In)   [str]     <-- $(if [bool],[str:if_true],[str:if_false])
or              (Built-In)   [true:N]  <-- $(or [bool:1],[bool:2],...)
and             (Built-In)   [true:1]  <-- $(and [bool:1],[bool:2],...)
intcmp          (Built-In)   [str]     <-- $(intcmp {int:1},{int:2},[str:lss],[str:equ],[str:gtr])
eval            (Built-In)   [empty]   <-- $(eval [dynamic])
call            (Built-In)   [str]     <-- $(call [func],[str:1],[str:2],...)
shell           (Built-In)   [str]     <-- $(shell [str:command])
file (Read)     (Built-In)   [str]     <-- $(file < [path])
file (Write)    (Built-In)   [empty]   <-- $(file > [path],[str:write])
file (Append)   (Built-In)   [empty]   <-- $(file >> [path],[str:append])
let             (Built-In)   [str]     <-- $(let [list[var]],[list:val],[expr])
```

### Words

```
word.pack                    [word[T]] <-- $(call word.pack,[type:T],[T:val])
word.unpack                  [T]       <-- $(call word.unpack,[type:T],[word[T]:packed_val])

word.repack                  [word[T]] <-- $(call word.repack,[type:T],[word[T]:packed_val])
normalize                    [T]       <-- $(call normalize,[type:T],[T:val])

word.join.pair               [word[T]] <-- $(call word.join.pair,[type:T],[word[T]:sep],[word[T]:1],[word[T]:2])
normalize.pair               [T]       <-- $(call normalize.pair,[type:T],[T:sep],[T:1],[T:2])
```

### Lists

#### Lists: Misc

```
words           (Built-In)   {uint}    <-- $(words [list])

list.prune                   [list[T]] <-- $(call list.prune,[type:T],[list[T]])
list.repack                  [list[T]] <-- $(call list.repack,[type:T],[list[T]])

sort            (Built-In)   [list]    <-- $(sort [list])
list.reverse                 [list]    <-- $(call list.reverse,[list])

str.split                    [list[T]] <-- $(call str.split,[type:T],[str],[str:sep])
list.merge                   [str]     <-- $(call list.merge,[type:T],[list[T]],[str:sep])

addprefix       (Built-In)   [list]    <-- $(addprefix [str:prefix],[list])
addsuffix       (Built-In)   [list]    <-- $(addsuffix [str:suffix],[list])

join            (Built-In)   [list]          <-- $(join [list:1],[list:2])
list.join                    [list[list[T]]] <-- $(call list.join,[list[T]:1],[list[T]:2])
list.join.N                  [list[list[T]]] <-- $(call list.join.{N},[list[T]:1],[list[T]:N])
```

#### Lists: Filter, Match, Replace

```
Subst-Expand    (Built-In)   [list]    <-- $([var[list]]:{word.pattern:match}=[str.pattern:repl])           (Pattern Match/Replace)
Subst-Expand    (Built-In)   [list]    <-- $([var[list]]:[word:suffix]=[str:repl])                          (Suffix Match/Replace)
patsubst        (Built-In)   [list]    <-- $(patsubst {word.pattern:match},[str.pattern:repl],[list:in])    (Pattern Match/Replace)
patsubst        (Built-In)   [list]    <-- $(patsubst [list:match],[str:repl],[list:in])                    (Sublist Match/Replace)
filter          (Built-In)   [list]    <-- $(filter [list[word.pattern]:keep],[list:in])
filter-out      (Built-In)   [list]    <-- $(filter-out [list[word.pattern]:remove],[list:in])
list.filter                  [list[T]] <-- $(call list.filter,[type:T],[list[T]],[T:val])
list.filter-out              [list[T]] <-- $(call list.filter-out,[type:T],[list[T]],[T:val])
list.filter-out.start        [list]    <-- $(call list.filter-out.start,[list:in],[list:filter-out])
list.filter-out.end          [list]    <-- $(call list.filter-out.end,[list:in],[list:filter-out])
```

#### Lists: Iteration

```
foreach         (Built-In)   [list]    <-- $(foreach [var],[list],[expr([var])])

list.map                     [list[T]] <-- $(call list.map,[type:T],[func[T]([T],[str:const1],...)],[list[T]],[str:const1],...)
list.map.N                   [list[T]] <-- $(call list.map.{N},[type:T],
                                              [func[T]([T:1],...[T:N],[str:const1],...)],
                                              [list[T]:1],...,[list[T]:N],
                                              [str:const1],...
                                           )

list.reduce                  [list[T]] <-- $(call list.reduce,[type:T],[func[T]([str:acc],[T],[str:const1],...)],[str:acc],[list[T]],[str:const1],...)
list.reduce.N                [list[T]] <-- $(call list.reduce.{N},[type:T],
                                              [func[T]([str:acc],[T:1],...[T:N],[str:const1],...)],
                                              [str:acc],
                                              [list[T]:1],...,[list[T]:N],
                                              [str:const1],...
                                           )
```

#### Lists: Indexing

```
list.idx                     [idx]     <-- $(call list.idx,[list[T]],[int:idx])
list.idx.prev                [idx]     <-- $(call list.idx.prev,[list[T]],[int:idx])
list.idx.next                [idx]     <-- $(call list.idx.next,[list[T]],[int:idx])
list.idx.first               [idx]     <-- $(call list.idx.first,[list[T]])
list.idx.last                [idx]     <-- $(call list.idx.last,[list[T]])

list.insert                  [list[T]] <-- $(call list.insert,[type:T],[list[T]],[T:val],[idx])
list.prepend                 [list[T]] <-- $(call list.prepend,[type:T],[list[T]],[T:val])
list.append                  [list[T]] <-- $(call list.append,[type:T],[list[T]],[T:val])

list.remove                  [list[T]] <-- $(call list.remove,[list[T]],[idx])
list.remove.first            [list[T]] <-- $(call list.remove.first,[list[T]])
list.remove.last             [list[T]] <-- $(call list.remove.last,[list[T]])

word            (Built-In)   [word]    <-- $(word {idx},[list])
wordlist        (Built-In)   [list]    <-- $(wordlist {idx:m},{uint:n},[list])
firstword       (Built-In)   [word]    <-- $(firstword [list])
lastword        (Built-In)   [word]    <-- $(lastword [list])
list.get                     [T]       <-- $(call list.get,[type:T],[list[T]],[idx])
list.get.first               [T]       <-- $(call list.get.first,[type:T],[list[T]])
list.get.last                [T]       <-- $(call list.get.last,[type:T],[list[T]])

list.set                     [list[T]] <-- $(call list.set,[type:T],[list[T]],[T:val],[idx])
list.set.first               [list[T]] <-- $(call list.set.first,[type:T],[list[T]],[T:val])
list.set.last                [list[T]] <-- $(call list.set.last,[type:T],[list[T]],[T:val])
```

### Strings

#### Strings: Misc

```
str.equ                      [str] <-- $(call str.equ,[str:1],[str:2],[bool:case_insensitive])
str.neq                      [str] <-- $(call str.neq,[str:1],[str:2],[bool:case_insensitive])

findstring      (Built-In)   [str] <-- $(findstring [str:find],[str:in])

str.concat                   [str] <-- $(call str.concat.pair,[str:sep],[str:1],[str:2])
str.concat.pair              [str] <-- $(call str.concat,[str:sep],[str:1],[str:2],...,[str:8])

strip           (Built-In)   [str] <-- $(strip [str])

str.indent.add               [str] <-- $(call str.indent.add,[str:multiline],[str:indent])
str.indent.set               [str] <-- $(call str.indent.set,[str:multiline],[str:indent])

str.escape.vars              [str] <-- $(call str.escape.vars,[str],[list{var}])
str.expand.vars              [str] <-- $(call str.expand.vars,[str],[list{var}])

str.to.lower                 [str] <-- $(call str.to.lower,[str])
str.to.upper                 [str] <-- $(call str.to.upper,[str])

str.map                      [str] <-- $(call str.map,[type:T],[func[T]([T],[str:const1],...)],[str:sep],[str],[str:const1],...)
str.map.N                    [str] <-- $(call str.map.{N},[type:T],
                                          [func[T]([T:1],...[T:N],[str:const1],...)],
                                          [str:sep],
                                          [str:1],...,[str:N],
                                          [str:const1],...
                                       )
```

#### Strings: Single Match, Single Replace

```
subst           (Built-In)   [str] <-- $(subst [str:find],[str:repl],[str:in])
str.subst.str2str            [str] <-- $(call str.subst.str2str,[str:in],[str:find],[str:repl])
str.subst.str2var            [str] <-- $(call str.subst.str2var,[str:in],[str:find],[var:repl])
str.subst.var2str            [str] <-- $(call str.subst.var2str,[str:in],[var:find],[str:repl])
str.subst.var2var            [str] <-- $(call str.subst.var2var,[str:in],[var:find],[var:repl])
str.prefix.str               [str] <-- $(call str.prefix.str,[str:in],[str:find],[str:prefix])
str.prefix.var               [str] <-- $(call str.prefix.var,[str:in],[var:find],[str:prefix])
str.suffix.str               [str] <-- $(call str.suffix.str,[str:in],[str:find],[str:suffix])
str.suffix.var               [str] <-- $(call str.suffix.var,[str:in],[var:find],[str:suffix])
str.wrap.str                 [str] <-- $(call str.wrap.str,[str:in],[str:find],[str:prefix],[str:suffix])
str.wrap.var                 [str] <-- $(call str.wrap.var,[str:in],[var:find],[str:prefix],[str:suffix])
str.strip.str                [str] <-- $(call str.strip.str,[str:in],[str:strip])
str.strip.str.start          [str] <-- $(call str.strip.str.start,[str:in],[str:strip])
str.strip.str.end            [str] <-- $(call str.strip.str.end,[str:in],[str:strip])
str.strip.var                [str] <-- $(call str.strip.var,[str:in],[var:strip])
str.strip.var.start          [str] <-- $(call str.strip.var.start,[str:in],[str:strip])
str.strip.var.end            [str] <-- $(call str.strip.var.end,[str:in],[str:strip])
```

#### Strings: Multiple Match, Single Replace

```
str.subst.list2str           [str] <-- $(call str.subst.list2str,[str:in],[list:find],[str:repl])
str.subst.list2var           [str] <-- $(call str.subst.list2var,[str:in],[list:find],[var:repl])
str.subst.vars2str           [str] <-- $(call str.subst.vars2str,[str:in],[list{var}:find],[str:repl])
str.subst.vars2var           [str] <-- $(call str.subst.vars2var,[str:in],[list{var}:find],[var:repl])
str.strip.list               [str] <-- $(call str.strip.list,[str:in],[list:strip])
str.strip.list.start         [str] <-- $(call str.strip.list.start,[str:in],[list:strip])
str.strip.list.end           [str] <-- $(call str.strip.list.end,[str:in],[list:strip])
str.strip.vars               [str] <-- $(call str.strip.vars,[str:in],[list{var}:strip])
str.strip.vars.start         [str] <-- $(call str.strip.vars.start,[str:in],[list{var}:strip])
str.strip.vars.end           [str] <-- $(call str.strip.vars.end,[str:in],[list{var}:strip])
```

#### Strings: Multiple Match, Multiple Replace

```
str.subst.list2list          [str] <-- $(call str.subst.list2list,[str:in],[list:find],[list:repl])
str.subst.list2vars          [str] <-- $(call str.subst.list2vars,[str:in],[list:find],[list{var}:repl])
str.subst.vars2list          [str] <-- $(call str.subst.vars2list,[str:in],[list{var}:find],[list:repl])
str.subst.vars2vars          [str] <-- $(call str.subst.vars2vars,[str:in],[list{var}:find],[list{var}:repl])
str.prefix.list              [str] <-- $(call str.prefix.list,[str:in],[list:find],[str:prefix])
str.prefix.vars              [str] <-- $(call str.prefix.vars,[str:in],[list{var}:find],[str:prefix])
str.suffix.list              [str] <-- $(call str.suffix.list,[str:in],[list:find],[str:suffix])
str.suffix.vars              [str] <-- $(call str.suffix.vars,[str:in],[list{var}:find],[str:suffix])
str.wrap.list                [str] <-- $(call str.wrap.list,[str:in],[list:find],[str:prefix],[str:suffix])
str.wrap.vars                [str] <-- $(call str.wrap.vars,[str:in],[list{var}:find],[str:prefix],[str:suffix])
str.treesubst.list2list      [str] <-- $(call str.treesubst.list2list,[str:in],[list:find],[list:repl])
str.treesubst.list2vars      [str] <-- $(call str.treesubst.list2vars,[str:in],[list:find],[list{var}:repl])
str.treesubst.vars2list      [str] <-- $(call str.treesubst.vars2list,[str:in],[list{var}:find],[list:repl])
str.treesubst.vars2vars      [str] <-- $(call str.treesubst.vars2vars,[str:in],[list{var}:find],[list{var}:repl])
```


### Paths

#### Paths: Misc

```
path.addprefix               [path]       <-- $(call path.addprefix,[path],[path:prefix])
path.addsuffix               [path]       <-- $(call path.addsuffix,[path],[path:suffix])
list.path.addprefix          [list[path]] <-- $(call list.path.addprefix,[list[path]],[path:prefix])
list.path.addsuffix          [list[path]] <-- $(call list.path.addsuffix,[list[path]],[path:suffix])
```

#### Paths: Components

```
abspath         (Built-In)   [paths]      <-- $(abspath [paths])
realpath        (Built-In)   [paths]      <-- $(realpath [paths])
dir             (Built-In)   [paths]      <-- $(dir [paths])
notdir          (Built-In)   [paths]      <-- $(notdir [paths])
basename        (Built-In)   [paths]      <-- $(basename [paths])
suffix          (Built-In)   [paths]      <-- $(suffix [paths])
path.abspath                 [path]       <-- $(call path.abspath,[path])
path.realpath                [path]       <-- $(call path.realpath,[path])
path.dir                     [path]       <-- $(call path.dir,[path])
path.notdir                  [path]       <-- $(call path.notdir,[path])
path.parent                  [path]       <-- $(call path.parent,[path])
path.name                    [path]       <-- $(call path.name,[path])
path.name.base               [path]       <-- $(call path.name.base,[path])
path.basename                [path]       <-- $(call path.basename,[path])
path.suffix                  [path]       <-- $(call path.suffix,[path])
list.path.abspath            [list[path]] <-- $(call list.path.abspath,[list[path]])
list.path.realpath           [list[path]] <-- $(call list.path.realpath,[list[path]])
list.path.dir                [list[path]] <-- $(call list.path.dir,[list[path]])
list.path.notdir             [list[path]] <-- $(call list.path.notdir,[list[path]])
list.path.parent             [list[path]] <-- $(call list.path.parent,[list[path]])
list.path.name               [list[path]] <-- $(call list.path.name,[list[path]])
list.path.name.base          [list[path]] <-- $(call list.path.name.base,[list[path]])
list.path.basename           [list[path]] <-- $(call list.path.basename,[list[path]])
list.path.suffix             [list[path]] <-- $(call list.path.suffix,[list[path]])
```

#### Paths: Substitutions

```
path.subst                   [path]       <-- $(call path.subst,[path:in],[path:find],[path:repl])
path.patsubst                [path]       <-- $(call path.patsubst,[path:in],[path.pattern:find],[path.pattern:repl])
path.patsubst.dir            [path]       <-- $(call path.patsubst.dir,[path:in],[path.pattern:dir],[path.pattern:repl])
path.patsubst.notdir         [path]       <-- $(call path.patsubst.notdir,[path:in],[path.pattern:notdir],[path.pattern:repl])
path.patsubst.parent         [path]       <-- $(call path.patsubst.parent,[path:in],[path.pattern:parent],[path.pattern:repl])
path.patsubst.name           [path]       <-- $(call path.patsubst.name,[path:in],[path.pattern:name],[path.pattern:repl])
path.patsubst.name.base      [path]       <-- $(call path.patsubst.name.base,[path:in],[path.pattern:name.base],[path.pattern:repl])
path.patsubst.basename       [path]       <-- $(call path.patsubst.basename,[path:in],[path.pattern:basename],[path.pattern:repl])
path.patsubst.suffix         [path]       <-- $(call path.patsubst.suffix,[path:in],[path.pattern:suffix],[path.pattern:repl])
list.path.subst              [list[path]] <-- $(call list.path.subst,[list[path]:in],[path:find],[path:repl])
list.path.patsubst           [list[path]] <-- $(call list.path.patsubst,[list[path]:in],[path.pattern:find],[path.pattern:repl])
list.path.patsubst.dir       [list[path]] <-- $(call list.path.patsubst.dir,[list[path]:in],[path.pattern:dir],[path.pattern:repl])
list.path.patsubst.notdir    [list[path]] <-- $(call list.path.patsubst.notdir,[list[path]:in],[path.pattern:notdir],[path.pattern:repl])
list.path.patsubst.parent    [list[path]] <-- $(call list.path.patsubst.parent,[list[path]:in],[path.pattern:parent],[path.pattern:repl])
list.path.patsubst.name      [list[path]] <-- $(call list.path.patsubst.name,[list[path]:in],[path.pattern:name],[path.pattern:repl])
list.path.patsubst.name.base   [list[path]] <-- $(call list.path.patsubst.name.base,[list[path]:in],[path.pattern:name.base],[path.pattern:repl])
list.path.patsubst.name.suffix [list[path]] <-- $(call list.path.patsubst.name.suffix,[list[path]:in],[path.pattern:name.suffix],[path.pattern:repl])
list.path.patsubst.basename  [list[path]] <-- $(call list.path.patsubst.basename,[list[path]:in],[path.pattern:basename],[path.pattern:repl])
list.path.patsubst.suffix    [list[path]] <-- $(call list.path.patsubst.suffix,[list[path]:in],[path.pattern:suffix],[path.pattern:repl])
```

#### Paths: Search

```
wildcard        (Built-In)   [paths]      <-- $(wildcard [paths.pattern])
path.wildcard                [list[path]] <-- $(call path.wildcard,[path.pattern:find])
list.path.wildcard           [list[path]] <-- $(call list.path.wildcard,[list[path.pattern]:find])
path.exists                  [path]       <-- $(call path.exists,[path])
file.exists                  [path]       <-- $(call dir.exists,[path])
dir.exists                   [path]       <-- $(call file.exists,[path])
list.path.exists             [list[path]] <-- $(call list.path.exists,[list[path]])
list.file.exists             [list[path]] <-- $(call list.dir.exists,[list[path]])
list.dir.exists              [list[path]] <-- $(call list.file.exists,[list[path]])
```
