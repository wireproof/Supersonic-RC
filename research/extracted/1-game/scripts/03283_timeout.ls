-- Script
property pCallback
property pStopMS

on new me, tCallback, tTime
  pCallback = tCallback
  pStopMS = the milliSeconds + tTime
  (the actorList).append(me)
end
on stepFrame me
  if the milliSeconds > pStopMS then
    doCallback(pCallback)
    me.destroy()
  end if
end
on destroy me
  (the actorList).deleteOne(me)
  pCallback = 0
end