.DEFAULT_GOAL := help

ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# Default paths
MANIFEST ?= $(ROOT_DIR)/dotfiles/manifest.tsv
STATE_DIR ?= $(ROOT_DIR)/state

.PHONY: help
help:
	@echo "march - Personal Arch Linux setup toolkit"
	@echo ""
	@echo "Quick start:"
	@echo "  make setup          Export packages + apply dotfiles"
	@echo ""
	@echo "Dotfiles:"
	@echo "  make dotfiles       Apply repo dotfiles to ~/ (interactive)"
	@echo "  make dotfiles-pull  Capture ~/ dotfiles to repo"
	@echo "  make dotfiles-diff  Check for drift between repo and ~/"
	@echo ""
	@echo "Packages:"
	@echo "  make packages       Install packages from state/"
	@echo "  make packages-pull  Export current packages + services to state/"
	@echo "  make packages-diff  Compare current packages + services to state/"
	@echo ""
	@echo "Docs:"
	@echo "  make docs           Serve MkDocs site locally"
	@echo ""
	@echo "Options:"
	@echo "  DRY_RUN=1           Show what would be done"
	@echo "  YES=1               Skip confirmations"
	@echo "  NOCONFIRM=1         Skip pacman confirmations"
	@echo "  NO_AUR=1            Skip AUR packages"
	@echo "  AUR_HELPER=paru     Use paru instead of yay"
	@echo ""
	@echo "Examples:"
	@echo "  make dotfiles YES=1"
	@echo "  make packages DRY_RUN=1"
	@echo "  make packages-pull"

.PHONY: setup
setup: packages-pull dotfiles

.PHONY: dotfiles
dotfiles:
	$(ROOT_DIR)/scripts/dotfiles.sh --push $(if $(YES),--yes) $(if $(DRY_RUN),--dry-run)

.PHONY: dotfiles-pull
dotfiles-pull:
	$(ROOT_DIR)/scripts/dotfiles.sh --pull $(if $(YES),--yes) $(if $(DRY_RUN),--dry-run)

.PHONY: dotfiles-diff
dotfiles-diff:
	$(ROOT_DIR)/scripts/dotfiles.sh --push --check

.PHONY: packages-pull
packages-pull:
	$(ROOT_DIR)/scripts/packages.sh export

.PHONY: packages-diff
packages-diff:
	@tmp_dir="$$(mktemp -d)"; \
	trap 'rm -rf "$$tmp_dir"' EXIT; \
	$(ROOT_DIR)/scripts/packages.sh export --state-dir "$$tmp_dir"; \
	if [ -d "$(STATE_DIR)" ]; then \
	  diff -ru "$(STATE_DIR)" "$$tmp_dir"; \
	else \
	  diff -ru /dev/null "$$tmp_dir"; \
	fi

.PHONY: packages
packages:
	$(ROOT_DIR)/scripts/packages.sh install $(if $(DRY_RUN),--dry-run) $(if $(NOCONFIRM),--noconfirm) $(if $(NO_AUR),--no-aur) $(if $(AUR_HELPER),--aur-helper $(AUR_HELPER))

.PHONY: docs
docs: docs-serve

.PHONY: docs-serve
docs-serve:
	$(ROOT_DIR)/scripts/docs.sh sync
	$(ROOT_DIR)/scripts/docs.sh serve

.PHONY: clean
clean:
	$(ROOT_DIR)/scripts/docs.sh clean
	rm -rf "$(STATE_DIR)"
