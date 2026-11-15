-- Script
property ancestor
property pLastFrameMS
property pCallback

on new me, tCallback
  pCallback = tCallback
  ancestor = script("sprite").rawNew()
  callAncestor(#new, me, [#range: #all])
  me.setLocz(1000)
  me.setMember(member("spritenameshape"))
  me.setBlend(100)
  me.SetWidth(640)
  me.SetHeight(480)
  (the actorList).append(me)
  pLastFrameMS = the milliSeconds
  return me
end
on stepFrame me
  tDif = the milliSeconds - pLastFrameMS
  pLastFrameMS = the milliSeconds
  tBlend = me.getBlend()
  tBlend = max(0, tBlend - tDif / 10.0)
  me.setBlend(tBlend)
  if tBlend <= 0 then
    return me.destroy()
  end if
end
on destroy me
  (the actorList).deleteOne(me)
  doCallback(pCallback)
  callAncestor(#destroy, me)
end