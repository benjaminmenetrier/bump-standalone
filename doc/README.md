# README

The documentation has to be built from the source code using "doxygen" (see: [www.doxygen.org](http://www.doxygen.org)). This is done like this:

    cd doc
    doxygen Doxyfile

You can control the contents of the documentation by editing doxyfile. For example, if the "dot" tool from graphviz [www.graphviz.org](http://www.graphviz.org) is available on your system, you can generate call graphs by setting
CALL_GRAPH to YES.

Once the documentation is built, point your web browser at:
doc/html/index.html
