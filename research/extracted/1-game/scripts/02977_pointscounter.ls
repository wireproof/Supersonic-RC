-- Script
property pTextures
property p3dSprites
property pHavok
property pPoints
property pGoal
property pGameManager
property pReachedGoal

on new me, tGameManager
  pGameManager = tGameManager
  p3d = member("3d")
  pTextures = [:]
  pPoints = 0
  pGoal = 500
  pReachedGoal = 0
  tGenerator = member("timerfontgenerator")
  tChars = "0123456789/ "
  repeat with i = 1 to tChars.length
    pTextures.addProp(tChars.char[i], p3d.texture("char_" & tChars.char[i]))
  end repeat
  p3dSprites = []
  repeat with ii = 1 to 5
    tOverlay = script("insceneoverlay").new(p3d)
    tOverlay.setPosition(point(544 - 18 + ii * 18, 50))
    tOverlay.turnOn()
    p3dSprites.append(tOverlay)
  end repeat
  member("textgenerator").text = "Points" & RETURN
  member("textgenerator").word[1].color = rgb(255, 255, 255)
  member("textgenerator").fontStyle = [#bold, #italic]
  member("textgenerator").fontSize = 12
  member("textgenerator").fixedLineSpace = 0
  tSprite = script("3d_textsprite").new()
  tSprite.setPosition(point(582, 20))
  pAddedTime = 0
  me.display()
  return me
end
on display me
  tString = me.getPointsString()
  repeat with i = 1 to tString.length
    p3dSprites[i].setTexture(pTextures[tString.char[i]])
  end repeat
end
on addPoints me, tPoints
  pPoints = min(99999, pPoints + tPoints)
  me.display()
end
on getPointsString me
  return padd(pPoints, 5)
end
on destroy me
  pGameManager = 0
  return 0
end
on padd tString, tLength
  tString = string(tString)
  repeat while tString.length < tLength
    tString = "0" & tString
  end repeat
  return tString
end