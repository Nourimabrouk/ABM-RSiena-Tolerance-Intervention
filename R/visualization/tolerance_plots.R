# Modern Tolerance Visualization with ggplot2 4.0.0
# Publication-ready plots for tolerance intervention research
# Author: Your Name
# Date: September 17, 2025

library(ggplot2)    # 4.0.0 with S7 object system
library(ggdist)     # Uncertainty visualization
library(ggtext)     # Rich text in plots
library(patchwork)  # Combining plots
library(tidyverse)
library(scales)

# Load custom themes
source("R/visualization/publication_themes.R")

#' Plot Tolerance Distribution Evolution
#'
#' Shows how tolerance levels change across waves with uncertainty
#' Uses ggdist for modern Bayesian-friendly uncertainty visualization
#'
#' @param tolerance_data Data frame with columns: wave, tolerance, ethnicity, group
#' @return ggplot object
plot_tolerance_evolution <- function(tolerance_data) {
  tolerance_data %>%
    ggplot(aes(x = factor(wave), y = tolerance)) +
    stat_halfeye(
      aes(fill = ethnicity),
      alpha = 0.8,
      .width = c(0.5, 0.8, 0.95),
      point_interval = "median_qi"
    ) +
    scale_fill_manual(
      values = c("Majority" = "#2E86AB", "Minority" = "#A23B72"),
      name = "Ethnic Group"
    ) +
    scale_y_continuous(
      name = "Tolerance Level",
      limits = c(1, 5),
      breaks = 1:5,
      labels = c("Very Low", "Low", "Moderate", "High", "Very High")
    ) +
    labs(
      title = "Tolerance Evolution Across Study Waves",
      subtitle = "Distribution shows median and 50%, 80%, 95% intervals",
      x = "Study Wave",
      caption = "Data: Together for Tolerance study (n=2,585)"
    ) +
    facet_wrap(~ group, labeller = label_both) +
    theme_tolerance_publication() +
    theme(
      legend.position = "bottom",
      strip.background = element_rect(fill = "grey95", color = "grey80")
    )
}

#' Plot Intervention Effect Visualization
#'
#' Shows tolerance changes from baseline with confidence intervals
#' Emphasizes uncertainty as first-class citizen
#'
#' @param intervention_effects Data with effect sizes and credible intervals
#' @return ggplot object
plot_intervention_effects <- function(intervention_effects) {
  intervention_effects %>%
    mutate(
      scenario = fct_reorder(scenario, effect_size),
      significant = ci_lower > 0
    ) %>%
    ggplot(aes(y = scenario, x = effect_size)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
    stat_pointinterval(
      aes(
        xmin = ci_lower,
        xmax = ci_upper,
        color = significant
      ),
      point_size = 3,
      interval_size = 1.2,
      .width = c(0.66, 0.95)
    ) +
    scale_color_manual(
      values = c("TRUE" = "#1B9E77", "FALSE" = "#D95F02"),
      labels = c("Non-significant", "Significant"),
      name = "Effect"
    ) +
    scale_x_continuous(
      name = "Tolerance Change (Cohen's d)",
      breaks = seq(-0.5, 1.5, 0.25),
      labels = number_format(accuracy = 0.01)
    ) +
    labs(
      title = "Intervention Effects on Tolerance",
      subtitle = "Point estimates with 66% and 95% credible intervals",
      y = "Intervention Scenario",
      caption = "Positive values indicate increased tolerance"
    ) +
    theme_tolerance_publication() +
    theme(
      legend.position = "bottom",
      panel.grid.major.y = element_line(color = "grey90", linewidth = 0.3)
    )
}

#' Plot Tolerance Diffusion Network
#'
#' Visualizes how tolerance spreads through social networks
#' Uses modern ggraph with ggplot2 4.0.0 integration
#'
#' @param network_data Network with node attributes
#' @param layout_algorithm Layout algorithm for network
#' @return ggplot object
plot_tolerance_diffusion <- function(network_data, layout_algorithm = "fr") {
  # This function requires tidygraph and ggraph
  require(tidygraph)
  require(ggraph)

  network_data %>%
    activate(nodes) %>%
    mutate(
      tolerance_change = tolerance_post - tolerance_pre,
      tolerance_category = case_when(
        tolerance_change > 0.5 ~ "Increased",
        tolerance_change < -0.5 ~ "Decreased",
        TRUE ~ "Stable"
      ),
      intervention_target = ifelse(intervention_target, "Targeted", "Non-targeted")
    ) %>%
    ggraph(layout = layout_algorithm) +
    geom_edge_link(
      aes(alpha = friendship_strength),
      color = "grey70",
      linewidth = 0.3
    ) +
    geom_node_point(
      aes(
        size = centrality,
        color = tolerance_change,
        shape = intervention_target
      ),
      alpha = 0.8
    ) +
    scale_edge_alpha_continuous(
      range = c(0.1, 0.6),
      guide = "none"
    ) +
    scale_color_gradient2(
      low = "#D73027",
      mid = "#F7F7F7",
      high = "#1A9850",
      midpoint = 0,
      name = "Tolerance\nChange",
      labels = function(x) sprintf("%+.1f", x)
    ) +
    scale_size_continuous(
      range = c(1, 4),
      name = "Network\nCentrality"
    ) +
    scale_shape_manual(
      values = c("Targeted" = 17, "Non-targeted" = 16),
      name = "Intervention\nStatus"
    ) +
    labs(
      title = "Tolerance Diffusion in School Networks",
      subtitle = "Node size = centrality, color = tolerance change, shape = intervention target",
      caption = "Layout: Fruchterman-Reingold algorithm"
    ) +
    theme_void() +
    theme(
      legend.position = "right",
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 11, color = "grey40"),
      legend.box = "vertical"
    ) +
    guides(
      color = guide_colorbar(barwidth = 1, barheight = 8),
      size = guide_legend(override.aes = list(shape = 16)),
      shape = guide_legend(override.aes = list(size = 3))
    )
}

