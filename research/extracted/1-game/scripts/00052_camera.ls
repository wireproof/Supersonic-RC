-- Script
property pW3D
property pcamera
property pCar
property pOldBehindDir
property pWannaBe
property pFollowing
property pRay3d
property pOrbit
global gMainManager

on new me
  pW3D = member("3d")
  pRay3d = member("3d2")
  pcamera = pW3D.camera[1]
  pCar = gMainManager.getDrivingManager().getCar()
  pcamera.worldPosition = vector(-2000, -584, 250)
  pcamera.fieldOfView = 70
  pOldBehindDir = vector(0, 0, 1)
  pWannaBe = pcamera.worldPosition
  pFolllowing = 1
  timage = image(1, 1, 32)
  timage.setPixel(0, 0, rgb(0, 0, 0))
  ttexture = pW3D.newTexture("black", #fromImageObject, timage)
  pcamera.addOverlay(ttexture, point(0, 0), 0)
  pcamera.overlay[1].scale = 640
  pcamera.overlay[1].loc = point(0, 0)
  pcamera.colorBuffer.clearAtRender = 0
  return me
end
on fadeIn me
  pcamera.removeOverlay(1)
end
on carStoppedDriving me
  pOrbit = 1
end
on update me, tDif
  tmodel = pCar.getModel()
  if pOrbit = 0 then
    if pCar.getRB().linearVelocity.length < 10 then
      tDontFollow = 1
    end if
    if pFollowing and tDontFollow = 0 then
      if pCar.getModel().worldPosition.distanceTo(pcamera.worldPosition) < 300 then
      end if
      tBehindDir = -pCar.getRB().linearVelocity
      tBehindDir.z = 0
      tBehindDir.normalize()
      pWannaBe = tmodel.worldPosition + tBehindDir * 50 + vector(0, 0, 0)
    else
      tBehindDir = -pCar.getModel().getWorldTransform().yAxis
      pWannaBe = tmodel.worldPosition + tBehindDir * 50 + vector(0, 0, 0)
      if pCar.getModel().worldPosition.distanceTo(pcamera.worldPosition) > 300 then
        pFollowing = 1
      end if
    end if
    pWannaBe.z = pCar.getModel().worldPosition.z + 10
  else
    tTime = the milliSeconds / 1000.0
    pWannaBe = pCar.getModel().worldPosition + vector(sin(tTime) * 150, cos(tTime) * 150, 50)
  end if
  pcamera.worldPosition = pcamera.worldPosition + (pWannaBe - pcamera.worldPosition) * 0.1
  tTarget = tmodel.worldPosition + vector(0, 0, 10)
  tResult = pRay3d.modelsUnderRay(tTarget, pcamera.worldPosition - tTarget, 1, #detailed)
  if tResult.count > 0 then
    if tResult[1][#isectPosition].distanceTo(tTarget) < pcamera.worldPosition.distanceTo(tTarget) then
      pcamera.worldPosition = tResult[1][#isectPosition]
    end if
  end if
  pcamera.pointAt(tTarget, vector(0, 0.01, 1))
  if the controlDown then
    nothing()
  end if
end