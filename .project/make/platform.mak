#===============================================================================
# platform.mak
#
# Defines mappings between common shell commands and their platform-specific
# variations.
#
# Usage:
#
#   Include in makefile:
#
#     include .project/make/functions.mak
#     include .project/make/platform.mak
#
#   Run a platform-independent shell command in a target definition block:
#
#     $(call mkdir,path/to/dir)
#
#   Run a shell command and store the output in a variable:
#
#     files := $(shell $(call ls,*.c))
#
#===============================================================================


ifndef LF
$(error CRITICAL: functions.mak has not yet been imported.)
endif

#===============================================================================
# OS Properties
#===============================================================================
# $(OS)                 Statically defined. Must update manually if OS changes for some reason.
#                         Typically already defined as an environment variable in Windows shells.
#                         If undefined, is set to $(shell uname).
#
# $(OS.type)            Returns "windows" if OS is Windows; "unix" otherwise.
# $(OS.type.windows)    Returns "windows" if OS is Windows; empty otherwise.
# $(OS.type.unix)       Returns "unix" if OS is Unix-like; empty otherwise.
#
# $(OS.user.name)       Returns the current username.
# $(OS.user.home)       Returns the current user's home directory.
# $(OS.temp.root)       Returns the root path for temporary files.
# $(OS.sep.path)        Returns the OS file path separator.
# $(OS.sep.list)        Returns the OS list-of-multiple-paths separator.
# $(OS.ext.exe)         Returns the OS file extension for executable binaries.
# $(OS.ext.lib)         Returns the OS file extension for statically-linked libraries.
# $(OS.ext.dll)         Returns the OS file extension for dynamically-linked libraries.
#===============================================================================

ifndef OS
OS := $(shell uname && exit 0 || exit 1)
ifneq "$(.SHELLSTATUS)" "0"
$(error CRITICAL: Environment variable OS undefined and 'uname' not available.)
endif
ifndef OS
$(error CRITICAL: Environment variable OS undefined and 'uname' returned empty.)
endif
endif

OS.type = $(or $(OS.type.windows),$(OS.type.unix),other)
  OS.type.windows = $(if $(or $(findstring Windows,$(OS)),$(findstring MINGW,$(OS)),$(findstring MSYS,$(OS)),$(findstring CYGWIN,$(OS))),windows)
  OS.type.unix = $(if $(OS.type.windows),,unix)

# OS.type variants are not intended to be used directly.
# They may return incorrect results if not expanded on their target platform.
OS.user.name = $(OS.user.name.$(OS.type))
OS.user.home = $(OS.user.home.$(OS.type))
OS.temp.root = $(OS.temp.root.$(OS.type))
OS.sep.path = $(OS.sep.path.$(OS.type))
OS.sep.list = $(OS.sep.list.$(OS.type))
OS.ext.exe = $(OS.ext.exe.$(OS.type))
OS.ext.lib = $(OS.ext.lib.$(OS.type))
OS.ext.dll = $(OS.ext.dll.$(OS.type))

  OS.user.name.windows = $(USERNAME)
  OS.user.home.windows = $(USERPROFILE)
  OS.temp.root.windows = $(or $(TEMP),$(TMP),$(OS.user.home.windows)\\AppData\\Local\\Temp)
  OS.sep.path.windows := $(BSLASH)
  OS.sep.list.windows := $(SEMICOLON)
  OS.ext.exe.windows := .exe
  OS.ext.lib.windows := .lib
  OS.ext.dll.windows := .dll

  OS.user.name.unix = $(USER)
  OS.user.home.unix = $(HOME)
  OS.temp.root.unix = $(or $(TMPDIR),$(TEMP),$(TMP),/var/tmp)
  OS.sep.path.unix := $(FSLASH)
  OS.sep.list.unix := $(COLON)
  OS.ext.exe.unix :=
  OS.ext.lib.unix := .a
  OS.ext.dll.unix := .so

