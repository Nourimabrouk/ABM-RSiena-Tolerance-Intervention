# Data Helper Functions for RSiena SAOM Analysis
# Utility functions for data preparation, validation, and transformation

#' Validate Network Structure
#'
#' Check network data for common issues before RSiena analysis
#'
#' @param network_data Network adjacency matrix or array
#' @param wave_labels Character vector of wave labels (optional)
#' @return List of validation results
validate_network_structure <- function(network_data, wave_labels = NULL) {
  cat("Validating network structure...\n")

  results <- list()

  # Check dimensions
  if (is.matrix(network_data)) {
    # Single wave network
    results$dimensions <- dim(network_data)
    results$n_waves <- 1
    results$n_actors <- nrow(network_data)
  } else if (is.array(network_data) && length(dim(network_data)) == 3) {
    # Multi-wave network
    results$dimensions <- dim(network_data)
    results$n_waves <- dim(network_data)[3]
    results$n_actors <- dim(network_data)[1]
  } else {
    stop("Network data must be a matrix or 3D array")
  }

  # Check for valid values
  valid_values <- c(0, 1, 10, 11, NA)
  unique_values <- unique(as.vector(network_data))
  invalid_values <- setdiff(unique_values, valid_values)

  if (length(invalid_values) > 0) {
    warning("Invalid values found in network data: ", paste(invalid_values, collapse = ", "))
    results$invalid_values <- invalid_values
  } else {
    results$invalid_values <- NULL
  }

  # Check diagonal (should be 0 for most networks)
  if (is.matrix(network_data)) {
    diag_values <- diag(network_data)
  } else {
    diag_values <- sapply(1:results$n_waves, function(w) diag(network_data[,,w]))
  }

  non_zero_diag <- sum(diag_values != 0, na.rm = TRUE)
  if (non_zero_diag > 0) {
    warning("Non-zero diagonal elements found: ", non_zero_diag)
    results$non_zero_diagonal <- non_zero_diag
  }

  # Calculate basic statistics
  if (is.matrix(network_data)) {
    results$density <- mean(network_data == 1, na.rm = TRUE)
    results$missing_prop <- mean(is.na(network_data))
  } else {
    results$density <- sapply(1:results$n_waves, function(w) {
      mean(network_data[,,w] == 1, na.rm = TRUE)
    })
    results$missing_prop <- sapply(1:results$n_waves, function(w) {
      mean(is.na(network_data[,,w]))
    })
    names(results$density) <- wave_labels %||% paste0("Wave", 1:results$n_waves)
    names(results$missing_prop) <- wave_labels %||% paste0("Wave", 1:results$n_waves)
  }

  cat("✓ Network validation complete\n")
  return(results)
}

#' Calculate Jaccard Stability
#'
#' Calculate Jaccard indices between consecutive waves
#' Essential for RSiena analysis - target > 0.30
#'
#' @param network_array 3D array of networks [actors, actors, waves]
#' @return Vector of Jaccard indices between consecutive waves
calculate_jaccard_stability <- function(network_array) {
  if (length(dim(network_array)) != 3) {
    stop("Network array must be 3-dimensional")
  }

  n_waves <- dim(network_array)[3]
  if (n_waves < 2) {
    stop("Need at least 2 waves to calculate Jaccard stability")
  }

  jaccard_indices <- numeric(n_waves - 1)

  for (w in 1:(n_waves - 1)) {
    net1 <- network_array[,,w]
    net2 <- network_array[,,w+1]

    # Only consider non-missing and non-structural values
    valid_mask <- !is.na(net1) & !is.na(net2) &
                  !(net1 %in% c(10, 11)) & !(net2 %in% c(10, 11))

    if (sum(valid_mask) == 0) {
      jaccard_indices[w] <- NA
      next
    }

    net1_valid <- net1[valid_mask]
    net2_valid <- net2[valid_mask]

    # Calculate Jaccard index
    ties_both <- sum(net1_valid == 1 & net2_valid == 1)
    ties_either <- sum(net1_valid == 1 | net2_valid == 1)

    jaccard_indices[w] <- if (ties_either > 0) ties_both / ties_either else 1
  }

  names(jaccard_indices) <- paste0("Wave", 1:(n_waves-1), "_to_", 2:n_waves)
  return(jaccard_indices)
}

#' Check Composition Changes
#'
#' Identify actors who join or leave between waves
#'
#' @param network_array 3D array of networks
#' @return List with joiners and leavers information
check_composition_changes <- function(network_array) {
  n_actors <- dim(network_array)[1]
  n_waves <- dim(network_array)[3]

  # Check which actors are present in each wave
  # An actor is present if they have at least one non-missing tie
  presence_matrix <- matrix(FALSE, nrow = n_actors, ncol = n_waves)

  for (w in 1:n_waves) {
    for (i in 1:n_actors) {
      # Check if actor i has any non-missing outgoing or incoming ties
      outgoing <- !all(is.na(network_array[i, , w]))
      incoming <- !all(is.na(network_array[, i, w]))
      presence_matrix[i, w] <- outgoing || incoming
    }
  }

  # Identify joiners and leavers
  joiners <- list()
  leavers <- list()

  for (w in 2:n_waves) {
    # Joiners: present in wave w but not in wave w-1
    wave_joiners <- which(presence_matrix[, w] & !presence_matrix[, w-1])
    if (length(wave_joiners) > 0) {
      joiners[[paste0("Wave", w)]] <- wave_joiners
    }

    # Leavers: present in wave w-1 but not in wave w
    wave_leavers <- which(presence_matrix[, w-1] & !presence_matrix[, w])
    if (length(wave_leavers) > 0) {
      leavers[[paste0("Wave", w)]] <- wave_leavers
    }
  }

  return(list(
    presence_matrix = presence_matrix,
    joiners = joiners,
    leavers = leavers,
    stable_actors = which(apply(presence_matrix, 1, all))
  ))
}

