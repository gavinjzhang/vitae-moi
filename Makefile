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

# Tailor variables (for per-application builds)
COMPANY ?=
ROLE_SHORT ?=
DATE ?= $(shell date +%Y-%m-%d)

.PHONY: all cv resume cover-letter open open-cv open-resume open-cover-letter watch-cv watch-resume watch-cover-letter tailor tailor-open clean

# Build everything that has a .tex next to it
all: $(PDFS)

# Explicit convenience targets
cv: cv.pdf
resume: resume.pdf
cover-letter: cover-letter.pdf

# Tailored build: copies sources with suffix and compiles PDFs into ./$(COMPANY)/
tailor:
ifndef COMPANY
	$(error Set COMPANY, e.g., make tailor COMPANY=Acme ROLE_SHORT=Sr-DS)
endif
ifndef ROLE_SHORT
	$(error Set ROLE_SHORT, e.g., make tailor COMPANY=Acme ROLE_SHORT=Sr-DS)
endif
	@set -e; \
	RESUME_TEX="resume-$(COMPANY)-$(ROLE_SHORT)-$(DATE).tex"; \
	CL_TEX="cover-letter-$(COMPANY)-$(ROLE_SHORT)-$(DATE).tex"; \
	mkdir -p "$(COMPANY)"; \
	if [ "$(FORCE_COPY)" = "1" ] || [ ! -f "$(COMPANY)/$$RESUME_TEX" ]; then \
	  cp -f resume.tex "$(COMPANY)/$$RESUME_TEX"; \
	  echo "Copied source -> $(COMPANY)/$$RESUME_TEX"; \
	else \
	  echo "Keeping existing $(COMPANY)/$$RESUME_TEX (set FORCE_COPY=1 to overwrite)"; \
	fi; \
	if [ "$(FORCE_COPY)" = "1" ] || [ ! -f "$(COMPANY)/$$CL_TEX" ]; then \
	  cp -f cover-letter.tex "$(COMPANY)/$$CL_TEX"; \
	  echo "Copied source -> $(COMPANY)/$$CL_TEX"; \
	else \
	  echo "Keeping existing $(COMPANY)/$$CL_TEX (set FORCE_COPY=1 to overwrite)"; \
	fi; \
if [ -z "$(LATEXMK)" ]; then \
	echo "Building $(COMPANY)/$${RESUME_TEX%.tex}.pdf ..."; \
	$(PDFLATEX) $(LATEXFLAGS) -output-directory "$(COMPANY)" "$(COMPANY)/$$RESUME_TEX" >/dev/null || true; \
	$(PDFLATEX) $(LATEXFLAGS) -output-directory "$(COMPANY)" "$(COMPANY)/$$RESUME_TEX"; \
	echo "Building $(COMPANY)/$${CL_TEX%.tex}.pdf ..."; \
	$(PDFLATEX) $(LATEXFLAGS) -output-directory "$(COMPANY)" "$(COMPANY)/$$CL_TEX" >/dev/null || true; \
	$(PDFLATEX) $(LATEXFLAGS) -output-directory "$(COMPANY)" "$(COMPANY)/$$CL_TEX"; \
else \
	echo "Building $(COMPANY)/$${RESUME_TEX%.tex}.pdf ..."; \
	latexmk -pdf -outdir="$(COMPANY)" $(LATEXFLAGS) "$(COMPANY)/$$RESUME_TEX"; \
	echo "Building $(COMPANY)/$${CL_TEX%.tex}.pdf ..."; \
	latexmk -pdf -outdir="$(COMPANY)" $(LATEXFLAGS) "$(COMPANY)/$$CL_TEX"; \
fi; \
	echo "Saved sources: $(COMPANY)/$$RESUME_TEX and $(COMPANY)/$$CL_TEX"; \
	echo "Done: $(COMPANY)/$${RESUME_TEX%.tex}.pdf"; \
	echo "Done: $(COMPANY)/$${CL_TEX%.tex}.pdf"

tailor-open: tailor
ifndef COMPANY
	$(error Set COMPANY, e.g., make tailor-open COMPANY=Acme ROLE_SHORT=Sr-DS)
endif
ifndef ROLE_SHORT
	$(error Set ROLE_SHORT, e.g., make tailor-open COMPANY=Acme ROLE_SHORT=Sr-DS)
endif
	@RESUME_PDF="$(COMPANY)/resume-$(COMPANY)-$(ROLE_SHORT)-$(DATE).pdf"; \
	CL_PDF="$(COMPANY)/cover-letter-$(COMPANY)-$(ROLE_SHORT)-$(DATE).pdf"; \
	$(OPEN) "$$RESUME_PDF"; \
	$(OPEN) "$$CL_PDF"

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

open-cover-letter: cover-letter
	@$(OPEN) cover-letter.pdf

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

watch-cover-letter:
ifeq ($(LATEXMK),)
	@echo "Install latexmk to use watch targets" && exit 1
else
	@latexmk -pdf -pvc $(LATEXFLAGS) cover-letter.tex
endif

# Cleanup
clean:
ifeq ($(LATEXMK),)
	@rm -f *.aux *.log *.out *.toc *.bbl *.blg *.fdb_latexmk *.fls
else
	@latexmk -C
endif
