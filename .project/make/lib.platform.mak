#===============================================================================
# lib.platform.mak
#===============================================================================
#
# Defines mappings between common shell commands and their platform-specific
# variations.
#
# Usage:
#
#	Include in makefile:
#
#		include .project/make/lib.mak
#		include .project/make/lib.platform.mak
#
#===============================================================================
$(if $(filter-out $(notdir $(MAKEFILE_LIST)), lib.mak ),$(error Makefile $(lastword $(notdir $(MAKEFILE_LIST))) is missing dependencies))
#===============================================================================




#===============================================================================
# OS Properties
#===============================================================================
# $(OS)                 Statically defined. Must update manually if OS changes for some reason.
#                         Typically already defined as an environment variable in Windows shells.
#                         If undefined, is set to $(shell uname).
#
# $(os.type)            Returns "windows" if OS is Windows; "unix" otherwise.
# $(os.type.windows)    Returns "windows" if OS is Windows; empty otherwise.
# $(os.type.unix)       Returns "unix" if OS is Unix-like; empty otherwise.
#
# $(os.user.name)       Returns the current username.
# $(os.user.home)       Returns the current user's home directory.
# $(os.temp.root)       Returns the root path for temporary files.
# $(os.sep.path)        Returns the OS file path separator.
# $(os.sep.list)        Returns the OS list-of-multiple-paths separator.
# $(os.ext.exe)         Returns the OS file extension for executable binaries.
# $(os.ext.lib)         Returns the OS file extension for statically-linked libraries.
# $(os.ext.dll)         Returns the OS file extension for dynamically-linked libraries.
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

os.type = $(or $(os.type.windows),$(os.type.unix),other)
  os.type.windows = $(if $(or $(findstring Windows,$(OS)),$(findstring MINGW,$(OS)),$(findstring MSYS,$(OS)),$(findstring CYGWIN,$(OS))),windows)
  os.type.unix = $(if $(os.type.windows),,unix)

# os.type variants are not intended to be used directly.
# They may return incorrect results if not expanded on their target platform.
os.user.name = $(os.user.name.$(os.type))
os.user.home = $(os.user.home.$(os.type))
os.temp.root = $(os.temp.root.$(os.type))
os.sep.path = $(os.sep.path.$(os.type))
os.sep.list = $(os.sep.list.$(os.type))
os.ext.exe = $(os.ext.exe.$(os.type))
os.ext.lib = $(os.ext.lib.$(os.type))
os.ext.dll = $(os.ext.dll.$(os.type))

  os.user.name.windows = $(USERNAME)
  os.user.home.windows = $(USERPROFILE)
  os.temp.root.windows = $(or $(TEMP),$(TMP),$(os.user.home.windows)\\AppData\\Local\\Temp)
  os.sep.path.windows := $(BSLASH)
  os.sep.list.windows := $(SEMICOLON)
  os.ext.exe.windows := .exe
  os.ext.lib.windows := .lib
  os.ext.dll.windows := .dll

  os.user.name.unix = $(USER)
  os.user.home.unix = $(HOME)
  os.temp.root.unix = $(or $(TMPDIR),$(TEMP),$(TMP),/var/tmp)
  os.sep.path.unix := $(FSLASH)
  os.sep.list.unix := $(COLON)
  os.ext.exe.unix :=
  os.ext.lib.unix := .a
  os.ext.dll.unix := .so

#===============================================================================
# Shell Properties
#===============================================================================
# Properties are organized into namespaces.
#
# Properties are intended to be read-only; their content is
# dynamically derived from lower-level sources.
#
# shell                Top-level namespace for the active shell configuration.
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
# shell.names.{name}   Namespaces for each shell definition.
#	.isactive            Returns $(TRUE.m) if this shell is currently active; empty otherwise.
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
# shell.types.{name}   Namespaces for each shell type definition.
#	.isactive            Returns $(TRUE.m) if a shell of this type is currently active; empty otherwise.
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

shell.properties = name $(shell.names.properties)
shell.names.properties = type $(shell.types.properties)
shell.types.properties = isactive path flags aliases sep.path sep.list ext.script



#===============================================================================
# shell.*
#===============================================================================
# Top-level namespace for the active shell configuration.
#
# Each property points to the corresponding property in
# the active shell's definition.
#===============================================================================
shell.name := default
shell.print = $(call print.var,$(foreach prop,$(shell.properties),shell.$(prop)))
$(foreach prop,$(filter-out name print,$(shell.properties)),$(eval shell.$(prop) = $$(shell.names.$$(shell.name).$(prop))))



