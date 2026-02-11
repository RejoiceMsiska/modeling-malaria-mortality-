# modeling-malaria-mortality-
The aim is to model and forecast Malaria Mortality in Mozambique.

# Contents of README.md
# Malaria Forecasting Model (R Version)

This repository contains an R-based forecasting model for malaria deaths using INLA for Bayesian Generalized Additive Models. It is designed to be compatible with the Climate and Health Assessment Platform (Chap).

## Structure
- `input/`: Contains sample data files (trainData.csv, futureClimateData.csv).
- `train.r`: Script to train the model (dummy for INLA approach).
- `predict.r`: Script to generate predictions using the trained model.
- `isolated_run.r`: Script to run training and prediction locally.
- `MLproject`: MLflow project file for Chap integration.

## Usage
1. Install renv: `install.packages('renv')` and run `renv::init()` to manage dependencies (INLA, dplyr, readr, lubridate).
2. Run locally: `Rscript isolated_run.r`
3. For Chap: Follow Chap documentation to evaluate the model. Uses docker image with INLA pre-installed.

Note: The model assumes input data has columns: time_period, rainfall, mean_temperature, disease_cases (for train), location, population.
Lagged features are computed internally. Fitting occurs in predict.r by appending future data.
