# generic compiler and linker settings:
CC     = gcc

ifeq ($(ARCH),)
    ARCH = $(shell uname -s)
endif

# generic platform specific rules:
ifeq ($(ARCH),Linux)
  POUET = $(shell echo prout)
  LUACFLAGS = $(shell pkg-config --cflags lua)
  LUALIBS   = $(shell pkg-config --libs lua)
  CFLAGS = -fPIC -O2 -c $(LUACFLAGS)
  SHLIBSUFFIX = .so
  LINKFLAGS = -shared -Wl,-no-undefined,-soname=LuaEWTS_lib$(SHLIBSUFFIX) $(LUALIBS)
else  
  ifeq ($(ARCH),Darwin) # MacOSX
    CFLAGS = -O2 -c
    SHLIBSUFFIX = .so
    LINKFLAGS = -bundle -L/usr/local/lib) -llua
  else  # debian has strange lua rules
    ifeq ($(ARCH),Debian)
      LUACFLAGS = $(shell pkg-config --cflags lua5.1)
      LUALIBS   = $(shell pkg-config --libs lua5.1)
      CFLAGS = -fPIC -O2 -c $(LUACFLAGS)
      SHLIBSUFFIX = .so
      LINKFLAGS = -shared -Wl,-no-undefined,-soname=LuaEWTS_lib$(SHLIBSUFFIX) $(LUALIBS)
    else # mingw
      CC = $(ARCH)-gcc
      ifeq ($(LINUXARCH),Debian)
        CFLAGS = $(shell pkg-config --cflags lua5.1) -02 -c
      else
        CFLAGS = $(shell pkg-config --cflags lua) -02 -c
      endif
      SHLIBSUFFIX = .dll
      LINKFLAGS = -shared -mconsole -s -Wl,-no-undefined,-soname=LuaEWTS_lib$(SHLIBSUFFIX) -L. -llua51
    endif
  endif
endif

all:  LuaEWTS_lib$(SHLIBSUFFIX)

LuaEWTS_lib$(SHLIBSUFFIX): ewts-parser.o
	$(CC) $(LINKFLAGS) -o $@ ewts-parser.o

ewts-parser.o:  ewts-parser.c ewts-parser.h
	$(CC) $(CFLAGS) ewts-parser.c -o $@
  
ewts-parser.c: ewts-parser.l
	flex ewts-parser.l

clean:
	@rm -f ewts-parser.c ewts-parser.o LuaEWTS_lib.dll LuaEWTS_lib.so 
