#===============================================================================
# git.mak
#
# Quick access to common Git operations.
#
# Usage:
#   From project root directory, run "make git".
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
# git
#-----------------------------------------------------------

# Global Variables
git.prereqs.normal ?=
git.prereqs.orderonly ?= help.git
git.prereqs = $(git.prereqs.normal) $(git.prereqs.orderonly)

# Help Text
$(eval $(call target.set_helptext,git,\
  Common Git operations.,\
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
$(eval $(call target.add_pretarget,git,$(git.prereqs),\
	$$(call print.trace,make $$(basename $$@))$$(LF)\
))

# Target Definition
.PHONY: git
git: $(git.prereqs.normal) | $(git.prereqs.orderonly)



#-----------------------------------------------------------
# git.gitconfig
#-----------------------------------------------------------

# Global Variables
git.gitconfig.prereqs.normal ?=
git.gitconfig.prereqs.orderonly ?=
git.gitconfig.prereqs = $(git.gitconfig.prereqs.normal) $(git.gitconfig.prereqs.orderonly)

git.gitconfig.file ?= .project/git/.gitconfig
git.gitconfig.hooksdir ?= .project/git/hooks


# Help Text
$(eval $(call target.set_helptext,git.gitconfig,\
$(EMPTY),\
  Sets Git property "include.path" to ../$$$$($$@.file).$(LF)\
  Also sets executable bit on files in $$$$($$@.hooksdir).$(LF)\
  ,\
  $$@.prereqs.normal\
  $$@.prereqs.orderonly\
  $$@.file\
  $$@.hooksdir\
))

# Target Definition
.PHONY: git.gitconfig
git.gitconfig: $(git.gitconfig.prereqs.normal) | $(git.gitconfig.prereqs.orderonly)
	$(call print.trace)
	git config --local include.path ../$($@.file)
	$(call shell.chmod,--recursive,u+x,$($@.hooksdir))



#-----------------------------------------------------------
# git.gitignore
#-----------------------------------------------------------

# Global Variables
git.gitignore.prereqs.normal ?=
git.gitignore.prereqs.orderonly ?= git.require.no-uncommitted-changes
git.gitignore.prereqs = $(git.gitignore.prereqs.normal) $(git.gitignore.prereqs.orderonly)

commitmsg ?=
git.gitignore.commitmsg ?= $(if $(commitmsg),$(commitmsg),Updated file tracking according to .gitignore)

# Help Text
$(eval $(call target.set_helptext,git.gitignore,\
$(EMPTY),\
  Untrack files identified in the repo's .gitignore.$(LF)\
  $(LF)\
  Modifies Git repo only. Local working tree is unaffected.$(LF)\
  $(LF)\
  If a file has already been committed to the repo$(COMMA) and$(LF)\
  is later added to .gitignore$(COMMA) the file remains in the$(LF)\
  repo until it is explicitly removed from tracking.$(LF)\
  $(LF)\
  This process is equivalent to running:$(LF)\
  $(LF)\
  $(INDENT.COMMAND) git rm -rf --cached --quiet .$(LF)\
  $(INDENT.COMMAND) git add --all$(LF)\
  $(INDENT.COMMAND) git commit -m "$$$$($$@.commitmsg)"$(LF)\
  ,\
  $$@.prereqs.normal\
  $$@.prereqs.orderonly\
  $$@.commitmsg\
  commitmsg\
))

# Target Definition
.PHONY: git.gitignore
git.gitignore: $(git.gitignore.prereqs.normal) | $(git.gitignore.prereqs.orderonly)
	$(call print.trace)
	git rm -rf --cached --quiet .
	git add --all
	-git commit -m "$($@.commitmsg)"



#-----------------------------------------------------------
# git.gitattributes
#-----------------------------------------------------------

# Global Variables
git.gitattributes.prereqs.normal ?=
git.gitattributes.prereqs.orderonly ?= git.require.no-uncommitted-changes
git.gitattributes.prereqs = $(git.gitattributes.prereqs.normal) $(git.gitattributes.prereqs.orderonly)

commitmsg ?=
git.gitattributes.commitmsg ?= $(if $(commitmsg),$(commitmsg),Reencoded files according to .gitattributes)

# Help Text
$(eval $(call target.set_helptext,git.gitattributes,\
$(EMPTY),\
  Reencode files according to the repo's .gitattributes.$(LF)\
  $(LF)\
  Modifies local files AND Git repo.$(LF)\
  $(LF)\
  When .gitattributes is changed$(COMMA) some files may not have$(LF)\
  the correct encoding or line ending format anymore.$(LF)\
  This renormalizes and commits changes to all files in the repo$(COMMA)$(LF)\
  then hard-resets to that commit so these changes are reflected$(LF)\
  in the working-tree as well.$(LF)\
  $(LF)\
  This process is equivalent to running:$(LF)\
  $(LF)\
  $(INDENT.COMMAND) git add --renormalize .$(LF)\
  $(INDENT.COMMAND) git commit -m "$$$$($$@.commitmsg)"$(LF)\
  $(INDENT.COMMAND) git rm -rf --cached --quiet .$(LF)\
  $(INDENT.COMMAND) git reset --hard$(LF)\
  $(LF)\
  Be sure these changes are also reflected in .vscode/settings.all.json$(LF)\
  $(LF)\
  WARNING: This process is not perfect! Some files may not be reencoded.$(LF)\
  ,\
  $$@.prereqs.normal\
  $$@.prereqs.orderonly\
  $$@.commitmsg\
  commitmsg\
))

# Target Definition
.PHONY: git.gitattributes
git.gitattributes: $(git.gitattributes.prereqs.normal) | $(git.gitattributes.prereqs.orderonly)
	$(call print.trace)
	git add --renormalize .
	-git commit -m "$($@.commitmsg)"
	git rm -rf --cached --quiet .
	git reset --hard



#-----------------------------------------------------------
# git.require.no-uncommitted-changes
#-----------------------------------------------------------

# Global Variables
git.require.no-uncommitted-changes.prereqs.normal ?=
git.require.no-uncommitted-changes.prereqs.orderonly ?=
git.require.no-uncommitted-changes.prereqs = $(git.require.no-uncommitted-changes.prereqs.normal) $(git.require.no-uncommitted-changes.prereqs.orderonly)

# Help Text
$(eval $(call target.set_helptext,git.require.no-uncommitted-changes,\
$(EMPTY),\
  Terminates make with an error message if repository contains$(LF)\
  unstaged changes$(COMMA) or staged but uncommitted changes.$(LF)\
  $(LF)\
  This process is equivalent to running:$(LF)\
  $(LF)\
  $(INDENT.COMMAND) git diff --quiet && git diff --cached --quiet$(LF)\
  ,\
  $$@.prereqs.normal\
  $$@.prereqs.orderonly\
))

# Target Definition
.PHONY: git.require.no-uncommitted-changes
git.require.no-uncommitted-changes: $(git.require.no-uncommitted-changes.prereqs.normal) | $(git.require.no-uncommitted-changes.prereqs.orderonly)
	$(call print.trace)
	git diff --quiet && git diff --cached --quiet



#===============================================================================
# UPSTREAM: CURRENT PROJECT
#===============================================================================


