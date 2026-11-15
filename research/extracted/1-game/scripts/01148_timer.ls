-- Script
property pTextures
property p3dSprites
property pHavok
property pStopped
property pStopTime
property pOutOfTime
property pGameManager

on new me, tGameManager
  pGameManager = tGameManager
  p3d = member("3d")
  pHavok = member("havok")
  pTextures = [:]
  pStopped = 0
  pOutOfTime = 0
  tGenerator = member("timerfontgenerator")
  tChars = "1234567890:/ "
  timage = image(32, 64, 32)
  timage.fill(0, 0, 32, 64, rgb(255, 255, 255))
  tImage2 = image(32, 64, 8, #grayscale)
  repeat with i = 1 to tChars.length
    tGenerator.text = tChars.char[i]
    tImage2.fill(0, 0, 32, 64, rgb(255, 255, 255))
    tImage2.copyPixels(tGenerator.image, tGenerator.rect, tGenerator.rect)
    timage.setAlpha(tImage2)
    timage.useAlpha = 1
    member("debug").image = timage
    ttexture = p3d.newTexture("char_" & tChars.char[i], #fromImageObject, timage)
    ttexture.renderFormat = #rgba8888
    pTextures.addProp(tChars.char[i], ttexture)
  end repeat
  p3dSprites = []
  repeat with ii = 1 to 5
    tOverlay = script("insceneoverlay").new(p3d)
    tOverlay.setPosition(point(16 + ii * 18, 50))
    tOverlay.turnOn()
    p3dSprites.append(tOverlay)
  end repeat
  member("textgenerator").text = "Time remaining" & RETURN
  member("textgenerator").fontStyle = [#bold, #italic]
  member("textgenerator").fontSize = 12
  member("textgenerator").fixedLineSpace = 0
  member("textgenerator").color = rgb(255, 255, 255)
  tSprite = script("3d_textsprite").new()
  tSprite.setPosition(point(72, 20))
  (the actorList).append(me)
  pAddedTime = 0
  return me
end
on stepFrame me
  t = me.getTime()
  if t = 0 and pOutOfTime = 0 then
    pOutOfTime = 1
    call(#outOfTime, [pGameManager])
  end if
  tString = me.getTimeString()
  repeat with i = 1 to tString.length
    p3dSprites[i].setTexture(pTextures[tString.char[i]])
  end repeat
end
on getTime me
  if pStopped then
    return pStopTime
  else
    return max(0, integer(the simTime of pHavok / 3))
  end if
end
on stop me
  pStopTime = me.getTime()
  pStopped = 1
end
on getTimeString me
  tTime = me.getTime()
  tMinutes = tTime / 60
  tSeconds = tTime - tMinutes * 60
  return padd(tMinutes, 2) & ":" & padd(tSeconds, 2)
end
on destroy me
  (the actorList).deleteOne(me)
end
on padd tString, tLength
  tString = string(tString)
  repeat while tString.length < tLength
    tString = "0" & tString
  end repeat
  return tString
end
on subtractTime me, tTime
  pAddedTime = pAddedTime - tTime
end