# Model Estimation with Convergence Monitoring
# Tolerance Interventions for Interethnic Cooperation Research
#
# This script estimates the SAOM model with proper convergence monitoring
# Following RSiena best practices for algorithm tuning and continuation

# Load required libraries
library(RSiena)
library(tidyverse)
library(here)
library(parallel)

# Set random seed for reproducibility
set.seed(20250917)

cat("=== RSiena Model Estimation ===\n")
cat("Estimating SAOM with convergence monitoring\n\n")

# =============================================================================
# 1. LOAD DATA AND EFFECTS
# =============================================================================

cat("Loading data and effects...\n")

# Load RSiena data
data_file <- here("data", "processed", "siena_data.rds")
effects_file <- here("configs", "baseline_effects.rds")

if (!file.exists(data_file) || !file.exists(effects_file)) {
  cat("ERROR: Required files not found\n")
  cat("Run 00_data_prep.R and 01_baseline.R first\n")
  stop("Prerequisites not met")
}

siena_data <- readRDS(data_file)
effects <- readRDS(effects_file)

cat("Loaded data and effects successfully\n")
cat("Effects to estimate:", sum(effects$include), "\n\n")

# =============================================================================
# 2. ALGORITHM CONFIGURATION
# =============================================================================

cat("Configuring estimation algorithm...\n")

# Create algorithm object with robust defaults
algorithm <- sienaAlgorithmCreate(
  projname = "tolerance_cooperation_saom",
  useStdInits = TRUE,           # Use standard initial values
  nsub = 4,                     # Number of subphases
  n3 = 3000,                    # Iterations in phase 3
  firstg = 0.2,                 # Robbins-Monro gain parameter
  diagonalize = 0.2,            # Diagonalization parameter
  doubleAveraging = 0,          # Double averaging (0 = off)
  seed = 20250917               # Random seed for reproducibility
)

cat("Algorithm configured with:\n")
cat("  - nsub:", algorithm$nsub, "\n")
cat("  - n3:", algorithm$n3, "\n")
cat("  - firstg:", algorithm$firstg, "\n")
cat("  - seed:", algorithm$seed, "\n\n")

# =============================================================================
# 3. INITIAL ESTIMATION
# =============================================================================

cat("Starting initial estimation...\n")
start_time <- Sys.time()

# First estimation attempt
cat("Phase 1: Initial parameter estimation\n")
result1 <- siena07(algorithm,
                   data = siena_data,
                   effects = effects,
                   batch = TRUE,
                   verbose = TRUE,
                   returnDeps = TRUE)

end_time <- Sys.time()
estimation_time <- as.numeric(difftime(end_time, start_time, units = "mins"))
cat("Initial estimation completed in", round(estimation_time, 2), "minutes\n")

# =============================================================================
# 4. CONVERGENCE ASSESSMENT
# =============================================================================

cat("\n=== Convergence Assessment ===\n")

# Extract convergence diagnostics
summary_result <- summary(result1)
t_ratios <- abs(summary_result$tstat)
max_t_ratio <- max(t_ratios, na.rm = TRUE)
overall_conv <- summary_result$tconv.max

cat("Convergence diagnostics:\n")
cat("  - Maximum t-ratio:", round(max_t_ratio, 3), "\n")
cat("  - Overall convergence ratio:", round(overall_conv, 3), "\n")

# RSiena convergence standards
t_threshold <- 0.1
conv_threshold <- 0.25

converged <- (max_t_ratio < t_threshold) && (overall_conv < conv_threshold)

if (converged) {
  cat("✓ Model converged successfully!\n")
  final_result <- result1
} else {
  cat("⚠ Model not converged. Continuing estimation...\n")
  cat("Targets: t-ratios <", t_threshold, ", convergence ratio <", conv_threshold, "\n")
}

# =============================================================================
# 5. CONTINUATION STRATEGY
# =============================================================================

