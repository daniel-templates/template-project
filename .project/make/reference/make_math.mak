#-----------------------------------------------------------
# num := $(call int.inc,{integer})
# num := $(call int.dec,{integer})
#-----------------------------------------------------------
# Increments or decrements a (postive or negative) integer by 1.

#-----------------------------------------------------------
# 1. int.inc:
#-----------------------------------------------------------
#   val   sign op
# >  1       .inc.recurse(abs(val))
#    1       .inc.recurse(abs(val))
#    0       .inc.recurse(abs(val))
#   -1       .dec.recurse(abs(val))
# < -1     - .dec.recurse(abs(val))
# empty      *
#
# sign = $(if $(filter -%,$(1:-1=)),-)
#   op = $(if $(1:-%=),inc,dec).recurse

int.inc = $(if $(filter -%,$(1:-1=)),-)$(subst .,,$(call int.$(if $(1:-%=),inc,dec).recurse,$(call str.digits.addprefix,.,$(1:-%=%))))



#-----------------------------------------------------------
# 1. int.dec:
#-----------------------------------------------------------
#   val   sign op
# >  1       .dec.recurse(abs(val))
#    1       .dec.recurse(abs(val))
#    0     - .inc.recurse(abs(val))
#   -1     - .inc.recurse(abs(val))
# < -1     - .inc.recurse(abs(val))
# empty      *
#
# sign = $(if $(filter 0 -%,$(1)),-)
#   op = $(if $(filter 0 -%,$(1)),inc,dec).recurse

int.dec = $(if $(filter 0 -%,$(1)),-)$(subst .,,$(call int.$(if $(filter 0 -%,$(1)),inc,dec).recurse,$(call str.digits.addprefix,.,$(1:-%=%))))


#-----------------------------------------------------------
# 2. Prefix each digit with ".":
#      int = $(call str.digits.addprefix,.,$(int))
# 3. Split int into two parts: [first][last]
#       first              = $(basename $(1))
#       last               = $(suffix $(1))
#       first == EMPTY     = $(if $(basename $(1)),,true)
#       first != EMPTY     = $(basename $(1))
#       last == EMPTY      = $(if $(1),,true)
#       last != EMPTY      = $(1)
#       last == 9          = $(filter %9,$(1))
#       last != 9          = $(if $(filter %9,$(1)),,true)
#       last < 9           = $(1:%9=)
#       last !< 9          = $(if $(1:%9=),,true)
#       last == 0          = $(filter %0,$(1))
#       last != 0          = $(if $(filter %0,$(1)),,true)
#       last > 0           = $(1:%0=)
#       last !> 0          = $(if $(1:%0=),,true)
#
#-----------------------------------------------------------
# 4. int.inc.recurse:
#-----------------------------------------------------------
#   F1L1: first == EMPTY && last == EMPTY     = (empty)(empty)
#   F1L2: first == EMPTY && last < 9          = (empty)(last++)
#   F1L3: first == EMPTY && last == 9         = (.1)(.0)
#   F2L1: first != EMPTY && last == EMPTY     = (empty)(empty)
#   F2L2: first != EMPTY && last < 9          = (first)(last++)
#   F2L3: first != EMPTY && last == 9         = (first++)(.0)
#
# $(if first != EMPTY,
#   $(if last < 9,       (first)(last++),     (F2L2)
#   $(if last != EMPTY,  (first++)(.0),       (F2L3)
#                        (empty)(empty)       (F2L1)
#   )),
#   $(if last < 9,       (empty)(last++),     (F1L2)
#   $(if last != EMPTY,  (.1)(.0),            (F1L3)
#                        (empty)(empty)       (F1L1)
#   ))
# )
#-----------------------------------------------------------

int.inc.recurse = $(if $(basename $(1)),$(if $(1:%9=),$(basename $(1))$(call digit.inc,$(suffix $(1)),.),$(if $(1),$(call int.inc.recurse,$(basename $(1))).0)),$(if $(1:%9=),$(call digit.inc,$(suffix $(1)),.),$(if $(1),.1.0)))



