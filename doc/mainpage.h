//----------------------------------------------------------------------
// Documentation file: mainpage
// Author: Benjamin Menetrier
// Licensing: this code is distributed under the CeCILL-C license
// Copyright © 2015-... UCAR, CERFACS and METEO-FRANCE
//----------------------------------------------------------------------
/*!
\mainpage BUMP

Welcome to the documentation for the software BUMP.

Contact: benjamin.menetrier@meteo.fr

To download the code: <a target="_blank" href="https://github.com/benjaminmenetrier/BUMP">GitHub repository</a>

\section Introduction Introduction
The software <b>BUMP</b> (B matrix on an Unstructured Package) aims at estimating and applying background error covariance-related operators, defined on an unstructured mesh.

The code is distributed under the CeCILL-C license (in English: <a target="_blank" href="LICENSE_MF.html">LICENSE</a> or in French: <a target="_blank" href="LICENCE_MF.html">LICENCE</a>).

Code size and characterics can be found in the <a target="_blank" href="http://benjaminmenetrier.free.fr/bump/CLOC_REPORT.html">CLOC report</a>.

\section Offline_online Offline or online usage

This package can be used as standalone code, with NetCDF inputs, for the following models:
  - <a target="_blank" href="http://www.cnrm-game-meteo.fr/spip.php?article121&lang=en">ARPEGE</a>
  - <a target="_blank" href="http://www.cnrm-game-meteo.fr/spip.php?article120&lang=en">AROME</a>
  - <a target="_blank" href="https://www.gfdl.noaa.gov/fv3">FV3</a>
  - <a target="_blank" href="https://en.wikipedia.org/wiki/Global_Environmental_Multiscale_Model">GEM</a>
  - <a target="_blank" href="https://gmao.gsfc.nasa.gov/GEOS">GEOS</a>
  - <a target="_blank" href="https://www.ncdc.noaa.gov/data-access/model-data/model-datasets/global-forcast-system-gfs">GFS</a>
  - <a target="_blank" href="http://www.ecmwf.int/en/research/modelling-and-prediction">IFS</a>
  - <a target="_blank" href="https://mpas-dev.github.io">MPAS</a>
  - <a target="_blank" href="http://www.nemo-ocean.eu">NEMO</a>
  - <a target="_blank" href="http://www.wrf-model.org">WRF</a>

It can also be used "online" within an other code, using a dedicated interface.

\section Folders Folders organization
The main directory $MAINDIR contains the CMakeLists.txt file and several folders:
  - data: data (only links script in the archive)
  - doc: documentation and support
  - ncl: <a target="_blank" href="http://ncl.ucar.edu">NCL</a> scripts to plot curves
  - run: executables and namelists
  - script: useful scripts
  - src: source code
  - test: test data

\section Compilation Compilation and dependencies
The compilation of sources uses cmake (<a target="_blank" href="https://cmake.org">https://cmake.org</a>). Compilation options (compiler, build type, NetCDF inclue and library paths) have to be specified in four environment variables:
 - <b>BUMP_COMPILER</b>: GNU, Intel or Cray
 - <b>BUMP_BUILD</b>: DEBUG or RELEASE
 - <b>BUMP_NETCDF_INCLUDE</b>: C NetCDF include path
 - <b>BUMP_NETCDFF_INCLUDE</b>: Fortran NetCDF include path
 - <b>BUMP_NETCDF_LIBPATH</b>: C NetCDF library path
 - <b>BUMP_NETCDFF_LIBPATH</b>: Fotran NetCDF library path

Some examples are given for several supercomputer:
 - at <a target="_blank" href="ENV_ECMWF.html">ECMWF (Cray compiler)</a>
 - at <a target="_blank" href="ENV_MF.html">Météo-France (GNU and Intel compiler)</a>
 - at <a target="_blank" href="ENV_NCAR.html">NCAR (GNU compiler)</a>

Then, to compile in a directory $BUILDDIR, with $N processors (if available):
 
    cd $BUILDDIR
    cmake $MAINDIR/CMakeLists.txt
    make -j$N

An executable file $MAINDIR/run/bump should be created if compilation is successful.

WARNING: for the Intel compiler, it seems that version intel/17.[...].[...] is required.

Input and output files use the NetCDF format. The NetCDF library can be downloaded at: <a target="_blank" href="http://www.unidata.ucar.edu/software/netcdf">http://www.unidata.ucar.edu/software/netcdf</a>

\section code Code structure
The source code is organized in modules with several groups indicated by a prefix:
  - main.F90: main program
  - model/model_[...]: model related routines, to get the coordinates, read and write fields
  - tools_[...]: useful tools for the whole code
  - type_[...]: derived types
  - external/[...]: external tools

\section input Input data
A "grid.nc" file containing the coordinates of the model grid is used in every model/model_$MODEL_coord routine and should be placed in $DATADIR. The script "links.ksh" located in the $DATADIR folder can help you to generate it.

For the MPI splitting, a file $DATADIR/$PREFIX_distribution_$NPROC.nc is required, where $PREFIX and $NPROC is the number of MPI tasks formatted with 4 digits, both specified in the namelist.

\section namelist Namelists management

Namelists can be found in $MAINDIR/run. They are also stored in the SQLite database $MAINDIR/script/namelist.sqlite. This database can be browsed with appropriate softwares like <a target="_blank" href="http://sqlitebrowser.org">SQLiteBrowser</a>.

To add or update a namelist in the database:
 
    cd $MAINDIR/script
    ./namelist_nam2sql.ksh $SUFFIX

where $SUFFIX is the namelist suffix. If no $SUFFIX is specified, all namelists present in $MAINDIR/run are added or updated.

To generate a namelist from the database:
 
    cd $MAINDIR/script
    ./namelist_sql2nam.ksh $SUFFIX

where $SUFFIX is the namelist suffix. If no $SUFFIX is specified, all namelists present in the database are generated in $MAINDIR/run.

\section running Running the code

To run the code on a single node, you have to edit a namelist located in the $MAINDIR/run directory, and then:
 
    cd $MAINDIR/run
    export OMP_NUM_THREADS=$NTHREAD
    mpirun -n $NTASK bump namelist_$SUFFIX

where $NTHREAD is the number of OpenMP threads and $NTASK is the number of MPI tasks that are desired.

The script $MAINDIR/script/sbatch.ksh is available for multi-nodes executions with SBATCH.

\section ncl NCL plots
Various <a target="_blank" href="http://ncl.ucar.edu">NCL</a> scripts are available in $MAINDIR/ncl/script to plot data.

\section test Test
A simple test script is available in $MAINDIR/script:
 
    cd $MAINDIR/script
    ./test.ksh

It uses data stored in $MAINDIR/test and calls the NetCDF tools ncdump.

\section model Adding a new model
To add a model $MODEL in bump, you need to write a new module containing three routines:
 - model/model_$MODEL_coord to get model coordinates
 - model_$MODEL_read to read a model field

You need also to add three calls to model/model_$MODEL_coord and model/model_$MODEL_read in routines model_coord and model_read respectively, which are contained in the module model_interface.

Finally, you need to add a case for the namelist check in the routine nam_check, contained in type_nam.f90.

For models with a regular grid, you can start from AROME, ARPEGE, FV3, GEM, GEOS, GFS, IFS, NEMO and WRF routines. For models with an unstructured grid, you can start from MPAS routines.
*/
