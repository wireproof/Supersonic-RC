-- Script
property pHavok
property pRB
property pmodel
property pW3D
property pWheels
property pStep
property pRayCaster
property pCarSound
property pSkidding
property pReversing
property pStopped
property pRay3d
property pShadow
property pPickUpManager
property pCrashSoundsDown
property pCrashSoundsUp

on new me
  pW3D = member("3d")
  pHavok = member("havok")
  pmodel = pW3D.model("car")
  pmodel.addModifier(#meshDeform)
  updateStage()
  pRB = pHavok.makeMovableRigidBody("car", 3, 1)
  pRay3d = member("3d2")
  tLiftBody = 2
  pStopped = 0
  pRB.position = vector(2854.77, -5445.81, 345.6299)
  pRB.position = vector(3790.17, -5696.19, 338.6598)
  pRB.shiftCenterOfMass(vector(0, 0, -11.5 - tLiftBody))
  pRB.friction = 10
  pRB.restitution = 0.01
  member("holypolycrap").preload()
  pW3D.cloneModelFromCastmember("car2", "car", member("holypolycrap"))
  pW3D.model("car2").parent = pmodel
  pmodel.visibility = #none
  tTransform = transform()
  tTransform.scale = vector(0.17, 0.17, 0.17)
  tTransform.rotation = vector(0, 0, 180)
  tTransform.position = vector(0, 0, 4 - tLiftBody)
  pW3D.model("car2").transform = tTransform
  pSkidding = 0
  pWheels = []
  pWheels.append(script("wheel").new(me, vector(-9.5, 17, -5 - tLiftBody), 1, 1))
  pWheels.append(script("wheel").new(me, vector(9.5, 17, -5 - tLiftBody), 1, 2))
  pWheels.append(script("wheel").new(me, vector(-9.5, -17, -5 - tLiftBody), 0, 3))
  pWheels.append(script("wheel").new(me, vector(9.5, -17, -5 - tLiftBody), 0, 4))
  (the actorList).append(me)
  pHavok.registerStepCallback(#havokStep, me)
  pHavok.registerInterest("car", #all, 0, 0, #collision, me)
  pStep = 0
  pCarSound = script("carsound").new(me, pWheels)
  pShadow = pW3D.newModel("carshadow", pW3D.modelResource("defaultModel"))
  tshader = pW3D.newShader("shadowshader", #standard)
  pShadow.shader = tshader
  ttexture = pW3D.newTexture("carshadowtex", #fromCastMember, member("carshadow", "art"))
  ttexture.renderFormat = #rgba8888
  tshader.texture = ttexture
  tshader.blend = 50
  tshader.emissive = rgb(255, 255, 255)
  tshader.specular = rgb(0, 0, 0)
  tshader.ambient = rgb(0, 0, 0)
  tshader.diffuse = rgb(0, 0, 0)
  pShadow.visibility = #both
  pPickUpManager = script("pickupmanager").new()
  pCrashSoundsDown = []
  pCrashSoundsUp = []
  repeat with i = 1 to 3
    pCrashSoundsDown.append(member("crash" & i & "_glass"))
  end repeat
  repeat with i = 1 to 8
    pCrashSoundsUp.append(member("crash" & i))
  end repeat
  return me
end
on stepFrame me
  callAncestor(#stepFrame, [me])
  tResult = pRay3d.modelsUnderRay(pRB.position, vector(0, 0, -1), 1, #detailed)
  if tResult.count > 0 then
    pShadow.transform.identity()
    pShadow.transform.scale = vector(32, 78, 1)
    pShadow.worldPosition = tResult[1][#isectPosition] + tResult[1][#isectNormal] * 2
    pShadow.pointAt(pShadow.worldPosition + tResult[1][#isectNormal])
    pShadow.rotate(0, 0, -pmodel.transform.rotation[3])
  end if
end
on collision me, t1, t2, t3, t4, t5, t6
  tMax = 4
  t = pRB.angularmomentum
  if t.length > tMax then
    pRB.angularmomentum = pRB.angularmomentum.getNormalized() * tMax
  end if
  t = pRB.angularVelocity
  if t.length > tMax then
    pRB.angularVelocity = pRB.angularVelocity.getNormalized() * tMax
  end if
  if t1[5] > 1 then
    if ilk(sound(3).member) <> #member then
      if pmodel.transform.zAxis.z > 0.5 then
        tmember = pCrashSoundsUp[1]
        pCrashSoundsUp.deleteAt(1)
        pCrashSoundsUp.append(tmember)
      else
        tmember = pCrashSoundsDown[1]
        pCrashSoundsDown.deleteAt(1)
        pCrashSoundsDown.append(tmember)
      end if
      sound(3).play([#member: tmember])
      sound(3).volume = 125
    end if
  end if
end
on update me, tDif
  pCarSound.update()
  call(#update, pWheels, tDif)
end
on getRayCaster me
  return pRayCaster
end
on prepareForRay me
  pW3D.model("car2").removeFromWorld()
end
on unprepareForRay me
end
on stopDriving me
  pCarSound.stopDriving()
  gGameTypeManager.getTimer().stop()
  call(#stopDriving, pWheels)
  pStopped = 1
end
on getRB me
  return pRB
end
on getWheels me
  return pWheels
end
on getModel me
  return pmodel
end
on destroy me
  if objectp(pPickUpManager) then
    pPickUpManager = pPickUpManager.destroy()
  end if
  (the actorList).deleteOne(me)
  call(#destroy, pWheels)
  pCarSound = pCarSound.destroy()
  pWheels = 0
  return 0
end