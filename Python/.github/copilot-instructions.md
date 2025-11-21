<!-- .github/copilot-instructions.md - guidance for AI coding agents working on this workspace -->
# Quick orientation (what this repo is)
- This workspace is a collection of small, mostly-independent Python practice projects and demos (not a single unified app).
- Major folders: `ML from Scratch/` (learning-model prototypes), `PY from Scratch/` (tutorials and small packages), `tui/` (Textual/TUI examples), `trading/` (trading scripts). Top-level scripts include `main.py` and `test-tui.py`.

# Big picture & purpose for edits
- Treat changes as small, localized improvements unless the user asks for large refactors. Many files are standalone scripts or teaching snippets.
- Preserve intent: examples often demonstrate concepts (e.g., `ML from Scratch/model.py`) rather than production-quality libraries. Avoid making API-breaking changes unless adding tests and migration steps.

# Key entry points (use these to understand behavior quickly)
- `main.py` — minimal top-level script (entry example). See it for project-level invocation style.
- `test-tui.py` and `tui/dashboard.py` — Textual-based TUI examples; launching these requires the `textual` package.
- `ML from Scratch/model.py`, `train.py` — small neural/net prototypes that import `ML from Scratch/lib/*` prototyped wrappers (files named `*Proto.py`).
- `PY from Scratch/` — contains many tutorial scripts and a small package `math_package/` showing how packages are structured here.

# Project-specific conventions and patterns
- Many modules are single-file scripts; keep changes minimal and file-local by default.
- Teaching/prototype code lives in `ML from Scratch/lib/` where helper wrappers are named with `Proto` suffix (e.g., `numpyProto.py`, `pandasProto.py`). When editing ML examples, look for these wrappers first — they model dependency behavior.
- Small packages include `__init__.py` (example: `PY from Scratch/3. Advanced/math_package/`). Use `python -m` for package-level execution where appropriate.

# How to run / developer workflows (discovered patterns)
- There is no top-level `requirements.txt`. Before running files, check imports at the top of the target file. Typical commands:
  - Run a script: `python3 path/to/script.py` (e.g., `python3 main.py` or `python3 "tui/dashboard.py"`).
  - Run a package module: `python3 -m "PY from Scratch.math_package.calculate"` (adjust path-like module names to dots).
- TUI examples require `textual` (install into venv): `pip install textual`.
- ML examples import `numpy`, `scipy` etc.; if missing, create a `requirements.txt` in the repo root listing packages used by the files you edit.

# Patterns for safe edits (what AI agents should do)
- Favor small, explainable commits: one logical change per PR. Add a short commit message explaining why (education/demo vs bugfix).
- When you modify an example's output or behavior, update any in-file comments that explain it.
- If adding external dependencies, add/update `requirements.txt` and note why the dependency is necessary.

# Examples & concrete hints (point to real files)
- To add a new TUI view, follow `tui/dashboard.py` structure: `App`, `Screen` classes, `compose()` and `on_button_pressed()` handlers.
- To extend the toy ML models, check `ML from Scratch/lib/numpyProto.py` (proto wrappers) before replacing with a direct `numpy` call.
- To add a reusable utility, prefer placing it in an existing package (e.g., `PY from Scratch/3. Advanced/math_package/`) and update `__init__.py`.

# What not to do
- Do not assume this is a production monolith: avoid broad refactors across directories unless the user requests them.
- Don't remove example comments or learning scaffolding without confirming the user's intent.

# If you need clarification from the user
- Ask which subproject to focus on (e.g., `ML from Scratch` vs `tui/` vs `trading/`).
- Ask whether to add a `requirements.txt` and CI/tests; these are not present and the user may want to keep the repo as-is for learning.

# Verification checklist for changes
- Run the edited script(s) locally with `python3` and confirm no ImportError. If you add deps, include `requirements.txt`.
- Keep commits atomic and push with a descriptive message indicating demo vs production change.

-- End of guidance --