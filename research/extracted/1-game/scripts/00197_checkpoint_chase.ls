-- Script
property ancestor
property p3d
property pLaps
global gMainManager

on new me
  ancestor = script("checkpoint_gameType").rawNew()
  callAncestor(#new, me)
  p3d = member("3d")
  pLaps = 0
  return me
end
on realStart me
  callAncestor(#realStart, me)
  me.pTimer.setTime(10)
end
on outOfTime me
  sound(4).play([#member: member("stingloseloop")])
  me.pTextMessageManager.setText("Out of Time!" & RETURN & "Hit all Checkpoints to unlock Stunt Rally")
  me.pTextMessageManager.stop()
  me.stopDriving()
  script("timeout").new(script("callback").new(#destroy, me), 6000)
  me.pArrow.hide()
end
on passedCheckPoint me
  me.pTextMessageManager.setText("Checkpoint!" & RETURN & "+10 Seconds")
  me.pTimer.addTime(10)
  me.pCheckPointIndex = me.pCheckPointIndex + 1
  if me.pCheckPointIndex > me.pCheckPoints.count then
    me.pCheckPointIndex = 1
    pLaps = pLaps + 1
    if pLaps > 1 then
      sound(4).play([#member: member("stingwin")])
      gMainManager.getSelectLevelManager().unlock("stunt_rally")
      me.pTextMessageManager.setText("You did it!" & RETURN & "Stunt Rally unlocked!" & RETURN)
      me.pTextMessageManager.stop()
      me.stopDriving()
      script("timeout").new(script("callback").new(#destroy, me), 6000)
      me.pArrow.hide()
    end if
  end if
  me.pArrow.pointAt(me.pCheckPoints[me.pCheckPointIndex].worldPosition)
end
on getPointsCounterScript me
  return script("pointscounter")
end
on destroy me
  callAncestor(#destroy, me)
end