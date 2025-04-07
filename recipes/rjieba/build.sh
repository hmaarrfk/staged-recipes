#!/bin/bash

# -e = exit on first error
# -x = print every executed command
set -ex

# Build the package using maturin - should produce *.whl files.
maturin build --interpreter $PYTHON --release

# Install *.whl files using pip
$PYTHON -m pip install target/wheels/*.whl --no-deps --ignore-installed -vv