#' Plot Interethnic Cooperation Outcomes
#'
#' Shows cooperation levels by ethnicity pairing
#' Uses faceting for clear comparison
#'
#' @param cooperation_data Data with cooperation outcomes by ethnic pairing
#' @return ggplot object
plot_interethnic_cooperation <- function(cooperation_data) {
  cooperation_data %>%
    mutate(
      ethnic_pairing = factor(
        ethnic_pairing,
        levels = c("Majority-Majority", "Majority-Minority", "Minority-Minority"),
        labels = c("Within-Majority", "Interethnic", "Within-Minority")
      )
    ) %>%
    ggplot(aes(x = wave, y = cooperation_rate)) +
    stat_lineribbon(
      aes(fill = ethnic_pairing),
      .width = c(0.5, 0.8, 0.95),
      alpha = 0.6,
      linewidth = 1
    ) +
    scale_fill_viridis_d(
      option = "plasma",
      begin = 0.2,
      end = 0.8,
      name = "Ethnic Pairing"
    ) +
    scale_x_continuous(
      name = "Study Wave",
      breaks = 1:3,
      labels = c("Baseline", "Post-Intervention", "Follow-up")
    ) +
    scale_y_continuous(
      name = "Cooperation Rate",
      labels = percent_format(),
      limits = c(0, 1)
    ) +
    labs(
      title = "Interethnic Cooperation Over Time",
      subtitle = "Ribbons show 50%, 80%, and 95% credible intervals",
      caption = "Key outcome: sustained increase in interethnic cooperation"
    ) +
    facet_wrap(~ school, labeller = label_both) +
    theme_tolerance_publication() +
    theme(
      legend.position = "bottom",
      strip.background = element_rect(fill = "grey95", color = "grey80")
    )
}

