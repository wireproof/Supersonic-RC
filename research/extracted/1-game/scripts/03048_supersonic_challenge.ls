-- Script
property ancestor
property p3d
property pPrizesNotFound
property pReachedGoal
property pOutOfTime
property pLaps
global gMainManager

on new me
  ancestor = script("checkpoint_gameType").rawNew()
  callAncestor(#new, me)
  p3d = member("3d")
  pStopping = 0
  pReachedGoal = 0
  pOutOfTime = 0
  pLaps = 0
  return me
end
on realStart me
  callAncestor(#realStart, me)
  member("prize").preload()
  tPrize = p3d.cloneModelFromCastmember("prize", "prizesbox", member("prize"))
  tPrize.removeFromWorld()
  pPrizesNotFound = list()
  i = 1
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
  me.pTimer.setTime(5 * 60)
  me.pPointsCounter.setGoal(15000)
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
      me.pPointsCounter.addPoints(100)
      sound(4).play([#member: member("stinghiddentreasure")])
      me.pTextMessageManager.setText("+100 Points")
    end if
  end repeat
end
on stuntEvent me, tPoints
  me.pTextMessageManager.setText(getStuntText(tPoints) & RETURN & "+" & tPoints & " Points!")
  me.pPointsCounter.addPoints(tPoints)
end
on passedCheckPoint me
  me.pCheckPointIndex = me.pCheckPointIndex + 1
  if me.pCheckPointIndex > me.pCheckPoints.count then
    me.pCheckPointIndex = 1
    pLaps = pLaps + 1
    me.pArrow.hide()
    me.hideCheckpoints()
    if pLaps > 0 and pReachedGoal then
      me.win()
      exit
    end if
  end if
  me.pArrow.pointAt(me.pCheckPoints[me.pCheckPointIndex].worldPosition)
  me.pTimer.addTime(2)
  me.pPointsCounter.addPoints(500)
  me.pTextMessageManager.setText("Checkpoint!" & RETURN & "+2 Seconds! +500 Points!")
end
on outOfTime me
  if pReachedGoal and pLaps > 1 then
    exit
  end if
  pOutOfTime = 1
  sound(4).play([#member: member("stingloseloop")])
  me.pTextMessageManager.setText("Out of Time!" & RETURN & "Get 15000 Points and 1 Lap to win the game." & RETURN & "Press ESC to exit")
  me.pTextMessageManager.stop()
  me.pCarObject.stopDriving()
  script("timeout").new(script("callback").new(#destroy, me), 6000)
end
on reachedGoal me
  if pOutOfTime then
    exit
  end if
  pReachedGoal = 1
  if pLaps > 0 then
    me.win()
  end if
end
on win me
  sound(4).play([#member: member("stingwin")])
  me.pTextMessageManager.setText(RETURN & "Congratulations! You've won the Supersonic Challenge!" & RETURN & "Press ESC to return to the main menu.")
  me.pTextMessageManager.stop()
  me.pCarObject.stopDriving()
  script("timeout").new(script("callback").new(#destroy, me), 6000)
end
on destroy me
  callAncestor(#destroy, me)
end