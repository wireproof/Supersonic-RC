-- Script
property ancestor
property pLastFrameMS
property pCallback
global gMach8GUIManager

on new me, tCallback
  ancestor = script("sprite").rawNew()
  callAncestor(#new, me, [#range: #all])
  me.setLocz(1000)
  me.setMember(member("spritenameshape"))
  me.setBlend(0)
  me.SetWidth(640)
  me.SetHeight(480)
  gMach8GUIManager.disableInterfaceExcept([])
  pCallback = tCallback
  (the actorList).append(me)
  pLastFrameMS = the milliSeconds
  return me
end
on stepFrame me
  tDif = the milliSeconds - pLastFrameMS
  pLastFrameMS = the milliSeconds
  tBlend = me.getBlend()
  tBlend = tBlend + tDif / 10.0
  me.setBlend(tBlend)
  if tBlend >= 100 then
    doCallback(pCallback)
    return me.destroy()
  end if
end
on destroy me
  gMach8GUIManager.enableInterface()
  (the actorList).deleteOne(me)
  callAncestor(#destroy, me)
end