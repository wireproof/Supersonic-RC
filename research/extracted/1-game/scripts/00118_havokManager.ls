-- Movie Script
property pHavok
property pForces
property pForcesOnPoint
global gMainManager

on new me
  p3d = member("3d")
  pHavok = member("havok")
  pHavok.Initialize(p3d)
  pHavok.dragParameters = [0, 0]
  pHavok.gravity = pHavok.gravity * 0.2
  repeat with i = 1 to pHavok.rigidBody.count
    pHavok.rigidBody[i].restitution = 0
  end repeat
  pNextHavokUpdate = the milliSeconds
  pHavokStepSize = 1 / 60.0
  pForces = []
  pForcesOnPoint = []
  return me
end
on update me, tDif
  tDif = tDif / 1000.0
  if tDif > 0.015 then
    tDif = 0.015
  end if
  if tDif < 0.003 then
    tDif = 0.003
  end if
  tDifL = tDif
  repeat with tForce in pForces
    tForce[1].applyForce(tForce[2])
  end repeat
  repeat with tForce in pForcesOnPoint
    tForce[1].applyForceAtPoint(tForce[2], tForce[3])
  end repeat
  pHavok.step(tDif * 2.5, 7)
  pForces.deleteAll()
  pForcesOnPoint.deleteAll()
end
on getHavok
  return pHavok
end
on applyForceAtPoint me, tRB, tPoint, tForce
  pForcesOnPoint.append([tRB, tPoint, tForce])
end
on applyForce me, tRB, tForce
  pForces.append([tRB, tForce])
end
on getSimTime me
  return the simTime of pHavok
end
on destroy me
  pHavok.shutDown()
  return 0
end