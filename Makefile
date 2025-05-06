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

db:
	docker compose up -d db adminer

etl:
	python etl/download_nhanes.py
	jupyter nbconvert --execute etl/transform.ipynb --to notebook --inplace
	bash etl/load.sh

test:
	pytest tests/

run:
	cd src/api && uvicorn main:app --reload --host $(API_HOST) --port $(API_PORT)

ui:
	cd src/ui && streamlit run app.py

clean:
	docker compose down -v
	rm -rf data/raw/* data/clean/*
