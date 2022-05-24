ARG PYTHON_VERSION=3.8
FROM python:${PYTHON_VERSION}-bullseye

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    git \
    libsndfile1 \
    build-essential \
    g++ \
    cmake \
    unzip

ARG NODE_VERSION="17"
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && apt-get install -y nodejs

ENV JAVA_HOME=${HOME}/jdk-17.0.2
ENV PATH=${JAVA_HOME}/bin:${PATH}
RUN mkdir -p ${JAVA_HOME} && curl -s https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-aarch64_bin.tar.gz | tar xvz -C ${HOME}

ARG BAZEL_VERSION=4.2.1
RUN wget https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-arm64 -O /usr/local/bin/bazel && chmod +x /usr/local/bin/bazel
ENV USE_BAZEL_VERSION=${BAZEL_VERSION}

RUN python -m pip install cython==0.29.0 pytest

ARG RAY_TAG=ray-1.12.0
WORKDIR /tmp
RUN git clone https://github.com/ray-project/ray.git && cd ray && git checkout tags/$RAY_TAG

WORKDIR /tmp/ray/dashboard/client
ENV NODE_OPTIONS=--openssl-legacy-provider
RUN npm install && npm ci && npm run build

WORKDIR /tmp/ray/python
RUN RAY_DISABLE_EXTRA_CPP=1 python setup.py bdist_wheel
RUN ls /tmp/ray/python/dist