#-----------------------------------------------------------
# 4. int.dec.recurse:
#-----------------------------------------------------------
#   F1L1: first == EMPTY && last == EMPTY     = (empty)(empty)
#   F1L2: first == EMPTY && last > 0          = (empty)(last--)
#   F1L3: first == EMPTY && last == 0         = (empty)(empty)
#   F2L1: first != EMPTY && last == EMPTY     = (empty)(empty)
#   F2L2: first != EMPTY && last > 0          = (first)(last--)
#   F2L3: first != EMPTY && last == 0         = (filter-out .0,(first--))(.9)
#
# $(if first != EMPTY,
#   $(if last > 0,       (first)(last--),     (F2L2)
#   $(if last != EMPTY,  (filter-out .0,(first--))(.9),       (F2L3)
#                        (empty)(empty)       (F2L1)
#   )),
#   $(if last > 0,       (empty)(last--),     (F1L2)
#   $(if last != EMPTY,  (empty)(empty),      (F1L3)
#                        (empty)(empty)       (F1L1)
#   ))
# )
#-----------------------------------------------------------

int.dec.recurse = $(if $(basename $(1)),$(if $(1:%0=),$(basename $(1))$(call digit.dec,$(suffix $(1)),.),$(if $(1),$(filter-out .0,$(call int.dec.recurse,$(basename $(1)))).9)),$(if $(1:%0=),$(call digit.dec,$(suffix $(1)),.)))



#-----------------------------------------------------------
# digit := $(call digit.inc,{digit},[prefix])
# digit := $(call digit.dec,{digit},[prefix])
#-----------------------------------------------------------
# Increments or decrements {digit} by 1.
# inc/dec over max/min wraps to min/max.
# digit=$(EMPTY) implies digit=0.
#
#   $(call digit.inc,$(EMPTY))    --> 1
#   $(call digit.inc,9)           --> 0
#   $(call digit.dec,$(EMPTY))    --> 9
#   $(call digit.dec,0)           --> 9
#-----------------------------------------------------------

digit.inc  = $(addprefix $(2),$(word 1$(1:$(2)%=%),1 x x x x x x x x 1 2 3 4 5 6 7 8 9 0))
digit.dec  = $(addprefix $(2),$(word 1$(1:$(2)%=%),9 x x x x x x x x 9 0 1 2 3 4 5 6 7 8))



#-----------------------------------------------------------
# str = $(call str.digits.addprefix,{prefix},{str})
# str = $(call str.digits.addsuffix,{suffix},{str})
#-----------------------------------------------------------
# Prefixes or suffixes each numeric character (0-9) in {str}.
# $(EMPTY) -> $(EMPTY)
# Ex:
#   $(call str.digits.addprefix,.,1234) --> .1.2.3.4
#-----------------------------------------------------------
str.digits.addprefix = $(subst 9,$(1)9,$(subst 8,$(1)8,$(subst 7,$(1)7,$(subst 6,$(1)6,$(subst 5,$(1)5,$(subst 4,$(1)4,$(subst 3,$(1)3,$(subst 2,$(1)2,$(subst 1,$(1)1,$(subst 0,$(1)0,$(2)))))))))))
str.digits.addsuffix = $(subst 9,9$(1),$(subst 8,8$(1),$(subst 7,7$(1),$(subst 6,6$(1),$(subst 5,5$(1),$(subst 4,4$(1),$(subst 3,3$(1),$(subst 2,2$(1),$(subst 1,1$(1),$(subst 0,0$(1),$(2)))))))))))



#-----------------------------------------------------------
# equ.0 = $(call int.equ.0,{int})
# neq.0 = $(call int.neq.0,{int})
# gtr.0 = $(call int.gtr.0,{int})
# geq.0 = $(call int.geq.0,{int})
# leq.0 = $(call int.leq.0,{int})
# lss.0 = $(call int.lss.0,{int})
#-----------------------------------------------------------
# Compares {int} to 0. Returns nonempty if truel
#                              empty if false or {int} is empty.
#-----------------------------------------------------------

