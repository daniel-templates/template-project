# lib.common.md

### Automatic Variables


### Default Variables

MAKEFILE_LIST []
.DEFAULT_GOAL [target]
MAKE_RESTARTS [idx]
MAKE_TERMOUT [bool]
MAKE_TERMERR [bool]
.RECIPEPREFIX [char]
.VARIABLES
.FEATURES
.INCLUDE_DIRS
.EXTRA_PREREQS
SHELL
MAKESHELL
.SHELLFLAGS
.SHELLSTATUS
MAKE
MAKEFLAGS
GNUMAKEFLAGS
MFLAGS
MAKEOVERRIDES
MAKECMDGOALS
VPATH

## BOOLEANS


### Booleans: Constants


### Booleans: Logic

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
if | `[str]` | `$(if [bool],[str:if_true],[str:if_false])` | GNU Make
or | `[true:N]` | `$(or [bool:1],[bool:2],...)` | GNU Make 3.81+
and | `[true:1]` | `$(and [bool:1],[bool:2],...)` | GNU Make 3.81+

### Booleans: User Interaction

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
bool.is.truthy | `[bool]` | `$(call bool.is.truthy,[str])` | lib.common.mak
bool.is.falsey | `[bool]` | `$(call bool.is.falsey,[str])` | lib.common.mak

## CHARACTERS


### Characters: Charsets

Function | Syntax | Requires
------------------- | ------ | --------
chars.split | `[list{char}] <-- $(call chars.split,[type:T],[T:val])`

## STRINGS

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
str.lower [lower] <-- $(call str.lower,[str])
str.upper [upper] <-- $(call str.upper,[str])
str.len {uint} <-- $(call str.len,[type:T],[T:str])
str.sub [T] <-- $(call str.sub,[type:T],[T:str],[idx:start],[uint:end])
str.cnt {uint} <-- $(call str.cnt,[type:T],[T:find],[T:in])

### Strings: Tests

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
findstring [bool] <-- $(findstring [str:find],[str:in]) GNU Make
str.equ [bool] <-- $(call str.equ,[str:1],[str:2],[bool:case_insensitive])
str.neq [bool] <-- $(call str.neq,[str:1],[str:2],[bool:case_insensitive])

### Strings: Concatenation

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
str.concat.pair [str] <-- $(call str.concat.pair,[str:sep],[str:1],[str:2])
str.concat [str] <-- $(call str.concat,[str:sep],[str:1],[str:2],...,[str:8])
word.concat.pair [word[T]] <-- $(call word.concat.pair,[type:T],[word[T]:sep],[word[T]:1],[word[T]:2])

### Strings: Iteration

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
str.map [str] <-- $(call str.map.{N},[type:T],\
str.map.1 [func[T]([T:1],...,[T:N],[str:const1],...)],\
str.map.2 [str:sep],\
str.map.3 [str:1],...,[str:N],\
str.map.4 [str:const1],...)

### Strings: Single Match, Single Replace

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
strip [str] <-- $(strip [str]) GNU Make
subst [str] <-- $(subst [str:find],[str:repl],[str:in]) GNU Make
str.subst.str2str [str] <-- $(call str.subst.str2str,[str:in],[str:find],[str:repl])
str.subst.str2var [str] <-- $(call str.subst.str2var,[str:in],[str:find],[var:repl])
str.subst.var2str [str] <-- $(call str.subst.var2str,[str:in],[var:find],[str:repl])
str.subst.var2var [str] <-- $(call str.subst.var2var,[str:in],[var:find],[var:repl])
str.prefix.str [str] <-- $(call str.prefix.str,[str:in],[str:find],[str:prefix])
str.prefix.var [str] <-- $(call str.prefix.var,[str:in],[var:find],[str:prefix])
str.suffix.str [str] <-- $(call str.suffix.str,[str:in],[str:find],[str:suffix])
str.suffix.var [str] <-- $(call str.suffix.var,[str:in],[var:find],[str:suffix])
str.wrap.str [str] <-- $(call str.wrap.str,[str:in],[str:find],[str:prefix],[str:suffix])
str.wrap.var [str] <-- $(call str.wrap.var,[str:in],[var:find],[str:prefix],[str:suffix])
str.strip.str [str] <-- $(call str.strip.str,[str:in],[str:strip])
str.strip.str.start [str] <-- $(call str.strip.str.start,[str:in],[str:strip])
str.strip.str.end [str] <-- $(call str.strip.str.end,[str:in],[str:strip])
str.strip.var [str] <-- $(call str.strip.var,[str:in],[var:strip])
str.strip.var.start [str] <-- $(call str.strip.var.start,[str:in],[str:strip])
str.strip.var.end [str] <-- $(call str.strip.var.end,[str:in],[str:strip])

