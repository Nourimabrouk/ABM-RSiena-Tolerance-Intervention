# Publication-Ready ggplot2 4.0.0 Themes
# Custom themes for tolerance intervention research
# Adheres to modern visualization standards
# Author: Your Name
# Date: September 17, 2025

library(ggplot2)
library(ggtext)     # For rich text elements
library(showtext)   # For custom fonts (optional)

#' Main publication theme for tolerance research
#'
#' Clean, minimal theme optimized for academic publications
#' Follows Wickham's Grammar of Graphics principles
#'
#' @param base_size Base font size
#' @param base_family Font family
#' @return ggplot2 theme object
theme_tolerance_publication <- function(base_size = 12, base_family = "") {
  theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      # Overall plot appearance
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      panel.border = element_blank(),

      # Grid lines - minimal but functional
      panel.grid.major = element_line(color = "grey92", linewidth = 0.3),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_line(color = "grey95", linewidth = 0.2),

      # Axes
      axis.line = element_line(color = "grey20", linewidth = 0.4),
      axis.ticks = element_line(color = "grey20", linewidth = 0.3),
      axis.ticks.length = unit(0.15, "cm"),

      # Text elements
      plot.title = element_text(
        size = rel(1.3),
        face = "bold",
        color = "grey10",
        margin = margin(b = 10)
      ),
      plot.subtitle = element_text(
        size = rel(1.0),
        color = "grey30",
        margin = margin(b = 15)
      ),
      plot.caption = element_text(
        size = rel(0.8),
        color = "grey50",
        hjust = 0,
        margin = margin(t = 10)
      ),

      # Axis text
      axis.title = element_text(
        size = rel(1.0),
        color = "grey20"
      ),
      axis.text = element_text(
        size = rel(0.9),
        color = "grey30"
      ),

      # Legend
      legend.background = element_rect(fill = "white", color = NA),
      legend.key = element_rect(fill = "white", color = NA),
      legend.text = element_text(size = rel(0.9), color = "grey30"),
      legend.title = element_text(size = rel(1.0), color = "grey20"),
      legend.margin = margin(10, 10, 10, 10),
      legend.box.spacing = unit(0.4, "cm"),

      # Faceting
      strip.background = element_rect(
        fill = "grey95",
        color = "grey80",
        linewidth = 0.3
      ),
      strip.text = element_text(
        size = rel(0.95),
        color = "grey20",
        face = "bold",
        margin = margin(4, 4, 4, 4)
      ),

      # Spacing
      plot.margin = margin(20, 20, 20, 20),
      panel.spacing = unit(0.6, "cm")
    )
}

#' Network visualization theme
#'
#' Specialized theme for network plots using ggraph
#' Removes axes and grid for clean network display
#'
#' @param base_size Base font size
#' @return ggplot2 theme object
theme_tolerance_network <- function(base_size = 12) {
  theme_void(base_size = base_size) +
    theme(
      # Plot elements
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),

      # Text elements
      plot.title = element_text(
        size = rel(1.3),
        face = "bold",
        color = "grey10",
        hjust = 0.5,
        margin = margin(b = 10)
      ),
      plot.subtitle = element_text(
        size = rel(1.0),
        color = "grey30",
        hjust = 0.5,
        margin = margin(b = 15)
      ),
      plot.caption = element_text(
        size = rel(0.8),
        color = "grey50",
        hjust = 0.5,
        margin = margin(t = 10)
      ),

      # Legend positioning for networks
      legend.position = "right",
      legend.background = element_rect(fill = "white", color = NA),
      legend.key = element_rect(fill = "white", color = NA),
      legend.text = element_text(size = rel(0.9), color = "grey30"),
      legend.title = element_text(size = rel(1.0), color = "grey20"),
      legend.box = "vertical",
      legend.margin = margin(10, 10, 10, 10),

      # Overall spacing
      plot.margin = margin(20, 20, 20, 20)
    )
}

