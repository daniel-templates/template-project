#===============================================================================
# help.mak
#
# Prints information about the available Make commands for this project.
#
# Usage:
#   From project root directory, run "make help" or "make help.TARGET".
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
# help
#-----------------------------------------------------------

# Global Variables
HELP_INDENT := $(SPACE)$(SPACE)
HELP_TARGET_COL_WIDTH := ........................
HELP_VARN_COL_WIDTH := ........................

# Help Text
$(eval $(call set_helptext,help,\
  Prints the top-level Make targets available in this project,\
  Targets can define help text using the "set_helptext" macro.$(LF)\
  See "functions.mak" for more information.$(LF)\
  ,\
  HELP_INDENT\
  HELP_TARGET_COL_WIDTH\
  HELP_VARN_COL_WIDTH\
))

# Definition
.PHONY: help
help:
	@$(call nop)
	$(info )
	$(info Usage:)
	$(info $(HELP_INDENT)make [target] [variable=value])
	$(info )
	$(info Targets:)
	$(foreach tgt,$(sort $(help_targets)),$(if $($(tgt).shortdesc),\
	  $(info $(HELP_INDENT)$(call rpad,$(patsubst help.%,%,$(tgt)),$(HELP_TARGET_COL_WIDTH)) $($(tgt).shortdesc))\
	))
	$(info )



#-----------------------------------------------------------
# help.[target]
#-----------------------------------------------------------

# Help Text
$(eval $(call set_helptext,help.[target],\
  Prints detailed info about a specific target,\
  Targets can define help text using the "set_helptext" macro.$(LF)\
  See "functions.mak" for more information.$(LF)\
  ,\
$(EMPTY)\
))

# Definition
.PHONY: help.%
help.%:
	@$(call nop)
	$(if $(filter $@,$(help_targets)),\
	  $(info )\
	  $(info Usage:)\
	  $(info $(HELP_INDENT)make $(patsubst help.%,%,$@) [variable=value])\
	  $(if $($@.shortdesc),\
	    $(info )\
	    $(info $(HELP_INDENT)$($@.shortdesc))\
	  )\
	  $(if $($@.longdesc),\
	    $(info )\
	    $(info $(HELP_INDENT)$(subst $(LF),$(LF)$(HELP_INDENT),$($@.longdesc)))\
	  )\
	  $(if $($@.variables),\
	    $(info )\
	    $(info $(call rpad,Variable:,$(HELP_VARN_COL_WIDTH))Value:)\
	    $(foreach varn,$(sort $($@.variables)),\
	      $(info $(HELP_INDENT)$(call rpad,$(varn),$(HELP_VARN_COL_WIDTH))$($(varn)))\
	    )\
	  )\
	  $(if $(strip $(foreach tgt,$(filter-out $@,$(help_targets)),$(if $(findstring $(patsubst help.%,%,$@),$(tgt)),$(tgt)))),\
	    $(info )\
	    $(info $(call rpad,Related Targets:,$(HELP_TARGET_COL_WIDTH))For more info, run "make help.[target]")\
	    $(foreach tgt,$(sort $(filter-out $@,$(help_targets))),\
	      $(if $(findstring $(patsubst help.%,%,$@),$(tgt)),\
	        $(info $(HELP_INDENT)$(call rpad,$(patsubst help.%,%,$(tgt)),$(HELP_TARGET_COL_WIDTH)) $($(tgt).shortdesc))\
	      )\
	    )\
	  )\
	  $(info )\
	,\
	  $(info )\
	  $(info No information available for target "$(patsubst help.%,%,$@)".)\
	  $(info )\
	)



#===============================================================================
# UPSTREAM: CURRENT PROJECT
#===============================================================================


