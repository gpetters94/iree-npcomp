#!/bin/bash

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
cmake --build build -j 3
popd

PYTHONPATHONE="$PYTHONPATH"
unset PYTHONPATH

pushd external/iree
source .env
cmake --build build -j 3
popd

export PYTHONPATH="$PYTHONPATHONE:$PYTHONPATH"

#external/torch-mlir/tools/torchscript_e2e_test.sh -c external --external-config "$PWD/models/torchscript_e2e_config.py"
#python -m e2e_testing.torchscript.main -c external --external-config "$PWD/models/torchscript_e2e_config.py"

set -euo pipefail

cd external/torch-mlir

# Ensure PYTHONPATH is set for export to child processes, even if empty.
export PYTHONPATH=${PYTHONPATH-}

# python -m e2e_testing.torchscript.main --serialized-test-dir "../../serialized_tests" --filter=MiniLMSequenceClassification_basic -v
python -m e2e_testing.torchscript.main --serialized-test-dir "../../serialized_tests" --filter=MiniLMSequenceClassification_basic -v -c external --external-config "../../models/torchscript_e2e_config.py"
# python -m e2e_testing.torchscript.main -v -c external --external-config "../../models/torchscript_e2e_config.py" "$@"

deactivate
