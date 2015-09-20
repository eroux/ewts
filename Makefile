# generic compiler and linker settings:
CC     = gcc
LD     = ld

ifeq ($(ARCH),)
    ARCH = $(shell uname -s)
endif

# generic platform specific rules:
ifeq ($(ARCH),Linux)
  CFLAGS = -fPIC -O2 -c
  SHLIBSUFFIX = .so
  LINKFLAGS = -shared -Wl,-no-undefined
else  
  ifeq ($(ARCH),Darwin) # MacOSX
    CFLAGS = -O2 -c
    SHLIBSUFFIX = .so
    LINKFLAGS = -bundle -L/usr/local/lib
  else  # mingw
    CC = $(ARCH)-gcc
    LD = $(ARCH)-ld
    CFLAGS = -O2 -c
    SHLIBSUFFIX = .dll
    LINKFLAGS = -shared -mconsole -s -Wl,-no-undefined,-soname=ewts$(SHLIBSUFFIX) -L.
  endif
endif

all: ewts$(SHLIBSUFFIX)

ewts-parser.o:  ewts-parser.c ewts-parser.h
	$(CC) $(CFLAGS) ewts-parser.c -o $@
  
ewts-parser.c: ewts-parser.l
	flex ewts-parser.l

ewts$(SHLIBSUFFIX): ewts-parser.o
	$(CC) $(LINKFLAGS) ewts-parser.o -o ewts$(SHLIBSUFFIX)

clean:
	@rm -f ewts-parser.c ewts-parser.o ewts.so
