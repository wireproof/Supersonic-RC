-- Script
property ancestor
property pTexture
property p3d
property pBlendTarget
property pLastFrameMS

on new me, tText
  tGenerator = member("textgenerator")
  if voidp(tText) = 0 then
    tGenerator.text = tText
    tGenerator.fontSize = 24
    tGenerator.fontStyle = [#bold]
  end if
  p3d = member("3d")
  tTextHeight = member("textgenerator").height
  tPowersOf2 = [2, 4, 8, 16, 32, 64, 128, 256, 512]
  i = 1
  repeat while tPowersOf2[i] < tTextHeight
    i = i + 1
  end repeat
  timage = image(512, tPowersOf2[i], 32)
  tAlpha = image(512, tPowersOf2[i], 8, #grayscale)
  tAlpha.copyPixels(tGenerator.image.extractAlpha(), tGenerator.rect, tGenerator.rect)
  timage.copyPixels(tGenerator.image, tGenerator.rect, tGenerator.rect)
  timage.setAlpha(tAlpha)
  timage.useAlpha = 1
  pTexture = p3d.newTexture("text" & random(42342342), #fromImageObject, timage)
  pTexture.renderFormat = #rgba8888
  ancestor = script("insceneoverlay").rawNew()
  callAncestor(#new, me, p3d)
  me.setTexture(pTexture)
  me.turnOn()
  me.setPosition(point(330, 200))
  me.setBlend(0)
  (the actorList).append(me)
  pLastFrameMS = the milliSeconds
  pBlendTarget = 100
  return me
end
on stepFrame me
  tDif = max(1, the milliSeconds - pLastFrameMS)
  pLastFrameMS = the milliSeconds
  tBlend = min(100, max(0, me.getBlend() + (pBlendTarget - me.getBlend()) * power(0.003, 15.0 / tDif)))
  me.setBlend(tBlend)
  if pBlendTarget = 0 and tBlend = 0 then
    me.destroy()
  end if
end
on fadeOutAndDestroy me
  pBlendTarget = 0
end
on destroy me
  (the actorList).deleteOne(me)
  callAncestor(#destroy, me)
  p3d.deleteTexture(pTexture.name)
  return 0
end