-- Script
property pOutsideSpriteRects
property pOutSideSprites
property pInsideSpriteRects
property pInsideSprites
property pClickSpriteRects
property pClickSprites
property pNeedsMouseUpOutside
property pLastMouseLoc

on new me
  pOutsideSpriteRects = []
  pOutSideSprites = []
  pInsideSpriteRects = []
  pInsideSprites = []
  pClickSpriteRects = [:]
  pClickSprites = []
  pNeedsMouseUpOutside = []
  return me
end
on destroy me
  pOutsideSpriteRects = 0
  pOutSideSprites = 0
  pInsideSpriteRects = 0
  pInsideSprites = 0
  pClickSpriteRects = 0
  pClickSprites = 0
  return 0
end
on registerForMouseMoveEvents me, tSprite
  if pOutSideSprites.getOne(tSprite) <> 0 then
    nothing()
  end if
  if pInsideSprites.getOne(tSprite) <> 0 then
    nothing()
  end if
  tRect = tSprite.getMouseRect()
  pOutSideSprites.addAt(1, tSprite)
  pOutsideSpriteRects.addAt(1, tRect)
end
on unregisterForMouseMoveEvents me, tSprite
  t = pOutSideSprites.getOne(tSprite)
  if t <> 0 then
    pOutSideSprites.deleteAt(t)
    pOutsideSpriteRects.deleteAt(t)
  end if
  t = pInsideSprites.getOne(tSprite)
  if t <> 0 then
    pInsideSprites.deleteAt(t)
    pInsideSpriteRects.deleteAt(t)
  end if
end
on registerForMouseClickEvents me, tSprite, tLocZ
  tRect = tSprite.getMouseRect()
  pClickSpriteRects.addProp(-tLocZ, tRect)
  pClickSpriteRects.sort()
  tWhere = pClickSpriteRects.getPos(tRect)
  pClickSprites.addAt(tWhere, tSprite)
end
on unregisterForMouseClickEvents me, tSprite
  t = pClickSprites.getOne(tSprite)
  if t <> 0 then
    pClickSprites.deleteAt(t)
    pClickSpriteRects.deleteAt(t)
  end if
end
on needMouseUpOutside me, tSprite
  pNeedsMouseUpOutside.append(tSprite)
end
on mouseDown me
  t = the mouseLoc
  repeat with i = 1 to pClickSpriteRects.count
    if t.inside(pClickSpriteRects[i]) then
      t2 = pClickSprites[i].spriteMouseDown()
      if t2 <> #pass then
        tDidMouseDown = 1
        return 1
      end if
    end if
  end repeat
  return tDidMouseDown
end
on mouseUp me
  t = the mouseLoc
  tMouseUppedSprites = []
  repeat with i = 1 to pClickSpriteRects.count
    if t.inside(pClickSpriteRects[i]) then
      t2 = pClickSprites[i].spriteMouseUp()
      if t2 <> #pass then
        tMouseUppedSprites.append(pClickSprites[i])
        tDidMouseUp = 1
      end if
    end if
  end repeat
  repeat with i = pNeedsMouseUpOutside.count down to 1
    if tMouseUppedSprites.getOne(pNeedsMouseUpOutside[i]) = 0 then
      pNeedsMouseUpOutside[i].spriteMouseUpOutside()
    end if
  end repeat
  pNeedsMouseUpOutside = []
  return tDidMouseUp
end
on stepFrame me
  t = the mouseLoc
  if t = pLastMouseLoc then
    exit
  end if
  pLastMouseLoc = t
  tMove = []
  tMoveBack = []
  repeat with i = 1 to pOutsideSpriteRects.count
    if t.inside(pOutsideSpriteRects[i]) then
      pOutSideSprites[i].spriteMouseEnter()
      tMove.append(i)
    end if
  end repeat
  repeat with i = 1 to pInsideSpriteRects.count
    if t.inside(pInsideSpriteRects[i]) = 0 then
      pInsideSprites[i].spriteMouseLeave()
      tMoveBack.append(i)
    end if
  end repeat
  repeat with ii = tMove.count down to 1
    i = tMove[ii]
    pInsideSpriteRects.append(pOutsideSpriteRects[i])
    pInsideSprites.append(pOutSideSprites[i])
    pOutsideSpriteRects.deleteAt(i)
    pOutSideSprites.deleteAt(i)
  end repeat
  repeat with ii = tMoveBack.count down to 1
    i = tMoveBack[ii]
    pOutsideSpriteRects.append(pInsideSpriteRects[i])
    pOutSideSprites.append(pInsideSprites[i])
    pInsideSpriteRects.deleteAt(i)
    pInsideSprites.deleteAt(i)
  end repeat
end