#!/bin/bash

curPath=$(pwd)

if [[ ${curPath} != *"PrismaticHaxe" ]]
then
  echo "Current path is wrong, should be run with project root as WD"
  echo "Current path: "${curPath}
  exit 1
fi

#Copies directory $1 over directory $2
function moveAll {
  if test -d "$1"
    then
    echo "Moving all"
    if test -d "$1"
      then
      rm -r "$2"
    fi
    cp -rf "$1" "$2"
  else
    echo "Nothing to move. File location error?"
    echo "Got $1"
    exit 2
  fi
}

# Copies the files given by $3... from directory $1 to directory $2
function moveFiles {
  if test -d "$1"
    then
    for f in "${@:3}"
      do
      fromFile="$1"$"/"${f}
      toFile="$2""/"${f}

      if test -e ${fromFile}
        then
        echo $"Moving "${f}
        cp -f ${fromFile} ${toFile}
      else
        echo $"Data file "${f}$" doesn't exist"
      fi
    done
  else
    echo "Nothing to move. File location error?"
    echo "Got $1"
    exit 2
  fi
}

# Calls one of the two above depending on arg list
function move {
  echo "Performing file moving"
  echo "From $1"
  echo "To $2"

  if [[ $# == 2 ]]; then moveAll "$1" "$2"
  else moveFiles "$1" "$2" "${@:3}"
  fi
  echo "Done."
  echo ""
}


fromPath=${curPath}$"/export/mac64/neko/bin/PrismaticHaxe.app/Contents/Resources/assets/data"
toPath=${curPath}$"/assets/data"
move ${fromPath} ${toPath} "$@"

fromPath=${curPath}$"/export/mac64/neko/bin/PrismaticTests.app/Contents/assets/data"
toPath=${curPath}$"/PrismaticTests/testAssets/data"
move ${fromPath} ${toPath} "$@"
