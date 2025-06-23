#===============================================================================
# help.mak
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
#		$(call help.targets.define,target,\
#			Short Description
#			,\
#			Optional extended$(LF)\
#			multiline description text$(LF)\
#			,\
#			list of related variables
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
# $(call help.targets.define,target,\
# 	Short description text,\
# 	Optional extended$(LF)\
# 	multiline description text$(LF)\
# 	,\
# 	list of related variables
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
#
# Other variables can be referenced as well, but also they must be $$(escaped).
#-----------------------------------------------------------

help.targets.define = $(eval $(subst $(LF)$(SPACE),$(LF),$(LF)\
	help.targets += help.$(strip $(1))$(LF)\
	$(subst $$@,$(strip $(1)),$(LF)\
		help.$(strip $(1)).shortdesc := $(strip $(2))$(LF)\
		help.$(strip $(1)).longdesc := $(strip $(subst $$(LF)$(SPACE),$$(LF),$(subst $(LF),$$(LF),$(3))))$(LF)\
		help.$(strip $(1)).variables := $(strip $(4))$(LF)\
	)$(LF)\
))




#-----------------------------------------------------------
# TARGET: help
#-----------------------------------------------------------

# Global Variables
help.colwidth := ........................
help.targets ?=

# Help Text (make help.help)
$(call help.targets.define,help,\
	Prints the top-level Make targets available in this project,\
	Targets can define help text using the "help.targets.define" macro.$(LF)\
	See "lib.help.mak" for more information.$(LF)\
	,\
	help.targets\
)

# Target Definition
.PHONY: help
help:
	@$(call nop)
	$(info )
	$(info Usage:)
	$(info $(INDENT)make [target] [variable=value])
	$(info )
	$(info Targets:)
	$(foreach tgt,$(sort $(help.targets)),$(if $($(tgt).shortdesc),\
	  $(info $(INDENT)$(call str.rpad,$(patsubst help.%,%,$(tgt)),$(help.colwidth)) $($(tgt).shortdesc))\
	))
	$(info )



#-----------------------------------------------------------
# TARGET: help.[target]
#-----------------------------------------------------------

# Global Variables
expand ?= false

# Help Text (make help.[target])
$(call help.targets.define,help.[target],\
	Prints detailed info about [target],\
	Targets can define help text using the "help.targets.define" macro.$(LF)\
	See "lib.help.mak" for more information.$(LF)\
	,\
	help.targets\
	expand\
)

# Target Definition
.PHONY: help.%
help.%:
	@$(call shell.nop)
	$(if $(filter $@,$(help.targets)),\
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
	    $(info $(INDENT)$(subst $(LF),$(LF)$(INDENT),$($@.longdesc)))\
	  )\
	  $(if $($@.variables),\
	    $(info )\
	    $(if $(findstring true,$(expand)),\
	      $(info $(call str.rpad,Variables:,....................) Values expanded recursively.)\
	      $(info )\
	      $(foreach varn,$(sort $($@.variables)),\
	        $(info $(INDENT)$(varn)=[$($(varn))])\
	      ),\
	      $(info $(call str.rpad,Variables:,....................) Expand values by rerunning with "expand=true".)\
	      $(info )\
	      $(foreach varn,$(sort $($@.variables)),\
	        $(info $(INDENT)$(varn)=[$(value $(varn))])\
	      )\
		)\
	  )\
	  $(if $(strip $(foreach tgt,$(filter-out $@,$(help.targets)),$(if $(findstring $(patsubst help.%,%,$@),$(tgt)),$(tgt)))),\
	    $(info )\
	    $(info $(call str.rpad,Related Targets:,....................) For more info$(COMMA) run "make help.[target]".)\
	    $(info )\
	    $(foreach tgt,$(sort $(filter-out $@,$(help.targets))),\
	      $(if $(findstring $(patsubst help.%,%,$@),$(tgt)),\
	        $(info $(INDENT)$(call str.rpad,$(patsubst help.%,%,$(tgt)),$(help.colwidth)) $($(tgt).shortdesc))\
	      )\
	    )\
	  )\
	  $(info )\
	,\
	  $(info )\
	  $(info No information available for target "$(patsubst help.%,%,$@)".)\
	  $(info )\
	)

