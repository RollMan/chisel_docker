FROM gcc:13.2.0-bookworm AS verilator
WORKDIR /verilator_src
RUN apt update && \
    apt install -y \
    bison \
    flex \
    g++ \
    gcc  \
    help2man \
    make \
    perl \
    texi2html && \
    curl -OL https://github.com/verilator/verilator/archive/refs/tags/v5.024.tar.gz && \
    tar xf v5.024.tar.gz && \
    cd verilator-5.024 && \
    autoconf && \
    ./configure --prefix=/verilator && \
    make -j`nproc` && make install && \
    rm -rf /var/lib/apt/lists/*

# Install Scala
# Check jdk compatibility for scala at https://docs.scala-lang.org/overviews/jdk-compatibility/overview.html
FROM openjdk:21-bookworm
COPY --from=verilator /verilator/bin /usr/bin
COPY --from=verilator /verilator/share /usr/share
RUN curl -OL https://github.com/sbt/sbt/releases/download/v1.9.9/sbt-1.9.9.tgz && \
    tar xf sbt-1.9.9.tgz && \
    mv sbt/bin/sbt sbt/bin/sbt-launch.jar sbt/bin/sbtn-x86_64-pc-linux /usr/bin && \
    rm -rf sbt sbt-1.9.9.tgz
