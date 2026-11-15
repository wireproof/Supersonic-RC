-- Script
property pLevels
global gMainManager

on new me
  pBG = script("sprite").new([#range: ["selectlevel"], #name: "bg"])
  pLevels = [:]
  tButton = script("standardbutton").new([#range: ["selectlevel"], #name: "free"])
  pLevels.addProp(tButton, script("free_driving"))
  tButton = script("standardbutton").new([#range: ["selectlevel"], #name: "checkpoint"])
  pLevels.addProp(tButton, script("checkpoint_chase"))
  tButton = script("standardbutton").new([#range: ["selectlevel"], #name: "stunt"])
  pLevels.addProp(tButton, script("stunt_rally"))
  tButton = script("standardbutton").new([#range: ["selectlevel"], #name: "scavenger"])
  pLevels.addProp(tButton, script("scavenger_hunt"))
  tButton = script("standardbutton").new([#range: ["selectlevel"], #name: "supersonic"])
  pLevels.addProp(tButton, script("supersonic_challenge"))
  repeat with i = 1 to pLevels.count
    pLevels.getPropAt(i).setActionCallback(script("callback").new(#buttonClicked, me, pLevels.getPropAt(i)))
    if i > 1 then
      pLevels.getPropAt(i).Disable()
    end if
  end repeat
  if debugModus() or the controlDown then
    repeat with i = 1 to pLevels.count
      pLevels.getPropAt(i).enable()
    end repeat
  end if
  return me
end
on start me
  the actorList = []
  script("fadein").new()
  mach8_go("selectlevel")
  sound(8).play([#member: member("SSRMusicSplashScreen"), #loopCount: 0])
end
on destroy me
  return 0
end
on unlock me, tName
  repeat with i = 1 to pLevels.count
    if pLevels[i] = script(tName) then
      pLevels.getPropAt(i).enable()
    end if
  end repeat
end
on buttonClicked me, tButton
  script("fadeout").new(script("callback").new(#start, gMainManager.getHelpManager(), pLevels[tButton]))
end