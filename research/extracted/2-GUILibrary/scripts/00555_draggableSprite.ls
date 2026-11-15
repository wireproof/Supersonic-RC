-- Script
property ancestor
property pPressed
property pPressLoc
property pDragStartRadius
property pDragObject
property pDragSprite
global gMach8GUIManager

on new me, tParams
  pDragObject = tParams[#dragobject]
  ancestor = script("sprite").rawNew()
  callAncestor(#new, me, tParams)
  me.setNeedEvents(1)
  pDragStartRadius = 10
  return me
end
on setDragObject me, tDragObject
  pDragObject = tDragObject
end
on mouseDown me
  pPressed = 1
  pPressLoc = the mouseLoc
end
on exitFrame me
  if pDragObject = VOID then
    exit
  end if
  if pPressed then
    if vector(the mouseH, the mouseV, 0).distanceTo(vector(pPressLoc[1], pPressLoc[2], 0)) > pDragStartRadius then
      if gMach8GUIManager.getDragInProgress() = 0 then
        me.StartDrag()
        pPressed = 0
      end if
    end if
  end if
end
on mouseUp me
  pPressed = 0
end
on mouseUpOutSide me
  pPressed = 0
end
on StartDrag me
  tParams = [:]
  tParams[#initSprite] = me
  tParams[#dragobject] = pDragObject
  return script("followMouseDragSprite").new(tParams)
end