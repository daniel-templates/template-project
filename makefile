#===============================================================================
# makefile
#
# Minimal makefile which can be extended and specialized on a per-project basis
# by adding additional makefiles to the MAKE_DIR
#
#===============================================================================

# Import paths
MAKE_DIR = .project/make
MAKE_TARGETS_DIR = $(MAKE_DIR)/targets

# Libraries
include $(MAKE_DIR)/lib.mak
include $(MAKE_DIR)/lib.help.mak
include $(MAKE_DIR)/lib.platform.mak

# Project-specific configuration
include $(MAKE_DIR)/config.mak

# Set default target (override value in config.mak, not here)
ifdef DEFAULT_TARGET
$(DEFAULT_TARGET):
endif

# Target definitions
include $(sort $(wildcard $(MAKE_TARGETS_DIR)/*.mak))

