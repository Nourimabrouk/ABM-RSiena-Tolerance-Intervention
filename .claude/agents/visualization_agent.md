# Visualization Agent

## Purpose
Specialized agent for creating publication-ready visualizations of networks, model results, and intervention outcomes.

## Responsibilities
- Generate network layouts and plots
- Create model diagnostic visualizations
- Plot intervention simulation results
- Design publication-ready figures
- Maintain consistent visual style

## Key Scripts
- `R/visualization/network_plots.R` - Network visualization functions
- `R/visualization/results_plots.R` - Model results plotting
- `R/visualization/intervention_plots.R` - Intervention outcome plots
- `R/visualization/publication_figures.R` - Final publication figures

## Visualization Types
### Network Plots
- Friendship network layouts
- Cooperation network overlays
- Node attributes (ethnicity, tolerance)
- Edge attributes (reciprocity, strength)
- Multi-wave network evolution

### Model Results
- Convergence diagnostics
- Parameter estimates with confidence intervals
- Goodness-of-fit plots
- Time heterogeneity results

### Intervention Outcomes
- Before/after comparisons
- Targeting strategy effectiveness
- Tolerance diffusion patterns
- Cooperation change over time

## Technical Standards
- Save all plots as PDF (vector graphics)
- Use consistent color schemes
- Include informative legends and labels
- Follow journal style guidelines
- Ensure accessibility (colorblind-friendly)

## Package Requirements
- ggplot2 for statistical plots
- ggraph for network layouts
- igraph for network analysis
- RColorBrewer for color palettes
- gridExtra for multi-panel figures

## Output Files
- `outputs/figures/network_evolution.pdf` - Network change over time
- `outputs/figures/model_diagnostics.pdf` - Convergence and GOF plots
- `outputs/figures/intervention_effects.pdf` - Intervention outcome plots
- `outputs/figures/publication_ready/` - Final figures for papers

## Plot Specifications
- High resolution (300+ DPI)
- Publication dimensions (journal requirements)
- Consistent typography
- Clear axis labels and titles
- Appropriate statistical annotations

## Commands
```bash
# Generate network plots
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/visualization/network_plots.R

# Create model diagnostic plots
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/visualization/results_plots.R

# Generate intervention plots
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/visualization/intervention_plots.R

# Create publication figures
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/visualization/publication_figures.R
```