ARG PYTHON_VERSION=3.8
FROM python:${PYTHON_VERSION}-bullseye as main

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    git \
    libsndfile1 \
    build-essential \
    g++ \
    cmake

RUN python -m pip install -U pip wheel && python -m pip install torch==1.11.0 --extra-index-url https://download.pytorch.org/whl/cpu
WORKDIR /tmp
ARG TORCHVISION_BRANCH=v0.12.0
RUN git clone --branch ${TORCHVISION_BRANCH} https://github.com/pytorch/vision torchvision && cd torchvision && python setup.py bdist_wheel

RUN ls /tmp/torchvision/dist
