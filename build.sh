#!/bin/bash

haxe build.hxml

if [ $? -ne 0 ]; then
    echo build failed
    exit $?
fi

mkdir -p dist
rm -f dist/*.zip

cd bin-runtime && zip -ry ../dist/neko_runtime.zip * && cd ..

cd bin-example && zip -ry ../dist/lambda_function.zip * && cd ..

LIBNAME=awslambda-neko

if [ -a "$LIBNAME.zip" ]; then
    rm -f "$LIBNAME.zip"
fi
zip -r "$LIBNAME.zip" haxelib.json src bin-runtime/bootstrap bin-runtime/lib LICENSE lgpl-3.0.txt README.md
echo "Saved as $LIBNAME.zip"
