#!/bin/bash

# this file will be executed from the makefile

for i in $PYGAME_BUILDDIR/setup/*; do
    cat $i >> $PYTHON_BUILDDIR/Modules/Setup.dist
done