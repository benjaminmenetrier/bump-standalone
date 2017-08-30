#!/bin/ksh

# NICAS source
src=${HOME}/codes/nicas/src

# OOPS directory for NICAS
dst=${HOME}/codes/OOPS/oops/src/oops/generic/nicas

# Sync
rsync -avh --delete --exclude "nicas.f90" ${src}/* ${dst}
