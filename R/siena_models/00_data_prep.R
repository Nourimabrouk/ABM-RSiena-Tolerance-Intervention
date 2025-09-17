# Data Preparation for SAOM Analysis
# Tolerance Interventions for Interethnic Cooperation Research
#
# This script prepares longitudinal network and behavior data for RSiena analysis
# Following RSiena best practices for structural coding and data validation

# Load required libraries
library(RSiena)
library(tidyverse)
library(here)

# Set random seed for reproducibility
set.seed(20250917)

# Source utility functions
source(here("R", "utils", "data_helpers.R"))

cat("=== RSiena Data Preparation ===\n")
cat("Preparing data for tolerance intervention SAOM analysis\n\n")

# =============================================================================
# 1. LOAD RAW DATA
# =============================================================================

cat("Loading raw data...\n")

# TODO: Replace with actual data loading
# Example structure for longitudinal school network data
#
# Expected data files:
# - friendship_wave1.csv, friendship_wave2.csv, friendship_wave3.csv
# - tolerance_data.csv (behavior data across waves)
# - student_attributes.csv (ethnicity, gender, class, etc.)

# Placeholder data structure
# In actual implementation, load from data/raw/
# friendship_data <- read_csv(here("data", "raw", "friendship_data.csv"))
# tolerance_data <- read_csv(here("data", "raw", "tolerance_data.csv"))
# student_attrs <- read_csv(here("data", "raw", "student_attributes.csv"))

cat("Note: Replace placeholder data loading with actual data files\n")
cat("Expected files in data/raw/:\n")
cat("  - friendship_wave1.csv, friendship_wave2.csv, friendship_wave3.csv\n")
cat("  - tolerance_data.csv\n")
cat("  - student_attributes.csv\n\n")

# =============================================================================
# 2. DATA CLEANING AND VALIDATION
# =============================================================================

cat("Data cleaning and validation...\n")

# TODO: Implement data cleaning functions
# - Check for missing actor IDs
# - Validate friendship network symmetry (if undirected)
# - Handle composition changes (joiners/leavers)
# - Validate tolerance score ranges
# - Check for structural constraints

# Example validation functions:
# validate_network_structure(friendship_data)
# check_composition_changes(friendship_data)
# validate_behavior_range(tolerance_data)

# =============================================================================
# 3. CREATE NETWORK ARRAYS
# =============================================================================

cat("Creating network arrays...\n")

# TODO: Create 3D arrays for RSiena
# Dimensions: [actors, actors, waves]
# Values: 0/1 for ties, 10 for structural zeros, 11 for structural ones, NA for missing

# Example structure:
# n_actors <- length(unique(student_attrs$student_id))
# n_waves <- 3
#
# friendship_array <- array(0, dim = c(n_actors, n_actors, n_waves))
# cooperation_array <- array(0, dim = c(n_actors, n_actors, n_waves))

# Apply structural constraints
# Example: students from different schools cannot be friends
# friendship_array[different_schools] <- 10  # structural zero

cat("Note: Implement network array creation from your data\n")

# =============================================================================
# 4. CREATE BEHAVIOR MATRICES
# =============================================================================

cat("Creating behavior matrices...\n")

# TODO: Create behavior matrices for RSiena
# Dimensions: [actors, waves]
# Values: integer tolerance scores

# Example:
# tolerance_matrix <- matrix(NA, nrow = n_actors, ncol = n_waves)
# # Fill with actual tolerance scores

cat("Note: Implement behavior matrix creation\n")

# =============================================================================
# 5. PREPARE COVARIATES
# =============================================================================

cat("Preparing covariates...\n")

# TODO: Prepare actor-level covariates
# - Ethnicity (categorical -> numeric coding)
# - Gender (binary)
# - Class/Grade (categorical)
# - Intervention status (time-varying if applicable)

# Example:
# ethnicity_covar <- coCovar(student_attrs$ethnicity_numeric)
# gender_covar <- coCovar(student_attrs$gender_binary)
# class_covar <- coCovar(student_attrs$class_numeric)

cat("Note: Implement covariate preparation\n")

# =============================================================================
# 6. CREATE RSIENA OBJECTS
# =============================================================================

cat("Creating RSiena objects...\n")

# TODO: Create RSiena dependent variables and data object

# Example structure:
# friendship <- sienaDependent(friendship_array, type = "oneMode")
# cooperation <- sienaDependent(cooperation_array, type = "oneMode")
# tolerance <- sienaDependent(tolerance_matrix, type = "behavior")
#
# siena_data <- sienaDataCreate(
#   friendship = friendship,
#   cooperation = cooperation,
#   tolerance = tolerance,
#   ethnicity = ethnicity_covar,
#   gender = gender_covar,
#   class = class_covar
# )

cat("Note: Create actual RSiena objects when data is available\n")

# =============================================================================
# 7. DATA QUALITY REPORT
# =============================================================================

cat("Generating data quality report...\n")

# TODO: Generate comprehensive data report using print01Report
# This is ESSENTIAL for RSiena analysis - checks Jaccard stability, density, etc.

# Example:
# print01Report(siena_data, modelname = "data_quality_check")

# Additional checks:
# - Jaccard stability across waves (target > 0.30)
# - Network density and reciprocity
# - Behavior distribution and monotonicity
# - Missing data patterns

cat("Note: Run print01Report when RSiena objects are created\n")

# =============================================================================
# 8. SAVE PROCESSED DATA
# =============================================================================

cat("Saving processed data objects...\n")

# Create output directory if it doesn't exist
output_dir <- here("data", "processed")
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# TODO: Save processed objects
# saveRDS(siena_data, here("data", "processed", "siena_data.rds"))
# saveRDS(friendship_array, here("data", "processed", "friendship_array.rds"))
# saveRDS(tolerance_matrix, here("data", "processed", "tolerance_matrix.rds"))

cat("Note: Save actual objects when created\n")

# =============================================================================
# 9. SUMMARY STATISTICS
# =============================================================================

cat("\n=== Data Preparation Summary ===\n")
cat("Timestamp:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("R Session Info:\n")
print(sessionInfo())

cat("\nNext steps:\n")
cat("1. Review data quality report output\n")
cat("2. Check Jaccard stability (should be > 0.30)\n")
cat("3. Proceed to baseline model specification\n")
cat("4. Run: Rscript R/siena_models/01_baseline.R\n")

cat("\n=== End Data Preparation ===\n")