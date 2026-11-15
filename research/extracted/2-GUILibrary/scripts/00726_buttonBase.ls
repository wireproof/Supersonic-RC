-- Script
property ancestor
property pPressed
property pEnabled
property pLockingInterface
property pDebugEvents
property pHackMouseUpOutsideFrames
global gMach8GUIManager

on new me, tParams
  if tParams[#dontEnheritFromSpriteWithButtonMembers] then
    ancestor = script("sprite").rawNew()
  else
    ancestor = script("spriteWithButtonMembers").rawNew()
  end if
  callAncestor(#new, me, tParams)
  me.setNeedEvents(1)
  me.setNormalState()
  me.correctRectToMember()
  pPressed = 0
  pEnabled = 1
  pLockingInterface = 0
  pDebugEvents = []
  pHackMouseUpOutsideFrames = 0
  return me
end
on goingOutOfSpan me, t1, t2, t3
  callAncestor(#goingOutOfSpan, [me], t1, t2, t3)
  if pEnabled then
    me.setNormalState()
  else
    me.setDisabledState()
  end if
end
on Disable me
  if pEnabled = 0 then
    exit
  end if
  pEnabled = 0
  pPressed = 0
  me.setDisabledState()
end
on enable me
  if pEnabled then
    exit
  end if
  pEnabled = 1
  me.setNormalState()
end
on setNewMembers me, tMembers
  callAncestor(#setNewMembers, me, tMembers)
  if pEnabled = 0 then
    me.setDisabledState()
    exit
  end if
  if pPressed = 1 then
    me.setPressedState()
    exit
  end if
  me.setNormalState()
  me.correctRectToMember()
end
on mouseEnter me
  callAncestor(#mouseEnter, [me])
  if me.pEnabled = 0 then
    exit
  end if
  if pPressed = 0 then
    me.setRollOverState()
  else
    me.setPressedState()
  end if
end
on mouseLeave me
  callAncestor(#mouseLeave, [me])
  if me.pEnabled = 0 then
    exit
  end if
  if pPressed = 0 then
    me.setNormalState()
  else
    gMach8GUIManager.disableInterfaceExcept(me)
    pLockingInterface = 1
  end if
end
on mouseDown me
  callAncestor(#mouseDown, [me])
  if me.pEnabled = 0 then
    exit
  end if
  pPressed = 1
  me.setPressedState()
end
on mouseUp me
  callAncestor(#mouseUp, [me])
  if pLockingInterface then
    gMach8GUIManager.enableInterface()
    pLockingInterface = 0
  end if
  if me.pEnabled = 0 then
    exit
  end if
  me.setRollOverState()
  pPressed = 0
end
on mouseUpOutSide me
  me.realMouseUpOutside()
end
on exitFrame me
  callAncestor(#exitFrame, [me])
  if pPressed and the mouseDown = 0 then
    pHackMouseUpOutsideFrames = pHackMouseUpOutsideFrames + 1
    if pHackMouseUpOutsideFrames = 5 then
      put "fakemouseupoutside"
      me.realMouseUpOutside()
    end if
  else
    pHackMouseUpOutsideFrames = 0
  end if
end
on realMouseUpOutside me
  if pLockingInterface then
    gMach8GUIManager.enableInterface()
    pLockingInterface = 0
  end if
  if me.pEnabled = 0 then
    exit
  end if
  pPressed = 0
  me.setNormalState()
  gMach8GUIManager.enableInterface()
end
on setNormalState me
  me.setMember(me.pMembers[#normal])
  me.correctRectToMember()
end
on setRollOverState me
  me.setMember(me.pMembers[#rollover])
  me.correctRectToMember()
end
on setPressedState me
  me.setMember(me.pMembers[#pressed])
  me.correctRectToMember()
end
on setDisabledState me
  me.setMember(me.pMembers[#disabled])
  me.correctRectToMember()
end
on destroy me
  callAncestor(#destroy, me)
  ancestor = 0
  return 0
end