%{
/*

Tewts parser for the luaewts library.
Copyright (C) 2010 Elie Roux <elie.roux@telecom-bretagne.eu>

luaewts library loading file.
Copyright 2010 Elie Roux <elie.roux@telecom-bretagne.eu>

This file is under the Creative Commons CC0 license.

See the full text at

http://creativecommons.org/publicdomain/zero/1.0/legalcode

and a FAQ at

http://wiki.creativecommons.org/CC0

*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h> /*for tolower*/
#include "ewts-parser.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

unsigned char last_is_plus = 0;
unsigned char current_state = S_INITIAL;
unsigned char last_cons_num = 0;
unsigned char nb_cons = 0;
char nb_vow = 0;

// everything is made with globar variables, which is a bit dangerous...
// patches accepted ;)

// string writing variables
char *utfbuf = NULL;
int utfbufindex = 0;

#define _reinitialize() \
 last_is_plus = 0;\
 current_state = S_INITIAL;\
 last_cons_num = 0;\
 nb_cons = 0;\
 nb_vow = 0;

// this function prints a char in utfbuf in utf8 and sets bufindex accordingly
void
print_unichar (pwchar to_print)
{
  char *buf = utfbuf + utfbufindex;
  if (!to_print)
    {
      return;
    }
  if (to_print <= 0x7F)
    {
      sprintf (buf, "%c", (unsigned char) to_print);
      utfbufindex = utfbufindex + 1;
      return;
    }
  if (to_print >= 0x80 && to_print <= 0x7FF)
    {
      sprintf (buf, "%c%c", 0xC0 | (to_print >> 6), 0x80 | (to_print & 0x3F));
      utfbufindex = utfbufindex + 2;
      return;
    }
  if ((to_print >= 0x800 && to_print <= 0xD7FF) ||
      (to_print >= 0xE000 && to_print <= 0xFFFF))
    {
      sprintf (buf, "%c%c%c", 0xE0 | (to_print >> 12),
	       0x80 | ((to_print >> 6) & 0x3F), 0x80 | (to_print & 0x3F));
	    utfbufindex = utfbufindex + 3;
	    return;
    }
  if (to_print >= 0x10000 && to_print <= 0x10FFFF)
    {
      sprintf (buf, "%c%c%c%c", 0xF0 | (to_print >> 18),
	       0x80 | ((to_print >> 12) & 0x3F),
	       0x80 | ((to_print >> 6) & 0x3F), 0x80 | (to_print & 0x3F));
	    utfbufindex = utfbufindex + 4;
    }
}

// helper
#define elsereinit() \
    else \
      {\
         _reinitialize()\
         print_unichar(cons_initial[cons]);\
         current_state = S_WAIT_CONS;\
         nb_cons = nb_cons + 1;\
      }

void
add_cons(unsigned char cons)
{
  if (nb_vow != 0)
    {
      _reinitialize();
    }
  switch(current_state)
    {
      case S_INITIAL:
        print_unichar(cons_initial[cons]);
        current_state = S_WAIT_CONS;
        nb_cons = nb_cons + 1;
        break;
      case S_WAIT_CONS:
        if (last_is_plus == 1)
          {
            print_unichar(cons_subjoined[cons]);
            current_state = S_WAIT_END;
            nb_cons = nb_cons + 1;
          }
        else
          {
            switch(last_cons_num)
              {
                case c_r:
                  if (right_combine_r[cons] == 1)
                    {
                      print_unichar(cons_subjoined[cons]);
                      current_state = S_WAIT_END;
                      nb_cons = nb_cons + 1;
                    }
                  elsereinit();
                  break;
                case c_l:
                  if (right_combine_l[cons] == 1)
                    {
                      print_unichar(cons_subjoined[cons]);
                      current_state = S_WAIT_END;
                      nb_cons = nb_cons + 1;
                    }
                  elsereinit();
                  break;
                case c_s:
                  if (right_combine_s[cons] == 1)
                    {
                      print_unichar(cons_subjoined[cons]);
                      current_state = S_WAIT_END;
                      nb_cons = nb_cons + 1;
                    }
                  elsereinit();
                  break;
                default:
                  _reinitialize()
                  print_unichar(cons_initial[cons]);
                  current_state = S_WAIT_CONS;
                  nb_cons = nb_cons + 1;
              }
          }
        break;
      default:
        // S_WAIT_END, quite similar
        if (last_is_plus == 1)
          {
            print_unichar(cons_subjoined[cons]);
            nb_cons = nb_cons + 1;
          }
        else
          {
            switch(cons)
              {
                case c_r:
                  if (left_combine_r[cons] == 1 && nb_cons < 3)
                    {
                      print_unichar(cons_subjoined[cons]);
                      nb_cons = nb_cons + 1;
                    }
                  elsereinit();
                  break;
                case c_l:
                  if (left_combine_l[cons] == 1 && nb_cons < 3)
                    {
                      print_unichar(cons_subjoined[cons]);
                      nb_cons = nb_cons + 1;
                    }
                  elsereinit();
                  break;
                case c_w:
                  if (left_combine_w[cons] == 1 && nb_cons < 3)
                    {
                      print_unichar(cons_subjoined[cons]);
                      nb_cons = nb_cons + 1;
                    }
                  elsereinit();
                  break;
                case c_y:
                  if (left_combine_y[cons] == 1 && nb_cons < 3)
                    {
                      print_unichar(cons_subjoined[cons]);
                      nb_cons = nb_cons + 1;
                    }
                  elsereinit();
                  break;
                default:
                  _reinitialize()
                  print_unichar(cons_initial[cons]);
                  nb_cons = nb_cons + 1;
                  current_state = S_WAIT_CONS;
                  
              }
          }
        break;
    }
  last_cons_num = cons;
  last_is_plus = 0;
}

void
add_vowel(unsigned char vow)
{
  if (current_state == S_INITIAL)
    {
      print_unichar(cons_initial[c_none]);
      print_unichar(vowelchars[vow]);
      nb_vow = nb_vow + 1;
      return;
    }
  if (current_state == S_WAIT_CONS && vow == v_a && last_is_plus == 1)
    {
      print_unichar(cons_subjoined[c_none]);
      return;
    }
  if (last_is_plus == 1 || nb_vow == 0)
    {
      print_unichar(vowelchars[vow]);
      nb_vow = nb_vow + 1;
    }
  else
    {
      _reinitialize();
      print_unichar(cons_initial[c_none]);
      print_unichar(vowelchars[vow]);
    }
  last_is_plus = 0;
}

void
add_other(pwchar num)
{
  _reinitialize();
  print_unichar(num);
}

void
add_verb(char *str)
{
  _reinitialize();
  sprintf (utfbuf+utfbufindex, "%s", str);
	utfbufindex = utfbufindex + (int) strlen(str);
}

#define add_num(num) add_other(digchars[num]);

#define plus_sign() last_is_plus = 1;

#define dot_sign() _reinitialize();

#define add_uni(str) add_other(strtol(str, NULL, 16));

%}

