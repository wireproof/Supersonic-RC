-- Script
property pScoreSprite
property pName
property pBlend
property pMember
property pLoc
property pInk
property pLocZ
property pRotation
property pSkew
property pFlipH
property pFlipV
property pForeColor
property pBackColor
property pcolor
property pInSpan
property pwidth
property pheight
property prange
property pVisible
property pcursor
property pEditable
property pNeedEvents
property pHibernated
property pRelativeLoc
property pRelativeOrigin
property pStageOrientation
property pTrails
global gMach8GUIManager

on new me, tParams
  me.instantiate(tParams)
  if me.inSpan(the frame) then
    pInSpan = 1
    pScoreSprite = gMach8GUIManager.getScoreSprite(me, pName)
    me.applySettingsToScoreSprite()
    call(#comingIntoSpan, [me])
  else
    pInSpan = 0
    pScoreSprite = 0
  end if
  pHibernated = 0
  gMach8GUIManager.spriteObjectReporting(me)
  return me
end
on instantiate me, tParams
  if voidp(tParams) then
    tParams = [:]
  end if
  case ilk(tParams) of
    #instance:
      me.populateAccordingToSpriteObject(tParams)
    #propList:
      if voidp(tParams[#initSprite]) = 0 then
        me.populateAccordingToSpriteObject(tParams[#initSprite])
        exit
      end if
      pName = tParams[#name]
      prange = tParams[#range]
      if prange = VOID then
        prange = [the frame]
      end if
      if prange = #all then
        prange = [the frame, [1, 1000]]
      end if
      case ilk(pName) of
        #string:
          me.populateAccordingToScoreSprite(pName, prange)
        #void:
          me.populateAccordingToDefault()

      end case

  end case
  pStageOrientation = [0, 0]
end
on aboutToGo1 me, tFrame
  if pInSpan then
    if me.inSpan(tFrame) = 0 then
      pInSpan = 0
      call(#goingOutOfSpan, [me])
      if pHibernated = 0 then
        gMach8GUIManager.returnScoreSprite(pScoreSprite)
        pScoreSprite = 0
      end if
    end if
  end if
end
on aboutToGo2 me, tFrame
  if pInSpan = 0 then
    if me.inSpan(tFrame) then
      pInSpan = 1
      if pHibernated = 0 then
        if gTwo = me then
          nothing()
        end if
        pScoreSprite = gMach8GUIManager.getScoreSprite(me, pName)
        if pScoreSprite.spriteNum = 98 then
          nothing()
        end if
        me.applySettingsToScoreSprite()
      end if
      call(#comingIntoSpan, [me])
    end if
  else
    if pHibernated then
      exit
    end if
    if pNeedEvents then
      tPresent = 0
      repeat with i in me.pScoreSprite.scriptInstanceList
        if i.script = script("eventCatcher") then
          tPresent = 1
        end if
      end repeat
      if tPresent = 0 then
        pScoreSprite.scriptInstanceList = [script("eventCatcher").new(me)]
      end if
    end if
  end if
end
on destroy me
  if pScoreSprite <> 0 then
    gMach8GUIManager.returnScoreSprite(pScoreSprite)
  end if
  gMach8GUIManager.spriteObjectDied(me)
  return 0
end
on setRelativeOrigin me, torigin, tSpecial
  tAbsPos = pLoc + pRelativeOrigin
  pRelativeOrigin = torigin
  if tSpecial = #preserveWorld then
    pLoc = tAbsPos - pRelativeOrigin
  else
    me.setLoc(pLoc)
  end if
end
on getStageOrientation me
  return pStageOrientation
end
on setStageOrientation me, tOrientation
  pStageOrientation = tOrientation
  tRect = rect(0, 0, 0, 0)
  tRect[3] = (the stage).rect.width
  tRect[4] = (the stage).rect.height
  me.stageRectChanged(tRect, #preserveWorld)
end
on stageRectChanged me, tRect, tSpecial
  case pStageOrientation[1] of
    #right:
      t1 = tRect[3]
    #middle:
      t1 = tRect[3] / 2
    0:
      t1 = 0
    otherwise:
      t1 = pRelativeOrigin[1]

  end case
  case pStageOrientation[2] of
    #bottom:
      t2 = tRect[4]
    #middle:
      t2 = tRect[4] / 2
    0:
      t2 = 0
    otherwise:
      t2 = pRelativeOrigin[2]

  end case
  me.setRelativeOrigin(point(t1, t2), tSpecial)
end
on dragSupportedForObject me, tObject
  return 0
end
on setRange me, tRange
  prange = tRange
  if prange = #all then
    prange = [the frame, [1, 1000]]
  end if
  me.aboutToGo1(the frame)
  me.aboutToGo2(the frame)
end
on populateAccordingToScoreSprite me, tName, tRange
  tBackupFrame = the frame
  the updateLock = 1
  case ilk(tRange[1]) of
    #string:
      MACH8_UpdateLockedGo(tRange[1] & "_layout")
    #list:
      MACH8_UpdateLockedGo(tRange[1][1] & "_layout")

  end case
  tResult = []
  sendAllSprites(#findSpriteByName, tName, tResult)
  if tResult.count = 0 then
    alert("Can't find sprite with name " & tName & " at frame " & the frame)
  end if
  tSprite = tResult[1]
  me.getSettingsFromScoreSprite(tSprite)
  MACH8_UpdateLockedGoBack()
  pVisible = 1
  pNeedEvents = 0
end
on getSettingsFromScoreSprite me, tSprite
  if voidp(tSprite) then
    tSprite = pScoreSprite
  end if
  pBlend = tSprite.blend
  pLoc = tSprite.loc
  pFlipH = tSprite.flipH
  pFlipV = tSprite.flipV
  pLocZ = tSprite.locZ
  pInk = tSprite.ink
  pRotation = tSprite.rotation
  pSkew = tSprite.skew
  pwidth = tSprite.width
  pheight = tSprite.height
  pVisible = tSprite.visible
  pMember = tSprite.member
  pForeColor = tSprite.foreColor
  pBackColor = tSprite.bgColor
  pEditable = tSprite.editable
  pcursor = tSprite.cursor
  pRelativeOrigin = point(0, 0)
  pTrails = tSprite.trails
end
on populateAccordingToDefault me
  pBlend = 100
  pLoc = point(0, 0)
  pFlipH = 0
  pFlipV = 0
  pMember = VOID
  pLocZ = 10
  pInk = 0
  pwidth = VOID
  pheight = VOID
  pRotation = 0
  pSkew = 0
  pForeColor = 255
  pBackColor = rgb(255, 255, 255)
  pcolor = VOID
  pEditable = 0
  pVisible = 1
  pNeedEvents = 1
  pcursor = 0
  pRelativeOrigin = point(0, 0)
  pTrails = 0
end
on populateAccordingToSpriteObject me, tSprite
  prange = tSprite.getRange()
  pBlend = tSprite.getBlend()
  pLoc = tSprite.getLoc()
  pFlipH = tSprite.getFlipH()
  pFlipV = tSprite.getFlipV()
  pMember = tSprite.getMember()
  pLocZ = tSprite.getLocz()
  pInk = tSprite.getInk()
  pwidth = tSprite.getWidth()
  pheight = tSprite.getHeight()
  pRotation = tSprite.getRotation()
  pSkew = tSprite.getSkew()
  pForeColor = tSprite.getForeColor()
  pBackColor = tSprite.getBackColor()
  pcolor = tSprite.getColor()
  pEditable = tSprite.getEditable()
  pVisible = tSprite.getVisible()
  pNeedEvents = tSprite.getNeedEvents()
  pcursor = tSprite.getCursor()
  pRelativeOrigin = point(0, 0)
  pTrails = tSprite.getTrails()
end
on applySettingsToScoreSprite me
  pScoreSprite.blend = pBlend
  pScoreSprite.loc = pLoc + pRelativeOrigin
  pScoreSprite.ink = pInk
  pScoreSprite.member = pMember
  pScoreSprite.flipH = pFlipH
  pScoreSprite.flipV = pFlipV
  pScoreSprite.locZ = pLocZ
  pScoreSprite.rotation = pRotation
  pScoreSprite.skew = pSkew
  pScoreSprite.editable = pEditable
  pScoreSprite.foreColor = pForeColor
  pScoreSprite.bgColor = pBackColor
  if voidp(pcolor) = 0 then
    pScoreSprite.color = pcolor
  end if
  pScoreSprite.visible = pVisible
  pScoreSprite.width = pwidth
  pScoreSprite.height = pheight
  pScoreSprite.cursor = pcursor
  pScoreSprite.trails = pTrails
  if pNeedEvents then
    pScoreSprite.scriptInstanceList = [script("eventCatcher").new(me)]
  end if
end
on inSpan me, tFrame
  if ilk(tFrame) = #string then
    tFrame = marker(tFrame)
  end if
  repeat with tSegment in prange
    case ilk(tSegment) of
      #string:
        if tFrame = marker(tSegment) then
          return 1
        end if
      #integer:
        if tFrame = tSegment then
          return 1
        end if
      #list:
        if ilk(tSegment[1]) = #string then
          tSegment[1] = marker(tSegment[1])
        end if
        if ilk(tSegment[2]) = #string then
          tSegment[2] = marker(tSegment[2])
        end if
        if tFrame >= tSegment[1] and tFrame <= tSegment[2] then
          return 1
        end if

    end case
  end repeat
  return 0
end
on setBlend me, tBlend
  pBlend = tBlend
  if pScoreSprite <> 0 then
    pScoreSprite.blend = pBlend
  end if
end
on setMember me, tmember
  if tmember = member(-1, 1) then
    nothing()
  end if
  pMember = tmember
  if pScoreSprite <> 0 then
    pScoreSprite.member = pMember
    if pScoreSprite.member <> pMember and not voidp(pMember) then
      nothing()
    end if
  end if
  if pwidth = VOID or pheight = VOID then
    me.correctRectToMember()
  end if
end
on correctRectToMember me
  if voidp(pMember) then
    exit
  end if
  me.SetWidth(pMember.width)
  me.SetHeight(pMember.height)
end
on setLocH me, tLocH
  pLoc[1] = tLocH
  me.setLoc(pLoc)
end
on setLocV me, tLocV
  pLoc[2] = tLocV
  me.setLoc(pLoc)
end
on setLoc me, tLoc
  pLoc = tLoc
  if pScoreSprite <> 0 then
    pScoreSprite.loc = pLoc + pRelativeOrigin
  end if
end
on setInk me, tInk
  pInk = tInk
  if pScoreSprite <> 0 then
    pScoreSprite.ink = pInk
  end if
end
on setForeColor me, tForecolor
  pForeColor = tForecolor
  if pScoreSprite <> 0 then
    pScoreSprite.foreColor = pForeColor
  end if
end
on setBackColor me, tBackColor
  pBackColor = tBackColor
  if pScoreSprite <> 0 then
    pScoreSprite.bgColor = pBackColor
  end if
end
on setColor me, tColor
  pcolor = tColor
  if voidp(pcolor) then
    me.setForeColor(pForeColor)
    me.setBackColor(pBackColor)
  else
    if pScoreSprite <> 0 then
      pScoreSprite.color = tColor
    end if
  end if
end
on setVisible me, tVisible, tSpecial
  pVisible = tVisible
  if pScoreSprite <> 0 then
    pScoreSprite.visible = pVisible
  end if
  if tVisible = 1 and pScoreSprite = 0 then
    pHibernated = 0
    if pInSpan then
      pScoreSprite = gMach8GUIManager.getScoreSprite(pName)
      me.applySettingsToScoreSprite()
    end if
  end if
  if tVisible = 0 and tSpecial = #hibernate then
    pHibernated = 1
    if pScoreSprite <> 0 then
      if the controlDown then
        nothing()
      end if
      gMach8GUIManager.returnScoreSprite(pScoreSprite)
      pScoreSprite = 0
    end if
  end if
end
on setCursor me, tCursor
  pcursor = tCursor
  if pScoreSprite <> 0 then
    pScoreSprite.cursor = pcursor
  end if
end
on setRotation me, trotation
  pRotation = trotation
  if pScoreSprite <> 0 then
    pScoreSprite.rotation = pRotation
  end if
end
on setEditable me, tEditable
  pEditable = tEditable
  if pScoreSprite <> 0 then
    pScoreSprite.editable = pEditable
  end if
end
on setSkew me, tSkew
  pSkew = tSkew
  if pScoreSprite <> 0 then
    pScoreSprite.skew = pSkew
  end if
end
on setFlipH me, tFlipH
  pFlipH = tFlipH
  if pScoreSprite <> 0 then
    pScoreSprite.flipH = pFlipH
  end if
end
on setFlipV me, tFlipV
  pFlipV = tFlipV
  if pScoreSprite <> 0 then
    pScoreSprite.flipV = pFlipV
  end if
end
on setLocz me, tLocZ
  pLocZ = tLocZ
  if pScoreSprite <> 0 then
    pScoreSprite.locZ = pLocZ
  end if
end
on SetHeight me, tHeight
  pheight = tHeight
  if pScoreSprite <> 0 then
    pScoreSprite.height = pheight
  end if
end
on SetWidth me, tWidth
  pwidth = tWidth
  if pScoreSprite <> 0 then
    pScoreSprite.width = pwidth
  end if
end
on setTrails me, tTrails
  pTrails = tTrails
  if pScoreSprite <> 0 then
    pScoreSprite.trails = pTrails
  end if
end
on spriteMouseEnter me
  if gMach8GUIManager.getDragInProgress() then
    tObjectBeingDragged = gMach8GUIManager.getObjectBeingDragged()
    if me.dragSupportedForObject(tObjectBeingDragged) then
      call(#dragRollover, [me], tObjectBeingDragged)
    end if
  else
    if gMach8GUIManager.getGloballyDisabled(me) = 0 then
      call(#mouseEnter, [me])
    end if
  end if
end
on spriteMouseWithin me
  if gMach8GUIManager.getDragInProgress() then
    tObjectBeingDragged = gMach8GUIManager.getObjectBeingDragged()
    if me.dragSupportedForObject(tObjectBeingDragged) then
      call(#dragWithin, [me], tObjectBeingDragged)
    end if
  else
    if gMach8GUIManager.getGloballyDisabled(me) = 0 then
      call(#mouseWithin, [me])
    end if
  end if
end
on spriteMouseLeave me
  if gMach8GUIManager.getDragInProgress() then
    tObjectBeingDragged = gMach8GUIManager.getObjectBeingDragged()
    if me.dragSupportedForObject(tObjectBeingDragged) then
      call(#dragRollOut, [me], tObjectBeingDragged)
    end if
  else
    if gMach8GUIManager.getGloballyDisabled(me) = 0 then
      call(#mouseLeave, [me])
    end if
  end if
end
on spriteMouseUp me
  if gMach8GUIManager.getDragInProgress() then
    tObjectBeingDragged = gMach8GUIManager.getObjectBeingDragged()
    if me.dragSupportedForObject(tObjectBeingDragged) then
      call(#dragDrop, [me], tObjectBeingDragged)
      gMach8GUIManager.dragSucceeded()
    end if
  else
    if gMach8GUIManager.getGloballyDisabled(me) = 0 then
      call(#mouseUp, [me])
    end if
  end if
end
on spriteMouseDown me
  if gMach8GUIManager.getGloballyDisabled(me) = 0 then
    call(#mouseDown, [me])
  end if
end
on spriteMouseUpOutside me
  if gMach8GUIManager.getGloballyDisabled(me) = 0 then
    call(#mouseUpOutSide, [me])
  end if
end
on getScoreSprite me
  return pScoreSprite
end
on getBlend me
  return pBlend
end
on getMember me
  return pMember
end
on getLocH me
  return pLoc[1]
end
on getLocV me
  return pLoc[2]
end
on getLoc me
  return pLoc
end
on getInk me
  return pInk
end
on getEditable me
  return pEditable
end
on getForeColor me
  return pForeColor
end
on getBackColor me
  return pBackColor
end
on getVisible me
  return pVisible
end
on getRotation me
  return pRotation
end
on getSkew me
  return pSkew
end
on getColor me
  return pcolor
end
on getFlipH me
  return pFlipH
end
on getFlipV me
  return pFlipV
end
on getLocz me
  return pLocZ
end
on getWidth me
  return pwidth
end
on getHeight me
  return pheight
end
on getRange me
  return prange
end
on getCursor me
  return pcursor
end
on getTrails me
  return pTrails
end
on getBottom me
  if pMember = VOID then
    return pLoc[2]
  end if
  if pMember.width = 0 then
    return pLoc[2]
  end if
  tRatio = pMember.regPoint.locV / float(pMember.height)
  return pLoc[2] + (1 - tRatio) * pheight
end
on getTop me
  if pMember = VOID then
    return pLoc[2]
  end if
  if pMember.width = 0 then
    return pLoc[2]
  end if
  tRatio = pMember.regPoint.locV / float(pMember.height)
  return pLoc[2] - tRatio * pheight
end
on getRight me
  if pMember = VOID then
    return pLoc[1]
  end if
  if pMember.width = 0 then
    return pLoc[1]
  end if
  tRatio = pMember.regPoint.locH / float(pMember.width)
  return pLoc[1] + (1 - tRatio) * pwidth
end
on getLeft me
  if pMember = VOID then
    return pLoc[1]
  end if
  if pMember.width = 0 then
    return pLoc[1]
  end if
  tRatio = pMember.regPoint.locH / float(pMember.width)
  return pLoc[1] - tRatio * pwidth
end
on GetTopLeft me
  return point(me.getLeft(), me.getTop())
end
on getTopRight me
  return point(me.getRight(), me.getTop())
end
on getBottomLeft me
  return point(me.getLeft(), me.getBottom())
end
on getBottomRight me
  return point(me.getRight(), me.getBottom())
end
on getMiddle me
  return (me.GetTopLeft() + me.getBottomRight()) / 2
end
on setNeedEvents me, tNeed
  if pNeedEvents = tNeed then
    exit
  end if
  pNeedEvents = tNeed
  if pScoreSprite <> 0 then
    case pNeedEvents of
      1:
        pScoreSprite.scriptInstanceList = [script("eventCatcher").new(me)]
      0:
        pScoreSprite.scriptInstanceList = []

    end case
  end if
end
on getRect me
  assert(pScoreSprite <> 0, "Rect requested for sprite with pScoreSprite<>0")
  return the rect of pScoreSprite
end
on getNeedEvents me
  return pNeedEvents
end