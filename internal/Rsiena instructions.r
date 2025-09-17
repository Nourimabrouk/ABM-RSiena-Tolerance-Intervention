RSiena “rules of practice” for AI research agents (tailored to your dissertation)

Below is a practical, pre-implementation checklist distilled from the RSiena manual (Tom Snijders et al.). I’ve focused on steps and standards that matter most for your topic (school friendship networks; tolerance interventions) and your workflow (re-using Together for Tolerance or simulating data; no new field collection). Inline citations point you to the exact passages.

0) Canonical workflow (do this, in order)

Build RSiena objects → create effects → create algorithm → print01Report → refine effects → siena07 estimation → diagnose convergence → sienaTimeTest (if ≥3 waves) → sienaGOF → (if needed) simulation studies. The manual lays out these steps and the starter scripts (basicRSiena.r; Rscript01/02/03/04). 

RSiena_Manual

 

RSiena_Manual

1) Data hygiene & stability checks (before modeling)

Run print01Report immediately after building your sienaDataCreate(...). Use it to verify degrees and the Change in networks section (Hamming distance; Jaccard). 

RSiena_Manual

 

RSiena_Manual

Interpret Jaccard stability: for typical sparse school networks (average degree ≈ 2–15, roughly stable over waves), Jaccard ≥ .30 is good; < .20 can cause estimation difficulties; < .10 is “quite low indeed”—consider whether SAOM is appropriate (unless low values reflect mostly monotone tie creation/termination or extreme sparsity). 

RSiena_Manual

 

RSiena_Manual

R snippet (minimal precheck):

print01Report(mydata, modelname = "precheck")  # inspect Jaccard & degrees


(Report/meaning explained in manual.) 

RSiena_Manual

2) Build a defensible baseline model (start simple)

Use getEffects(mydata) to start with outdegree (density) and reciprocity for networks; then add theory-driven effects stepwise. 

RSiena_Manual

Specify effects with includeEffects, setEffect, and includeInteraction. These are the sanctioned ways to configure SAOM terms. 

RSiena_Manual

R skeleton:

eff <- getEffects(mydata)
eff <- includeEffects(eff, recip)           # baseline
# add triadic closure, assortativity, covariates, etc., one at a time


(Functions and sequence as per manual.) 

RSiena_Manual

3) Behavior–network coevolution (selection & influence)

When modeling behavior (e.g., tolerance) with networks, follow the manual’s behavior interaction rules: only effects with interactionType “OK” (not similarity “sim” effects) may freely interact; use effectsDocumentation() to check interaction eligibility. 

RSiena_Manual

 

RSiena_Manual

Example of a valid influence-by-trait interaction (average alter × quadratic shape) is provided in the manual; pattern your code similarly when testing moderation of peer influence. 

RSiena_Manual

R pattern:

# influence (average alter) of friends' behavior on ego's behavior:
eff <- includeEffects(eff, avAlt, name = "tolerance", interaction1 = "friendship")
# moderation by current level (quadratic shape):
eff <- includeInteraction(eff, quad, avAlt, name = "tolerance",
                          interaction1 = c("", "friendship"))


(Structure mirrors the manual’s example.) 

RSiena_Manual

4) Estimation & algorithm tuning

Create an algorithm object with sienaAlgorithmCreate(...) and estimate with siena07(...). 

RSiena_Manual

Convergence standard (non-negotiable): after estimation, check overall maximum convergence ratio and t-statistics for deviations from targets. “Converged” if tconv.max < 0.25 and all deviation t’s < 0.10; “nearly converged” if < 0.35 and < 0.15, respectively. Don’t trust non-converged runs. 

RSiena_Manual

If instability persists, consider the Robbins–Monro gain (firstg)—too low slows progress, too high causes instability; adjust only if necessary. 

RSiena_Manual

R pattern:

alg <- sienaAlgorithmCreate(projname = "rsiena_fit")
fit <- siena07(alg, data = mydata, effects = eff)
summary(fit)$tconv.max  # expect < .25 (ideal)


(Thresholds & rationale per manual.) 

RSiena_Manual

5) Guard against multicollinearity & fragile SEs

RSiena flags near-perfect collinearity; drop one or more implicated effects when you see the “*** Standard errors not reliable ***” warning. 

RSiena_Manual

With strong but imperfect collinearity, re-estimate and check stability of SEs across runs; parameter correlations > .90 warrant caution (except high correlation with outdegree, which is common and less worrying). Prefer a more parsimonious model if instability persists. 

RSiena_Manual

 

RSiena_Manual

6) Time heterogeneity (when ≥3 waves)

Test whether parameters change across periods using sienaTimeTest(ans) (score test; no extra estimation needed). 

RSiena_Manual

 

RSiena_Manual

If heterogeneity is present, either (i) analyze subsets/wave-by-wave, or (ii) add time dummies with includeTimeDummy(...) to allow specific effects to vary by period, then re-test. 

RSiena_Manual

 

RSiena_Manual

R pattern:

tt <- sienaTimeTest(fit)
eff <- includeTimeDummy(eff, recip, transTrip, timeDummy = "2")
fit2 <- siena07(alg, data = mydata, effects = eff)


(Usage & follow-ups as documented.) 

RSiena_Manual

7) Goodness of fit (model adequacy)

Use sienaGOF with auxiliary targets like degree distributions (in/out), geodesic distances, triad census. Small p-values mean misfit (reject the null that the model reproduces target statistics). Continue simulations until p-values stabilize. (Manual help page and guidance.) 

RSiena_Manual

 

RSiena_Manual

 

RSiena_Manual

 

RSiena_Manual

R pattern:

gof_deg <- sienaGOF(fit, IndegreeDistribution, verbose = TRUE)
gof_geo <- sienaGOF(fit, GeodesicDistribution)
gof_tri <- sienaGOF(fit, TriadCensus)

