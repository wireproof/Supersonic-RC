-- Script
property ancestor
property pActionCallback
property pRollOverCallback
property pRollOutCallback

on new me, tParams
  ancestor = script("buttonbase").rawNew()
  callAncestor(#new, me, tParams)
  pActionCallback = tParams[#actionCallback]
  pRollOverCallback = tParams[#rollOverCallback]
  pRollOutCallback = tParams[#rollOutCallback]
  return me
end
on mouseUp me
  t = me.pPressed
  callAncestor(#mouseUp, me)
  if t then
    call(#Action, [me])
    doCallback(pActionCallback)
  end if
end
on mouseDown me
  sound(1).play([#member: member("buttonclick")])
  callAncestor(#mouseDown, me)
end
on mouseEnter me
  call(#rollover, [me])
  doCallback(pRollOverCallback)
  callAncestor(#mouseEnter, me)
end
on mouseLeave me
  call(#rollOut, [me])
  doCallback(pRollOutCallback)
  callAncestor(#mouseLeave, me)
end
on setActionCallback me, tActionCallback
  if voidp(tActionCallback) = 0 then
    if voidp(tActionCallback[#object]) then
      nothing()
    end if
  end if
  pActionCallback = tActionCallback
end
on setRolloverCallback me, tRollOverCallback
  pRollOverCallback = tRollOverCallback
end
on setRollOutCallBack me, tRollOutCallback
  pRollOutCallback = tRollOutCallback
end
on getActionCallback me
  return pActionCallback
end
on destroy me
  pActionCallback = 0
  pRollOverCallback = 0
  pRollOutCallback = 0
  callAncestor(#destroy, me)
  ancestor = 0
  return 0
end