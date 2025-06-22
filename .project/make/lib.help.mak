#===============================================================================
# lib.help.mak
#===============================================================================
#
# Functions for dynamically adding help text to make targets.
#
# Usage:
#
#	Include in makefile:
#
#		include path/to/lib.mak
#		include path/to/lib.help.mak
#
#	Define help text for a target:
#
#		$(call lib.help.targets.define,target,\
#		  Short description text,\
#		  Optional extended$(LF)\
#		  multiline description text$(LF)\
#		  ,\
#		  list of related variables
#		)
#
#	View help text:
#
#		make help
#		make help.target
#
#===============================================================================
$(if $(filter-out $(notdir $(MAKEFILE_LIST)), lib.mak ),$(error Makefile $(lastword $(notdir $(MAKEFILE_LIST))) is missing dependencies))
#===============================================================================


#-----------------------------------------------------------
# $(call lib.help.targets.define,target,\
#   Short description text,\
#   Optional extended$(LF)\
#   multiline description text$(LF)\
#   ,\
#   list of related variables
# )
#-----------------------------------------------------------
# Stores usage info and help text for the given target.
# If a short description is provided, "make help" will print it.
# If a long description is provided, "make help.{target}" will print it.
# If a list of variable names are provided, variables and their values
#   will be printed below the long description.
#
# In any argument except 1, the literal string $@ is substituted
#   with the name of the target $(1).
# Since literal '$' must be escaped, must type "$$@".
#-----------------------------------------------------------

define lib.help.targets.define
lib.help.targets += help.$(strip $(1))
help.$(strip $(1)).shortdesc := $(subst $$@,$(strip $(1)),$(strip $(2)))
define help.$(strip $(1)).longdesc
$(subst $$@,$(strip $(1)),$(3))
endef
help.$(strip $(1)).variables := $(subst $$@,$(strip $(1)),$(strip $(4)))
endef


#-----------------------------------------------------------
# TARGET: help
#-----------------------------------------------------------

# Global Variables
lib.help.colwidth := ........................
lib.help.targets ?=

# Help Text (make help.help)
$(eval $(call lib.help.targets.define,help,\
  Prints the top-level Make targets available in this project,\
  Targets can define help text using the "lib.help.targets.define" macro.$(LF)\
  See "functions.mak" for more information.$(LF)\
  ,\
  lib.help.targets\
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
	$(foreach tgt,$(sort $(lib.help.targets)),$(if $($(tgt).shortdesc),\
	  $(info $(INDENT)$(call rpad,$(patsubst help.%,%,$(tgt)),$(lib.help.colwidth)) $($(tgt).shortdesc))\
	))
	$(info )



#-----------------------------------------------------------
# TARGET: help.[target]
#-----------------------------------------------------------

# Global Variables
expand ?= false

# Target Definition
.PHONY: help.%
help.%:
	@$(call shell.nop)
	$(if $(filter $@,$(lib.help.targets)),\
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
	  $(if $(strip $(foreach tgt,$(filter-out $@,$(lib.help.targets)),$(if $(findstring $(patsubst help.%,%,$@),$(tgt)),$(tgt)))),\
	    $(info )\
	    $(info $(call rpad,Related Targets:,....................) For more info$(COMMA) run "make help.[target]".)\
	    $(info )\
	    $(foreach tgt,$(sort $(filter-out $@,$(lib.help.targets))),\
	      $(if $(findstring $(patsubst help.%,%,$@),$(tgt)),\
	        $(info $(INDENT)$(call rpad,$(patsubst help.%,%,$(tgt)),$(lib.help.colwidth)) $($(tgt).shortdesc))\
	      )\
	    )\
	  )\
	  $(info )\
	,\
	  $(info )\
	  $(info No information available for target "$(patsubst help.%,%,$@)".)\
	  $(info )\
	)