### Strings: Multiple Match, Single Replace

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
str.subst.list2str [str] <-- $(call str.subst.list2str,[str:in],[list:find],[str:repl])
str.subst.list2var [str] <-- $(call str.subst.list2var,[str:in],[list:find],[var:repl])
str.subst.vars2str [str] <-- $(call str.subst.vars2str,[str:in],[list{var}:find],[str:repl])
str.subst.vars2var [str] <-- $(call str.subst.vars2var,[str:in],[list{var}:find],[var:repl])
str.strip.list [str] <-- $(call str.strip.list,[str:in],[list:strip])
str.strip.list.start [str] <-- $(call str.strip.list.start,[str:in],[list:strip])
str.strip.list.end [str] <-- $(call str.strip.list.end,[str:in],[list:strip])
str.strip.vars [str] <-- $(call str.strip.vars,[str:in],[list{var}:strip])
str.strip.vars.start [str] <-- $(call str.strip.vars.start,[str:in],[list{var}:strip])
str.strip.vars.end [str] <-- $(call str.strip.vars.end,[str:in],[list{var}:strip])

### Strings: Multiple Match, Multiple Replace

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
str.subst.list2list [str] <-- $(call str.subst.list2list,[str:in],[list:find],[list:repl])
str.subst.list2vars [str] <-- $(call str.subst.list2vars,[str:in],[list:find],[list{var}:repl])
str.subst.vars2list [str] <-- $(call str.subst.vars2list,[str:in],[list{var}:find],[list:repl])
str.subst.vars2vars [str] <-- $(call str.subst.vars2vars,[str:in],[list{var}:find],[list{var}:repl])
str.prefix.list [str] <-- $(call str.prefix.list,[str:in],[list:find],[str:prefix])
str.prefix.vars [str] <-- $(call str.prefix.vars,[str:in],[list{var}:find],[str:prefix])
str.suffix.list [str] <-- $(call str.suffix.list,[str:in],[list:find],[str:suffix])
str.suffix.vars [str] <-- $(call str.suffix.vars,[str:in],[list{var}:find],[str:suffix])
str.wrap.list [str] <-- $(call str.wrap.list,[str:in],[list:find],[str:prefix],[str:suffix])
str.wrap.vars [str] <-- $(call str.wrap.vars,[str:in],[list{var}:find],[str:prefix],[str:suffix])

### Strings: Tree Match, Multiple Replace

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
str.treesubst.list2list [str] <-- $(call str.treesubst.list2list,[str:in],[list:find],[list:repl])
str.treesubst.list2vars [str] <-- $(call str.treesubst.list2vars,[str:in],[list:find],[list{var}:repl])
str.treesubst.vars2list [str] <-- $(call str.treesubst.vars2list,[str:in],[list{var}:find],[list:repl])
str.treesubst.vars2vars [str] <-- $(call str.treesubst.vars2vars,[str:in],[list{var}:find],[list{var}:repl])

## VARIABLES

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
value [str] <-- $(value [var:simple]) GNU Make
call [str] <-- $(call [var:recursive],[str:1],[str:2],...) GNU Make
let [str] <-- $(let [list[var]],[list:vals],[expr]) GNU Make 4.4+
var.is.shortname [bool:var] <-- $(call var.is.shortname,[var])

