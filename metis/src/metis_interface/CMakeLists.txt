# (C) Copyright 2017-2019 UCAR.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

set( metis_interface_src_files

metis_interface.f90

)

ecbuild_add_library( TARGET     metis_interface
                     SOURCES    ${FORTRAN_BINDINGS}
                                ${metis_interface_src_files}
                     LIBS       gklib metis
                     INSTALL_HEADERS LISTED
                     LINKER_LANGUAGE ${METISJEDI_LINKER_LANGUAGE}
                   )
