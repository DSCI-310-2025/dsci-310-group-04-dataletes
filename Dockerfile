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

# Install R dependencies

# Install remotes package
RUN R -e "install.packages('remotes', repos='https://cran.r-project.org')"
# Install specific versions of R dependencies
RUN R -e "remotes::install_version('IRkernel', '1.3.2', repos = 'https://cran.r-project.org')" && \
    R -e "remotes::install_version('tidyverse', '2.0.0', repos = 'https://cran.r-project.org')" && \
    R -e "remotes::install_version('lattice', '0.22-6', repos = 'https://cran.r-project.org')" && \
# I could not figure out how to install caret using remotes, I think it's impossible
    R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/caret/caret_6.0-94.tar.gz', repos = NULL, type = 'source')" && \
    R -e "install.packages('docopt')" && \
    R -e "install.packages('ggplot2')" && \
    R -e "install.packages('ggpubr')" && \
    R -e "install.packages('gridExtra')" && \
    R -e "install.packages('grid')" && \
    R -e "install.packages('knitr')"

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
RUN mkdir -p /home/${NB_USER}/results
RUN R -e "IRkernel::installspec(user = FALSE)"
RUN fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}" && \
    fix-permissions "/home/${NB_USER}/data"


USER ${NB_UID}

# Expose Jupyter port
ENV JUPYTER_PORT=8888
EXPOSE $JUPYTER_PORT

# Copy Jupyter notebooks and make directories
COPY *.ipynb /home/${NB_USER}/

# Set working directory
WORKDIR "${HOME}"

# Start JupyterLab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root"]