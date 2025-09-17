# CLAUDE.md

This file provides guidance to Claude Code when working with Agent-Based Models (ABM) for statistical sociology research.

## Repository Overview

This repository contains a PhD dissertation project focused on Stochastic Actor-Oriented Models (SAOM) using RSiena for investigating social norm interventions to promote interethnic cooperation through tolerance. The research utilizes R with RSiena as the primary analytical framework with Claude Code coordination for advanced computational social science research.

## Research Context

**Discipline**: Statistical Sociology / Computational Social Science
**Focus**: Social norm interventions for interethnic cooperation using SAOM/ABM
**Objective**: PhD dissertation investigating how tolerance interventions spread through social networks and affect interethnic cooperation
**Primary Tools**: R with RSiena, Claude Code for development and analysis coordination
**Data**: 5825 observations, 2585 respondents, 105 classes, 3 schools, 3 time waves

## 🎯 **CRITICAL PUBLICATION CONSTRAINT**

**MAXIMUM WORD LIMIT: 10,000 WORDS**

This entire research project must produce **ONE HIGH-QUALITY ACADEMIC PAPER** of maximum 10,000 words for publication in a top-tier statistical sociology journal. Every analysis, every code line, every decision must serve this singular publication goal.

### Publication Scope Discipline
- **Single Focus**: Tolerance intervention effectiveness via network diffusion
- **Core Contribution**: SAOM methodology for intervention analysis
- **Key Innovation**: Attraction-repulsion mechanism for tolerance spread
- **Policy Relevance**: Optimal intervention targeting strategies
- **Theoretical Advance**: Network-mediated tolerance → cooperation pathway

### Word Allocation Framework
```
Target Publication Structure (≤10,000 words):
├── Abstract (250 words)
├── Introduction (1,500 words)
├── Literature Review (1,500 words)
├── Methodology (2,000 words)
├── Results (3,000 words)
├── Discussion (1,500 words)
└── Conclusion (250 words)
```

### Scope Boundaries (EXCLUDE)
- ❌ Multiple intervention types beyond tolerance
- ❌ Extensive sensitivity analyses beyond journal requirements
- ❌ Exploratory effects not central to tolerance argument
- ❌ Methodological extensions for future work
- ❌ Additional robustness checks beyond essential validation

## Research Question

How can individual-level changes in tolerance from interventions spread and persist in social networks to increase sustained interethnic cooperation?

## Development Guidelines

### R Environment Commands

**R Installation Path**: `C:\Program Files\R\R-4.5.1\`

```bash
# Execute R scripts directly
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" script.R

# Run R interactively
"C:\Program Files\R\R-4.5.1\bin\x64\R.exe"

# Install core packages
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" -e "install.packages(c('RSiena', 'RSienaTest', 'network', 'sna', 'igraph', 'tidyverse', 'data.table', 'ggplot2', 'ggraph', 'ggdist', 'ggtext', 'gganimate', 'sf', 'tmap', 'vdiffr', 'ggh4x', 'ggforce', 'ggnewscale', 'patchwork', 'targets', 'quarto', 'parallel', 'foreach', 'doParallel'), repos='https://cloud.r-project.org')"
```

### VSCode Terminal Workflow

**Claude Code in VSCode Terminal**:
- Always use absolute paths for R scripts
- Execute R commands via Rscript.exe for non-interactive operations
- Use R.exe for interactive sessions when needed
- Save plots to files rather than attempting interactive display

**Best Practices for R in Terminal**:
```bash
# Good: Run analysis and save output
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/siena_models/main_analysis.R

# Good: Generate plots to file
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" -e "pdf('outputs/figures/network_plot.pdf'); plot(network); dev.off()"

