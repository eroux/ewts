# generic compiler and linker settings:
CC     = gcc
LD     = ld

ifeq ($(ARCH),)
    ARCH = $(shell uname -s)
endif

# generic platform specific rules:
ifeq ($(ARCH),Linux)
  POUET = $(shell echo prout)
  ifeq ($(LINUXARCH),Debian)
    LUACFLAGS = $(shell pkg-config --cflags lua5.1)
    LUALIBS   = $(shell pkg-config --libs lua5.1)
  else
    LUACFLAGS = $(shell pkg-config --cflags lua)
    LUALIBS   = $(shell pkg-config --libs lua)
  endif
  CFLAGS = -fPIC -O2 -c $(LUACFLAGS) -DENABLE_LUA
  SHLIBSUFFIX = .so
  LINKFLAGS = -shared -Wl,-no-undefined,-soname=LuaEWTS_lib$(SHLIBSUFFIX) $(LUALIBS)
else  
  ifeq ($(ARCH),Darwin) # MacOSX
    CFLAGS = -O2 -c
    SHLIBSUFFIX = .so
    LINKFLAGS = -bundle -L/usr/local/lib) -llua
  else  # mingw
    CC = $(ARCH)-gcc
    LD = $(ARCH)-ld
    ifeq ($(LINUXARCH),Debian)
      CFLAGS = $(shell pkg-config --cflags lua5.1) -02 -c -DENABLE_LUA
    else
      CFLAGS = $(shell pkg-config --cflags lua) -02 -c -DENABLE_LUA
    endif
    SHLIBSUFFIX = .dll
    LINKFLAGS = -shared -mconsole -s -Wl,-no-undefined,-soname=LuaEWTS_lib$(SHLIBSUFFIX) -L. -llua51
  endif
endif

all: lua perl

lua: LuaEWTS_lib$(SHLIBSUFFIX)

perl: ewts-parser.o ewts_wrap.c
	$(CC) -c ewts-parser.c ewts_wrap.c `perl -MExtUtils::Embed -e ccopts`
	ld -G ewts-parser.o ewts_wrap.o -o ewts.so

ewts_wrap.c: ewts.i
	swig -perl ewts.i

LuaEWTS_lib$(SHLIBSUFFIX): ewts-parser.o
	$(CC) $(LINKFLAGS) -o $@ ewts-parser.o

ewts-parser.o:  ewts-parser.c ewts-parser.h
	$(CC) $(CFLAGS) ewts-parser.c -o $@
  
ewts-parser.c: ewts-parser.l
	flex ewts-parser.l

clean:
	@rm -f ewts-parser.c ewts-parser.o LuaEWTS_lib.dll LuaEWTS_lib.so ewts_wrap.c ewts.pm ewts_wrap.o ewts.so
