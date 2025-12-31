# Synthetic Data Generation for Tolerance Intervention SAOM
# Creates realistic school network data matching German high school patterns
#
# Purpose: Generate synthetic data for model development when empirical unavailable
# Objectives: (1) Match known German school network characteristics
#            (2) Create plausible tolerance evolution patterns
#
# Assumptions for valid synthetic data:
# - Network density ≈ 0.05-0.10 (sparse school networks)
# - Clustering coefficient ≈ 0.30-0.40
# - Ethnic homophily present but not deterministic
# - Tolerance varies by ethnicity with overlap

library(RSiena)
library(igraph)
library(tidyverse)
library(here)

set.seed(20250917)  # Reproducibility

cat("=== Generating Synthetic School Network Data ===\n")
cat("Matching German high school network characteristics\n\n")

# =============================================================================
# PARAMETERS
# =============================================================================

# Network structure parameters
n_students <- 150      # Students per class (realistic class size: 25-30 × 5-6 classes)
n_waves <- 3           # Time points
n_schools <- 1         # Focus on single school for clarity
n_classes <- 5         # Classes within school

# Demographic parameters
prop_minority <- 0.30  # Proportion ethnic minority (Turkish German)
prop_female <- 0.52    # Proportion female

# Network parameters (calibrated to German schools)
density_target <- 0.08          # Average density
reciprocity_target <- 0.45      # Reciprocity rate
transitivity_target <- 0.35     # Clustering coefficient
homophily_strength <- 1.5       # Ethnic homophily parameter

# Tolerance parameters (1-7 scale)
tolerance_mean_majority <- 4.2
tolerance_sd_majority <- 1.2
tolerance_mean_minority <- 5.1
tolerance_sd_minority <- 1.0

# Change parameters across waves
friendship_stability <- 0.70    # Jaccard index target
tolerance_change_sd <- 0.5      # Within-person change SD

# =============================================================================
# GENERATE ACTOR ATTRIBUTES
# =============================================================================

cat("Generating actor attributes...\n")

# Create student data frame
students <- tibble(
  id = 1:n_students,
  school = rep(1, n_students),
  class = sample(1:n_classes, n_students, replace = TRUE),
  ethnicity = sample(c(0, 1), n_students,
                    replace = TRUE,
                    prob = c(1 - prop_minority, prop_minority)),
  gender = sample(c(0, 1), n_students,
                 replace = TRUE,
                 prob = c(1 - prop_female, prop_female))
) %>%
  mutate(
    ethnicity_label = ifelse(ethnicity == 0, "German", "Turkish"),
    gender_label = ifelse(gender == 0, "Male", "Female")
  )

# Generate initial tolerance scores
students <- students %>%
  mutate(
    tolerance_wave1 = case_when(
      ethnicity == 0 ~ pmin(7, pmax(1, round(
        rnorm(n(), tolerance_mean_majority, tolerance_sd_majority)
      ))),
      ethnicity == 1 ~ pmin(7, pmax(1, round(
        rnorm(n(), tolerance_mean_minority, tolerance_sd_minority)
      )))
    )
  )

cat(sprintf("  Generated %d students\n", n_students))
cat(sprintf("  Ethnic composition: %.1f%% minority\n", mean(students$ethnicity) * 100))
cat(sprintf("  Gender composition: %.1f%% female\n", mean(students$gender) * 100))
cat(sprintf("  Classes: %d\n", n_classes))

# =============================================================================
# GENERATE FRIENDSHIP NETWORKS
# =============================================================================

cat("\nGenerating friendship networks...\n")

# Function to generate one network wave
generate_network <- function(n, class_vec, ethnicity_vec, gender_vec,
                           density_target = 0.08,
                           homophily_strength = 1.5,
                           reciprocity_boost = 2.0) {

  # Initialize empty network
  network <- matrix(0, n, n)

  # Calculate tie probabilities
  for (i in 1:(n-1)) {
    for (j in (i+1):n) {
      # Base probability
      p_base <- density_target

      # Same class bonus
      if (class_vec[i] == class_vec[j]) {
        p_base <- p_base * 3  # Much more likely within class
      } else {
        p_base <- p_base * 0.1  # Rare across classes
      }

      # Homophily effects
      if (ethnicity_vec[i] == ethnicity_vec[j]) {
        p_base <- p_base * homophily_strength
      }

      if (gender_vec[i] == gender_vec[j]) {
        p_base <- p_base * 1.3
      }

      # Ensure probability is valid
      p_base <- min(1, p_base)

      # Generate directed ties
      if (runif(1) < p_base) {
        network[i, j] <- 1
        # Reciprocity
        if (runif(1) < (reciprocity_boost * p_base)) {
          network[j, i] <- 1
        }
      }
      if (runif(1) < p_base && network[j, i] == 0) {
        network[j, i] <- 1
      }
    }
  }

  # Add transitivity through triadic closure
  for (iteration in 1:3) {
    for (i in 1:n) {
      friends <- which(network[i, ] == 1)
      if (length(friends) > 1) {
        for (f1 in friends) {
          for (f2 in friends) {
            if (f1 != f2 && runif(1) < transitivity_target) {
              network[f1, f2] <- 1
            }
          }
        }
      }
    }
  }

  # Set diagonal to 0
  diag(network) <- 0

  return(network)
}

