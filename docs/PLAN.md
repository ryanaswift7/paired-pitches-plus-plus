# PairedPitches++ Project Plan

PairedPitches++ is a descriptive, predictive, and prescriptive system for studying how consecutive pitches interact. The project connects pitch-pair geometry—release similarity, trajectory, velocity differential, and late separation—to batter decisions and pitch outcomes.

## Overall vision

For a selected pitcher and plate-appearance state, the system will:

1. Describe the pitcher's arsenal and sequencing patterns.
2. Estimate outcome probabilities and run value with uncertainty.
3. Rank only feasible pitches from the pitcher's supported arsenal.
4. Account for realistic command distributions rather than assuming perfect location.
5. Explain recommendations and abstain when evidence is insufficient.

The detailed objectives and deliverables are organized by phase:

1. [Data foundation](phases/01-data-foundation.md)
2. [Descriptive analytics](phases/02-descriptive-analytics.md)
3. [Bayesian modeling](phases/03-bayesian-modeling.md)
4. [Predictive engine](phases/04-predictive-engine.md)
5. [Prescriptive system](phases/05-prescriptive-system.md)
6. [Portfolio release](phases/06-portfolio-release.md)

## Project boundaries

The initial analytical unit is a pitch and the pitch immediately preceding it within the same plate appearance. The initial population is MLB regular-season Statcast data from a limited number of seasons, expanded only after validation is stable.

The portfolio release excludes live game feeds, perfect-location assumptions, full plate-appearance simulation, reinforcement learning, computer vision, injury prediction, catcher game-calling evaluation, and claims that recommendations are causal guarantees.

## Target architecture

```text
Statcast source
      |
      v
Raw immutable files
      |
      v
Validation and normalization
      |
      v
Pitch and plate-appearance tables
      |
      v
Consecutive pitch-pair features
      |
      v
Parquet + DuckDB analytical layer
      |
      +------------------+
      |                  |
      v                  v
Modeling datasets    Application queries
      |                  |
      v                  v
Versioned models      API and interface
```

The implementation uses Python, Parquet, and DuckDB. Nix, direnv, and uv provide the reproducible development environment; see the root [README](../README.md).

## Evaluation principles

- Use temporal train, validation, and test splits rather than random pitch-level splits.
- Include held-out-pitcher evaluation for cold-start generalization.
- Report predictive performance by count, handedness, season, and sample-size group.
- Require prior and posterior predictive checks, convergence diagnostics, calibration, and posterior interval coverage.
- Test the central hypothesis with ablations from context-only through pitch-pair geometry.
- Treat recommendations as model-based decision support, not causal conclusions.

## Schedule

The schedule assumes approximately 10 hours per week. The estimates are targets, not deadlines:

| Milestone | Target | Primary outcome |
|---|---:|---|
| Data foundation | 3 weeks | Reproducible validated pitch-pair dataset |
| Descriptive MVP | 8 weeks total | Pitch-pair explorer |
| Bayesian modeling | 14 weeks total | Hierarchical outcome model and diagnostics |
| Predictive engine | 21 weeks total | State-conditional predictions |
| Prescriptive system | 25 weeks total | Execution-aware pitch ranking |
| Portfolio release | 29 weeks total | Polished application, report, and case studies |
| Policy evaluation | 35 weeks total | Offline evaluation and overlap analysis |
| Final strategy system | 40–42 weeks total | Regularized suggested pitch mixtures |

## Interpretation and limitations

Observational data do not identify the outcome of pitches that were not thrown. Public data do not reveal every factor used in pitch selection, and realized location is not intended location. Pitch classifications, tracking measurements, and small samples introduce additional uncertainty. The interface should expose these limitations through uncertainty intervals, support indicators, and abstention.
