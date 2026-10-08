# PairedPitches++

**From pitch-pair visualization to evidence-based pitch sequencing.**

## TL;DR

PairedPitches++ extends FanGraphs' pitch-pair visualization concept into a descriptive, predictive, and prescriptive pitch-sequencing system. It uses Statcast data to measure how consecutive pitches interact, a Bayesian hierarchical model to estimate player- and pitch-pair effects with partial pooling, and posterior predictive distributions to rank feasible follow-up pitches while communicating uncertainty.

The detailed project plan is in [`docs/PLAN.md`](docs/PLAN.md).
Concrete objectives, deliverables, and completion criteria are organized in the phase files under [`docs/phases/`](docs/phases/).

## Setup

The development environment uses Nix, direnv, and uv:

1. Install [Nix](https://nixos.org/download/), [direnv](https://direnv.net/), and [nix-direnv](https://github.com/nix-community/nix-direnv). Configure nix-direnv so that it is loaded by direnv; the repository's `.envrc` uses its `use flake` integration.
2. Enable direnv in your shell. For bash:

   ```zsh
   eval "$(direnv hook bash)"
   ```

3. From the project directory, authorize the environment:

   ```bash
   direnv allow
   ```

   This loads the development shell defined in `flake.nix`. It provides `uv` and `git` without requiring a system Python installation.

4. Synchronize Python dependencies:

   ```bash
   uv sync
   ```

   `uv sync` installs project and development dependencies. End users or production environments can omit development tools with:

   ```bash
   uv sync --no-dev
   ```

Run commands inside the managed environment with `uv run`, for example:

```bash
uv run pytest
```

Python project metadata and dependencies are defined in `pyproject.toml`; the exact environment is recorded in `uv.lock`.
