# _targets.R - Modern Reproducible Pipeline for Tolerance Intervention Research
# PhD dissertation project using RSiena and ggplot2 4.0.0
# Author: Your Name
# Date: September 17, 2025

# Load required packages
library(targets)
library(tarchetypes)
library(future)
library(crew)

# Configure parallel processing
if (parallel::detectCores() > 1) {
  tar_option_set(
    controller = crew_controller_local(workers = min(4, parallel::detectCores() - 1))
  )
}

# Source custom functions
source("R/utils/rsiena_helpers.R")
source("R/utils/plotting_helpers.R")

# Define global options
tar_option_set(
  packages = c(
    "RSiena", "RSienaTest", "network", "sna", "igraph",
    "tidyverse", "ggplot2", "ggdist", "ggraph", "tidygraph",
    "patchwork", "data.table", "parallel"
  ),
  format = "rds",
  seed = 20250917,
  storage = "worker",
  retrieval = "worker"
)

# Pipeline definition
list(
  # =============================================================================
  # DATA PREPARATION TARGETS
  # =============================================================================

  # Load raw data files
  tar_target(
    name = raw_wave1_data,
    command = read_csv("data/raw/wave1/friendship_tolerance.csv"),
    format = "file"
  ),

  tar_target(
    name = raw_wave2_data,
    command = read_csv("data/raw/wave2/friendship_tolerance.csv"),
    format = "file"
  ),

  tar_target(
    name = raw_wave3_data,
    command = read_csv("data/raw/wave3/friendship_tolerance.csv"),
    format = "file"
  ),

  # Process raw data into RSiena format
  tar_target(
    name = processed_networks,
    command = {
      source("R/siena_models/00_data_prep.R")
      create_siena_networks(raw_wave1_data, raw_wave2_data, raw_wave3_data)
    }
  ),

  tar_target(
    name = siena_data_object,
    command = {
      source("R/siena_models/00_data_prep.R")
      create_siena_data_object(processed_networks)
    }
  ),

  # Data quality checks
  tar_target(
    name = data_quality_report,
    command = {
      source("R/diagnostics/convergence_checks.R")
      generate_data_quality_report(siena_data_object)
    }
  ),

  # =============================================================================
  # MODEL DEVELOPMENT TARGETS
  # =============================================================================

  # Baseline model specification
  tar_target(
    name = baseline_effects,
    command = {
      source("R/siena_models/01_baseline.R")
      specify_baseline_effects(siena_data_object)
    }
  ),

  # Model estimation with convergence monitoring
  tar_target(
    name = baseline_fit,
    command = {
      source("R/siena_models/02_estimation.R")
      estimate_baseline_model(siena_data_object, baseline_effects)
    }
  ),

  # Convergence diagnostics
  tar_target(
    name = convergence_diagnostics,
    command = {
      source("R/diagnostics/convergence_checks.R")
      check_model_convergence(baseline_fit)
    }
  ),

  # Goodness-of-fit assessment
  tar_target(
    name = goodness_of_fit,
    command = {
      source("R/diagnostics/goodness_of_fit.R")
      assess_model_fit(baseline_fit, siena_data_object)
    }
  ),

  # =============================================================================
  # INTERVENTION ANALYSIS TARGETS
  # =============================================================================

  # Intervention scenario specifications
  tar_target(
    name = intervention_scenarios,
    command = {
      source("R/intervention/targeting_strategies.R")
      define_intervention_scenarios()
    }
  ),

  # Run intervention simulations
  tar_target(
    name = intervention_results,
    command = {
      source("R/siena_models/04_intervention.R")
      run_intervention_simulations(baseline_fit, intervention_scenarios)
    }
  ),

  # Analyze intervention outcomes
  tar_target(
    name = intervention_analysis,
    command = {
      source("R/intervention/diffusion_patterns.R")
      analyze_intervention_outcomes(intervention_results)
    }
  ),

  # =============================================================================
  # VISUALIZATION TARGETS
  # =============================================================================

  # Network descriptive plots
  tar_target(
    name = network_descriptive_plots,
    command = {
      source("R/visualization/network_plots.R")
      create_network_descriptive_plots(processed_networks)
    }
  ),

  # Tolerance evolution plots
  tar_target(
    name = tolerance_evolution_plots,
    command = {
      source("R/visualization/tolerance_plots.R")
      plot_tolerance_evolution(processed_networks)
    }
  ),

  # Model convergence plots
  tar_target(
    name = convergence_plots,
    command = {
      source("R/visualization/tolerance_plots.R")
      plot_convergence_diagnostics(convergence_diagnostics)
    }
  ),

  # Intervention effect plots
  tar_target(
    name = intervention_effect_plots,
    command = {
      source("R/visualization/tolerance_plots.R")
      plot_intervention_effects(intervention_analysis)
    }
  ),

  # Network diffusion visualization
  tar_target(
    name = network_diffusion_plots,
    command = {
      source("R/visualization/tolerance_plots.R")
      plot_tolerance_diffusion(intervention_results)
    }
  ),

  # Combined dashboard
  tar_target(
    name = tolerance_dashboard,
    command = {
      source("R/visualization/tolerance_plots.R")
      create_tolerance_dashboard(
        tolerance_evolution_plots,
        intervention_effect_plots,
        network_diffusion_plots
      )
    }
  ),

  # =============================================================================
  # CUSTOM EFFECTS TARGETS (Advanced)
  # =============================================================================

  # Attraction-repulsion effect implementation
  tar_target(
    name = attraction_repulsion_effect,
    command = {
      source("R/custom_effects/attraction_repulsion.cpp")
      compile_custom_effect("attraction_repulsion")
    },
    cue = tar_cue(mode = "always")  # Always check for C++ changes
  ),

  # Complex contagion effect implementation
  tar_target(
    name = complex_contagion_effect,
    command = {
      source("R/custom_effects/complex_contagion.cpp")
      compile_custom_effect("complex_contagion")
    },
    cue = tar_cue(mode = "always")
  ),

  # Models with custom effects
  tar_target(
    name = custom_effects_fit,
    command = {
      source("R/siena_models/03_simulation.R")
      estimate_model_with_custom_effects(
        siena_data_object,
        attraction_repulsion_effect,
        complex_contagion_effect
      )
    }
  ),

  # =============================================================================
  # REPORTING TARGETS
  # =============================================================================

  # Generate summary tables
  tar_target(
    name = summary_tables,
    command = {
      create_summary_tables(
        baseline_fit,
        intervention_analysis,
        convergence_diagnostics,
        goodness_of_fit
      )
    }
  ),

  # Export all plots to files
  tar_target(
    name = export_plots,
    command = {
      source("R/visualization/tolerance_plots.R")
      export_all_plots(
        tolerance_evolution_plots,
        convergence_plots,
        intervention_effect_plots,
        network_diffusion_plots,
        tolerance_dashboard
      )
    },
    format = "file"
  ),

  # =============================================================================
  # MANUSCRIPT TARGETS
  # =============================================================================

  # Render main analysis report
  tar_quarto(
    name = main_analysis_report,
    path = "docs/analysis_report.qmd",
    extra_files = c("outputs/figures/", "outputs/tables/")
  ),

  # Render methodology documentation
  tar_quarto(
    name = methodology_report,
    path = "docs/methodology/rsiena_methodology.qmd"
  ),

  # Render dissertation chapter
  tar_quarto(
    name = dissertation_chapter,
    path = "docs/dissertation/tolerance_chapter.qmd",
    extra_files = c("outputs/figures/", "outputs/tables/")
  ),

  # =============================================================================
  # VALIDATION AND TESTING TARGETS
  # =============================================================================

  # Visual regression testing
  tar_target(
    name = visual_regression_tests,
    command = {
      source("tests/test_visualizations.R")
      run_visual_regression_tests(
        tolerance_evolution_plots,
        convergence_plots,
        intervention_effect_plots
      )
    }
  ),

  # Model validation tests
  tar_target(
    name = model_validation_tests,
    command = {
      source("tests/test_models.R")
      run_model_validation_tests(baseline_fit, intervention_results)
    }
  ),

  # =============================================================================
  # FINAL OUTPUTS
  # =============================================================================

  # Complete research package
  tar_target(
    name = research_package,
    command = {
      package_research_outputs(
        baseline_fit,
        intervention_analysis,
        tolerance_dashboard,
        summary_tables,
        main_analysis_report,
        dissertation_chapter
      )
    },
    format = "file"
  ),

  # Archive for reproducibility
  tar_target(
    name = reproducibility_archive,
    command = {
      create_reproducibility_archive(
        session_info = sessionInfo(),
        renv_lockfile = "renv.lock",
        targets_manifest = tar_manifest(),
        git_commit = system("git rev-parse HEAD", intern = TRUE)
      )
    },
    format = "file"
  )
)

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

