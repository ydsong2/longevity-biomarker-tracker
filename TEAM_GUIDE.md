
# 🧬 Longevity Biomarker Tracking System — Team Guide (v0.4)

Welcome to the repo! This page is the **source‑of‑truth for who owns what, what lives where, and the 5‑minute routine to spin everything up locally.**

---

## 1 · Team roles & areas of ownership

|  Role                                     |  Main goals                                                  |  Owns these paths                                     |
| ----------------------------------------- | ------------------------------------------------------------ | ----------------------------------------------------- |
| **Database Architect (@db‑architect)**    |  • keep the schema in 3 NF  • publish the ER diagram         |  `/sql/`, `/docs/er_diagram.*`                        |
| **Data Engineer (@data‑engineer)**        |  • pull NHANES XPTs  • clean → CSVs  • bulk‑load into MySQL  |  `/etl/`, `/data/raw/`, `/data/clean/`, `/notebooks/` |
| **Backend Lead (@backend‑lead)**          |  • convert FastAPI stubs to real endpoints  • add unit tests |  `/src/api/`, `/tests/`                               |
| **Analytics / UI Lead (@analytics‑lead)** |  • build Streamlit dashboard  • charts & tables              |  `/src/ui/`, `/src/analytics/`                        |

> **Branch etiquette**  → *One feature = one branch.* Open a PR, request review from anyone whose code you touch. **CI must be green** before merge.

---

## 2 · Repository tour (birds‑eye view)

```
├── sql/                 ← DDL (schema + seed data)
├── etl/                 ← download → transform → load pipeline
│   ├─ download_nhanes.py
│   ├─ transform.ipynb   ← ⚠️ placeholder
│   └─ load.sh
├── data/
│   ├─ raw/    ← large XPTs (git‑ignored)
│   └─ clean/  ← CSVs ready for LOAD INFILE (git‑ignored)
├── src/
│   ├─ api/          ← FastAPI app
│   ├─ analytics/    ← helper modules for stats / plots
│   └─ ui/           ← Streamlit dashboard
├── tests/           ← pytest suite
├── docker-compose.yml  ← MySQL 8 + Adminer
├── Makefile          ← one‑word workflows (`make db`, …)
├── .env.example      ← copy → .env ; local config lives here
├── .github/workflows/ci.yml ← GitHub Actions (DB + API + tests)
└── docs/             ← diagrams & additional docs
```

### 2b · File‑by‑file cheat‑sheet

| Path                       | What it is / Why it matters                                                                                                             |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `sql/schema.sql`           | Single source‑of‑truth DDL + seed inserts. All migrations are manual edits to this file.                                                |
| `etl/download_nhanes.py`   | Pulls raw NHANES XPT files for the 2017‑2018 cycle to `data/raw/`.                                                                      |
| `etl/transform.ipynb`      | **TODO:** Data Engineer cleans & joins XPTs → four CSVs in `data/clean/`. Notebook executes headless via `nbconvert` during `make etl`. |
| `etl/load.sh`              | Uses `LOAD DATA LOCAL INFILE` to bulk‑insert the clean CSVs. Also writes a tiny relational sample dump for CI.                          |
| `docker-compose.yml`       | Spins up MySQL 8 (port 3307) + Adminer 4 (port 8080). DB initialises from `sql/` at first boot.                                         |
| `Makefile`                 | Quick commands: `make db`, `make etl`, `make run`, `make ui`, `make test`, etc. The `run` target now defaults to `127.0.0.1:8000`.      |
| `src/api/main.py`          | FastAPI entry‑point (currently returns stub JSON). Hot‑reload via `make run`.                                                           |
| `src/ui/app.py`            | Streamlit dashboard scaffolding; checks API health on the Home page.                                                                    |
| `tests/`                   | `conftest.py` sets up DB + API fixtures. `test_api.py` hits stub endpoints to ensure the stack is alive.                                |
| `.github/workflows/ci.yml` | GitHub Action: spins up MySQL service → loads schema & sample data → runs tests → schema diff check to catch un‑committed DDL edits.    |
| `.pre-commit-config.yaml`  | Black, flake8, trailing whitespace, YAML linting. Auto‑installed by `make install`.                                                     |
| `codebase_snapshot.sh`     | Utility to create a gist‑friendly snapshot excluding big binaries—no need to run during normal dev.                                     |