plot(gof_deg); plot(gof_geo); plot(gof_tri)  # expect acceptable p's & visual fit


(Exactly the recommended families of GOF stats.) 

RSiena_Manual

8) Simulation mode (theory checks, sensitivity, GOF)

For pure simulation with fixed parameters (e.g., to study expected diffusion of tolerance under an intervention), run Phase 3 only: set nsub = 0 and simOnly = TRUE (typically with cond = FALSE on two-wave data so simulations depend on params + first wave only). 

RSiena_Manual

 

RSiena_Manual

R pattern:

simAlg <- sienaAlgorithmCreate(projname="sim", cond=FALSE, useStdInits=FALSE,
                               nsub=0, simOnly=TRUE)
simAns <- siena07(simAlg, data=mydata, effects=eff)


(Parameters taken from eff$initialValue when useStdInits=FALSE.) 

RSiena_Manual

9) Missing data & composition change (schools often have both)

Composition change (joiners/leavers) has specific handling—use the dedicated procedures in §4.3.3. 

RSiena_Manual

The manual separates randomly missing tie data (MNAR/MAR/MCAR considerations) from composition change; follow the §4.3.2/4.3.3 instructions so that missingness & changing membership are correctly encoded before estimation. 

RSiena_Manual

 

RSiena_Manual

10) Independent groups & intervention contrasts

To compare parameters across independent groups (e.g., treated vs. control schools) or across periods (e.g., pre/post intervention), use the manual’s difference-in-parameters z-test:

𝑧
=
𝛽
^
𝑎
−
𝛽
^
𝑏
(
s
.
e
.
𝑎
)
2
+
(
s
.
e
.
𝑏
)
2
z=
(s.e.
a
	​

)
2
+(s.e.
b
	​

)
2
	​

β
^
	​

a
	​

−
β
^
	​

b
	​

	​


(approximately standard normal under equality). Keep the model identical across groups. 

RSiena_Manual

 

RSiena_Manual

The same logic applies for period-specific estimates when analyzed separately (conditioning on the middle wave). 

RSiena_Manual

11) Reproducibility & speed

Use the official example scripts as templates; they map one-to-one to the canonical steps and help keep your code reproducible. 

RSiena_Manual

Parallelization can speed estimation; see “multiple processors” guidance (Section 6.13). 

RSiena_Manual

12) Practical decision rules (quick checks)

Proceed with SAOM if Jaccard stability is acceptable (≥ .30 ideal) and degrees are in realistic school ranges; re-think if values are extremely low without monotone growth/decline. 

RSiena_Manual

 

RSiena_Manual

Accept estimates only after convergence: tconv.max < .25 and all deviation t’s < .10 (or the “nearly converged” thresholds). 

RSiena_Manual

Trim effects if RSiena flags collinearity or if SEs are unstable across runs; prefer the simpler model. 

RSiena_Manual

 

RSiena_Manual

Investigate time heterogeneity with sienaTimeTest; if present, enact includeTimeDummy or analyze subsets. 

RSiena_Manual

 

RSiena_Manual

Demonstrate adequacy via sienaGOF (degrees, geodesics, triads); poor p-values → refine effects and re-estimate. 

RSiena_Manual

 

RSiena_Manual

13) Minimal, high-quality code scaffold (drop-in template)
library(RSiena)

## 1) Data objects ----------------------------------------------------------
# friendship_arr: [N x N x W] 0/1 adjacency; behavior_mat: [N x W] integer/ordinal
friendship <- sienaDependent(friendship_arr)             # network
tolerance  <- sienaDependent(behavior_mat, type="behavior")  # behavior (if modeled)
mydata     <- sienaDataCreate(friendship, tolerance)

print01Report(mydata, modelname="00_precheck")  # check Jaccard/deg
# Manual explains report & Jaccard interpretation.
# (See 'Change in networks' & thresholds.)  # :contentReference[oaicite:51]{index=51} :contentReference[oaicite:52]{index=52}

## 2) Effects ---------------------------------------------------------------
eff <- getEffects(mydata)                                # baseline includes outdegree & reciprocity
# :contentReference[oaicite:53]{index=53}
eff <- includeEffects(eff, recip, transTrip)             # add triadic closure, etc.
# For behavior influence:
# eff <- includeEffects(eff, avAlt, name="tolerance", interaction1="friendship")  # :contentReference[oaicite:54]{index=54}

## 3) Algorithm & estimation -----------------------------------------------
alg <- sienaAlgorithmCreate(projname="01_rsiena_fit")
fit <- siena07(alg, data=mydata, effects=eff, batch=TRUE)
summary(fit)$tconv.max               # target < 0.25 (ideal)  # :contentReference[oaicite:55]{index=55}

## 4) Time heterogeneity (if W >= 3) ---------------------------------------
tt <- sienaTimeTest(fit)                                  # :contentReference[oaicite:56]{index=56}
# If significant: allow time-varying reciprocity and/or closure
eff <- includeTimeDummy(eff, recip, transTrip, timeDummy = "2")   # :contentReference[oaicite:57]{index=57}
fit2 <- siena07(alg, data=mydata, effects=eff, batch=TRUE)

## 5) Goodness of fit -------------------------------------------------------
gof_deg <- sienaGOF(fit2, IndegreeDistribution)
gof_geo <- sienaGOF(fit2, GeodesicDistribution)
gof_tri <- sienaGOF(fit2, TriadCensus)                     # :contentReference[oaicite:58]{index=58}
plot(gof_deg); plot(gof_geo); plot(gof_tri)               # interpret p-values

14) How this maps to your dissertation

Data: start with Together for Tolerance (or simulate if you need controlled scenarios/power). Use the simulation mode for theory probing (e.g., how strong should influence be for tolerance to spread?), then estimate on the empirical data and report GOF. 

