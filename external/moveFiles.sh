#!/bin/bash

curPath=$(pwd)
fromPath=$curPath$"/../export/mac64/neko/bin/PrismaticHaxe.app/Contents/Resources/assets/data"
toPath=$curPath$"/../assets/data"

if test -d $fromPath
  then
  if [[ $# == 0 ]]
    # Whole folder mode. Copies entire assets/data folder
    then
      echo "Moving all"
      if test -d $toPath
        then
        rm -r $toPath
      fi
      cp -rf $fromPath $toPath
  else
    # Specific file mode. Copies specified files within assets/data
    for f in "$@" 
    do
      fromFile=$fromPath$"/"$f
      toFile=$toPath$"/"$f

      if test -e $fromFile
        then
        echo $"Moving "$f
        cp -f $fromFile $toFile
      else
        echo $"Data file "$f$" doesn't exist"
      fi
    done
  fi    
else
  echo "Nothing to move"
fi