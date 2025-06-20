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
# Global Variables
#   Defined for all targets
#
# TARGET.prereqs.normal ?=    (List of file prereq targets, space-separated)
# TARGET.prereqs.orderonly ?= (List of phony prereqs, or prereq files whos timestamps should be ignored)
# TARGET.prereqs = $(TARGET.prereqs.normal) $(TARGET.prereqs.orderonly)
#
# globalvar ?= value
#
# Local Variables
#   Defined only while making this TARGET and its prereqs
#
# TARGET: localvar ?= value
#
# Help Text
#   Info printed with "make help" or "make help.TARGET"
#
# $(eval $(call target.set_helptext,TARGET,\
#   Short Description,\
#   Long Multiline$(LF)\
#   description$(LF)\
#   ,\
#   $$@.prereqs.normal\
#   $$@.prereqs.orderonly\
#   OTHER CONSUMED VARIABLES\
# ))
#
# Pretarget
#   Runs exactly once before any number of prereqs
#
# $(eval $(call target.add_pretarget,TARGET,$(TARGET.prereqs),\
# 	$$(call print.trace,make $$(basename $$@))$$(LF)\
# 	[COMMANDS]$$(LF)\
# ))
#
# Target Definition
#
# .PHONY: TARGET              (if TARGET is not an actual file on the system)
# .ONESHELL: TARGET           (if TARGET should run all command lines in a single shell process)
# TARGET: $(TARGET.prereqs.normal) | $(TARGET.prereqs.orderonly)
# 	COMMANDS TO MAKE TARGET
#



#===============================================================================
# UPSTREAM: daniel-templates/template-project
#===============================================================================



#-----------------------------------------------------------
# help
#-----------------------------------------------------------

# Global Variables
HELP_TARGET_COL_WIDTH := ........................

# Help Text
$(eval $(call target.set_helptext,help,\
  Prints the top-level Make targets available in this project,\
  Targets can define help text using the "target.set_helptext" macro.$(LF)\
  See "functions.mak" for more information.$(LF)\
  ,\
  HELP_TARGET_COL_WIDTH\
  help_targets\
))

# Target Definition
.PHONY: help
help:
	@$(call nop)
	$(info )
	$(info Usage:)
	$(info $(INDENT)make [target] [variable=value])
	$(info )
	$(info Targets:)
	$(foreach tgt,$(sort $(help_targets)),$(if $($(tgt).shortdesc),\
	  $(info $(INDENT)$(call rpad,$(patsubst help.%,%,$(tgt)),$(HELP_TARGET_COL_WIDTH)) $($(tgt).shortdesc))\
	))
	$(info )



#-----------------------------------------------------------
# help.[target]
#-----------------------------------------------------------

# Local Variables
help.%: expand ?= false

# Help Text
$(eval $(call target.set_helptext,help.[target],\
  Prints detailed info about a specific target,\
  Targets can define help text using the "target.set_helptext" macro.$(LF)\
  See "functions.mak" for more information.$(LF)\
  ,\
  expand\
))

# Target Definition
.PHONY: help.%
help.%:
	@$(call nop)
	$(if $(filter $@,$(help_targets)),\
	  $(info )\
	  $(info Usage:)\
	  $(info )\
	  $(info $(INDENT)make $(patsubst help.%,%,$@) [variable=value])\
	  $(if $($@.shortdesc),\
	    $(info )\
	    $(info $(INDENT)$($@.shortdesc))\
	  )\
	  $(if $($@.longdesc),\
	    $(info )\
	    $(info $(SPACE)$(subst $(LF)$(SPACE),$(LF)$(INDENT),$($@.longdesc)))\
	  )\
	  $(if $($@.variables),\
	    $(info )\
	    $(if $(findstring true,$(expand)),\
	      $(info $(call rpad,Variables:,....................) Values expanded recursively.)\
	      $(info )\
	      $(foreach varn,$(sort $($@.variables)),\
	        $(info $(INDENT)$(varn)=[$($(varn))])\
	      ),\
	      $(info $(call rpad,Variables:,....................) Expand values by rerunning with "expand=true".)\
	      $(info )\
	      $(foreach varn,$(sort $($@.variables)),\
	        $(info $(INDENT)$(varn)=[$(value $(varn))])\
	      )\
		)\
	  )\
	  $(if $(strip $(foreach tgt,$(filter-out $@,$(help_targets)),$(if $(findstring $(patsubst help.%,%,$@),$(tgt)),$(tgt)))),\
	    $(info )\
	    $(info $(call rpad,Related Targets:,....................) For more info$(COMMA) run "make help.[target]".)\
	    $(info )\
	    $(foreach tgt,$(sort $(filter-out $@,$(help_targets))),\
	      $(if $(findstring $(patsubst help.%,%,$@),$(tgt)),\
	        $(info $(INDENT)$(call rpad,$(patsubst help.%,%,$(tgt)),$(HELP_TARGET_COL_WIDTH)) $($(tgt).shortdesc))\
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