---

## 3 · Getting started locally (≈ 5 minutes)

> **Prereqs:** Docker Desktop, Python 3.11+, `pip install pre-commit`.

```bash
# 1 · Clone
git clone https://github.com/<org>/longevity-biomarker-tracker
cd longevity-biomarker-tracker

# 2 · Personal env vars
cp .env.example .env   # edit only if you need custom ports

# 3 · Install deps & git hooks
make install           # pip + pre‑commit

# 4 · Launch database (MySQL :3307) + Adminer (:8080)
make db

# 5 · ( Data Engineer ) download → transform → load sample data
make etl               # safe to run; skips if CSVs missing

# 6 · Fire up services
make run               # FastAPI hot‑reload on http://127.0.0.1:8000
make ui                # Streamlit on http://127.0.0.1:8501

# 7 · Sanity check tests & style
pytest -q              # all dots
pre-commit run --all-files
```

---

## 4 · Daily workflow cheatsheet

| Action                         | Command                          |
| ------------------------------ | -------------------------------- |
| Start DB + API + UI            | `make db && make run && make ui` |
| Reset schema after SQL edits   | `make db-reset`                  |
| Download / refresh NHANES      | `make etl`                       |
| Run all tests                  | `make test`                      |
| Lint & format                  | `pre-commit run --all-files`     |
| Stop everything & wipe volumes | `make clean`                     |

---

## 5 · Adminer login (GUI DB client)

* **URL:** [http://localhost:8080](http://localhost:8080)
* **System:** MySQL
* **Server:** `db` (inside docker) or `127.0.0.1:3307`
* **User:** `biomarker_user`   **PW:** `biomarker_pass`
* **Database:** `longevity`

---

## 6 · FAQ (extended)

<details><summary><strong>Why do I need a PR just to push a notebook?</strong></summary>
Because CI runs on every PR. That guarantees the DB schema, tests, and code style stay in sync. A quick notebook tweak can still break the build if it changes repo‑wide imports—better to catch it before merge.
</details>

<details><summary><strong>Can I use React or Shiny instead of Streamlit?</strong></summary>
Sure!  The UI lead should feel free to use their preferred tools.  Just mention on Slack and please build in the following minimal
code to show that it connects to the rest of the repo.
1. Adds the minimal scaffold for the new tool.
2. Passes pre‑commit + pytest + CI.
3. Includes a README note on how to run it.
</details>

<details><summary><strong>Help! Another service is already using port 3307 / 8000 / 8501.</strong></summary>
Edit `.env`, change `MYSQL_PORT`, `APP_API_PORT`, or Streamlit’s port in `Makefile` (`make ui` target). Then restart `make db` / `make run`.
</details>

<details><summary><strong>Pre‑commit reformats my file—what’s the policy?</strong></summary>
Anything auto‑changed by pre‑commit (black, flake8 fixes) should simply be committed. If you disagree with a rule, open a Discussion with an example.
</details>

<details><summary><strong>How do we add a Python dependency?</strong></summary>
1. Add it to `requirements.txt` (pin exact version).
2. `pip install -r requirements.txt` and ensure `pre-commit run --all-files` is still green.
3. Push a PR; CI will build a fresh environment and verify nothing breaks.
</details>

<details><summary><strong>Tests need real data but the CSVs are big. What’s the strategy?</strong></summary>
`load.sh` creates a tiny relational dump (`tests/sample_dump.sql`) with < 1 MB of data selected from the latest 10 users. CI restores that to keep test runs fast.
</details>

---

Let’s build something great—happy coding! 🎉
