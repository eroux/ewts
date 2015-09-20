/*

Common header file for the ewts library.
Copyright (C) 2010 Elie Roux <elie.roux@telecom-bretagne.eu>

luaewts library loading file.
Copyright 2010 Elie Roux <elie.roux@telecom-bretagne.eu>

This file is under the Creative Commons CC0 license.

See the full text at

http://creativecommons.org/publicdomain/zero/1.0/legalcode

and a FAQ at

http://wiki.creativecommons.org/CC0

*/

#ifndef EWTS_H
#define EWTS_H

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

// two useful defs
#define NON_STANDARD_STACK 0
#define NON_COMBINABLE_STACK 1

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

// signs
#define si_ca 1
#define si_tX 2
#define si_X 3
#define si_H 4
#define si_tM 5
#define si_M 6
#define si_tMq 7
#define si_qm 8

// number of vowels
#define si_nb 9

// a portable wchar_t 
typedef uint32_t pwchar;

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
    1, 0, 0, 0, 1, 0, 1, 1, 0, 0,
    1, 1, 0, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
    0, 0, 0, 0, 0, 0, 1, 1, 1, 1};

#endif