### Variables: Origin and Flavor

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
origin {origin} <-- $(origin [var]) GNU Make
flavor {flavor} <-- $(flavor [var]) GNU Make
var.is.defined [bool:var] <-- $(call var.is.defined,[var])
var.is.undefined [bool:var] <-- $(call var.is.undefined,[var])
var.is.environment [bool:var] <-- $(call var.is.environment,[var])
var.is.commandline [bool:var] <-- $(call var.is.commandline,[var])
var.is.makefile [bool:var] <-- $(call var.is.makefile,[var])
var.is.internal [bool:var] <-- $(call var.is.internal,[var])

### Variables: Value Tests

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
var.is.ws [bool:var] <-- $(call var.is.ws,[var])
var.is.nonws [bool:var] <-- $(call var.is.nonws,[var])
var.is.empty [bool:var] <-- $(call var.is.empty,[var])
var.is.def.empty [bool:var] <-- $(call var.is.def.empty,[var])
var.is.nonempty [bool:var] <-- $(call var.is.nonempty,[var])

### Variables: Assignment

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
var.set [empty] <-- $(call var.set,[directives],[var],[type:T],[T:val])
var.append [empty] <-- $(call var.append,[directives],[var],[type:T],[T:val])
var.set_with_alternatives $(call var.set_with_alternatives,{variable},{assignment_operator},[initial_value],[list of alternatives],[value_if_still_empty])
var.push [empty] <-- $(call var.push,[var],[type:T],[T:val])
var.pop [empty] <-- $(call var.pop,[var])

## LISTS

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
list.create [list[T]] <-- $(call list.create,[type:T],\
item 1 $n\
item 2 $n\
)

### Lists: Ordering

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
sort [list[T]] <-- $(sort [list[T]]) GNU Make
list.reverse [list[T]] <-- $(call list.reverse,[list[T]])

### Lists: Packing, Unpacking

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
word.pack [word[T]] <-- $(call word.pack,[type:T],[T:val])
word.unpack [T] <-- $(call word.unpack,[type:T],[word[T]:packed_val])
list.prune [list[T]] <-- $(call list.prune,[type:T],[list[T]])
list.repack [list[T]] <-- $(call list.repack,[type:T],[list[T]])

### Lists: String Split and Merge

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
str.split [list[T]] <-- $(call str.split,[type:T],[T:str],[T:sep])
list.merge [str] <-- $(call list.merge,[type:T],[list[T]],[T:sep])

### Lists: Match, Replace

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
Subst-Expand [list] <-- $([var[list]]:{word:pattern}=[str:repl]) (Pattern Match/Replace) GNU Make
Subst-Expand [list] <-- $([var[list]]:[word:suffix]=[str:repl]) (Suffix Match/Replace) GNU Make
patsubst [list] <-- $(patsubst {word:pattern},[str:repl],[list:in]) (Pattern Match/Replace) GNU Make
patsubst [list] <-- $(patsubst [list:match],[str:repl],[list:in]) (Sublist Match/Replace) GNU Make

### Lists: Filtering

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
filter [list] <-- $(filter [list:keep_patterns],[list]) GNU Make
filter-out [list] <-- $(filter-out [list:remove_patterns],[list]) GNU Make
filter.start [list] <-- $(call filter.start,[list:keep_patterns],[list])
filter.end [list] <-- $(call filter.end,[list:remove_patterns],[list])
filter-out.start [list] <-- $(call filter-out.start,[list:keep_patterns],[list])
filter-out.end [list] <-- $(call filter-out.end,[list:remove_patterns],[list])

