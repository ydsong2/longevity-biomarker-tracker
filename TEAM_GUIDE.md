
# 🧬 Longevity Biomarker Tracking System  — Team Guide

Welcome to the codebase!  This document tells you **who owns what, what each folder/file is for, and the 5-minute routine to spin everything up locally.**

---

## 1 · Team roles & areas of ownership

| Role                                      | Main goals                                                                     | Owns these paths                                     |
| ----------------------------------------- | ------------------------------------------------------------------------------ | ---------------------------------------------------- |
| **Database Architect (@db-architect)**    | • Keep the physical schema in 3 NF<br>• Produce the ER diagram PDF/PNG         | `/sql/`,  `/docs/er_diagram.*`                       |
| **Data Engineer (@data-engineer)**        | • Pull NHANES XPT files<br>• Clean → CSVs\n• Bulk-load into MySQL              | `/etl/`, `/data/raw/`, `/data/clean/`, `/notebooks/` |
| **Backend Lead (@backend-lead)**          | • Turn the FastAPI stubs into real endpoints<br>• Unit-test business logic     | `/src/api/`, `/tests/`                               |
| **Analytics / UI Lead (@analytics-lead)** | • Build interactive dashboard in Streamlit<br>• Deliver simple charts & tables | `/src/ui/`, `/src/analytics/`                        |

> **Branch etiquette**
> *One feature = one branch*.  Open a PR, request review from whoever’s code you touch.  CI must be green before merge.

---

## 2 · Repository tour

```
├── sql/                 ← single source-of-truth DDL (schema + seed data)
├── etl/
│   ├─ download_nhanes.py  ← grabs raw XPTs
│   ├─ transform.ipynb     ← ⚠️ placeholder; clean & join data here
│   └─ load.sh             ← LOAD DATA INFILE → MySQL
├── data/
│   ├─ raw/    ← large XPTs land here (git-ignored)
│   └─ clean/  ← CSVs ready for LOAD INFILE (git-ignored)
├── src/
│   ├─ api/          ← FastAPI app (currently minimal stubs)
│   ├─ analytics/    ← helper modules for stats / plots
│   └─ ui/           ← Streamlit dashboard (placeholder “Hello”)
├── tests/           ← PyTest suite (API + DB fixtures)
├── docker-compose.yml  ← MySQL 8 (port 3307) + Adminer
├── Makefile          ← one-word workflows (`make db`, `make run`, …)
├── .env.example      ← copy → .env ; local config lives here
├── .github/workflows/ci.yml  ← GH Actions: MySQL + API + tests
├── .pre-commit-config.yaml   ← black, flake8, sqlfluff, etc.
└── docs/
    └─ er_diagram_placeholder.md
```

**Placeholders**

* Anything that returns fixed/dummy JSON (FastAPI, Streamlit) is just scaffolding—replace at will.
* `transform.ipynb` currently does nothing except have an empty code cell; build your ETL there.

---

## 3 · Getting started locally (≈ 5 minutes)

> **Prereqs:** Docker Desktop, Python 3.11+, `pip install pre-commit`.

```bash
# 1.  Clone & enter repo
git clone https://github.com/randaldrew/longevity-biomarker-tracker
cd longevity-biomarker-tracker

# 2.  Personal env settings
cp .env.example .env        # adjust only if you really need to

# 3.  Start database (MySQL 8 on localhost:3307) + Adminer (localhost:8080)
make db

# 4.  (Data engineer only)  Download → transform → load sample data
make etl                    # safe to run; skips if CSVs missing

# 5.  Fire up services
make run                    # FastAPI hot-reload on http://localhost:8000
make ui                     # Streamlit dashboard on http://localhost:8501

# 6.  Sanity check tests & style
pre-commit install          # run once
pytest -q                   # should pass six stub tests
```

*Adminer login:*
**System** MySQL, **Server** db (inside docker) or 127.0.0.1:3307, **User** biomarker\_user, **PW** biomarker\_pass, **DB** longevity.

---

## 4 · Daily workflow cheatsheet

| Action                         | Command                          |
| ------------------------------ | -------------------------------- |
| Start DB + API + UI            | `make db && make run && make ui` |
| Reset schema after edits       | `make db-reset`                  |
| Download / refresh NHANES      | `make etl`                       |
| Run all tests                  | `make test`                      |
| Lint & format all files        | `pre-commit run --all-files`     |
| Stop everything & wipe volumes | `make clean`                     |

---

## 5. Adminer login:

*Adminer login:*
**System** MySQL, **Server** db (inside docker) or 127.0.0.1:3307, **User** biomarker_user, **PW** biomarker_pass, **DB** longevity.
Access Adminer at [http://localhost:8080](http://localhost:8080).

### Have questions?

*Open a GitHub Discussion or ping the owner of the folder you’re touching.*  Let’s build something great—happy coding!