# Generate wave 1 network
friendship_wave1 <- generate_network(
  n_students,
  students$class,
  students$ethnicity,
  students$gender,
  density_target,
  homophily_strength
)

# Calculate network statistics
g1 <- graph_from_adjacency_matrix(friendship_wave1, mode = "directed")
actual_density <- edge_density(g1)
actual_reciprocity <- reciprocity(g1)
actual_transitivity <- transitivity(g1, type = "global")

cat(sprintf("  Wave 1 network statistics:\n"))
cat(sprintf("    Density: %.3f (target: %.3f)\n", actual_density, density_target))
cat(sprintf("    Reciprocity: %.3f (target: %.3f)\n", actual_reciprocity, reciprocity_target))
cat(sprintf("    Transitivity: %.3f (target: %.3f)\n", actual_transitivity, transitivity_target))
cat(sprintf("    Total ties: %d\n", sum(friendship_wave1)))

# Generate subsequent waves with stability
friendship_wave2 <- friendship_wave1
friendship_wave3 <- friendship_wave2

# Introduce controlled change for waves 2 and 3
for (wave in 2:3) {
  if (wave == 2) {
    current_network <- friendship_wave2
  } else {
    current_network <- friendship_wave3
  }

  # Number of ties to change
  n_changes <- round(sum(current_network) * (1 - friendship_stability))

  # Remove some ties
  existing_ties <- which(current_network == 1, arr.ind = TRUE)
  if (nrow(existing_ties) > n_changes/2) {
    remove_idx <- sample(1:nrow(existing_ties), n_changes/2)
    for (idx in remove_idx) {
      current_network[existing_ties[idx, 1], existing_ties[idx, 2]] <- 0
    }
  }

  # Add some new ties
  no_ties <- which(current_network == 0 & upper.tri(current_network), arr.ind = TRUE)
  if (nrow(no_ties) > n_changes/2) {
    add_idx <- sample(1:nrow(no_ties), n_changes/2)
    for (idx in add_idx) {
      i <- no_ties[idx, 1]
      j <- no_ties[idx, 2]
      # Check class constraint
      if (students$class[i] == students$class[j]) {
        current_network[i, j] <- 1
        if (runif(1) < reciprocity_target) {
          current_network[j, i] <- 1
        }
      }
    }
  }

  if (wave == 2) {
    friendship_wave2 <- current_network
  } else {
    friendship_wave3 <- current_network
  }
}

# Calculate Jaccard indices
jaccard_1_2 <- sum(friendship_wave1 & friendship_wave2) /
              sum(friendship_wave1 | friendship_wave2)
jaccard_2_3 <- sum(friendship_wave2 & friendship_wave3) /
              sum(friendship_wave2 | friendship_wave3)

cat(sprintf("\n  Wave-to-wave stability:\n"))
cat(sprintf("    Jaccard 1→2: %.3f\n", jaccard_1_2))
cat(sprintf("    Jaccard 2→3: %.3f\n", jaccard_2_3))

# =============================================================================
# GENERATE TOLERANCE EVOLUTION
# =============================================================================

cat("\nGenerating tolerance evolution...\n")

# Create tolerance matrix
tolerance_matrix <- matrix(NA, n_students, n_waves)
tolerance_matrix[, 1] <- students$tolerance_wave1

# Evolve tolerance with friend influence
for (wave in 2:3) {
  prev_tolerance <- tolerance_matrix[, wave - 1]
  new_tolerance <- prev_tolerance

  if (wave == 2) {
    friend_network <- friendship_wave1
  } else {
    friend_network <- friendship_wave2
  }

  for (i in 1:n_students) {
    friends <- which(friend_network[i, ] == 1)
    if (length(friends) > 0) {
      # Friend influence
      friend_mean <- mean(prev_tolerance[friends])
      pull_strength <- 0.3  # Influence parameter

      # Pull toward friend mean
      change <- pull_strength * (friend_mean - prev_tolerance[i])

      # Add random variation
      change <- change + rnorm(1, 0, tolerance_change_sd)

      # Update tolerance
      new_tolerance[i] <- prev_tolerance[i] + change

      # Bound to scale
      new_tolerance[i] <- pmin(7, pmax(1, round(new_tolerance[i])))
    } else {
      # Random walk if no friends
      new_tolerance[i] <- pmin(7, pmax(1,
        round(prev_tolerance[i] + rnorm(1, 0, tolerance_change_sd))
      ))
    }
  }

  tolerance_matrix[, wave] <- new_tolerance
}

