# CITS4407 – Assignment 2  
**Board Games or Bored Games: Data-Cleaning & Analysis**  
Author : \<23911598\Terran Deng>  
Date   : \<18/05/2025>

---

## 1  Project Overview
This repository contains **three top-level Bash scripts**—`empty_cells`, `preprocess`, and `analysis`—that together clean, validate, and analyse the “BoardGameGeek” dataset supplied for Assignment 2.

| Script | Purpose | Typical Input | Typical Output |
|--------|---------|--------------|----------------|
| `empty_cells`   | Count empty (missing) cells per column in **raw** `.txt` files (semicolon-delimited). | `*.txt` | list of “\<column\>: \<count\>” |
| `preprocess` | Convert raw dataset to a clean **TAB-delimited `.tsv`**, normalising decimal commas, CRLF, non-ASCII characters, and blank IDs.  Rows whose field-count deviates from the header are silently skipped. | `*.txt` | cleaned `*.tsv` |
| `analysis` | Using the cleaned TSV, answers four research questions: most-popular mechanics, most-popular domains, Pearson _r_ (Year vs Rating), Pearson _r_ (Complexity vs Rating).  Handles case-folding, per-game de-duplication, plural grammar, and correlation edge cases. | cleaned `*.tsv` | four human-readable lines |

---

## 2  Directory Layout
assignment2/
├── empty_cells # ← executable script
├── preprocess # ← executable script
├── analysis # ← executable script
├── README.md # ← this file
└── .git/ # full history (multiple commits, descriptive messages)

## 3  Prerequisites

* GNU coreutils (tested on Ubuntu 22.04 / course Docker image)  
* `awk` (GNU Awk 5.1)  
* Bash 4 or newer  
* No external libraries or Python required.

---

## 4  Setup & Quick Start

```bash
# 1. Make scripts executable
chmod +x empty_cells preprocess analysis

# 2. Count missing cells in the raw dataset
./empty_cells bgg_dataset.txt ';'

# 3. Produce a cleaned TSV
./preprocess  bgg_dataset.txt > bgg_dataset.tsv

# 4. Analyse the cleaned data
./analysis    bgg_dataset.tsv
```

Expected terminal output (numbers may vary slightly with dataset version):
```
The most popular game mechanics are Dice Rolling found in 5672 games
The most popular game domains are Wargames found in 3316 games
The correlation between the year of publication and the average rating is 0.081
The correlation between the complexity of a game and its average rating is 0.481
```

## 5 Script Reference

5.1  empty_cells
    Usage: empty_cells <file> [separator]
           separator defaults to ';'

    - Verifies file exists, is readable and non-empty.
    - Reads the header, then counts per-column empty fields in a single awk pass.
    - Treats “missing field” (row shorter than header) as empty.
    - Outputs one line per column in original order:  <Column>: <count>

------------------------------------------------------------

5.2  preprocess
    Usage: preprocess <raw-file.txt>  > clean.tsv

    Pipeline:
      1. Convert CRLF to LF; strip UTF-8 BOM.
      2. Change ';' to TAB on ALL rows, including header.
      3. Convert numeric commas: 3,5 → 3.5  (only if cell matches [0-9]+,[0-9]+)
      4. Remove non-ASCII characters.
      5. Fill blank IDs with max(existing_ID)+1, +2, ...
      6. Skip any data row whose field count differs from the header.

------------------------------------------------------------

5.3  analysis
    Usage: analysis <clean-file.tsv>

    Features:
      • Mechanics & Domains
          – Split on commas, trim spaces, fold to lower-case.
          – De-duplicate per game so each game counts max once per mechanic/domain.

      • Pearson correlation
          – Year Published  vs  Rating Average
          – Complexity Avg  vs  Rating Average
          – Requires ≥2 valid rows and non-constant variables;
            otherwise prints:  data insufficient to calculate correlation coefficient

      • Output wording
          – Automatic “is/are” and “game/games” grammar.
          – Example:
              The most popular game mechanics are Hand Management found in 1913 games

## 6  Testing Guide

   Provided samples:
     tiny_sample.*  – matches tiny_sample.xls, correlations compute
     sample1.*      – new IDs generated; analysis still correct
     bgg_dataset.txt – runtime < 30 s in course Docker; output as in §3

   Quick smoke test:
     ./empty_cells tests/tiny_sample.txt ';' | grep '/ID'
     ./preprocess  tests/tiny_sample.txt > /tmp/tiny.tsv
     diff -u /tmp/tiny.tsv tests/tiny_sample.tsv
     ./analysis    /tmp/tiny.tsv
    

## 7  Design Decisions
• Header order is trusted once the separator is fixed.
• Implemented entirely with POSIX/GNU tools → zero external deps.
• Malformed rows are dropped (per assignment allowance).
• Non-ASCII stripped for portability; no transliteration.

## 8 Known Limitations
1. preprocess quietly drops malformed rows (no verbose flag yet).
2. Only Pearson correlation required; Spearman/Kendall not implemented.
3. Uses GNU Awk feature PROCINFO["sorted_in"]; BusyBox awk may differ.
