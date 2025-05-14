#!/usr/bin/env bash

mkdir X
cd X
mkdir Y1 Y2 Y3

echo "abba" > file1
mv file1 Y1

echo "abba" > file2
mv file2 Y2

echo "queen" > file2
mv file2 Y3
