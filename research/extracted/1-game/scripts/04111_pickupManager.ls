-- Script
property pCarRB
property pmodel
property pUp
property pUpSideDown
property pUpSideDownStartTime
property pHavok
global gMainManager

on new me
  pCarRB = gMainManager.getDrivingManager().getCar().getRB()
  pmodel = gMainManager.getDrivingManager().getCar().getModel()
  pHavok = gMainManager.getDrivingManager().getHavokManager().getHavok()
  pUp = vector(0, 0, -1)
  (the actorList).append(me)
  return me
end
on stepFrame me
  tUpSideDown = 0
  if pCarRB.position.z < -10 then
    tPos = pCarRB.position
    tPos.z = 800
    tResult = member("3d2").modelsUnderRay(tPos, vector(0, 0, -1), 1, #detailed)
    if tResult.count > 0 then
      tNewPos = tResult[1][#isectPosition] + vector(0, 0, 30)
    else
      tNewPos = tPos
      tNewPos.z = 100
    end if
    pCarRB.position = tNewPos
  end if
  if pCarRB.linearVelocity.length < 10 then
    if pmodel.getWorldTransform().zAxis.angleBetween(pUp) < 20 then
      case pUpSideDown of
        0:
          pUpSideDownStartTime = pHavok.simTime
        1:
          if pHavok.simTime - pUpSideDownStartTime > 8 then
            pCarRB.position = pCarRB.position + vector(0, 0, 20)
            pCarRB.rotation = [vector(0, 0, 1), 0]
          end if

      end case
      pUpSideDown = 1
      tUpSideDown = 1
    end if
  end if
  if tUpSideDown = 0 then
    pUpSideDown = 0
  end if
end
on destroy me
  (the actorList).deleteOne(me)
end