#===============================================================================
# Shell Properties
#===============================================================================
# Properties are organized into namespaces.
#
# Properties are intended to be read-only; their content is
# dynamically derived from lower-level sources.
#
# SHELL                Top-level namespace for the active shell configuration.
#	.name                Name of active shell.
#	.type                Type of active shell.
#	.path                Path to shell executable.
#	.flags               Options for shell executable. Shell command is appended after this.
#	.aliases             List of possible filenames which may identify this kind of shell.
#	.sep.path            File path separator for this shell.
#	.sep.list            List-of-multiple-paths separator for this shell.
#	.ext.script          File extension typically associated with scripts for this shell.
#	.properties          List of properties in this namespace.
#	.print               Returns empty. Prints values of all properties in this namespace.
#
# SHELL.names.{name}   Namespaces for each shell definition.
#	.isactive            Returns {name} if this shell is currently active; empty otherwise.
#	.type                Type associated with this shell definition.
#	.path
#	.flags
#	.aliases
#	.sep.path
#	.sep.list
#	.ext.script
#	.properties
#	.print               Returns empty. Prints values of all properties in this namespace.
#	.activate            Returns empty. Sets this shell configuration as active.
#
# SHELL.types.{name}   Namespaces for each shell type definition.
#	.isactive            Returns {name} if a shell of this type is currently active; empty otherwise.
#	.path
#	.flags
#	.aliases
#	.sep.path
#	.sep.list
#	.ext.script
#	.properties
#	.print               Returns empty. Prints values of all properties in this namespace.
#
#===============================================================================

SHELL.properties = name $(SHELL.names.properties)
SHELL.names.properties = type $(SHELL.types.properties)
SHELL.types.properties = isactive path flags aliases sep.path sep.list ext.script



#===============================================================================
# SHELL.*
#===============================================================================
# Top-level namespace for the active shell configuration.
#
# Each property points to the corresponding property in
# the active shell's definition.
#===============================================================================
SHELL.name := default
SHELL.print = $(call print.var,$(foreach prop,$(SHELL.properties),SHELL.$(prop)))
$(foreach prop,$(filter-out name print,$(SHELL.properties)),$(eval SHELL.$(prop) = $$(SHELL.names.$$(SHELL.name).$(prop))))



#===============================================================================
# SHELL.names.*
#===============================================================================
# Namespaces for each shell definition.
#
# Top-level Properties with User-Writeable Namespaces:
#	.path
#	.flags
#	.aliases
#	.sep.path
#	.sep.list
#	.ext.script
#
# Top-level properties are intended to be read-only, and are set automatically:
#
#	SHELL.names.{name}.{prop}
#
# Each top-level property is its own namespace, and the property's value is
# determined by the contents of its namespace, which are fully user-writeable:
#
#	SHELL.names.{name}.{prop}.*
#
# Property value is assigned as the first non-empty string, in order:
#
#	1. SHELL.names.{name}.{prop}.{OS_name}    1st priority, if $(OS.name) matches
#	2. SHELL.names.{name}.{prop}.{OS_type}    2nd priority, if $(OS.type) matches
#	3. SHELL.names.{name}.{prop}.default      3rd priority
#	4. SHELL.types.{type}.{prop}              4th priority
#
# User should define as many of 1,2,3 as are applicable to the shell configuration.
#===============================================================================

#-----------------------------------------------------------
# $(call SHELL.names.define,{shell_name},{shell_type})
#-----------------------------------------------------------
SHELL.names := $(EMPTY)
define SHELL.names.define
$(eval SHELL.names += $(1))
$(eval SHELL.names.$(1).type := $(or $(2),$(error Empty shell_type in definition of '$(1)')))
$(eval SHELL.names.$(1).isactive = $$(if $$(filter $(1),$$(SHELL.name)),$(1)))
$(eval SHELL.names.$(1).print = $$(call print.var,$(foreach prop,$(SHELL.names.properties),SHELL.names.$(1).$(prop))))
$(eval SHELL.names.$(1).activate = $$(if $$(SHELL.names.$(1).isactive),,$$(eval SHELL.name := $(1))$$(eval SHELL := $$(SHELL.path))$$(eval .SHELLFLAGS := $$(SHELL.flags))))
$(foreach prop,$(filter-out type isactive print activate,$(SHELL.names.properties)),$(call variable.set_with_alternatives,SHELL.names.$(1).$(prop),?=,,  SHELL.names.$(1).$(prop).$$(OS.name)  SHELL.names.$(1).$(prop).$$(OS.type)  SHELL.names.$(1).$(prop).default  SHELL.types.$(2).$(prop)  ))
endef



