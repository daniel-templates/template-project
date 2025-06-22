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

# Disable built-in rules and variables; prefer to define them manually
MAKEFLAGS += --no-builtin-rules --no-builtin-variables

# Consumed by: functions.mak
print.debug.enable = false
print.trace.enable = true

# Consumed by: all.mak
all.prereqs.normal =
all.prereqs.orderonly = help.all

# Consumed by: clean.mak
clean.prereqs.normal =
clean.prereqs.orderonly = clean.remove
  clean.remove.dirs = $(init.create.dirs)
  clean.remove.files = $(init.create.files)

# Consumed by: git.mak
git.prereqs.normal =
git.prereqs.orderonly = help.git
  git.gitconfig.file = .project/git/.gitconfig
  git.gitconfig.hooksdir = .project/git/hooks

# Consumed by: init.mak
init.prereqs.normal =
init.prereqs.orderonly = init.create git.gitconfig
  init.create.dirs =
  init.create.dirs.perms = $(foreach path,$(init.create.dirs),u+rwX)
  init.create.files =
  init.create.files.perms = $(foreach path,$(init.create.files),u+rwx)

# Consumed by: install.mak
install.prereqs.normal =
install.prereqs.orderonly = help.install

# Consumed by: makefile (project root)
DEFAULT_TARGET = help


#===============================================================================
# UPSTREAM: CURRENT PROJECT
#===============================================================================
# variable = value1 value2 ...       To overwrite value(s)
# variable += value1 value2 ...      To append values(s)


