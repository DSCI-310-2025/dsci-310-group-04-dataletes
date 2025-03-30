# Predicting Weeks on Billboard for Rolling Stone's Top 500 Albums

Authors: Ritisha Jhamb, Aarav Mahajan, and Roy Chen

## **About**  

This project builds a regression model using the k-nearest neighbors (kNN) algorithm to predict the number of weeks an album spends on the Billboard chart (weeks_on_billboard). By leveraging data from Rolling Stone’s “500 Greatest Albums of All Time” rankings, alongside information such as Spotify popularity, peak Billboard position, and release year, we aim to identify the key factors that contribute to an album’s longevity on the charts.

---

## Report
You can view the **full analysis report** [here](reports/rolling_stone_analysis.pdf).

---
## Usage
We use a Docker container to ensure a reproducible computational environment. There are two ways to execute the project:
  

### Interactive Mode (Exploring in Jupyter Lab)

- Start docker
- Go to your command line and type in: docker pull rchen34/dsci310-group-4:latest
- Run the docker image with: docker run -p 8888:8888 rchen34/dsci310-group-4:latest
- Open the notebook in your browser with the http://127.0.0.1:8888 link in the console output
- In the File tab, under the New dropdown, open a Terminal
- In the terminal type make all
- The visualizations and data are stored in the data folder
- The results of the knn model are stored in the results folder

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
- gridExtra
- ggpubr
- docopt
- knitr
- testthat
  
Makefile Dependencies:

- GNU Make
- macOS: Comes pre-installed
- Linux: Install via sudo apt install make
- Windows: Use Git Bash or install Make for Windows


## License:

This project is offered under the [Attribution 4.0 International (CC BY 4.0) License](https://creativecommons.org/licenses/by/4.0/).  
The software provided in this project is offered under the [MIT open source license](https://opensource.org/licenses/MIT).  
See the [`LICENSE.md`](LICENSE.md) file for more information.
