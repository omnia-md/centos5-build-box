FROM jchodera/omnia-build-box:cuda80-amd30

RUN yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all

# Install clang 3.8.1
RUN yum install -y --quiet xz
ADD http://llvm.org/releases/3.8.1/llvm-3.8.1.src.tar.xz /tmp
RUN xzcat /tmp/llvm-3.8.1.src.tar.xz | tar xf -
ADD http://llvm.org/releases/3.8.1/cfe-3.8.1.src.tar.xz /tmp
RUN xzcat /tmp/cfe-3.8.1.src.tar.xz | tar xf - && mv cfe-3.8.1.src llvm-3.8.1.src/tools/clang
RUN source /opt/rh/devtoolset-2/enable && \
    mkdir llvm-build && cd llvm-build && \
    CC=gcc CXX=g++ /hbb/bin/cmake ../llvm-3.8.1.src/ \
        -DCMAKE_INSTALL_PREFIX=/opt/clang \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_TARGETS_TO_BUILD=X86 \
        -DGCC_INSTALL_PREFIX=/opt/rh/devtoolset-2/root/usr/ \
        && \
    NCORES=$(grep -c '^processor' /proc/cpuinfo) && \
    make -j $NCORES && \
    make install/strip
RUN rm -rf /llvm-3.8.1.src /tmp/llvm-3.8.1.src.tar.xz /tmp/cfe-3.8.1.src.tar.xz /llvm-build
