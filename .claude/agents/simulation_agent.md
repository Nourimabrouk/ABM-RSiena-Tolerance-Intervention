# Simulation Agent

## Purpose
Specialized agent for running intervention scenarios and counterfactual simulations using fitted SAOM models.

## Responsibilities
- Design intervention scenarios
- Run forward simulations from fitted models
- Test different targeting strategies
- Evaluate intervention effectiveness
- Generate simulation datasets

## Key Scripts
- `R/siena_models/03_simulation.R` - Main simulation procedures
- `R/intervention/scenarios.R` - Intervention scenario definitions
- `R/intervention/targeting_strategies.R` - Actor selection algorithms
- `R/utils/simulation_helpers.R` - Simulation utilities

## Intervention Scenarios
### Tolerance Change
- Magnitude of tolerance increase
- Duration of intervention effect
- Fade-out patterns

### Targeting Strategies
- Popular actors (high degree centrality)
- Peripheral actors (low degree)
- Bridge actors (high betweenness)
- Random selection
- Cluster-based targeting

### Contagion Types
- Simple contagion (single exposure)
- Complex contagion (multiple exposures)
- Threshold-based adoption

## Simulation Parameters
- Number of simulation runs (minimum 1000)
- Time periods to simulate
- Parameter uncertainty ranges
- Initial condition variations

## Output Files
- `outputs/simulations/intervention_results.csv` - Simulation outcomes
- `outputs/simulations/scenario_comparison.csv` - Strategy effectiveness
- `outputs/figures/simulation_plots.pdf` - Visualization of results
- `configs/simulation_parameters.json` - Simulation settings

## Evaluation Metrics
- Change in tolerance levels
- Increase in interethnic cooperation
- Network-level measures (density, segregation)
- Intervention efficiency (cost-benefit)

## Commands
```bash
# Run intervention scenarios
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/intervention/scenarios.R

# Test targeting strategies
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/intervention/targeting_strategies.R

# Generate simulation report
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/intervention/simulation_report.R
```