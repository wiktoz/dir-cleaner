#!/usr/bin/env bash
rm -rf X

mkdir X
cd X
mkdir Y1 Y2 Y3

# Duplicated file
echo "abba" > file1
echo "abba" > file2
mv file1 Y1
mv file2 Y2

# Duplicated file 2
echo "meer" > file
echo "meer" > file2
echo "meer" > file100
mv file Y3
mv file2 Y1
mv file100 Y1

# Unusual Permissions
echo "queen" > file2
chmod 777 file2
mv file2 Y3

# Unusual Permissions 2
echo "king" > fil33
chmod 477 fil33
 
# Empty file
touch file_empty
mv file_empty Y3

# Dangerous filename
echo "im dangerous" > "testfile_:;\*?\$\#\`\''"

# Temp file
echo "im temp" > file333.tmp
echo "im temp too" > file333~
mv file333.tmp Y1
mv file333~ Y2


