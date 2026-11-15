-- Script
property pTimer
property pCar
property pStopping
property pPointsCounter
property pStuntDetector
property pCarObject
property pTextMessageManager
global gMainManager

on new me
  return me
end
on start me
  pStopping = 0
  script("fadein").new(script("callback").new(#realStart, me))
  mach8_go("loading")
  gGameTypeManager = me
end
on realStart me
  gMainManager.getDrivingManager().start()
  gMainManager.getDrivingManager().registerForUpdate(me)
  pCar = gMainManager.getDrivingManager().getCar().getRB()
  pCarObject = gMainManager.getDrivingManager().getCar()
  script("fadeout").new(script("callback").new(#realStart2, me))
  pTimer = script("chasetimer").new(me)
  pPointsCounter = me.getPointsCounterScript().new(me)
  pTextMessageManager = script("textmessagemanager").new()
  pStuntDetector = script("stuntdetector").new(me)
end
on getPointsCounterScript me
  return script("pointsgoalcounter")
end
on realStart2 me
  mach8_go("driving")
  gMainManager.getDrivingManager().firstFrame()
  (the actorList).append(me)
end
on havokUpdate me
  if keyPressed(53) then
    me.stopDriving()
    me.destroy()
  end if
  if keyPressed("s") then
    set the soundEnabled to not the soundEnabled
  end if
end
on stuntEvent me, tPoints
  pTextMessageManager.setText(getStuntText(tPoints) & RETURN & tPoints & " Points!")
  pPointsCounter.addPoints(tPoints)
end
on stopDriving me
  pStopping = 1
  pTimer.stop()
  gMainManager.getDrivingManager().stopDriving()
end
on getTimer me
  return pTimer
end
on destroy me
  if objectp(pTimer) then
    pTimer = pTimer.destroy()
  end if
  pTextMessageManager = pTextMessageManager.destroy()
  gMainManager.getDrivingManager().stop()
  gMainManager.getSelectLevelManager().start()
  return 0
end