-- Script
property pSliderSprite
property pScroller
property pDragging
property pOrientation
property pOrientationIndex
property pLoc
property pSize
property pTopCoordinate
property pBottomCoordinate
property pMiddleCoordinate
property pLastDragMouseLoc
property pMaxSize
global gMach8GUIManager

on new me, tScroller, tUpButton, tDownButton, tParams
  pScroller = tScroller
  pDragging = 0
  tUpLoc = tUpButton.getLoc()
  tDownLOc = tDownButton.getLoc()
  if abs(tUpLoc[1] - tDownLOc[1]) > abs(tUpLoc[2] - tDownLOc[2]) then
    pOrientation = #horizontal
    pOrientationIndex = 1
  else
    pOrientation = #vertical
    pOrientationIndex = 2
  end if
  tParams[#orientation] = pOrientation
  pSliderSprite = script("slidersprite").new(me, tParams)
  pSliderSprite.setInk(9)
  case pOrientation of
    #horizontal:
      pTopCoordinate = tUpButton.getRight()
      pBottomCoordinate = tDownButton.getLeft()
      pSliderSprite.setLocV(tUpButton.getTop())
    #vertical:
      pTopCoordinate = tUpButton.getBottom()
      pBottomCoordinate = tDownButton.getTop()
      pSliderSprite.setLocH(tUpButton.getLeft())

  end case
  pSliderSprite.setLocz(tUpButton.getLocz() + 2)
  pMaxSize = pBottomCoordinate - pTopCoordinate
  (the actorList).append(me)
  return me
end
on setStageOrientation me, tOrientation
  pSliderSprite.setStageOrientation(tOrientation)
end
on setLocz me, tLocZ
  pSliderSprite.setLocz(tLocZ)
end
on destroy me
  pSliderSprite = pSliderSprite.destroy()
  pScroller = 0
  (the actorList).deleteOne(me)
  return 0
end
on setVisible me, tVisible
  pSliderSprite.setVisible(tVisible)
end
on update me, tScrollOffset, tTotalItems
  if pDragging then
    me.stopDragging()
    tWasDragging = 1
  else
    tWasDragging = 0
  end if
  pScrollOffset = tScrollOffset
  pTotalItems = tTotalItems
  if pTotalItems = 0 then
    tRatio = 1
  else
    tRatio = pScroller.getItemsPerPage() / float(pTotalItems)
  end if
  if tRatio >= 1 then
    pSliderSprite.setVisible(1)
  else
    pSliderSprite.setVisible(1)
  end if
  pSize = integer(max(min(1, tRatio) * pMaxSize, pSliderSprite.getMinimumSize()))
  tRatio = pScrollOffset / float(pTotalItems - pScroller.getItemsPerPage())
  pLoc = integer(pTopCoordinate + tRatio * (pMaxSize - pSize))
  pSliderSprite.setSize(pSize)
  pSliderSprite.setLoc(pLoc)
  if tWasDragging then
    me.startDragging()
  end if
end
on mouseDown me
  me.startDragging()
end
on mouseUp me
  me.stopDragging()
end
on startDragging me
  pDragging = 1
  pLastDragMouseLoc = the mouseLoc[pOrientationIndex]
  gMach8GUIManager.disableInterfaceExcept(pSliderSprite)
end
on stopDragging me
  pDragging = 0
  pScroller.sliderStoppedMoving()
  gMach8GUIManager.enableInterface()
end
on stepFrame me
  if pDragging = 0 then
    exit
  end if
  tMLoc = the mouseLoc[pOrientationIndex]
  tDif = tMLoc - pLastDragMouseLoc
  if tDif = 0 then
    exit
  end if
  tNewLoc = pLoc + tDif
  tNewLoc = min(pBottomCoordinate - pSize, tNewLoc)
  tNewLoc = max(pTopCoordinate, tNewLoc)
  if tNewLoc <> pLoc then
    pLastDragMouseLoc = tMLoc
    pLoc = tNewLoc
    pSliderSprite.setLoc(pLoc)
    pScroller.sliderMoving(float(pLoc - pTopCoordinate) / (pMaxSize - pSize))
  end if
end
on getOrientation me
  return pOrientation
end
on getLoc me
  return pLoc
end