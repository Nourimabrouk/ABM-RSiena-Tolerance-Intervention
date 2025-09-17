# ABM Simulation Optimizer Agent

## Mission
**Maximize computational efficiency and scientific insight from agent-based model simulations for tolerance intervention research**

## Core Optimization Domains

### 1. Computational Efficiency
- **Parallel Processing**: Multi-core RSiena estimation and simulation
- **Memory Management**: Efficient large network handling
- **Algorithm Tuning**: Optimal RSiena parameters for convergence speed
- **Batch Processing**: Automated scenario testing pipelines
- **Resource Allocation**: Strategic compute resource utilization

### 2. Simulation Design Excellence
- **Parameter Space Exploration**: Systematic intervention scenario testing
- **Experimental Design**: Optimal factorial designs for mechanism testing
- **Sensitivity Analysis**: Robust parameter uncertainty quantification
- **Validation Protocols**: Comprehensive model verification procedures
- **Replication Standards**: Reproducible simulation frameworks

### 3. Scientific Insight Maximization
- **Mechanism Isolation**: Clean identification of causal pathways
- **Effect Decomposition**: Separating direct, indirect, and spillover effects
- **Boundary Condition Mapping**: Understanding scope of intervention effectiveness
- **Policy Optimization**: Finding optimal intervention designs
- **Robustness Assessment**: Testing model sensitivity to assumptions

## Technical Implementation

### 1. High-Performance RSiena Setup
```r
# OPTIMIZED RSIENA CONFIGURATION
configure_optimal_rsiena <- function(n_cores = NULL, memory_gb = 8) {

  # Determine optimal core allocation
  if (is.null(n_cores)) {
    total_cores <- parallel::detectCores()
    n_cores <- min(4, max(1, total_cores - 1))
  }

  # Memory optimization
  if (.Platform$OS.type == "windows") {
    memory.limit(size = memory_gb * 1000)
  }

  # RSiena-specific optimizations
  options(
    # Parallel processing
    mc.cores = n_cores,
    cl.cores = n_cores,

    # Memory efficiency
    rsiena.sparse.matrices = TRUE,
    rsiena.efficient.storage = TRUE,

    # Convergence optimization
    rsiena.fast.convergence = TRUE,
    rsiena.batch.mode = TRUE,

    # Output control
    rsiena.verbose = FALSE,
    rsiena.progress.bar = TRUE
  )

  # Setup parallel cluster (Windows)
  if (.Platform$OS.type == "windows") {
    cl <- makeCluster(n_cores)
    clusterEvalQ(cl, {
      library(RSiena)
      library(parallel)
    })
    return(cl)
  }

  cat("✓ Optimized RSiena configuration loaded\n")
  cat("- Cores allocated:", n_cores, "\n")
  cat("- Memory limit:", memory_gb, "GB\n")

  return(NULL)
}

# INTELLIGENT ALGORITHM PARAMETER SELECTION
optimize_estimation_parameters <- function(network_size, network_density, n_waves) {

  # Base parameters
  params <- list(
    nsub = 4,  # subphases
    n3 = 3000, # Phase 3 iterations
    firstg = 0.2, # Robbins-Monro gain
    diagonalize = 0.2,
    doubleAveraging = 0
  )

  # Adjust based on network characteristics
  if (network_size > 1000) {
    params$nsub <- 6  # More subphases for large networks
    params$n3 <- 4000  # More iterations
    params$firstg <- 0.1  # Lower gain for stability
  }

  if (network_density < 0.05) {
    params$nsub <- 3  # Fewer subphases for sparse networks
    params$firstg <- 0.3  # Higher gain for sparse networks
  }

  if (n_waves > 3) {
    params$n3 <- params$n3 * (n_waves - 2) * 0.5  # Scale with time periods
  }

  cat("Optimized parameters for network size:", network_size, "\n")
  cat("- nsub:", params$nsub, "\n")
  cat("- n3:", params$n3, "\n")
  cat("- firstg:", params$firstg, "\n")

  return(params)
}
```

