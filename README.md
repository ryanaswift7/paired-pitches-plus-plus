# PairedPitches++

**From pitch-pair visualization to evidence-based pitch sequencing.**

## TL;DR

PairedPitches++ extends FanGraphs' pitch-pair visualization concept into a descriptive, predictive, and prescriptive pitch-sequencing system. It uses Statcast data to measure how consecutive pitches interact, a Bayesian hierarchical model to estimate player- and pitch-pair effects with partial pooling, and posterior predictive distributions to rank feasible follow-up pitches while communicating uncertainty. The project uses DuckDB and Parquet for reproducible local analytics, PyMC for the core Bayesian workflow, and a lightweight interactive application for exploration and decision support.

PairedPitches++ is an interactive baseball analytics system that studies how consecutive pitches work together. It extends the idea behind FanGraphs' Paired Pitches tool by connecting pitch-pair geometry—release similarity, trajectory, velocity differential, and late separation—to batter decisions and pitch outcomes. Its statistical core is a **Bayesian hierarchical model** that partially pools information across pitchers, batters, pitch types, and pitch pairs while preserving player-level differences and propagating posterior uncertainty into recommendations.

The project progresses through three analytical layers:

1. **Descriptive:** How does a pitcher pair and sequence their pitches?
2. **Predictive:** What posterior outcome distribution does the Bayesian hierarchical model assign to each feasible follow-up pitch?
3. **Prescriptive:** Given the current plate-appearance state, which pitch or pitch mix has the best posterior expected outcome after accounting for uncertainty?

> **Project status:** Planning and data-pipeline development. Features marked **Planned** are not yet implemented.

<!-- Replace this block with a screenshot or GIF after the MVP is deployed. -->
<!-- ![PairedPitches++ demo](docs/assets/demo.gif) -->

## Why this project?

Pitch quality is usually evaluated one pitch at a time, but pitchers sequence offerings so that one pitch changes how the next is perceived. A slider may be effective not only because of its own movement and location, but because it initially resembles the preceding fastball before separating late in flight.

PairedPitches++ asks:

> After controlling for pitch quality, location, count, handedness, and player ability, which properties of a pitch pair make the second pitch more effective?

The final system translates that analysis into a constrained decision aid. It ranks only pitches in the selected pitcher's demonstrated arsenal, accounts for the pitcher's command distribution, reports uncertainty, and abstains when the available data do not support a reliable recommendation.

## Product vision

For a selected pitcher and plate-appearance state, PairedPitches++ will answer:

- What does this pitcher throw?
- Which pitches are commonly paired?
- How similarly do those pitches travel before separating?
- How have hitters responded to those sequences?
- Do pitch-pair characteristics improve outcome prediction out of sample?
- How much do player- and pitch-pair-specific estimates shrink toward their population distributions?
- Which feasible follow-up pitch has the best model-estimated outcome?
- How uncertain is that recommendation?

The intended final interaction is:

```text
Pitcher + batter + count + previous pitch
                    |
                    v
      Feasible pitches in the arsenal
                    |
                    v
    Outcome and command distributions
                    |
                    v
 Expected run value + uncertainty by pitch
                    |
                    v
     Ranked pitches and suggested mix
```

## Scope

### Initial analytical unit

One observation represents a pitch and the pitch immediately preceding it within the same plate appearance. The pair contains:

- Pitcher and batter identifiers
- Count before the current pitch
- Pitcher and batter handedness
- Previous and current pitch types
- Previous-pitch result
- Velocity, movement, release, and location for both pitches
- Pairwise geometric features
- Swing, take, chase, whiff, contact, and run-value outcomes

### Initial population

- MLB regular-season Statcast pitches
- Statcast-era seasons with consistent required measurements
- Consecutive pitches within a plate appearance
- Pitchers and pitch pairs meeting documented usage thresholds

Development will begin with a limited number of seasons. Historical coverage will expand only after the pipeline and validation checks are stable.

### Out of scope for the portfolio release

