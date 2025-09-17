# Baseline Model Specification for SAOM Analysis
# Tolerance Interventions for Interethnic Cooperation Research
#
# This script specifies the baseline SAOM model including:
# - Core network effects (density, reciprocity, transitivity)
# - Selection effects (homophily, actor attributes)
# - Behavior dynamics (tolerance shape and influence)

# Load required libraries
library(RSiena)
library(tidyverse)
library(here)

# Set random seed for reproducibility
set.seed(20250917)

cat("=== RSiena Baseline Model Specification ===\n")
cat("Developing baseline SAOM for tolerance-cooperation dynamics\n\n")

# =============================================================================
# 1. LOAD PREPARED DATA
# =============================================================================

cat("Loading prepared RSiena data...\n")

# Load processed data objects
data_file <- here("data", "processed", "siena_data.rds")

if (file.exists(data_file)) {
  siena_data <- readRDS(data_file)
  cat("Loaded RSiena data object successfully\n")
} else {
  cat("ERROR: RSiena data not found. Run 00_data_prep.R first\n")
  stop("Data preparation required")
}

# Verify data structure
cat("Data structure:\n")
print(siena_data)

# =============================================================================
# 2. BASELINE EFFECTS SPECIFICATION
# =============================================================================

cat("\nSpecifying baseline effects...\n")

# Get default effects
baseline_effects <- getEffects(siena_data)

cat("Default effects included:\n")
print(baseline_effects[baseline_effects$include == TRUE, c("name", "effectName", "type")])

# =============================================================================
# 3. NETWORK STRUCTURE EFFECTS
# =============================================================================

cat("\nAdding core network structure effects...\n")

# Core structural effects for friendship network
baseline_effects <- includeEffects(baseline_effects,
                                   recip,        # Reciprocity
                                   transTrip,    # Transitive triplets (closure)
                                   name = "friendship")

# Additional structural effects
baseline_effects <- includeEffects(baseline_effects,
                                   cycle3,       # 3-cycles (often negative in schools)
                                   name = "friendship")

cat("Added network structure effects: reciprocity, transitive triplets, 3-cycles\n")

# =============================================================================
# 4. ACTOR ATTRIBUTE EFFECTS (SELECTION)
# =============================================================================

cat("\nAdding actor attribute effects...\n")

# Homophily effects (selection based on similarity)
baseline_effects <- includeEffects(baseline_effects,
                                   sameX,        # Same ethnicity preference
                                   interaction1 = "ethnicity",
                                   name = "friendship")

baseline_effects <- includeEffects(baseline_effects,
                                   sameX,        # Same gender preference
                                   interaction1 = "gender",
                                   name = "friendship")

# Actor attribute effects (ego and alter)
baseline_effects <- includeEffects(baseline_effects,
                                   egoX,         # Ego effect for ethnicity
                                   altX,         # Alter effect for ethnicity
                                   interaction1 = "ethnicity",
                                   name = "friendship")

cat("Added homophily effects: ethnicity, gender\n")
cat("Added actor effects: ethnicity ego/alter\n")

# =============================================================================
# 5. BEHAVIOR DYNAMICS (TOLERANCE)
# =============================================================================

cat("\nAdding behavior dynamics effects...\n")

# Shape effects for tolerance behavior
baseline_effects <- includeEffects(baseline_effects,
                                   linear,       # Linear shape
                                   quad,         # Quadratic shape
                                   name = "tolerance")

# Social influence effect
baseline_effects <- includeEffects(baseline_effects,
                                   avAlt,        # Average alter (peer influence)
                                   name = "tolerance",
                                   interaction1 = "friendship")

cat("Added behavior effects: linear/quadratic shape, peer influence\n")

# =============================================================================
# 6. SELECTION ON BEHAVIOR (TOLERANCE HOMOPHILY)
# =============================================================================

cat("\nAdding selection on behavior...\n")

# Tolerance similarity in friendship formation
baseline_effects <- includeEffects(baseline_effects,
                                   simX,         # Similarity in tolerance
                                   interaction1 = "tolerance",
                                   name = "friendship")