#' Dashboard theme for combined plots
#'
#' Optimized for multi-panel figures and dashboards
#' Reduced spacing for efficient use of space
#'
#' @param base_size Base font size
#' @return ggplot2 theme object
theme_tolerance_dashboard <- function(base_size = 10) {
  theme_tolerance_publication(base_size = base_size) +
    theme(
      # Reduced spacing for dashboard
      plot.margin = margin(10, 10, 10, 10),
      panel.spacing = unit(0.3, "cm"),

      # Smaller text for dashboard
      plot.title = element_text(size = rel(1.2)),
      plot.subtitle = element_text(size = rel(0.9)),
      plot.caption = element_text(size = rel(0.7)),

      # Compact legend
      legend.margin = margin(5, 5, 5, 5),
      legend.box.spacing = unit(0.2, "cm"),

      # Strip text
      strip.text = element_text(size = rel(0.8))
    )
}

#' Presentation theme for slides and talks
#'
#' High contrast, larger text for visibility in presentations
#'
#' @param base_size Base font size (larger for presentations)
#' @return ggplot2 theme object
theme_tolerance_presentation <- function(base_size = 16) {
  theme_tolerance_publication(base_size = base_size) +
    theme(
      # High contrast for presentations
      text = element_text(color = "black"),
      axis.text = element_text(color = "black"),
      axis.title = element_text(color = "black"),

      # Larger text elements
      plot.title = element_text(size = rel(1.4), face = "bold"),
      plot.subtitle = element_text(size = rel(1.1)),
      axis.title = element_text(size = rel(1.1)),
      axis.text = element_text(size = rel(1.0)),
      legend.text = element_text(size = rel(1.0)),
      legend.title = element_text(size = rel(1.1)),

      # Thicker lines for visibility
      axis.line = element_line(linewidth = 0.6),
      panel.grid.major = element_line(linewidth = 0.4),

      # Increased margins
      plot.margin = margin(25, 25, 25, 25)
    )
}

#' Color palettes for tolerance research
#'
#' Consistent color schemes for different data types
#'
#' @return Named list of color palettes
tolerance_color_palettes <- function() {
  list(
    # Ethnic groups
    ethnicity = c(
      "Majority" = "#2E86AB",      # Blue
      "Minority" = "#A23B72",      # Purple
      "Mixed" = "#F18F01"          # Orange
    ),

    # Intervention status
    intervention = c(
      "Control" = "#7F8C8D",       # Gray
      "Treatment" = "#27AE60",     # Green
      "Targeted" = "#E74C3C",      # Red
      "Non-targeted" = "#95A5A6"   # Light gray
    ),

    # Tolerance levels (diverging)
    tolerance = c(
      "Very Low" = "#D73027",      # Dark red
      "Low" = "#FC8D59",           # Light red
      "Moderate" = "#FEE08B",      # Yellow
      "High" = "#91D1C2",          # Light green
      "Very High" = "#1A9641"      # Dark green
    ),

    # Network centrality (sequential)
    centrality = c(
      "Low" = "#F7FBFF",
      "Medium" = "#6BAED6",
      "High" = "#08306B"
    ),

    # Cooperation outcomes
    cooperation = c(
      "None" = "#FFFFFF",
      "Low" = "#FED976",
      "Medium" = "#FD8D3C",
      "High" = "#E31A1C"
    ),

    # Statistical significance
    significance = c(
      "Non-significant" = "#D95F02",  # Orange
      "Significant" = "#1B9E77"       # Teal
    )
  )
}

#' Get tolerance color palette
#'
#' @param palette_name Name of palette from tolerance_color_palettes()
#' @return Named vector of colors
get_tolerance_colors <- function(palette_name) {
  palettes <- tolerance_color_palettes()
  if (!palette_name %in% names(palettes)) {
    stop("Palette '", palette_name, "' not found. Available: ",
         paste(names(palettes), collapse = ", "))
  }
  return(palettes[[palette_name]])
}