#===============================================================================
# shell.names.*
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
#	shell.names.{name}.{prop}
#
# Each top-level property is its own namespace, and the property's value is
# determined by the contents of its namespace, which are fully user-writeable:
#
#	shell.names.{name}.{prop}.*
#
# Property value is assigned as the first non-empty string, in order:
#
#	1. shell.names.{name}.{prop}.{OS_name}    1st priority, if $(os.name) matches
#	2. shell.names.{name}.{prop}.{OS_type}    2nd priority, if $(os.type) matches
#	3. shell.names.{name}.{prop}.default      3rd priority
#	4. shell.types.{type}.{prop}              4th priority
#
# User should define as many of 1,2,3 as are applicable to the shell configuration.
#===============================================================================

#-----------------------------------------------------------
# $(call shell.names.define,{shell_name},{shell_type})
#-----------------------------------------------------------
shell.names := $(EMPTY)
define shell.names.define
$(eval shell.names += $(1))
$(eval shell.names.$(1).type := $(or $(2),$(error Empty shell_type in definition of '$(1)')))
$(eval shell.names.$(1).isactive = $$(if $$(filter $(1),$$(shell.name)),$(TRUE.m),$(FALSE.m)))
$(eval shell.names.$(1).print = $$(call print.var,$(foreach prop,$(shell.names.properties),shell.names.$(1).$(prop))))
$(eval shell.names.$(1).activate = $$(if $$(shell.names.$(1).isactive),,$$(eval shell.name := $(1))$$(eval SHELL := $$(shell.path))$$(eval .SHELLFLAGS := $$(shell.flags))))
$(foreach prop,$(filter-out type isactive print activate,$(shell.names.properties)),$(call variable.set_with_alternatives,shell.names.$(1).$(prop),?=,,  shell.names.$(1).$(prop).$$(os.name)  shell.names.$(1).$(prop).$$(os.type)  shell.names.$(1).$(prop).default  shell.types.$(2).$(prop)  ))
endef



#-----------------------------------------------------------
$(call shell.names.define,default,unknown)
#-----------------------------------------------------------
# Contains the original shell configuration that make was started with.
#
# Must be defined before $(SHELL) or $(.SHELLFLAGS) are modified.
# shell.names.default has the unique property shell.default.identity,
#  which searches shell.names.*.aliases for a matching executable,
#  then returns the name of the match.
#-----------------------------------------------------------
shell.names.default.path := $(SHELL)
shell.names.default.flags := $(.SHELLFLAGS)
shell.names.default.identity = $(strip $(firstword $(foreach name,$(filter-out default,$(shell.names)),$(if $(filter $(shell.names.$(name).aliases),$(notdir $(lastword $(shell.names.default.path)))),$(name)))))
$(foreach prop,$(filter-out path flags isactive,$(shell.names.properties)),$(eval shell.names.default.$(prop) = $$(shell.names.$$(shell.names.default.identity).$(prop))))



#-----------------------------------------------------------
$(call shell.names.define,bash,posix)
#-----------------------------------------------------------
# Common default shell on Linux-based systems.
#
# Flags:
#	--noprofile        Skip reading .profile scripts at startup
#	--norc             Skip reading .bashrc scripts at startup
#	--posix            Improve compatibility with POSIX standard
#	-e                 Exit immediately if any command line fails
#	-o pipefail        Exit if any part of a piped | command fails
#	-c                 Run the final argument as a command
#	--                 No more options; next arg is the command
#-----------------------------------------------------------
shell.names.bash.path.default := bash
  shell.names.bash.path.windows := bash.exe
  shell.names.bash.path.unix := bash
shell.names.bash.flags.default := --noprofile --norc --posix -eco pipefail --
shell.names.bash.aliases.default :=
  shell.names.bash.aliases.windows := bash.exe git-bash.exe
  shell.names.bash.aliases.unix := bash zsh fish



#-----------------------------------------------------------
$(call shell.names.define,sh,posix)
#-----------------------------------------------------------
# Available on most POSIX-compliant systems, but rarely the default shell.
#
# This definition just defers to the defaults for posix-type shells.
# See definion of shell.types.posix for details.
#-----------------------------------------------------------



#-----------------------------------------------------------
$(call shell.names.define,ash,posix)
#-----------------------------------------------------------
# Ash is the shell function of the busybox multitool.
# Default shell in many small distros like Alpine Linux.
#-----------------------------------------------------------
shell.names.ash.path.default := busybox
  shell.names.ash.path.unix := busybox
    shell.names.ash.path.alpine := /bin/busybox
shell.names.ash.flags.default :=
shell.names.ash.aliases.default := ash busybox



#-----------------------------------------------------------
$(call shell.names.define,cmd,cmd)
#-----------------------------------------------------------
# Default Windows command interpreter.
#
# This definition just defers to the defaults for cmd-type shells.
# See definion of shell.types.cmd for details.
#-----------------------------------------------------------