### Lists: Resizing

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
list.extend.start [list[T]] <-- $(call list.extend.start,[type:T],[list[T]:from],[list[T]:to],[T:pad_with])
list.extend.end [list[T]] <-- $(call list.extend.end,[type:T],[list[T]:from],[list[T]:to],[T:pad_with])
list.resize.start [list[T]] <-- $(call list.resize.start,[type:T],[list[T]:from],[list[T]:to],[T:pad_with])
list.resize.end [list[T]] <-- $(call list.resize.end,[type:T],[list[T]:from],[list[T]:to],[T:pad_with])

### Lists: Iteration

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
join [list[T]] <-- $(join [list[T]:1],[list[T]:2]) GNU Make
foreach [list[T]] <-- $(foreach [var],[list[T]],[expr[T]([var])]) GNU Make
list.map [list[T]] <-- $(call list.map.{N},[type:T],const1],...)
list.map.1 [func[T]([T:1],...,[T:N],[str:const1],...)],
list.map.2 [list[T]:1],...,[list[T]:N],
list.map.3 [str:const1],...
list.map.4 )
list.reduce [str] <-- $(call list.reduce.{N},[type:T],
list.reduce.1 [func[str]([str:acc],[T:1],...,[T:N],[str:const1],...)],
list.reduce.2 [str:acc],
list.reduce.3 [list[T]:1],...,[list[T]:N],
list.reduce.4 [str:const1],...
)

### Lists: Indexing

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
words {uint} <-- $(words [list]) GNU Make
list.idx [idx] <-- $(call list.idx,[list[T]],[int:idx])
list.idx.prev [idx] <-- $(call list.idx.prev,[list[T]],[int:idx])
list.idx.next [idx] <-- $(call list.idx.next,[list[T]],[int:idx])
list.idx.first [idx] <-- $(call list.idx.first,[list[T]])
list.idx.last [idx] <-- $(call list.idx.last,[list[T]])

### Lists: Add Items

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
list.insert [list[T]] <-- $(call list.insert,[type:T],[list[T]],[T:val],[idx])
list.prepend [list[T]] <-- $(call list.prepend,[type:T],[list[T]],[T:val])
list.append [list[T]] <-- $(call list.append,[type:T],[list[T]],[T:val])

### Lists: Remove Items

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
list.remove [list[T]] <-- $(call list.remove,[list[T]],[idx])
list.remove.first [list[T]] <-- $(call list.remove.first,[list[T]])
list.remove.last [list[T]] <-- $(call list.remove.last,[list[T]])

### Lists: Get Items

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
word [word] <-- $(word {idx},[list]) GNU Make
wordlist [list] <-- $(wordlist {idx:m},{uint:n},[list]) GNU Make
firstword [word] <-- $(firstword [list]) GNU Make 3.81+
lastword [word] <-- $(lastword [list]) GNU Make 3.81+
list.get [T] <-- $(call list.get,[type:T],[list[T]],[idx])
list.get.first [T] <-- $(call list.get.first,[type:T],list[T]])
list.get.last [T] <-- $(call list.get.last,[type:T],list[T]])

### Lists: Set Items

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
list.set [list[T]] <-- $(call list.set,[type:T],[list[T]],[T:val],[idx])
list.set.first [list[T]] <-- $(call list.set.first,[type:T],[list[T]],[T:val])
list.set.last [list[T]] <-- $(call list.set.last,[type:T],[list[T]],[T:val])

### Lists: 2D Lists

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
list.join [list[list[T]]] <-- $(call list.join,[list[T]:1],[list[T]:2])
list.join.2 [list[list[T]]] <-- $(call list.join.{N},[list[T]:1],[list[T]:N])
list.join.3
list.join.4

## PATHS

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
multipath.create [multipath] <-- $(call multipath.create,$n\
/path/to a/file.1 $n\
path/to a/dir/ $n\
)

