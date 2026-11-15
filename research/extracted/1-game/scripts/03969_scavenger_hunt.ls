-- Script
property ancestor
property p3d
property pPrizesNotFound
property pOutOfTime
property pReachedGoal
global gMainManager

on new me
  ancestor = script("gameTypeManager").rawNew()
  callAncestor(#new, me)
  p3d = member("3d")
  pOutOfTime = 0
  pReachedGoal = 0
  return me
end
on realStart me
  callAncestor(#realStart, me)
  i = 1
  member("prize").preload()
  tPrize = p3d.cloneModelFromCastmember("prize", "prizesbox", member("prize"))
  tPrize.removeFromWorld()
  pPrizesNotFound = list()
  repeat while i < 140
    tGroup = p3d.group("prizes_" & i)
    if voidp(tGroup) then
      i = i + 1
      next repeat
    end if
    tmodel = tPrize.clone("prize" & i)
    tmodel.worldPosition = tGroup.worldPosition
    tmodel.addToWorld()
    pPrizesNotFound.append(tmodel)
    i = i + 1
  end repeat
  pCheckPointIndex = 1
  pTimeWon = 0
  me.pPointsCounter.setGoal(3000)
  me.pTimer.setTime(5 * 60)
end
on stuntEvent me
end
on havokUpdate me
  callAncestor(#havokUpdate, me)
  if me.pStopping then
    exit
  end if
  repeat with i = pPrizesNotFound.count down to 1
    tPrize = pPrizesNotFound[i]
    if me.pCar.position.distanceTo(tPrize.worldPosition) < 100 then
      pPrizesNotFound.deleteAt(i)
      tPrize.removeFromWorld()
      sound(4).play([#member: member("stinghiddentreasure")])
      me.pPointsCounter.addPoints(100)
      me.pTextMessageManager.setText("+100 Points")
    end if
  end repeat
end
on outOfTime me
  if pReachedGoal then
    exit
  end if
  pOutOfTime = 1
  sound(4).play([#member: member("stingloseloop")])
  me.pTextMessageManager.setText("Out of Time!" & RETURN & "Get 3000 points to unlock Supersonic Challenge" & RETURN & "Press ESC to exit")
  me.pTextMessageManager.stop()
  me.pCarObject.stopDriving()
  script("timeout").new(script("callback").new(#destroy, me), 6000)
end
on reachedGoal me
  if pOutOfTime then
    exit
  end if
  pReachedGoal = 1
  sound(4).play([#member: member("stingwin")])
  gMainManager.getSelectLevelManager().unlock("supersonic_challenge")
  me.pTextMessageManager.setText("You did it!" & RETURN & "Supersonic Challenge Unlocked!")
  me.pTextMessageManager.stop()
  me.pCarObject.stopDriving()
  script("timeout").new(script("callback").new(#destroy, me), 6000)
end