RSiena_Manual

Design: baseline network model (outdegree, reciprocity, transitive closure), add covariates (e.g., same class/ethnicity), then add influence (average alter on tolerance) and selection (similarity in tolerance) carefully, watching interaction rules. 

RSiena_Manual

Evaluation: require convergence by the strict thresholds; probe time heterogeneity (pre/post intervention periods); finalize with sienaGOF on degrees, geodesics, triads. 

RSiena_Manual

 

RSiena_Manual

 

RSiena_Manual

Reporting: show Jaccard stability, model table (effects, estimates, SEs, t), convergence metrics, time-heterogeneity tests, and GOF figures—this mirrors “Steps for looking at results” in the manual. 

RSiena_Manual

Final reminders (the “don’t skip these” list)

Always inspect print01Report and Jaccard before modeling. 

RSiena_Manual

 

RSiena_Manual

Enforce manual convergence thresholds; don’t interpret non-converged runs. 

RSiena_Manual

Use score-based time tests and time dummies if needed. 

RSiena_Manual

 

RSiena_Manual

Validate with sienaGOF (degrees, geodesics, triads) and iterate. 

RSiena_Manual

Trim effects if RSiena warns about collinearity; prefer parsimony and SE stability. 

RSiena_Manual

A) Title

“Network Dynamics of Tolerance: A RSiena-Based Research Plan for Interethnic Cooperation”

(Short running title: “RSiena Plan: Tolerance & Cooperation”)

B) What I’d add after six months living in the RSiena manual
1) Convergence, continuation, and algorithm control — be stricter and systematic

Report both indicators and aim for strong thresholds. Publish only results where all convergence t-ratios are |t| < 0.10 and the overall maximum convergence ratio < 0.25 (excellent if < 0.20). These directly reflect deviations of simulated targets from observed targets; large averages/SDs alone are not concerning—only the t-ratios are. 

RSiena_Manual

 

RSiena_Manual

Continue estimation rather than restarting. If not converged, rerun siena07() with prevAns=... (default useStdInits=FALSE) until the criteria are met; this is the normal workflow. 

RSiena_Manual

Tune the algorithm only if needed. If still unstable, adjust n2start, nsub, firstg, diagonalize, or enable double averaging; these are the primary levers recommended for difficult data-model combinations. 

RSiena_Manual

 

RSiena_Manual

 

RSiena_Manual

2) Data hygiene that materially affects estimates

Check stability of networks across waves. Use print01Report() and inspect Jaccard indices; low wave-to-wave stability (e.g., Jaccard < ~0.20) is a red flag for SAOM. (Manual provides this diagnostic explicitly.) 

RSiena_Manual

Handle monotone behaviors up front. If your tolerance measure is monotone (many actors change only upward or only downward), treat that explicitly; monotone behaviors can bias dynamics/shape effects if ignored. 

RSiena_Manual

Scale covariates sensibly. Keep standard deviations in a sane band (≈0.1–10) to avoid numerical issues in estimation. (The manual states this guidance in the covariates section.) 

RSiena_Manual

3) Structural values, missingness, and composition change

Use structural zeros/ones correctly. Structural zeros and ones (e.g., class boundaries where ties are impossible, or “always-ties” for mandatory relations) must be coded as structural values in the dependent arrays before creating the sienaDependent. RSiena uses special codes: 10 = structural zero, 11 = structural one. Don’t impute these—encode them. 

RSiena_Manual

Treat missing data as missing, not structural. The manual distinguishes “structurally determined” from “missing”; keep them separate—structural values constrain the process, missing values do not. 

RSiena_Manual

Composition change (joiners/leavers). Follow the manual’s recipe for actors entering/leaving between waves; composition change is supported and must be encoded according to Section 4.3.3 (do not silently drop actors). 

RSiena_Manual

4) Model architecture you’ll actually estimate

Creation vs. endowment (networks). Remember RSiena splits tie dynamics into creation and endowment objective functions, allowing different preferences for forming vs. maintaining ties. If maintenance differs from formation in school settings (plausible), include endowment variants for key structural effects. 

RSiena_Manual

Behavior model (shape + social influence). Include linear and quadratic shape for the tolerance behavior, plus the average-alter effect from the friendship network (selection–influence co-evolution). The manual’s behavior section lays out these pieces and how to interact them. 

RSiena_Manual

Two-mode / multiple networks (if needed). If you add, say, “group activities” or “classroom membership” as a bipartite network, RSiena supports two-mode and cross-network effects; specify the node sets and cross-network statistics accordingly. 

RSiena_Manual

 

RSiena_Manual

Undirected networks. If your relation is effectively symmetric (e.g., reciprocated “working-together only when mutual”), set the correct model type for undirected networks to use the appropriate statistics. 

RSiena_Manual

Boundaries & constraints. If outdegree is institutionally limited (e.g., formal mentoring quotas), RSiena has explicit “limit outdegree” machinery—use it rather than ad-hoc trimming. 

RSiena_Manual

5) Time heterogeneity and formal tests

Always test time heterogeneity. Use sienaTimeTest() to detect period-specific deviations; if present, add includeTimeDummy() dummies for the implicated effects. This is the manual’s recommended path for modeling wave-by-wave variation. 

RSiena_Manual

Wald/score tests and linear contrasts. For theory-driven constraints (e.g., equality of parameters across periods or groups), use the manual’s Section 8 testing framework (Wald tests for linear combinations). 

RSiena_Manual

6) Multigroup (classes/schools) and random effects

Pooled vs. multigroup. Use sienaGroupCreate() to analyze multiple classrooms as groups with a common parameter vector (or allow group-specific parameters as required). 

RSiena_Manual

