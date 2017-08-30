//----------------------------------------------------------------------
// Documentation file: mainpage
// Author: Benjamin Menetrier
// Licensing: this code is distributed under the CeCILL-C license
// Copyright © 2017 METEO-FRANCE
//----------------------------------------------------------------------
/*!
 * \mainpage nicas
 *
 * Welcome to the documentation for the software NICAS.
 *
 * Contact: benjamin.menetrier@meteo.fr
 *
 * To download the code:
 *  - <a target="_blank" href="https://opensource.cnrm-game-meteo.fr/projects/nicas/files">archives page</a>
 *  - git repository: git clone git://opensource.cnrm-game-meteo.fr/nicas.git .
 *
 * \section Introduction Introduction
 * The software <b>NICAS</b> aims at computing coefficients for a localization method based on a Normalized Interpolated Convolution on an Adaptive Subgrid.
 *
 * Already available input models are: <a target="_blank" href="http://www.cnrm-game-meteo.fr/spip.php?article121&lang=en">ARPEGE</a>, <a target="_blank" href="http://www.cnrm-game-meteo.fr/spip.php?article120&lang=en">AROME</a>, <a target="_blank" href="https://en.wikipedia.org/wiki/Global_Environmental_Multiscale_Model">GEM</a>, <a target="_blank" href="https://gmao.gsfc.nasa.gov/GEOS">GEOS</a>, <a target="_blank" href="https://www.ncdc.noaa.gov/data-access/model-data/model-datasets/global-forcast-system-gfs">GFS</a>, <a target="_blank" href="http://www.ecmwf.int/en/research/modelling-and-prediction">IFS</a>, <a target="_blank" href="https://mpas-dev.github.io">MPAS</a>, <a target="_blank" href="http://www.nemo-ocean.eu">NEMO</a> and <a target="_blank" href="http://www.wrf-model.org">WRF</a>.
 *
 * Code size and characterics can be found in the <a target="_blank" href="http://benjaminmenetrier.free.fr/nicas/html/CLOC_REPORT.html">CLOC report</a>.
 *
 * \section license License
 * The code is distributed under the CeCILL-B license (in English: <a target="_blank" href="http://benjaminmenetrier.free.fr/nicas/html/MF_LICENSE.html">LICENSE</a> or in French: <a target="_blank" href="http://benjaminmenetrier.free.fr/nicas/html/MF_LICENCE.html">LICENCE</a>).
 *
 * \section Folders Folders organization
 * The main directory $MAINDIR contains six folders:
 *   - build: cmake-generated files
 *   - data: data (only links script in the archive)
 *   - doc: documentation and support
 *   - ncl: <a target="_blank" href="http://ncl.ucar.edu">NCL</a> scripts to plot curves
 *   - run: executables and namelists
 *   - script: useful scripts
 *   - src: source code
 *   - test: test data
 *
 * They should have been created when unpacking the archive nicas.tar.gz or cloning the git repository.
 *
 * \section Compilation Compilation and dependencies
 * The compilation of sources uses cmake (<a target="_blank" href="https://cmake.org">https://cmake.org</a>). Compilation options (compiler, build type, NetCDF root path) have to be specified in three environment variables:
 *  - NICAS_COMPILER (GNU or Intel)
 *  - NICAS_BUILD (DEBUG or RELEASE)
 *  - NICAS_NETCDF (NetCDF root path)
 *
Then, to compile:
 *  - cd build
 *  - cmake CMakeLists.txt
 *  - make
 *
 * An executable file run/nicas should be created if compilation is sucessful.
 *
 * Input and output files use the NetCDF format. The NetCDF library can be downloaded at: <a target="_blank" href="http://www.unidata.ucar.edu/software/netcdf">http://www.unidata.ucar.edu/software/netcdf</a>
 *
 * Horizontal interpolations are performed with the tool ESMF_RegridWeightGen, available at:  <a target="_blank" href="https://www.earthsystemcog.org/projects/esmf/">https://www.earthsystemcog.org/projects/esmf/</a>. A supplementary file must be generated in the scripts links.ksh, which use <a target="_blank" href="http://ncl.ucar.edu">NCL</a>.
 *
 * \section code Code structure
 * The source code is organized in modules with several groups indicated by a prefix:
 *   - nicas: main program
 *   - model_[...]: model related routines, to get the coordinates, read and write fields
 *   - module_[...]: generic computation routines
 *   - tools_[...]: useful tools for the whole code
 *   - type_[...]: derived types
 *
 * \section input Input data
 * A "grid.nc" file containing the coordinates of the model grid is used in every model_$MODEL_coord routine and should be placed in $DATADIR. The script "links.ksh" located in the $DATADIR folder can help you to generate it.
 *
 * If required by namelist keys Lbh_file and Lbv_file, input files containing the horizontal and vertical length-scales are read.
 *
 * For the MPI splitting, a file $DATADIR/$PREFIX_distribution_$NPROC.nc is required, where $PREFIX and $NPROC is the number of MPI tasks formatted with 4 digits, both specified in the namelist.
 *
 * \section output Output data
 * \subsection output_1 Mesh data
 * The file $DATADIR/$PREFIX_mesh.nc contains informative data about the subgrid that are not required to apply the NICAS method.
 *
 * \subsection output_2 Global parameters
 * The file $DATADIR/$PREFIX_param.nc contains all the required paramters to apply the NICAS method on a single task. This file can also be used to bypass the parameters computations in a future restart.
 *
 * \subsection output_3 Local parameters
 * The file $DATADIR/$PREFIX_mpi-$MPI_$IPROC_$NPROC.nc all the required paramters to apply the NICAS method for task $IPROC among $NPROC tasks (both formatted with 4 digits), where $MPI is the number of communication steps (1 or 2, formatted with 1 digit). This file can also be used to bypass the parameters computations in a future restart.
 *
 * \subsection output_3 Distribution parameters
 * The file $DATADIR/$PREFIX_mpi-$MPI_$NPROC_summary.nc contains informative data about the MPI splitting that are not required to apply the NICAS method.
 *
 * \section namelist Namelists management
 *
 * Namelists can be found in $MAINDIR/run. They are also stored in the SQLite database $MAINDIR/script/namelist.sqlite. This database can be browsed with appropriate softwares like <a target="_blank" href="http://sqlitebrowser.org">SQLiteBrowser</a>.
 *
 * To add or update a namelist in the database:
 *  - cd $MAINDIR/script
 *  - ./namelist_nam2sql.ksh $SUFFIX
 * where $SUFFIX is the namelist suffix. If no $SUFFIX is specified, all namelists present in $MAINDIR/run are added or updated.
 *
 * To generate a namelist from the database:
 *  - cd $MAINDIR/script
 *  - ./namelist_sql2nam.ksh $SUFFIX
 * where $SUFFIX is the namelist suffix. If no $SUFFIX is specified, all namelists present in the database are generated in $MAINDIR/run.
 *
 * \section running Running the code
 *
 * To run the code on a single node, you have to edit a namelist located in the $MAINDIR/run directory, and then:
 *  - cd $MAINDIR/run
 *  - export OMP_NUM_THREADS=$NTHREAD
 *  - mpirun --npernode $NTASK nicas < namelist_$SUFFIX
 * where $NTHREAD is the number of OpenMP threads and $NTASK is the number of MPI tasks that are desired.
 *
 * The script $MAINDIR/script/sbatch.ksh is available for multi-nodes executions with SBATCH.
 *
 * \section ncl NCL plots
 * Various <a target="_blank" href="http://ncl.ucar.edu">NCL</a> scripts are available in $MAINDIR/ncl/script to plot data.
 *
 * \section test Test
 * A simple test script is available in $MAINDIR/script:
 *  - cd $MAINDIR/script
 *  - ./test.ksh
 *
 * It uses data stored in $MAINDIR/test and calls the NetCDF tools ncdump.
 *
 * \section model Adding a new model
 * To add a model $MODEL in nicas, you need to write a new module containing three routines:
 *  - model_$MODEL_coord to get model coordinates
 *  - model_$MODEL_read to read a model field
 *  - model_$MODEL_write to write a model field
 *
 * You need also to add three calls to model_$MODEL_coord, model_$MODEL_read and model_$MODEL_write in routines model_coord, model_read and model_write, respectively, which are contained in the module model_interface.
 *
 * Finally, you need to add a case for the namelist check in the routine namread, contained in the module module_namelist.
 *
 * For models with a regular grid, you can start from AROME, ARPEGE, IFS, GEM, GEOS, GFS, NEMO and WRF routines. For models with an unstructured grid, you can start from MPAS routines.
 *
 * \section change_log Change log
 * A log of the code updates is available here: <a target="_blank" href="http://benjaminmenetrier.free.fr/nicas/html/CHANGE_LOG.html">CHANGE_LOG</a>.
 */
