# (C) Copyright 2017-2019 UCAR.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

set( gklib_src_files

b64.c
blas.c
csr.c
error.c
evaluate.c
fkvkselect.c
fs.c
getopt.c
gk_arch.h
gk_defs.h
gk_externs.h
gk_getopt.h
GKlib.h
gk_macros.h
gk_mkblas.h
gk_mkmemory.h
gk_mkpqueue2.h
gk_mkpqueue.h
gk_mkrandom.h
gk_mksort.h
gk_mkutils.h
gk_proto.h
gkregex.c
gkregex.h
gk_struct.h
gk_types.h
graph.c
htable.c
io.c
itemsets.c
mcore.c
memory.c
ms_inttypes.h
ms_stat.h
ms_stdint.h
omp.c
pdb.c
pqueue.c
random.c
rw.c
seq.c
sort.c
string.c
timers.c
tokenizer.c
util.c

)

ecbuild_add_library( TARGET     gklib
                     SOURCES    ${FORTRAN_BINDINGS}
                                ${gklib_src_files}
                     INSTALL_HEADERS LISTED
                     LINKER_LANGUAGE ${METISJEDI_LINKER_LANGUAGE}
                   )
