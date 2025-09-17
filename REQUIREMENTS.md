# REQUIREMENTS.md

Comprehensive dependency specifications for tolerance intervention research using RSiena and modern visualization.

## System Requirements

**Operating System**: Windows 11
**R Version**: 4.5.1
**R Installation Path**: `C:\Program Files\R\R-4.5.1\`

## Core R Environment

### Essential Statistical Packages

```r
# RSiena Ecosystem for SAOM Analysis
install.packages(c(
  "RSiena",         # Stochastic Actor-Oriented Models (v1.4.7+)
  "RSienaTest",     # Additional RSiena diagnostics
  "network",        # Network data structures
  "sna",            # Social network analysis
  "igraph",         # Network manipulation and analysis
  "statnet.common", # Network analysis utilities
  "ergm",           # Exponential Random Graph Models (comparative)
  "tergm"           # Temporal ERGM (comparative)
), repos = "https://cloud.r-project.org")
```

### Modern Visualization Stack (ggplot2 4.0.0)

```r
# Grammar of Graphics with S7 Object System
install.packages(c(
  "ggplot2",        # Grammar of Graphics 4.0.0 with S7
  "ggdist",         # Uncertainty visualization (Bayesian-friendly)
  "ggraph",         # Network visualization with ggplot2
  "tidygraph",      # Tidy network data manipulation
  "ggtext",         # Markdown/HTML text in plots
  "gganimate",      # Animated visualizations
  "ggrepel",        # Non-overlapping text labels
  "patchwork",      # Combining multiple plots
  "cowplot"         # Publication-ready plot themes
), repos = "https://cloud.r-project.org")
```

### Advanced Visualization Extensions

```r
# Specialized ggplot2 Extensions
install.packages(c(
  "ggh4x",          # Advanced axes and faceting
  "ggforce",        # Additional geoms and transformations
  "ggnewscale",     # Multiple color/fill scales
  "ggbeeswarm",     # Bee swarm plots for distributions
  "ggridges",       # Ridge plots for distributions
  "ggalluvial",     # Alluvial diagrams for flows
  "ggcorrplot",     # Correlation matrix visualization
  "GGally"          # Matrix plots and extensions
), repos = "https://cloud.r-project.org")
```

### Spatial and Network-Specific Visualization

```r
# Spatial and Geographic Data
install.packages(c(
  "sf",             # Simple Features for spatial data
  "tmap",           # Thematic mapping
  "leaflet",        # Interactive maps
  "mapview",        # Quick interactive maps
  "ggmap"           # Maps in ggplot2
), repos = "https://cloud.r-project.org")

# Network Layout and Analysis
install.packages(c(
  "graphlayouts",   # Network layout algorithms
  "netrankr",       # Network ranking and centrality
  "influenceR",     # Network influence measures
  "NetSwan"         # Network structural analysis (if available)
), repos = "https://cloud.r-project.org")
```

### Data Manipulation and Pipeline

```r
# Tidyverse Ecosystem
install.packages(c(
  "tidyverse",      # Complete tidyverse meta-package
  "dplyr",          # Data manipulation
  "tidyr",          # Data reshaping
  "purrr",          # Functional programming
  "readr",          # Data reading
  "stringr",        # String manipulation
  "forcats",        # Factor handling
  "lubridate"       # Date/time manipulation
), repos = "https://cloud.r-project.org")

# Performance and Large Data
install.packages(c(
  "data.table",     # High-performance data manipulation
  "dtplyr",         # dplyr backend using data.table
  "vroom",          # Fast data reading
  "arrow",          # Columnar data format
  "fst"             # Fast serialization
), repos = "https://cloud.r-project.org")
```

### Reproducible Research Infrastructure

```r
# Pipeline and Workflow Management
install.packages(c(
  "targets",        # Pipeline orchestration
  "tarchetypes",    # Specialized target types
  "clustermq",      # High-performance computing
  "future",         # Parallel and distributed computing
  "furrr",          # Parallel map functions
  "parallelly"      # Parallel processing utilities
), repos = "https://cloud.r-project.org")

