# JASSS Paper Style and Constraints Guide
## Based on: "An Empirical and Simulation Investigation of Bounded Confidence and Negative Influence in Opinion Dynamics using Stochastic Actor-Oriented Modelling" (Tang et al., 2025)

---

## 1. JOURNAL METADATA & FORMATTING

### Publication Details
- **Journal**: Journal of Artificial Societies and Social Simulation (JASSS)
- **Volume/Issue Format**: 28(1) 2, 2025
- **DOI Format**: 10.18564/jasss.XXXX
- **URL Structure**: http://jasss.soc.surrey.ac.uk/28/1/2.html
- **Dates Required**: Received, Accepted, Published

### Author Information Structure
- Full names with superscript affiliations
- Complete institutional addresses including postal codes
- Corresponding author email clearly indicated
- Format: `Correspondence should be addressed to [email]`

---

## 2. ABSTRACT REQUIREMENTS

### Structure (150-250 words)
1. **Opening**: State the two main mechanisms being investigated
2. **Problem Statement**: Identify limitations in existing empirical studies
3. **Methods**: Brief description of approach (SAOM + data source)
4. **Key Innovation**: Two new SAOM effects introduced
5. **Results**: Main empirical findings
6. **Implications**: Macro-level conclusions despite micro-level findings
7. **Bridge Statement**: How study connects SAOM and ABM

### Required Elements
- Keywords (6-8 terms, alphabetically ordered)
- Must include: methodology terms, theoretical concepts, empirical approach

---

## 3. INTRODUCTION STRUCTURE