#-----------------------------------------------------------
$(call SHELL.names.define,default,unknown)
#-----------------------------------------------------------
# Contains the original shell configuration that make was started with.
#
# Must be defined before $(SHELL) or $(.SHELLFLAGS) are modified.
# SHELL.names.default has the unique property SHELL.default.identity,
#  which searches SHELL.names.*.aliases for a matching executable,
#  then returns the name of the match.
#-----------------------------------------------------------
SHELL.names.default.path := $(SHELL)
SHELL.names.default.flags := $(.SHELLFLAGS)
SHELL.names.default.identity = $(strip $(firstword $(foreach name,$(filter-out default,$(SHELL.names)),$(if $(filter $(SHELL.names.$(name).aliases),$(notdir $(lastword $(SHELL.names.default.path)))),$(name)))))
$(foreach prop,$(filter-out path flags isactive,$(SHELL.names.properties)),$(eval SHELL.names.default.$(prop) = $$(SHELL.names.$$(SHELL.names.default.identity).$(prop))))



#-----------------------------------------------------------
$(call SHELL.names.define,bash,posix)
#-----------------------------------------------------------
# Common default shell on Linux-based systems.
#
# Flags:
#	--noprofile        Skip reading .profile scripts at startup
#	--norc             Skip reading .bashrc scripts at startup
#	--posix            Improve compatibility with POSIX standard
#	-e                 Exit immediately if any command line fails
#	-o pipefail        Exit if any part of a piped | command fails
#	-c                 Make appends the command line after this
#-----------------------------------------------------------
SHELL.names.bash.path.default := bash
  SHELL.names.bash.path.windows := bash.exe
  SHELL.names.bash.path.unix := bash
SHELL.names.bash.flags.default := --noprofile --norc --posix -e -o pipefail -c
SHELL.names.bash.aliases.default :=
  SHELL.names.bash.aliases.windows := bash.exe git-bash.exe
  SHELL.names.bash.aliases.unix := bash zsh fish



#-----------------------------------------------------------
$(call SHELL.names.define,sh,posix)
#-----------------------------------------------------------
# Available on most POSIX-compliant systems, but rarely the default shell.
#
# This definition just defers to the defaults for posix-type shells.
# See definion of SHELL.types.posix for details.
#-----------------------------------------------------------



#-----------------------------------------------------------
$(call SHELL.names.define,ash,posix)
#-----------------------------------------------------------
# Ash is the shell function of the busybox multitool.
# Default shell in many small distros like Alpine Linux.
#-----------------------------------------------------------
SHELL.names.ash.path.default := busybox
  SHELL.names.ash.path.unix := busybox
    SHELL.names.ash.path.alpine := /bin/busybox
SHELL.names.ash.flags.default :=
SHELL.names.ash.aliases.default := ash busybox



#-----------------------------------------------------------
$(call SHELL.names.define,cmd,cmd)
#-----------------------------------------------------------
# Default Windows command interpreter.
#
# This definition just defers to the defaults for cmd-type shells.
# See definion of SHELL.types.cmd for details.
#-----------------------------------------------------------



#-----------------------------------------------------------
$(call SHELL.names.define,powershell,powershell)
# PowerShell is generally a better alternative to cmd.exe.
#-----------------------------------------------------------
# This definition just defers to the defaults for PowerShell-type shells.
# See definion of SHELL.types.powershell for details.
#-----------------------------------------------------------



#-----------------------------------------------------------
$(call SHELL.names.define,msys,posix)
# MSYS is a POSIX-compliant shell for Windows.
#-----------------------------------------------------------
SHELL.names.msys.path.default :=
SHELL.names.msys.flags.default :=



#-----------------------------------------------------------
$(call SHELL.names.define,cygwin,posix)
# Cygwin is a POSIX-compliant shell for Windows.
#-----------------------------------------------------------
SHELL.names.cygwin.path.default :=
SHELL.names.cygwin.flags.default :=



#-----------------------------------------------------------
$(call SHELL.names.define,python,python)
# Run Python syntax directly from make recipes!
#-----------------------------------------------------------
# This definition just defers to the defaults for Python-type shells.
# See definition of SHELL.types.python for details.
#-----------------------------------------------------------



