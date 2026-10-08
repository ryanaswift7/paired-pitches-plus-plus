# Phase 1: Data Foundation

## Objective

Build a reproducible, validated dataset of final-two-pitch Statcast pairs for 2023-2026.

## Scope

Each observation represents the final two pitches of a plate appearance (at bat). The final pitch is the pitch that produces the plate-appearance outcome; the preceding observation is the penultimate pitch. Select these rows using the highest two `pitch_number` values within each `(game_pk, at_bat_number)` group. The observation should preserve:

- `game_pk`, `at_bat_number`, and `pitch_number`
- Pitcher and batter identifiers
- Count before the current pitch
- Pitcher and batter handedness
- Previous and current pitch types
- Previous-pitch result
- Velocity, movement, release, and location for both pitches
- Pairwise geometric features
- Swing, take, chase, whiff, contact, and run-value outcomes

The initial population is MLB regular-season Statcast data with consistent required measurements, restricted to pitchers and pitch pairs meeting documented usage thresholds.

## Concrete objectives

- Define the supported source fields, units, coordinate conventions, and missing-data policy.
- Download and preserve raw source files as immutable inputs.
- Validate identifiers, dates, plate appearances, pitch ordering, and required measurements.
- Normalize source data into pitch and plate-appearance tables.
- Select the final two pitches from every plate appearance with at least two pitches.
- Construct final-pitch/penultimate-pitch pairs without crossing plate-appearance boundaries.
- Add initial pairwise features: velocity, release-point, movement, location, and approach-angle differences.
- Store analytical outputs as partitioned Parquet and query them with DuckDB.
- Add data-contract tests and versioned raw-data manifests.

## Deliverables

- Reproducible download and build scripts
- Raw, interim, and processed data layout
- Validated pitch-pair Parquet dataset
- Data dictionary and feature definitions
- Automated validation and data-contract tests
- Documented season and usage-threshold configuration

## Definition of done

- A clean clone can rebuild the same dataset from a documented source manifest.
- Every retained plate appearance has at least two pitches and contributes exactly its final two pitches.
- No pitch pair crosses a plate-appearance boundary.
- Validation reports expose row counts, missingness, duplicates, and rejected records.
- Every derived feature has a documented definition, unit, coordinate convention, and missing-data policy.
