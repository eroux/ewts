/*

Declarations for the EWTS->Unicode parser.
Copyright (C) 2010 Elie Roux <elie.roux@telecom-bretagne.eu>

luaewts library loading file.
Copyright 2010 Elie Roux <elie.roux@telecom-bretagne.eu>

This file is under the Creative Commons CC0 license.

See the full text at

http://creativecommons.org/publicdomain/zero/1.0/legalcode

and a FAQ at

http://wiki.creativecommons.org/CC0

*/

#ifndef EWTS_PARSER_H
#define EWTS_PARSER_H

#include "ewts-common.h"

// the public function
char* ewts_scanner(const char *argstr);

// the state struct
typedef struct ewts_state {
  char *utfbuf;
  int utfbufindex;
  unsigned char last_is_plus;
  unsigned char current_state;
  unsigned char last_stack_num;
  unsigned char syllable_state;
  unsigned char nb_vow;
} ewts_state;


// the different states
#define S_INITIAL 1
#define S_WAIT_CONS 2
#define S_END 3

static pwchar vowelchars[v_nb] = {0,
// v_a
0,
// v_i
0xf72,
// v_u
0xf74,
// v_e
0xf7a,
// v_o
0xf7c,
// v_ri
0xf76,
// v_li
0xf78,
// v_mini
0xf80,
// v_A
0xf71,
// v_I
0xf73,
// v_U
0xf75,
// v_ai
0xf7b,
// v_au
0xf7d,
// v_rI
0xf77,
// v_lI
0xf79,
// v_minI
0xf81,
};

static pwchar cons_initial[c_nb] = {0,
// c_k
L'ཀ',
// c_kh
L'ཁ',
// c_g
L'ག',
// c_ng
L'ང',
// c_c
L'ཅ',
// c_ch
L'ཆ',
// c_j
L'ཇ',
// c_ny
L'ཉ',
// c_t
L'ཏ',
// c_th
L'ཐ',
// c_d
L'ད',
// c_n
L'ན',
// c_p
L'པ',
// c_ph
L'ཕ',
// c_b
L'བ',
// c_m
L'མ',
// c_ts
L'ཙ',
// c_tsh
L'ཚ',
// c_dz
L'ཛ',
// c_w
L'ཝ',
// c_zh
L'ཞ',
// c_z
L'ཟ',
// c_y
L'ཡ',
// c_r
L'ར',
// c_l
L'ལ',
// c_sh
L'ཤ',
// c_s
L'ས',
// c_h
L'ཧ',
// c_none
L'ཨ',
// c_R
L'ཪ',
// c_D
L'ཌ',
// c_dh
L'དྷ',
// c_Dh
L'ཌྷ',
// c_T
L'ཊ',
// c_Th
L'ཋ',
// c_N
L'ཎ',
// c_Sh
L'ཥ',
// c_gh
L'གྷ',
// c_bh
L'བྷ',
// c_dzh
L'ཛྷ',
// c_apo
L'འ',
// c_kSh
L'ཀྵ',
// c_f
1,
// c_v
2,
// c_W
L'ཝ',
// c_Y
L'ཡ',
// c_OM
L'ༀ',
};

static pwchar cons_subjoined[c_nb] = {0,
// c_k
0xf90,
// c_kh
0xf91,
// c_g
0xf92,
// c_ng
0xf94,
// c_c
0xf95,
// c_ch
0xf96,
// c_j
0xf97,
// c_ny
0xf99,
// c_t
0xf9f,
// c_th
0xfa0,
// c_d
0xfa1,
// c_n
0xfa3,
// c_p
0xfa4,
// c_ph
0xfa5,
// c_b
0xfa6,
// c_m
0xfa8,
// c_ts
0xfa9,
// c_tsh
0xfaa,
// c_dz
0xfab,
// c_w
0xfad,
// c_zh
0xfae,
// c_z
0xfaf,
// c_y
0xfb1,
// c_r
0xfb2,
// c_l
0xfb3,
// c_sh
0xfb4,
// c_s
0xfb6,
// c_h
0xfb7,
// c_none
0xfb8,
// c_R
0xfbc,
// c_D
0xf9c,
// c_dh
0xfa2,
// c_Dh
0xf9d,
// c_T
0xf9a,
// c_Th
0xf9b,
// c_N
0xf9e,
// c_Sh
0xfb5,
// c_gh
0xf93,
// c_bh
0xfa7,
// c_dzh
0xfac,
// c_apo
0xfb0,
// c_kSh
0xfb9,
// c_f
0,
// c_v
0,
// c_W
0xfba,
// c_Y
0xfbb,
// c_OM
0,
};

// digits

static pwchar digchars[c_nb] = {
0xf20,
0xf21,
0xf22,
0xf23,
0xf24,
0xf25,
0xf26,
0xf27,
0xf28,
0xf29,
};

#endif