#===============================================================================
# SHELL.types.*
#===============================================================================
# Namespaces for each shell type definition.
#
# Top-level Properties with User-Writeable Namespaces:
#	.path
#	.flags
#	.aliases
#	.sep.path
#	.sep.list
#	.ext.script
#
# Top-level properties are intended to be read-only, and are set automatically:
#
#	SHELL.types.{type}.{prop}
#
# Each top-level property is its own namespace, and the property's value is
# determined by the contents of its namespace, which are fully user-writeable:
#
#	SHELL.types.{type}.{prop}.*
#
# Property value is assigned as the first non-empty string, in order:
#
#	1. SHELL.types.{type}.{prop}.{OS_name}    1st priority, if $(OS.name) matches
#	2. SHELL.types.{type}.{prop}.{OS_type}    2nd priority, if $(OS.type) matches
#	3. SHELL.types.{type}.{prop}.default      3rd priority
#
# User should define as many of 1,2,3 as are applicable to the shell configuration.
#===============================================================================

#-----------------------------------------------------------
# $(call SHELL.types.define,{name})
#-----------------------------------------------------------
SHELL.types := $(EMPTY)
define SHELL.types.define
$(eval SHELL.types += $(1))
$(eval SHELL.types.$(1).isactive = $$(if $$(filter $(1),$$(SHELL.type)),$(1)))
$(eval SHELL.types.$(1).print = $$(call print.var,$(foreach prop,$(SHELL.types.properties),SHELL.types.$(1).$(prop))))
$(foreach prop,$(filter-out isactive print,$(SHELL.types.properties)),$(call variable.set_with_alternatives,SHELL.types.$(1).$(prop),?=,,  SHELL.types.$(1).$(prop).$$(OS.name)  SHELL.types.$(1).$(prop).$$(OS.type)  SHELL.types.$(1).$(prop).default  SHELL.types.$(2).$(prop)  ))
endef



#-----------------------------------------------------------
$(call SHELL.types.define,unknown)
#-----------------------------------------------------------
# Sensible defaults for when the shell type is unknown.
#-----------------------------------------------------------
SHELL.types.unknown.path.default :=
SHELL.types.unknown.flags.default :=
SHELL.types.unknown.aliases.default :=
SHELL.types.unknown.sep.path.default := $(OS.sep.path)
SHELL.types.unknown.sep.list.default := $(OS.sep.list)
SHELL.types.unknown.ext.script.default :=



#-----------------------------------------------------------
$(call SHELL.types.define,posix)
#-----------------------------------------------------------
# Syntax definitions and default launch config for POSIX-type shells.
#
# Flags:
#	-e                 Exit immediately if any command line fails
#	-c                 Make appends the command line after this
#-----------------------------------------------------------
SHELL.types.posix.path.default := sh
  SHELL.types.posix.path.windows :=
  SHELL.types.posix.path.unix :=
SHELL.types.posix.flags.default := -e -c
  SHELL.types.posix.flags.windows :=
  SHELL.types.posix.flags.unix :=
SHELL.types.posix.aliases.default := sh sh.exe
  SHELL.types.posix.aliases.windows :=
  SHELL.types.posix.aliases.unix :=
SHELL.types.posix.sep.path.default := $(FSLASH)
  SHELL.types.posix.sep.path.windows :=
  SHELL.types.posix.sep.path.unix :=
SHELL.types.posix.sep.list.default := $(COLON)
  SHELL.types.posix.sep.list.windows :=
  SHELL.types.posix.sep.list.unix :=
SHELL.types.posix.ext.script.default := .sh



#-----------------------------------------------------------
$(call SHELL.types.define,cmd)
#-----------------------------------------------------------
# Syntax definitions and default launch config for Windows cmd.exe.
#
# Flags: Order of flags matters for cmd.exe! Not sure why.
#	/Q                 Disable command echoing; make does this already
#	/D                 Skip execution of registry AutoRun commands at startup
#	/E:ON              Enable Command Extensions; typical default behavior of CMD anyway
#	/V:OFF             Disable delayed expansion; reduces problems with '!' and other special characters
#	/S                 Simpler, more reliable parsing of doublequotes '"'
#	/C                 Make appends the command line after this
#-----------------------------------------------------------
SHELL.types.cmd.path.default := cmd
  SHELL.types.cmd.path.windows := cmd.exe
  SHELL.types.cmd.path.unix :=
