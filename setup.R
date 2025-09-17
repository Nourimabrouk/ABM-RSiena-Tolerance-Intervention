# Setup script for ABM RSiena Research Project
# Run this script to install all required packages and initialize the project

# Project metadata
cat("Setting up ABM RSiena Research Project\n")
cat("======================================\n")
cat("PhD Research on Tolerance Interventions for Interethnic Cooperation\n")
cat("Using Stochastic Actor-Oriented Models (SAOM) with RSiena\n\n")

# Check R version
r_version <- R.version.string
cat("R Version:", r_version, "\n")

if (R.version$major < 4 || (R.version$major == 4 && as.numeric(R.version$minor) < 3)) {
  warning("R version 4.3.0 or higher is recommended for optimal RSiena performance")
}

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Core packages for SAOM analysis
core_packages <- c(
  "RSiena",        # Main SAOM estimation
  "RSienaTest",    # Model diagnostics and testing
  "network",       # Network data structures
  "sna",           # Social network analysis
  "igraph",        # Network manipulation and visualization
  "tidyverse",     # Data manipulation and visualization
  "data.table",    # Fast data operations
  "ggplot2",       # Statistical graphics
  "ggraph",        # Network plotting
  "parallel",      # Parallel computing
  "foreach",       # Parallel loops
  "doParallel"     # Parallel backend
)

# Additional useful packages
optional_packages <- c(
  "rmarkdown",     # Report generation
  "knitr",         # Dynamic documents
  "testthat",      # Unit testing
  "devtools",      # Development tools
  "here",          # Project-relative paths
  "janitor",       # Data cleaning
  "readxl",        # Excel file reading
  "haven",         # SPSS/Stata file reading
  "RColorBrewer",  # Color palettes
  "gridExtra",     # Grid graphics
  "patchwork"      # Plot composition
)

# Function to install packages if not already installed
install_if_missing <- function(packages) {
  missing_packages <- packages[!packages %in% installed.packages()[,"Package"]]

  if (length(missing_packages) > 0) {
    cat("Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
    install.packages(missing_packages, dependencies = TRUE)
  } else {
    cat("All packages already installed.\n")
  }
}

# Install core packages
cat("\nInstalling core packages...\n")
install_if_missing(core_packages)

# Install optional packages
cat("\nInstalling optional packages...\n")
install_if_missing(optional_packages)

# Verify RSiena installation
cat("\nVerifying RSiena installation...\n")
tryCatch({
  library(RSiena)
  cat("RSiena version:", packageVersion("RSiena"), "successfully loaded.\n")
}, error = function(e) {
  warning("Failed to load RSiena. Please check installation.")
})

# Create necessary directories with .gitkeep files
directories <- c(
  "data/raw",
  "data/processed",
  "data/networks",
  "data/simulated",
  "outputs/figures",
  "outputs/models",
  "outputs/reports",
  "outputs/simulations",
  "outputs/tables"
)

cat("\nCreating directory structure...\n")
for (dir in directories) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    cat("Created:", dir, "\n")
  }

  # Create .gitkeep file to maintain empty directories in git
  gitkeep_path <- file.path(dir, ".gitkeep")
  if (!file.exists(gitkeep_path)) {
    file.create(gitkeep_path)
  }
}

# Create basic configuration files
cat("\nSetting up project configuration...\n")

# Create a basic R project configuration
if (!file.exists("ABM_RSiena.Rproj")) {
  rproj_content <- "Version: 1.0

RestoreWorkspace: No
SaveWorkspace: No
AlwaysSaveHistory: Default

EnableCodeIndexing: Yes
UseSpacesForTab: Yes
NumSpacesForTab: 2
Encoding: UTF-8

RnwWeave: Sweave
LaTeX: pdfLaTeX

AutoAppendNewline: Yes
StripTrailingWhitespace: Yes

BuildType: Package
PackageUseDevtools: Yes
PackageInstallArgs: --no-multiarch --with-keep.source
"
  writeLines(rproj_content, "ABM_RSiena.Rproj")
  cat("Created R project file: ABM_RSiena.Rproj\n")
}

# Display setup summary
cat("\n" , rep("=", 50), "\n")
cat("SETUP COMPLETE\n")
cat(rep("=", 50), "\n")
cat("Project: ABM RSiena Research\n")
cat("Focus: Tolerance interventions for interethnic cooperation\n")
cat("Method: Stochastic Actor-Oriented Models (SAOM)\n")
cat("Software: RSiena with R", R.version$major, ".", R.version$minor, "\n")
cat("\nNext steps:\n")
cat("1. Load data into data/raw/\n")
cat("2. Run data preparation: Rscript R/siena_models/00_data_prep.R\n")
cat("3. Develop baseline model: Rscript R/siena_models/01_baseline.R\n")
cat("4. Check convergence: Rscript R/diagnostics/convergence_check.R\n")
cat("\nFor help: see CLAUDE.md and .claude/ folder for project guidelines\n")
cat(rep("=", 50), "\n")

# Load commonly used libraries for this session
suppressMessages({
  library(RSiena)
  library(tidyverse)
  library(igraph)
})

cat("\nCore libraries loaded. Ready for SAOM analysis!\n")