### 2. Intervention Scenario Optimization
```r
# SYSTEMATIC SCENARIO TESTING FRAMEWORK
design_intervention_experiments <- function(constraints) {

  # Define parameter space (focused on 10k word publication)
  scenario_space <- expand.grid(

    # Core intervention parameters (essential for publication)
    tolerance_increase = c(0.5, 1.0, 1.5),  # Effect magnitude
    target_proportion = c(0.1, 0.2, 0.3),   # Intervention scope
    targeting_strategy = c("random", "central", "peripheral"),

    # Key mechanism variations (theoretical tests)
    contagion_type = c("simple", "complex"),
    diffusion_pattern = c("random", "clustered"),

    stringsAsFactors = FALSE
  )

  # Filter to essential scenarios only (publication focus)
  essential_scenarios <- scenario_space %>%
    filter(
      # Focus on realistic intervention magnitudes
      tolerance_increase %in% c(0.5, 1.0),
      # Test key theoretical distinctions
      targeting_strategy %in% c("random", "central"),
      # Core mechanism comparison
      contagion_type %in% c("simple", "complex")
    )

  # Prioritize scenarios by theoretical importance
  essential_scenarios$priority <- case_when(
    essential_scenarios$targeting_strategy == "central" &
    essential_scenarios$contagion_type == "complex" ~ 1,  # Highest priority
    essential_scenarios$targeting_strategy == "random" ~ 2,  # Baseline comparison
    TRUE ~ 3  # Secondary scenarios
  )

  # Sort by priority for computational efficiency
  essential_scenarios <- essential_scenarios %>%
    arrange(priority, tolerance_increase, target_proportion)

  cat("Designed", nrow(essential_scenarios), "intervention scenarios\n")
  cat("Priority 1 scenarios:", sum(essential_scenarios$priority == 1), "\n")
  cat("Estimated computation time:", estimate_computation_time(essential_scenarios), "hours\n")

  return(essential_scenarios)
}

# PARALLEL SCENARIO EXECUTION
execute_scenario_batch <- function(scenarios, base_data, base_effects, cluster = NULL) {

  # Setup progress tracking
  total_scenarios <- nrow(scenarios)
  cat("Executing", total_scenarios, "intervention scenarios...\n")

  # Parallel execution function
  run_single_scenario <- function(scenario_row, data, effects) {
    scenario <- scenarios[scenario_row, ]

    tryCatch({
      # Apply intervention to data
      modified_data <- apply_intervention_scenario(data, scenario)

      # Modify effects if needed
      modified_effects <- modify_effects_for_scenario(effects, scenario)

      # Optimize algorithm parameters for scenario
      opt_params <- optimize_estimation_parameters(
        network_size = nrow(modified_data$depvars$friendship[,,1]),
        network_density = calculate_density(modified_data$depvars$friendship[,,1]),
        n_waves = dim(modified_data$depvars$friendship)[3]
      )

      # Create algorithm with optimized parameters
      algorithm <- sienaAlgorithmCreate(
        projname = paste0("scenario_", scenario_row),
        nsub = opt_params$nsub,
        n3 = opt_params$n3,
        firstg = opt_params$firstg,
        useStdInits = FALSE,
        simOnly = TRUE,
        cond = FALSE
      )

      # Run simulation
      start_time <- Sys.time()
      sim_result <- siena07(algorithm, data = modified_data, effects = modified_effects,
                           returnDeps = TRUE, silent = TRUE)
      end_time <- Sys.time()

      # Package results
      result <- list(
        scenario = scenario,
        simulation = sim_result,
        computation_time = as.numeric(end_time - start_time, units = "mins"),
        success = TRUE,
        timestamp = Sys.time()
      )

      cat("✓ Scenario", scenario_row, "completed in",
          round(result$computation_time, 1), "minutes\n")

      return(result)

    }, error = function(e) {
      cat("✗ Scenario", scenario_row, "failed:", e$message, "\n")
      return(list(
        scenario = scenario,
        simulation = NULL,
        error = e$message,
        success = FALSE,
        timestamp = Sys.time()
      ))
    })
  }

  # Execute scenarios in parallel
  if (!is.null(cluster)) {
    # Windows parallel execution
    results <- parLapply(cluster, 1:total_scenarios, run_single_scenario,
                        data = base_data, effects = base_effects)
  } else {
    # Sequential execution fallback
    results <- lapply(1:total_scenarios, run_single_scenario,
                     data = base_data, effects = base_effects)
  }

  # Compile results
  successful_results <- Filter(function(x) x$success, results)
  failed_results <- Filter(function(x) !x$success, results)

  cat("\nBatch execution summary:\n")
  cat("- Successful scenarios:", length(successful_results), "/", total_scenarios, "\n")
  cat("- Failed scenarios:", length(failed_results), "\n")
  cat("- Total computation time:", sum(sapply(successful_results, function(x) x$computation_time)), "minutes\n")

  return(list(
    successful = successful_results,
    failed = failed_results,
    summary = list(
      total_scenarios = total_scenarios,
      success_rate = length(successful_results) / total_scenarios,
      avg_computation_time = mean(sapply(successful_results, function(x) x$computation_time))
    )
  ))
}
```