Random coefficients (Bayesian). If you want partial pooling across schools, Section 11 describes Bayesian estimation for random effects (sienaBayes), which is directly relevant if sampling many classes. 

RSiena_Manual

7) Fit assessment and reporting

GOF is not optional. Evaluate degree distributions, geodesic distances, triad census, and behavior distributions via sienaGOF; GOF p-values are (weakly) expected to be non-significant—small p’s indicate model misfit. Report them. 

RSiena_Manual

Interpretation discipline. Use ego–alter tables and carefully interpret selection vs. influence; avoid raw “effect size” metaphors that don’t map to ministep log-odds parameters.

C) High-quality RSiena R scaffolding (drop-in, amend paths/names)

The snippets below follow the manual’s workflow: data prep → print01Report() checks → effects/build → estimation with convergence protocol → time tests → GOF → multigroup. Key manual rules are referenced right after each step.

# --- 0) Setup ---------------------------------------------------------------
# Install once:
# install.packages(c("RSiena","igraph","ggraph"))

library(RSiena)

set.seed(20250917)   # Reproducibility; keep this in your log

# --- 1) Load or construct arrays -------------------------------------------
# Suppose you have W waves of an N x N friendship network, and a tolerance behavior.
# Replace the placeholders with actual arrays from your dataset.

# Example shapes:
# friendship_arr: array of dimension [N, N, W], binary 0/1; may contain 10/11 structural codes
# tolerance_mat : matrix [N, W], integer or ordered categories

# friendship_arr <- ...   # load your OSF / local data here
# tolerance_mat  <- ...

# --- 1a) Structural constraints (if any) -----------------------------------
# Encode structural zeros/ones directly in the array *before* sienaDependent():
# 10 = structural zero; 11 = structural one (manual Sec. 4.3.1).
# Example: forbid ties across cohorts by a block mask 'forbid' (N x N; 1=forbidden).
# friendship_arr[forbid == 1] <- 10

# --- 1b) Quick diagnostics --------------------------------------------------
# The built-in report flags unstable networks (includes Jaccard) and monotone behavior.
# (Manual emphasizes using print01Report, Jaccard, monotonicity checks.)
# print01Report(list(friendship_arr), list(tolerance_mat))


Narrative rule: use print01Report() and inspect Jaccard/monotone behavior before modeling. 

RSiena_Manual

 

RSiena_Manual

# --- 2) Build siena data ----------------------------------------------------
friendship <- sienaDependent(friendship_arr, type = "oneMode", allowOnly = FALSE)
tolerance  <- sienaDependent(tolerance_mat,  type = "behavior")  # ensure integer-coded range

# Optional: actor covariates (center/scale upstream to keep SD in ~[0.1,10])
# sex         <- coCovar(sex_vec)
# migrant     <- coCovar(migrant_status)
# grade       <- varCovar(grade_by_wave)   # time-varying

mydata <- sienaDataCreate(friendship, tolerance)  # , sex, migrant, grade, ...)

# --- 3) Define effects ------------------------------------------------------
myeff <- getEffects(mydata)

# 3a) Core network structure
myeff <- includeEffects(myeff,
                        density, reciprocity,
                        transTrip,        # transitive triplets
                        cycle3,           # 3-cycles (often negative in directed school networks)
                        name = "friendship")

# 3b) Selection on tolerance (homophily/similarity)
# 'simX' uses similarity on behavior or covariate
myeff <- includeEffects(myeff, simX, name = "friendship", interaction1 = "tolerance")

# 3c) Behavior dynamics (shape + social influence)
myeff <- includeEffects(myeff,
                        linear, quad,                       # shape of tolerance evolution
                        avAlt, name = "tolerance",         # average alter in friendship network
                        interaction1 = "friendship")

# 3d) (Optional) Endowment for networks: allow different maintenance vs creation
# myeff <- includeEffects(myeff, endow, name = "friendship")  # exemplar; adjust to the exact endowment term(s)

# --- 4) Algorithm with robust defaults -------------------------------------
# Start with standard initial values only if needed; otherwise rely on prevAns iteration.
# Convergence protocol: repeat using prevAns until |t|<.10 and tconv.max<.25.
algo <- sienaAlgorithmCreate(projname = "tolerance_friendship_saom",
                             nsub = 4,        # subphases
                             n2start = 0,     # let default depend on p & nodes; tune only if needed
                             firstg = 0.2,    # step size; reduce if unstable
                             diagonalize = 0.2,
                             doubleAveraging = 0)  # manual defaults and tuning knobs

ans <- siena07(algo, data = mydata, effects = myeff, batch = TRUE, returnDeps = TRUE)

# Continue until converged:
while (ans$tconv.max > 0.25 || any(abs(ans$tstat) > 0.10)) {
  ans <- siena07(algo, data = mydata, effects = myeff, prevAns = ans, batch = TRUE, returnDeps = TRUE)
}

summary(ans)


Why this loop: the manual explicitly prescribes iterative continuation with prevAns and convergence thresholds; tuning knobs (n2start, nsub, firstg, diagonalize, doubleAveraging) are the endorsed next step if convergence resists. 

RSiena_Manual

 

RSiena_Manual

 

RSiena_Manual

# --- 5) Time heterogeneity tests -------------------------------------------
# Detect wave-specific deviations; then add time dummies for implicated effects
(tt <- sienaTimeTest(ans))  # inspect which effects fail time homogeneity

# Example: add time dummies to reciprocity in periods 1->2 and 2->3 (indices as indicated by sienaTimeTest)
# myeff <- includeTimeDummy(myeff, recip, timeDummy = c(1, 2), name = "friendship")
# Re-estimate with updated myeff:
# ans <- siena07(algo, data = mydata, effects = myeff, prevAns = ans, batch = TRUE, returnDeps = TRUE)