# Avoid: Interactive commands that require GUI
# Instead: Save all outputs to files for review
```

### Code Quality Standards

**RSiena-Specific Requirements**:
- All models must achieve proper convergence (t-ratios < 0.1, max convergence ratio < 0.25)
- Use print01Report() to check Jaccard stability before modeling (>0.30 ideal)
- Implement proper handling of structural zeros/ones (10/11 codes)
- Document random seeds for reproducibility
- Use sienaGOF() for goodness-of-fit assessment

**R Code Standards**:
- Use roxygen2 documentation for all functions
- Follow tidyverse style guide
- Implement unit tests using testthat
- Use explicit namespace references (e.g., RSiena::siena07())
- Save all outputs (plots, tables, models) to files

### SAOM Development Workflow

**Standard RSiena Pipeline**:
1. **Data Preparation**: Create sienaDependent objects for networks and behaviors
2. **Diagnostics**: Run print01Report() to check data quality
3. **Model Specification**: Use getEffects() and includeEffects()
4. **Estimation**: siena07() with convergence monitoring
5. **Convergence Check**: Verify t-ratios and max convergence ratio
6. **Time Heterogeneity**: sienaTimeTest() for multi-wave data
7. **Goodness-of-Fit**: sienaGOF() for model validation
8. **Simulation**: Forward simulation for intervention scenarios

### Custom Effects Implementation

**Attraction-Repulsion Effect**:
- Friend-based influence with latitude of acceptance
- Requires C++ development in RSiena architecture
- Test against known benchmarks before use

**Complex Contagion**:
- Multiple simultaneous exposure thresholds
- Implement via custom interaction effects
- Document threshold parameters clearly

## Modern Visualization Standards (ggplot2 4.0.0)

### Grammar of Graphics Philosophy

Following Wickham's north star principle: treat plots as declarative compositions of **data → aesthetics → geometric marks**, modulated by scales, stats, coordinates, facets, and themes. ggplot2 4.0.0 modernizes internals with S7 object system while maintaining the declarative API.

### Key ggplot2 4.0.0 Updates

**Breaking Changes**:
- S3 parts replaced with S7 object system for better type safety
- Enhanced guide system for axes and legends
- Deprecated dot-dot notation (use `after_stat()` instead)
- `size` aesthetic replaced with `linewidth` for lines

**New Features for Research**:
- `coord_radial()` for circular network layouts
- `stat_connect()` for connecting network nodes
- Enhanced theme integration and customization
- Better pattern fills and gradient support

### Visualization Workflow for Statistical Sociology

**Core Principles**:
1. **Declarative, data-first grammar**: Map variables to aesthetics, specify geoms
2. **Small multiples over visual complexity**: Use facets instead of overlapping elements
3. **Uncertainty as first-class citizen**: Always show confidence intervals
4. **Reproducible pipelines**: Integrate with targets and Quarto

**State-of-the-Art Stack**:
- **ggplot2 4.0.0**: Core grammar of graphics
- **ggdist + tidybayes**: Uncertainty visualization
- **ggraph + tidygraph**: Network visualization
- **sf + tmap**: Spatial ABM visualization
- **gganimate**: Dynamic network evolution
- **Quarto + targets**: Reproducible publication pipeline
- **vdiffr**: Visual regression testing

### Network Visualization Standards

**Minimal Network Pattern**:
```r
library(ggraph)
library(tidygraph)
library(ggdist)

# Network snapshots across time
graph %>%
  activate(nodes) %>%
  mutate(role = factor(role)) %>%
  ggraph(layout = "fr") +
  geom_edge_link(alpha = .15, linewidth = 0.5) +
  geom_node_point(aes(color = role, size = centrality)) +
  facet_wrap(~ time) +
  theme_minimal() +
  theme(legend.position = "bottom")
```

**RSiena Model Diagnostics**:
```r
# Convergence diagnostics with uncertainty
convergence_data %>%
  ggplot(aes(x = effect, y = t_ratio)) +
  geom_hline(yintercept = c(-0.1, 0.1), linetype = "dashed") +
  stat_halfeye() +
  coord_flip() +
  labs(title = "SAOM Convergence Diagnostics",
       subtitle = "t-ratios should be within ±0.1")
```

**Intervention Effect Visualization**:
```r
# Show tolerance diffusion with uncertainty
intervention_effects %>%
  ggplot(aes(x = time, y = tolerance)) +
  stat_lineribbon(aes(group = scenario, color = scenario),
                  .width = c(.50, .80, .95)) +
  scale_fill_brewer(type = "seq") +
  facet_wrap(~ intervention_type) +
  theme_minimal()