SHELL.types.cmd.flags.default := /Q /D /E:ON /V:OFF /S /C
  SHELL.types.cmd.flags.windows :=
  SHELL.types.cmd.flags.unix :=
SHELL.types.cmd.aliases.default := cmd cmd.exe
  SHELL.types.cmd.aliases.windows :=
  SHELL.types.cmd.aliases.unix :=
SHELL.types.cmd.sep.path.default := $(BSLASH)
  SHELL.types.cmd.sep.path.windows :=
  SHELL.types.cmd.sep.path.unix :=
SHELL.types.cmd.sep.list.default := $(SEMICOLON)
  SHELL.types.cmd.sep.list.windows :=
  SHELL.types.cmd.sep.list.unix :=
SHELL.types.cmd.ext.script.default := .bat



#-----------------------------------------------------------
$(call SHELL.types.define,powershell)
#-----------------------------------------------------------
# Syntax definitions and default launch config for PowerShell.
#
# Flags:
#	-NoProfile         Skip reading profile.ps1 scripts at startup
#	-Command           Make appends the command line after this
#-----------------------------------------------------------
SHELL.types.powershell.path.default := powershell
  SHELL.types.powershell.path.windows := powershell.exe
  SHELL.types.powershell.path.unix := pwsh
SHELL.types.powershell.flags.default := -NoProfile -Command
  SHELL.types.powershell.flags.windows :=
  SHELL.types.powershell.flags.unix :=
SHELL.types.powershell.aliases.default :=
  SHELL.types.powershell.aliases.windows := powershell.exe pwsh.exe
  SHELL.types.powershell.aliases.unix := powershell pwsh
SHELL.types.powershell.sep.path.default := $(OS.sep.path)
  SHELL.types.powershell.sep.path.windows :=
  SHELL.types.powershell.sep.path.unix :=
SHELL.types.powershell.sep.list.default := $(OS.sep.list)
  SHELL.types.powershell.sep.list.windows :=
  SHELL.types.powershell.sep.list.unix :=
SHELL.types.powershell.ext.script.default := .ps1



#-----------------------------------------------------------
$(call SHELL.types.define,python)
#-----------------------------------------------------------
# Syntax definitions and default launch config for Python.
#
# Flags:
#	-q                 Dont print version and copyright messages
#	-c                 Make appends the command line after this
#-----------------------------------------------------------
SHELL.types.python.path.default := python
  SHELL.types.python.path.windows = python.exe
  SHELL.types.python.path.unix = python
    SHELL.types.python.path.ubuntu = python3
SHELL.types.python.flags.default := -q -c
  SHELL.types.python.flags.windows :=
  SHELL.types.python.flags.unix :=
SHELL.types.python.aliases.default :=
  SHELL.types.python.aliases.windows := python.exe python3.exe py.exe
  SHELL.types.python.aliases.unix := python python3
SHELL.types.python.sep.path.default := $(OS.sep.path)
  SHELL.types.python.sep.path.windows :=
  SHELL.types.python.sep.path.unix :=
SHELL.types.python.sep.list.default := $(OS.sep.list)
  SHELL.types.python.sep.list.windows :=
  SHELL.types.python.sep.list.unix :=
SHELL.types.python.ext.script.default := .py



$(info )
$(call SHELL.print)
$(info )
$(call SHELL.names.cmd.activate)
$(call SHELL.print)
$(info )
$(call SHELL.names.powershell.activate)
$(call SHELL.print)
$(info )
$(call SHELL.names.bash.activate)
$(call SHELL.print)
$(info )
$(call SHELL.names.python.activate)
$(call SHELL.print)
$(info )
$(error Exiting here.)






