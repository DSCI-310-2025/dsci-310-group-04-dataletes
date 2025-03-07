# Start with Jupyter base image
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_IMAGE=$REGISTRY/$OWNER/docker-stacks-foundation
FROM $BASE_IMAGE

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Switch to root user to install everything
USER root

# Install R
RUN apt-get update && \
    apt-get install -y --no-install-recommends\
    r-base \
    r-base-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install R dependencies
RUN R -e "install.packages(c('IRkernel', 'tidyr', 'readr', 'ggplot2', 'caret', 'lattice'), repos='http://cran.r-project.org')"
# Install Jupyter dependencies
WORKDIR /tmp
RUN mamba install --yes \
    'jupyterhub-singleuser' \
    'jupyterlab' \
    'nbclassic' \
    'notebook>=7.2.2' && \
    jupyter server --generate-config && \
    mamba clean --all -f -y && \
    jupyter lab clean
RUN mkdir -p /home/${NB_USER}/data
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