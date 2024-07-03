# Dockerfile created 2024-07-03, Alaina Hardie (xBio.ca)
# mapDamage2 with all deps required (I can't get the quay.io build to work)
#
# call like so:
#
# docker run -v /working:/data -v /references:/references -w /data -ti mapdamage2_with_deps -i /data/my_bamfile.bam -r /references/my_reference.fasta

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libgsl-dev \
    libpng-dev \
    libjpeg-dev \
    libtiff-dev \
    r-base \
    python3 \
    python3-pip \
    git \
    tzdata \
    seqtk \
    && apt-get clean

RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata

# Install packages required for mapDamage2
RUN Rscript -e "install.packages('inline', repos='http://cran.us.r-project.org')" \
    && Rscript -e "install.packages('gam', repos='http://cran.us.r-project.org')" \
    && Rscript -e "install.packages('Rcpp', repos='http://cran.us.r-project.org')" \
    && Rscript -e "install.packages('ggplot2', repos='http://cran.us.r-project.org')" \
    && Rscript -e "install.packages('RcppGSL', repos='http://cran.us.r-project.org')"

# Install Python packages
RUN pip3 install pysam Cython

# Clone and install mapDamage
RUN git clone https://github.com/ginolhac/mapDamage.git \
    && cd mapDamage \
    && python3 setup.py install

# Set the working directory
WORKDIR /data

# Ensure Rscript is in PATH
ENV PATH="/usr/local/bin/Rscript:${PATH}"

# Check installation and R packages
RUN mapDamage --check-R-packages

# Entry point
ENTRYPOINT ["mapDamage"]
