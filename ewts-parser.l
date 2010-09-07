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
#include "ewts-parser.h"
#ifndef ENABLE_LUA
#define ENABLE_LUA 0
#endif
#if ENABLE_LUA == 1
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#endif


// we redeclare yylex to pass an argument to it
#define YY_DECL int ewts_lex (ewts_state *curstate)

// the state is a global variable... looking for passing arguments to yylex...
//ewts_state *curstate;

inline void ewts_reinitialize(ewts_state *s)
{
  s->last_is_plus = 0;
  s->current_state = S_INITIAL;
  s-> last_stack_num = 0;
  s->nb_vow = 0;
}

#define _reinitialize() \
 ewts_reinitialize(curstate);

// this function prints a char in utfbuf in utf8 and sets bufindex accordingly
void
ewts_print_unichar (pwchar to_print, ewts_state *curstate)
{
  char *buf = curstate->utfbuf + curstate->utfbufindex;
  if (!to_print)
    {
      return;
    }
  if (to_print <= 0x7F)
    {
      sprintf (buf, "%c", (unsigned char) to_print);
      curstate->utfbufindex = curstate->utfbufindex + 1;
      return;
    }
  if (to_print >= 0x80 && to_print <= 0x7FF)
    {
      sprintf (buf, "%c%c", 0xC0 | (to_print >> 6), 0x80 | (to_print & 0x3F));
      curstate->utfbufindex = curstate->utfbufindex + 2;
      return;
    }
  if ((to_print >= 0x800 && to_print <= 0xD7FF) ||
      (to_print >= 0xE000 && to_print <= 0xFFFF))
    {
      sprintf (buf, "%c%c%c", 0xE0 | (to_print >> 12),
	       0x80 | ((to_print >> 6) & 0x3F), 0x80 | (to_print & 0x3F));
	    curstate->utfbufindex = curstate->utfbufindex + 3;
	    return;
    }
  if (to_print >= 0x10000 && to_print <= 0x10FFFF)
    {
      sprintf (buf, "%c%c%c%c", 0xF0 | (to_print >> 18),
	       0x80 | ((to_print >> 12) & 0x3F),
	       0x80 | ((to_print >> 6) & 0x3F), 0x80 | (to_print & 0x3F));
	    curstate->utfbufindex = curstate->utfbufindex + 4;
    }
}

#define print_unichar(char) ewts_print_unichar(char, curstate);

// helper
#define elsereinit() \
    else \
      {\
         _reinitialize()\
         print_unichar(cons_initial[cons]);\
         curstate->current_state = S_WAIT_CONS;\
         curstate->nb_cons = curstate->nb_cons + 1;\
      }


// a function that returns the result of the combination of consone and constwo
// result is NON_STANDARD_STACK, NON_COMBINABLE_STACK or the standard combinable stack number
unsigned char
// consone can be also a stack
ewts_combine(unsigned char consone, unsigned char constwo)
{
  switch(consone)
  {
    case c_r:
      return right_combine_r[constwo];
      break;
    case c_l:
      return right_combine_l[constwo];
      break;
    case c_s:
      return right_combine_s[constwo];
      break;
    default:
      break;
  }
  switch(constwo)
  {
    case c_y:
      return left_combine_y[consone];
      break;
    case c_r:
      return left_combine_r[consone];
      break;
    case c_l:
      return left_combine_l[consone];
      break;
    case c_w:
      return left_combine_w[consone];
      break;
    default:
      return NON_STANDARD_STACK;
      break;
  }
}

void
ewts_add_cons(unsigned char cons, ewts_state *curstate)
{
  unsigned char newstack = 0;
  if (curstate->nb_vow != 0)
    {
      _reinitialize();
    }
  switch(curstate->current_state)
    {
      case S_INITIAL:
        print_unichar(cons_initial[cons]);
        curstate->current_state = S_WAIT_CONS;
        curstate->last_stack_num = cons;
        break;
      case S_WAIT_CONS:
      case S_WAIT_END:
        newstack = ewts_combine(curstate->last_stack_num, cons);
        if (newstack == NON_STANDARD_STACK && curstate->last_is_plus == 0)
          {
            _reinitialize();
            print_unichar(cons_initial[cons]);
            curstate->current_state = curstate->current_state + 1;
            curstate->last_stack_num = cons;
          }
        else
          {
            print_unichar(cons_subjoined[cons]);
            curstate->current_state = S_WAIT_END;
            curstate->last_stack_num = newstack;
          }
        break;
      default:
      //case S_END:
        if (curstate->last_is_plus == 1)
          {
            print_unichar(cons_subjoined[cons]);
            curstate->last_stack_num = NON_STANDARD_STACK;
          }
        else
          {
            _reinitialize();
            print_unichar(cons_initial[cons]);
            curstate->current_state = curstate->current_state + 1;
            curstate->last_stack_num = cons;
          }
        break;
    }
  curstate->last_is_plus = 0;
}

