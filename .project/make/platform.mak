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


#-----------------------------------------------------------
# Special Characters
#-----------------------------------------------------------

EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
TAB := $(EMPTY)	$(EMPTY)
COMMA := ,
PERCENT := %$(EMPTY)
BACKSLASH := \$(EMPTY)
POUND := \#
DOLLAR := $$
OPAREN := ($(EMPTY)
CPAREN := )$(EMPTY)
define LF


endef


#### SHELL PREFERENCES

CMD := cmd.exe
POWERSHELL := powershell.exe
SH := /bin/sh
BASH := /usr/bin/env bash
PWSH := /usr/bin/env pwsh

WINDOWS_SHELL_PREFERENCE := $(CMD)
UNIX_SHELL_PREFERENCE := $(BASH)


#### DETECT OS

## Windows
ifeq "$(OS)" "Windows_NT"
    OS_TYPE := WINDOWS

## UNIX-like (Linux, BSD, etc)
else
    OS_TYPE := UNIX
endif


#### DETECT SHELL

## Windows Shells
ifeq "$(SHLVL)" ""
    # Apply Windows shell preference
    SHELL := $(WINDOWS_SHELL_PREFERENCE)

    # Detect Windows shell types
ifeq "$(findstring powershell, $(SHELL))" "powershell"
    SHELL_TYPE := POWERSHELL
    .SHELLFLAGS := -NoProfile -Command
else
ifeq "$(findstring pwsh, $(SHELL))" "pwsh"
    SHELL_TYPE := POWERSHELL
    .SHELLFLAGS := -NoProfile -Command
else
ifeq "$(findstring cmd, $(SHELL))" "cmd"
    SHELL_TYPE := CMD
    .SHELLFLAGS := /Q /D /E:ON /V:OFF /S /C
else  # Default
    SHELL_TYPE := CMD
    .SHELLFLAGS := /Q /D /E:ON /V:OFF /S /C
endif
endif
endif

## UNIX Shells
else
    # Apply UNIX shell preference
    SHELL := $(UNIX_SHELL_PREFERENCE)

    # Detect UNIX shell types
ifeq "$(findstring pwsh, $(SHELL))" "pwsh"
    SHELL_TYPE := POWERSHELL
    .SHELLFLAGS := -NoProfile -Command
else
ifeq "$(findstring bash, $(SHELL))" "bash"
    SHELL_TYPE := POSIX
    .SHELLFLAGS := --noprofile --norc --posix -e -c
else
ifeq "$(findstring sh, $(SHELL))" "sh"
    SHELL_TYPE := POSIX
    .SHELLFLAGS := -e -c
else  # Default
    SHELL_TYPE := POSIX
    .SHELLFLAGS := -e -c
endif
endif
endif

endif


#### OS PROPERTIES
# Apply when expanding environment variables in Make or interacting directly with the OS

ifeq "$(OS_TYPE)" "WINDOWS"
    OS_FILESEP := $(BACKSLASH)
    OS_PATHSEP := ;
    EXEC_EXT := .exe
    LIB_EXT := .lib
    DLL_EXT := .dll
endif
ifeq "$(OS_TYPE)" "UNIX"
    OS_FILESEP := /
    OS_PATHSEP := :
    EXEC_EXT :=
    LIB_EXT := .a
    DLL_EXT := .so
endif


#### SHELL PROPERTIES
# Apply when running shell commands or shell scripts from Make

ifeq "$(SHELL_TYPE)" "CMD"
    FILESEP := $(BACKSLASH)
    PATHSEP := ;
    SCRIPT_EXT := .bat
    CMDSEP := &
endif
ifeq "$(SHELL_TYPE)" "POWERSHELL"
    FILESEP := $(BACKSLASH)
    PATHSEP := ;
    SCRIPT_EXT := .ps1
    CMDSEP := ;
endif
ifeq "$(SHELL_TYPE)" "POSIX"
    FILESEP := /
    PATHSEP := :
    SCRIPT_EXT := .sh
    CMDSEP := ;
endif


