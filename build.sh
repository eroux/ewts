#!/usr/bin/env bash
#
# Public Domain
#
# script to build LuaEWTS library (inspired from LuaTeX's one).
# ----------
# Options:
#      --mingw     : crosscompile for mingw32 from i-386linux
      
# try to find bash, in case the standard shell is not capable of
# handling the generated configure's += variable assignments
if which bash >/dev/null
then
 CONFIG_SHELL=`which bash`
 export CONFIG_SHELL
fi

MINGWCROSS=FALSE

until [ -z "$1" ]; do
  case "$1" in
    --mingw     ) MINGWCROSS=TRUE    ;;
    *           ) echo "ERROR: invalid build.sh parameter: $1"; exit 1       ;;
  esac
  shift
done

ARCH=`uname -s`

LINUXARCH=Linux

if [ "$MINGWCROSS" = "TRUE" ]
then
  MINGWBUILD=$HOSTTYPE-$OSTYPE
  MINGWSTR=mingw32
  if [ -d /usr/mingw32 ]; then
    MINGWSTR=mingw32
  else
    if [ -d /usr/i386-mingw32msvc ]; then
      MINGWSTR=i386-mingw32msvc
    else
      if [ -d /usr/i586-mingw32msvc ]; then
        MINGWSTR=i586-mingw32msvc
      fi
    fi
  fi
  OLDPATH=$PATH
  PATH=/usr/$MINGWSTR/bin:$PATH
  ARCH=$MINGWSTR
fi

export ARCH LINUXARCH

make

if [ "$MINGWCROSS" = "TRUE" ]
then
  PATH=$OLDPATH
fi

