-- Script
property ancestor
property p3d
property pOutOfTime
property pReachedGoal
global gMainManager

on new me
  ancestor = script("gameTypeManager").rawNew()
  callAncestor(#new, me)
  p3d = member("3d")
  pReachedGoal = 0
  pOutOfTime = 0
  return me
end
on realStart me
  callAncestor(#realStart, me)
  me.pTimer.setTime(120)
  me.pPointsCounter.setGoal(2500)
end
on outOfTime me
  if pReachedGoal then
    exit
  end if
  pOutOfTime = 1
  me.pCarObject.stopDriving()
  sound(4).play([#member: member("stingloseloop")])
  me.pTextMessageManager.setText("Out of Time!" & RETURN & "Get 2500 points to unlock Scavenger Hunt")
  me.pTextMessageManager.stop()
  script("timeout").new(script("callback").new(#destroy, me), 6000)
end
on reachedGoal me
  if pOutOfTime then
    exit
  end if
  pReachedGoal = 1
  sound(4).play([#member: member("stingwin")])
  gMainManager.getSelectLevelManager().unlock("scavenger_hunt")
  me.pTextMessageManager.setText("You did it!" & RETURN & "Scavenger Hunt Unlocked!")
  me.pTextMessageManager.stop()
  script("timeout").new(script("callback").new(#destroy, me), 6000)
  me.pCarObject.stopDriving()
end
on stuntEvent me, tPoints
  me.pTextMessageManager.setText(getStuntText(tPoints) & RETURN & tPoints & " Points!")
  me.pPointsCounter.addPoints(tPoints)
end