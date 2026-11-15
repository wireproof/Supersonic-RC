-- Script
property pW3D
property pcamera
property pCar
property pSpeed
property pRadius
property pheight
global gMainManager

on new me
  pW3D = member("3d")
  pcamera = pW3D.camera[1]
  pCar = gMainManager.getCar()
  pcamera.worldPosition = vector(0, -584, 250)
  pcamera.fieldOfView = 45
  pheight = 640
  pRadius = 480
  pSpeed = 10
  return me
end
on update me, tDif
  tmodel = pCar.getModel()
  tPos = tmodel.worldPosition
  tPos.z = 0
  tMyPos = pcamera.worldPosition
  tMyPos.z = 0
  tDif = tPos - tMyPos
  if tDif.length > pRadius then
    tMyPos = tMyPos + tDif.getNormalized() * pSpeed
  end if
  tMyPos.z = max(pheight, tmodel.worldPosition.z + 200)
  pcamera.worldPosition = tMyPos
  pcamera.pointAt(tmodel.worldPosition, vector(0, 0, 1))
end