- Live game feeds
- Perfect-location or perfect-command assumptions
- Full plate-appearance simulation
- Reinforcement learning
- Computer vision
- Injury prediction
- Catcher game-calling evaluation
- Claims that model recommendations are causal guarantees

## Analytical progression

### 1. Descriptive analytics

The MVP will provide:

- Pitcher arsenal and usage summaries
- Pitch-pair transition matrices
- Sequence usage by count and batter handedness
- Release-point and movement comparisons
- Location distributions and heatmaps
- Swing, chase, whiff, called-strike, contact, and hard-hit rates
- Expected wOBA and run-value summaries where appropriate
- Sample sizes and confidence intervals

Descriptive results will always expose their numerator, denominator, and relevant conditioning population.

### 2. Predictive analytics: Bayesian hierarchical modeling

Rather than predicting one generic definition of a “good pitch,” the system decomposes the pitch outcome into interpretable branches:

\[
P(\text{swing}\mid s,a),
\]

\[
P(\text{whiff}\mid \text{swing},s,a),
\]

\[
P(\text{called strike}\mid \text{take},s,a),
\]

and

\[
E[\text{contact value}\mid \text{contact},s,a],
\]

where \(s\) is the observed plate-appearance state and \(a\) is a candidate pitch.

The first modeling milestone focuses on whiff probability conditional on a swing. Later models combine the outcome branches into expected run value. The primary inferential model is Bayesian and hierarchical; simpler frequentist and machine-learning models serve as baselines rather than replacements for it.

The modeling comparison includes:

- Logistic regression and generalized additive models as interpretable baselines
- A Bayesian hierarchical generalized linear model as the core model
- Gradient-boosted trees as a predictive benchmark

Hierarchical effects will be modeled for pitchers, batters, pitch types, pitch-pair types, and pitcher-specific pitch pairs. Exact pitcher–batter effects will be omitted initially or strongly pooled because most matchups have small samples.

## Bayesian hierarchical model

The core model is intended to demonstrate more than the use of Bayesian software. Its structure should encode the baseball data-generating hierarchy and solve the project's central small-sample problem.

For the initial whiff model, let \(y_i\) indicate whether pitch \(i\) produced a whiff, conditional on a swing:

\[
y_i \sim \operatorname{Bernoulli}(p_i),
\]

\[
\operatorname{logit}(p_i)
= \alpha
+ \mathbf{x}_i^\top\boldsymbol\beta
+ u_{\text{pitcher}[i]}
+ v_{\text{batter}[i]}
+ w_{\text{pair}[i]}
+ r_{\text{pitcher-pair}[i]}.
\]

The varying effects receive population distributions such as:

\[
u_j \sim \mathcal N(0,\sigma_{\text{pitcher}}),
\qquad
v_k \sim \mathcal N(0,\sigma_{\text{batter}}),
\]

with weakly informative priors on population-level coefficients and regularizing priors on group-level scales. Where supported by the data, the model will add varying slopes—for example, allowing the effect of decision-point separation to vary by pitch-pair family or pitcher.

The hierarchy provides partial pooling:

- Low-sample players and pitch pairs shrink more strongly toward their population means.
- High-sample groups retain more individualized estimates.
- New or lightly observed pitchers can borrow strength from pitchers with comparable pitch types and characteristics.
- Posterior uncertainty naturally widens when a recommendation is weakly supported.

### Why PyMC?

PyMC is the primary modeling framework because it provides an expressive Python interface for hierarchical models, integrates naturally with ArviZ for posterior diagnostics and visualization, and fits the project's Python data and application stack. It also preserves flexibility in computation: PyMC models can use its native sampler or JAX-backed samplers when benchmarking shows a meaningful speed advantage. NumPyro and gradient-boosted models may be used as computational or predictive benchmarks, but PyMC keeps model specification, posterior analysis, and communication of partial pooling central to the portfolio narrative.

The production model must report:

