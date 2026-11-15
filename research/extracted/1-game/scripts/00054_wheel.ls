-- Script
property pCar
property p3d
property pmodel
property pHavok
property pTraction
property pSpinSpeed
property pRadius
property pRB
property pCarRB
property pRayISect
property pRestLength
property pSpring
property pSpeed
property pRealWorldPos
property pLoad
property pArrow
property pArrow2
property pArrow3
property pOnGround
property pArrow4
property pIndex
property pForceMultiplier
property pGroundNormal
property pLeft
property pRay3d
property pRayStart
property pSpringLength
property pRayCaster
property pHavokManager
property pPosition
property pVisualModel
property pRotation
property pVisualGroup
property pSkidding
property pStopped
property pDistanceCovered
global gMainManager

on new me, tCar, tPosition, tTraction, tIndex
  pCar = tCar
  pStopped = 0
  pTraction = tTraction
  p3d = member("3d")
  pRay3d = member("3d2")
  pHavok = member("havok")
  pHavokManager = gMainManager.getDrivingManager().getHavokManager()
  pRotation = 0
  pRayCaster = pCar.getRayCaster()
  tResource = p3d.modelResource("wheel")
  if voidp(tResource) then
    tResource = p3d.newModelResource("wheel", #box)
    tResource.length = 5
    tResource.width = 5
    tResource.height = 5
  end if
  pForceMultiplier = 0.0003
  pIndex = tIndex
  case tPosition.x < 0 of
    0:
      pLeft = 0
    1:
      pLeft = 1

  end case
  pmodel = p3d.newModel("wheel" & me, tResource)
  pVisualModel = pCar.getModel().child[1].child[1]
  tScale = pVisualModel.getWorldTransform().scale
  pVisualModel.removeFromWorld()
  pVisualModel.transform.scale = tScale
  pVisualGroup = p3d.newGroup("visualwheel" & me)
  pVisualGroup.transform = pVisualModel.transform
  pVisualModel.transform.identity()
  tFlipGroup = p3d.newGroup("flipgroup" & me)
  tFlipGroup.parent = pVisualGroup
  if pIndex = 1 or pIndex = 2 then
    tFlipGroup.rotate(0, 180, 0)
  end if
  pVisualModel.parent = tFlipGroup
  pmodel.parent = tCar.getModel()
  pmodel.transform.position = tPosition
  pPosition = tPosition
  pmodel.visibility = #none
  if pTraction then
    pmodel.debug = 0
  end if
  pHavok.registerStepCallback(#havokStep, me)
  pSkidding = 0
  pRadius = 25
  pRestLength = 30
  pDistanceCovered = 0
  tRBModel = p3d.newModel("wheelrb" & me, tResource)
  tRBModel.addModifier(#meshDeform)
  tRBModel.worldPosition = vector(550, 550, 450) + tPosition
  tRBModel.removeFromWorld()
  pCarRB = pCar.getRB()
  pSpringLength = pRestLength
  pGroundNormal = vector(0, 0, 1)
  return me
end
on update me
  if pStopped then
    t126 = 0
    t125 = 0
    t123 = 0
    t124 = 0
  else
    t126 = keyPressed(126)
    t125 = keyPressed(125)
    t123 = keyPressed(123)
    t124 = keyPressed(124)
  end if
  pVisualGroup.transform.rotation = pCar.getModel().transform.rotation
  me.findRayISect()
  pSpeed = pCarRB.linearVelocity + pCarRB.angularVelocity.cross(pmodel.worldPosition - (pCarRB.position + pCarRB.centerOfMass))
  tSpeed = pSpeed.duplicate()
  tSpeed.z = 0
  if pOnGround then
    pDistanceCovered = pDistanceCovered + tSpeed.length * 0.1
  end if
  tDown = -pmodel.getWorldTransform().zAxis.getNormalized()
  pRealWorldPos = tDown * (pSpringLength - 25) + pmodel.worldPosition
  me.actAsSpring()
  tSideWayDirection = pGroundNormal.cross(pmodel.getWorldTransform().yAxis)
  tSideWayDirection.normalize()
  tForwardDirection = -pGroundNormal.cross(tSideWayDirection)
  tForwardDirection.normalize()
  if pLeft then
    tSideWayDirection = -tSideWayDirection
  end if
  tLocalForwardSpeed = pSpeed.dot(tForwardDirection)
  if t126 then
    tLongitudonalForce = 6300
  end if
  tBraking = 0
  pCar.pReversing = 0
  if t125 then
    if tLocalForwardSpeed < 0 then
      tLongitudonalForce = -4000
      pCar.pReversing = 1
    else
      tLongitudonalForce = -10000
      tBraking = 1
    end if
  end if
  if keyPressed(" ") and abs(tLocalForwardSpeed) > 10 or pStopped then
    tLongitudonalForce = -10000 * sign(tLocalForwardSpeed)
    tBraking = 1
  end if
  tWheelPos = pCar.getModel().transform.inverse() * pRealWorldPos + vector()
  tTotalForce = vector()
  if pTraction and pOnGround then
    if pCar.pSkidding then
      tLongitudonalForce = tLongitudonalForce * 0.5
    end if
    tTotalForce = tTotalForce + tForwardDirection * tLongitudonalForce
  end if
  if pOnGround then
    tDrag = tLocalForwardSpeed * 6
    if pCar.pSkidding then
      tDrag = tDrag * 0.5
    end if
    tTotalForce = tTotalForce - tForwardDirection * tDrag
  end if
  if pTraction = 1 then
    if t123 then
      pRotation = min(5, pRotation + 1)
    else
      if t124 then
        pRotation = max(-5, pRotation - 1)
      else
        if abs(pRotation) > 0 then
          pRotation = pRotation - sign(pRotation)
        end if
      end if
    end if
    pmodel.transform.rotation = vector(0, 0, pRotation)
    pVisualModel.transform.rotation = vector(0, 0, -pRotation * 3)
  else
    pVisualModel.transform.rotation = vector()
  end if
  pVisualModel.transform.preRotate(pDistanceCovered, 0, 0)
  if pOnGround then
    t = pmodel.getWorldTransform()
    t.position = vector()
    tLocalSideWaySpeed = pSpeed.dot(tSideWayDirection)
    tSideWayDrag = tLocalSideWaySpeed * 150
    tMaxDrag = 3.0 * pLoad + pTraction * 100
    if pCar.pSkidding then
      tMaxDrag = tMaxDrag * 0.75
    end if
    if keyPressed(" ") and pTraction = 0 then
      tMaxDrag = tMaxDrag * 0.3
    end if
    if abs(tSideWayDrag) > tMaxDrag then
      tSideWayDrag = tSideWayDrag * 0.5
      pCar.pSkidding = 1
    else
      pCar.pSkidding = 0
    end if
    tTotalForce = tTotalForce - tSideWayDirection * tSideWayDrag
  end if
  pHavokManager.applyForceAtPoint(pCarRB, tTotalForce, tWheelPos)
  exit
end
on actAsSpring me
  pLoad = 0
  if pOnGround = 0 then
    exit
  end if
  tStrength = pCarRB.mass * pHavok.gravity.length / 4 * 10
  tdiff = pRayISect - pRayStart
  tForceLength = tStrength * (pRestLength - pSpringLength)
  tSpeedInDirectionOfForce = pSpeed.dot(tdiff.getNormalized())
  tLimit = 30
  tSpeedInDirectionOfForce = min(max(tSpeedInDirectionOfForce, -tLimit), tLimit)
  tDampFactor = 0.09
  tDamping = tStrength * tDampFactor * tSpeedInDirectionOfForce
  pLoad = tForceLength + tDamping
  tForce = pGroundNormal.getNormalized() * pLoad
  pHavokManager.applyForceAtPoint(pCarRB, tForce, pmodel.transform.position)
end
on stopDriving me
  pStopped = 1
end
on findRayISect me
  tDown = -pmodel.getWorldTransform().zAxis.getNormalized()
  tStartOffset = 25
  pRayStart = pmodel.worldPosition + pmodel.getWorldTransform().zAxis.getNormalized() * tStartOffset
  tResult = pRay3d.modelsUnderRay(pRayStart, tDown, 1, #detailed)
  if tResult.count > 0 then
    pRayISect = tResult[1][#isectPosition]
    if pRayISect.distanceTo(pRayStart) <= pRestLength then
      pSpringLength = max(20, pRayISect.distanceTo(pRayStart))
      pGroundNormal = tResult[1][#isectNormal]
      pVisualGroup.worldPosition = pRayStart + tDown * pSpringLength + vector(0, 0, 5.2)
      pOnGround = 1
      exit
    end if
  end if
  pOnGround = 0
  pSpringLength = pRestLength
  pVisualGroup.worldPosition = pRayStart + tDown * (pSpringLength - 5.2)
end