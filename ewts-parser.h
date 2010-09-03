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

#ifndef TEWTS_TYPES_H
#define TEWTS_TYPES_H

#ifdef HAVE_STDINT_H
# include <stdint.h>
#else
# include <inttypes.h>
#endif

#if defined __WIN32__ || defined WIN32
# include <windows.h>
# define _EXPORT __declspec(dllexport)
#else
# define _EXPORT
#endif

// the public function
char* ewts_scanner(const char *argstr);

// two useful defs
#define NON_STANDARD_STACK 0
#define NON_COMBINABLE_STACK 1

// the state struct
typedef struct ewts_state {
  char *utfbuf;
  int utfbufindex;
  unsigned char last_is_plus;
  unsigned char current_state;
  unsigned char last_stack_num;
  unsigned char nb_vow;
} ewts_state;

// consonants
#define c_k 1
#define c_kh 2
#define c_g 3
#define c_ng 4
#define c_c 5
#define c_ch 6
#define c_j 7
#define c_ny 8
#define c_t 9
#define c_th 10
#define c_d 11
#define c_n 12
#define c_p 13
#define c_ph 14
#define c_b 15
#define c_m 16
#define c_ts 17
#define c_tsh 18
#define c_dz 19
#define c_w 20
#define c_zh 21
#define c_z 22
#define c_y 23
#define c_r 24
#define c_l 25
#define c_sh 26
#define c_s 27
#define c_h 28
#define c_none 29
#define c_R 30
#define c_D 31
#define c_dh 32
#define c_Dh 33
#define c_T 34
#define c_Th 35
#define c_N 36
#define c_Sh 37
#define c_gh 38
#define c_bh 39
#define c_dzh 40
#define c_apo 41
#define c_kSh 42
#define c_f 43
#define c_v 44
#define c_W 45
#define c_Y 46
#define c_OM 47

// the number of consonants (we fill 0 with 0 in order to align everything)
#define c_nb 48

// the stacks that can be combined
#define s_rk 48
#define s_rg 49
#define s_rm 50
#define s_sm 51
#define s_sk 52
#define s_sg 53
#define s_sp 54
#define s_sb 55
#define s_sn 56
#define s_rts 57
#define s_gr 58
#define s_dr 59
#define s_phy 60

// the number of stacks that can be combined
#define s_nb 13

// the number of consonnants + stacks
#define sc_nb 61

// vowels
#define v_a 1
#define v_i 2
#define v_u 3
#define v_e 4
#define v_o 5
#define v_ri 6
#define v_li 7
#define v_mini 8
#define v_A 9
#define v_I 10
#define v_U 11
#define v_ai 12
#define v_au 13
#define v_rI 14
#define v_lI 15
#define v_minI 16

// number of vowels
#define v_nb 17

// a portable wchar_t 
typedef uint32_t pwchar;

// the different states
#define S_INITIAL 1
#define S_WAIT_CONS 2
#define S_WAIT_END 3
#define S_END 4

static pwchar vowelchars[c_nb] = {0,
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

static char right_combine_r[c_nb] = {0, 
    s_rk, 0, s_rg, 1, 0, 0, 1, 1, 1, 0, 
    1, 1, 0, 0, 1, s_rm, s_rts, 0, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0};
    
static char right_combine_l[c_nb] = {0, 
    1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 
    0, 1, 0, 1, 1, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0};
    
static char right_combine_s[c_nb] = {0, 
    s_sk, 0, s_sg, 1, 0, 0, 0, 1, 1, 0, 
    1, s_sn, s_sp, 0, s_sb, 1, s_sm, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0};

static char left_combine_y[sc_nb] = {0, 
    1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 
    0, 0, 1, s_phy, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 1, 1, 1,
    1, 1, 1, 1, 1, 0, 0, 0, 0, 0};
    
static char left_combine_r[sc_nb] = {0, 
    1, 1, s_gr, 0, 0, 0, 0, 0, 1, 1, 
    s_dr, 0, 1, 1, 1, 1, 0, 0, 0, 1,
    0, 0, 0, 0, 0, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 0, 0, 0, 0};
    
static char left_combine_l[sc_nb] = {0, 
    1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 
    0, 0, 0, 0, 1, 0, 0, 0, 0, 0,
    0, 1, 0, 1, 0, 0, 1, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    
static char left_combine_w[sc_nb] = {0, 
    1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 
    1, 0, 0, 0, 0, 0, 1, 1, 0, 0,
    1, 1, 0, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
    0, 0, 0, 0, 0, 0, 1, 1, 1, 1};

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
L'ཀྵ',
// c_v
L'ཀྵ',
// c_W
0,
// c_Y
0,
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
