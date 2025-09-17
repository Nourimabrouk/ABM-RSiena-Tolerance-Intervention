# .Rprofile for ABM Tolerance Research
# PhD dissertation project configuration
# Author: Your Name
# Date: September 17, 2025

# =============================================================================
# BASIC CONFIGURATION
# =============================================================================

# Set default repository
options(
  repos = c(CRAN = "https://cloud.r-project.org"),
  download.file.method = "auto"
)

# Set scientific notation preferences
options(
  scipen = 999,  # Avoid scientific notation
  digits = 4     # Default decimal places
)

# Configure parallel processing
options(
  mc.cores = max(1, parallel::detectCores() - 1),
  cl.cores = max(1, parallel::detectCores() - 1)
)

# Data handling preferences
options(
  stringsAsFactors = FALSE,
  warn = 1,  # Show warnings as they occur
  error = recover  # Enter debugger on error
)

# renv configuration
options(
  renv.config.auto.snapshot = FALSE,  # Manual snapshots
  renv.config.startup.quiet = TRUE
)

# =============================================================================
# TOLERANCE RESEARCH SPECIFIC OPTIONS
# =============================================================================

# Research-specific constants
options(
  tolerance.seed = 20250917,
  tolerance.iterations = 1000,
  tolerance.convergence.threshold = 0.1,
  tolerance.max.convergence.ratio = 0.25,
  tolerance.n.schools = 3,
  tolerance.n.classes = 105,
  tolerance.n.students = 2585,
  tolerance.n.waves = 3
)

# RSiena specific options
options(
  rsiena.batch.mode = TRUE,
  rsiena.silent = FALSE,
  rsiena.print01.report = TRUE
)

# ggplot2 and visualization options
options(
  ggplot2.continuous.colour = "viridis",
  ggplot2.continuous.fill = "viridis",
  ggplot2.discrete.colour = c("#2E86AB", "#A23B72", "#F18F01"),
  ggplot2.discrete.fill = c("#2E86AB", "#A23B72", "#F18F01")
)

# =============================================================================
# PACKAGE LOADING
# =============================================================================

# Suppress package startup messages
suppressPackageStartupMessages({
  # Essential packages for tolerance research
  if (requireNamespace("tidyverse", quietly = TRUE)) {
    library(tidyverse, quietly = TRUE)
  }

  if (requireNamespace("ggplot2", quietly = TRUE)) {
    library(ggplot2, quietly = TRUE)
  }

  if (requireNamespace("targets", quietly = TRUE)) {
    library(targets, quietly = TRUE)
  }

  # Set custom theme if available
  if (file.exists("R/visualization/publication_themes.R")) {
    source("R/visualization/publication_themes.R")
    theme_set(theme_tolerance_publication())
  }
})

# =============================================================================
# CUSTOM FUNCTIONS
# =============================================================================

#' Quick function to check RSiena convergence
#' @param fit RSiena fit object
#' @return Logical indicating convergence
check_convergence <- function(fit) {
  if (missing(fit) || is.null(fit)) return(FALSE)

  tconv_max <- summary(fit)$tconv.max
  t_ratios <- abs(summary(fit)$tstat)

  converged <- tconv_max < 0.25 && all(t_ratios < 0.1, na.rm = TRUE)

  cat("Max convergence ratio:", round(tconv_max, 3), "\n")
  cat("Max |t-ratio|:", round(max(t_ratios, na.rm = TRUE), 3), "\n")
  cat("Converged:", converged, "\n")

  return(converged)
}

#' Quick function to load processed data
#' @return RSiena data object
load_tolerance_data <- function() {
  data_path <- "data/processed/siena_data.rds"
  if (file.exists(data_path)) {
    readRDS(data_path)
  } else {
    message("Processed data not found. Run data preparation first.")
    NULL
  }
}

#' Quick function to run targets pipeline
#' @param n_targets Number of targets to run (default: all)
run_tolerance_pipeline <- function(n_targets = Inf) {
  if (!requireNamespace("targets", quietly = TRUE)) {
    stop("targets package not available")
  }

  if (n_targets == Inf) {
    targets::tar_make()
  } else {
    targets::tar_make(names = head(targets::tar_manifest()$name, n_targets))
  }
}

#' Quick function to check pipeline status
check_pipeline_status <- function() {
  if (!requireNamespace("targets", quietly = TRUE)) {
    message("targets package not available")
    return(invisible())
  }

  progress <- targets::tar_progress()
  cat("Pipeline Status:\n")
  cat("- Completed:", sum(progress$progress == "completed"), "\n")
  cat("- Errored:", sum(progress$progress == "errored"), "\n")
  cat("- Running:", sum(progress$progress == "running"), "\n")
  cat("- Outdated:", sum(progress$progress == "outdated"), "\n")

  return(invisible(progress))
}

