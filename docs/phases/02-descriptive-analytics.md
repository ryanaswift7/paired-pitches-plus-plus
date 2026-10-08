# Phase 2: Descriptive Analytics

## Objective

Deliver a transparent descriptive MVP that explains how pitchers use and sequence their pitches.

## Concrete objectives

- Summarize pitcher arsenals and pitch usage.
- Build pitch-pair transition matrices.
- Break sequence usage down by count and batter handedness.
- Compare release point, movement, velocity, and pair geometry.
- Display location distributions and heatmaps.
- Report swing, chase, whiff, called-strike, contact, hard-hit, expected wOBA, and run-value summaries where appropriate.
- Expose numerators, denominators, conditioning populations, sample sizes, and confidence intervals.
- Add filters for pitcher, pitch type, count, handedness, season, and previous pitch.

## Deliverables

- Reusable descriptive query layer
- Pitcher arsenal and sequencing summaries
- Pitch-pair transition views
- Movement, release, location, and outcome visualizations
- Initial interactive pitch-pair explorer
- First documented pitcher case study

## Definition of done

- A user can inspect a supported pitcher's arsenal and transitions.
- Every displayed rate identifies its numerator, denominator, and conditioning population.
- Small samples are visible rather than presented as stable estimates.
- Results can be reproduced from the Phase 1 analytical tables.