#### SHELL COMMANDS
# Path arguments can be specified with "/" or "\" and will be automatically corrected for the platform.
#
# $(call nop)                        Runs a shell command which does nothing. Useful for suppressing "Nothing to be done for target" messages.
# $(call errlvl,{num})               Set's the shell's error level. 0 is success, 1+ is failure.
# $(call echo,{string})              Prints the string
# $(call line)                       Print an empty line
# $(call ls,{path})                  Lists files under the given path
# $(call chmod,{args},{path})        Standard POSIX chmod. Calls "nop" on non-posix systems.
# $(call mkdir,{path})               Creates the directory, if it doesn't already exist.
# $(call rm,{path})                  Deletes a file, if it exists.
# $(call rmdir,{path})               Deletes a directory, if it exists.
# $(call copy,{src},{dst})           Copies {src} file to {dst}.
#                                      If {dst} does not exist, creates new file {dst}.
#                                      If {dst} is a file, overwrites.
#                                      If {dst} is a directory, creates new file {dst}/basename({src})
# $(call copydir,{src},{dst})        Copies {src} directory and its contents to {dst}.
#                                      If {dst} does not exist, creates new directory {dst}.
#                                      If {dst} is a directory, copies the CONTENTS of {src} into {dst}, overwriting files as necessary.
#
# $(call subshell,$(call COMMAND))   Runs the shell command in a subshell process.
# $(call and,$(call ...),$(call ...))  Runs two or more commands in sequence.

ifeq "$(SHELL_TYPE)" "CMD"
    SILENT := 1>nul
    nop = echo 1>nul
    errlvl = $(call subshell,exit $(1))
    echo = $(call subshell,echo$(OPAREN)$(1))
    line = $(call echo,)
    ls = dir /b "$(call mkpath,$(1))"
    chmod = $(NOP)
    mkdir = if not exist "$(call mkpath,$(1))\" ( mkdir "$(call mkpath,$(1))" )
    rm = if exist "$(call mkpath,$(1))" ( del /f /q "$(call mkpath,$(1))" )
    rmdir = if exist "$(call mkpath,$(1))\" ( rmdir /s /q "$(call mkpath,$(1))" )
    copy = xcopy /Y /I /-I "$(call mkpath,$(1))" "$(call mkpath,$(2))"
    copydir = xcopy /Y /I /E "$(call mkpath,$(1))" "$(call mkpath,$(2))"
    subshell = $(SHELL) $(.SHELLFLAGS) "$(1)"
    and = $(OPAREN)$(call concatargs,$(CPAREN) $(CMDSEP) $(OPAREN),$(1),$(2),$(3),$(4),$(5),$(6),$(7),$(8))$(CPAREN)
endif
ifeq "$(SHELL_TYPE)" "POWERSHELL"
    SILENT :=
    nop = ? .
    errlvl = $(error Function "errlvl" is not implemented for SHELL_TYPE=$(SHELL_TYPE). See platform.mak for details.)
    echo = Write-Output '$(1)'
    line = Write-Output ''
    ls = Get-ChildItem -Name '$(call mkpath,$(1))'
    chmod = $(NOP)
    mkdir = New-Item -ItemType Directory -Force -Path '$(call mkpath,$(1))'
    rm = Remove-Item -Force -Path '$(call mkpath,$(1))'
    rmdir = Remove-Item -Force -Recurse -Path '$(call mkpath,$(1))'
    copy = $(error Function "copy" is not implemented for SHELL_TYPE=$(SHELL_TYPE). See platform.mak for details.)
    copydir = $(error Function "copydir" is not implemented for SHELL_TYPE=$(SHELL_TYPE). See platform.mak for details.)
    subshell = $(SHELL) $(.SHELLFLAGS) "$(1)"
endif
ifeq "$(SHELL_TYPE)" "POSIX"
    SILENT := > /dev/null
    nop = :
    errlvl = $(call subshell,exit $(1))
    echo = echo "$(1)"
    line = $(call echo,)
    ls = ls -A -1 --color=no "$(call mkpath,$(1))"
    chmod = chmod $(1) "$(call mkpath,$(2))"
    mkdir = mkdir -p "$(call mkpath,$(1))"
    rm = rm -f "$(call mkpath,$(1))"
    rmdir = rm -rf "$(call mkpath,$(1))"
    copy = cp -f "$(call mkpath,$(1))" "$(call mkpath,$(2))"
    copydir = cp -rf "$(call mkpath,$(1))/." "$(call mkpath,$(2))"
    subshell = $(SHELL) $(.SHELLFLAGS) "$(1)"
endif


#$(info OS_TYPE:     $(OS_TYPE))
#$(info SHELL_TYPE:  $(SHELL_TYPE))
#$(info SHELL:       $(SHELL) $(.SHELLFLAGS))




#===============================================================================
# UPSTREAM: CURRENT PROJECT
#===============================================================================