This mirrors the manual’s prescription: test with sienaTimeTest() then incorporate includeTimeDummy() for period-specific parameters. 

RSiena_Manual

# --- 6) Goodness-of-fit (must report) --------------------------------------
# Degree distributions:
gof_indeg  <- sienaGOF(ans, IndegreeDistribution, verbose = FALSE, varName = "friendship")
gof_outdeg <- sienaGOF(ans, OutdegreeDistribution, verbose = FALSE, varName = "friendship")
# Geodesic distances:
gof_geo    <- sienaGOF(ans, GeodesicDistribution, verbose = FALSE, varName = "friendship")
# Triad census:
gof_triad  <- sienaGOF(ans, TriadCensus, verbose = FALSE, varName = "friendship")
# Behavior distribution:
gof_beh    <- sienaGOF(ans, BehaviorDistribution, verbose = FALSE, varName = "tolerance")

print(gof_indeg); print(gof_outdeg); print(gof_geo); print(gof_triad); print(gof_beh)


Report GOF and seek non-significant p-values for these distributions; small p’s signal misfit requiring respecification. 

RSiena_Manual

# --- 7) Multigroup (e.g., classes) -----------------------------------------
# If you have multiple classrooms with identical variable structure:
# group_list <- list(data_class1, data_class2, ...)   # each is a sienaData object
# group_data <- sienaGroupCreate(group_list)
# myeff_g    <- getEffects(group_data)
# (redefine effects as above, then)
# ans_g      <- siena07(algo, data = group_data, effects = myeff_g, batch=TRUE, returnDeps=TRUE)


Use sienaGroupCreate() for pooled estimation across groups; consider Bayesian random effects (sienaBayes) when partial pooling is desirable. 

RSiena_Manual

# --- 8) Reproducible export -------------------------------------------------
# saveRDS(ans, "rsiena_tolerance_friendship_fit.rds")
# write.csv(summary(ans)$theta, "rsiena_parameters.csv")

Optional control code (only if convergence resists)

If the loop above keeps failing, lower firstg (e.g., 0.05), raise n2start, or temporarily set nsub=1 with a large n2start to stabilize, as the manual suggests for difficult combos. 

RSiena_Manual

 

RSiena_Manual

D) Pitfalls & fixes I would watch for (manual-anchored)

Convergence not improving after several prevAns runs.
Lower firstg and increase n2start; possibly re-seed and try updateTheta() rather than prevAns to re-enter Phase 1. 

RSiena_Manual

 

RSiena_Manual

Mis-specification from ignoring endowment.
If tie persistence dynamics differ from formation, include endowment counterparts for key effects (reciprocity, transitivity) to avoid biased selection parameters. 

RSiena_Manual

Hidden time heterogeneity.
Always run sienaTimeTest(); if ignored, pooled parameters average over regime shifts in norms (e.g., a mid-year program launch), degrading fit. 

RSiena_Manual

Structural vs. missing conflation.
Mis-coding constraints as NA (or vice versa) breaks the data-generating assumptions; use 10/11 codes for structural ties, NA for missing, as instructed. 

RSiena_Manual

Overly large/small covariate scales.
Standardize upstream; don’t rely on the optimizer to solve numeric scale problems. 

RSiena_Manual

E) What’s already “production-ready” vs. what you’ll still need

Already provided

Full RSiena workflow code (single-group) with convergence loop, time tests, and GOF.

Templates for structural coding, endowment inclusion, and multigroup setup.

Decision rules for thresholds, continuation, tuning, and reporting—cited to the manual.

Still to plug in

Your actual data objects (friendship_arr, tolerance_mat, covariates).

Specific endowment terms (choose the exact endowment effects matching the structure you include). 

RSiena_Manual

Time dummies only after inspecting sienaTimeTest() output. 

RSiena_Manual

F) Minimal reporting checklist (compliant with the manual)

Convergence table with all |t| and tconv.max, and the number of Phase-3 sims used for diagnostics. 

RSiena_Manual

Exact algorithm settings (firstg, n2start, nsub, diagonalize, doubleAveraging) and whether/when they were changed. 

RSiena_Manual

Rationale and coding of structural values and any composition change decisions. 

RSiena_Manual

 

RSiena_Manual

Full GOF suite (degree, geodesic, triads, behavior distribution) with interpretation. 

RSiena_Manual

Results of time heterogeneity tests and any time dummies added. 

RSiena_Manual

RSiena manual—deeper guidelines distilled for your project

Below are the rules of thumb I’d actually work by when implementing your plan on tolerance interventions and interethnic cooperation with SAOM, with pinpointed manual anchors.

0) Data intake, coding, and prelim checks

Use structural codes deliberately. In longitudinal adjacency arrays, 10 = structural zero (tie is impossible) and 11 = structural one (tie is forced); NA marks missingness. Don’t conflate them—structural codes change the model’s probability space while NA affects likelihood contributions. 

RSiena_Manual

Behavioral variables (type = "behavior"): define the allowed range explicitly (min/max) and mind centering/scale—these affect shape parameters and downstream interpretability. 

RSiena_Manual

01-report & stability. Before any estimation, run a descriptive report to check densities, reciprocity, transitions, and Jaccard stability across waves; use this to justify period pooling and model identifiability. The manual’s workflow points to print01Report() and Jaccard as standard first checks. 

RSiena_Manual

1) Specification logic you’ll reuse

Default network backbone: include density (outdegree), reciprocity, at least one triadic closure (e.g., transTrip). These stabilize simulated micro-steps and help fit local clustering; later validate with triad census GOF. (See 5.10 & 5.15 headings for directed networks and GOF menu.) 

RSiena_Manual

 

RSiena_Manual

Selection vs. influence separation (co-evolution):

