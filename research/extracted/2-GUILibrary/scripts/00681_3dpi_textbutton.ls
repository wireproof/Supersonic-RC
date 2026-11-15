-- Script
property ancestor

on new me, tParams
  tParams[#gfxSet] = "3DPI"
  ancestor = script("standardButton").rawNew()
  callAncestor(#new, me, tParams)
  return me
end
on destroy me
  callAncestor(#destroy, me)
  ancestor = 0
end