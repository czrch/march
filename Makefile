.DEFAULT_GOAL := help

ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

MANIFEST ?= $(ROOT_DIR)/dotfiles/manifest.tsv
STATE_DIR ?= $(ROOT_DIR)/state

YES ?= 0
DRY_RUN ?= 0
CHECK ?= 0
NOCONFIRM ?= 0

NO_AUR ?= 0
AUR_HELPER ?=

DOTFILES_FLAGS :=
ifeq ($(YES),1)
	DOTFILES_FLAGS += --yes
endif
ifeq ($(DRY_RUN),1)
	DOTFILES_FLAGS += --dry-run
endif
ifeq ($(CHECK),1)
	DOTFILES_FLAGS += --check
endif

PACKAGES_FLAGS :=
ifeq ($(DRY_RUN),1)
	PACKAGES_FLAGS += --dry-run
endif
ifeq ($(NOCONFIRM),1)
	PACKAGES_FLAGS += --noconfirm
endif
ifeq ($(NO_AUR),1)
	PACKAGES_FLAGS += --no-aur
endif
ifneq ($(strip $(AUR_HELPER)),)
	PACKAGES_FLAGS += --aur-helper $(AUR_HELPER)
endif

.PHONY: help
help:
	@printf "%s\n" \
	  "march (Makefile)" \
	  "" \
	  "Common:" \
	  "  make dotfiles-push         Apply repo dotfiles -> \$$HOME" \
	  "  make dotfiles-pull         Capture \$$HOME dotfiles -> repo" \
	  "  make dotfiles-check        Check drift (fails if differs)" \
	  "  make dotfiles-status       Show drift + summary (always succeeds)" \
	  "  make dotfiles-list         Print manifest entries" \
	  "" \
	  "  make export                Export packages + services into state/" \
	  "  make export-packages       Export packages only" \
	  "  make export-services       Export enabled services only" \
	  "" \
	  "  make packages              Install pacman + AUR packages from state/" \
	  "  make packages-pacman       Install pacman packages only" \
	  "  make packages-aur          Install AUR packages only" \
	  "" \
	  "  make docs-sync             uv sync (set up docs tooling)" \
	  "  make docs-serve            Serve MkDocs site locally" \
	  "  make docs-build            Build static site into ./site/" \
	  "  make docs-clean            Remove ./site and ./.mkdocs_cache" \
	  "" \
	  "Options (examples):" \
	  "  make dotfiles-push YES=1" \
	  "  make dotfiles-push DRY_RUN=1" \
	  "  make packages DRY_RUN=1" \
	  "  make packages NOCONFIRM=1" \
	  "  make packages AUR_HELPER=paru" \
	  "" \
	  "Vars:" \
	  "  MANIFEST=$(MANIFEST)" \
	  "  STATE_DIR=$(STATE_DIR)"

.PHONY: dotfiles-push dotfiles-pull dotfiles-check dotfiles-status dotfiles-list
dotfiles-push:
	@$(ROOT_DIR)/scripts/sync-dotfiles.sh --push --manifest "$(MANIFEST)" $(DOTFILES_FLAGS)

dotfiles-pull:
	@$(ROOT_DIR)/scripts/sync-dotfiles.sh --pull --manifest "$(MANIFEST)" $(DOTFILES_FLAGS)

dotfiles-check:
	@$(ROOT_DIR)/scripts/sync-dotfiles.sh --push --manifest "$(MANIFEST)" --check

dotfiles-status:
	@set +e; \
	$(ROOT_DIR)/scripts/sync-dotfiles.sh --push --manifest "$(MANIFEST)" --check; \
	rc="$$?"; \
	if [ "$$rc" -eq 0 ]; then \
	  echo "Status: OK (no drift)"; \
	else \
	  echo "Status: DRIFT DETECTED (ignored exit $$rc)"; \
	  echo "Hint: run 'make dotfiles-check' for a failing exit code, or 'make dotfiles-push YES=1' / 'make dotfiles-pull YES=1' to resolve."; \
	fi; \
	exit 0

dotfiles-list:
	@$(ROOT_DIR)/scripts/sync-dotfiles.sh --manifest "$(MANIFEST)" --list

.PHONY: export export-packages export-services
export:
	@$(ROOT_DIR)/scripts/export.sh all

export-packages:
	@$(ROOT_DIR)/scripts/export.sh packages

export-services:
	@$(ROOT_DIR)/scripts/export.sh services

.PHONY: packages packages-pacman packages-aur
packages:
	@$(ROOT_DIR)/scripts/install-packages.sh all --state-dir "$(STATE_DIR)" $(PACKAGES_FLAGS)

packages-pacman:
	@$(ROOT_DIR)/scripts/install-packages.sh pacman --state-dir "$(STATE_DIR)" $(PACKAGES_FLAGS)

packages-aur:
	@$(ROOT_DIR)/scripts/install-packages.sh aur --state-dir "$(STATE_DIR)" $(PACKAGES_FLAGS)

.PHONY: docs-sync docs-serve docs-build docs-clean
docs-sync:
	@$(ROOT_DIR)/scripts/docs.sh sync

docs-serve:
	@$(ROOT_DIR)/scripts/docs.sh serve

docs-build:
	@$(ROOT_DIR)/scripts/docs.sh build

docs-clean:
	@$(ROOT_DIR)/scripts/docs.sh clean

.PHONY: clean-state
clean-state:
	@rm -rf -- "$(STATE_DIR)"
