-- Script
property ancestor

on new me, tParams
  ancestor = script("togglebutton").rawNew()
  callAncestor(#new, me, tParams)
  return me
end
on mouseDown me
  if me.pOn = 0 then
    callAncestor(#mouseDown, me)
  end if
end
on destroy me
  callAncestor(#destroy, me)
  ancestor = 0
end