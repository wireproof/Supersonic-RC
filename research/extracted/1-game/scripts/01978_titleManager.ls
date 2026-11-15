-- Script
property pBG
global gMainManager

on new me
  pBG = script("standardbutton").new([#range: ["title"], #name: "bg"])
  pBG.setActionCallback(script("callback").new(#bgClicked, me))
  return me
end
on bgClicked me
  script("fadeout").new(script("callback").new(#start, gMainManager.getSelectLevelManager()))
end
on start me
  script("fadein").new()
  mach8_go("title")
end