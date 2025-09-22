FROM emscripten/emsdk:4.0.15-arm64

RUN apt update
RUN apt-get install -y autotools-dev automake libtool
RUN wget -O binaryen.tar.gz https://github.com/WebAssembly/binaryen/releases/download/version_124/binaryen-version_124-aarch64-linux.tar.gz && echo "6291bd9a57d8e046f3bc099a4db386c147433a87f71c783a901c5b1792e38de3 binaryen.tar.gz" | sha256sum -c - && tar -xf binaryen.tar.gz && rm binaryen.tar.gz && mv binaryen-version_124 /
ENV PATH="/binaryen-version_124/bin:${PATH}"
RUN git config --global --add safe.directory '*'