### Path: Components

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
abspath [list<wpath>] <-- $(abspath [list<wpath>]) GNU Make
realpath [list<wpath>] <-- $(realpath [list<wpath>]) GNU Make
dir [list<wpath>] <-- $(dir [list<wpath>]) GNU Make
notdir [list<wpath>] <-- $(notdir [list<wpath>]) GNU Make
basename [list<wpath>] <-- $(basename [list<wpath>]) GNU Make
suffix [list<wpath>] <-- $(suffix [list<wpath>]) GNU Make
path.abspath [path] <-- $(call path.abspath,[path])
path.realpath [path] <-- $(call path.realpath,[path])
path.dir [path] <-- $(call path.dir,[path])
path.notdir [path] <-- $(call path.notdir,[path])
path.parent [path] <-- $(call path.parent,[path])
path.name [path] <-- $(call path.name,[path])
path.name.base [path] <-- $(call path.name.base,[path])
path.basename [path] <-- $(call path.basename,[path])
path.suffix [path] <-- $(call path.suffix,[path])
list.path.abspath [list[path]] <-- $(call list.path.abspath,[list[path]])
list.path.realpath [list[path]] <-- $(call list.path.realpath,[list[path]])
list.path.dir [list[path]] <-- $(call list.path.dir,[list[path]])
list.path.notdir [list[path]] <-- $(call list.path.notdir,[list[path]])
list.path.parent [list[path]] <-- $(call list.path.parent,[list[path]])
list.path.name [list[path]] <-- $(call list.path.name,[list[path]])
list.path.name.base [list[path]] <-- $(call list.path.name.base,[list[path]])
list.path.basename [list[path]] <-- $(call list.path.basename,[list[path]])
list.path.suffix [list[path]] <-- $(call list.path.suffix,[list[path]])

### Path: Prefix/Suffix

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
addprefix [list<wpath>] <-- $(addprefix [str:prefix],[list<wpath>]) GNU Make
addsuffix [list<wpath>] <-- $(addsuffix [str:suffix],[list<wpath>]) GNU Make
path.addprefix [path] <-- $(call path.addprefix,[path],[path:prefix])
path.addsuffix [path] <-- $(call path.addsuffix,[path],[path:suffix])
list.path.addprefix [list[path]] <-- $(call list.path.addprefix,[list[path]],[path:prefix])
list.path.addsuffix [list[path]] <-- $(call list.path.addsuffix,[list[path]],[path:suffix])

### Path: Substitutions

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
path.subst [path] <-- $(call path.subst,[path:in],[path:find],[path:repl])
path.patsubst [path] <-- $(call path.patsubst,[path:in],[path:find],[path:repl])
path.patsubst.dir [path] <-- $(call path.patsubst.dir,[path:in],[path:dir],[path:repl])
path.patsubst.notdir [path] <-- $(call path.patsubst.notdir,[path:in],[path:notdir],[path:repl])
path.patsubst.parent [path] <-- $(call path.patsubst.parent,[path:in],[path:parent],[path:repl])
path.patsubst.name [path] <-- $(call path.patsubst.name,[path:in],[path:name],[path:repl])
path.patsubst.name.base [path] <-- $(call path.patsubst.name.base,[path:in],[path:name.base],[path:repl])
path.patsubst.basename [path] <-- $(call path.patsubst.basename,[path:in],[path:basename],[path:repl])
path.patsubst.suffix [path] <-- $(call path.patsubst.suffix,[path:in],[path:suffix],[path:repl])
list.path.subst [list[path]] <-- $(call list.path.subst,[list[path]:in],[path:find],[path:repl])
list.path.patsubst [list[path]] <-- $(call list.path.patsubst,[list[path]:in],[path:find],[path:repl])
list.path.patsubst.dir [list[path]] <-- $(call list.path.patsubst.dir,[list[path]:in],[path:dir],[path:repl])
list.path.patsubst.notdir [list[path]] <-- $(call list.path.patsubst.notdir,[list[path]:in],[path:notdir],[path:repl])
list.path.patsubst.parent [list[path]] <-- $(call list.path.patsubst.parent,[list[path]:in],[path:parent],[path:repl])
list.path.patsubst.name [list[path]] <-- $(call list.path.patsubst.name,[list[path]:in],[path:name],[path:repl])
list.path.patsubst.name.base [list[path]] <-- $(call list.path.patsubst.name.base,[list[path]:in],[path:name.base],[path:repl])
list.path.patsubst.name.suffix [list[path]] <-- $(call list.path.patsubst.name.suffix,[list[path]:in],[path:name.suffix],[path:repl])
list.path.patsubst.basename [list[path]] <-- $(call list.path.patsubst.basename,[list[path]:in],[path:basename],[path:repl])
list.path.patsubst.suffix [list[path]] <-- $(call list.path.patsubst.suffix,[list[path]:in],[path:suffix],[path:repl])

