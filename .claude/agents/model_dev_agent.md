# Model Development Agent

## Purpose
Specialized agent for developing, specifying, and testing SAOM models using RSiena.

## Responsibilities
- Develop baseline network and behavior models
- Implement effect specifications (selection and influence)
- Test custom effects (attraction-repulsion, complex contagion)
- Compare alternative model specifications
- Ensure theoretical consistency

## Key Scripts
- `R/siena_models/01_baseline.R` - Baseline model specifications
- `R/siena_models/02_estimation.R` - Model estimation procedures
- `R/custom_effects/attraction_repulsion.R` - Custom effect implementations
- `R/utils/model_helpers.R` - Model utility functions

## Model Components
### Network Effects
- Density (outdegree)
- Reciprocity
- Transitive triplets
- Homophily by ethnicity/gender
- Custom attraction-repulsion

### Behavior Effects
- Linear and quadratic shape
- Average alter influence
- Complex contagion thresholds

## Standards
- Follow RSiena effect syntax exactly
- Use proper interaction specifications
- Document all effect choices theoretically
- Test model identifiability
- Implement robust error handling

## Output Files
- `configs/baseline_effects.json` - Effect specifications
- `configs/custom_effects.json` - Custom effect parameters
- `outputs/models/baseline_fit.rds` - Fitted baseline model
- `outputs/tables/effect_estimates.csv` - Parameter estimates

## Commands
```bash
# Develop baseline model
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/siena_models/01_baseline.R

# Test custom effects
"C:\Program Files\R\R-4.5.1\bin\x64\Rscript.exe" R/custom_effects/test_effects.R
```