void
ewts_add_vowel(unsigned char vow, ewts_state *curstate)
{
  if (curstate->current_state == S_INITIAL)
    {;
      print_unichar(cons_initial[c_none]);
      print_unichar(vowelchars[vow]);
      curstate->nb_vow = curstate->nb_vow + 1;
      return;
    }
  if (curstate->current_state == S_WAIT_CONS && vow == v_a && curstate->last_is_plus == 1)
    {
      print_unichar(cons_subjoined[c_none]);
      curstate->current_state = S_WAIT_END;
      return;
    }
  if (curstate->last_is_plus == 1 || curstate->nb_vow == 0)
    {
      print_unichar(vowelchars[vow]);
      curstate->nb_vow = curstate->nb_vow + 1;
    }
  else
    {
      _reinitialize();
      print_unichar(cons_initial[c_none]);
      print_unichar(vowelchars[vow]);
    }
  curstate->last_is_plus = 0;
}

void 
ewts_add_ambiguous(unsigned char one_vow, unsigned char two_cons, unsigned char two_vow, ewts_state *curstate)
{
  if (curstate->current_state == S_INITIAL || curstate->last_is_plus)
    {
      ewts_add_cons(two_cons, curstate);
      ewts_add_vowel(two_vow, curstate);
    }
  else
    {
      ewts_add_vowel(one_vow, curstate);
    }
}

void
ewts_add_other(pwchar num, ewts_state *curstate)
{
  _reinitialize();
  print_unichar(num);
}

void
ewts_add_verb(char *str, ewts_state *curstate)
{
  _reinitialize();
  sprintf (curstate->utfbuf+curstate->utfbufindex, "%s", str);
	curstate->utfbufindex = curstate->utfbufindex + (int) strlen(str);
}

#define add_cons(num) ewts_add_cons(num, curstate);

#define add_vowel(num) ewts_add_vowel(num, curstate);

#define add_ambiguous(num, numtwo, numthree) ewts_add_ambiguous(num, numtwo, numthree, curstate);

#define add_verb(str) ewts_add_verb(str, curstate);

#define add_num(num) ewts_add_other(digchars[num], curstate);

#define plus_sign() curstate->last_is_plus = 1;

#define dot_sign() ewts_reinitialize(curstate);

#define add_uni(str) ewts_add_other(strtol(str, NULL, 16), curstate);

#define add_other(num) ewts_add_other(num, curstate)

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
\\[^u]     { add_other(ewts_text[1]); }
\+a     { plus_sign(); add_cons(c_none); }
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
(OM|oM) { add_cons(c_OM); }
W     { add_cons(c_W); }
Y     { add_cons(c_Y); }
a     { add_vowel(v_a); }
i     { add_vowel(v_i); }
u     { add_vowel(v_u); }
e     { add_vowel(v_e); }
o     { add_vowel(v_o); }
r-i   { add_ambiguous(v_ri, c_r, v_mini); }
l-i   { add_ambiguous(v_li, c_l, v_mini); }
-i    { add_vowel(v_mini); }
A     { add_vowel(v_A); }
I     { add_vowel(v_I); }
U     { add_vowel(v_U); }
ai    { add_vowel(v_ai); }
au    { add_vowel(v_au); }
r-I   { add_ambiguous(v_rI, c_r, v_minI); }
l-I   { add_ambiguous(v_lI, c_l, v_minI); }
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

ewts_state *new_state()
{
  ewts_state *s;
  s = malloc (sizeof (ewts_state));
  s->utfbuf = NULL;
  s->utfbufindex = 0;
  s->last_is_plus = 0;
  s->current_state = S_INITIAL;
  s-> last_stack_num = 0;
  s->nb_vow = 0;
  return s;
}

char* ewts_scanner(const char *argstr)
{
    YY_BUFFER_STATE ybuf;
    size_t len = 0;
    ewts_state *curstate = new_state();
    len = strlen(argstr);
    curstate->utfbuf = (char *) malloc((len*4+1)*sizeof(char));
    ybuf=yy_scan_string(argstr);
    ewts_lex(curstate);
    yy_flush_buffer(ybuf);
    yy_delete_buffer(ybuf);
    curstate->utfbuf[curstate->utfbufindex] = 0;
    return curstate->utfbuf;
}

#if ENABLE_LUA == 1
// Lua bindings

// quite useful template if you whish to integrate a lib into LuaTeX.
static int lua_ewts_scanner(lua_State *L)
{
    const char *argstr;
    char *res;
    if (!lua_isstring(L, 1))
      {
        lua_pushnil(L);
        lua_pushstring(L, "incorrect argument, string expected");
        lua_error(L);
        return 0;
      }
    argstr = luaL_checklstring(L, 1, NULL);
    res = ewts_scanner(argstr);
    lua_pushstring(L, res);
    free(res);
    return 1;
}

int _EXPORT luaopen_LuaEWTS_lib (lua_State* L) {
        static const struct luaL_Reg funcs[] = {
                {"translate", lua_ewts_scanner},
                {NULL, NULL}
        };
        luaL_register(L, "ewts", funcs);
        return 1;
}
#endif