- Prior and posterior predictive checks
- \(\hat R\), effective sample sizes, divergences, and chain diagnostics
- Sensitivity to defensible alternative priors
- Posterior calibration and held-out predictive performance
- Group-level variance estimates
- Shrinkage plots comparing raw, unpooled, and partially pooled estimates
- Posterior intervals for player, pitch-pair, and recommendation-level quantities

The Bayesian model remains the project's primary explanatory and decision model even if a boosted-tree benchmark achieves slightly better point prediction.

### 3. Prescriptive analytics

For a state \(s\), the system evaluates only the pitches in pitcher \(p\)'s supported arsenal \(\mathcal A_p\):

\[
a^*(s)=\arg\min_{a\in\mathcal A_p} Q(s,a),
\]

where \(Q(s,a)\) is the model-estimated expected run value and lower values favor the pitcher.

The final recommendation will be computed from posterior predictive distributions and include:

- Ranked feasible pitches
- Expected run value for each pitch
- Difference from the pitcher's historical or model-estimated baseline
- Posterior credible interval and probability of outperforming the baseline pitch
- Data-support or overlap warning
- Coarse target-region guidance
- Plain-language explanation
- Abstention when posterior uncertainty is too large or candidate pitches are not meaningfully distinguishable

For example, the interface should prefer a statement such as “slider has a 78% posterior probability of producing a lower expected run value than four-seam” over declaring a pitch categorically optimal.

## Execution-aware location modeling

Public pitch tracking records where a pitch crossed the plate, not necessarily its intended target. Optimizing directly over realized `plate_x` and `plate_z` would implicitly assume perfect command.

PairedPitches++ instead plans to estimate a pitcher-specific command distribution:

\[
p(x,z\mid p,a,s).
\]

The value of choosing a pitch is then averaged over locations the pitcher is realistically likely to reach:

\[
Q(s,a)=\int E[Y\mid s,a,x,z]\,p(x,z\mid p,a,s)\,dx\,dz.
\]

Location heatmaps remain useful for exploration, but they will be clearly distinguished from execution-aware pitch recommendations.

## Pitch-pair features

The planned feature set includes:

### State and context

- Balls and strikes
- Batter and pitcher handedness
- Previous-pitch result
- Pitch number within the plate appearance
- Optional base/out state when modeling run value

### Individual pitch characteristics

- Pitch type
- Release speed
- Spin rate and spin axis when available
- Horizontal and induced vertical movement
- Release position and extension
- Plate location
- Vertical and horizontal approach information when available or derivable

### Pairwise characteristics

- Velocity differential
- Release-point distance
- Movement differential
- Location differential
- Approach-angle differential
- Estimated separation at selected flight points
- Separation at the plate
- Previous/current pitch-type interaction
- Same-side versus opposite-side movement relationship

Every derived feature will have a documented definition, coordinate convention, unit, and missing-data policy.

## Data pipeline

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

The initial implementation uses Python, Parquet, and DuckDB. A separate production database will be introduced only if application requirements justify it.

### Why DuckDB?

DuckDB is used because the core workload consists of local, read-heavy scans and aggregations over millions of pitch records. It can query partitioned Parquet files directly, runs as an embedded database without a separate server, and integrates cleanly with Python, Polars, pandas, and Arrow. This makes the analytical pipeline easier to reproduce and avoids maintaining a second copy of the complete pitch dataset in a transactional database. PostgreSQL remains an option for a later multi-user deployment, but only compact application-facing tables and precomputed posterior summaries would need to be moved there.

## Proposed repository structure

