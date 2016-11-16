FROM jchodera/omnia-build-box:texlive

# Install CUDA 7.5, AMD APP SDK 3.0

# CUDA requires dkms libvdpau
# TeX installation requires wget
# The other TeX packages installed with `tlmgr install` are required for OpenMM's sphinx docs
# libXext libSM libXrender are required for matplotlib to work

ADD http://download.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm .
RUN rpm -i --quiet epel-release-5-4.noarch.rpm && \
    rm -rf epel-release-5-4.noarch.rpm

RUN  yum install -y --quiet dkms libvdpau git wget libXext libSM libXrender

# Install AMD APP SDK
#ADD https://jenkins.choderalab.org/userContent/AMD-APP-SDKInstaller-v3.0.130.135-GA-linux64.tar.bz2 .
ADD http://s3.amazonaws.com/omnia-ci/AMD-APP-SDKInstaller-v3.0.130.135-GA-linux64.tar.bz2 .
RUN pwd
RUN ls -ltr
RUN tar xjf AMD-APP-SDKInstaller-v3.0.130.135-GA-linux64.tar.bz2 && \
    ./AMD-APP-SDK-v3.0.130.135-GA-linux64.sh -- -s -a yes && \
    rm -f AMD-APP-SDK-v3.0.130.135-GA-linux64.sh AMD-APP-SDKInstaller-v3.0.130.135-GA-linux64.tar.bz2 && \
    rm -rf /opt/AMDAPPSDK-3.0/samples/
ENV OPENCL_HOME=/opt/AMDAPPSDK-3.0 OPENCL_LIBPATH=/opt/AMDAPPSDK-3.0/lib/x86_64

# Install minimal CUDA components (this may be more than needed)
ADD https://developer.nvidia.com/compute/cuda/8.0/prod/local_installers/cuda-repo-rhel6-8-0-local-8.0.44-1.x86_64-rpm .
RUN mv cuda-repo-rhel6-8-0-local-8.0.44-1.x86_64-rpm cuda-repo-rhel6-8-0-local-8.0.44-1.x86_64.rpm
RUN rpm --quiet -i cuda-repo-rhel6-8-0-local-8.0.44-1.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-8-0-local/cuda-minimal-build-8-0-8.0.44-1.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-8-0-local/cuda-cufft-dev-8-0-8.0.44-1.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-8-0-local/cuda-driver-dev-8-0-8.0.44-1.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-8-0-local/xorg-x11-drv-nvidia-libs-367.48-1.el6.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-8-0-local/xorg-x11-drv-nvidia-devel-367.48-1.el6.x86_64.rpm&& \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-8-0-local/cuda-driver-dev-8-0-8.0.44-1.x86_64.rpm&& \
    rm -rf /cuda-repo-rhel6-8-0-local-8.0.44-1.x86_64.rpm /var/cuda-repo-8-0-local/*.rpm /var/cache/yum/cuda-8-0-local/

RUN yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all
