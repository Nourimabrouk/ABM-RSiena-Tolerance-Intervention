# Convergence Agent

## Purpose
Specialized agent for monitoring and ensuring RSiena model convergence and goodness-of-fit.

## Responsibilities
- Monitor convergence during estimation
- Implement continuation strategies (prevAns)
- Assess goodness-of-fit with sienaGOF
- Test time heterogeneity with sienaTimeTest
- Optimize algorithm parameters

## Key Scripts
- `R/diagnostics/convergence_check.R` - Convergence monitoring
- `R/diagnostics/gof_assessment.R` - Goodness-of-fit testing
- `R/diagnostics/time_heterogeneity.R` - Time test procedures
- `R/utils/convergence_helpers.R` - Convergence utilities

## Convergence Standards
- All t-ratios < 0.1 (absolute value)
- Overall maximum convergence ratio < 0.25
- Minimum 2000 iterations in Phase 3
- Stable parameter estimates across runs

## GOF Requirements
- Indegree distribution
- Outdegree distribution
- Geodesic distance distribution
- Triad census
- Behavior distribution (if applicable)

## Algorithm Tuning
- Adjust nsub, n3 parameters
- Modify Robbins-Monro gain (firstg)
- Use double averaging if needed
- Implement parallel chains

## Output Files
- `outputs/diagnostics/convergence_report.html` - Convergence summary
- `outputs/diagnostics/gof_plots.pdf` - Goodness-of-fit plots
- `outputs/diagnostics/time_test_results.csv` - Time heterogeneity tests
- `outputs/models/converged_fit.rds` - Final converged model

## Commands
```bash
# Check convergence
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/diagnostics/convergence_check.R

# Run GOF assessment
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/diagnostics/gof_assessment.R

# Test time heterogeneity
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/diagnostics/time_heterogeneity.R
```