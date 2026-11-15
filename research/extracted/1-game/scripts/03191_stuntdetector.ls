-- Script
property pGameTypeManager
property pCar
property pWheels
property pJumpInProgress
property pJumpStartTime
property pHavok
property pJumpStartPos
property pJumpMaxHeight
property pCarRB
property pAngularDistance
property pMaxCrash
global gMainManager

on new me, tGameTypeManager
  pGameTypeManager = tGameTypeManager
  gMainManager.getDrivingManager().registerForUpdate(me)
  pCar = gMainManager.getDrivingManager().getCar()
  pCarRB = pCar.getRB()
  pWheels = pCar.getWheels()
  pHavok = gMainManager.getDrivingManager().getHavokManager().getHavok()
  pHavok.registerInterest("car", #all, 1, 0.1, #chassisCollision, me)
  pJumpInProgress = 0
  return me
end
on havokUpdate me
  tJumpInProgress = 1
  repeat with tWheel in pWheels
    if tWheel.pOnGround then
      tJumpInProgress = 0
    end if
  end repeat
  if pJumpInProgress then
    pAngularDistance = pAngularDistance + pCarRB.angularVelocity.length * pHavok.timeStep
    pJumpMaxHeight = max(pCarRB.position.z - pJumpStartPos.z, pJumpMaxHeight)
  end if
  if tJumpInProgress = 0 and pJumpInProgress = 1 then
    t = pCarRB.position
    t.z = 0
    pJumpStartPos.z = 0
    tDistanceCovered = pJumpStartPos.distanceTo(t)
    tPoints = 2
    tDuration = integer(me.getTime() - pJumpStartTime)
    tPoints = tPoints * max(1, tDuration / 20.0)
    tPoints = tPoints * max(1, pAngularDistance)
    tPoints = tPoints * 10
    if tPoints > 20 then
      pGameTypeManager.stuntEvent(integer(tPoints))
    end if
    put "duration " & tPoints
    put "height   " & pJumpMaxHeight
    put "distanceCovered :" & tDistanceCovered
    put "angularDistance :" & pAngularDistance
    put "maxcrash : " & pMaxCrash
    put "--"
  end if
  if tJumpInProgress = 1 and pJumpInProgress = 0 then
    pJumpStartTime = me.getTime()
    pJumpStartPos = pCarRB.position
    pJumpMaxHeight = 0
    pAngularDistance = 0
    pMaxCrash = 0
  end if
  pJumpInProgress = tJumpInProgress
end
on getTime me
  return the simTime of pHavok
end
on chassisCollision me, tInfo
  pMaxCrash = max(pMaxCrash, tInfo[5])
end
on destroy me
  pGameTypeManager = 0
  gMainManager.getDrivingManager().unregisterForUpdate(me)
  return 0
end