Selection (who befriends whom) uses similarity in behavior and actor covariates: e.g., simX (same ethnicity or same tolerance level), egoX/altX (actor/alter effects).

Influence (how tolerance changes) uses average similarity of friends (avSim) and/or average alter behavior (avAlt); specify name=<behavior> and interaction1=<network> in includeEffects() so RSiena knows you’re adding network→behavior pathways. 

RSiena_Manual

 

RSiena_Manual

 

RSiena_Manual

avSim vs. avAlt:

avSim = conformity toward your friends’ similarity in tolerance (proximity pull).

avAlt = conformity toward your friends’ mean level (a direct mean-alter pull). Both are in the behavior effects list and often compared; include one at a time first for identifiability, then test alternatives. 

RSiena_Manual

 

RSiena_Manual

2) Time heterogeneity, intervention periods, and tests

Intervention dummies: Represent program periods (pre, during, post) via time dummies on key effects with includeTimeDummy(); then use sienaTimeTest() to test whether parameters differ across periods (e.g., stronger peer influence during the campaign). 

RSiena_Manual

 

RSiena_Manual

Practical rule: start with homogeneous parameters; only keep time dummies that pass the time-heterogeneity test and are theoretically motivated.

3) Degree limits and fixed-choice surveys

Avoid hard outdegree caps during ML estimation. MaxDegree= is not supported for ML (siena07) and can harm convergence; instead enforce via outMore/outThreshold with a large negative fixed coefficient if truly needed. Also, fixed-choice designs near the cap impede convergence and contradict SAOM’s free-choice assumption. 

RSiena_Manual

 

RSiena_Manual

4) Estimation, convergence, continuation

Convergence standards to enforce in code: all t-ratios (for means) |t| < 0.10 and Overall maximum convergence ratio < 0.25. If not met, continue estimation with updated initial values (‘phase 3’ restarts). 

RSiena_Manual

 

RSiena_Manual

Algorithm knobs you’ll use: nsub, n3, seeds, and saving sims (for GOF). Tune them after a minimal model converges. 

RSiena_Manual

5) Post-estimation model adequacy (required)

sienaGOF: Evaluate fit for (i) in/outdegree distributions, (ii) geodesic distances, (iii) triad census; specify levls sensibly (default 0:8 is often too short), and inspect Mahalanobis-based p-values/plots. 

RSiena_Manual

 

RSiena_Manual

 

RSiena_Manual

6) Simulation & counterfactuals

Forward simulation from a fitted model: either run simOnly=TRUE or set nsub=0 to generate sample paths under your estimated mechanisms—use this for intervention scenarios (e.g., stronger referent targeting). 

RSiena_Manual

End-to-end research process mapped to executable R (scaffold)

Scope: Friendship network (directed) across ≥3 waves; a behavioral tolerance score per wave; ethnicity (categorical), gender, class; optional “cooperation” network. Dataset: Together-for-Tolerance (if used) or simulated.

1) Setup & data assembly
# Packages
library(RSiena)
library(igraph)     # used for some GOF aux stats
library(sna)        # idem

# --- Load your longitudinal networks as 3D arrays: [i, j, wave] ---
# Friendship network: Y_friend[ i, j, t ] in {0,1, NA, 10 (struct 0), 11 (struct 1)}
# Behavior (tolerance): Y_tol[ i, wave ] - integer or discrete scale; define min/max.
# Covariates: ethnicity (factor), gender (0/1), class (factor), etc.

# Sanity checks & structural coding per manual:
# 10 = structural zero; 11 = structural one; NA = missing.
# Ensure only {0,1,NA,10,11} appear in the adjacency arrays.
stopifnot(all(Y_friend %in% c(0,1,NA,10,11)))


(Structural coding principle.) 

RSiena_Manual

Create RSiena dependents & covariates
# Network dependent
FR <- sienaDependent(Y_friend, type = "oneMode")

# Behavior dependent (set range; the centering affects shape params)
# e.g., tolerance coded 1..5
TOL <- sienaDependent(Y_tol, type = "behavior", allowOnly = FALSE, range = c(1,5))
# (behavior creation & centering implications) :contentReference[oaicite:22]{index=22}

# Actor covariates
ETH <- coCovar(ethnicity_numeric)     # or create dummies for categories
GEN <- coCovar(gender_binary)
CLS <- coCovar(class_id)

# Optional: dyadic covariates for same ethnicity
SameEth <- varDyadCovar(outer(ethnicity_numeric, ethnicity_numeric, "==")*1)

Build the Siena data object & 01 report
dat <- sienaDataCreate(FR, TOL, ETH, GEN, CLS, SameEth)

# Descriptives & stability diagnostics (density, reciprocity, transitions, Jaccard)
print01Report(dat, filename = "01report_tolerance.txt")


(Manual emphasizes this “first look” report & Jaccard stability to judge pooling.) 

RSiena_Manual

2) Baseline model: selection & influence separated
# Effects
eff <- getEffects(dat)

# --- Network dynamics backbone ---
eff <- setEffect(eff, outdeg)        # density
eff <- setEffect(eff, reciprocity)
eff <- setEffect(eff, transTrip)     # triadic closure

# Actor covariate effects on selection
eff <- setEffect(eff, egoX, altX, interaction1 = "GEN") # example
eff <- setEffect(eff, sameX, interaction1 = "ETH")      # homophily by ethnicity
eff <- setEffect(eff, XTransTrip, interaction1 = "SameEth") # closure moderated by similarity (optional)

# --- Behavior dynamics backbone ---
eff <- setEffect(eff, linear)        # linear shape
eff <- setEffect(eff, quad)          # quadratic shape

# Influence candidates (add one first; compare models)
eff <- includeEffects(eff, name = "TOL", avSim, interaction1 = "FR")   # similarity-based pull
# alt: eff <- includeEffects(eff, name = "TOL", avAlt, interaction1 = "FR")  # mean-alter pull