# Documentation and Reporting
install.packages(c(
  "quarto",         # Next-generation R Markdown
  "rmarkdown",      # Dynamic documents
  "knitr",          # Literate programming
  "bookdown",       # Long-form documents
  "distill",        # Scientific web publishing
  "blogdown"        # Website generation
), repos = "https://cloud.r-project.org")
```

### Testing and Quality Assurance

```r
# Testing Framework
install.packages(c(
  "testthat",       # Unit testing framework
  "vdiffr",         # Visual regression testing for plots
  "mockr",          # Mocking for tests
  "withr",          # Temporary state changes
  "covr"            # Code coverage analysis
), repos = "https://cloud.r-project.org")

# Code Quality
install.packages(c(
  "lintr",          # Static code analysis
  "styler",         # Code formatting
  "usethis",        # Package development utilities
  "devtools",       # Development tools
  "roxygen2"        # Documentation generation
), repos = "https://cloud.r-project.org")
```

### Specialized Statistical Methods

```r
# Bayesian and Advanced Statistics
install.packages(c(
  "brms",           # Bayesian regression models
  "rstanarm",       # Bayesian applied regression
  "tidybayes",      # Tidy Bayesian analysis
  "posterior",      # Posterior distribution tools
  "bayesplot",      # Bayesian visualization
  "loo"             # Leave-one-out cross-validation
), repos = "https://cloud.r-project.org")

# Multilevel and Mixed Effects
install.packages(c(
  "lme4",           # Linear mixed-effects models
  "nlme",           # Nonlinear mixed-effects models
  "glmmTMB",        # Generalized mixed models
  "merTools",       # Tools for mixed models
  "sjPlot"          # Visualization for mixed models
), repos = "https://cloud.r-project.org")
```

### Simulation and Computational Methods

```r
# Agent-Based Modeling Support
install.packages(c(
  "abmR",           # Agent-based modeling in R
  "NetLogoR",       # NetLogo-style ABM
  "nlrx",           # Interface to NetLogo
  "RNetLogo"        # R-NetLogo interface (if needed)
), repos = "https://cloud.r-project.org")

# Simulation Utilities
install.packages(c(
  "simmer",         # Discrete event simulation
  "SimDesign",      # Simulation study framework
  "MASS",           # Statistical functions
  "mvtnorm",        # Multivariate normal distribution
  "extraDistr"      # Additional probability distributions
), repos = "https://cloud.r-project.org")
```

### Database and External Data Integration

```r
# Database Connectivity
install.packages(c(
  "DBI",            # Database interface
  "RSQLite",        # SQLite database
  "RPostgreSQL",    # PostgreSQL interface
  "odbc",           # ODBC database connectivity
  "bigrquery"       # Google BigQuery interface
), repos = "https://cloud.r-project.org")

# Web APIs and Scraping
install.packages(c(
  "httr2",          # HTTP client
  "jsonlite",       # JSON parsing
  "xml2",           # XML parsing
  "rvest",          # Web scraping
  "curl"            # HTTP requests
), repos = "https://cloud.r-project.org")
```

## Environment Management

### Package Version Control

```r
# Reproducible environments
install.packages(c(
  "renv",           # Project-local package management
  "checkpoint",     # CRAN snapshots
  "packrat",        # Package management (legacy)
  "miniCRAN"        # CRAN mirror creation
), repos = "https://cloud.r-project.org")
```

### Version Tracking

```r
# Git integration
install.packages(c(
  "gert",           # Git interface
  "usethis",        # Git workflow automation
  "gh",             # GitHub API interface
  "gitcreds"        # Git credential management
), repos = "https://cloud.r-project.org")
```

## Installation Script

Complete installation command for all dependencies:

```bash
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" -e "
install.packages(c(
  # RSiena Ecosystem
  'RSiena', 'RSienaTest', 'network', 'sna', 'igraph', 'statnet.common',
  # Modern Visualization
  'ggplot2', 'ggdist', 'ggraph', 'tidygraph', 'ggtext', 'gganimate',
  'ggrepel', 'patchwork', 'cowplot', 'ggh4x', 'ggforce', 'ggnewscale',
  # Spatial and Network
  'sf', 'tmap', 'leaflet', 'mapview', 'graphlayouts', 'netrankr',
  # Data and Pipeline
  'tidyverse', 'data.table', 'targets', 'quarto', 'parallel',
  # Testing and Quality
  'testthat', 'vdiffr', 'lintr', 'styler',
  # Statistics
  'brms', 'tidybayes', 'lme4', 'mvtnorm',
  # Environment
  'renv', 'gert', 'usethis'
), repos = 'https://cloud.r-project.org', dependencies = TRUE)
"
```

## System Configuration

### R Profile Setup

Create `.Rprofile` in project root:

```r
# .Rprofile for ABM Tolerance Research
options(
  repos = c(CRAN = "https://cloud.r-project.org"),
  renv.config.auto.snapshot = FALSE,
  mc.cores = parallel::detectCores() - 1,
  scipen = 999,
  stringsAsFactors = FALSE
)