#-----------------------------------------------------------
$(call shell.names.define,powershell,powershell)
# PowerShell is generally a better alternative to cmd.exe.
#-----------------------------------------------------------
# This definition just defers to the defaults for PowerShell-type shells.
# See definion of shell.types.powershell for details.
#-----------------------------------------------------------



#-----------------------------------------------------------
$(call shell.names.define,msys,posix)
# MSYS is a POSIX-compliant shell for Windows.
#-----------------------------------------------------------
shell.names.msys.path.default :=
shell.names.msys.flags.default :=



#-----------------------------------------------------------
$(call shell.names.define,cygwin,posix)
# Cygwin is a POSIX-compliant shell for Windows.
#-----------------------------------------------------------
shell.names.cygwin.path.default :=
shell.names.cygwin.flags.default :=



#-----------------------------------------------------------
$(call shell.names.define,python,python)
# Run Python syntax directly from make recipes!
#-----------------------------------------------------------
# This definition just defers to the defaults for Python-type shells.
# See definition of shell.types.python for details.
#-----------------------------------------------------------



#===============================================================================
# shell.types.*
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
#	shell.types.{type}.{prop}
#
# Each top-level property is its own namespace, and the property's value is
# determined by the contents of its namespace, which are fully user-writeable:
#
#	shell.types.{type}.{prop}.*
#
# Property value is assigned as the first non-empty string, in order:
#
#	1. shell.types.{type}.{prop}.{OS_name}    1st priority, if $(os.name) matches
#	2. shell.types.{type}.{prop}.{OS_type}    2nd priority, if $(os.type) matches
#	3. shell.types.{type}.{prop}.default      3rd priority
#
# User should define as many of 1,2,3 as are applicable to the shell configuration.
#===============================================================================

#-----------------------------------------------------------
# $(call shell.types.define,{name})
#-----------------------------------------------------------
shell.types := $(EMPTY)
define shell.types.define
$(eval shell.types += $(1))
$(eval shell.types.$(1).isactive = $$(if $$(filter $(1),$$(shell.type)),$(TRUE.m),$(FALSE.m)))
$(eval shell.types.$(1).print = $$(call print.var,$(foreach prop,$(shell.types.properties),shell.types.$(1).$(prop))))
$(foreach prop,$(filter-out isactive print,$(shell.types.properties)),$(call variable.set_with_alternatives,shell.types.$(1).$(prop),?=,,  shell.types.$(1).$(prop).$$(os.name)  shell.types.$(1).$(prop).$$(os.type)  shell.types.$(1).$(prop).default  shell.types.$(2).$(prop)  ))
endef



#-----------------------------------------------------------
$(call shell.types.define,unknown)
#-----------------------------------------------------------
# Sensible defaults for when the shell type is unknown.
#-----------------------------------------------------------
shell.types.unknown.path.default :=
shell.types.unknown.flags.default :=
shell.types.unknown.aliases.default :=
shell.types.unknown.sep.path.default := $(os.sep.path)
shell.types.unknown.sep.list.default := $(os.sep.list)
shell.types.unknown.ext.script.default :=



#-----------------------------------------------------------
$(call shell.types.define,posix)
#-----------------------------------------------------------
# Syntax definitions and default launch config for POSIX-type shells.
#
# Flags:
#	-e                 Exit immediately if any command line fails
#	-c                 Make appends the command line after this
#-----------------------------------------------------------
shell.types.posix.path.default := sh
  shell.types.posix.path.windows :=
  shell.types.posix.path.unix :=
shell.types.posix.flags.default := -ec
  shell.types.posix.flags.windows :=
  shell.types.posix.flags.unix :=
shell.types.posix.aliases.default := sh sh.exe
  shell.types.posix.aliases.windows :=
  shell.types.posix.aliases.unix :=
shell.types.posix.sep.path.default := $(FSLASH)
  shell.types.posix.sep.path.windows :=
  shell.types.posix.sep.path.unix :=
shell.types.posix.sep.list.default := $(COLON)
  shell.types.posix.sep.list.windows :=
  shell.types.posix.sep.list.unix :=
shell.types.posix.ext.script.default := .sh