(Correct co-evolution syntax: specify name=<behavior> and interaction1=<network>.) 

RSiena_Manual

3) Intervention timing and time heterogeneity
# Suppose wave 2 spans the program; test whether reciprocity and influence change
eff <- includeTimeDummy(eff, effectName = "reciprocity", timeDummy = 2)
eff <- includeTimeDummy(eff, effectName = "avSim", name="TOL", interaction1="FR", timeDummy = 2)

# Later: test which time dummies are needed
# fit0 -> sienaTimeTest(fit0, effectsOfInterest) to decide whether to keep heterogeneity


(Use of time dummies and formal tests.) 

RSiena_Manual

 

RSiena_Manual

4) Estimation loop with strict convergence gates
# Algorithm – start moderate, then increase for fine convergence
alg <- sienaAlgorithmCreate(
  projname = "tolerance_saom",
  useStdInits = TRUE
)

# First fit
fit1 <- siena07(alg, data = dat, effects = eff,
                batch = TRUE, returnDeps = TRUE, silent = FALSE)

# Convergence continuation if required
needs_more <- (summary(fit1)$tconv.max > 0.25) || any(abs(summary(fit1)$tstat) > 0.1)
if (needs_more) {
  alg2 <- sienaAlgorithmCreate(projname = "tolerance_saom_cont", useStdInits = FALSE)
  fit2 <- siena07(alg2, data = dat, effects = eff, prevAns = fit1,
                  batch = TRUE, returnDeps = TRUE)
} else {
  fit2 <- fit1
}


(Continuation and thresholds: |t-ratios| < .10 and overall convergence ratio < .25.) 

RSiena_Manual

 

RSiena_Manual

5) Model comparison and pruning

Compare avSim vs. avAlt specifications; retain the one with (i) better fit, (ii) interpretable sign, and (iii) improved GOF. (Effect definitions and syntax.) 

RSiena_Manual

 

RSiena_Manual

Drop weak/collinear covariate effects after checks; re-estimate to maintain convergence margins.

6) Goodness-of-fit (mandatory)
# Degree distributions (choose sensible support)
gof_indeg <- sienaGOF(fit2, IndegreeDistribution, verbose = TRUE,
                      varName = "FR", cumulative = TRUE, levls = c(0:10, 15, 20, 30))
gof_outdeg <- sienaGOF(fit2, OutdegreeDistribution, verbose = TRUE,
                       varName = "FR", cumulative = TRUE, levls = c(0:10, 15, 20, 30))

# Geodesic distances (requires sna/igraph)
gof_geo   <- sienaGOF(fit2, GeodesicDistribution, varName = "FR")

# Triad census
gof_tri   <- sienaGOF(fit2, TriadCensus, varName = "FR")

# Inspect p-values and plots
plot(gof_indeg); plot(gof_outdeg); plot(gof_geo); plot(gof_tri)


(Use sienaGOF; set levls; Mahalanobis distance, p-values & plots.) 

RSiena_Manual

 

RSiena_Manual

 

RSiena_Manual

7) Counterfactual simulation (program design questions)
# Simulate from fitted model to inspect tolerance diffusion and cross-ethnic tie formation
alg_sim <- sienaAlgorithmCreate(projname = "tolerance_sim", simOnly = TRUE)
sim <- siena07(alg_sim, data = dat, effects = eff, prevAns = fit2,
               nsub = 0, returnDeps = TRUE)


(Forward simulation knobs.) 

RSiena_Manual

Additional pieces you’ll likely need from the manual
Interaction effects & internal parameters (for advanced hypotheses)

When modeling moderation (e.g., influence is stronger inside reciprocated ties), use the interaction-effects machinery (5.12), minding interactionType and internal effect parameters. Use this after a stable base model. 

RSiena_Manual

Limiting outdegree without ML conflicts

As ML (siena07) ignores MaxDegree, emulate caps by fixing outMore/outThreshold with very negative values. Don’t use survey designs that force near-cap degrees; they harm convergence. 

RSiena_Manual

 

RSiena_Manual

Multigroup data & centering

For multiple classes/schools, use sienaGroupCreate(). For behavior centering across groups, consider the group-average (avGroup) centering parameter p when between-group means differ—this affects linear shape estimates. 

RSiena_Manual

 

RSiena_Manual

Influence variants beyond avSim

You can test in-degree-weighted or reciprocity-restricted influence (e.g., avInSim, avRecAlt) if theory says the source of influence matters (popular peers, mutuals). Start simple, then extend. 

RSiena_Manual

 

RSiena_Manual

GOF for composition change and missingness

When running GOF in the presence of joiners/leavers/missing data/structural values, consult section 5.15.4 to set options accordingly so auxiliary statistics are computed on a comparable support. 

RSiena_Manual

Minimal ABM baseline (optional contrast, not to overcomplicate)

If you want a lean ABM contrast to SAOM’s micro-step logic:

# Threshold adoption ABM over observed network at wave t0
# (Simple complex-contagion surrogate; not SAOM estimation.)
threshold_adopt <- function(A, z0, thresh = 0.5, steps = 10) {
  z <- z0
  for (s in seq_len(steps)) {
    for (i in seq_len(nrow(A))) {
      nbrs <- which(A[i,] == 1)
      if (length(nbrs)) {
        p <- mean(z[nbrs] > median(z0, na.rm = TRUE))
        if (p >= thresh) z[i] <- z[i] + 1L
      }
    }
  }
  z
}


Use this only for qualitative triangulation (e.g., “multiple exposures needed for tolerance increase”), while SAOM remains the inferential engine.

Step-by-step execution checklist (to literally follow in code)