int.equ.0 = $(filter 0,$(1))
#int.equ.0 = $(if $(1:0=),,true)
int.neq.0 = $(1:0=)
int.gtr.0 = $(filter-out 0 -%,$(1))
#int.gtr.0 = $(and $(1:0=),$(1:-%=))
int.geq.0 = $(1:-%=)
int.leq.0 = $(filter 0 -%,$(1))
int.lss.0 = $(filter -%,$(1))
#int.lss.0 = $(if $(1:-%=),,true)



#-----------------------------------------------------------
#   num = $(call int.abs,{int})
#   num = $(call int.neg,{int})
#-----------------------------------------------------------
# int.abs:  Returns absolute value of {int};
#                   empty if {int} is empty.
# int.neg:  Returns negation of {int};
#                   empty if {int} is empty.
#-----------------------------------------------------------
int.abs = $(1:-%=%)
int.neg = $(if $(1:-%=),$(if $(1:0=),-$(1),$(1)),$(1:-%=%))




val := 0
val.inc := $(call int.inc,$(val))
val.dec := $(call int.dec,$(val))
val.equ.0 := $(if $(call int.equ.0,$(val)),true,false)
val.neq.0 := $(if $(call int.neq.0,$(val)),true,false)
val.gtr.0 := $(if $(call int.gtr.0,$(val)),true,false)
val.geq.0 := $(if $(call int.geq.0,$(val)),true,false)
val.leq.0 := $(if $(call int.leq.0,$(val)),true,false)
val.lss.0 := $(if $(call int.lss.0,$(val)),true,false)
val.abs := $(call int.abs,$(val))
val.neg := $(call int.neg,$(val))
sval := $(call str.digits.addprefix,.,$(val))
first := $(basename $(sval))
first.inc := $(call int.inc.recurse,$(first))
first.dec := $(call int.dec.recurse,$(first))
last := $(suffix $(sval))
last.inc := $(call digit.inc,$(last),.)
last.dec := $(call digit.dec,$(last),.)
first.equ.EMPTY := $(if $(if $(basename $(sval)),,true),true,false)
first.neq.EMPTY := $(if $(basename $(sval)),true,false)
last.equ.EMPTY := $(if $(if $(sval),,true),true,false)
last.neq.EMPTY := $(if $(sval),true,false)
last.equ.9 := $(if $(filter %9,$(sval)),true,false)
last.neq.9 := $(if $(if $(sval),$(sval:%9=),true),true,false)
last.lss.9 := $(if $(sval:%9=),true,false)
last.nls.9 := $(if $(if $(sval:%9=),,true),true,false)
last.equ.0 := $(if $(filter %0,$(sval)),true,false)
last.neq.0 := $(if $(if $(sval),$(sval:%0=),true),true,false)
last.lss.0 := $(if $(sval:%0=),true,false)
last.nls.0 := $(if $(if $(sval:%0=),,true),true,false)
last.inc.clear := $(call digit.inc.clear,$(last),.)
last.dec.clear := $(call digit.dec.clear,$(last),.)
sval.inc := $(call int.inc.recurse,$(sval))
sval.dec := $(call int.dec.recurse,$(sval))


$(info )
$(call print.var,val val.inc val.dec val.equ.0 val.neq.0 val.gtr.0 val.geq.0 val.leq.0 val.lss.0 val.abs val.neg sval first first.inc first.dec last last.inc last.dec first.equ.EMPTY first.neq.EMPTY last.equ.EMPTY last.neq.EMPTY last.equ.9 last.neq.9 last.lss.9 last.nls.9 last.equ.0 last.neq.0 last.lss.0 last.nls.0 sval.inc sval.dec)
$(info )
$(error Exiting...)