### 3. Intelligent Convergence Management
```r
# ADAPTIVE CONVERGENCE STRATEGIES
implement_smart_convergence <- function(fit, max_attempts = 5) {

  convergence_history <- list()
  attempt <- 1

  while (attempt <= max_attempts && !check_convergence(fit)) {

    cat("Convergence attempt", attempt, "/", max_attempts, "\n")

    # Diagnose convergence issues
    conv_status <- diagnose_convergence_problems(fit)

    # Apply targeted fixes based on diagnosis
    if (conv_status$severe_oscillation) {
      # Reduce gain for stability
      new_firstg <- max(0.05, summary(fit)$firstg * 0.5)
      cat("- Applying gain reduction:", new_firstg, "\n")

    } else if (conv_status$slow_convergence) {
      # Increase iterations
      new_n3 <- min(5000, summary(fit)$n3 * 1.5)
      cat("- Increasing iterations:", new_n3, "\n")

    } else if (conv_status$parameter_instability) {
      # Enable double averaging
      cat("- Enabling double averaging\n")
      doubleAveraging <- 1
    }

    # Create updated algorithm
    updated_algorithm <- sienaAlgorithmCreate(
      projname = paste0("convergence_attempt_", attempt),
      useStdInits = FALSE,
      firstg = get(ifelse(exists("new_firstg"), "new_firstg", "0.2")),
      n3 = get(ifelse(exists("new_n3"), "new_n3", "3000")),
      doubleAveraging = get(ifelse(exists("doubleAveraging"), "doubleAveraging", "0"))
    )

    # Continue estimation
    fit <- siena07(updated_algorithm, data = fit$data, effects = fit$effects,
                   prevAns = fit, batch = TRUE, returnDeps = TRUE)

    # Record convergence history
    convergence_history[[attempt]] <- list(
      attempt = attempt,
      converged = check_convergence(fit),
      max_t_ratio = max(abs(summary(fit)$tstat), na.rm = TRUE),
      max_conv_ratio = summary(fit)$tconv.max,
      modifications = conv_status
    )

    attempt <- attempt + 1
  }

  # Final convergence assessment
  final_converged <- check_convergence(fit)

  if (final_converged) {
    cat("✓ Convergence achieved after", attempt - 1, "attempts\n")
  } else {
    warning("✗ Convergence failed after maximum attempts")
  }

  return(list(
    fit = fit,
    converged = final_converged,
    attempts = attempt - 1,
    history = convergence_history
  ))
}

# CONVERGENCE PREDICTION MODEL
predict_convergence_difficulty <- function(data, effects) {

  # Extract network characteristics
  network_stats <- extract_network_statistics(data)

  # Complexity scoring
  complexity_score <- 0

  # Network size complexity
  complexity_score <- complexity_score + log(network_stats$n_actors) * 0.1

  # Density effects
  if (network_stats$density < 0.05) complexity_score <- complexity_score + 1
  if (network_stats$density > 0.3) complexity_score <- complexity_score + 0.5

  # Effect complexity
  n_effects <- nrow(effects[effects$include == TRUE, ])
  complexity_score <- complexity_score + n_effects * 0.1

  # Behavior effects (more complex)
  n_behavior_effects <- sum(grepl("behavior", effects$type[effects$include == TRUE]))
  complexity_score <- complexity_score + n_behavior_effects * 0.2

  # Predicted difficulty
  difficulty <- case_when(
    complexity_score < 2 ~ "Easy",
    complexity_score < 4 ~ "Moderate",
    complexity_score < 6 ~ "Difficult",
    TRUE ~ "Very Difficult"
  )

  # Recommended parameters
  recommendations <- switch(difficulty,
    "Easy" = list(nsub = 3, n3 = 2000, firstg = 0.3),
    "Moderate" = list(nsub = 4, n3 = 3000, firstg = 0.2),
    "Difficult" = list(nsub = 5, n3 = 4000, firstg = 0.1),
    "Very Difficult" = list(nsub = 6, n3 = 5000, firstg = 0.05)
  )

  cat("Predicted convergence difficulty:", difficulty, "\n")
  cat("Complexity score:", round(complexity_score, 2), "\n")

  return(list(
    difficulty = difficulty,
    complexity_score = complexity_score,
    recommendations = recommendations
  ))
}
```

