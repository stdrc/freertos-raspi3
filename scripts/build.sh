#!/bin/bash

if [ ! -d build ]; then
  mkdir build
fi
make clean
make