# Records

Plain CSV files, one row per item, appended as text. Never rewrite a whole file through a CSV library (it re-quotes
rows and makes a huge diff); to change one field, parse that one line, change the field, write that line back, and
check every row still has the same number of fields.

| File | One row per | ID format | Notes |
|---|---|---|---|
| `decisions.csv` | owner decision | `D-001` | `owner_words` quotes the owner exactly; `status` decided / superseded by D-xxx |
| `findings.csv` | bug or problem | `F-<AREA>-01` | `severity` P0 (live broken, money or data at risk) … P3 (cosmetic); `status` open / fixed / verified / won't fix (owner's decision) |
| `test_execution.csv` | test run that decided something | `LOCAL-<commit>-<check>` | `evidence_path` points into the local-data folder; `status` PASS / FAIL / NEUTRAL with a reason |

Before taking a new number, read the highest one in the file and check other branches:
`git grep -n "^F-CART-0" $(git for-each-ref --format="%(refname)" refs/heads) -- docs/records/findings.csv`.