%option stack
%option pointer
%option nounput
%option noyy_push_state 
%option noyy_pop_state
%option noyy_top_state
%option full
%option noread
%option nomain
%option align
%option noyylineno
%option prefix="ewts_"
%option outfile="ewts-parser.c"
%option noyywrap

%x verb

%%
\[    { BEGIN(verb); }
<verb>[^\]]+ { add_verb(strdup(ewts_text)); }
<verb>\]     { BEGIN(INITIAL); }
\\u[0-9a-fA-F]{3,4}     { add_uni(ewts_text+2); }
k     { add_cons(c_k); }
c     { add_cons(c_c); }
kh    { add_cons(c_kh); }
g     { add_cons(c_g); }
ng    { add_cons(c_ng); }
ch    { add_cons(c_ch); }
j     { add_cons(c_j); }
ny    { add_cons(c_ny); }
t     { add_cons(c_t); }
th    { add_cons(c_th); }
d     { add_cons(c_d); }
n     { add_cons(c_n); }
p     { add_cons(c_p); }
ph    { add_cons(c_ph); }
b     { add_cons(c_b); }
m     { add_cons(c_m); }
ts    { add_cons(c_ts); }
tsh   { add_cons(c_tsh); }
dz    { add_cons(c_dz); }
w     { add_cons(c_w); }
zh    { add_cons(c_zh); }
z     { add_cons(c_z); }
'     { add_cons(c_apo); }
y     { add_cons(c_y); }
r     { add_cons(c_r); }
l     { add_cons(c_l); }
sh    { add_cons(c_sh); }
s     { add_cons(c_s); }
h     { add_cons(c_h); }
R     { add_cons(c_R); }
D     { add_cons(c_D); }
(dh|d\+h)    { add_cons(c_dh); }
(Dh|D\+h)    { add_cons(c_Dh); }
T     { add_cons(c_T); }
Th    { add_cons(c_Th); }
N     { add_cons(c_N); }
Sh    { add_cons(c_Sh); }
(gh|g\+h)    { add_cons(c_gh); }
(bh|b\+h)    { add_cons(c_bh); }
(dzh|dz\+h)  { add_cons(c_dzh); }
(kSh|k+Sh)   { add_cons(c_kSh); }
f     { add_cons(c_f); }
v     { add_cons(c_v); }
(om|Om|OM|oM) { add_cons(c_OM); }
W     { add_cons(c_W); }
Y     { add_cons(c_Y); }
a     { add_vowel(v_a); }
i     { add_vowel(v_i); }
u     { add_vowel(v_u); }
e     { add_vowel(v_e); }
o     { add_vowel(v_o); }
r-i   { add_vowel(v_ri); }
l-i   { add_vowel(v_li); }
-i    { add_vowel(v_mini); }
A     { add_vowel(v_A); }
I     { add_vowel(v_I); }
U     { add_vowel(v_U); }
ai    { add_vowel(v_ai); }
au    { add_vowel(v_au); }
r-I   { add_vowel(v_rI); }
l-I   { add_vowel(v_lI); }
-I    { add_vowel(v_minI); }
[0-9] { add_num(ewts_text[0]-48); }
\/    { add_other(0xf0d); }
\/\/  { add_other(0xf0e); }
;     { add_other(0xf0f); }
\|    { add_other(0xf11); }
!     { add_other(0xf08); }
:     { add_other(0xf14); }
_     { add_other(' '); }
\     { add_other(0xf0b); }
\*    { add_other(0xf0c); }
@     { add_other(0xf04); }
#     { add_other(0xf05); }
\$    { add_other(0xf06); }
\%    { add_other(0xf07); }
\<    { add_other(0xf3a); }
>     { add_other(0xf3b); }
\(    { add_other(0xf3c); }
\)    { add_other(0xf3d); }    
=     { add_other(0xf34); }
\^    { add_other(0xf39); } 
~X    { add_other(0xf35); } 
X     { add_other(0xf37); } 
M     { add_other(0xf7e); } 
H     { add_other(0xf7f); } 
~M`   { add_other(0xf82); } 
~M    { add_other(0xf83); } 
\?    { add_other(0xf84); }
&     { add_other(0xf85); }
\+    { plus_sign(); }
\.    { dot_sign(); }
.     {   /* Ignore all other characters. */   }

%%

// quite useful template if you whish to integrate a lib into LuaTeX.
static int ewts_scanner(lua_State *L)
{
    YY_BUFFER_STATE ybuf;
    size_t len = 0;
    char *argstr;
    if (!lua_isstring(L, 1))
      {
        lua_pushnil(L);
        lua_pushstring(L, "incorrect argument, string expected");
        lua_error(L);
        return 0;
      }
    argstr = luaL_checklstring(L, 1, &len);
    utfbuf = (char *) malloc((len*4+1)*sizeof(char));
    utfbufindex = 0;
    ybuf=yy_scan_string(argstr);
    yylex();
    yy_flush_buffer(ybuf);
    yy_delete_buffer(ybuf);
    utfbuf[utfbufindex] = 0;
    lua_pushstring(L, utfbuf);
    free(utfbuf);
    return 1;
}

int _EXPORT luaopen_LuaEWTS_lib (lua_State* L) {
        static const struct luaL_Reg funcs[] = {
                {"translate", ewts_scanner},
                {NULL, NULL}
        };
        luaL_register(L, "ewts", funcs);
        return 1;
}

