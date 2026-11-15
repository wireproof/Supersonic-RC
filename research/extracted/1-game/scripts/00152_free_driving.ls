-- Script
property ancestor
property pReachedGoal
property pLaps
global gMainManager

on new me
  ancestor = script("checkpoint_gameType").rawNew()
  callAncestor(#new, me)
  p3d = member("3d")
  pReachedGoal = 0
  pLaps = 0
  return me
end
on passedCheckPoint me
  me.pTextMessageManager.setText("Checkpoint!" & RETURN & "+2 Seconds")
  me.pTimer.addTime(2)
  me.pCheckPointIndex = me.pCheckPointIndex + 1
  if me.pCheckPointIndex > me.pCheckPoints.count then
    me.pCheckPointIndex = 1
    pLaps = pLaps + 1
    if pReachedGoal = 0 and pLaps > 1 then
      sound(4).play([#member: member("stingwin")])
      gMainManager.getSelectLevelManager().unlock("checkpoint_chase")
      me.pTextMessageManager.setText("You did it!" & RETURN & "Checkpoint Chase unlocked!" & RETURN & "Free Driving Mode - Press ESC to exit")
      pReachedGoal = 1
      me.pArrow.hide()
    end if
  end if
  me.pArrow.pointAt(me.pCheckPoints[me.pCheckPointIndex].worldPosition)
end
on realStart me
  callAncestor(#realStart, me)
  me.pTimer.setTime(150)
end
on getPointsCounterScript me
  return script("pointscounter")
end
on outOfTime me
  if pReachedGoal then
    exit
  end if
  me.pTextMessageManager.setText("Out of Time!" & RETURN & "Finish 2 laps in under 2:30 to unlock Checkpoint Chase" & RETURN & "Free Driving Mode - Press ESC to exit")
  me.hideCheckpoints()
  me.pArrow.hide()
  pOutOfTime = 1
end
on destroy me
  callAncestor(#destroy, me)
  (the actorList).deleteOne(me)
end