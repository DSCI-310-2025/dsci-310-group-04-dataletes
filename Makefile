.PHONY: clean all

all:    clean \
	data/raw/rolling_stone.csv \
	data/processed/cleaned_data.csv \
	data/visualizations.png \
	validate \
	results \
	reports/analysis.html \
	reports/analysis.pdf


# download the data from the web
data/raw/rolling_stone.csv: 
	Rscript src/01_download.R https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2024/2024-05-07/rolling_stone.csv data/raw/rolling_stone.csv

# clean the downloaded data
data/processed/cleaned_data.csv: data/raw/rolling_stone.csv
	Rscript src/02_clean.R data/raw/rolling_stone.csv data/processed/cleaned_data.csv

validate: 
	Rscript src/03_validate.R data/processed/cleaned_data.csv

data/visualizations.png: data/processed/cleaned_data.csv
	Rscript src/04_visualize.R data/processed/cleaned_data.csv data/visualizations.png

results: data/processed/cleaned_data.csv
	Rscript src/05_model.R data/processed/cleaned_data.csv results

# render quarto report in HTML and PDF
reports/analysis.html: data/visualizations.png results reports/output.txt
	quarto render reports/analysis.qmd --to html

reports/analysis.pdf: data/visualizations.png results reports/output.txt
	quarto render reports/analysis.qmd --to pdf

# clean
clean:
	rm -rf results
	rm -rf data/*
	rm -rf reports/analysis.html \
		reports/analysis.pdf \
		reports/analaysis_files \
		reports/output.txt
