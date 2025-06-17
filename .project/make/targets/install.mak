#===============================================================================
# install.mak
#
# Install build artifacts to the local system.
#
# Usage:
#   From project root directory, run "make install".
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
# install
#-----------------------------------------------------------

# Help Text
$(eval $(call set_helptext,install, \
  Install build artifacts to the local system,\
  This is a standard top-level target.$(LF)\
  Projects can change the behavior of this target through$(LF)\
  two methods:$(LF)\
  $(LF)\
  1: define new targets and append them as prereqs$(LF)\
  _    (see all.mak for details)$(LF)\
  2: leverage existing prereqs by overwriting their variables$(LF)\
  _    (see Related Targets below)$(LF)\
  ,\
$(EMPTY)\
))

# Definition
.PHONY: install
install:
	$(PRINT_TRACE)



#===============================================================================
# UPSTREAM: CURRENT PROJECT
#===============================================================================


