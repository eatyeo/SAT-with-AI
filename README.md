# SAT-with-AI

An end-to-end Mathematica pipeline that automates the structured analytic 
technique of Analysis of Competing Hypotheses (ACH) as described in 
Beebe & Pherson (2015) *Cases in Intelligence Analysis*, using the 
Google Gemini API.

## Overview

This pipeline takes a plain-text case narrative and produces:
- A ranked evidence vault with hallucination filtering
- A Multiple Hypotheses Generator (MHG) permutation tree with credibility scores
- An AI-scored ACH matrix sorted by diagnosticity
- A heatmap visualization with hypothesis and diagnosticity legends
- An assumption audit log surfacing key assumptions behind contested ratings

## File Structure
```
SAT-with-AI/
├── Core_API_Functions.wl                # API wrapper, rate limiter, shared config
├── case.txt                             # Input: plain-text case narrative
├── 01_Data_Ingestion.nb                 # Evidence extraction and deduplication
├── 01.5_Hypothesis_Generation_Tree.nb   # MHG permutation tree
├── 02_Matrix_Logic.nb                   # ACH matrix scoring
├── 03_Visualization_and_Report.nb       # Heatmap and export
└── Vault/                               # Auto-generated outputs
    ├── central_question.md
    ├── evidence_vault.md
    ├── evidence_hallucinations.md
    ├── target_hypotheses.md
    ├── permutation_scores.md
    ├── assumption_audit.md
    ├── ai_scored_matrix.md
    ├── ai_scored_matrix.json
    ├── Permutation_Tree_Master.pdf
    └── ACH_Final_Heatmap.pdf
```

## Setup

1. Place your case narrative in `case.txt`
2. Open `Core_API_Functions.wl` — no configuration needed, paths resolve automatically
3. Connect your Gemini API key via Mathematica's `ServiceConnect["GoogleGemini"]`
4. Run notebooks in order: 01 → 01.5 → 02 → 03

## Pipeline

**NB01 — Data Ingestion**  
Calls Gemini 5 times at varied temperatures, clusters outputs to filter 
hallucinations, deduplicates semantically, and extracts the central 
analytical question.

**NB01.5 — Hypothesis Generation + Permutation Tree**  
Implements the Beebe & Pherson MHG: AI identifies analytical dimensions 
and options, Mathematica generates all permutations via `Tuples`, AI scores 
each 1–5 or discards. Survivors become hypotheses. Exports a multi-level 
permutation tree visualization.

**NB02 — Matrix Logic**  
Scores all evidence against all hypotheses in batches of 10 to prevent 
truncation. Runs a second pass to surface key assumptions behind 
contested ratings.

**NB03 — Visualization**  
Produces a heatmap sorted by diagnosticity with dynamic row height, 
full evidence labels, and consolidated bottom legends.

## Validation

Tested against the *Death in the Southwest* case (Beebe & Pherson 2015, Ch. 9).  
The pipeline correctly identifies the leading hypothesis (naturally occurring 
infectious pathogen primarily affecting the Navajo population) consistent with 
the real-world outcome (hantavirus, 1993).

**Known limitations**  
- The MHG step may not reliably generate commonsense prior hypotheses
  (e.g. common flu), and intentional scenarios are sometimes over-discarded
  at permutation scoring. Both reflect LLM salience bias, in tension with
  ACH's requirement for an exhaustive hypothesis space. Analyst review is
  recommended after NB01.5 before proceeding.
- The consensus filter trades completeness for reliability: clustering
  favours evidence that recurs across samples, which suppresses
  hallucinations but biases the evidence set toward the dominant
  interpretation.
- Scoring runs at temperature 0.2 but may still vary between runs; the
  assumption audit log records the reasoning behind each contested rating.
- Validated against a single case; external validity is limited.

## Dependencies

- Mathematica 14.3+
- Google Gemini API (`gemini-2.5-flash`) via Mathematica ServiceConnect

## Reference

Beebe, S. M., & Pherson, R. H. (2015). *Cases in intelligence analysis: 
Structured analytic techniques in action* (2nd ed.). CQ Press.