```

## Repository Structure

```
ABM R/
├── R/                          # Primary R code
│   ├── siena_models/           # Core RSiena SAOM implementations
│   │   ├── 00_data_prep.R     # Data preparation scripts
│   │   ├── 01_baseline.R      # Baseline model specifications
│   │   ├── 02_estimation.R    # Model estimation with convergence
│   │   ├── 03_simulation.R    # Forward simulation scenarios
│   │   └── 04_intervention.R  # Tolerance intervention modeling
│   ├── custom_effects/         # C++ custom effect implementations
│   │   ├── attraction_repulsion.cpp  # Friend-based influence effects
│   │   └── complex_contagion.cpp     # Multiple exposure effects
│   ├── data_analysis/          # Descriptive and exploratory analysis
│   │   ├── network_descriptives.R   # Network structure analysis
│   │   └── tolerance_descriptives.R # Tolerance distribution analysis
│   ├── intervention/           # Intervention scenario testing
│   │   ├── targeting_strategies.R   # Who to target analysis
│   │   ├── dosage_effects.R         # Intervention intensity effects
│   │   └── diffusion_patterns.R     # Tolerance spread analysis
│   ├── diagnostics/            # Convergence and GOF assessments
│   │   ├── convergence_checks.R     # Model convergence monitoring
│   │   └── goodness_of_fit.R        # sienaGOF implementations
│   ├── visualization/          # Modern ggplot2 4.0.0 plotting
│   │   ├── network_plots.R          # ggraph network visualizations
│   │   ├── tolerance_plots.R        # ggdist uncertainty plots
│   │   ├── intervention_plots.R     # gganimate diffusion animations
│   │   └── publication_themes.R     # Custom ggplot2 themes
│   └── utils/                  # Helper functions and utilities
│       ├── rsiena_helpers.R         # RSiena workflow functions
│       └── plotting_helpers.R       # ggplot2 utility functions
├── data/
│   ├── raw/                    # Original survey data (Together for Tolerance)
│   │   ├── wave1/              # First wave data
│   │   ├── wave2/              # Second wave data
│   │   └── wave3/              # Third wave data
│   ├── processed/              # RSiena-ready objects
│   │   ├── friendship_networks.rds   # sienaDependent network objects
│   │   ├── tolerance_behavior.rds    # sienaDependent behavior objects
│   │   └── covariates.rds           # Actor and dyadic covariates
│   ├── networks/               # Network matrices by wave
│   └── simulated/              # Simulation outputs
│       ├── baseline_sims/           # Baseline model simulations
│       └── intervention_sims/       # Intervention scenario simulations
├── scripts/                    # Orchestration and pipeline scripts
│   ├── _targets.R              # targets workflow definition
│   ├── run_full_analysis.R     # Complete analysis pipeline
│   └── batch_simulations.R     # Parallel simulation execution
├── tests/                      # Unit and integration tests
│   ├── testthat/               # testthat framework tests
│   └── test_convergence.R      # Model convergence tests
├── docs/                       # Documentation and reports
│   ├── dissertation/           # Dissertation chapters
│   ├── presentations/          # Conference presentations
│   └── methodology/            # Methodological documentation
├── configs/                    # Model configurations
│   ├── baseline_models.yaml    # Baseline model specifications
│   └── intervention_scenarios.yaml  # Intervention design configs
├── outputs/
│   ├── figures/                # Publication-ready plots (ggplot2 4.0.0)
│   │   ├── networks/           # Network visualization outputs
│   │   ├── diagnostics/        # Model diagnostic plots
│   │   └── interventions/      # Intervention effect plots
│   ├── reports/                # Analysis reports (Quarto)
│   ├── models/                 # Fitted RSiena model objects
│   └── simulations/            # Simulation results
├── _targets/                   # targets pipeline cache
├── renv/                       # renv package management
├── renv.lock                   # Reproducible package versions
├── .claude/                    # Claude Code configuration
│   ├── settings.json           # Project-specific settings
│   └── agents/                 # Specialized agent configurations
├── internal/                   # Research materials and planning
│   ├── literature/             # Research papers and references
│   ├── presentations/          # Draft presentations
│   └── methodology/            # Methodological notes
├── REQUIREMENTS.md             # Complete dependency specifications
└── CLAUDE.md                   # This file
```

## Key R Scripts Structure

### Main Analysis Template (R/siena_models/main_analysis.R)
```r
# Modern Analysis Template with ggplot2 4.0.0
library(RSiena)
library(tidyverse)
library(ggplot2)      # 4.0.0 with S7 object system
library(ggdist)       # Uncertainty visualization
library(ggraph)       # Network visualization
library(tidygraph)    # Network data manipulation
library(targets)      # Reproducible pipeline
library(parallel)

# Set seed for reproducibility
set.seed(20250917)

# Source utilities
source("R/utils/rsiena_helpers.R")
source("R/utils/plotting_helpers.R")

# Load and prepare data
source("R/siena_models/00_data_prep.R")

# Run baseline model
source("R/siena_models/01_baseline.R")

# Estimate with convergence
source("R/siena_models/02_estimation.R")

