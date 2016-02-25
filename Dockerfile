FROM phusion/holy-build-box-64

# Install TeX, CUDA 7.5, AMD APP SDK 3.0

# CUDA requires dkms libvdpau
# TeX installation requires wget
# The other TeX packages installed with `tlmgr install` are required for OpenMM's sphinx docs
# libXext libSM libXrender are required for matplotlib to work

ADD http://download.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm .
RUN rpm -i --quiet epel-release-5-4.noarch.rpm && \
    rm -rf epel-release-5-4.noarch.rpm

RUN  yum install -y --quiet dkms libvdpau git wget libXext libSM libXrender 

# Install AMD APP SDK
ADD https://jenkins.choderalab.org/userContent/AMD-APP-SDKInstaller-v3.0.130.135-GA-linux64.tar.bz2 .
RUN tar xjf AMD-APP-SDKInstaller-v3.0.130.135-GA-linux64.tar.bz2 && \
    ./AMD-APP-SDK-v3.0.130.135-GA-linux64.sh -- -s -a yes && \
    rm -f AMD-APP-SDK-v3.0.130.135-GA-linux64.sh AMD-APP-SDKInstaller-v3.0.130.135-GA-linux64.tar.bz2 && \
    rm -rf /opt/AMDAPPSDK-3.0/samples/
ENV OPENCL_HOME=/opt/AMDAPPSDK-3.0 OPENCL_LIBPATH=/opt/AMDAPPSDK-3.0/lib/x86_64

# Install minimal CUDA components (this may be more than needed)
ADD http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda-repo-rhel6-7-5-local-7.5-18.x86_64.rpm .
RUN rpm --quiet -i cuda-repo-rhel6-7-5-local-7.5-18.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-7-5-local/cuda-minimal-build-7-5-7.5-18.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-7-5-local/cuda-cufft-dev-7-5-7.5-18.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-7-5-local/cuda-driver-dev-7-5-7.5-18.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-7-5-local/xorg-x11-drv-nvidia-devel-352.39-1.el6.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-7-5-local/cuda-driver-dev-7-5-7.5-18.x86_64.rpm && \
    rm -rf /cuda-repo-rhel6-7-5-local-7.5-18.x86_64.rpm /var/cuda-repo-7-5-local/*.rpm /var/cache/yum/cuda-7-5-local/

RUN yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all

# Install TeXLive
ADD http://ctan.mackichan.com/systems/texlive/tlnet/install-tl-unx.tar.gz .
ADD texlive.profile .
RUN tar -xzf install-tl-unx.tar.gz && \
    cd install-tl-* &&  ./install-tl -profile /texlive.profile && cd - && \
    rm -rf install-tl-unx.tar.gz install-tl-* texlive.profile && \
    /usr/local/texlive/2015/bin/x86_64-linux/tlmgr install \
          cmap fancybox titlesec framed fancyvrb threeparttable \
          mdwtools wrapfig parskip upquote float multirow hyphenat caption \
          xstring
ENV PATH=/usr/local/texlive/2015/bin/x86_64-linux:$PATH

