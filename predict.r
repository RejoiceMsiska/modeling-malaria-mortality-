# Contents of predict.r
# Requires INLA package

library(INLA)
library(dplyr)
library(readr)
library(lubridate)

predict_chap <- function(model_fn, historic_data_fn, future_climatedata_fn, predictions_fn) {
  # Load dummy model (not used, but to comply with interface)
  readRDS(model_fn)
  
  # Read historic and future data
  historic <- read_csv(historic_data_fn, show_col_types = FALSE)
  future <- read_csv(future_climatedata_fn, show_col_types = FALSE)
  
  # Add disease_cases NA to future
  future$disease_cases <- NA_real_
  
  # Combine
  fit_data <- bind_rows(historic, future)
  
  # Process dates and create lags
  fit_data$time_period <- ymd(fit_data$time_period)
  fit_data <- fit_data %>%
    arrange(location, time_period) %>%
    group_by(location) %>%
    mutate(
      rain_lag1 = lag(rainfall, 1),
      rain_lag2 = lag(rainfall, 2),
      temp_lag1 = lag(mean_temperature, 1)
    ) %>%
    ungroup() %>%
    mutate(
      rain_lag1 = ifelse(is.na(rain_lag1), 0, rain_lag1),
      rain_lag2 = ifelse(is.na(rain_lag2), 0, rain_lag2),
      temp_lag1 = ifelse(is.na(temp_lag1), 0, temp_lag1)
    )
  
  # Extract month
  fit_data$month <- month(fit_data$time_period)
  
  # District as numeric factor
  fit_data$district <- as.integer(factor(fit_data$location))
  
  # INLA formula
  inla_formula <- disease_cases ~
    f(rain_lag1, model = "rw1") +
    f(rain_lag2, model = "rw1") +
    f(temp_lag1, model = "rw1") +
    f(month, model = "seasonal", season.length = 12) +
    f(district, model = "iid") +
    offset(log(population / 1000))
  
  # Fit model
  model <- inla(
    inla_formula,
    family = "poisson",
    data = fit_data,
    control.predictor = list(compute = TRUE, link = 1),
    control.compute = list(dic = TRUE, waic = TRUE, cpo = TRUE)
  )
  
  # Indices for future rows
  n_new <- nrow(future)
  idx_new <- (nrow(fit_data) - n_new + 1):nrow(fit_data)
  
  # Extract posterior mean on response scale
  y_pred <- model$summary.fitted.values[idx_new, "mean"]
  
  # Add to future dataframe
  future$sample_0 <- y_pred
  
  # Write output
  write_csv(future, predictions_fn, row.names = FALSE)
  
  # Print for debugging
  cat("Forecasted values:", paste(y_pred, collapse = ", "), "\n")
}

# Command line execution
if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) != 4) {
    stop("Usage: Rscript predict.r <model_bin> <historic_csv> <future_csv> <predictions_csv>")
  }
  predict_chap(args[1], args[2], args[3], args[4])
}