cat("Added tolerance homophily in friendship selection\n")

# =============================================================================
# 7. COOPERATION NETWORK EFFECTS (IF AVAILABLE)
# =============================================================================

# Check if cooperation network is available
if ("cooperation" %in% names(siena_data$depvars)) {
  cat("\nAdding cooperation network effects...\n")

  # Basic cooperation network structure
  baseline_effects <- includeEffects(baseline_effects,
                                     recip,        # Reciprocity
                                     transTrip,    # Transitivity
                                     name = "cooperation")

  # Cross-network effects (friendship -> cooperation)
  baseline_effects <- includeEffects(baseline_effects,
                                     crprod,       # Cross-network tie formation
                                     interaction1 = "friendship",
                                     name = "cooperation")

  cat("Added cooperation network and cross-network effects\n")
}

# =============================================================================
# 8. CONTROL VARIABLES
# =============================================================================

cat("\nAdding control variables...\n")

# Class-level controls (if available)
if ("class" %in% names(siena_data$cCovars)) {
  baseline_effects <- includeEffects(baseline_effects,
                                     sameX,        # Same class preference
                                     interaction1 = "class",
                                     name = "friendship")
  cat("Added class homophily control\n")
}

# =============================================================================
# 9. REVIEW FINAL EFFECTS
# =============================================================================

cat("\n=== Final Effect Specification ===\n")

# Display all included effects
included_effects <- baseline_effects[baseline_effects$include == TRUE, ]
cat("Total effects included:", nrow(included_effects), "\n\n")

# Group by network/behavior
for (network_name in unique(included_effects$name)) {
  cat(sprintf("--- %s ---\n", network_name))
  network_effects <- included_effects[included_effects$name == network_name, ]
  for (i in 1:nrow(network_effects)) {
    effect <- network_effects[i, ]
    cat(sprintf("  %s (%s)\n", effect$effectName, effect$type))
  }
  cat("\n")
}

# =============================================================================
# 10. SAVE EFFECTS SPECIFICATION
# =============================================================================

cat("Saving effects specification...\n")

# Create output directory
output_dir <- here("configs")
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Save effects object
saveRDS(baseline_effects, here("configs", "baseline_effects.rds"))

# Export effects as readable table
effects_table <- baseline_effects[baseline_effects$include == TRUE,
                                  c("name", "effectName", "type", "initialValue", "parm")]
write_csv(effects_table, here("configs", "baseline_effects.csv"))

cat("Effects saved to configs/baseline_effects.rds and baseline_effects.csv\n")

# =============================================================================
# 11. PRELIMINARY CHECKS
# =============================================================================

cat("\nRunning preliminary checks...\n")

# Check for potential collinearity issues
cat("Checking for potential effect interactions...\n")

# Count effects by type
effect_counts <- table(included_effects$type)
cat("Effect counts by type:\n")
print(effect_counts)

# Warn about potential issues
if (effect_counts["eval"] > 10) {
  cat("WARNING: Large number of evaluation effects may cause convergence issues\n")
}

if (any(duplicated(paste(included_effects$name, included_effects$effectName)))) {
  cat("WARNING: Duplicate effects detected\n")
}

# =============================================================================
# 12. NEXT STEPS
# =============================================================================

cat("\n=== Baseline Model Specification Complete ===\n")
cat("Timestamp:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")

cat("\nModel components:\n")
cat("- Network structure: reciprocity, transitivity, 3-cycles\n")
cat("- Homophily: ethnicity, gender, tolerance\n")
cat("- Behavior dynamics: tolerance shape and peer influence\n")
if ("cooperation" %in% names(siena_data$depvars)) {
  cat("- Cross-network: friendship -> cooperation\n")
}

cat("\nNext steps:\n")
cat("1. Review effect specification in configs/baseline_effects.csv\n")
cat("2. Run model estimation: Rscript R/siena_models/02_estimation.R\n")
cat("3. Check convergence and goodness-of-fit\n")

cat("\n=== End Baseline Specification ===\n")