#===============================================================================
# all.mak
#
# Build all artifacts.
#
# Usage:
#   From project root directory, run "make all".
#
# Defining New Targets:
#  1. Copy the TARGET definition template to the appropriate section of this file.
#  2. Uncomment (remove leading whitespace) and edit as necessary.
#
# Appending Prerequisites:
#   Target definitions take the form:
#
#     target: prereq | prereq_orderonly
#
#   The target runs if any of its "normal" prereqs are newer.
#   The target ignores the timestamps of its "orderonly" prereqs;
#     they run if they need to, but won't force the target to update as well.
#   Targets should be .PHONY if they do not produce an actual file on the system.
#
#===============================================================================


#-----------------------------------------------------------
# TARGET
#-----------------------------------------------------------
#
# Append To Prerequisites Of
#
#   OTHER: TARGET            (if TARGET is file and timestamp should be checked)
#   OTHER: | TARGET          (if TARGET is phony or timestamp should be ignored)
#
# Global Variables       Defined for all targets
#
#   VAR ?= value
#
# Local Variables        Defined only during this TARGET and its prereqs
#
#   TARGET: VAR ?= value
#
# Help Text              Info printed with "make help" or "make help.TARGET"
#
#   $(eval $(call set_helptext,TARGET,ShortDesc,LongDesc,VarList))
#
# Definition
#
#   .PHONY: TARGET           (if TARGET is not an actual file on the system)
#   TARGET: PREREQS (file prereqs) | PREREQS_ORDERONLY (phony or ignore timestamps)
#   	COMMANDS TO MAKE TARGET
#



#===============================================================================
# UPSTREAM: daniel-templates/template-project
#===============================================================================



#-----------------------------------------------------------
# all
#-----------------------------------------------------------

# Help Text
$(eval $(call set_helptext,all, \
  Build all artifacts,\
  Projects can extend the behavior of this (or related) targets$(LF)\
  through two methods:$(LF)\
  $(LF)\
  1: define new targets and append them as prereqs$(LF)\
  _    (see all.mak for details)$(LF)\
  2: leverage existing targets by overriding their variables$(LF)\
  _    (see Related Targets below)$(LF)\
  ,\
$(EMPTY)\
))

# Definition
.PHONY: all
all:
	$(PRINT_TRACE)



#===============================================================================
# UPSTREAM: CURRENT PROJECT
#===============================================================================