#' Plot Model Convergence Diagnostics
#'
#' Modern visualization of RSiena convergence using ggdist
#'
#' @param convergence_data Data frame with convergence statistics
#' @return ggplot object
plot_convergence_diagnostics <- function(convergence_data) {
  # Create diagnostic plot showing t-ratios
  p1 <- convergence_data %>%
    mutate(
      converged = abs(t_ratio) < 0.1,
      effect_clean = str_wrap(effect, 20)
    ) %>%
    ggplot(aes(y = fct_reorder(effect_clean, abs(t_ratio)), x = t_ratio)) +
    geom_vline(xintercept = c(-0.1, 0.1), linetype = "dashed", color = "red", alpha = 0.7) +
    geom_vline(xintercept = 0, color = "grey50") +
    geom_point(
      aes(color = converged),
      size = 3,
      alpha = 0.8
    ) +
    scale_color_manual(
      values = c("TRUE" = "#1B9E77", "FALSE" = "#D95F02"),
      labels = c("Not Converged", "Converged"),
      name = "Status"
    ) +
    scale_x_continuous(
      name = "t-ratio",
      limits = c(-0.5, 0.5),
      breaks = seq(-0.4, 0.4, 0.2)
    ) +
    labs(
      title = "RSiena Model Convergence",
      subtitle = "t-ratios should be within ±0.1 (red lines)",
      y = "Model Effect"
    ) +
    theme_tolerance_publication() +
    theme(
      legend.position = "bottom",
      axis.text.y = element_text(size = 9)
    )

  # Create overall convergence ratio plot
  p2 <- convergence_data %>%
    summarise(
      max_conv_ratio = max(abs(t_ratio), na.rm = TRUE),
      .groups = "drop"
    ) %>%
    ggplot(aes(x = 1, y = max_conv_ratio)) +
    geom_hline(yintercept = 0.25, linetype = "dashed", color = "red", alpha = 0.7) +
    geom_col(
      fill = ifelse(pull(., max_conv_ratio) < 0.25, "#1B9E77", "#D95F02"),
      width = 0.5,
      alpha = 0.8
    ) +
    scale_y_continuous(
      name = "Maximum Convergence Ratio",
      limits = c(0, max(0.3, max(convergence_data$t_ratio, na.rm = TRUE) * 1.1))
    ) +
    scale_x_continuous(
      limits = c(0.5, 1.5),
      breaks = NULL
    ) +
    labs(
      title = "Overall Convergence",
      subtitle = "Should be < 0.25"
    ) +
    theme_tolerance_publication() +
    theme(
      axis.title.x = element_blank(),
      axis.text.x = element_blank()
    )

  # Combine plots
  p1 + p2 +
    plot_layout(widths = c(3, 1)) +
    plot_annotation(
      caption = "RSiena convergence diagnostics: all effects should meet convergence criteria"
    )
}

#' Create tolerance intervention summary dashboard
#'
#' Combines multiple visualizations into publication-ready figure
#'
#' @param tolerance_data Tolerance evolution data
#' @param effect_data Intervention effect data
#' @param network_data Network diffusion data
#' @return Combined ggplot object
create_tolerance_dashboard <- function(tolerance_data, effect_data, network_data) {
  p1 <- plot_tolerance_evolution(tolerance_data)
  p2 <- plot_intervention_effects(effect_data)
  p3 <- plot_tolerance_diffusion(network_data)

  # Combine with patchwork
  dashboard <- (p1 | p2) / p3 +
    plot_layout(heights = c(1, 1.2)) +
    plot_annotation(
      title = "Tolerance Intervention Research Dashboard",
      subtitle = "Social norm interventions for interethnic cooperation",
      caption = "PhD Dissertation Research | Utrecht University | Statistical Sociology",
      theme = theme(
        plot.title = element_text(size = 16, face = "bold"),
        plot.subtitle = element_text(size = 12),
        plot.caption = element_text(size = 10, color = "grey50")
      )
    )

  return(dashboard)
}

#' Export plots with consistent styling
#'
#' @param plot_object ggplot object to export
#' @param filename Output filename
#' @param width Plot width in inches
#' @param height Plot height in inches
#' @param dpi Resolution
export_tolerance_plot <- function(plot_object, filename, width = 10, height = 8, dpi = 300) {
  # Ensure outputs directory exists
  dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)

  ggsave(
    filename = file.path("outputs/figures", filename),
    plot = plot_object,
    width = width,
    height = height,
    dpi = dpi,
    device = cairo_pdf,  # High-quality PDF output
    bg = "white"
  )

  cat("Plot saved to:", file.path("outputs/figures", filename), "\n")
}

# Example usage and testing
if (FALSE) {
  # This section is for testing and examples
  # Load example data
  example_tolerance <- read_csv("data/processed/tolerance_evolution.csv")
  example_effects <- read_csv("data/processed/intervention_effects.csv")

  # Create plots
  p1 <- plot_tolerance_evolution(example_tolerance)
  p2 <- plot_intervention_effects(example_effects)

  # Export plots
  export_tolerance_plot(p1, "tolerance_evolution.pdf")
  export_tolerance_plot(p2, "intervention_effects.pdf")
}