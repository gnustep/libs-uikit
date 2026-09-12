FROM debian:bookworm
RUN apt-get update && apt-get install -y --no-install-recommends \
    clang cmake make libgnustep-gui-dev gnustep-back0.29-cairo xvfb xauth \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /work
CMD ["sh", "-c", "cmake -S . -B /tmp/uikit-build -DCMAKE_OBJC_COMPILER=/usr/bin/clang && cmake --build /tmp/uikit-build -j2 && xvfb-run -a ctest --test-dir /tmp/uikit-build --output-on-failure"]
