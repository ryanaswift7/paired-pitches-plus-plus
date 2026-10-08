# Phase 4: Predictive Engine

## Objective

Extend the initial whiff model into state-conditional outcome predictions that combine the major branches of the pitch outcome process.

## Concrete objectives

- Predict the swing/take outcome tree.
- Model whiff probability conditional on a swing.
- Model called-strike probability conditional on a take.
- Model contact value conditional on contact.
- Build pitcher-specific command distributions over realistic locations.
- Restrict candidate pitches to the pitcher's supported arsenal.
- Surface predictive uncertainty, data support, and plain-language explanations.
- Evaluate log loss, Brier score, calibration, PR-AUC, and RMSE or MAE as appropriate.
- Evaluate performance by count, handedness, season, and sample-size group.

## Execution-aware location model

The system should estimate a pitcher-specific command distribution:

$$
p(x,z\mid p,a,s).
$$

Candidate pitch value should be averaged over locations the pitcher is realistically likely to reach:

$$
Q(s,a)=\int E[Y\mid s,a,x,z]\,p(x,z\mid p,a,s)\,dx\,dz.
$$

Realized `plate_x` and `plate_z` should not be treated as intended targets or as evidence of perfect command.

## Deliverables

- State-conditional prediction pipeline
- Outcome-branch models and calibration reports
- Pitcher-specific command distribution estimates
- Supported-arsenal candidate generator
- Predictive uncertainty and support indicators
- Predictive engine API or query interface

## Definition of done

- Predictions are generated only for supported candidate pitches.
- The outcome branches can be combined into expected run value.
- Predictions include uncertainty and calibration evidence.
- Location-aware predictions reflect realistic execution rather than arbitrary plate locations.
