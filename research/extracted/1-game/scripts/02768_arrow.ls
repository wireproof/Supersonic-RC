-- Script
property pmodel
property pcamera
property pCarCam
property pTarget
property pCarRB
property pGroup
property pDummy
global gMainManager

on new me
  p3d = member("3d")
  member("arrow2").preload()
  pmodel = p3d.cloneModelFromCastmember("pointarrow", "arrow", member("arrow2"))
  pCarCam = p3d.camera[1]
  pcamera = p3d.newCamera("arrowcam")
  pCarRB = gMainManager.getDrivingManager().getCar().getRB()
  pcamera.rootNode = pmodel
  pcamera.removeFromWorld()
  pcamera.transform = transform()
  pcamera.removeFromWorld()
  pmodel.parent = pcamera
  pmodel.transform.position = vector(0, -12, -50)
  pmodel.transform.scale = vector(0.05, 0.05, 0.05)
  pmodel.transform.rotation = vector(-70, 0, 0)
  pmodel.pointAtOrientation = [vector(0, 1, 0), vector(0, 0, 1)]
  pDummy = pmodel.clone("arrowdummy")
  pDummy.transform.identity()
  pDummy.pointAtOrientation = [vector(0, 1, 0), vector(0, 0, 1)]
  pDummy.parent = pcamera
  pTarget = vector()
  (the actorList).append(me)
  return me
end
on pointAt me, tTarget
  pTarget = tTarget
end
on spriteReady me
  tSprite = gMainManager.getDrivingManager().get3dSprite().pScoreSprite
  tSprite.addCamera(pcamera)
  tSprite.camera(tSprite.cameraCount()).rect = rect(0, 0, 640, 480)
  pcamera.colorBuffer.clearAtRender = 0
end
on stepFrame me
  pcamera.transform = pCarCam.transform
  pTarget.z = pmodel.worldPosition.z
  pDummy.pointAt(pTarget, pCarCam.transform.yAxis)
  pmodel.transform.rotation = pDummy.transform.rotation
end
on hide me
  pmodel.visibility = #none
end
on destroy me
  (the actorList).deleteOne(me)
  return 0
end