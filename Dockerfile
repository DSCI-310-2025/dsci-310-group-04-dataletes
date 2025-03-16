# Start with Jupyter base image
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_IMAGE=$REGISTRY/$OWNER/docker-stacks-foundation:2025-03-12

FROM $BASE_IMAGE

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Switch to root user to install everything
USER root

# Install R
RUN conda install mamba=2.0.5 -c conda-forge && \
    conda install r-base=4.4 -c conda-forge
# Get build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    r-base-dev
# Install R dependencies

# Install remotes package
RUN R -e "install.packages('remotes', repos='https://cran.r-project.org')"
# Install specific versions of R dependencies
RUN R -e "remotes::install_version('IRkernel', '1.3.2', repos = 'https://cran.r-project.org')" && \
    #tidyverse contains dyplyr tydyr and ggplot2
    R -e "remotes::install_version('tidyverse', '2.0.0', repos = 'https://cran.r-project.org')" && \
    R -e "remotes::install_version('lattice', '0.22-6', repos = 'https://cran.r-project.org')" && \
# I could not figure out how to install caret using remotes, I think it's impossible
    R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/caret/caret_6.0-94.tar.gz', repos = NULL, type = 'source')" && \
    R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/docopt/docopt_0.7.tar.gz', repos = NULL, type = 'source')" && \
    R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/ggpubr/ggpubr_0.5.0.tar.gz', repos = NULL, type = 'source')" && \
    R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/gridExtra/gridExtra_2.2.1.tar.gz', repos = NULL, type = 'source')" && \
    R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/knitr/knitr_1.48.tar.gz', repos = NULL, type = 'source')"

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
RUN mkdir -p /home/${NB_USER}/data
RUN mkdir -p /home/${NB_USER}/src
RUN mkdir -p /home/${NB_USER}/results
RUN R -e "IRkernel::installspec(user = FALSE)"
RUN fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}" && \
    fix-permissions "/home/${NB_USER}/data" && \
    fix-permissions "/home/${NB_USER}/src" && \
    fix-permissions "/home/${NB_USER}/results"

USER ${NB_UID}

# Expose Jupyter port
ENV JUPYTER_PORT=8888
EXPOSE $JUPYTER_PORT

# Copy Jupyter notebooks and make directories
COPY src/*.ipynb /home/${NB_USER}/src
# Copy R scripts and make directories
COPY src/*.R /home/${NB_USER}/src/
# Set working directory
WORKDIR "$HOME"

# Start JupyterLab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root"]