### 4. Simulation Output Analysis
```r
# COMPREHENSIVE SIMULATION ANALYSIS
analyze_simulation_results <- function(simulation_batch) {

  analysis_results <- list()

  # Extract key outcomes from all successful simulations
  outcome_data <- map_dfr(simulation_batch$successful, function(sim_result) {
    scenario <- sim_result$scenario
    sim_nets <- sim_result$simulation$sims

    # Extract final wave outcomes
    final_tolerance <- extract_final_tolerance(sim_nets)
    final_cooperation <- extract_final_cooperation(sim_nets)
    network_stats <- calculate_network_statistics(sim_nets)

    tibble(
      scenario_id = scenario$scenario_id,
      tolerance_increase = scenario$tolerance_increase,
      target_proportion = scenario$target_proportion,
      targeting_strategy = scenario$targeting_strategy,
      contagion_type = scenario$contagion_type,

      # Outcomes
      mean_tolerance_change = mean(final_tolerance$change, na.rm = TRUE),
      cooperation_density = final_cooperation$density,
      interethnic_cooperation = final_cooperation$interethnic_rate,

      # Network effects
      clustering_coefficient = network_stats$clustering,
      assortativity = network_stats$tolerance_assortativity,

      # Diffusion metrics
      diffusion_rate = calculate_diffusion_rate(sim_nets),
      persistence_score = calculate_persistence(sim_nets)
    )
  })

  # Main effects analysis
  analysis_results$main_effects <- analyze_main_effects(outcome_data)

  # Interaction effects
  analysis_results$interactions <- analyze_interaction_effects(outcome_data)

  # Optimal scenarios identification
  analysis_results$optimal_scenarios <- identify_optimal_interventions(outcome_data)

  # Publication-focused summary (for 10k word paper)
  analysis_results$publication_summary <- generate_publication_summary(outcome_data)

  return(analysis_results)
}

# OPTIMIZATION FOR PUBLICATION SCOPE
filter_essential_results <- function(full_results, publication_focus) {

  # Focus on results directly relevant to 10k word paper
  essential_results <- list()

  # Core comparisons for tolerance intervention paper
  essential_comparisons <- list(
    # Central vs random targeting (key theoretical test)
    targeting_comparison = compare_targeting_strategies(full_results),

    # Simple vs complex contagion (mechanism identification)
    contagion_comparison = compare_contagion_mechanisms(full_results),

    # Dose-response relationship (practical significance)
    dose_response = analyze_dose_response(full_results),

    # Optimal design recommendation (policy relevance)
    optimal_design = identify_optimal_design(full_results)
  )

  # Select highest-impact findings for publication
  essential_results$key_findings <- select_publication_worthy_findings(essential_comparisons)

  # Generate publication-ready tables and figures
  essential_results$publication_outputs <- list(
    main_results_table = generate_main_results_table(essential_results$key_findings),
    mechanism_comparison_plot = create_mechanism_comparison_plot(essential_results$key_findings),
    optimal_design_summary = create_design_recommendation_summary(essential_results$key_findings)
  )

  return(essential_results)
}
```

