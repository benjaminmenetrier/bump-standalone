# (C) Copyright 2017-2019 UCAR.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

set( metis_src_files

auxapi.c
balance.c
bucketsort.c
checkgraph.c
coarsen.c
compress.c
contig.c
debug.c
defs.h
fm.c
fortran.c
frename.c
gklib.c
gklib_defs.h
gklib_rename.h
graph.c
initpart.c
kmetis.c
kwayfm.c
kwayrefine.c
macros.h
mcutil.c
mesh.c
meshpart.c
metis.h
metislib.h
minconn.c
mincover.c
mmd.c
ometis.c
options.c
parmetis.c
pmetis.c
proto.h
refine.c
rename.h
separator.c
sfm.c
srefine.c
stat.c
stdheaders.h
struct.h
timing.c
util.c
wspace.c

)

ecbuild_add_library( TARGET     metis
                     SOURCES    ${FORTRAN_BINDINGS}
                                ${metis_src_files}
                     LIBS       gklib
                     INSTALL_HEADERS LISTED
                     LINKER_LANGUAGE ${METISJEDI_LINKER_LANGUAGE}
                   )
