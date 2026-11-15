-- Script
property pCurrentSprite
property pCurrentSpriteStartedAt
property pStopped

on new me
  pStopped = 0
  (the actorList).append(me)
  return me
end
on setText me, tText
  if pStopped then
    exit
  end if
  member("textgenerator").text = tText
  member("textgenerator").line[1].fontSize = 24
  member("textgenerator").line[2].fontSize = 18
  member("textgenerator").line[3].fontSize = 12
  member("textgenerator").fixedLineSpace = 0
  member("textgenerator").fontStyle = [#bold, #italic]
  member("textgenerator").color = rgb(255, 255, 255)
  if objectp(pCurrentSprite) then
    pCurrentSprite.destroy()
  end if
  pCurrentSprite = script("3d_textsprite").new()
  pCurrentSprite.turnOn()
  pCurrentSprite.setPosition(point(320, 400))
  pCurrentSpriteStartedAt = the milliSeconds
end
on stop me
  pStopped = 1
end
on stepFrame me
  if objectp(pCurrentSprite) then
    if the milliSeconds > pCurrentSpriteStartedAt + 5000 then
      pCurrentSprite = pCurrentSprite.fadeOutAndDestroy()
    end if
  end if
end
on destroy me
  if objectp(pCurrentSprite) then
    pCurrentSprite.destroy()
  end if
  (the actorList).deleteOne(me)
end