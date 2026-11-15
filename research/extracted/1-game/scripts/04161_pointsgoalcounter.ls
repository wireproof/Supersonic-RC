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
  repeat with ii = 1 to 5 + 1 + 5
    tOverlay = script("insceneoverlay").new(p3d)
    tOverlay.setPosition(point(426 + ii * 18, 50))
    tOverlay.turnOn()
    if ii < 6 then
      tOverlay.setColor(rgb(255, 0, 0))
    end if
    if ii > 6 then
      tOverlay.setColor(rgb(0, 255, 0))
    end if
    p3dSprites.append(tOverlay)
  end repeat
  member("textgenerator").text = "Score / Goal" & RETURN
  member("textgenerator").word[1].color = rgb(255, 0, 0)
  member("textgenerator").word[3].color = rgb(0, 255, 0)
  member("textgenerator").fontStyle = [#bold, #italic]
  member("textgenerator").fontSize = 12
  member("textgenerator").fixedLineSpace = 0
  tSprite = script("3d_textsprite").new()
  tSprite.setPosition(point(552 - 18, 20))
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
  if pPoints >= pGoal and pReachedGoal = 0 then
    pReachedGoal = 1
    p3dSprites[1].setColor(rgb(0, 255, 0))
    p3dSprites[2].setColor(rgb(0, 255, 0))
    p3dSprites[3].setColor(rgb(0, 255, 0))
    p3dSprites[4].setColor(rgb(0, 255, 0))
    p3dSprites[5].setColor(rgb(0, 255, 0))
    call(#reachedGoal, [pGameManager])
  end if
  me.display()
end
on setGoal me, tGoal
  pGoal = tGoal
  me.display()
end
on getPointsString me
  return padd(pPoints, 5) & "/" & rpadd(pGoal, 5)
end
on destroy me
  pGameManager = 0
  call(#destroy, p3dSprites)
  return 0
end
on padd tString, tLength
  tString = string(tString)
  repeat while tString.length < tLength
    tString = " " & tString
  end repeat
  return tString
end
on rpadd tString, tLength
  tString = string(tString)
  repeat while tString.length < tLength
    tString = tString & " "
  end repeat
  return tString
end