#===============================================================================
# init.mak
#
# Initializes this project's development environment.
#
# Usage:
#   From project root directory, run "make init".
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
# init
#-----------------------------------------------------------

# Global Variables
init.prereqs.normal ?=
init.prereqs.orderonly ?= help.init
init.prereqs = $(init.prereqs.normal) $(init.prereqs.orderonly)

# Help Text
$(eval $(call target.set_helptext,init,\
  Initializes the project's development environment.,\
  Available sub-tasks are listed in "Related Targets" below.$(LF)\
  $(LF)\
  Projects can extend the behavior of this (or related) targets$(LF)\
  through two methods:$(LF)\
  $(LF)\
  1: Define new targets and append them as prereqs;$(LF)\
  $(INDENT) In config.mak$(COMMA) add the lines:$(LF)\
  $(LF)\
  $(INDENT)$(INDENT) $$@.prereqs.normal = TARGETS$(LF)\
  $(INDENT)$(INDENT) $$@.prereqs.orderonly = TARGETS$(LF)\
  $(LF)\
  2: Leverage existing targets by overriding their variables.$(LF)\
  $(INDENT) See Related Targets below.$(LF)\
  ,\
  $$@.prereqs.normal\
  $$@.prereqs.orderonly\
))

# Pretarget; runs exactly once before any number of prereqs
$(eval $(call target.add_pretarget,init,$(init.prereqs),\
	$$(call print.trace,make $$(basename $$@))$$(LF)\
))

# Target Definition
.PHONY: init
init: $(init.prereqs.normal) | $(init.prereqs.orderonly)



#-----------------------------------------------------------
# init.dirs
#-----------------------------------------------------------

# Global Variables
init.dirs.prereqs.normal ?=
init.dirs.prereqs.orderonly ?= $(init.dirs.paths)
init.dirs.prereqs = $(init.dirs.prereqs.normal) $(init.dirs.prereqs.orderonly)

init.dirs.paths ?=

# Help Text
$(eval $(call target.set_helptext,init.dirs,\
$(EMPTY),\
  Creates each directory listed in $(DOLLAR)$(OPAREN)init.dirs.paths$(CPAREN).$(LF)\
  ,\
  init.dirs.prereqs.normal\
  init.dirs.prereqs.orderonly\
  init.dirs.paths\
))

# Pretarget
$(eval $(call target.add_pretarget,init.dirs,$(init.dirs.prereqs),\
	$$(call print.trace,make $$(basename $$@))$$(LF)\
))

# Target Definition
.PHONY: init.dirs
init.dirs: $(init.dirs.prereqs.normal) | $(init.dirs.prereqs.orderonly)

# Create a file target for each path in CREATE_DIRS
$(init.dirs.paths):
	$(call mkdir,$@)



#===============================================================================
# UPSTREAM: CURRENT PROJECT
#===============================================================================


