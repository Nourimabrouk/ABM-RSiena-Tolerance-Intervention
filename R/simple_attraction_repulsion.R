# ==================================================================================
# Simple Attraction-Repulsion Model for Tolerance (Base R Only)
# Based on Tang, Snijders & Flache (2025) Social Judgment Theory Implementation
# ==================================================================================

cat("=== ATTRACTION-REPULSION TOLERANCE MODEL ===\n\n")

# Set seed for reproducibility
set.seed(20250917)

# ==================================================================================
# 1. SIMULATION PARAMETERS
# ==================================================================================

n_actors <- 30  # Number of actors
n_waves <- 2    # Number of observation waves

# Attraction-repulsion parameters (based on Tang et al. 2025)
epsilon <- 1    # Threshold for attraction/assimilation (ε-near similarity)
kappa <- 3      # Threshold for repulsion (κ-far similarity)

cat("Simulation Parameters:\n")
cat("- Number of actors:", n_actors, "\n")
cat("- Attraction threshold (ε):", epsilon, "\n")
cat("- Repulsion threshold (κ):", kappa, "\n")
cat("- Social Judgment Theory zones:\n")
cat("  * Assimilation: |difference| ≤", epsilon, "\n")
cat("  * Non-commitment: ", epsilon, "< |difference| <", kappa, "\n")
cat("  * Repulsion: |difference| ≥", kappa, "\n\n")

# ==================================================================================
# 2. NETWORK GENERATION
# ==================================================================================

cat("=== GENERATING NETWORKS ===\n")

# Function to generate random network with given density
generate_network <- function(n, density) {
  matrix(as.numeric(runif(n*n) < density), n, n) * (1 - diag(n))
}

# Generate friendship network (slightly higher density)
friendship_density <- 0.15
friendship_net <- generate_network(n_actors, friendship_density)

# Generate cooperation network (correlated with friendship)
cooperation_density <- 0.12
cooperation_net <- generate_network(n_actors, cooperation_density)

# Add some correlation between networks
for(i in 1:n_actors) {
  for(j in 1:n_actors) {
    if(friendship_net[i,j] == 1 && runif(1) < 0.4) {
      cooperation_net[i,j] <- 1
    }
  }
}

cat("Friendship network density:", round(sum(friendship_net)/(n_actors*(n_actors-1)), 3), "\n")
cat("Cooperation network density:", round(sum(cooperation_net)/(n_actors*(n_actors-1)), 3), "\n")
cat("Network correlation:", round(cor(as.vector(friendship_net), as.vector(cooperation_net)), 3), "\n\n")

# ==================================================================================
# 3. TOLERANCE SIMULATION
# ==================================================================================

cat("=== SIMULATING TOLERANCE BEHAVIOR ===\n")

# Initial tolerance distribution (wave 1) - scale 1 to 5
tolerance_w1 <- sample(1:5, n_actors, replace = TRUE, prob = c(0.1, 0.2, 0.4, 0.2, 0.1))

cat("Initial tolerance distribution:\n")
print(table(tolerance_w1))

# ==================================================================================
# 4. ATTRACTION-REPULSION DYNAMICS
# ==================================================================================

cat("\n=== APPLYING ATTRACTION-REPULSION DYNAMICS ===\n")

# Function to calculate attraction-repulsion influence
calculate_influence <- function(focal_tolerance, other_tolerance, epsilon, kappa) {
  diff <- abs(focal_tolerance - other_tolerance)

  if(diff <= epsilon) {
    # Assimilation zone - move toward other
    return(0.3 * sign(other_tolerance - focal_tolerance))
  } else if(diff >= kappa) {
    # Repulsion zone - move away from other
    return(-0.2 * sign(other_tolerance - focal_tolerance))
  } else {
    # Non-commitment zone - no influence
    return(0)
  }
}

# Apply dynamics to generate wave 2
tolerance_w2 <- tolerance_w1
influence_matrix <- matrix(0, n_actors, n_actors)

