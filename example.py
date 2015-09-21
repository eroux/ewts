# simple python3 file importing the ewts shared object and converting ewts into unicode

import sys
import os.path
from ctypes import *

ewts = None
if os.path.isfile("./ewts.so"):
    ewts = cdll.LoadLibrary("./ewts.so")
else:
    ewts = cdll.LoadLibrary("ewts.so")

ewts_scan = ewts.ewts_scanner
ewts_scan.restype = c_char_p

def ewts_to_unicode(ewts_str):
    return ewts_scan(ewts_str.encode(encoding='UTF-8')).decode(encoding='UTF-8')

tabl = ["'drad"]

for t in tabl:
    print(ewts_to_unicode(t))
