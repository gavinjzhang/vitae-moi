## Generic Makefile to build cv and resume PDFs

# Tool detection
LATEXMK := $(shell command -v latexmk 2>/dev/null)
PDFLATEX ?= pdflatex
LATEXFLAGS ?= -interaction=nonstopmode -file-line-error -halt-on-error

# OS-specific opener
UNAME_S := $(shell uname 2>/dev/null)
ifeq ($(UNAME_S),Darwin)
  OPEN ?= open
else
  OPEN ?= xdg-open
endif

# Source and outputs
TEXS := $(wildcard *.tex)
PDFS := $(TEXS:.tex=.pdf)

.PHONY: all cv resume open open-cv open-resume watch-cv watch-resume clean

# Build everything that has a .tex next to it
all: $(PDFS)

# Explicit convenience targets
cv: cv.pdf
resume: resume.pdf

# Pattern rule to build any .tex into .pdf
%.pdf: %.tex
ifeq ($(LATEXMK),)
	@echo "Building $@ ..."
	@$(PDFLATEX) $(LATEXFLAGS) "$<" >/dev/null || true
	@$(PDFLATEX) $(LATEXFLAGS) "$<"
	@echo "Done: $@"
else
	@echo "Building $@ ..."
	@latexmk -pdf $(LATEXFLAGS) "$<"
	@echo "Done: $@"
endif

# Openers
open: open-cv

open-cv: cv
	@$(OPEN) cv.pdf

open-resume: resume
	@$(OPEN) resume.pdf

# File watchers (latexmk required)
watch-cv:
ifeq ($(LATEXMK),)
	@echo "Install latexmk to use watch targets" && exit 1
else
	@latexmk -pdf -pvc $(LATEXFLAGS) cv.tex
endif

watch-resume:
ifeq ($(LATEXMK),)
	@echo "Install latexmk to use watch targets" && exit 1
else
	@latexmk -pdf -pvc $(LATEXFLAGS) resume.tex
endif

# Cleanup
clean:
ifeq ($(LATEXMK),)
	@rm -f *.aux *.log *.out *.toc *.bbl *.blg *.fdb_latexmk *.fls
else
	@latexmk -C
endif