```text
pairedpitches-plus-plus/
├── README.md
├── pyproject.toml
├── configs/
│   ├── data.yaml
│   └── model.yaml
├── data/
│   ├── raw/                 # ignored; immutable source files
│   ├── interim/             # ignored; normalized pitch data
│   └── processed/           # ignored; analytical tables
├── docs/
│   ├── data_dictionary.md
│   ├── methodology.md
│   ├── model_card.md
│   └── assets/
├── notebooks/
│   ├── exploration/
│   └── reports/
├── src/pairedpitches/
│   ├── data/
│   │   ├── ingest.py
│   │   ├── validate.py
│   │   └── build_pairs.py
│   ├── features/
│   │   ├── geometry.py
│   │   └── outcomes.py
│   ├── models/
│   │   ├── baselines.py
│   │   ├── outcomes.py
│   │   ├── command.py
│   │   └── policy.py
│   ├── evaluation/
│   │   ├── prediction.py
│   │   └── policy.py
│   └── app/
├── tests/
│   ├── data/
│   ├── features/
│   └── models/
└── scripts/
    ├── download_data.py
    ├── build_dataset.py
    ├── train_models.py
    └── evaluate_models.py
```

This structure is provisional and will evolve with the implementation.

## Validation strategy

Random pitch-level splitting would leak information across seasons, players, and nearby plate appearances. Primary evaluation will therefore be temporal.

### Data splits

- Train on earlier seasons
- Tune on a subsequent validation season
- Report final results on a later untouched test season
- Add a held-out-pitcher evaluation to test cold-start generalization

### Predictive metrics

- Log loss
- Brier score
- Calibration curves and calibration error
- PR-AUC for uncommon binary outcomes
- RMSE or MAE for continuous outcomes
- Performance by count, handedness, season, and sample-size group

### Bayesian diagnostics and model criticism

- Prior predictive checks
- Posterior predictive checks overall and by player/sample-size group
- MCMC convergence diagnostics
- Simulation-based calibration for the implemented model where feasible
- Sensitivity to prior choices
- Leave-one-out cross-validation for within-training model comparison
- Calibration and log score on the untouched temporal test set
- Empirical coverage of posterior predictive intervals

### Core ablation study

| Model | Purpose |
|---|---|
| Context only | Establish predictability from count and handedness |
| Context + current pitch | Measure the value of current-pitch quality |
| + previous pitch | Measure the value of sequence identity |
| + pair geometry | Test the central PairedPitches++ hypothesis |

The principal analytical result is whether pitch-pair information improves held-out prediction beyond the context and current pitch alone.

## Recommendation evaluation

Historical pitch selection is not random. Pitchers and catchers choose pitches using information that is only partially observable in public data, and only the result of the selected pitch is observed.

The recommendation system will therefore be described as model-based decision support, not a causal oracle. Planned offline evaluation includes:

- Historical pitch-selection propensity modeling
- Policy coverage and overlap diagnostics
- Self-normalized inverse propensity weighting
- Doubly robust policy evaluation
- Bootstrap uncertainty intervals
- Sensitivity analysis across player and game-state groups

The proposed policy will be compared with:

- The pitcher's historical strategy
- The pitcher's most common pitch in the count
- A league-average strategy
- A ranking based on unadjusted historical outcomes
- A predictive policy without pitch-pair features

## Roadmap

The schedule assumes approximately 10 hours per week.

| Release | Target | Primary deliverable | Status |
|---|---:|---|---|
| Data foundation | 3 weeks | Reproducible validated pitch-pair dataset | Planned |
| Descriptive MVP | 8 weeks total | Deployed pitch-pair explorer | Planned |
| Bayesian adjusted analytics | 14 weeks total | Bayesian hierarchical outcome model, diagnostics, and ablations | Planned |
| Predictive engine | 21 weeks total | State-conditional outcome predictions | Planned |
| Prescriptive MVP | 25 weeks total | Execution-aware pitch ranking | Planned |
| Portfolio release | 29 weeks total | Polished application, report, and case studies | Planned |
| Policy evaluation | 35 weeks total | Offline evaluation and overlap analysis | Planned |
| Final strategy system | 40–42 weeks total | Regularized suggested pitch mixtures | Planned |

### Release 1: Descriptive MVP

- Build and validate consecutive pitch pairs
- Explore arsenals and pitch transitions
- Add count and handedness filters
- Display geometric and outcome summaries
- Report samples and confidence intervals

### Release 2: Bayesian adjusted analytics

