-- Script
property ancestor
property pPressed
property pDragObject
property pDestroyed
property pMouseDownFrames
global gMach8GUIManager

on new me, tParams
  pDragObject = tParams[#dragobject]
  ancestor = script("sprite").rawNew()
  callAncestor(#new, me, tParams)
  me.setLocz(360)
  me.setNeedEvents(0)
  me.setBlend(50)
  gMach8GUIManager.StartDrag(me)
  (the actorList).append(me)
  pDestroyed = 0
  pMouseDownFrames = 0
  return me
end
on destroy me
  pDestroyed = 1
  gMach8GUIManager.dragEnded()
  (the actorList).deleteOne(me)
  callAncestor(#destroy, me)
end
on dragFailed me
  me.destroy()
end
on dragSucceeded me
  me.destroy()
end
on getRepresentingObject me
  return pDragObject
end
on stepFrame me
  if pDestroyed then
    alert("adas")
  end if
  me.setLoc(the mouseLoc)
  if the mouseDown = 0 then
    pMouseDownFrames = pMouseDownFrames + 1
    if pMouseDownFrames = 3 then
      me.dragFailed()
    end if
  else
    pMouseDownFrames = 0
  end if
end