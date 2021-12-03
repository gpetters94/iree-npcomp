#!/bin/bash

set -euo pipefail
JOBCOUNT="$(($(nproc) + 2))"

source venv/bin/activate

python3 -m pip install transformers fairseq fvcore sacremoses subword-nmt > /dev/null
SERIAL="$PWD/serialized_tests"
rm -rf "$SERIAL"
mkdir -p "$SERIAL/tests"
pushd external/torch-mlir
cmake --build build --target check-torch-mlir
build_tools/write_env_file.sh
export PYTHONPATH=${PYTHONPATH-}
source ".env"
python3 -m build_tools.torchscript_e2e_heavydep_tests.main --output_dir="$SERIAL/tests" || exit
unset PYTHONPATH
popd

pushd external/torch-mlir
[[ -e .env ]] || build_tools/write_env_file.sh
source .env
cmake --build build -j "$JOBCOUNT" || exit
popd

PYTHONPATHONE="$PYTHONPATH"

pushd external/iree
source .env
cmake --build build -j "$JOBCOUNT" || exit
popd

PYTHONPATH="$PYTHONPATH:$PYTHONPATHONE"
export PYTHONPATH=${PYTHONPATH-}

# Resnet
echo "===Running Resnet==="
python3 models/resnet18.py

# BERT
pushd external/torch-mlir
echo "===Running BERT==="
python -m e2e_testing.torchscript.main --serialized-test-dir "../../serialized_tests" --filter=MiniLMSequenceClassification_basic -v -c external --external-config "../../models/torchscript_e2e_config.py"
popd

deactivate
