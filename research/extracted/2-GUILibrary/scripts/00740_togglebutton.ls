-- Script
property ancestor
property pEnabled
property pOn
property pCallbackOnSelected
property pCallbackOnDeselected

on new me, tParams
  ancestor = script("spriteWithButtonMembers").rawNew()
  callAncestor(#new, me, tParams)
  me.setNeedEvents(1)
  pCallbackOnSelected = tParams[#callbackOnSelected]
  pCallbackOnDeselected = tParams[#callbackOnDeselected]
  pOn = 0
  pEnabled = 1
  return me
end
on setChangeCallback me, tCallback
  pCallbackOnSelected = tCallback
  pCallbackOnDeselected = tCallback
end
on Disable me
  if pEnabled = 0 then
    exit
  end if
  pEnabled = 0
  pPressed = 0
  me.setMember(me.pMembers[#disabled])
end
on enable me
  if pEnabled then
    exit
  end if
  pEnabled = 1
  me.setMember(me.pMembers[#normal])
end
on setNewMembers me, tMembers
  callAncestor(#setNewMembers, me, tMembers)
  if pEnabled = 0 then
    me.setMember(me.pMembers[#disabled])
    exit
  end if
  case pOn of
    0:
      me.setMember(me.pMembers[#normal])
    1:
      me.setMember(me.pMembers[#pressed])

  end case
end
on mouseEnter me
  if pEnabled = 0 then
    exit
  end if
  if pOn then
    exit
  end if
  me.setMember(me.pMembers[#rollover])
end
on mouseLeave me
  if pEnabled = 0 then
    exit
  end if
  if pOn then
    exit
  end if
  me.setMember(me.pMembers[#normal])
end
on mouseDown me
  if pEnabled = 0 then
    exit
  end if
  if pOn then
    me.deselect()
  else
    me.select()
  end if
end
on setValue me, tvalue, tSpecial
  if tvalue = 1 then
    me.select(tSpecial)
  else
    me.deselect(tSpecial)
  end if
end
on deselect me, tSpecial
  pOn = 0
  me.setMember(me.pMembers[#rollover])
  if paramPresent(tSpecial, #dontupdate) = 0 then
    doCallback(pCallbackOnDeselected)
  end if
end
on select me, tSpecial
  pOn = 1
  me.setMember(me.pMembers[#pressed])
  if paramPresent(tSpecial, #dontupdate) = 0 then
    doCallback(pCallbackOnSelected)
  end if
end
on GetValue me
  return pOn
end
on destroy me
  callAncestor(#destroy, me)
  ancestor = 0
  return 0
end