# Report tolerance statistics
cat("  Tolerance distribution:\n")
for (wave in 1:3) {
  cat(sprintf("    Wave %d: Mean = %.2f, SD = %.2f\n",
             wave, mean(tolerance_matrix[, wave]),
             sd(tolerance_matrix[, wave])))
}

# Check for monotonicity
monotone_increase <- sum(apply(tolerance_matrix, 1, function(x) all(diff(x) >= 0)))
monotone_decrease <- sum(apply(tolerance_matrix, 1, function(x) all(diff(x) <= 0)))

cat(sprintf("  Monotonic patterns:\n"))
cat(sprintf("    Monotone increase: %d (%.1f%%)\n",
           monotone_increase, monotone_increase/n_students * 100))
cat(sprintf("    Monotone decrease: %d (%.1f%%)\n",
           monotone_decrease, monotone_decrease/n_students * 100))

# =============================================================================
# CREATE RSIENA OBJECTS
# =============================================================================

cat("\nCreating RSiena objects...\n")

# Create 3D array for networks
friendship_array <- array(0, dim = c(n_students, n_students, n_waves))
friendship_array[, , 1] <- friendship_wave1
friendship_array[, , 2] <- friendship_wave2
friendship_array[, , 3] <- friendship_wave3

# Add structural constraints (no self-ties)
for (wave in 1:n_waves) {
  diag(friendship_array[, , wave]) <- 10  # Structural zeros
}

# Create RSiena objects
friendship <- sienaDependent(friendship_array, type = "oneMode")
tolerance <- sienaDependent(tolerance_matrix, type = "behavior")

# Covariates
ethnicity_covar <- coCovar(students$ethnicity)
gender_covar <- coCovar(students$gender)
class_covar <- coCovar(students$class)

# Same ethnicity dyadic covariate
same_ethnicity <- outer(students$ethnicity, students$ethnicity, "==") * 1
diag(same_ethnicity) <- 0
same_ethnicity_covar <- coDyadCovar(same_ethnicity)

# Create siena data object
siena_data <- sienaDataCreate(
  friendship = friendship,
  tolerance = tolerance,
  ethnicity = ethnicity_covar,
  gender = gender_covar,
  class = class_covar,
  same_ethnicity = same_ethnicity_covar
)

cat("  Created RSiena data object\n")

# =============================================================================
# SAVE SYNTHETIC DATA
# =============================================================================

cat("\nSaving synthetic data...\n")

# Create directories if needed
if (!dir.exists(here("data", "synthetic"))) {
  dir.create(here("data", "synthetic"), recursive = TRUE)
}

# Save all components
saveRDS(students, here("data", "synthetic", "students.rds"))
saveRDS(friendship_array, here("data", "synthetic", "friendship_array.rds"))
saveRDS(tolerance_matrix, here("data", "synthetic", "tolerance_matrix.rds"))
saveRDS(siena_data, here("data", "synthetic", "siena_data.rds"))

# Save readable CSV versions for inspection
write.csv(students, here("data", "synthetic", "students.csv"), row.names = FALSE)
write.csv(tolerance_matrix, here("data", "synthetic", "tolerance.csv"), row.names = FALSE)

# Save network edge lists
for (wave in 1:3) {
  edges <- which(friendship_array[, , wave] == 1, arr.ind = TRUE)
  edge_list <- data.frame(from = edges[, 1], to = edges[, 2], wave = wave)
  write.csv(edge_list,
           here("data", "synthetic", sprintf("edges_wave%d.csv", wave)),
           row.names = FALSE)
}

cat("  Saved to data/synthetic/\n")

# =============================================================================
# SUMMARY
# =============================================================================

cat("\n=== Synthetic Data Generation Complete ===\n")
cat("Summary:\n")
cat(sprintf("  Students: %d\n", n_students))
cat(sprintf("  Waves: %d\n", n_waves))
cat(sprintf("  Network density: %.3f\n", actual_density))
cat(sprintf("  Jaccard stability: %.3f\n", mean(c(jaccard_1_2, jaccard_2_3))))
cat(sprintf("  Tolerance range: %d-%d\n",
           min(tolerance_matrix), max(tolerance_matrix)))

cat("\nNext step: Run print01Report() to validate data quality\n")

# Return siena_data for use in main pipeline
siena_data