### Path: Search

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
wildcard [list<path>] = $(wildcard list<xpath>:patterns) GNU Make
path.wildcard [list[path]] <-- $(call path.wildcard,[path:pattern])
list.path.wildcard [list[path]] <-- $(call list.path.wildcard,[list[path]:patterns])

### Path: Existence

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
path.exists [path] <-- $(call path.exists,[path])
file.exists [path] <-- $(call dir.exists,[path])
dir.exists [path] <-- $(call file.exists,[path])
list.path.exists [list[path]] <-- $(call list.path.exists,[list[path]])
list.file.exists [list[path]] <-- $(call list.dir.exists,[list[path]])
list.dir.exists [list[path]] <-- $(call list.file.exists,[list[path]])

## INTEGERS

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
int.trim {int} <-- $(call int.trim,[int])

### Integer: Arithmetic

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
digits.add {list{digit|-}} = $(call digits.add,[list{digit|-}:A],[list{digit|-}:B])
digits.sub {list{digit|-}} = $(call digits.sub,[list{digit|-}:A],[list{digit|-}:B])
int.abs {int} <-- $(call int.abs,[int])
int.neg {int} <-- $(call int.neg,[int])
int.add {int} <-- $(call int.add,[int:A],[int:B])
int.sub {int} <-- $(call int.sub,[int:A],[int:B])
int.max {int} <-- $(call int.max,[int:A],[int:B])
int.min {int} <-- $(call int.min,[int:A],[int:B])

### Integer: Comparisons

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
intcmp [str] <-- $(intcmp {int:1},{int:2},[str:if_lss],[str:if_equ],[str:if_gtr]) GNU Make 4.4+
int.equ.0 [bool:A] <-- $(call int.equ.0,[int:A])
int.neq.0 [bool:A] <-- $(call int.neq.0,[int:A])
int.gtr.0 [bool:A] <-- $(call int.gtr.0,[int:A])
int.geq.0 [bool:A] <-- $(call int.geq.0,[int:A])
int.leq.0 [bool:A] <-- $(call int.leq.0,[int:A])
int.lss.0 [bool:A] <-- $(call int.lss.0,[int:A])
int.equ [bool:A] <-- $(call int.equ,[int:A],[int:B])
int.neq [bool:A] <-- $(call int.neq,[int:A],[int:B])
int.gtr [bool:A] <-- $(call int.gtr,[int:A],[int:B])
int.geq [bool:A] <-- $(call int.geq,[int:A],[int:B])
int.leq [bool:A] <-- $(call int.leq,[int:A],[int:B])
int.lss [bool:A] <-- $(call int.lss,[int:A],[int:B])

## EXPRESSIONS, DYNAMIC PROGRAMMING

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
eval [empty] <-- $(eval [expr]) GNU Make 3.80+
value [expr] <-- $(value [var:recursive]) GNU Make
expr.expand [str] <-- $(call expr.expand,[expr[str]])

### Expressions: Embedded Literals, Variable References

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
expr.str [expr[str]] <-- $(call expr.str,[str])
expr.list [list[expr[str]]] <-- $(call expr.list,[list[str]])
expr.var [expr[str]] <-- $(call expr.var,[expr[var]:name],[expr[word]:find],[expr[str]:repl])
expr.vars [list[expr[str]]] <-- $(call expr.vars,[list[var]])

