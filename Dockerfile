# Start with Jupyter base image
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_IMAGE=$REGISTRY/$OWNER/docker-stacks-foundation:2025-03-12

FROM $BASE_IMAGE

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Switch to root user to install everything
USER root

# Install system dependencies
RUN conda install mamba=2.0.5 -c conda-forge
RUN mamba install r-base=4.4 -c conda-forge && \
    mamba install zlib=1.3.1 -c conda-forge && \
    mamba install cmake=3.31.6 -c conda-forge && \
    mamba install quarto=1.6.40 -c conda-forge && \
    apt-get update && apt-get install -y libfontconfig1=2.15.0-1.1ubuntu2 && \
    quarto install tinytex

# Install R dependencies
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/remotes/remotes_2.4.2.tar.gz', repos = NULL, type = 'source')"
RUN R -e "remotes::install_version('IRkernel', '1.3.2', repos = 'https://cran.r-project.org')" && \
    R -e "remotes::install_version('tidyverse', '2.0.0', repos = 'https://cran.r-project.org')" && \
    R -e "remotes::install_version('lattice', '0.22-6', repos = 'https://cran.r-project.org')" && \
    R -e "remotes::install_version('docopt', '0.7', repos = 'https://cran.r-project.org', dependencies = TRUE)" && \
    R -e "remotes::install_version('gridExtra', '2.2.1', repos = 'https://cran.r-project.org', dependencies = TRUE)" && \
    R -e "remotes::install_version('knitr', '1.48', repos = 'https://cran.r-project.org', dependencies = TRUE)" && \
    R -e "remotes::install_version('ggpubr', '0.5.0', repos = 'https://cran.r-project.org', dependencies = TRUE)" && \
    R -e "remotes::install_version('caret', '6.0-94', repos = 'https://cran.r-project.org', dependencies = TRUE)"

# Allow jovyan user to use sudo without password
RUN echo "jovyan ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/jovyan

# Install Jupyter dependencies
WORKDIR /tmp
RUN mamba install --yes \
    'jupyterhub-singleuser=5.2.1' \
    'jupyterlab=4.3.5' \
    'nbclassic=1.2.0' \
    'notebook=7.3' && \
    jupyter server --generate-config && \
    mamba clean --all -f -y && \
    jupyter lab clean

# Create necessary directories for jovyan user
RUN mkdir -p /home/${NB_USER}/data && \
    mkdir -p /home/${NB_USER}/src && \
    mkdir -p /home/${NB_USER}/reports

# Install IRkernel for Jupyter
RUN R -e "IRkernel::installspec(user = FALSE)"

# Fix permissions
RUN fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}" && \
    fix-permissions "/home/${NB_USER}/data" && \
    fix-permissions "/home/${NB_USER}/src" && \
    fix-permissions "/home/${NB_USER}/reports"

USER ${NB_UID}

# Expose Jupyter port
ENV JUPYTER_PORT=8888
EXPOSE $JUPYTER_PORT

# Copy Jupyter notebooks and R scripts
COPY src/*.ipynb /home/${NB_USER}/src
COPY src/*.R /home/${NB_USER}/src/
COPY reports/*.qmd /home/${NB_USER}/reports/
COPY reports/*.bib /home/${NB_USER}/reports/
COPY Makefile /home/${NB_USER}
# Set working directory
WORKDIR "$HOME"

# Start JupyterLab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root"]
