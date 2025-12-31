# Main Analysis Pipeline for Tolerance Intervention SAOM Research
# Network Dynamics of Tolerance: Attraction-Repulsion Models
#
# Purpose: Orchestrate complete analysis from data to publication
# Objectives: (1) Estimate friend-based attraction-repulsion models
#            (2) Simulate intervention scenarios for design optimization
#
# Assumptions for valid inference:
# - Correct specification of endogenous/exogenous effects
# - Network stability (Jaccard > 0.30)
# - Convergence to RSiena standards (t-ratios < 0.10)
#
# Model space: Baseline, attraction-repulsion, complex contagion variants
# Prior sensitivity: Test latitude thresholds τ₁ ∈ [0.5, 1.5], τ₂ ∈ [2.0, 3.0]
#
# Reproducibility: Seed 20250917, RSiena 1.4.0+, R 4.3+

# =============================================================================
# SETUP
# =============================================================================

library(RSiena)
library(tidyverse)
library(here)
library(targets)
library(parallel)
library(ggplot2)
library(ggdist)
library(ggraph)
library(tidygraph)
library(patchwork)

# Set seed for reproducibility
set.seed(20250917)

# Source all utility functions
source(here("R", "utils", "data_helpers.R"))
source(here("R", "utils", "rsiena_helpers.R"))
source(here("R", "utils", "plotting_helpers.R"))

cat("======================================\n")
cat("TOLERANCE INTERVENTION SAOM ANALYSIS\n")
cat("======================================\n")
cat("Timestamp:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")

# =============================================================================
# PHASE 1: DATA PREPARATION
# =============================================================================

cat("PHASE 1: Data Preparation\n")
cat("--------------------------\n")

# Load or simulate data
if (file.exists(here("data", "raw", "together_tolerance.rds"))) {
  cat("Loading empirical data...\n")
  source(here("R", "data_processing", "01_load_empirical.R"))
} else {
  cat("Empirical data not found. Creating synthetic data...\n")
  source(here("R", "data_processing", "01_simulate_data.R"))
}

# Validate data quality
source(here("R", "data_processing", "02_validate_data.R"))

# Create RSiena objects
source(here("R", "data_processing", "03_create_siena.R"))

# Generate data quality report
print01Report(siena_data, modelname = "01_data_quality")

# Check Jaccard stability
jaccard_check <- check_jaccard_stability(siena_data)
if (any(jaccard_check$jaccard < 0.30)) {
  warning("Low Jaccard stability detected. SAOM may not be appropriate.")
  cat("Jaccard values:\n")
  print(jaccard_check)
}

cat("\n✓ Phase 1 complete: Data prepared and validated\n\n")

# =============================================================================
# PHASE 2: BASELINE MODEL ESTIMATION
# =============================================================================

cat("PHASE 2: Baseline Model Estimation\n")
cat("-----------------------------------\n")

# Specify baseline effects
effects <- getEffects(siena_data)

# Network dynamics
effects <- includeEffects(effects,
  density,      # outdegree
  recip,        # reciprocity
  transTrip,    # transitive triplets
  cycle3,       # 3-cycles
  name = "friendship"
)

# Selection effects (network formation based on attributes)
effects <- includeEffects(effects,
  simX,         # ethnic homophily
  name = "friendship",
  interaction1 = "ethnicity"
)

effects <- includeEffects(effects,
  egoX, altX,   # gender effects
  name = "friendship",
  interaction1 = "gender"
)

# Behavior dynamics (tolerance evolution)
effects <- includeEffects(effects,
  linear, quad,  # shape effects
  name = "tolerance"
)

# Basic influence (to be replaced with custom effect)
effects <- includeEffects(effects,
  avAlt,        # average alter effect
  name = "tolerance",
  interaction1 = "friendship"
)

# Algorithm with conservative settings
algo <- sienaAlgorithmCreate(
  projname = "baseline_tolerance",
  useStdInits = TRUE,
  nsub = 4,
  n3 = 3000,
  seed = 20250917
)

# Estimate with convergence protocol
cat("Estimating baseline model...\n")
baseline_fit <- siena07(algo, data = siena_data, effects = effects,
                        batch = FALSE, verbose = TRUE)

# Convergence continuation
iteration <- 1
while (baseline_fit$tconv.max > 0.25 || any(abs(baseline_fit$tstat) > 0.10)) {
  cat(sprintf("Iteration %d: max convergence ratio = %.3f\n",
              iteration, baseline_fit$tconv.max))

  algo_cont <- sienaAlgorithmCreate(
    projname = sprintf("baseline_cont_%d", iteration),
    useStdInits = FALSE,
    nsub = 4,
    n3 = 5000
  )

  baseline_fit <- siena07(algo_cont, data = siena_data, effects = effects,
                         prevAns = baseline_fit, batch = FALSE)
  iteration <- iteration + 1

  if (iteration > 10) {
    stop("Failed to achieve convergence after 10 iterations")
  }
}