if (!converged) {
  cat("\n=== Continuation Strategy ===\n")

  max_iterations <- 5
  iteration <- 1
  current_result <- result1

  while (!converged && iteration <= max_iterations) {
    cat(sprintf("\nContinuation iteration %d/%d\n", iteration, max_iterations))

    # Update algorithm for continuation
    algorithm_cont <- sienaAlgorithmCreate(
      projname = paste0("tolerance_cooperation_cont_", iteration),
      useStdInits = FALSE,        # Use previous estimates
      nsub = 4,
      n3 = 3000,
      firstg = 0.2,
      diagonalize = 0.2,
      doubleAveraging = 0,
      seed = 20250917 + iteration
    )

    # Continue estimation
    start_cont <- Sys.time()
    current_result <- siena07(algorithm_cont,
                              data = siena_data,
                              effects = effects,
                              prevAns = current_result,
                              batch = TRUE,
                              verbose = TRUE,
                              returnDeps = TRUE)

    end_cont <- Sys.time()
    cont_time <- as.numeric(difftime(end_cont, start_cont, units = "mins"))

    # Check convergence
    summary_cont <- summary(current_result)
    t_ratios <- abs(summary_cont$tstat)
    max_t_ratio <- max(t_ratios, na.rm = TRUE)
    overall_conv <- summary_cont$tconv.max

    cat("Iteration", iteration, "results:\n")
    cat("  - Time:", round(cont_time, 2), "minutes\n")
    cat("  - Max t-ratio:", round(max_t_ratio, 3), "\n")
    cat("  - Overall convergence:", round(overall_conv, 3), "\n")

    converged <- (max_t_ratio < t_threshold) && (overall_conv < conv_threshold)

    if (converged) {
      cat("✓ Convergence achieved!\n")
      final_result <- current_result
      break
    }

    iteration <- iteration + 1
  }

  if (!converged) {
    cat("⚠ Warning: Maximum iterations reached without convergence\n")
    cat("Consider adjusting algorithm parameters or model specification\n")
    final_result <- current_result
  }
}

# =============================================================================
# 6. FINAL CONVERGENCE REPORT
# =============================================================================

cat("\n=== Final Convergence Report ===\n")

final_summary <- summary(final_result)
final_t_ratios <- abs(final_summary$tstat)
final_max_t <- max(final_t_ratios, na.rm = TRUE)
final_conv <- final_summary$tconv.max

cat("Final convergence status:\n")
cat("  - Maximum t-ratio:", round(final_max_t, 3), "(target < 0.1)\n")
cat("  - Overall convergence ratio:", round(final_conv, 3), "(target < 0.25)\n")

if (final_max_t < 0.1 && final_conv < 0.25) {
  cat("✓ EXCELLENT convergence achieved\n")
} else if (final_max_t < 0.15 && final_conv < 0.35) {
  cat("✓ Acceptable convergence (nearly converged)\n")
} else {
  cat("⚠ Poor convergence - interpret results with caution\n")
}

# Detailed t-ratio report
cat("\nDetailed t-ratio report:\n")
effect_names <- rownames(final_summary$theta)
for (i in seq_along(final_t_ratios)) {
  if (!is.na(final_t_ratios[i])) {
    status <- if (final_t_ratios[i] < 0.1) "✓" else "⚠"
    cat(sprintf("  %s %s: %.3f\n", status, effect_names[i], final_t_ratios[i]))
  }
}

# =============================================================================
# 7. PARAMETER ESTIMATES
# =============================================================================

cat("\n=== Parameter Estimates ===\n")

# Extract parameter table
param_table <- final_summary$theta
param_df <- data.frame(
  Effect = rownames(param_table),
  Estimate = param_table[, "Estimate"],
  SE = param_table[, "Standard Error"],
  t_ratio = param_table[, "t-statistic"],
  t_conv = final_t_ratios
)

print(param_df, digits = 3)

# =============================================================================
# 8. SAVE RESULTS
# =============================================================================

cat("\nSaving estimation results...\n")

# Create output directories
output_dirs <- c("outputs/models", "outputs/tables", "outputs/reports")
for (dir in output_dirs) {
  if (!dir.exists(here(dir))) {
    dir.create(here(dir), recursive = TRUE)
  }
}

# Save model object
model_file <- here("outputs", "models", "baseline_model.rds")
saveRDS(final_result, model_file)
cat("Model saved to:", model_file, "\n")

# Save parameter estimates
params_file <- here("outputs", "tables", "parameter_estimates.csv")
write_csv(param_df, params_file)
cat("Parameters saved to:", params_file, "\n")

# Save convergence summary
conv_summary <- data.frame(
  Metric = c("Max t-ratio", "Overall convergence", "Converged", "Iterations"),
  Value = c(final_max_t, final_conv, converged,
            if (exists("iteration")) iteration else 1)
)
conv_file <- here("outputs", "tables", "convergence_summary.csv")
write_csv(conv_summary, conv_file)
cat("Convergence summary saved to:", conv_file, "\n")

# =============================================================================
# 9. SESSION INFO
# =============================================================================

cat("\n=== Estimation Complete ===\n")
cat("Timestamp:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("Total estimation time:", round(as.numeric(difftime(Sys.time(), start_time, units = "mins")), 2), "minutes\n")

cat("\nNext steps:\n")
cat("1. Review parameter estimates in outputs/tables/parameter_estimates.csv\n")
cat("2. Check goodness-of-fit: Rscript R/diagnostics/gof_assessment.R\n")
cat("3. Test time heterogeneity: Rscript R/diagnostics/time_heterogeneity.R\n")
cat("4. Run intervention simulations if model is satisfactory\n")

cat("\n=== End Estimation ===\n")