#===============================================================================
# makefile
#
# Minimal makefile which can be extended and specialized on a per-project basis
# by adding additional makefiles to the MAKE_DIR
#
#===============================================================================
.PHONY: $(notdir $(lastword $(MAKEFILE_LIST)))

# Import paths
MAKE_DIR = .project/make
MAKE_TARGETS_DIR = $(MAKE_DIR)/targets

# Libraries
include $(MAKE_DIR)/lib.common.mak
#include $(MAKE_DIR)/lib.help.mak
#include $(MAKE_DIR)/lib.platform.mak

# Project-specific configuration
# include $(MAKE_DIR)/config.mak


# Target definitions
# include $(sort $(wildcard $(MAKE_TARGETS_DIR)/*.mak))