### Opening Hook (Para 1.1)
- Metaphorical opening comparing field to economics
- Establish polarization as central threat
- Frame the paradox: assimilation should lead to consensus, not polarization
- End with foundational question (e.g., Axelrod's quote)

### Mechanism Introduction (Para 1.2)
- Define bounded confidence precisely
- Define negative influence precisely
- Explain activation conditions for each
- Note combination approaches in literature

### Empirical Challenge (Para 1.3-1.4)
- Mixed evidence discussion
- Two key limitations of existing studies
- External validity concerns
- Disentanglement challenges

### Study Overview (Para 1.5-1.7)
- Data source and context
- Methodological innovation (new SAOM effects)
- Results preview
- Section roadmap

---

## 4. BACKGROUND SECTION

### Required Subsections
1. **Bounded Confidence**
   - Mathematical formalization (Equations required)
   - Implementation variants (Deffuant vs. Hegselmann-Krause)
   - Theoretical foundations
   - Macro behaviors

2. **Negative Influence**
   - Alternative terminology listing
   - Mathematical formalization
   - Combination with bounded confidence
   - Polarization potential

3. **Empirical Studies**
   - Laboratory experiments
   - Field studies
   - Limitations summary

---

## 5. METHODS SECTION

### Core Components
1. **SAOM as Agent-Based Model**
   - Technical description
   - Ministep framework
   - Objective functions
   - Parameter interpretation

2. **Data Description**
   - Source details
   - Sample size and structure
   - Variable definitions
   - Descriptive statistics

3. **Model Specification**
   - Network effects (list with mathematical expressions)
   - Behavior/Opinion effects
   - New effects introduction with full mathematical derivation
   - Numerical examples (use tables)

4. **Estimation Approach**
   - Software (RSiena/multiSiena)
   - Bayesian framework
   - Convergence criteria
   - Prior specifications

---

## 6. MATHEMATICAL REQUIREMENTS

### Equation Standards
- Number all key equations sequentially
- Use consistent notation throughout
- Define all symbols upon first use
- Provide intuitive explanations after technical formulas

### Required Mathematical Elements
1. Objective function formulation
2. Effect specifications
3. Probability calculations
4. Convergence metrics

### Example Table Requirements
- Demonstration tables for new effects
- Show step-by-step calculations
- Include both positive and negative cases

---

## 7. RESULTS PRESENTATION

### Main Results Table
**Required Columns**:
- Effect name
- Feature (Group-varying/Group-constant)
- p.m. (posterior mean)
- p.s.d. (posterior standard deviation)
- b.s.d. (between-groups standard deviation)
- p (posterior probability > 0)

### Interpretation Guidelines
- Focus on p values near 0 or 1 for significance
- Explain parameter signs and magnitudes
- Provide concrete examples of effect meanings

### Visualization Requirements
1. **Posterior Distributions Figure**
   - Density plots for key parameters
   - Median lines (bold)
   - 80% intervals (shaded)

2. **Posterior Predictive Checks**
   - Multiple polarization measures
   - Observed vs. simulated comparisons
   - Scatter plots with clear legends

---

## 8. DISCUSSION STRUCTURE

### Opening (5.1)
- Restate main findings succinctly
- Connect to broader theoretical debates

### Contributions (5.2)
- Methodological advances
- Empirical insights
- Theoretical implications

### Limitations (5.3)
- Scope boundaries
- Generalizability concerns
- Future research directions

### Broader Implications (5.4-5.5)
- Policy relevance
- Methodological lessons
- Field advancement

---

## 9. TECHNICAL WRITING STYLE

### Paragraph Numbering
- Main sections numbered (1, 2, 3...)
- Subsections use descriptive headers
- Paragraphs numbered X.Y format throughout

### Citation Style
- Author-year format: (Surname Year)
- Multiple authors: (Author1 et al. Year)
- Multiple citations: (Citation1; Citation2; Citation3)

### Technical Terms
- Define on first use
- Maintain consistency
- Use established terminology where possible

### Footnotes
- Superscript numbers
- Substantive content only
- Technical clarifications preferred

---

## 10. SPECIFIC CONSTRAINTS

### Word Limits
- Abstract: 150-250 words
- Total: No explicit limit, but aim for 8,000-10,000 words

### Figure/Table Limits
- Tables: 4-5 maximum
- Figures: 3-4 maximum
- Each must be referenced in text

### Equation Balance
- Core model equations: 5-10
- Supporting formulas: As needed
- Always provide intuitive explanations

---

## 11. SUPPLEMENTARY MATERIALS

### Appendix Requirements
- Prior specifications
- Convergence diagnostics
- Robustness checks
- Additional technical details

### Code/Data Availability
- State availability clearly
- Provide repository links if applicable
- Include replication materials

---

## 12. QUALITY CHECKLIST

### Before Submission
- [ ] All effects mathematically specified
- [ ] Convergence criteria met and reported
- [ ] Multiple polarization measures used
- [ ] Posterior predictive checks completed
- [ ] Alternative model specifications tested
- [ ] Limitations explicitly discussed
- [ ] Policy implications addressed
- [ ] Future research directions identified

### Statistical Rigor
- [ ] Bayesian estimation properly implemented
- [ ] Prior sensitivity discussed
- [ ] Model fit assessed multiple ways
- [ ] Parameter uncertainty quantified
- [ ] Group-level variation examined

---

## 13. UNIQUE PAPER FEATURES TO EMULATE

### Theoretical Innovation
- Introduce new methodological tools (e.g., new SAOM effects)
- Bridge different modeling traditions (SAOM + ABM)
- Test competing theories simultaneously

### Empirical Sophistication
- Use longitudinal field data
- Control for network dynamics
- Separate selection from influence

### Presentation Excellence
- Numerical examples with tables
- Multiple model comparisons
- Clear mechanism explanations
- Policy-relevant conclusions

---

## 14. COMMON PITFALLS TO AVOID

### Methodological
- Don't ignore convergence issues
- Don't rely on single polarization measure
- Don't neglect alternative explanations
- Don't oversimplify network dynamics

### Writing
- Avoid excessive technical jargon without explanation
- Don't bury key findings in technical details
- Maintain clear narrative thread
- Balance technical rigor with accessibility

---

## 15. JASSS-SPECIFIC REQUIREMENTS

### Open Science
- Emphasize reproducibility
- Provide implementation details
- Share model code when possible

### Interdisciplinary Appeal
- Connect to multiple fields
- Explain technical concepts clearly
- Highlight practical applications

### Simulation Focus
- Document model assumptions
- Validate against empirical data
- Explore parameter spaces
- Discuss emergence properties

---

## IMPLEMENTATION NOTES FOR YOUR PAPER

Given your tolerance intervention research, adapt this template by:

1. **Opening**: Frame around tolerance interventions instead of polarization
2. **Mechanisms**: Focus on tolerance diffusion vs. resistance
3. **Data**: Emphasize intervention experiment structure
4. **New Effects**: Develop attraction-repulsion effects for tolerance
5. **Results**: Highlight intervention effectiveness patterns
6. **Discussion**: Policy implications for intervention design

Remember: JASSS values methodological innovation, empirical grounding, and clear connections between micro-mechanisms and macro-outcomes.