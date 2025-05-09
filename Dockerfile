FROM ubuntu:22.04

# Prevent interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# Update and install all required dependencies
RUN apt update && apt install -y \
    git curl make cmake gfortran \
    libcoarrays-dev libopenmpi-dev libcoarrays-openmpi-dev libcaf-openmpi-3 \
    vim stress \
    python3 python3-pip python3-dev python3-venv \
    python3-numpy python3-matplotlib python3-astropy \
    meson ninja-build \
    && apt clean

# get ipython because I like it
RUN pip install ipython

# Silence OpenMPI root warnings (acceptable in Docker)
ENV OMPI_ALLOW_RUN_AS_ROOT=1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

# Override mpifort with flags to support large memory models
RUN echo '#!/bin/bash\nexec /usr/bin/mpifort -mcmodel=medium -fPIC "$@"' > /usr/local/bin/mpifort && chmod +x /usr/local/bin/mpifort

# Clone and build the ALF source code. This code actually takes the fork by
# Tom Barone, which contains its own dockerfile to run alf in a container
# for stress testing. The original repo is at https://github.com/cconroy20/alf
# (it was useful to debug memory issues I was encountering when running large
# numbers of steps and chains).
ENV ALF_HOME=/opt/alf
RUN git clone https://github.com/tom-barone/alf.git $ALF_HOME \
    && cd $ALF_HOME/src && make

# Clone the alf-python wrapper by Gabe Brammer.
RUN git clone https://github.com/gbrammer/alf-python.git /opt/alf-python

# Patch out hardcoded macOS paths
RUN find /opt/alf-python -type f -exec sed -i 's|/opt/homebrew|/usr|g' {} +

# Set working directory to alf-python
WORKDIR /opt/alf-python

# Ensure correct Fortran compiler is used and disable Meson backend
ENV FC=/usr/bin/mpifort
ENV F90=/usr/bin/mpifort
ENV MPIFC=/usr/bin/mpifort
ENV NPY_USE_MESON=0

# Install the Python wrapper
RUN python3 setup.py install

# Drop into a bash shell
CMD ["/bin/bash"]
