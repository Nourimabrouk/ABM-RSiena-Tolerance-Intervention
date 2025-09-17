# Tolerance Intervention Modeling for Interethnic Cooperation
# Part of PhD dissertation on social norm interventions
# Author: Your Name
# Date: September 17, 2025

library(RSiena)
library(tidyverse)
library(ggplot2)
library(ggdist)
library(parallel)

# Load helper functions
source("R/utils/rsiena_helpers.R")
source("R/utils/plotting_helpers.R")

#' Model Tolerance Intervention Effects
#'
#' This script implements intervention scenarios for tolerance promotion
#' Based on the Together for Tolerance study design (Shani et al., 2023)
#'
#' Research Question: How can individual-level changes in tolerance from
#' interventions spread and persist in social networks to increase sustained
#' interethnic cooperation?

# Set reproducible seed
set.seed(20250917)

#' Intervention Design Parameters
#' Testing different aspects of intervention design:
#' 1. Tolerance change magnitude
#' 2. Target group size
#' 3. Targeting strategy (central vs. peripheral actors)
#' 4. Contagion type (simple vs. complex)
#' 5. Delivery strategy (clustered vs. random)

intervention_scenarios <- list(
  # Magnitude of change
  change_small = list(tolerance_increase = 0.5),
  change_medium = list(tolerance_increase = 1.0),
  change_large = list(tolerance_increase = 1.5),

  # Target group size (proportion of network)
  size_small = list(target_proportion = 0.1),
  size_medium = list(target_proportion = 0.2),
  size_large = list(target_proportion = 0.3),

  # Targeting strategy
  strategy_central = list(target_by = "eigenvector_centrality"),
  strategy_popular = list(target_by = "indegree_centrality"),
  strategy_bridges = list(target_by = "betweenness_centrality"),
  strategy_random = list(target_by = "random"),

  # Contagion type
  contagion_simple = list(threshold = 1),
  contagion_complex = list(threshold = 2)
)

#' Load baseline fitted model
#' This should be the converged model from 02_estimation.R
baseline_fit <- readRDS("outputs/models/baseline_fit.rds")

#' Intervention Implementation Functions

#' Apply tolerance intervention to selected actors
#' @param network_data RSiena data object
#' @param target_ids Vector of actor IDs to receive intervention
#' @param tolerance_increase Amount to increase tolerance (scale units)
#' @return Modified RSiena data object with intervention applied
apply_tolerance_intervention <- function(network_data, target_ids, tolerance_increase) {
  # Implementation depends on specific data structure
  # This is a template for the intervention application

  # Extract tolerance behavior data
  tolerance_data <- network_data$depvars$tolerance

  # Apply intervention to wave 2 (intervention period)
  # Increase tolerance for targeted actors
  tolerance_data[target_ids, 2] <- pmin(
    tolerance_data[target_ids, 2] + tolerance_increase,
    max(tolerance_data, na.rm = TRUE)  # Cap at maximum scale value
  )

  # Update RSiena data object
  modified_data <- network_data
  modified_data$depvars$tolerance <- tolerance_data

  return(modified_data)
}

#' Select intervention targets based on strategy
#' @param network Wave 1 network matrix
#' @param strategy Targeting strategy ("random", "central", etc.)
#' @param proportion Proportion of network to target
#' @return Vector of actor IDs to target
select_intervention_targets <- function(network, strategy, proportion) {
  n_actors <- nrow(network)
  n_targets <- round(n_actors * proportion)

  if (strategy == "random") {
    return(sample(1:n_actors, n_targets))
  }

  # Calculate centrality measures using igraph
  g <- igraph::graph_from_adjacency_matrix(network, mode = "directed")

  centrality_scores <- switch(strategy,
    "eigenvector_centrality" = igraph::eigen_centrality(g)$vector,
    "indegree_centrality" = igraph::degree(g, mode = "in"),
    "betweenness_centrality" = igraph::betweenness(g),
    "outdegree_centrality" = igraph::degree(g, mode = "out")
  )

  # Select top actors by centrality
  top_actors <- order(centrality_scores, decreasing = TRUE)[1:n_targets]
  return(top_actors)
}

