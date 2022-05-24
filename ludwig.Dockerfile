ARG PYTHON_VERSION=3.8
ARG TORCHVISION_TAG=3.8-0.12
ARG TORCHVISION_WHEEL=torchvision-0.12.0a0+9b5a3fe-cp38-cp38-linux_aarch64.whl
ARG RAY_TAG=3.8-1.12.0
ARG RAY_WHEEL=ray-1.12.0-cp38-cp38-linux_aarch64.whl
FROM python:${PYTHON_VERSION}-bullseye

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    git \
    libsndfile1 \
    build-essential \
    g++ \
    cmake

COPY --from=jppgks/ray-arm64:${RAY_TAG} /tmp/ray/python/dist/ .
RUN python -m pip --no-cache-dir install "${RAY_WHEEL}[all]" --find-links=. && rm *.whl

RUN python -m pip install -U pip wheel && python -m pip install torch

COPY --from=jppgks/torchvision-arm64:${TORCHVISION_TAG} /tmp/torchvision/dist .
RUN python -m pip --no-cache-dir install ${TORCHVISION_WHEEL} --find-links=. && rm *.whl

# all Ludwig extras except 'serve', 'test' since neuropod dependency has no arm64 release
RUN mkdir -p ${HOME}/ludwig && git clone https://github.com/ludwig-ai/ludwig.git ${HOME}/ludwig && cd ${HOME}/ludwig && \
    HOROVOD_WITH_PYTORCH=1 \
    HOROVOD_WITHOUT_MPI=1 \
    HOROVOD_WITHOUT_TENSORFLOW=1 \
    HOROVOD_WITHOUT_MXNET=1 \
    python -m pip install -e '.[audio,image,text,viz,distributed,hyperopt]' && \
    horovodrun --check-build && \
    python -c "import horovod.torch; horovod.torch.init(); import ludwig"

RUN python -m pip install pytest