# Load frequently used packages silently
suppressPackageStartupMessages({
  require(tidyverse)
  require(ggplot2)
  require(targets)
})

# Custom theme for all plots
theme_set(theme_minimal() +
  theme(
    text = element_text(size = 12),
    plot.title = element_text(size = 14, face = "bold"),
    legend.position = "bottom"
  ))

# Tolerance research specific options
options(
  tolerance.seed = 20250917,
  tolerance.iterations = 1000,
  tolerance.convergence.threshold = 0.1
)

cat("Tolerance Intervention Research Environment Loaded\n")
cat("ggplot2 version:", as.character(packageVersion("ggplot2")), "\n")
cat("RSiena version:", as.character(packageVersion("RSiena")), "\n")
```

### Git Configuration

```bash
# Configure git for reproducible research
git config --global user.name "Your Name"
git config --global user.email "your.email@university.edu"
git config --global init.defaultBranch main
git config --global pull.rebase false
```

## Project Initialization

### Initialize renv

```r
# Initialize package management
renv::init()
renv::snapshot()
```

### Initialize targets pipeline

```r
# Set up reproducible pipeline
targets::use_targets()
```

## Development Tools

### Recommended RStudio Configuration

- **Code completion**: Enabled for all objects
- **Diagnostics**: Show R diagnostics in editor
- **Style**: Use tidyverse style guide
- **Terminal**: Use Git Bash or PowerShell
- **Build tools**: Enable for package development

### Visual Studio Code Integration

Required extensions:
- R Extension for Visual Studio Code
- R LSP Client
- GitLens
- Quarto
- Live Share (for collaboration)

## Hardware Recommendations

**Minimum Requirements**:
- RAM: 8GB (16GB recommended for large networks)
- CPU: 4 cores (8+ cores recommended for parallel processing)
- Storage: 50GB free space for data and outputs
- Network: Stable internet for package downloads

**Optimal Configuration**:
- RAM: 32GB+ for large-scale simulations
- CPU: 16+ cores for parallel RSiena estimation
- Storage: SSD with 100GB+ free space
- GPU: Not required but beneficial for some visualizations

## Quality Assurance Checklist

Before starting analysis:
- [ ] All packages installed and loading without errors
- [ ] renv.lock file created and committed
- [ ] .Rprofile configured for project
- [ ] targets pipeline initialized
- [ ] Git repository initialized
- [ ] Test scripts run successfully
- [ ] Convergence thresholds configured
- [ ] Output directories created
- [ ] vdiffr baseline plots established

## Troubleshooting

### Common Installation Issues

**ggplot2 4.0.0 installation fails**:
```r
# Force install from CRAN
install.packages("ggplot2", repos = "https://cloud.r-project.org", type = "binary")
```

**RSiena compilation errors**:
```r
# Install Rtools for Windows if needed
# Download from: https://cran.r-project.org/bin/windows/Rtools/
```

**Memory issues with large networks**:
```r
# Increase memory limit
memory.limit(size = 8000)  # 8GB
```

### Performance Optimization

```r
# Configure parallel processing
options(mc.cores = parallel::detectCores() - 1)
library(future)
plan(multisession, workers = availableCores() - 1)
```

## Update Schedule

- **Weekly**: Check for RSiena updates
- **Monthly**: Update visualization packages
- **Quarterly**: Full dependency audit
- **Semester**: Major version updates with testing

---

**Last Updated**: September 17, 2025
**ggplot2 Version**: 4.0.0
**RSiena Version**: 1.4.7+
**R Version**: 4.5.1

For issues or updates, consult the internal documentation or Utrecht University computational resources.