#' Apply tolerance color scale to ggplot
#'
#' @param palette_name Name of color palette
#' @param discrete Whether the scale is discrete (TRUE) or continuous (FALSE)
#' @param ... Additional arguments passed to scale function
#' @return ggplot2 scale object
scale_color_tolerance <- function(palette_name, discrete = TRUE, ...) {
  colors <- get_tolerance_colors(palette_name)

  if (discrete) {
    scale_color_manual(values = colors, ...)
  } else {
    scale_color_gradientn(colors = colors, ...)
  }
}

#' Apply tolerance fill scale to ggplot
#'
#' @param palette_name Name of color palette
#' @param discrete Whether the scale is discrete (TRUE) or continuous (FALSE)
#' @param ... Additional arguments passed to scale function
#' @return ggplot2 scale object
scale_fill_tolerance <- function(palette_name, discrete = TRUE, ...) {
  colors <- get_tolerance_colors(palette_name)

  if (discrete) {
    scale_fill_manual(values = colors, ...)
  } else {
    scale_fill_gradientn(colors = colors, ...)
  }
}

#' Set global ggplot2 theme for tolerance research
#'
#' Sets the default theme for all subsequent plots
#'
#' @param theme_function Theme function to use as default
#' @param ... Additional arguments passed to theme function
set_tolerance_theme <- function(theme_function = theme_tolerance_publication, ...) {
  theme_set(theme_function(...))

  # Also set default discrete color scale
  options(
    ggplot2.discrete.colour = get_tolerance_colors("ethnicity"),
    ggplot2.discrete.fill = get_tolerance_colors("ethnicity")
  )

  cat("Set tolerance research theme as default\n")
}

#' Create consistent figure caption for publications
#'
#' @param data_source Description of data source
#' @param sample_size Sample size description
#' @param time_period Time period of study
#' @return Formatted caption string
tolerance_figure_caption <- function(
  data_source = "Together for Tolerance study",
  sample_size = "n=2,585 students",
  time_period = "3 waves"
) {
  paste0(
    "Data: ", data_source, " (", sample_size, ", ", time_period, "). ",
    "PhD research on tolerance interventions for interethnic cooperation."
  )
}

#' Print theme usage guide
#'
#' Displays information about available themes and their use cases
print_theme_guide <- function() {
  cat("Tolerance Research ggplot2 Themes\n")
  cat("==================================\n\n")

  cat("Available themes:\n")
  cat("• theme_tolerance_publication() - Main theme for journal articles\n")
  cat("• theme_tolerance_network() - For network visualizations (ggraph)\n")
  cat("• theme_tolerance_dashboard() - Multi-panel figures\n")
  cat("• theme_tolerance_presentation() - Slides and talks\n\n")

  cat("Color palettes:\n")
  palettes <- tolerance_color_palettes()
  for (name in names(palettes)) {
    cat("•", name, ":", length(palettes[[name]]), "colors\n")
  }

  cat("\nUsage:\n")
  cat("theme_set(theme_tolerance_publication())\n")
  cat("scale_color_tolerance('ethnicity')\n")
  cat("scale_fill_tolerance('intervention')\n")
}

# Set up default theme when package loads
# theme_set(theme_tolerance_publication())

# Example usage
if (FALSE) {
  # This is for testing and demonstration
  library(ggplot2)

  # Set default theme
  set_tolerance_theme()

  # Create example plot
  mtcars %>%
    ggplot(aes(x = mpg, y = hp, color = factor(cyl))) +
    geom_point(size = 3, alpha = 0.7) +
    scale_color_tolerance("ethnicity") +
    labs(
      title = "Example Plot with Tolerance Theme",
      subtitle = "Demonstrates publication-ready styling",
      x = "Miles per Gallon",
      y = "Horsepower",
      color = "Cylinders",
      caption = tolerance_figure_caption()
    )

  # Print theme guide
  print_theme_guide()
}