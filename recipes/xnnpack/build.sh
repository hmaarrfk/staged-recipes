mkdir build
cd build
cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release     \
    -DXNNPACK_BUILD_TESTS=OFF \
    -DXNNPACK_BUILD_BENCHMARKS=OFF \
    -DXNNPACK_LIBRARY_TYPE=shared \
    -DXNNPACK_USE_SYSTEM_LIBS=ON \
    ..
make -j${CPU_COUNT} VERBOSE=1 V=1
make install