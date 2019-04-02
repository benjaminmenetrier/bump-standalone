#!/bin/ksh
#----------------------------------------------------------------------
# Korn shell script: standalone
# Author: Benjamin Menetrier
# Licensing: this code is distributed under the CeCILL-C license
# Copyright © 2015-... UCAR, CERFACS, METEO-FRANCE and IRIT
#----------------------------------------------------------------------
# Parameters
src_origin="${HOME}/code/ufo-bundle/oops/src/oops/generic/bump"
src="${HOME}/code/bump-standalone/src"
standalone="${HOME}/code/bump-standalone/standalone"

# Get src
mkdir -p ${src}
rsync -rtv --delete ${src_origin}/* ${src}

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
