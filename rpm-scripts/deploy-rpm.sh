#!/bin/sh

# * This script should be run from the root of the node distribution.
# * Expects one arguments:
#   * DESTINATION_MACHINE: to deploy to.
# * It will deploy the latest rpm file in the build directory on
#   `DESTINATION_MACHINE`.

set -o nounset
set -o errexit

if [ $# -ne 1 ]; then
  echo "usage: $0 DESTINATION_MACHINE"
  exit 1;
fi

if [ ! -e 'node.gyp' ]; then
  echo "error: $0 must be run from the root of a node repository"
  exit 1;
fi

DESTINATION_MACHINE=$1

RPM_PATH=build
RPM=`ls -t1 ${RPM_PATH}/*.rpm | head -1`

if [ -z ${RPM} ]; then
  echo "error: no rpm file found in ${RPM_PATH}"
  exit 1
fi

echo "Using ${RPM}"

USER=hitesh.g
HOST_PATH=/tmp
HOST_RPM=${HOST_PATH}/`basename ${RPM}`

sudo -u ${USER} -H scp ${RPM} ${USER}@${HOSTNAME}:${HOST_PATH}
sudo -u ${USER} -H ssh ${USER}@${HOSTNAME} "sudo yum -y install ${HOST_RPM} && rm ${HOST_RPM}"

