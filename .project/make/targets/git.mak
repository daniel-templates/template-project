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
# git
#-----------------------------------------------------------

# Help Text
$(eval $(call set_helptext,git,\
  Common Git operations.,\
  Available sub-tasks are listed in "Related Targets" below.$(LF)\
  $(LF)\
  Projects can extend the behavior of this (or related) targets$(LF)\
  through two methods:$(LF)\
  $(LF)\
  1: define new targets and append them as prereqs$(LF)\
  _    (see git.mak for details)$(LF)\
  2: leverage existing targets by overriding their variables$(LF)\
  _    (see Related Targets below)$(LF)\
  ,\
$(EMPTY)\
))

# Definition
.PHONY: git
git: | help.git



#-----------------------------------------------------------
# git.gitconfig
#-----------------------------------------------------------

# Local Variables
git.gitconfig: GIT_CONFIG_FILE ?= .project/git/.gitconfig
git.gitconfig: GIT_HOOKS_DIR ?= .project/git/hooks

# Help Text
$(eval $(call set_helptext,git.gitconfig,\
$(EMPTY),\
  Sets Git property "include.path" to ../GIT_CONFIG_FILE.$(LF)\
  Also sets executable bit on files in GIT_HOOKS_DIR.$(LF)\
  ,\
  GIT_CONFIG_FILE\
  GIT_HOOKS_DIR\
))

# Definition
.PHONY: git.gitconfig
git.gitconfig:
	$(PRINT_TRACE)
	git config --local include.path ../$(GIT_CONFIG_FILE)
	$(call chmod,--verbose u+x,$(GIT_HOOKS_DIR)/*)



#-----------------------------------------------------------
# git.gitignore
#-----------------------------------------------------------

# Local Variables
git.gitignore: GIT_COMMIT_MESSAGE ?= Updated file tracking according to .gitignore
git.gitignore: m ?= $(GIT_COMMIT_MESSAGE)

# Help Text
$(eval $(call set_helptext,git.gitignore,\
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
    git rm -rf --cached --quiet .$(LF)\
    git add --all$(LF)\
    git commit -m "GIT_COMMIT_MESSAGE"$(LF)\
  ,\
  GIT_COMMIT_MESSAGE\
  m\
))

# Definition
.PHONY: git.gitignore
git.gitignore: | git.require.no-uncommitted-changes
	$(PRINT_TRACE)
	git rm -rf --cached --quiet .
	git add --all
	-git commit -m "$(m)"



#-----------------------------------------------------------
# git.gitattributes
#-----------------------------------------------------------

# Local Variables
git.gitattributes: GIT_COMMIT_MESSAGE ?= Reencoded files according to .gitattributes
git.gitattributes: m ?= $(GIT_COMMIT_MESSAGE)

# Help Text
$(eval $(call set_helptext,git.gitattributes,\
$(EMPTY),\
  Reencode files according to the repo's .gitattributes.$(LF)\
  $(LF)\
  Modifies local files AND Git repo.$(LF)\
  $(LF)\
  When .gitattributes is changed, some files may not have$(LF)\
  the correct encoding or line ending format anymore.$(LF)\
  This renormalizes and commits changes to all files in the repo$(COMMA)$(LF)\
  then hard-resets to that commit so these changes are reflected$(LF)\
  in the working-tree as well.$(LF)\
  $(LF)\
  This process is equivalent to running:$(LF)\
  $(LF)\
  _ git add --renormalize .$(LF),\
    git commit -m "GIT_COMMIT_MESSAGE"$(LF)\
    git rm -rf --cached --quiet .$(LF)\
    git reset --hard$(LF)\
  $(LF)\
  Be sure these changes are also reflected in .vscode/settings.all.json$(LF)\
  $(LF)\
  WARNING: This process is not perfect! Some files may not be reencoded.$(LF)\
  ,\
  GIT_COMMIT_MESSAGE\
  m\
))

# Definition
.PHONY: git.gitattributes
git.gitattributes: | git.require.no-uncommitted-changes
	$(PRINT_TRACE)
	git add --renormalize .
	-git commit -m "$(m)"
	git rm -rf --cached --quiet .
	git reset --hard



#-----------------------------------------------------------
# git.require.no-uncommitted-changes
#-----------------------------------------------------------

# Help Text
$(eval $(call set_helptext,git.require.no-uncommitted-changes,\
$(EMPTY),\
  Terminates make with an error message if repository contains$(LF)\
  unstaged changes$(COMMA) or staged but uncommitted changes.$(LF)\
  $(LF)\
  This process is equivalent to running:$(LF)\
  $(LF)\
    git add . && git diff --quiet && git diff --cached --quiet$(LF)\
  ,\
$(EMPTY),\
))

# Definition
.PHONY: git.require.no-uncommitted-changes
git.require.no-uncommitted-changes:
	$(PRINT_TRACE)
	git add . && git diff --quiet && git diff --cached --quiet



#===============================================================================
# UPSTREAM: CURRENT PROJECT
#===============================================================================


