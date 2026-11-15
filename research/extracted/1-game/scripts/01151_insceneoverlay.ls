-- Script
property pOverlayManager
property pShader
property pTexture
property pmodel
property pScene
property pDepth
property pPos
property pHorizontalUnits
property pVerticalUnits
property pOn
property pChild
global gMainManager

on new me, tScene
  pScene = tScene
  tResource = pScene.modelResource("defaultmodel")
  pmodel = pScene.newModel("overlay" & random(1000000), tResource)
  pmodel.visibility = #both
  pmodel.removeFromWorld()
  pOn = 0
  pShader = pScene.newShader("overlayshader" & random(1000000), #standard)
  pShader.specular = rgb(0, 0, 0)
  pShader.emissive = rgb("ffffff")
  pShader.diffuse = rgb(0, 0, 0)
  pShader.ambient = rgb(0, 0, 0)
  pShader.textureRepeatList[1] = 0
  pmodel.shaderList[1] = pShader
  pmodel.shaderList[2] = pShader
  tcamera = pScene.camera("overlays")
  if voidp(tcamera) then
    tcamera = pScene.newCamera("overlays")
    tcamera.rootNode = tcamera
    tcamera.removeFromWorld()
    tcamera.colorBuffer.clearAtRender = 0
  end if
  me.setDepth(500)
  me.setPosition(point(100, 50))
  me.stageResize()
  return me
end
on setDepth me, tDepth
  me.pDepth = pScene.camera[1].hither + tDepth
  me.figureOutUnitsAtDepth()
  if pPos <> VOID then
    me.positionModel()
  end if
end
on setBlend me, tBlend
  pShader.blend = tBlend
end
on getBlend me
  return the blend of pShader
end
on setColor me, tColor
  pShader.emissive = tColor
end
on setTexture me, ttexture
  pTexture = ttexture
  pShader.textureList[1] = pTexture
  me.positionModel()
end
on setPosition me, tPos
  pPos = tPos
  me.positionModel()
end
on getPosition me
  return pPos
end
on SetWidth me, tWidth
  pwidth = tWidth
end
on SetHeight me, tHeight
  pheight = tHeight
end
on getModel me
  return pmodel
end
on destroy me
  pScene.deleteShader(pShader.name)
  pScene.deleteModel(pmodel.name)
  return 0
end
on turnOn me
  tGroup = pScene.camera("overlays")
  if voidp(tGroup) then
    tcamera = pScene.newCamera("overlays")
    tcamera.rootNode = tcamera
    tcamera.removeFromWorld()
    tcamera.colorBuffer.clearAtRender = 0
  end if
  pmodel.parent = tGroup
  pOn = 1
end
on turnOff me
  pmodel.removeFromWorld()
  pOn = 0
end
on isOn me
  return pOn
end
on figureOutUnitsAtDepth me
  pVerticalUnits = pDepth * tan(pScene.camera("overlays").fieldOfView * 0.5 * PI / 180) * 2
  pHorizontalUnits = pVerticalUnits * 640 / 480.0
end
on positionModel me
  tX = float(pPos[1]) / 640
  tY = 1 - float(pPos[2]) / 480
  trX = (tX - 0.5) * pHorizontalUnits
  trY = (tY - 0.5) * pVerticalUnits
  pmodel.transform.position = vector(trX, trY, -pDepth)
  t = transform()
  t.rotate(0, 180, 0)
  pmodel.transform.axisAngle = t.axisAngle
  if pTexture <> VOID then
    tWidth = pTexture.width
    tHeight = pTexture.height
  else
    tWidth = 1
    tHeight = 1
  end if
  tXRatio = float(tWidth) / 640
  tYRatio = float(tHeight) / 480
  pmodel.transform.scale.x = tXRatio * pHorizontalUnits
  pmodel.transform.scale.y = tYRatio * pVerticalUnits
end
on stageResize me
  me.figureOutUnitsAtDepth()
  me.positionModel()
end