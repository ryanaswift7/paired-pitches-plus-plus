# Phase 3: Bayesian Modeling

## Objective

Build and validate the core Bayesian hierarchical model for pitch outcomes, beginning with whiff probability conditional on a swing.

## Model scope

The initial model is:

$$
y_i \sim \operatorname{Bernoulli}(p_i),
$$

$$
\operatorname{logit}(p_i)
= \alpha
+ \mathbf{x}_i^\top\boldsymbol\beta
+ u_{\text{pitcher}[i]}
+ v_{\text{batter}[i]}
+ w_{\text{pair}[i]}
+ r_{\text{pitcher-pair}[i]}.
$$

The hierarchy should partially pool effects for pitchers, batters, pitch types, pitch-pair types, and pitcher-specific pitch pairs. Exact pitcher–batter effects should be omitted initially or strongly pooled because most matchups are sparse.

## Concrete objectives

- Establish interpretable logistic and generalized additive baselines.
- Specify weakly informative priors and regularizing group-level priors.
- Run prior predictive checks before fitting the model.
- Fit the hierarchical whiff model in PyMC.
- Validate sampling, convergence, divergences, effective sample sizes, and posterior predictive behavior.
- Compare raw, unpooled, and partially pooled estimates.
- Quantify shrinkage and group-level variation.
- Run temporal tests and feature ablations.
- Compare the Bayesian model with gradient-boosted predictive benchmarks.

## Deliverables

- Versioned model specification and prior configuration
- Baseline models and comparison report
- PyMC model and fitting workflow
- Prior and posterior predictive checks
- MCMC diagnostics and sensitivity analysis
- Shrinkage and group-level effect visualizations
- First Bayesian pitcher case study

## Definition of done

- The model passes convergence and posterior predictive checks.
- Diagnostics and uncertainty are reported with every model result.
- The model demonstrates partial pooling on low- and high-sample groups.
- Temporal held-out performance and ablation results are documented.