#-----------------------------------------------------------
$(call shell.types.define,cmd)
#-----------------------------------------------------------
# Syntax definitions and default launch config for Windows cmd.exe.
#
# Flags: must appear in a specific order or they get ignored by cmd.exe! Not sure why.
#	/Q                 Disable command echoing; make does this already
#	/D                 Skip execution of registry AutoRun commands at startup
#	/E:ON              Enable Command Extensions; typical default behavior of CMD anyway
#	/V:OFF             Disable delayed expansion; reduces problems with '!' and other special characters
#	/S                 Simpler, more reliable parsing of doublequotes '"'
#	/C                 Make appends the command line after this
#-----------------------------------------------------------
shell.types.cmd.path.default := cmd
  shell.types.cmd.path.windows := cmd.exe
  shell.types.cmd.path.unix :=
shell.types.cmd.flags.default := /Q /D /E:ON /V:OFF /S /C
  shell.types.cmd.flags.windows :=
  shell.types.cmd.flags.unix :=
shell.types.cmd.aliases.default := cmd cmd.exe
  shell.types.cmd.aliases.windows :=
  shell.types.cmd.aliases.unix :=
shell.types.cmd.sep.path.default := $(BSLASH)
  shell.types.cmd.sep.path.windows :=
  shell.types.cmd.sep.path.unix :=
shell.types.cmd.sep.list.default := $(SEMICOLON)
  shell.types.cmd.sep.list.windows :=
  shell.types.cmd.sep.list.unix :=
shell.types.cmd.ext.script.default := .bat



#-----------------------------------------------------------
$(call shell.types.define,powershell)
#-----------------------------------------------------------
# Syntax definitions and default launch config for PowerShell.
#
# Flags:
#	-NoProfile         Skip reading profile.ps1 scripts at startup
#	-Command           Make appends the command line after this
#-----------------------------------------------------------
shell.types.powershell.path.default := powershell
  shell.types.powershell.path.windows := powershell.exe
  shell.types.powershell.path.unix := pwsh
shell.types.powershell.flags.default := -NoProfile -Command
  shell.types.powershell.flags.windows :=
  shell.types.powershell.flags.unix :=
shell.types.powershell.aliases.default :=
  shell.types.powershell.aliases.windows := powershell.exe pwsh.exe
  shell.types.powershell.aliases.unix := powershell pwsh
shell.types.powershell.sep.path.default := $(os.sep.path)
  shell.types.powershell.sep.path.windows :=
  shell.types.powershell.sep.path.unix :=
shell.types.powershell.sep.list.default := $(os.sep.list)
  shell.types.powershell.sep.list.windows :=
  shell.types.powershell.sep.list.unix :=
shell.types.powershell.ext.script.default := .ps1



#-----------------------------------------------------------
$(call shell.types.define,python)
#-----------------------------------------------------------
# Syntax definitions and default launch config for Python.
#
# Flags:
#	-q                 Dont print version and copyright messages
#	-c                 Make appends the command line after this
#-----------------------------------------------------------
shell.types.python.path.default := python
  shell.types.python.path.windows = python.exe
  shell.types.python.path.unix = python
    shell.types.python.path.ubuntu = python3
shell.types.python.flags.default := -q -c
  shell.types.python.flags.windows :=
  shell.types.python.flags.unix :=
shell.types.python.aliases.default :=
  shell.types.python.aliases.windows := python.exe python3.exe py.exe
  shell.types.python.aliases.unix := python python3
shell.types.python.sep.path.default := $(os.sep.path)
  shell.types.python.sep.path.windows :=
  shell.types.python.sep.path.unix :=
shell.types.python.sep.list.default := $(os.sep.list)
  shell.types.python.sep.list.windows :=
  shell.types.python.sep.list.unix :=
shell.types.python.ext.script.default := .py


#-----------------------------------------------------------
# An interesting test
#-----------------------------------------------------------
#
# $(info )
# $(call shell.print)
# $(info )
# $(call shell.names.cmd.activate)
# $(call shell.print)
# $(info )
# $(info $(shell echo Is this cmd.exe? cmdcmdline=$(PERCENT)cmdcmdline$(PERCENT)))
# $(info )
# $(call shell.names.powershell.activate)
# $(call shell.print)
# $(info )
# $(info $(shell Write-Output 'Is this powershell? $(DOLLAR)MyInvocation='; $(DOLLAR)MyInvocation))
# $(info )
# $(call shell.names.bash.activate)
# $(call shell.print)
# $(info )
# $(info $(shell echo $(DQUOTE)Is this bash? $(DOLLAR)0 -$(DOLLAR)- $(DOLLAR)SHELLOPTS $(DOLLAR)* $(DQUOTE)))
# $(info )
# $(call shell.names.python.activate)
# $(call shell.print)
# $(info )
# $(info $(shell import sys; print$(OPAREN)$(DQUOTE)Is this python? sys.argv[0]=[$(DQUOTE)+sys.argv[0]+$(DQUOTE)]$(DQUOTE)$(CPAREN)))
# $(info )
# $(error Exiting here.)






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