- Establish interpretable baselines
- Specify priors and run prior predictive checks
- Fit the Bayesian hierarchical whiff model
- Validate sampling, convergence, and posterior predictive behavior
- Visualize partial pooling and group-level variation
- Compare raw and adjusted estimates
- Run temporal tests and feature ablations
- Publish the first pitcher case study

### Release 3: Predictive engine

- Predict the swing/take outcome tree
- Model contact value
- Build pitcher-specific command distributions
- Restrict candidates to supported arsenal pitches
- Surface model uncertainty and explanations

### Release 4: Prescriptive MVP

- Combine outcome branches into expected run value
- Rank feasible pitches
- Penalize uncertain recommendations
- Recommend coarse target regions
- Abstain in low-support states

### Release 5: Final strategy system

- Estimate historical pitch-selection propensities
- Evaluate the recommendation policy offline
- Diagnose support and overlap
- Produce regularized suggested pitch mixtures
- Publish final methodology, model card, and case studies

## Installation

> **Not yet available.** Replace this section once the project environment and entry points are stable. Do not publish commands that have not been tested from a clean clone.

Planned workflow:

```bash
# Clone and install the project
git clone <repository-url>
cd pairedpitches-plus-plus
uv sync

# Build a development dataset
uv run python scripts/download_data.py --start <date> --end <date>
uv run python scripts/build_dataset.py

# Run validation and tests
uv run pytest

# Start the application
uv run <app-entry-point>
```

## Reproducibility

The project will provide:

- Pinned dependencies
- Configuration-driven data and model builds
- Versioned Bayesian model specifications and priors
- Saved sampler diagnostics and posterior predictive checks
- Deterministic random seeds where supported
- Versioned raw-data manifests
- Versioned feature definitions
- Saved train/validation/test boundaries
- Automated data-contract tests
- Model metadata and evaluation artifacts

Raw tracking data will not be committed to the repository. Documentation will explain how to obtain the source data and reproduce the processed tables subject to the source's terms and availability.

## Interpretation and limitations

PairedPitches++ recommendations should be interpreted cautiously:

- Observational data do not identify the outcome of pitches that were not thrown.
- Public data do not reveal the catcher's target or all information used during pitch selection.
- Realized location is not intended location.
- Batter and pitcher abilities change over time.
- Pitch classifications and tracking measurements contain error.
- Rare pitches and exact pitcher–batter matchups provide limited support.
- Offline policy estimates depend on modeling and overlap assumptions.
- A lower model-estimated run value does not guarantee a better realized outcome.

The interface will expose these limitations through uncertainty intervals, support indicators, and abstention rather than hiding them in documentation alone.

## Portfolio goals

This project is designed to demonstrate:

- Baseball research and domain reasoning
- Reproducible data engineering
- Feature engineering from pitch-level tracking data
- Bayesian hierarchical modeling and partial pooling
- Prior specification, posterior inference, and posterior predictive checking
- Communicating posterior uncertainty in individual and population estimates
- Predictive calibration and temporal validation
- Decision analysis under uncertainty
- Off-policy evaluation
- Interactive visualization and product design
- Clear communication of assumptions and limitations

Success is not defined by the number of features. A successful final project will produce one defensible baseball finding, a well-validated model, and a polished interface that makes the reasoning behind every recommendation inspectable.

## Planned case studies

- A pitcher with a highly effective fastball–breaking-ball combination
- A pitcher whose unusual pitch shapes create distinctive separation
- A pitcher for whom raw and adjusted sequence results disagree
- A state in which the system abstains because candidate pitches are too uncertain
- A comparison between deterministic pitch ranking and a regularized pitch mix

## Acknowledgments

PairedPitches++ is inspired by FanGraphs' Paired Pitches visualization. It is an independent portfolio and research project and is not affiliated with or endorsed by FanGraphs or Major League Baseball.

Data-source attribution and licensing language will be added and verified before public deployment.

## License

License to be selected before the first public release. The software license will not supersede the terms governing any underlying baseball data.
