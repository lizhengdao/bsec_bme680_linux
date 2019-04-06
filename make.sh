#!/bin/sh

set  -eu

. ./make.config

if [ ! -d "${BSEC_DIR}" ]; then
  echo 'BSEC directory missing.'
  exit 1
fi

if [ ! -d "${CONFIG_DIR}" ]; then
  mkdir "${CONFIG_DIR}"
fi

STATEFILE="${CONFIG_DIR}/bsec_iaq.state"
if [ ! -f "${STATEFILE}" ]; then
  touch "${STATEFILE}"
fi

echo 'Patching...'
patch -d "${BSEC_DIR}"/examples/ < patches/eCO2+bVOCe.diff

echo 'Compiling...'
cc -Wall -Wno-unused-but-set-variable -Wno-unused-variable -static \
  -std=c99 -pedantic \
  -iquote"${BSEC_DIR}"/API \
  -iquote"${BSEC_DIR}"/algo/bin/${ARCH} \
  -iquote"${BSEC_DIR}"/examples \
  "${BSEC_DIR}"/API/bme680.c \
  "${BSEC_DIR}"/examples/bsec_integration.c \
  ./bsec_bme680.c \
  -L"${BSEC_DIR}"/algo/bin/"${ARCH}" -lalgobsec \
  -lm -lrt \
  -o bsec_bme680
echo 'Compiled.'

cp "${BSEC_DIR}"/config/"${CONFIG}"/bsec_iaq.config "${CONFIG_DIR}"/
echo 'Copied config.'

