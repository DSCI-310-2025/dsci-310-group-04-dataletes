all: data/rolling_stone.csv \
	data/cleaned_data.csv \
	data/visualizations.png \
	results/



# download the data from the web
data/rolling_stone.csv: 
	Rscript src/download.R https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2024/2024-05-07/rolling_stone.csv data/rolling_stone.csv

# clean the downloaded data
data/cleaned_data.csv: data/rolling_stone.csv
	Rscript src/clean.R data/rolling_stone.csv data/cleaned_data.csv

# create a png of the visualizations
data/visualizations.png: data/cleaned_data.csv 
	Rscript src/visualize.R data/cleaned_data.csv data/visualizations.png

# create and visualize the knn model
results/: data/cleaned_data.csv
	Rscript src/model.R data/cleaned_data.csv results

# render quarto report in HTML and PDF
reports/analysis.html: data/visualizations.png results reports/analysis.qmd
	quarto render reports/qmd_example.qmd --to html

reports/analysis.pdf: data/visualizations.png results reports/analysis.qmd
	quarto render reports/qmd_example.qmd --to pdf

# clean
clean:
	rm -rf results
	rm -rf data/*
	rm -rf reports/qmd_example.html \
		reports/qmd_example.pdf \
		reports/qmd_example_files
