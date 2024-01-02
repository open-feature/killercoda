ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
.PHONY: linkcheck

linkcheck:
	find . -name \*.md -print0 | xargs -0 -n1 docker run --rm -i -v $(CURDIR):/tmp -w /tmp ghcr.io/tcort/markdown-link-check:stable -c .markdown-link-check.json