cat("\n✓ Baseline model converged\n")
cat(sprintf("  Max convergence ratio: %.4f\n", baseline_fit$tconv.max))
cat(sprintf("  Max t-ratio: %.4f\n", max(abs(baseline_fit$tstat))))

# Save baseline results
saveRDS(baseline_fit, here("outputs", "models", "baseline_fit.rds"))

# =============================================================================
# PHASE 3: GOODNESS OF FIT
# =============================================================================

cat("\nPHASE 3: Goodness of Fit Assessment\n")
cat("------------------------------------\n")

# Degree distributions
gof_indegree <- sienaGOF(baseline_fit, IndegreeDistribution,
                         verbose = TRUE, join = TRUE,
                         varName = "friendship")

gof_outdegree <- sienaGOF(baseline_fit, OutdegreeDistribution,
                          verbose = TRUE, join = TRUE,
                          varName = "friendship")

# Geodesic distances
gof_geodesic <- sienaGOF(baseline_fit, GeodesicDistribution,
                         verbose = TRUE, join = TRUE,
                         varName = "friendship")

# Triad census
gof_triads <- sienaGOF(baseline_fit, TriadCensus,
                       verbose = TRUE, join = TRUE,
                       varName = "friendship")

# Behavior distribution
gof_behavior <- sienaGOF(baseline_fit, BehaviorDistribution,
                         verbose = TRUE, join = TRUE,
                         varName = "tolerance")

# Create GOF plots
pdf(here("outputs", "figures", "gof_baseline.pdf"), width = 12, height = 8)
par(mfrow = c(2, 3))
plot(gof_indegree, main = "Indegree Distribution")
plot(gof_outdegree, main = "Outdegree Distribution")
plot(gof_geodesic, main = "Geodesic Distribution")
plot(gof_triads, main = "Triad Census")
plot(gof_behavior, main = "Tolerance Distribution")
dev.off()

# Report GOF p-values
cat("\nGOF p-values:\n")
cat(sprintf("  Indegree: %.3f\n", gof_indegree$p))
cat(sprintf("  Outdegree: %.3f\n", gof_outdegree$p))
cat(sprintf("  Geodesic: %.3f\n", gof_geodesic$p))
cat(sprintf("  Triads: %.3f\n", gof_triads$p))
cat(sprintf("  Behavior: %.3f\n", gof_behavior$p))

if (any(c(gof_indegree$p, gof_outdegree$p, gof_geodesic$p,
         gof_triads$p, gof_behavior$p) < 0.05)) {
  warning("Some GOF tests indicate poor fit. Model refinement may be needed.")
}

cat("\n✓ Phase 3 complete: GOF assessment done\n\n")

# =============================================================================
# PHASE 4: TIME HETEROGENEITY TEST
# =============================================================================

cat("PHASE 4: Time Heterogeneity Testing\n")
cat("------------------------------------\n")

if (n_waves >= 3) {
  time_test <- sienaTimeTest(baseline_fit)
  print(time_test)

  # If heterogeneity detected, add time dummies
  if (time_test$chi2 > qchisq(0.95, time_test$df)) {
    cat("Time heterogeneity detected. Adding time dummies...\n")

    # Add time dummies for key effects
    effects_td <- includeTimeDummy(effects,
      recip, transTrip, avAlt,
      timeDummy = "2",
      name = c("friendship", "friendship", "tolerance")
    )

    # Re-estimate with time dummies
    td_fit <- siena07(algo, data = siena_data, effects = effects_td,
                     prevAns = baseline_fit, batch = FALSE)

    saveRDS(td_fit, here("outputs", "models", "td_fit.rds"))
  }
}

cat("\n✓ Phase 4 complete: Time heterogeneity tested\n\n")

# =============================================================================
# PHASE 5: CUSTOM EFFECTS MODEL
# =============================================================================

cat("PHASE 5: Custom Effects Model\n")
cat("------------------------------\n")

# Note: This requires C++ implementation of attraction-repulsion effect
# For now, we approximate with existing effects

cat("Note: Custom attraction-repulsion effects require C++ implementation\n")
cat("Using approximation with existing RSiena effects\n")

# Alternative specification with similarity and interaction effects
effects_custom <- effects

# Add similarity-based influence with quadratic interaction
effects_custom <- includeEffects(effects_custom,
  avSim,        # average similarity effect
  name = "tolerance",
  interaction1 = "friendship"
)

# Estimate custom model
custom_fit <- siena07(algo, data = siena_data, effects = effects_custom,
                     prevAns = baseline_fit, batch = FALSE)

# Continue to convergence
iteration <- 1
while (custom_fit$tconv.max > 0.25 || any(abs(custom_fit$tstat) > 0.10)) {
  cat(sprintf("Custom model iteration %d: max convergence = %.3f\n",
              iteration, custom_fit$tconv.max))

  custom_fit <- siena07(algo_cont, data = siena_data, effects = effects_custom,
                       prevAns = custom_fit, batch = FALSE)
  iteration <- iteration + 1

  if (iteration > 10) break
}