Assemble arrays (networks, behavior, covariates). Encode 10/11/NA correctly. 

RSiena_Manual

sienaDependent() objects for network and behavior; define behavior range and centering expectations. 

RSiena_Manual

sienaDataCreate() ➜ print01Report(); confirm reasonable density/reciprocity, transitions, and Jaccard stability per period. 

RSiena_Manual

Baseline effects: (network) outdeg, reciprocity, transTrip; (behavior) linear, quad. Add selection covariates and simX for homophily.

Add one influence pathway (avSim or avAlt) with explicit name=/interaction1=. 

RSiena_Manual

Estimate with siena07(). If max conv ratio ≥ .25 or any |t| ≥ .10, continue estimation with prevAns. 

RSiena_Manual

 

RSiena_Manual

Test time heterogeneity on theoretically targeted effects (program period) using includeTimeDummy() + sienaTimeTest(). Keep only supported heterogeneity. 

RSiena_Manual

GOF suite (sienaGOF): in/outdegree (careful levls), geodesic, triad census; check Mahalanobis p-values and plots. 

RSiena_Manual

 

RSiena_Manual

Sensitivity: swap avSim ↔ avAlt, toggle a key triadic effect, and re-run GOF.

Simulate counterfactuals (e.g., stronger referent exposure) with simOnly/nsub=0. 

RSiena_Manual

Report: tables with estimates, standard errors, conv diagnostics, GOF plots, and a pre-registered analysis path.

Common pitfalls & fixes (manual-aligned)

Fixed-choice network caps (everyone near max outdegree) → estimation may not converge; avoid or model with strong outMore/outThreshold fixed negative penalty (not MaxDegree under ML). 

RSiena_Manual

 

RSiena_Manual

Too many time dummies → weak identification; add gradually and test with sienaTimeTest. 

RSiena_Manual

Over-rich influence block (avSim + avAlt + weighted variants) → collinearity; compare nested models one change at a time. 

RSiena_Manual

Default GOF levls too short → misleading p-values; set levls to cover observed tails. 

RSiena_Manual

Minimal, high-quality code shell you can extend
# 0) Data ----
FR <- sienaDependent(Y_friend, type="oneMode")
TOL <- sienaDependent(Y_tol, type="behavior", allowOnly=FALSE, range=c(1,5))
ETH <- coCovar(ethnicity_numeric); GEN <- coCovar(gender_binary)
SameEth <- varDyadCovar(outer(ethnicity_numeric, ethnicity_numeric, "==")*1)
dat <- sienaDataCreate(FR, TOL, ETH, GEN, SameEth)
print01Report(dat, "01report_tolerance.txt")  # Jaccard & transitions

# 1) Effects ----
eff <- getEffects(dat)
eff <- setEffect(eff, outdeg); eff <- setEffect(eff, reciprocity); eff <- setEffect(eff, transTrip)
eff <- setEffect(eff, egoX, altX, interaction1="GEN")
eff <- setEffect(eff, sameX, interaction1="ETH")
eff <- setEffect(eff, linear, name="TOL"); eff <- setEffect(eff, quad, name="TOL")
eff <- includeEffects(eff, name="TOL", avSim, interaction1="FR")  # try avAlt in a rival model

# Optional: time dummy on avSim during intervention period 2
eff_td <- includeTimeDummy(eff, effectName="avSim", name="TOL", interaction1="FR", timeDummy=2)

# 2) Estimation ----
alg <- sienaAlgorithmCreate(projname="tolerance_saom", useStdInits=TRUE)
fit1 <- siena07(alg, data=dat, effects=eff, batch=TRUE, returnDeps=TRUE)

# Continue to convergence if needed
while (summary(fit1)$tconv.max > 0.25 || any(abs(summary(fit1)$tstat) > 0.10)) {
  alg <- sienaAlgorithmCreate(projname="tolerance_saom_cont", useStdInits=FALSE)
  fit1 <- siena07(alg, data=dat, effects=eff, prevAns=fit1, batch=TRUE, returnDeps=TRUE)
}

# 3) Time heterogeneity test (keep only if supported)
# sienaTimeTest(fit1, effectsOfInterest)

# 4) GOF ----
gof_indeg <- sienaGOF(fit1, IndegreeDistribution, varName="FR",
                      cumulative=TRUE, levls=c(0:10,15,20,30))
gof_outdeg <- sienaGOF(fit1, OutdegreeDistribution, varName="FR",
                       cumulative=TRUE, levls=c(0:10,15,20,30))
gof_geo   <- sienaGOF(fit1, GeodesicDistribution, varName="FR")
gof_tri   <- sienaGOF(fit1, TriadCensus, varName="FR")

# 5) Counterfactual sims ----
alg_sim <- sienaAlgorithmCreate(projname="tolerance_sim", simOnly=TRUE)
simPaths <- siena07(alg_sim, data=dat, effects=eff, prevAns=fit1,
                    nsub=0, returnDeps=TRUE)


Inline comments and thresholds match the manual standards (convergence, effect syntax, GOF choices).
Convergence gates & continuation: 

RSiena_Manual

 

RSiena_Manual


Effect wiring for co-evolution & influence: 

RSiena_Manual


GOF menu & level settings: 

RSiena_Manual

What this adds beyond our earlier plan

Explicit structural coding (10/11/NA) and why it matters. 

RSiena_Manual

A strict, automated continue-to-convergence loop at manual thresholds. 

RSiena_Manual

Time-heterogeneity testing workflow tied to the intervention period. 

RSiena_Manual

GOF coverage (degree, geodesic, triads) with non-default support levels. 

RSiena_Manual

Forward simulation control for counterfactual design questions. 

RSiena_Manual

Guidance on outdegree limits under ML and avoiding fixed-choice traps. 

RSiena_Manual