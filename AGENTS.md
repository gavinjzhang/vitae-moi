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

## Tailoring Workflow (AI Assistants)
The user will paste job descriptions and ask you to tailor both the resume and the cover letter for a specific role and company, then produce compiled PDFs with a descriptive suffix.

What to do
- Parse the pasted job description and extract:
  - `Company` (canonical short form, e.g., `Acme` not `Acme, Inc.`)
  - `Role` (e.g., `Senior Data Scientist`)
  - Key responsibilities, qualifications, and keywords to reflect in the content

- Update sources before compiling:
  - `resume.tex`: adjust bullet points and highlights to match the job’s requirements; keep truthful content, emphasize relevant impact, and trim irrelevant details.
  - `cover-letter.tex`:
    - Set `\CompanyName{...}` and other recipient fields if provided.
    - Update `\LetterSubject` to `Application for <Role>`.
    - Rewrite the intro line and highlights to mirror the role and top requirements.
    - Keep spacing and macro safety (escape `& % # $ _ { } ~ ^ \`).

- Filename suffix convention when compiling tailored versions:
  - `-[Company]-[RoleShort]-[Date]`
  - `Date`: `YYYY-MM-DD`
  - `RoleShort`: abbreviated form, e.g.:
    - Senior → `Sr`, Staff → `Stf`, Principal → `Prin`
    - Machine Learning → `ML`, Data Scientist → `DS`, Engineer → `Eng`, Manager → `Mgr`
    - Example: `Senior Data Scientist` → `Sr-DS`

How to produce the tailored PDFs
- Preferred: use the Makefile helper which also saves the .tex copies into a company-specific folder and compiles there.
  ```sh
  make tailor COMPANY="Acme" ROLE_SHORT="Sr-DS"
  # Results:
  #   ./Acme/resume-Acme-Sr-DS-YYYY-MM-DD.tex + .pdf
  #   ./Acme/cover-letter-Acme-Sr-DS-YYYY-MM-DD.tex + .pdf
  # You can edit the copies in ./Acme/ and re-run the same command to rebuild.
  ```
  - Safety: the helper will NOT overwrite existing .tex copies in ./[Company]/ by default.
    - To force overwriting the saved copies, set `FORCE_COPY=1`:
      `make tailor COMPANY="Acme" ROLE_SHORT="Sr-DS" FORCE_COPY=1`

- Manual (if you’re not using the helper):
  ```sh
  DATE=$(date +%Y-%m-%d)
  COMPANY="Acme"; ROLE_SHORT="Sr-DS"
  mkdir -p "$COMPANY"
  cp resume.tex "$COMPANY/resume-${COMPANY}-${ROLE_SHORT}-${DATE}.tex"
  cp cover-letter.tex "$COMPANY/cover-letter-${COMPANY}-${ROLE_SHORT}-${DATE}.tex"
  latexmk -pdf "$COMPANY/resume-${COMPANY}-${ROLE_SHORT}-${DATE}.tex"
  latexmk -pdf "$COMPANY/cover-letter-${COMPANY}-${ROLE_SHORT}-${DATE}.tex"
  ```

Notes
- The Makefile already builds any `*.tex` into a matching `*.pdf`.
- Do not introduce external build tools; stick to `make`/LaTeX.
- It is acceptable to commit the generated PDFs for review, but regenerate via `make` before merging.
