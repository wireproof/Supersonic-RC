-- Parent Script
property ancestor
property pActionCallback
property pLastPulseMS
property pMouseDownOverSprite
property pPulseMSChart
property pPulsesSent

on new me, tParams
  ancestor = script("buttonbase").rawNew()
  callAncestor(#new, me, tParams)
  pActionCallback = tParams[#actionCallback]
  pMouseDownOverSprite = 0
  pPulseMSChart = [300, 200, 100, 50, 20, 10]
  return me
end
on comingIntoSpan me
  callAncestor(#comingIntoSpan, [me])
  (the actorList).append(me)
end
on goingOutOfSpan me
  callAncestor(#goingOutOfSpan, [me])
  (the actorList).deleteOne(me)
end
on mouseDown me
  if me.pEnabled = 0 then
    exit
  end if
  callAncestor(#mouseDown, me)
  call(#Action, [me])
  doCallback(pActionCallback)
  pLastPulseMS = the milliSeconds
  pMouseDownOverSprite = 1
  pPulsesSent = 1
end
on mouseLeave me
  callAncestor(#mouseLeave, me)
  pMouseDownOverSprite = 0
end
on mouseUp me
  callAncestor(#mouseUp, me)
  pMouseDownOverSprite = 0
end
on mouseEnter me
  callAncestor(#mouseEnter, me)
  if me.pPressed then
    pMouseDownOverSprite = 1
  end if
end
on stepFrame me
  callAncestor(#exitFrame, [me])
  if me.pEnabled = 0 then
    exit
  end if
  if pMouseDownOverSprite then
    if the milliSeconds - pLastPulseMS > pPulseMSChart[pPulsesSent] then
      call(#Action, [me])
      doCallback(pActionCallback)
      pLastPulseMS = the milliSeconds
      pPulsesSent = min(pPulseMSChart.count, pPulsesSent + 1)
    end if
  end if
end
on destroy me
  pActionCallback = 0
  callAncestor(#destroy, me)
  ancestor = 0
  (the actorList).deleteOne(me)
  return 0
end