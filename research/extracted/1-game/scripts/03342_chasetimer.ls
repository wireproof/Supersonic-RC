-- Script
property ancestor
property pStartTime
property pTotalTime
property pLastOink

on new me, tGameManager
  ancestor = script("timer").rawNew()
  callAncestor(#new, me, tGameManager)
  me.setTime(20)
  pLastOink = 10
  return me
end
on setTime me, tTime
  pStartTime = integer(me.pHavok.simTime / 3)
  pTotalTime = tTime
end
on getTime me
  if me.pStopped then
    return the pStopTime of me
  else
    t = max(0, integer(-me.pHavok.simTime / 3 + pStartTime + pTotalTime))
    if t < pLastOink then
      pLastOink = t
      sound(4).play([#member: member("alarm")])
    end if
    return t
  end if
end
on addTime me, tTime
  pTotalTime = pTotalTime + tTime
  pLastOink = min(10, pTotalTime)
end