for(i in 1:n_actors) {
  total_influence <- 0
  influence_count <- 0

  # Calculate influence from friends
  for(j in 1:n_actors) {
    if(i != j && friendship_net[i,j] == 1) {
      influence <- calculate_influence(tolerance_w1[i], tolerance_w1[j], epsilon, kappa)
      influence_matrix[i,j] <- influence
      total_influence <- total_influence + influence
      influence_count <- influence_count + 1
    }
  }

  # Apply average influence from friends
  if(influence_count > 0) {
    avg_influence <- total_influence / influence_count
    tolerance_w2[i] <- tolerance_w1[i] + round(avg_influence)
  }
}

# Ensure bounds
tolerance_w2[tolerance_w2 < 1] <- 1
tolerance_w2[tolerance_w2 > 5] <- 5

cat("Wave 2 tolerance distribution:\n")
print(table(tolerance_w2))

# ==================================================================================
# 5. ANALYSIS OF ATTRACTION-REPULSION EFFECTS
# ==================================================================================

cat("\n=== ATTRACTION-REPULSION ANALYSIS ===\n")

# Count types of influences
assimilation_count <- sum(influence_matrix > 0)
repulsion_count <- sum(influence_matrix < 0)
no_influence_count <- sum(influence_matrix == 0 & friendship_net == 1)

cat("Influence types among friends:\n")
cat("- Assimilative influences:", assimilation_count, "\n")
cat("- Repulsive influences:", repulsion_count, "\n")
cat("- No influence (non-commitment):", no_influence_count, "\n")

# Calculate tolerance changes
tolerance_change <- tolerance_w2 - tolerance_w1

cat("\nTolerance changes:\n")
cat("- Actors who increased tolerance:", sum(tolerance_change > 0), "\n")
cat("- Actors who decreased tolerance:", sum(tolerance_change < 0), "\n")
cat("- Actors with no change:", sum(tolerance_change == 0), "\n")
cat("- Mean change:", round(mean(tolerance_change), 3), "\n")
cat("- Standard deviation of change:", round(sd(tolerance_change), 3), "\n")

# ==================================================================================
# 6. DETAILED EXAMPLE ANALYSIS
# ==================================================================================

cat("\n=== DETAILED EXAMPLE: Actor Influence Patterns ===\n")

# Show detailed analysis for first few actors
for(actor in 1:5) {
  cat("Actor", actor, "(tolerance =", tolerance_w1[actor], "):\n")

  friends <- which(friendship_net[actor,] == 1)
  if(length(friends) > 0) {
    for(friend in friends) {
      diff <- abs(tolerance_w1[actor] - tolerance_w1[friend])
      influence <- influence_matrix[actor, friend]

      zone <- if(diff <= epsilon) "ASSIMILATION" else if(diff >= kappa) "REPULSION" else "NO INFLUENCE"

      cat("  Friend", friend, "(tolerance =", tolerance_w1[friend],
          ") | Diff =", diff, "| Zone:", zone, "| Influence:", influence, "\n")
    }
    cat("  Final tolerance:", tolerance_w2[actor], "(change:", tolerance_change[actor], ")\n")
  } else {
    cat("  No friends - no social influence\n")
  }
  cat("\n")
}

# ==================================================================================
# 7. VISUALIZATION
# ==================================================================================

cat("=== CREATING VISUALIZATIONS ===\n")

# Set up plotting area
par(mfrow = c(2, 2), mar = c(4, 4, 3, 2))

# 1. Network plot with tolerance colors
plot_network <- function(adj_matrix, node_colors, title) {
  n <- nrow(adj_matrix)
  angles <- seq(0, 2*pi, length.out = n+1)[1:n]
  x <- cos(angles)
  y <- sin(angles)

  plot(x, y, col = node_colors, pch = 19, cex = 1.5,
       xlim = c(-1.5, 1.5), ylim = c(-1.5, 1.5),
       main = title, xlab = "", ylab = "", axes = FALSE)

  for(i in 1:n) {
    for(j in 1:n) {
      if(adj_matrix[i,j] == 1) {
        arrows(x[i], y[i], x[j], y[j], length = 0.05, col = "gray", lwd = 0.5)
      }
    }
  }
}

