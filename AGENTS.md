# Repository Guidelines

## Project Structure & Module Organization
- Root contains LaTeX sources: `cv.tex`, `resume.tex`.
- Generated artifacts: `*.pdf`, `*.aux`, `*.log`, `*.out` (created by builds). Do not edit by hand; prefer regenerating via `make`.
- Optional assets (images, logos) should live under `assets/` with lowercase, hyphenated names (e.g., `assets/company-logo.png`).

## Build, Test, and Development Commands
- `make` or `make all` — Build PDFs for all `*.tex` files.
- `make cv` / `make resume` — Build `cv.pdf` or `resume.pdf` respectively.
- `make open` / `make open-cv` / `make open-resume` — Build then open the PDF (uses `open` on macOS, `xdg-open` on Linux).
- `make watch-cv` / `make watch-resume` — Rebuild on save (requires `latexmk`).
- `make clean` — Remove intermediate files; with `latexmk` installed, performs a full clean.
Notes: Uses `latexmk` when available; otherwise falls back to `pdflatex` with two passes.

## Coding Style & Naming Conventions
- LaTeX: use consistent indentation (2 spaces recommended), wrap lines at ~100 chars where practical, and prefer semantic structuring (sections, commands) over manual spacing.
- Comment intent with `%` above non-obvious blocks; keep the preamble organized (packages, custom commands grouped logically).
- Filenames: keep `cv.tex` and `resume.tex`. Place images under `assets/` and reference with relative paths.

## Testing Guidelines
- No unit tests; builds must complete without errors. Run `make cv` and/or `make resume` and review the log.
- Aim to eliminate or justify Overfull/Underfull boxes. Visually verify spacing, section breaks, links, and page count in the resulting PDFs.
- Target a reproducible toolchain (TeX Live 2021+ or MacTeX equivalent).

## Commit & Pull Request Guidelines
- Commits: imperative mood, concise scope, and meaningful subject (e.g., `feat(cv): add publications section`, `fix(build): silence latexmk warning`).
- Pull Requests: include a short description of changes, screenshots or the resulting `*.pdf` if layout changes, and link any related issues.
- Keep changes small and focused. Do not commit `*.aux`/`*.log`. Committing `*.pdf` is acceptable for review, but regenerate via `make` when merging.

## Agent-Specific Instructions
- Edit only source files (`*.tex`, `Makefile`). Never hand-edit generated artifacts.
- Prefer minimal dependencies; do not introduce non-TeX build steps. Follow the Make targets above.