#### SHELL COMMANDS
# Path arguments can be specified with "/" or "\" and will be automatically corrected for the platform.
#
# $(call shell.nop)                        Runs a shell command which does nothing. Useful for suppressing "Nothing to be done for target" messages.
# $(call shell.errlvl,{num})               Set's the shell's error level. 0 is success, 1+ is failure.
# $(call shell.echo,{string})              Prints the string
# $(call shell.line)                       Print an empty line
# $(call shell.touch,{path})               Update the timestamp on a file. Creates file if it does not already exist.
# $(call shell.ls,{path})                  Lists files under the given path
# $(call shell.chmod,[options],[perms],{path})         Standard POSIX chmod. Default options are "--changes --preserve-root". Calls "nop" on non-posix systems.
# $(call shell.chown,[options],[user][:group],{path})  Standard POSIX chmod. Default options are "--changes --preserve-root". Calls "nop" on non-posix systems.
# $(call shell.mkdir,{path})               Creates the directory tree, if it doesn't already exist.
# $(call shell.rm,{path})                  Deletes a file, if it exists.
# $(call shell.rmdir,{path})               Deletes a directory, if it exists.
# $(call shell.copy,{src},{dst})           Copies {src} file to {dst}.
#                                            If {dst} does not exist, creates new file {dst}.
#                                            If {dst} is a file, overwrites.
#                                            If {dst} is a directory, creates new file {dst}/basename({src})
# $(call shell.copydir,{src},{dst})        Copies {src} directory and its contents to {dst}.
#                                            If {dst} does not exist, creates new directory {dst}.
#                                            If {dst} is a directory, copies the CONTENTS of {src} into {dst}, overwriting files as necessary.
#
# $(call shell.silent,$(call COMMAND))     Suppresses stdout from the shell command.
# $(call shell.subshell,$(call COMMAND))   Runs the shell command in a subshell process.
# $(call shell.and,$(call ...),$(call ...))  Runs two or more commands in sequence.
# $(call shell.test,$(call COMMAND)[,$(call IF_SUCCESS)][,$(call IF_FAILURE)]  Runs COMMAND. If successful (ERROR=0), runs IF_SUCCESS. Otherwise, runs IF_FAILURE.


ifeq "$(SHELL_TYPE)" "CMD"
    shell.nop = echo 1>nul
    shell.errlvl = $(call shell.subshell,exit $(1))
    shell.echo = $(call shell.subshell,echo$(OPAREN)$(1))
    shell.line = $(call shell.echo,)
    shell.touch = ( if exist "$(call mkpath,$(1))" ( copy /Y /B "$(call mkpath,$(1))"+,, "$(call mkpath,$(1))" 1>nul ) else ( echo 1>nul 2>"$(call mkpath,$(1))" ) ) && echo $(INDENT)Touched: $(call mkpath,$(1))
    shell.ls = dir /b "$(call mkpath,$(1))"
    shell.chmod = $(info $(INDENT)(Skipping) chmod --changes --preserve-root $(strip $(1)) $(strip $(2)) "$(call mkpath,$(3))")
    shell.chown = $(info $(INDENT)(Skipping) chown --changes --preserve-root $(strip $(1)) $(strip $(2)) "$(call mkpath,$(3))")
    shell.mkdir = if not exist "$(call mkpath,$(1))\" ( mkdir "$(call mkpath,$(1))" 1>nul && echo $(INDENT)Created: $(call mkpath,$(1))$(sep.path) )
    shell.rm = if exist "$(call mkpath,$(1))" ( del /f /q "$(call mkpath,$(1))" 1>nul && echo $(INDENT)Removed: $(call mkpath,$(1)) )
    shell.rmdir = if exist "$(call mkpath,$(1))\" ( rmdir /s /q "$(call mkpath,$(1))" && echo $(INDENT)Removed: $(call mkpath,$(1))$(sep.path) )
    shell.copy = xcopy /Y /I /-I "$(call mkpath,$(1))" "$(call mkpath,$(2))"
    shell.copydir = xcopy /Y /I /E "$(call mkpath,$(1))" "$(call mkpath,$(2))"
    shell.silent = ( $(1) ) 1>nul
    shell.subshell = $(SHELL) $(.SHELLFLAGS) "$(1)"
    shell.and = ( $(call concatargs,$(CPAREN) & $(OPAREN),$(1),$(2),$(3),$(4),$(5),$(6),$(7),$(8)) )
    shell.test = ( $(1) $(if $(2),$(CPAREN) && $(OPAREN) $(2)) $(if $(3),$(CPAREN) || $(OPAREN) $(3)) )
