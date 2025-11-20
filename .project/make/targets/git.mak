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
.PHONY: git.mak


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
# $(call help.targets.define,TARGET,\
# 	Short Description\
# 	,\
# 	Long Multiline$n\
# 	description$n\
# 	,\
# 	$$@.prereqs.normal\
# 	$$@.prereqs.orderonly\
# 	OTHER CONSUMED VARIABLES\
# )
#
# Pretarget
#   Runs exactly once before any number of prereqs
#
# $(call target.pre.define,TARGET,$(TARGET.prereqs),\
# 	$$(call print.trace,make $$(basename $$@))$n\
# 	[OTHER COMMANDS]$n\
# )
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
$(call help.targets.define,git,\
	Common Git operations\
	,\
	Available sub-tasks are listed in "Related Targets" below.$n\
	$n\
	Projects can extend the behavior of this (or related) targets$n\
	through two methods:$n\
	$n\
	1: Define new targets and append them as prereqs;$n\
	$$(line.indent) In config.mak$$c add the lines:$n\
	$n\
	$$(line.indent)$$(line.indent) $$@.prereqs.normal = TARGETS$n\
	$$(line.indent)$$(line.indent) $$@.prereqs.orderonly = TARGETS$n\
	$n\
	2: Leverage existing targets by overriding their variables.$n\
	$$(line.indent) See Related Targets below.$n\
	,\
	$$@.prereqs.normal\
	$$@.prereqs.orderonly\
)

# Pretarget; runs exactly once before any number of prereqs
$(call target.pre.define,git,$(git.prereqs),\
	$$(call print.trace,make $$(basename $$@))$n\
)

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
$(call help.targets.define,git.gitconfig,\
	$(char.empty)\
	,\
	Sets Git property "include.path" to ../$$$$($$@.file).$n\
	Also sets executable bit on files in $$$$($$@.hooksdir).$n\
	,\
	$$@.prereqs.normal\
	$$@.prereqs.orderonly\
	$$@.file\
	$$@.hooksdir\
)

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
$(call help.targets.define,git.gitignore,\
	$(char.empty)\
	,\
	Untrack files identified in the repo's .gitignore.$n\
	$n\
	Modifies Git repo only. Local working tree is unaffected.$n\
	$n\
	If a file has already been committed to the repo$$c and$n\
	is later added to .gitignore$$c the file remains in the$n\
	repo until it is explicitly removed from tracking.$n\
	$n\
	This process is equivalent to running:$n\
	$n\
	$$(COMMAND.INDENT) git rm -rf --cached --quiet .$n\
	$$(COMMAND.INDENT) git add --all$n\
	$$(COMMAND.INDENT) git commit -m "$$$$($$@.commitmsg)"$n\
	,\
	$$@.prereqs.normal\
	$$@.prereqs.orderonly\
	$$@.commitmsg\
	commitmsg\
)

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
$(call help.targets.define,git.gitattributes,\
	$(char.empty)\
	,\
	Reencode files according to the repo's .gitattributes.$n\
	$n\
	Modifies local files AND Git repo.$n\
	$n\
	When .gitattributes is changed$$c some files may not have$n\
	the correct encoding or line ending format anymore.$n\
	This renormalizes and commits changes to all files in the repo$$c$n\
	then hard-resets to that commit so these changes are reflected$n\
	in the working-tree as well.$n\
	$n\
	This process is equivalent to running:$n\
	$n\
	$$(COMMAND.INDENT) git add --renormalize .$n\
	$$(COMMAND.INDENT) git commit -m "$$$$($$@.commitmsg)"$n\
	$$(COMMAND.INDENT) git rm -rf --cached --quiet .$n\
	$$(COMMAND.INDENT) git reset --hard$n\
	$n\
	Be sure these changes are also reflected in .vscode/settings.all.json$n\
	$n\
	WARNING: This process is not perfect! Some files may not be reencoded.$n\
	,\
	$$@.prereqs.normal\
	$$@.prereqs.orderonly\
	$$@.commitmsg\
	commitmsg\
)

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
$(call help.targets.define,git.require.no-uncommitted-changes,\
	$(char.empty)\
	,\
	Terminates make with an error message if repository contains$n\
	unstaged changes$$c or staged but uncommitted changes.$n\
	$n\
	This process is equivalent to running:$n\
	$n\
	$$(COMMAND.INDENT) git diff --quiet && git diff --cached --quiet$n\
	,\
	$$@.prereqs.normal\
	$$@.prereqs.orderonly\
)

# Target Definition
.PHONY: git.require.no-uncommitted-changes
git.require.no-uncommitted-changes: $(git.require.no-uncommitted-changes.prereqs.normal) | $(git.require.no-uncommitted-changes.prereqs.orderonly)
	$(call print.trace)
	git diff --quiet && git diff --cached --quiet



#===============================================================================
# UPSTREAM: CURRENT PROJECT
#===============================================================================


