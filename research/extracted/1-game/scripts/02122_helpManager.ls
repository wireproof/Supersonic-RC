-- Script
property pBG
property pScriptToStart
global gMainManager

on new me
  pBG = script("standardbutton").new([#range: ["help"], #name: "bg"])
  pBG.setActionCallback(script("callback").new(#bgClicked, me))
  return me
end
on bgClicked me
  sound(8).fadeOut(500)
  script("fadeout").new(script("callback").new(#start, pScriptToStart.new()))
end
on start me, tScriptToStart
  pScriptToStart = tScriptToStart
  script("fadein").new()
  mach8_go("help")
end