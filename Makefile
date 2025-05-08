.PHONY: db etl test run ui clean help

help:
	@echo "Longevity Biomarker Tracker"
	@echo ""
	@echo "make db       - Start MySQL database"
	@echo "make etl      - Run ETL process (download, transform, load)"
	@echo "make test     - Run tests"
	@echo "make run      - Start API server"
	@echo "make ui       - Start UI dashboard"
	@echo "make clean    - Remove all data and containers"

install:
	pip install -r requirements.txt
	pre-commit install

db:
	docker compose up -d db adminer

etl:
	python etl/download_nhanes.py
	@if [ -f etl/transform.ipynb ] && [ -s etl/transform.ipynb ]; then \
		jupyter nbconvert --execute etl/transform.ipynb --to notebook --inplace || echo "[WARN] Failed to execute transform.ipynb - continuing anyway"; \
	else \
		echo "[WARN] transform.ipynb not found or empty — skipping transform step"; \
	fi
	bash etl/load.sh

test:
	pytest tests/

run:
-    # pass shell env straight through
-    cd src/api && uvicorn main:app --reload --host $$APP_API_HOST --port $$APP_API_PORT
+	# pass shell env straight through          ← this leading char is a TAB
+	cd src/api && uvicorn main:app --reload --host $$APP_API_HOST --port $$APP_API_PORT



ui:
	cd src/ui && streamlit run app.py

clean:
	docker compose down -v
	rm -rf data/raw/* data/clean/*

db-reset:
	docker compose exec db mysql -u$(MYSQL_USER) -p$(MYSQL_PASSWORD) $(MYSQL_DATABASE) < sql/schema.sql
