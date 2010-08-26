-- 
-- luaewts library loading file.
-- Copyright 2010 Elie Roux <elie.roux@telecom-bretagne.eu>
-- 
-- This file is under the Creative Commons CC0 license.
-- 
-- See the full text at
-- 
-- http://creativecommons.org/publicdomain/zero/1.0/legalcode
-- 
-- and a FAQ at
-- 
-- http://wiki.creativecommons.org/CC0

require("LuaEWTS_lib")

module("ewts", package.seeall)

ewts.module = {
    name          = "ewts",
    version       = 0.7,
    date          = "2010/08/26",
    description   = "Extended Wylie tibetan transcription.",
    author        = "Elie Roux",
    copyright     = "Elie Roux",
    license       = "CC0"
}

if luatexbase and luatexbase.provides_module then
    luatexbase.provides_module(ewts.module)
end

catcodetable = -1

function ewts.translatetotex(str)
    tex.print(catcodetable, ewts.translate(str))
end
