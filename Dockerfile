# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License
## modified for 2023 UW OCEAN 215 course.
ARG OWNER=jupyter
ARG BASE_CONTAINER=$OWNER/minimal-notebook
# root container (docker-stacks-foundation) uses ubuntu:22.04
FROM $BASE_CONTAINER

LABEL maintainer="Kathy Qi <klqi@uw.edu>"

# establish shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt-get update --yes && \
    apt-get install -y vim gcc openssh-client build-essential texlive-xetex texlive-fonts-recommended texlive-plain-generic \
    # apt-get install --yes --no-install-recommends 
    # for cython: https://cython.readthedocs.io/en/latest/src/quickstart/install.html
    build-essential \
    # for latex labels
    cm-super \
    dvipng \
    # for matplotlib anim
    ffmpeg && \
    apt-get clean && rm -rf /var/lib/apt/lists/* 
    #for vim
    #apt-get install -y vim gcc openssh-client build-essential texlive-xetex texlive-fonts-recommended texlive-plain-generic


USER ${NB_UID}

# mamba downgrades these packages to previous major versions, which causes issues
RUN echo 'jupyterlab >=4.0.4' >> "${CONDA_DIR}/conda-meta/pinned" && \
    echo 'notebook >=7.0.2' >> "${CONDA_DIR}/conda-meta/pinned"

# Install Python 3 packages
RUN mamba install --yes \
    'altair' \
    'beautifulsoup4' \
    'bokeh' \
    'bottleneck' \
    'cartopy' \
    'cloudpickle' \
    'conda-forge::blas=*=openblas' \
    'cmocean' \
    'cython' \
    'dask' \
    'dill' \
    'dropbox' \
    'h5py' \
    'ipympl'\
    'ipywidgets' \
    'jupyter-dash' \
    'jupyter-resource-usage' \
    'jupyterlab-git' \
    'matplotlib-base' \
    'netcdf4' \
    'numba' \
    'numexpr' \
    'openpyxl' \
    'pandas' \
    'patsy' \
    'plotly==5.17.0' \
    'protobuf' \
    'pytables' \
    'requests' \
    'scikit-image' \
    'scikit-learn' \
    'scipy' \
    'seaborn' \
    'shapely' \
    'sqlalchemy' \
    'statsmodels' \
    'sympy' \
    'widgetsnbextension'\
    'xarray'\
    'xlrd' && \
    mamba clean --all -f -y && \
    rm -rf "/home/${NB_USER}/.cache/yarn" && \
    rm -rf "/home/${NB_USER}/.node-gyp" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install Python 3 packages
RUN pip install \
  fuzzywuzzy \
  joblib \
  nbclassic \
  pqdm \
  pyldavis \
  pycmap \
  qgrid \
  requests-html \
  tqdm \
  unidecode

# Install facets which does not have a pip or conda package at the moment
WORKDIR /tmp
RUN git clone https://github.com/PAIR-code/facets && \
    jupyter nbclassic-extension install facets/facets-dist/ --sys-prefix && \
    rm -rf /tmp/facets && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}"

USER ${NB_UID}

WORKDIR "${HOME}"
