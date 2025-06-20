#===============================================================================
# config.mak
#
# Project configuration variables
#
#===============================================================================


#===============================================================================
# UPSTREAM: daniel-templates/template-project
#===============================================================================

# Project Directories
SOURCE_DIR = src
BUILD_DIR = build
LOG_DIR = logs

# Consumed by: functions.mak
print.debug.enable = false
print.trace.enable = true

# Consumed by: makefile (project root)
DEFAULT_TARGET ?= help

# Consumed by: .disable_implicit.mak
DISABLE_IMPLICIT ?= true

# Consumed by: git.mak
GIT_CONFIG_FILE = .project/git/.gitconfig
GIT_HOOKS_DIR = .project/git/hooks

# Consumed by: init.mak
CREATE_DIRS =

# Consumed by: clean.mak
REMOVE_DIRS = $(CREATE_DIRS)



#===============================================================================
# UPSTREAM: CURRENT PROJECT
#===============================================================================


