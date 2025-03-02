Predicting Weeks on Billboard for Rolling Stone's Top 500 Albums
Authors: Ritisha Jhamb, Aarav Mahajan, and Roy Chen

## **About**  

This project builds a regression model using the k-nearest neighbors (kNN) algorithm to predict the number of weeks an album spends on the Billboard chart (weeks_on_billboard). By leveraging data from Rolling Stone’s “500 Greatest Albums of All Time” rankings, alongside information such as Spotify popularity, peak Billboard position, and release year, we aim to identify the key factors that contribute to an album’s longevity on the charts.

---

## Report
You can view the **full analysis report** [here](imdb_analysis.ipynb).

---
##Usage
We use a Docker container to ensure a reproducible computational environment. There are two ways to execute the project:

###Non-Interactive Mode (Fully Automated Execution)

To run the analysis and generate results without manual intervention:
Clone this repository and navigate to the project root. Run the following Docker command in your terminal:

``
   docker run --rm \
  -p 8888:8888 \
  -v "$(pwd)":/opt/notebooks/billboard-chart-prediction \
  your-docker-image-name:v0.1.0 \
  jupyter nbconvert --to notebook --execute notebooks/imdb_analysis.ipynb``
  

###Interactive Mode (Exploring in Jupyter Lab)

- Navigate to the root of this repository (if not already there)
- Start the Docker container using `docker-compose`
- Copy the Jupyter Lab URL from the terminal output (it will look something like http://127.0.0.1:8888/lab?token=your_token).
- Paste the URL into your web browser.

Run the Notebook:
Navigate to notebooks/imdb_analysis.ipynb
Click Kernel > Restart & Run All to execute the entire analysis.
- Shut down the container when finished: `docker-compose down`

## Dependencies 

System Dependencies:

- Docker
- Git 
- R Dependencies:

- tidyr
- readr
- ggplot2
- dplyr
- caret
- lattice

Makefile Dependencies:

- GNU Make
- macOS: Comes pre-installed
- Linux: Install via sudo apt install make
- Windows: Use Git Bash or install Make for Windows


##Licenses: 




- a short summary of the project (view from 10,000 feet)
- - how to run your data analysis
  - - a list of the dependencies needed to run your analysis
    -  - the names of the licenses contained in LICENSE.md