saveRDS(custom_fit, here("outputs", "models", "custom_fit.rds"))

cat("\n✓ Phase 5 complete: Custom effects model estimated\n\n")

# =============================================================================
# PHASE 6: INTERVENTION SIMULATION
# =============================================================================

cat("PHASE 6: Intervention Scenario Simulation\n")
cat("------------------------------------------\n")

# Define intervention scenarios
scenarios <- expand.grid(
  tolerance_change = c(1, 2, 3),      # SD units
  target_size = c(0.10, 0.25, 0.50),  # proportion
  target_strategy = c("central", "peripheral", "random"),
  contagion_type = c("simple", "complex"),
  delivery = c("clustered", "dispersed")
)

cat(sprintf("Testing %d intervention scenarios...\n", nrow(scenarios)))

# Simulation algorithm
sim_algo <- sienaAlgorithmCreate(
  projname = "intervention_sim",
  simOnly = TRUE,
  nsub = 0,
  n3 = 1000,
  seed = 20250917
)

# Run simulations (parallel if possible)
if (parallel::detectCores() > 1) {
  cl <- makeCluster(min(4, detectCores() - 1))
  clusterEvalQ(cl, library(RSiena))

  sim_results <- parLapply(cl, 1:nrow(scenarios), function(i) {
    run_intervention_scenario(
      scenarios[i, ],
      baseline_fit,
      siena_data,
      sim_algo
    )
  })

  stopCluster(cl)
} else {
  sim_results <- lapply(1:nrow(scenarios), function(i) {
    cat(sprintf("  Scenario %d/%d\n", i, nrow(scenarios)))
    run_intervention_scenario(
      scenarios[i, ],
      baseline_fit,
      siena_data,
      sim_algo
    )
  })
}

# Combine results
intervention_results <- bind_rows(sim_results)
saveRDS(intervention_results, here("outputs", "simulations",
                                   "intervention_results.rds"))

cat("\n✓ Phase 6 complete: Intervention simulations done\n\n")

# =============================================================================
# PHASE 7: VISUALIZATION
# =============================================================================

cat("PHASE 7: Creating Publication Figures\n")
cat("--------------------------------------\n")

source(here("R", "visualization", "create_figures.R"))

# Figure 1: Model parameters with uncertainty
create_parameter_plot(baseline_fit, custom_fit)

# Figure 2: Intervention effectiveness surface
create_intervention_surface(intervention_results)

# Figure 3: Network evolution visualization
create_network_evolution(siena_data, baseline_fit)

# Figure 4: GOF diagnostic panel
create_gof_panel(gof_indegree, gof_outdegree, gof_geodesic, gof_triads)

cat("\n✓ Phase 7 complete: Figures created\n\n")

# =============================================================================
# PHASE 8: SUMMARY REPORT
# =============================================================================

cat("PHASE 8: Generating Summary Report\n")
cat("-----------------------------------\n")

# Create results summary
summary_stats <- list(
  n_actors = nrow(siena_data$depvars$friendship),
  n_waves = ncol(siena_data$depvars$tolerance),
  n_classes = length(unique(siena_data$cCovars$class)),
  baseline_convergence = baseline_fit$tconv.max,
  baseline_effects = summary(baseline_fit),
  best_intervention = intervention_results %>%
    filter(cooperation_increase == max(cooperation_increase)) %>%
    slice(1),
  computational_time = Sys.time()
)

# Save summary
saveRDS(summary_stats, here("outputs", "summary_statistics.rds"))

# Generate LaTeX tables
source(here("R", "tables", "create_tables.R"))
create_model_table(baseline_fit, custom_fit)
create_intervention_table(intervention_results)

cat("\n✓ Phase 8 complete: Summary report generated\n\n")

# =============================================================================
# COMPLETION
# =============================================================================

cat("======================================\n")
cat("ANALYSIS COMPLETE\n")
cat("======================================\n")
cat("\nKey findings:\n")
cat(sprintf("  - Baseline model converged: %.3f\n", baseline_fit$tconv.max))
cat(sprintf("  - Best intervention: %s targeting, %.0f%% coverage\n",
           summary_stats$best_intervention$target_strategy,
           summary_stats$best_intervention$target_size * 100))
cat(sprintf("  - Cooperation increase: %.2f%%\n",
           summary_stats$best_intervention$cooperation_increase * 100))

cat("\nOutputs saved to:\n")
cat("  - Models: outputs/models/\n")
cat("  - Figures: outputs/figures/\n")
cat("  - Tables: outputs/tables/\n")
cat("  - Simulations: outputs/simulations/\n")

cat("\nNext steps:\n")
cat("  1. Review GOF diagnostics\n")
cat("  2. Validate intervention assumptions\n")
cat("  3. Write manuscript sections\n")
cat("  4. Prepare OSF repository\n")

cat("\nReproducibility information:\n")
sessionInfo()

# Annotated code provided for replication and extension