endif
ifeq "$(SHELL_TYPE)" "POWERSHELL"
    shell.nop = ? .
    shell.errlvl = $(error Function "errlvl" is not implemented for SHELL_TYPE=$(SHELL_TYPE). See platform.mak for details.)
    shell.echo = Write-Output '$(1)'
    shell.line = $(call shell.echo,)
    shell.touch = $(error Function "touch" is not implemented for SHELL_TYPE=$(SHELL_TYPE). See platform.mak for details.)
    shell.ls = Get-ChildItem -Name '$(call mkpath,$(1))'
    shell.chmod = $(info $(INDENT)(Skipping) chmod --changes --preserve-root $(strip $(1)) $(strip $(2)) "$(call mkpath,$(3))")
    shell.chown = $(info $(INDENT)(Skipping) chown --changes --preserve-root $(strip $(1)) $(strip $(2)) "$(call mkpath,$(3))")
    shell.mkdir = New-Item -ItemType Directory -Force -Path '$(call mkpath,$(1))'
    shell.rm = Remove-Item -Force -Path '$(call mkpath,$(1))'
    shell.rmdir = Remove-Item -Force -Recurse -Path '$(call mkpath,$(1))'
    shell.copy = $(error Function "copy" is not implemented for SHELL_TYPE=$(SHELL_TYPE). See platform.mak for details.)
    shell.copydir = $(error Function "copydir" is not implemented for SHELL_TYPE=$(SHELL_TYPE). See platform.mak for details.)
    shell.silent = $(error Function "silent" is not implemented for SHELL_TYPE=$(SHELL_TYPE). See platform.mak for details.)
    shell.subshell = $(SHELL) $(.SHELLFLAGS) "$(1)"
    shell.and = $(error Function "and" is not implemented for SHELL_TYPE=$(SHELL_TYPE). See platform.mak for details.)
    shell.test = $(error Function "test" is not implemented for SHELL_TYPE=$(SHELL_TYPE). See platform.mak for details.)
endif
ifeq "$(SHELL_TYPE)" "POSIX"
    shell.nop = :
    shell.errlvl = $(call shell.subshell,exit $(1))
    shell.echo = echo "$(1)"
    shell.line = $(call shell.echo,)
    shell.touch = touch "$(call mkpath,$(1))" && echo "$(INDENT)Touched: $(call mkpath,$(1))"
    shell.ls = ls -A -1 --color=no "$(call mkpath,$(1))"
    shell.chmod = $(if $(strip $(2)),chmod --changes --preserve-root $(strip $(1)) $(strip $(2)) "$(call mkpath,$(3))")
    shell.chown = $(if $(strip $(2)),chown --changes --preserve-root $(strip $(1)) $(strip $(2)) "$(call mkpath,$(3))")
    shell.mkdir = if [ ! -d "$(call mkpath,$(1))" ]; then mkdir -p "$(call mkpath,$(1))" > /dev/null && echo "$(INDENT)Created: $(call mkpath,$(1))$(sep.path)"; fi
    shell.rm = if [ -e "$(call mkpath,$(1))" ]; then rm --preserve-root --verbose -f "$(call mkpath,$(1))" > /dev/null && echo "$(INDENT)Removed: $(call mkpath,$(1))"; fi
    shell.rmdir = if [ -e "$(call mkpath,$(1))" ]; then rm --preserve-root --verbose -rf "$(call mkpath,$(1))" && echo "$(INDENT)Removed: $(call mkpath,$(1))$(sep.path)"; fi
    shell.copy = cp -f "$(call mkpath,$(1))" "$(call mkpath,$(2))"
    shell.copydir = cp -rf "$(call mkpath,$(1))/." "$(call mkpath,$(2))"
    shell.silent = ( $(1) ) > /dev/null
    shell.subshell = $(SHELL) $(.SHELLFLAGS) "$(1)"
    shell.and = ( $(call concatargs,$(CPAREN) & $(OPAREN),$(1),$(2),$(3),$(4),$(5),$(6),$(7),$(8)) )
    shell.test = ( $(1) $(if $(2),$(CPAREN) && $(OPAREN) $(2)) $(if $(3),$(CPAREN) || $(OPAREN) $(3)) )
endif


$(info os.type:     $(os.type))
$(info SHELL_TYPE:  $(SHELL_TYPE))
$(info SHELL:       $(SHELL) $(.SHELLFLAGS))