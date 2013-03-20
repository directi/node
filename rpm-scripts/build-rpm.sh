#!/bin/sh

# * This script should be run from the root of a the node distribution
# * Expects two arguments:
#   * PACKAGE_NAME: of the generated rpm
#   * BUILD_NUMBER: to uniquely identify the generated RPM
# * It will create a rpm in the current directory that installs our custom
#   version of node into /opt/PACKAGE_NAME

set -o nounset
set -o errexit

if [ $# -ne 2 ]; then
  echo "usage: $0 PACKAGE_NAME BUILD_NUMBER"
  exit 1;
fi

if [ ! -e 'node.gyp' ]; then
  echo "error: $0 must be run from the root of a node repository"
  exit 1;
fi

PACKAGE_NAME=$1
BUILD_NUMBER=$2

RPM_INSTALL_PATH=/opt/${PACKAGE_NAME}
VERSION=`git describe --abbrev=0`

TMPDIR=`mktemp -d -t ${PACKAGE_NAME}.XXXX` || exit 1
trap 'rm -rf ${TMPDIR}' EXIT INT TERM
echo Using temp dir ${TMPDIR}

./configure --prefix=.
make
make install DESTDIR=${TMPDIR}

fpm -s dir -t rpm \
    -C ${TMPDIR} \
    --prefix ${RPM_INSTALL_PATH} \
    --name ${PACKAGE_NAME} \
    --version ${VERSION} \
    --iteration ${BUILD_NUMBER} \
    --verbose \
    --architecture all \
    .