# Color palette for tolerance levels
tolerance_colors_w1 <- rainbow(5)[tolerance_w1]
tolerance_colors_w2 <- rainbow(5)[tolerance_w2]

# Plot networks
plot_network(friendship_net, tolerance_colors_w1, "Friendship Network (Wave 1)")
plot_network(friendship_net, tolerance_colors_w2, "Friendship Network (Wave 2)")

# 2. Tolerance distributions
hist(tolerance_w1, breaks = 0.5:5.5, col = "lightblue", border = "blue",
     main = "Tolerance Distribution (Wave 1)", xlab = "Tolerance Level", ylab = "Frequency")

hist(tolerance_w2, breaks = 0.5:5.5, col = "lightcoral", border = "red",
     main = "Tolerance Distribution (Wave 2)", xlab = "Tolerance Level", ylab = "Frequency")

# 3. Change analysis
par(mfrow = c(2, 1), mar = c(4, 4, 3, 2))

# Tolerance change histogram
hist(tolerance_change, breaks = seq(-3.5, 3.5, 1), col = "lightgreen", border = "darkgreen",
     main = "Tolerance Change (Wave 2 - Wave 1)", xlab = "Change in Tolerance", ylab = "Frequency")

# Scatter plot: initial tolerance vs change
plot(tolerance_w1, tolerance_change,
     col = rainbow(5)[tolerance_w1], pch = 19, cex = 1.5,
     main = "Initial Tolerance vs. Change",
     xlab = "Initial Tolerance (Wave 1)", ylab = "Tolerance Change")
abline(h = 0, lty = 2, col = "gray")

# ==================================================================================
# 8. RSiena EFFECT FORMULATION
# ==================================================================================

cat("\n=== RSiena EFFECT IMPLEMENTATION ===\n")
cat("To implement this in RSiena, you would need:\n\n")

cat("1. ε-near similarity effect:\n")
cat("   Formula: Σ_{j≠i} max(ε - |o_j - o_i|, 0)\n")
cat("   Purpose: Captures assimilative influence from similar others\n")
cat("   Current ε =", epsilon, "\n\n")

cat("2. κ-far similarity effect:\n")
cat("   Formula: Σ_{j≠i} min(κ - |o_j - o_i|, 0)\n")
cat("   Purpose: Captures repulsive influence from dissimilar others\n")
cat("   Current κ =", kappa, "\n\n")

cat("3. Expected parameter signs:\n")
cat("   - ε-near similarity: POSITIVE (attraction/assimilation)\n")
cat("   - κ-far similarity: NEGATIVE (repulsion when parameter is negative)\n\n")

cat("4. Implementation in existing RSiena structure:\n")
cat("   - Use existing 'similarity' effects if available\n")
cat("   - Develop custom effects if needed\n")
cat("   - Include standard SAOM effects (reciprocity, transitivity, etc.)\n")
cat("   - Control for friendship influence with 'avAlt' effect\n\n")

# ==================================================================================
# 9. SUMMARY
# ==================================================================================

cat("=== SIMULATION SUMMARY ===\n")
cat("✓ Successfully simulated", n_actors, "actors with two networks\n")
cat("✓ Implemented attraction-repulsion tolerance dynamics\n")
cat("✓ Generated realistic network structures with appropriate density\n")
cat("✓ Applied Social Judgment Theory mechanisms:\n")
cat("  - Assimilation for small differences (≤", epsilon, ")\n")
cat("  - Repulsion for large differences (≥", kappa, ")\n")
cat("  - No influence for medium differences\n")
cat("✓ Created visualizations showing network and behavior patterns\n")
cat("✓ Provided framework for RSiena implementation\n\n")

cat("This simulation demonstrates the core attraction-repulsion mechanism\n")
cat("and provides a foundation for implementing the Tang et al. (2025) model\n")
cat("in RSiena with custom ε-near and κ-far similarity effects.\n")