#' Quick function to view latest plots
view_latest_plots <- function() {
  plot_dir <- "outputs/figures"
  if (!dir.exists(plot_dir)) {
    message("No plots directory found")
    return(invisible())
  }

  plot_files <- list.files(plot_dir, pattern = "\\.(pdf|png)$", full.names = TRUE)
  if (length(plot_files) == 0) {
    message("No plots found")
    return(invisible())
  }

  # Get most recent plots
  recent_plots <- head(plot_files[order(file.mtime(plot_files), decreasing = TRUE)], 5)

  cat("Recent plots:\n")
  for (plot in recent_plots) {
    cat("-", basename(plot), "\n")
  }

  return(invisible(recent_plots))
}

#' Create quick data summary
summarize_tolerance_data <- function() {
  data <- load_tolerance_data()
  if (is.null(data)) return(invisible())

  cat("Tolerance Research Data Summary\n")
  cat("===============================\n")
  cat("Data object:", class(data), "\n")

  if ("depvars" %in% names(data)) {
    for (var_name in names(data$depvars)) {
      var_data <- data$depvars[[var_name]]
      cat("\nVariable:", var_name, "\n")
      cat("- Type:", attr(var_data, "type"), "\n")

      if (is.array(var_data)) {
        cat("- Dimensions:", paste(dim(var_data), collapse = " x "), "\n")
        if (length(dim(var_data)) == 3) {
          cat("- Networks across", dim(var_data)[3], "waves\n")
        }
      } else if (is.matrix(var_data)) {
        cat("- Dimensions:", paste(dim(var_data), collapse = " x "), "\n")
        cat("- Behavior across", ncol(var_data), "waves\n")
      }
    }
  }

  return(invisible(data))
}

# =============================================================================
# STARTUP MESSAGE
# =============================================================================

# Display startup information
cat("\n")
cat("╔══════════════════════════════════════════════════════════════════╗\n")
cat("║                Tolerance Intervention Research                   ║\n")
cat("║                   PhD Dissertation Project                       ║\n")
cat("║                  Utrecht University - 2025                      ║\n")
cat("╚══════════════════════════════════════════════════════════════════╝\n")
cat("\n")

# Display key information
cat("R version:", R.version.string, "\n")

if (exists("packageVersion")) {
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    cat("ggplot2 version:", as.character(packageVersion("ggplot2")), "\n")
  }
  if (requireNamespace("RSiena", quietly = TRUE)) {
    cat("RSiena version:", as.character(packageVersion("RSiena")), "\n")
  }
}

cat("Working directory:", getwd(), "\n")

# Check if this is a git repository
if (file.exists(".git")) {
  git_branch <- try(system("git branch --show-current", intern = TRUE), silent = TRUE)
  if (!inherits(git_branch, "try-error") && length(git_branch) > 0) {
    cat("Git branch:", git_branch, "\n")
  }
}

cat("\n")
cat("Quick functions available:\n")
cat("• check_convergence(fit)     - Check RSiena model convergence\n")
cat("• load_tolerance_data()      - Load processed RSiena data\n")
cat("• run_tolerance_pipeline()   - Execute targets pipeline\n")
cat("• check_pipeline_status()    - View pipeline progress\n")
cat("• view_latest_plots()        - List recent visualizations\n")
cat("• summarize_tolerance_data() - Quick data overview\n")
cat("\n")

# Check for renv
if (file.exists("renv.lock")) {
  cat("📦 renv project detected - package versions locked\n")
}

# Check for targets
if (file.exists("_targets.R")) {
  cat("🎯 targets pipeline available - use run_tolerance_pipeline()\n")
}

# Check data availability
if (dir.exists("data/processed")) {
  n_files <- length(list.files("data/processed", pattern = "\\.rds$"))
  if (n_files > 0) {
    cat("📊", n_files, "processed data file(s) available\n")
  }
}

# Check outputs
if (dir.exists("outputs/figures")) {
  n_plots <- length(list.files("outputs/figures", pattern = "\\.(pdf|png)$"))
  if (n_plots > 0) {
    cat("📈", n_plots, "visualization(s) in outputs/figures/\n")
  }
}

cat("\n")
cat("Ready for tolerance intervention research! 🔬\n")
cat("═══════════════════════════════════════════\n")

# =============================================================================
# CLEANUP
# =============================================================================

# Clean up temporary variables
rm(list = ls(pattern = "^temp_"))

# Set working directory (if needed)
# setwd("path/to/project")  # Uncomment and adjust if needed