#' Create summary tables for all analyses
#' @param baseline_fit Fitted baseline model
#' @param intervention_analysis Intervention analysis results
#' @param convergence_diagnostics Convergence check results
#' @param goodness_of_fit Goodness-of-fit results
#' @return List of summary tables
create_summary_tables <- function(baseline_fit, intervention_analysis,
                                  convergence_diagnostics, goodness_of_fit) {
  # Implementation would create formatted tables for publication
  list(
    model_parameters = extract_model_table(baseline_fit),
    intervention_effects = extract_intervention_table(intervention_analysis),
    convergence_summary = extract_convergence_table(convergence_diagnostics),
    fit_statistics = extract_fit_table(goodness_of_fit)
  )
}

#' Export all plots with consistent formatting
#' @param ... Plot objects to export
#' @return File paths of exported plots
export_all_plots <- function(...) {
  plots <- list(...)
  plot_files <- character()

  for (i in seq_along(plots)) {
    plot_name <- names(plots)[i] %||% paste0("plot_", i)
    filename <- paste0("outputs/figures/", plot_name, ".pdf")

    ggsave(
      filename = filename,
      plot = plots[[i]],
      width = 10, height = 8, dpi = 300,
      device = cairo_pdf, bg = "white"
    )

    plot_files <- c(plot_files, filename)
  }

  return(plot_files)
}

#' Package all research outputs for sharing
#' @param ... Research objects to package
#' @return Archive file path
package_research_outputs <- function(...) {
  # Create comprehensive research package
  # This would bundle all outputs with metadata
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  archive_name <- paste0("tolerance_research_", timestamp, ".tar.gz")

  # Implementation would create structured archive
  file.path("outputs", archive_name)
}

#' Create reproducibility archive
#' @param session_info R session information
#' @param renv_lockfile renv lockfile path
#' @param targets_manifest targets pipeline manifest
#' @param git_commit Git commit hash
#' @return Archive metadata
create_reproducibility_archive <- function(session_info, renv_lockfile,
                                           targets_manifest, git_commit) {
  # Create comprehensive reproducibility documentation
  list(
    session_info = session_info,
    renv_lockfile = renv_lockfile,
    targets_manifest = targets_manifest,
    git_commit = git_commit,
    timestamp = Sys.time(),
    r_version = R.version.string,
    platform = Sys.info()
  )
}