#' Simulate intervention scenarios
#' @param scenario_name Name of scenario for output
#' @param parameters List of intervention parameters
#' @return Simulation results
simulate_intervention_scenario <- function(scenario_name, parameters) {
  cat("Simulating scenario:", scenario_name, "\n")

  # Load original data
  original_data <- readRDS("data/processed/siena_data.rds")

  # Extract wave 1 network for targeting
  wave1_network <- original_data$depvars$friendship[,,1]

  # Select targets based on strategy
  if ("target_by" %in% names(parameters)) {
    target_ids <- select_intervention_targets(
      wave1_network,
      parameters$target_by,
      parameters$target_proportion %||% 0.2
    )
  } else {
    # Random selection if no strategy specified
    n_targets <- round(nrow(wave1_network) * 0.2)
    target_ids <- sample(1:nrow(wave1_network), n_targets)
  }

  # Apply intervention
  intervention_data <- apply_tolerance_intervention(
    original_data,
    target_ids,
    parameters$tolerance_increase %||% 1.0
  )

  # Run forward simulation
  # Use baseline model parameters with modified initial conditions
  sim_algorithm <- sienaAlgorithmCreate(
    projname = paste0("intervention_", scenario_name),
    cond = FALSE,
    useStdInits = FALSE,
    nsub = 0,
    simOnly = TRUE,
    n3 = 1000
  )

  # Extract effects from baseline fit
  baseline_effects <- baseline_fit$effects

  # Run simulation
  sim_results <- siena07(
    sim_algorithm,
    data = intervention_data,
    effects = baseline_effects,
    returnDeps = TRUE,
    silent = TRUE
  )

  # Store results
  results <- list(
    scenario = scenario_name,
    parameters = parameters,
    target_ids = target_ids,
    simulation = sim_results,
    timestamp = Sys.time()
  )

  # Save individual scenario results
  saveRDS(results, file.path("outputs/simulations", paste0(scenario_name, "_results.rds")))

  return(results)
}

#' Main Intervention Analysis
#' Run all intervention scenarios and compare outcomes

# Initialize parallel processing
if (parallel::detectCores() > 1) {
  cl <- makeCluster(min(4, parallel::detectCores() - 1))
  clusterEvalQ(cl, {
    library(RSiena)
    library(igraph)
    source("R/utils/rsiena_helpers.R")
  })
  on.exit(stopCluster(cl))
}

# Run intervention scenarios
cat("Running tolerance intervention scenarios...\n")
cat("Total scenarios:", length(intervention_scenarios), "\n")

intervention_results <- map(
  names(intervention_scenarios),
  ~simulate_intervention_scenario(.x, intervention_scenarios[[.x]])
)
names(intervention_results) <- names(intervention_scenarios)

# Combine and analyze results
combined_results <- list(
  scenarios = intervention_results,
  baseline_fit = baseline_fit,
  analysis_timestamp = Sys.time(),
  session_info = sessionInfo()
)

# Save combined results
saveRDS(combined_results, "outputs/models/intervention_analysis.rds")

#' Intervention Outcome Analysis
#' Compare tolerance diffusion and cooperation outcomes across scenarios

analyze_intervention_outcomes <- function(results) {
  # Extract key metrics from each scenario
  outcome_metrics <- map_dfr(results$scenarios, function(scenario) {
    sim_nets <- scenario$simulation$sims

    # Calculate final tolerance levels
    final_tolerance <- sim_nets[[1]]$depvars$tolerance[,3]  # Wave 3

    # Calculate cooperation network density
    final_coop <- sim_nets[[1]]$depvars$cooperation[,,3]  # Wave 3 cooperation
    coop_density <- sum(final_coop, na.rm = TRUE) / (nrow(final_coop) * (nrow(final_coop) - 1))

    # Interethnic cooperation specifically
    # (This would need ethnicity covariate data)

    tibble(
      scenario = scenario$scenario,
      mean_tolerance = mean(final_tolerance, na.rm = TRUE),
      sd_tolerance = sd(final_tolerance, na.rm = TRUE),
      cooperation_density = coop_density,
      n_targets = length(scenario$target_ids),
      intervention_magnitude = scenario$parameters$tolerance_increase %||% NA
    )
  })

  return(outcome_metrics)
}

# Generate outcome analysis
outcome_analysis <- analyze_intervention_outcomes(combined_results)
write_csv(outcome_analysis, "outputs/tables/intervention_outcomes.csv")

# Generate intervention summary report
cat("Tolerance Intervention Analysis Complete\n")
cat("Results saved to outputs/models/intervention_analysis.rds\n")
cat("Outcome metrics saved to outputs/tables/intervention_outcomes.csv\n")
cat("Next steps: Review results and generate visualizations\n")

# Clean up
gc()