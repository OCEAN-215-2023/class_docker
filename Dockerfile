ARG BASE_CONTAINER=jupyter/scipy-notebook:hub-3.1.1
FROM $BASE_CONTAINER

LABEL maintainer="Kathy Qi <klqi@uw.edu>"

# Base image includes: (https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-tensorflow-notebook)
# texlive, git, vi, nano, tzdata, unzip
# dask, pandas, numexpr, matplotlib, scipy, seaborn, scikit-learn,
# scikit-image, sympy, cython, patsy, statsmodels, cloudpickle, dill, numba,
# bokeh, sqlalchemy, hdf5, vincent, beautifulsoup, protobuf, xlrd, bottleneck,
# pytables, ipywidgets, ipympl, facets

RUN set -ex \
  && mamba install --quiet --yes \
  cartopy \  
  cmocean \
  cssselect \
  dropbox \
  hickle \
  jupyter-dash \
  jupyter-resource-usage \
  lxml \
  netcdf4 \
  'plotly==5.14.1' \
  plotnine \
  requests \
  shapely \
  selenium \
  textblob \
  uncertainties \ 
  xarray

RUN mamba clean --all -f -y \
  && jupyter lab build -y \
  && jupyter lab clean -y \
  && rm -rf "/home/${NB_USER}/.cache/yarn" \
  && rm -rf "/home/${NB_USER}/.node-gyp" \
  && fix-permissions "${CONDA_DIR}" \
  && fix-permissions "/home/${NB_USER}"

# Install Python 3 packages
RUN pip install \
  fuzzywuzzy \
  joblib \
  'nbclassic==0.3.7' \
  nbgitpuller \
  otter-grader \
  pqdm \
  pycmap \
  pyldavis \
  qgrid \
  requests-html \
  tqdm \
  unidecode && \
  jupyter serverextension enable nbgitpuller --sys-prefix


USER root

RUN apt-get update && apt-get install -y vim gcc openssh-client build-essential texlive-xetex texlive-fonts-recommended texlive-plain-generic

# RUN echo 'export LD_LIBRARY_PATH=/usr/local/nvidia/lib64' >> /etc/profile
# RUN echo 'export PATH=$PATH:/usr/local/nvidia/bin'>> /etc/profile
# COPY kernel.json /opt/conda/share/jupyter/kernels/python3/kernel.json

USER $NB_UID
