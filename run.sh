#!/bin/bash

source venv/bin/activate

pushd external/torch-mlir
build_tools/write_env_file.sh
source .env
cmake --build build -j 3
popd

PYTHONPATHONE="$PYTHONPATH"

pushd external/iree
source .env
cmake --build build -j 3
popd

export PYTHONPATH="$PYTHONPATHONE:$PYTHONPATH"

for MODEL in models/*.py; do
  echo "Running $MODEL"
  python3 "$MODEL" #||
#  rm -rf out &&
#  mkdir -p out &&
#  external/iree/build/compiler-api/python_package/iree/compiler/_mlir_libs/ireec \
#    --iree-input-type=none \
#    --iree-vm-bytecode-module-output-format=flatbuffer-binary \
#    --iree-hal-target-backends=dylib-llvm-aot \
#    --iree-mlir-to-vm-bytecode-module \
#    --iree-llvm-embedded-linker-path=external/iree/build/compiler-api/python_package/iree/compiler/_mlir_libs/iree-lld \
#    --mlir-print-debuginfo \
#    --mlir-print-op-on-diagnostic=false \
#    --print-ir-before-all \
#    --print-ir-after-failure \
#    uncompiled.mlir 2>out.mlir ||
#  csplit out.mlir -n 4 -f out/pass_ '/\/\/\ -----\/\//' '{*}' &&
#  rm out.mlir &&
#  gdb --args \
#    external/iree/build/compiler-api/python_package/iree/compiler/_mlir_libs/ireec \
#      --iree-input-type=none \
#      --iree-vm-bytecode-module-output-format=flatbuffer-binary \
#      --iree-hal-target-backends=dylib-llvm-aot \
#      --iree-mlir-to-vm-bytecode-module \
#      --iree-llvm-embedded-linker-path=external/iree/build/compiler-api/python_package/iree/compiler/_mlir_libs/iree-lld \
#      --mlir-print-debuginfo \
#      --mlir-print-op-on-diagnostic=false \
#      uncompiled.mlir
done

deactivate