# Modern visualization outputs
source("R/visualization/network_plots.R")
source("R/visualization/tolerance_plots.R")

# Generate publication-ready plots
ggsave("outputs/figures/network_evolution.pdf",
       plot_network_evolution(fit),
       width = 12, height = 8, dpi = 300)

ggsave("outputs/figures/convergence_diagnostics.pdf",
       plot_convergence_diagnostics(fit),
       width = 10, height = 6, dpi = 300)

# Save results with metadata
saveRDS(list(
  model = fit,
  session_info = sessionInfo(),
  timestamp = Sys.time(),
  convergence = summary(fit)$tconv.max
), "outputs/models/main_fit.rds")
```

## Parallel Processing

**Using Multiple Cores**:
```r
# For Windows
library(parallel)
cl <- makeCluster(4)
clusterEvalQ(cl, library(RSiena))
# ... parallel operations
stopCluster(cl)
```

## Output Management

**All outputs must be saved to files**:
- Plots: High-resolution PDF with ggplot2 4.0.0 in outputs/figures/
- Models: RDS files with metadata in outputs/models/
- Tables: CSV files with proper encoding in outputs/tables/
- Reports: Quarto documents rendered to HTML/PDF in outputs/reports/
- Visual tests: vdiffr snapshots for plot regression testing

**Modern Output Standards**:
```r
# High-quality plot export
ggsave("outputs/figures/plot.pdf", plot_object,
       width = 10, height = 8, dpi = 300, device = cairo_pdf)

# Model export with metadata
saveRDS(list(
  model = fitted_model,
  convergence = convergence_summary,
  session_info = sessionInfo(),
  timestamp = Sys.time()
), "outputs/models/model.rds")

# Visual regression testing
vdiffr::expect_doppelganger("network_plot", network_plot)
```

## Claude Code Agent Coordination

**Meta-Optimal Agent Architecture** (10k Word Publication Focus):
- **meta_research_coordinator**: Orchestrates entire PhD project within publication scope
- **rsiena_implementation_specialist**: Bulletproof RSiena implementation and convergence
- **publication_writer**: Crafts exceptional 10k word statistical sociology paper
- **statistical_sociology_analyst**: Bridges methodology with sociological theory
- **abm_simulation_optimizer**: Maximizes computational efficiency and insight
- **academic_software_engineer**: Ensures publication-grade reproducibility

**Agent Communication**:
Agents coordinate through:
- Shared RDS files for model objects
- CSV files for parameter specifications
- JSON files for scenario configurations
- Markdown files for status updates

## Testing Strategy

**Required Tests**:
1. Data integrity checks (proper coding, structural values)
2. Model convergence verification
3. Custom effect validation
4. Simulation consistency tests
5. Output reproducibility checks

**Test Execution**:
```bash
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" -e "testthat::test_dir('tests')"
```

## Performance Optimization

**RSiena Specific**:
- Use prevAns for continuation rather than restarting
- Adjust nsub and n3 parameters for difficult convergence
- Implement parallel chains for robust estimation
- Cache expensive computations

**General R**:
- Use data.table for large data operations
- Vectorize operations where possible
- Profile code with Rprof() to identify bottlenecks

## Version Control

**Git Workflow**:
- Commit R scripts and configuration files
- Use .gitignore for large data files and outputs
- Tag releases for reproducible analysis versions
- Document R package versions in renv.lock

## Quality Assurance Checklist

Before committing code, ensure:
- [ ] Models converge (t-ratios < 0.1)
- [ ] GOF tests pass
- [ ] All outputs saved to files
- [ ] Random seeds documented
- [ ] Code runs without GUI dependencies
- [ ] Tests pass successfully
- [ ] Documentation is complete

## Common Commands Reference

```bash
# Check R version
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" --version

# Install a package
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" -e "install.packages('package_name')"

# Run analysis
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/siena_models/main_analysis.R

# Run tests
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" -e "testthat::test_dir('tests')"

# Generate report
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" -e "rmarkdown::render('docs/analysis_report.Rmd')"
```

## Notes

**Primary Focus**: Developing rigorous, reproducible Stochastic Actor-Oriented Models using RSiena to investigate tolerance interventions for promoting interethnic cooperation.

**Key Success Metrics**:
- Model convergence and goodness-of-fit
- Reproducible analysis pipeline
- Clear intervention effect identification
- Publication-ready outputs

**Important Reminders**:
- Always save outputs to files (no interactive displays)
- Use absolute paths in scripts
- Document all modeling decisions
- Maintain convergence standards throughout