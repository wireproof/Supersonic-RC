-- Script
property pSelectionButtons
property pSelectedButton
property pCallbackOnChange

on new me, tButtons, tParams
  pSelectionButtons = [:]
  tAllProceduralGfx = 1
  repeat with tButtonDesc in tButtons
    tButton = script("selectionGroupButton").rawNew()
    tButtonParams = [:]
    tButtonParams[#text] = tButtonDesc[#text]
    if voidp(tButtonParams[#text]) then
      tAllProceduralGfx = 0
    end if
    tButtonParams[#gfxSet] = tParams[#gfxSet]
    tButtonParams[#members] = tParams[#members]
    tButtonParams[#callbackOnSelected] = script("callback").new(#buttonGotSelected, me, tButton)
    pSelectionButtons.addProp(tButtonDesc[#symbol], tButton.new(tButtonParams))
  end repeat
  if tAllProceduralGfx then
    me.makeButtonsEquallyWide()
  end if
  pSelectionButtons[1].select()
  pCallbackOnChange = tParams[#callbackOnChange]
  pLoc = point(0, 0)
  if voidp(tParams[#loc]) = 0 then
    pLoc = tParams[#loc]
  end if
  me.setLoc(pLoc)
  return me
end
on setActionCallback me, tCallback
  pCallbackOnChange = tCallback
end
on setLoc me, tLoc
  pLoc = tLoc
  repeat with tSelectionButton in pSelectionButtons
    tSelectionButton.setLoc(tLoc)
    tLoc = tLoc + point(0, tSelectionButton.getHeight())
  end repeat
end
on setLocz me, tLocZ
  call(#setLocz, pSelectionButtons, tLocZ)
end
on buttonGotSelected me, tButton
  repeat with i in pSelectionButtons
    if i <> tButton then
      i.deselect()
    end if
  end repeat
  pSelectedButton = pSelectionButtons.getOne(tButton)
  doCallback(pCallbackOnChange)
end
on makeButtonsEquallyWide me
  tMaxWidth = -the maxinteger
  repeat with tButton in pSelectionButtons
    tMaxWidth = max(tMaxWidth, tButton.getWidth())
  end repeat
  repeat with tButton in pSelectionButtons
    if tButton.getProcedurallyGenerated() then
      tButton.setProceduralButtonData([#width: tMaxWidth])
    end if
  end repeat
end
on destroy me
  call(#destroy, pSelectionButtons.duplicate())
  pSelectionButtons = 0
  pCallbackOnChange = 0
  return 0
end