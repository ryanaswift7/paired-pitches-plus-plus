# Phase 5: Prescriptive System

## Objective

Provide a conservative decision aid that ranks feasible follow-up pitches and communicates when the evidence is insufficient.

## Concrete objectives

- Combine outcome branches into expected run value.
- Rank feasible pitches from the supported arsenal.
- Compare each candidate with the historical or model-estimated baseline.
- Penalize or flag uncertain recommendations.
- Report posterior credible intervals and the probability of outperforming the baseline.
- Recommend coarse target regions where execution support exists.
- Abstain when posterior uncertainty is too large or candidates are not meaningfully distinguishable.
- Provide a plain-language explanation for every recommendation.

## Recommendation target

For state $s$, choose among the feasible pitches $\mathcal A_p$:

$$
a^*(s)=\arg\min_{a\in\mathcal A_p} Q(s,a),
$$

where lower expected run value favors the pitcher. This is a model-based decision aid, not a causal oracle.

## Policy evaluation

Because historical pitch selection is not random, evaluate the recommendation policy with:

- Historical pitch-selection propensity modeling
- Policy coverage and overlap diagnostics
- Self-normalized inverse propensity weighting
- Doubly robust policy evaluation
- Bootstrap uncertainty intervals
- Sensitivity analysis across player and game-state groups

Compare the proposed policy with the pitcher's historical strategy, most common pitch in the count, a league-average strategy, unadjusted historical outcomes, and a predictive policy without pitch-pair features.

## Deliverables

- Feasible pitch-ranking workflow
- Expected run-value and uncertainty output
- Support and overlap diagnostics
- Abstention logic
- Coarse target-region guidance
- Offline policy evaluation report
- Prescriptive pitcher case study

## Definition of done

- Recommendations are limited to feasible, supported pitches.
- Uncertainty and support warnings are visible in the interface.
- The system abstains in low-support states.
- Offline evaluation and its assumptions are documented.
