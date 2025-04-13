.PHONY: clean all

all:    clean \
	data/rolling_stone.csv \
	data/cleaned_data.csv \
	data/visualizations.png \
	results \
	reports/analysis.html \
	reports/analysis.pdf


# download the data from the web
data/rolling_stone.csv: 
	Rscript src/download.R https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2024/2024-05-07/rolling_stone.csv data/raw/rolling_stone.csv

# clean the downloaded data
data/cleaned_data.csv: data/raw/rolling_stone.csv
	Rscript src/clean.R data/raw/rolling_stone.csv data/cleaned/cleaned_data.csv

# create a png of the visualizations
data/visualizations.png: data/cleaned/cleaned_data.csv
	Rscript src/visualize.R data/cleaned/cleaned_data.csv data/visualizations.png

# create and visualize the knn model
results: data/cleaned/cleaned_data.csv
	Rscript src/model.R data/cleaned/cleaned_data.csv results

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
