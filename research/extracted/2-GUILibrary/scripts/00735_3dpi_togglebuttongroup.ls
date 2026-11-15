-- Script
property ancestor

on new me, tButtons, tParams
  tButtons = [[#symbol: #always, #text: "Always save the changes?"], [#symbol: #never, #text: "Never save the changes"]]
  tParams = [:]
  tParams[#members] = MACH8_generate3DPIButtonMembers(tParams)
  ancestor = script("togglebuttongroup").rawNew()
  callAncestor(#new, me, tButtons, tParams)
  return me
end
on destroy me
  callAncestor(#destroy, me)
  ancestor = 0
end