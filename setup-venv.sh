#!/bin/bash

python -m venv ./venv
source venv/bin/activate

pushd external/torch-mlir
python -m pip install -r requirements.txt
popd

pushd external/iree
python -m pip install -r bindings/python/build_requirements.txt
popd

deactivate
