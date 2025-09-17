# Data Preparation Agent

## Purpose
Specialized agent for handling data cleaning, transformation, and RSiena object creation for SAOM analysis.

## Responsibilities
- Load and clean raw survey data
- Handle missing data and composition changes
- Create RSiena network and behavior objects
- Implement structural coding (10/11 for structural zeros/ones)
- Generate data quality reports
- Ensure Jaccard stability requirements

## Key Scripts
- `R/siena_models/00_data_prep.R` - Main data preparation pipeline
- `R/utils/data_helpers.R` - Data utility functions
- `scripts/check_data_quality.R` - Data validation scripts

## Standards
- Document all data transformations
- Use structural codes correctly (10=structural zero, 11=structural one)
- Check Jaccard stability (>0.30 ideal)
- Handle missing data appropriately (NA for missing, not structural)
- Save processed data as RDS objects

## Output Files
- `data/processed/siena_objects.rds` - Complete RSiena data objects
- `data/processed/network_arrays.rds` - Network adjacency arrays
- `data/processed/behavior_matrices.rds` - Behavior data matrices
- `outputs/reports/data_quality_report.html` - Data diagnostics

## Commands
```bash
# Run data preparation
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/siena_models/00_data_prep.R

# Generate data quality report
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" scripts/check_data_quality.R
```