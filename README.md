# Tolerance Intervention Research: Agent-Based Models for Interethnic Cooperation

[![R](https://img.shields.io/badge/R-4.5.1-blue.svg)](https://www.r-project.org/)
[![RSiena](https://img.shields.io/badge/RSiena-1.4.7+-green.svg)](https://www.stats.ox.ac.uk/~snijders/siena/)
[![ggplot2](https://img.shields.io/badge/ggplot2-4.0.0-purple.svg)](https://ggplot2.tidyverse.org/)
[![targets](https://img.shields.io/badge/targets-pipeline-orange.svg)](https://books.ropensci.org/targets/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**PhD Dissertation Project | Utrecht University | Statistical Sociology**

> *How can individual-level changes in tolerance from interventions spread and persist in social networks to increase sustained interethnic cooperation?*

## Overview

This repository contains the complete research infrastructure for a PhD dissertation investigating **how tolerance interventions spread through social networks to promote sustained interethnic cooperation**. The research employs **Stochastic Actor-Oriented Models (SAOM)** using RSiena to model the co-evolution of friendship networks and tolerance behaviors in educational settings.

## Research Question

**How can individual-level changes in tolerance from interventions spread and persist in social networks to increase sustained interethnic cooperation?**

### Key Components

1. **Tolerance as Target**: Moving beyond prejudice reduction to promote value-based acceptance despite principled disapproval
2. **Social Network Dynamics**: Using SAOM to model how tolerance spreads through friendship networks via attraction-repulsion mechanisms
3. **Intervention Design**: Testing different targeting strategies (popular vs. peripheral actors, centrality measures, complex vs. simple contagion)
4. **Empirical Calibration**: Using real-world intervention data from German high schools

## Methodology

- **Method**: Stochastic Actor-Oriented Models (SAOM)
- **Software**: RSiena with R 4.5.1
- **Data**: 5825 observations, 2585 respondents, 105 classes, 3 schools, 3 time waves
- **Custom Effects**: Attraction-repulsion social influence, complex contagion thresholds
- **Development Environment**: Claude Code integration for advanced R development

## Repository Structure

```
ABM R/
├── R/                          # Primary R analysis code
│   ├── siena_models/           # Core RSiena SAOM implementations
│   │   ├── 00_data_prep.R     # Data preparation and validation
│   │   ├── 01_baseline.R      # Baseline model specification
│   │   ├── 02_estimation.R    # Model estimation with convergence
│   │   └── 03_simulation.R    # Intervention scenario simulation
│   ├── custom_effects/         # C++ custom effect implementations
│   ├── data_analysis/          # Descriptive statistics and exploration
│   ├── intervention/           # Intervention scenario testing
│   ├── diagnostics/            # Model convergence and GOF assessment
│   ├── visualization/          # Network and results plotting
│   └── utils/                  # Helper functions and utilities
├── data/
│   ├── raw/                    # Original survey data
│   ├── processed/              # RSiena-ready objects
│   ├── networks/               # Network matrices by wave
│   └── simulated/              # Simulation outputs
├── outputs/
│   ├── figures/                # Publication-ready plots
│   ├── models/                 # Fitted model objects
│   ├── reports/                # Analysis reports
│   └── simulations/            # Intervention simulation results
├── .claude/                    # Claude Code configuration
│   ├── settings.json           # Project settings
│   └── agents/                 # Specialized agent configurations
├── configs/                    # Model specifications
├── docs/                       # Documentation
├── tests/                      # Unit and integration tests
└── internal/                   # Research planning materials
```

## Quick Start

### Prerequisites

- R 4.3.0+ (recommended 4.5.1)
- RSiena package
- Git for version control
- Claude Code (optional, for enhanced development)

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd "ABM R"
   ```

2. **Run setup script:**
   ```bash
   "C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" setup.R
   ```

3. **Verify installation:**
   ```bash
   "C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" -e "library(RSiena); packageVersion('RSiena')"
   ```

### Basic Workflow

1. **Data Preparation:**
   ```bash
   "C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/siena_models/00_data_prep.R
   ```

2. **Model Specification:**
   ```bash
   "C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/siena_models/01_baseline.R
   ```

3. **Model Estimation:**
   ```bash
   "C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/siena_models/02_estimation.R
   ```

4. **Convergence Assessment:**
   ```bash
   "C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/diagnostics/convergence_check.R
   ```

## Key Features

### SAOM Model Components

- **Network Effects**: Density, reciprocity, transitivity, homophily
- **Custom Effects**: Attraction-repulsion influence mechanism
- **Behavior Dynamics**: Tolerance shape and peer influence
- **Selection Mechanisms**: Friendship formation based on tolerance similarity
- **Cross-Network Effects**: Friendship → cooperation pathways

### Quality Assurance

- **Convergence Standards**: t-ratios < 0.1, max convergence ratio < 0.25
- **Data Validation**: Jaccard stability > 0.30, structural coding verification
- **Goodness-of-Fit**: Comprehensive testing with degree, geodesic, and triad distributions
- **Reproducibility**: Documented random seeds and version control

### Claude Code Integration

This project is optimized for development with **Claude Code**, featuring:

- Specialized agent configurations for different analysis components
- Automated workflow orchestration
- Terminal-based R execution (no GUI dependencies)
- Parallel processing coordination
- Quality assurance automation

## Research Applications

### Intervention Scenarios

The framework supports testing various intervention designs:

- **Targeting Strategies**: Popular actors vs. peripherals vs. bridge actors
- **Contagion Types**: Simple vs. complex contagion mechanisms
- **Intervention Intensity**: Magnitude and duration of tolerance changes
- **Network Position**: Centrality-based targeting algorithms

### Policy Implications

Results inform evidence-based recommendations for:

- Educational intervention design
- Peer influence program optimization
- Network-based norm change strategies
- Interethnic cooperation promotion

## Documentation

- **[CLAUDE.md](CLAUDE.md)**: Complete Claude Code development guidelines
- **[.claude/](.claude/)**: Agent configurations and project settings
- **[internal/](internal/)**: Research planning and theoretical background
- **R Script Documentation**: Comprehensive roxygen2 documentation throughout

## Requirements

### Core R Packages

```r
# Install required packages
install.packages(c(
  "RSiena",        # SAOM estimation
  "RSienaTest",    # Model diagnostics
  "network",       # Network data structures
  "sna",           # Social network analysis
  "igraph",        # Network visualization
  "tidyverse",     # Data manipulation
  "ggraph",        # Network plotting
  "parallel"       # Parallel processing
))
```

### System Requirements

- **RAM**: 8GB+ recommended for large networks
- **CPU**: Multi-core recommended for parallel estimation
- **Storage**: 2GB+ for data and simulation outputs
- **OS**: Windows, macOS, or Linux

## Development Standards

### Code Quality

- **Testing**: Unit tests with testthat framework
- **Documentation**: Roxygen2 for all functions
- **Style**: Tidyverse style guide compliance
- **Version Control**: Git with meaningful commit messages

### SAOM Standards

- **Convergence**: Strict adherence to RSiena convergence criteria
- **Effects**: Theoretically motivated effect specifications
- **Validation**: Comprehensive goodness-of-fit assessment
- **Reproducibility**: Documented seeds and algorithm parameters

## Contributing

This is a PhD research project. For questions or collaboration inquiries, please see the contact information in the documentation.

## Citation

If you use this code or methodology in your research, please cite:

```
[PhD Dissertation Citation - To be completed upon completion]
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Utrecht University** - Department of Statistical Sociology
- **RSiena Development Team** - Tom Snijders and colleagues
- **Together for Tolerance** - Original intervention study team
- **Claude Code** - AI-assisted development platform

---

*This research contributes to the growing field of computational social science by providing novel methodological approaches for understanding how tolerance interventions can create sustained improvements in interethnic cooperation within educational settings.*