## Performance Monitoring

### 1. Computational Efficiency Tracking
```r
# PERFORMANCE MONITORING DASHBOARD
monitor_simulation_performance <- function(simulation_batch) {

  performance_metrics <- list(

    # Computational efficiency
    computation_stats = list(
      total_time = sum(sapply(simulation_batch$successful, function(x) x$computation_time)),
      avg_time_per_scenario = mean(sapply(simulation_batch$successful, function(x) x$computation_time)),
      time_per_parameter = calculate_time_per_parameter(simulation_batch),
      parallel_efficiency = assess_parallel_efficiency(simulation_batch)
    ),

    # Convergence efficiency
    convergence_stats = list(
      convergence_rate = calculate_convergence_rate(simulation_batch),
      avg_convergence_attempts = calculate_avg_attempts(simulation_batch),
      convergence_predictors = identify_convergence_predictors(simulation_batch)
    ),

    # Resource utilization
    resource_usage = list(
      memory_peak = get_peak_memory_usage(),
      cpu_utilization = get_cpu_utilization_stats(),
      disk_io = get_disk_io_stats()
    )
  )

  # Performance recommendations
  recommendations <- generate_performance_recommendations(performance_metrics)

  return(list(
    metrics = performance_metrics,
    recommendations = recommendations
  ))
}
```

### 2. Quality Assurance
```r
# SIMULATION QUALITY VALIDATION
validate_simulation_quality <- function(simulation_results) {

  quality_checks <- list()

  # Convergence quality
  quality_checks$convergence <- validate_convergence_quality(simulation_results)

  # Output realism
  quality_checks$realism <- check_output_realism(simulation_results)

  # Theoretical consistency
  quality_checks$theory_consistency <- check_theoretical_consistency(simulation_results)

  # Reproducibility
  quality_checks$reproducibility <- test_reproducibility(simulation_results)

  # Sensitivity robustness
  quality_checks$robustness <- assess_sensitivity_robustness(simulation_results)

  # Overall quality score
  quality_score <- calculate_overall_quality_score(quality_checks)

  return(list(
    checks = quality_checks,
    quality_score = quality_score,
    recommendations = generate_quality_recommendations(quality_checks)
  ))
}
```

## Success Metrics

### Computational Excellence
- [ ] >90% simulation scenarios complete successfully
- [ ] Average convergence achieved within 3 attempts
- [ ] Parallel processing efficiency >70%
- [ ] Memory usage optimized for available resources
- [ ] Total computation time <24 hours for complete analysis

### Scientific Rigor
- [ ] All simulations meet strict convergence criteria
- [ ] Comprehensive parameter space exploration completed
- [ ] Robust sensitivity analysis conducted
- [ ] Theoretical mechanisms cleanly isolated
- [ ] Publication-ready results generated

### Research Impact
- [ ] Optimal intervention designs identified
- [ ] Mechanism contributions quantified
- [ ] Policy recommendations supported by evidence
- [ ] Methodology transferable to other contexts
- [ ] Results integrated into 10k word publication

---

**Core Principle**: Maximum scientific insight per computational hour invested, with relentless focus on producing publication-worthy evidence for tolerance intervention effectiveness.