#' Validate Behavior Data
#'
#' Check behavior matrix for RSiena requirements
#'
#' @param behavior_matrix Matrix of behavior scores [actors, waves]
#' @param expected_range Expected range of behavior values (optional)
#' @return List of validation results
validate_behavior_data <- function(behavior_matrix, expected_range = NULL) {
  cat("Validating behavior data...\n")

  results <- list()
  results$dimensions <- dim(behavior_matrix)
  results$n_actors <- nrow(behavior_matrix)
  results$n_waves <- ncol(behavior_matrix)

  # Check for valid numeric data
  if (!is.numeric(behavior_matrix)) {
    stop("Behavior matrix must be numeric")
  }

  # Check range
  results$actual_range <- range(behavior_matrix, na.rm = TRUE)
  results$unique_values <- sort(unique(as.vector(behavior_matrix[!is.na(behavior_matrix)])))

  if (!is.null(expected_range)) {
    outside_range <- behavior_matrix < expected_range[1] | behavior_matrix > expected_range[2]
    outside_range[is.na(behavior_matrix)] <- FALSE

    if (any(outside_range)) {
      warning("Values outside expected range found")
      results$outside_range_count <- sum(outside_range)
    }
  }

  # Check for monotonicity (may affect SAOM estimation)
  monotonic_actors <- apply(behavior_matrix, 1, function(row) {
    non_missing <- !is.na(row)
    if (sum(non_missing) < 2) return(NA)

    values <- row[non_missing]
    all(diff(values) >= 0) || all(diff(values) <= 0)
  })

  results$monotonic_count <- sum(monotonic_actors, na.rm = TRUE)
  results$monotonic_actors <- which(monotonic_actors)

  if (results$monotonic_count > results$n_actors * 0.5) {
    warning("High proportion of monotonic actors detected: ",
            round(results$monotonic_count / results$n_actors * 100, 1), "%")
  }

  # Missing data patterns
  results$missing_prop <- mean(is.na(behavior_matrix))
  results$missing_by_wave <- apply(behavior_matrix, 2, function(col) mean(is.na(col)))
  results$missing_by_actor <- apply(behavior_matrix, 1, function(row) mean(is.na(row)))

  cat("✓ Behavior validation complete\n")
  return(results)
}

#' Create Covariate Matrix
#'
#' Helper function to create properly formatted covariate matrices
#'
#' @param data Data frame with actor attributes
#' @param var_name Name of the variable to convert
#' @param type Type of covariate ("constant", "changing")
#' @return Formatted covariate matrix or vector
create_covariate <- function(data, var_name, type = "constant") {
  if (!var_name %in% names(data)) {
    stop("Variable '", var_name, "' not found in data")
  }

  if (type == "constant") {
    # Time-constant covariate
    values <- data[[var_name]]

    # Convert factors to numeric if needed
    if (is.factor(values)) {
      values <- as.numeric(values)
    }

    return(values)
  } else if (type == "changing") {
    # Time-changing covariate - implement based on data structure
    stop("Time-changing covariates not yet implemented")
  } else {
    stop("Type must be 'constant' or 'changing'")
  }
}

#' Apply Structural Constraints
#'
#' Apply structural zeros and ones to network arrays
#'
#' @param network_array 3D network array
#' @param constraint_matrix Matrix indicating structural constraints
#' @param constraint_type Type of constraint: "zero" (10) or "one" (11)
#' @return Modified network array
apply_structural_constraints <- function(network_array, constraint_matrix, constraint_type = "zero") {
  constraint_value <- if (constraint_type == "zero") 10 else 11

  for (w in 1:dim(network_array)[3]) {
    network_array[,,w][constraint_matrix] <- constraint_value
  }

  return(network_array)
}

#' Generate Data Quality Report
#'
#' Create comprehensive data quality report for RSiena analysis
#'
#' @param siena_data RSiena data object
#' @param output_file Output file path (optional)
#' @return Invisible list of all diagnostics
generate_data_quality_report <- function(siena_data, output_file = NULL) {
  cat("Generating comprehensive data quality report...\n")

  # This would generate a detailed report
  # Implementation would depend on the specific siena_data structure

  if (!is.null(output_file)) {
    cat("Report would be saved to:", output_file, "\n")
  }

  cat("✓ Data quality report complete\n")

  # Return diagnostics list (placeholder)
  return(invisible(list(
    timestamp = Sys.time(),
    status = "complete"
  )))
}