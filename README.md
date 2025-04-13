# Predicting Weeks on Billboard for Rolling Stone's Top 500 Albums

Authors: Ritisha Jhamb, Aarav Mahajan, and Roy Chen

## **Summary**

This project builds a regression model using the k-nearest neighbors (kNN) algorithm to predict the number of weeks an album spends on the Billboard chart, using features such as release year, peak chart position, and Spotify popularity. Drawing on Rolling Stone’s "500 Greatest Albums of All Time" dataset, we aim to uncover patterns that explain an album's chart longevity.

Our final model achieved a Root Mean Squared Error (RMSE) of approximately **74.71 weeks**, while the interquartile range of the target variable (`weeks_on_billboard`) is around **50 weeks**, indicating considerable variance and room for improvement. The model explains about **13.95% of the variability**, suggesting only weak linear relationships between predictors and the response.

Interestingly, the strongest positive correlation was with **Spotify popularity**, reinforcing the intuition that streaming relevance maps well to chart success. The weakest was with **artist experience** (measured as the years since debut), which challenges the common belief that veteran artists consistently produce more commercially successful music.

These findings suggest that popularity and exposure may outweigh experience in predicting chart success — a takeaway with potential implications for record labels, marketing teams, and emerging artists alike.


------------------------------------------------------------------------

## Report

The **full analysis report** can be viewed [here](reports/analysis.pdf).

------------------------------------------------------------------------

## Usage

We use a Docker container to ensure a reproducible computational environment. Here is how to execute the project:

### Interactive Mode (Exploring in Jupyter Lab)

-   Start Docker Desktop.
-   Open a terminal and type in: `docker pull rchen34/dsci310-group-4:latest`
-   Run the Docker image with: `docker run -p 8888:8888 rchen34/dsci310-group-4:latest`
-   Open the notebook in a browser using the URL from the console output (e.g., `http://127.0.0.1:8888`)
-   In the File tab, under the New dropdown, open a Terminal.
-   In the terminal, type: `make`
-   The raw and cleaned data files can be found in `data/raw` and `data/processed` directories, respectively.
-   Visualizations of the summary statistics of the downloaded rolling stone dataset are created in the data folder.
-   A table of the knn model's performance is created in the results folder along with a sample of the testing and training datasets.
-   The final reports are created in the reports folder and are called analysis.pdf and analysis.html.
-   The Rscripts for testing purposes are located in the tests/testthat directory.

## Makefile Usage

You can use the `Makefile` to automate your workflow. Below are the available targets:

-   `make all`\
    Runs the full analysis pipeline: downloads the data, cleans it, generates visualizations and results, and renders the final reports in both HTML and PDF.

-   `make clean`\
    Removes all generated files including `data/`, `results/`, and the Quarto reports to reset the project workspace.

-   `make data/raw/rolling_stone.csv`\
    Downloads the Rolling Stone dataset from TidyTuesday.

-   `make data/processed/cleaned_data.csv`\
    Cleans the downloaded dataset and saves it to the `data/processed/` directory.

-   `make validate`\
    Peforms 8 validation checks on the data and prints out a clear message indicating results.

-   `make data/visualizations.png`\
    Generates a PNG image of exploratory visualizations using the cleaned dataset.

-   `make results`\
    Trains the kNN model and saves the model performance output.

-   `make reports/analysis.html` or `make reports/analysis.pdf`\
    Renders the final analysis report in HTML or PDF format using Quarto.

> Note: Run all `make` commands from the project root directory.

## Dependencies

System Dependencies:

-   Docker

-   Git

R Dependencies:

-   tidyr

-   readr

-   ggplot2

-   dplyr

-   caret

-   lattice

-   gridExtra

-   ggpubr

-   docopt

-   knitr

-   testthat

Makefile Dependencies:

-   GNU Make
    -   macOS: Comes pre-installed
    -   Linux: Install via sudo apt install make
    -   Windows: Use Git Bash or install Make for Windows

## License:

This project is offered under the [Attribution 4.0 International (CC BY 4.0) License](https://creativecommons.org/licenses/by/4.0/).\
The software provided in this project is offered under the [MIT open source license](https://opensource.org/licenses/MIT).\
See the [`LICENSE.md`](LICENSE.md) file for more information.
