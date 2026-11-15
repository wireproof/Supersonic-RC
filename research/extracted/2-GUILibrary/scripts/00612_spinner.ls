-- Script
property pUpButton
property pDownButton
property pSpeed
property pSpinning
property pPulseCallback
property pLastSpinMouseLoc
property pEnabled

on new me, tPulseCallback, tParams
  pPulseCallback = tPulseCallback
  pLoc = point(0, 0)
  pSpeed = 0.3
  if voidp(tParams[#loc]) = 0 then
    pLoc = tParams[#loc]
  end if
  if voidp(tParams[#speed]) = 0 then
    pSpeed = tParams[#speed]
  end if
  pUpButton = script("spinnerbutton").rawNew()
  pDownButton = script("spinnerbutton").rawNew()
  tParams[#direction] = #up
  pUpButton.new(me, tParams)
  tParams[#direction] = #down
  pDownButton.new(me, tParams)
  pEnabled = 1
  pSpinning = 0
  return me
end
on stepFrame me
  if pSpinning = 0 then
    exit
  end if
  tDif = the mouseV - pLastSpinMouseLoc
  if abs(tDif) > 0 then
    tModifier = 1
    if the shiftDown then
      tModifier = 10
    end if
    if the controlDown then
      tModifier = 0.1
    end if
    tHadEffect = doCallback(pPulseCallback, -tDif * tModifier * pSpeed)
    if tHadEffect then
      pLastSpinMouseLoc = the mouseV
    end if
  end if
end
on buttonPulse me, t1OneMinus1
  doCallback(pPulseCallback, t1OneMinus1)
end
on startSpinning me
  if pSpinning then
    exit
  end if
  (the actorList).append(me)
  pUpButton.Disable()
  pDownButton.Disable()
  pSpinning = 1
  pLastSpinMouseLoc = the mouseV
  gMach8GUIManager.disableInterfaceExcept([me, pUpButton, pDownButton])
end
on stopSpinning me
  if pEnabled then
    pUpButton.enable()
    pDownButton.enable()
  end if
  (the actorList).deleteOne(me)
  pSpinning = 0
  gMach8GUIManager.enableInterface()
end
on setLocz me, tLocZ
  pUpButton.setLocz(tLocZ)
  pDownButton.setLocz(tLocZ)
end
on destroy me
  pUpButton = pUpButton.destroy()
  pDownButton = pDownButton.destroy()
  pPulseCallback = 0
  (the actorList).deleteOne(me)
  return 0
end
on setVisible me, tVisible
  pUpButton.setVisible(tVisible)
  pDownButton.setVisible(tVisible)
end
on enable me
  if pEnabled then
    exit
  end if
  pUpButton.enable()
  pDownButton.enable()
  pEnabled = 1
end
on Disable me
  if pEnabled = 0 then
    exit
  end if
  if pSpinning then
    me.stopSpinning()
  end if
  pUpButton.Disable()
  pDownButton.Disable()
  pEnabled = 0
end
on setLoc me, tLoc
  pUpButton.setLoc(tLoc)
  pDownButton.setLoc(tLoc)
end