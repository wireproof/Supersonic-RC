-- Script
property ancestor
property pStates
property pStateMembers
property pCurrentState
property pValueChangeCallback

on new me, tParams
  tStates = tParams[#states]
  pStateMembers = [:]
  pStates = []
  repeat with i = 1 to tStates.count
    pStates.append(tStates.getPropAt(i))
    tStateDescription = tStates[i]
    if voidp(tStateDescription[#text]) then
      pStateMembers.addProp(pStates.getLast(), tStateDescription[#members])
      next repeat
    end if
    tMembers = call(#generateButtonMembers, script(tParams[#gfxSet] & "_Gfx_Generator"), [#text: tStateDescription[#text]])
    pStateMembers.addProp(pStates.getLast(), tMembers)
  end repeat
  ancestor = script("buttonbase").rawNew()
  callAncestor(#new, me, tParams)
  me.setState(pStates[1])
  pValueChangeCallback = tParams[#valueChangeCallback]
  return me
end
on setValueChangeCallback me, tValueChangeCallback
  pValueChangeCallback = tValueChangeCallback
end
on getState me
  return pCurrentState
end
on mouseUp me
  if me.pEnabled = 0 then
    exit
  end if
  t = pStates.getOne(pCurrentState)
  t = t + 1
  if t > pStates.count then
    t = 1
  end if
  me.setState(pStates[t])
  doCallback(pValueChangeCallback)
  callAncestor(#mouseUp, me)
end
on setState me, tstate
  me.setNewMembers(pStateMembers[tstate])
  pCurrentState = tstate
end
on destroy me
  callAncestor(#destroy, me)
  ancestor = 0
  return 0
end