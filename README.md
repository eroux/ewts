# EWTS to Unicode library

This repository contains the code of a minimal [ewts](http://www.thlib.org/reference/transliteration/#!essay=/thl/ewts/intro/) to unicode conversion library. Its api is only one function:

    char* ewts_scanner(const char *argstr)

it is designed to be super-efficient and easily useable in any language. You can bind it to your favorite language with [swig](http://www.swig.org/) with the [ewts.i](ewts.i) file, or use it directly from python following the [example.py](example.py) example.

## Dependencies

The library is built using [GNU flex](http://flex.sourceforge.net/), so you obviously need it, as well as a C compiler.

## Compilation

Run `make` to compile `ewts.so` or `./build.sh --mingw` to compile `ewts.dll` for Windows.

## License

The files are under [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed).
