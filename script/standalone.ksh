#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: standalone
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
#----------------------------------------------------------------------
# Parameters
src_origin="${HOME}/code/ufo-bundle/oops/src/oops/generic/bump"
src_lib="${HOME}/code/bump-standalone/src_lib"
src="${HOME}/code/bump-standalone/src"
standalone="${HOME}/code/bump-standalone/standalone"

# Get src_lib
mkdir -p ${src_lib}
rsync -rtv --delete ${src_origin}/* ${src_lib}

# Copy src_lib into src, exclude type_bump.F90 and type_ens.F90
mkdir -p ${src}
rsync -rtv --delete ${src_lib}/* ${src}

# Add fckit routines
rsync -rtv --delete ${standalone}/fckit ${src}

# Add model routines
rsync -rtv --delete ${standalone}/model ${src}

# Add main.F90
rsync -rtv --delete ${standalone}/main.F90 ${src}

# Add type_model.F90
rsync -rtv --delete ${standalone}/type_model.F90 ${src}

# Add type_timer.F90
rsync -rtv --delete ${standalone}/type_timer.F90 ${src}
