-- Behavior
property p3dSprite
property pCar
property pLastFrameMS
property pHavokManager
property p3d
property pcamera
property pRunning
property pHavokSubscribers
property pLightMapManager

on new me
  p3dSprite = script("sprite").new([#range: ["driving"], #name: "3d"])
  return me
end
on start me
  p3d = member("3d")
  t = getDynamicSlot()
  p3d.duplicate(t)
  t.name = "3d2"
  p3d.resetWorld()
  pRay3d = member("3d2")
  pRay3d.preload()
  pLightMapManager = script("lightmapmanager").new()
  pStopped = 0
  pHavokSubscribers = []
  pHavokManager = script("havokmanager").new()
  (the actorList).append(me)
  pCar = script("car").rawNew()
  pCar.new()
  if keyPressed("1") = 0 then
    pcamera = script("camera").new()
  else
    pcamera = script("camera_fromadistance").new()
  end if
  pLastFrameMS = the milliSeconds
  pUpdatedUntillMS = the milliSeconds
  pMaxIterations = 1
  pRunning = 1
end
on firstFrame me
  pLightMapManager.doApplyUVs()
  pcamera.fadeIn()
  tSprite = p3dSprite.pScoreSprite
  tcamera = p3d.camera("overlays")
  tSprite.addCamera(tcamera)
  tSprite.camera(tSprite.cameraCount()).rect = rect(0, 0, 640, 480)
end
on stop me
  pRunning = 0
  pHavokSubscribers.deleteAll()
  (the actorList).deleteOne(me)
  if objectp(pCar) then
    pCar = pCar.destroy()
  end if
end
on stopDriving me
  pcamera.carStoppedDriving()
  pCar.stopDriving()
end
on registerForUpdate me, tObject
  pHavokSubscribers.append(tObject)
end
on stepFrame me
  if pRunning = 0 then
    exit
  end if
  tDif = the milliSeconds - pLastFrameMS
  pLastFrameMS = the milliSeconds
  tDif = min(tDif, 100)
  me.update(tDif)
end
on update me, tDif
  if tDif > 20 then
    me.update(tDif - 20)
    tDif = 20
  end if
  if pRunning = 0 then
    exit
  end if
  pHavokManager.update(tDif)
  pcamera.update(tDif)
  pCar.update(tDif)
  call(#havokUpdate, pHavokSubscribers, tDif)
end
on destroy me
  (the actorList).deleteOne(me)
  if objectp(pCar) then
    pCar = pCar.destroy()
  end if
  return 0
end
on get3dSprite me
  return p3dSprite
end
on getHavokManager me
  return pHavokManager
end
on getCar me
  return pCar
end