### Expressions: Built-In Functions

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
expr.builtin [expr[str]] <-- $(call expr.builtin,{expr[builtin]:name},[expr:1],[expr:2],...)
expr.call [expr[str]] <-- $(call expr.call,{expr[func]:name},[expr:1],[expr:2],...)
expr.if [expr[str]] <-- $(call expr.if,[expr:cond],[expr:ifnonempty],[expr:ifempty])
expr.or [expr[str]] <-- $(call expr.or,[expr:1],[expr:2],...)
expr.and [expr[str]] <-- $(call expr.and,[expr:1],[expr:2],...)
expr.foreach [expr[str]] <-- $(call expr.foreach,[expr[var]],[expr[list]:in],[expr[str](var)])
expr.subst [expr[str]] <-- $(call expr.subst,[expr:from],[expr:to],[expr([str:in])])
expr.strip [expr[str]] <-- $(call expr.strip,[expr([str:in])])

### Expressions: Variable Assignment

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
expr.assign [expr[empty]] <-- $(call expr.assign,[list[expr]:directives],[expr[var]:name],[expr:assign_operator],[expr:value])

### Expressions: Target Definition

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
expr.target [expr[empty]] <-- $(call expr.target,[expr[multipath]:targets],\
[expr[multipath]:prereqs],[expr[multipath]:orderonly],\
[expr[multipath]:prereqs_of],[expr[multipath]:orderonly_of],\
[list[expr]:assignments],\
[list[expr]:commands]
)
expr.target [expr[empty]] <-- $(call expr.target,$(call multipath.create,$n\
/target/multipath$n\
),$(call multipath.create,$n\
/prereq/multipath$n\
),$(call multipath.create,$n\
/orderonly/multipath$n\
),$(call multipath.create,$n\
/prereqs/of$n\
),$(call multipath.create,$n\
/orderonly/of$n\
),$(call list.create,expr,$n\
localvar := value$n\
),$(call list.create,expr,$n\
commands$n\
)\
)

## SHELL

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
shell [str] <-- $(shell [str:command]) GNU Make
shell.push [empty] <-- $(call shell.push,[path:shell],[str:flags])
shell.pop [empty] <-- $(call shell.pop)
shell.run [str:stdout] <-- $(call shell.run,[str:command],[var:exitcode],[path:shell],[str:flags])
shell.test [bool:success] <-- $(call shell.test,[str:command],[var:stdout],[path:shell],[str:flags])

## FILES

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
file (Read) [str] <-- $(file < [wpath]) GNU Make 4.2+
file (Write) [empty] <-- $(file > [wpath],[str:write]) GNU Make 4.0+
file (Append) [empty] <-- $(file >> [wpath],[str:append]) GNU Make 4.0+
file.tee [str] <-- $(call file.tee,[>>|>],[wpath],[str])

## PRINTING

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
info [empty] <-- $(info [str:message]) GNU Make
warning [empty] <-- $(warning [str:message]) GNU Make
error [empty] <-- $(error [str:message]) GNU Make

### Printing: Indentation

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
str.indent.add [str] <-- $(call str.indent.add,[str:multiline],[str:indent])
str.indent.set [str] <-- $(call str.indent.set,[str:multiline],[str:indent])

### Printing: Block Formatting

Function | Returns | Syntax | Requires
-------- | ------- | ------ | --------
str.to.block {block} <-- $(call str.to.block,[type:T],[T:str],[T:pad],[left|right])
block.to.str [str] <-- $(call block.to.str,[block])
block.hresize [block] <-- $(call block.hresize,[block],[block:width],[char:pad],[extend|resize],[end|start])
block.vresize [block] <-- $(call block.vresize,[block],[block:height],[char:pad],[extend|resize],[end|start])
block.hreshape [block] <-- $(call block.hreshape,[block],[block:width],[char:pad]
block.hstack [block] <-- $(call block.hstack,[block:1],[block:2],[char:pad])
block.vstack [block] <-- $(call block.vstack,[block:1],[block:2],[char:pad])
footer
