#!/bin/bash

source venv/bin/activate

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

# python -m e2e_testing.torchscript.main -v -c external --external-config "../../models/torchscript_e2e_config.py" "$@"

python -m e2e_testing.torchscript.main --serialized-test-dir "../../serialized_tests" --filter=MiniLMSequenceClassification_basic -v -c external --external-config "../../models/torchscript_e2e_config.py"

deactivate
