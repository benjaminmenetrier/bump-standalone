# BUMP-STANDALONE
B matrix on an Unstructured Mesh Package - Standalone package

This repository is in a transition phase: actually the **original** BUMP code is included in the [SABER](https://github.com/JCSDA/saber) project of the JCSDA. At the moment, the SABER repository is private (it should become public in August 2020). Thus, a **copy** is distributed here, which is not updated automatically and can be slightly out-of-date.

To build, compile and run the code, please follow the steps proposed in the script [install_bump-standalone.sh](install_bump-standalone.sh).
Previously, you need to download the JCSDA fork of [ecuild](https://github.com/JCSDA/ecbuild).

Please notice:
 - The test **saber_coding_norms** is failing in this temporary setting.
 - The BUMP executable is located in the `${BUILD_DIR}/bin/bump.x`
 - The usual command to run this executable is: `mpiexec -n ${NPROC} ${BUILD_DIR}/bin/bump.x ${INPUT_YAML_FILE} ${OUTPUT_LOG_DIRECTORY}` where `${NPROC}` is the number of MPI tasks.
