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
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" -e "install.packages(c('RSiena', 'RSienaTest', 'network', 'sna', 'igraph', 'tidyverse', 'data.table', 'ggplot2', 'ggraph', 'parallel', 'foreach', 'doParallel'), repos='https://cloud.r-project.org')"
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

## Repository Structure

```
ABM R/
├── R/                          # Primary R code
│   ├── siena_models/           # Core RSiena SAOM implementations
│   │   ├── 00_data_prep.R     # Data preparation scripts
│   │   ├── 01_baseline.R      # Baseline model specifications
│   │   ├── 02_estimation.R    # Model estimation with convergence
│   │   └── 03_simulation.R    # Forward simulation scenarios
│   ├── custom_effects/         # C++ custom effect implementations
│   ├── data_analysis/          # Descriptive and exploratory analysis
│   ├── intervention/           # Intervention scenario testing
│   ├── diagnostics/            # Convergence and GOF assessments
│   ├── visualization/          # Network and results plotting
│   └── utils/                  # Helper functions and utilities
├── data/
│   ├── raw/                    # Original survey data
│   ├── processed/              # RSiena-ready objects
│   ├── networks/               # Network matrices by wave
│   └── simulated/              # Simulation outputs
├── scripts/                    # Orchestration and pipeline scripts
├── tests/                      # Unit and integration tests
├── docs/                       # Documentation and reports
├── configs/                    # Model configurations
├── outputs/
│   ├── figures/                # Publication-ready plots
│   ├── reports/                # Analysis reports
│   └── simulations/            # Simulation results
├── .claude/                    # Claude Code configuration
│   ├── settings.json           # Project-specific settings
│   └── agents/                 # Specialized agent configurations
├── internal/                   # Research materials and planning
└── CLAUDE.md                   # This file
```

## Key R Scripts Structure

### Main Analysis Template (R/siena_models/main_analysis.R)
```r
# Load libraries
library(RSiena)
library(tidyverse)
library(parallel)

# Set seed for reproducibility
set.seed(20250917)

# Source utilities
source("R/utils/helpers.R")

# Load and prepare data
source("R/siena_models/00_data_prep.R")

# Run baseline model
source("R/siena_models/01_baseline.R")

# Estimate with convergence
source("R/siena_models/02_estimation.R")

# Generate outputs
pdf("outputs/figures/convergence.pdf")
# ... plotting code
dev.off()

# Save results
saveRDS(fit, "outputs/models/main_fit.rds")
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
- Plots: PDF or PNG in outputs/figures/
- Models: RDS files in outputs/models/
- Tables: CSV files in outputs/tables/
- Reports: R Markdown rendered to HTML/PDF in outputs/reports/

## Claude Code Agent Coordination

**Agent Specialization**:
- **data_prep_agent**: Handles data cleaning and RSiena object creation
- **model_dev_agent**: Develops and tests model specifications
- **convergence_agent**: Monitors and ensures model convergence
- **simulation_agent**: Runs intervention scenarios
- **viz_agent**: Creates publication-ready visualizations

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