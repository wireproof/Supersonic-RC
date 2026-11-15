-- Behavior
on getScoreSpriteInfo tFrame, tName
  if voidp(gCachedScoreSpriteInfo) then
    gCachedScoreSpriteInfo = getCachedScoreData()
  end if
  case ilk(tFrame) of
    #string:
      tFrame = marker(tFrame)
    #integer:
      nothing()
    #list:
      return getScoreSpriteInfo(tFrame[1], tName)
    otherwise:
      alert("incorrect getscorespriteinfo call")

  end case
  return gCachedScoreSpriteInfo.getProp(tFrame).getProp(tName)
end
on buildCachedScoreData
  gCachedScoreSpriteInfo = VOID
  showAll()
  go(1)
  tLastFrame = 0
  i = 0
  tData = [:]
  repeat while marker(i) <> tLastFrame
    tFrame = marker(i)
    tLastFrame = tFrame
    go(tFrame)
    tFrameData = [:]
    tData.addProp(tFrame, tFrameData)
    repeat with tSN = 1 to 100
      t = sprite(tSN).scriptList
      if t.count > 0 then
        if t[1][1] = member("nameASprite") then
          tSpriteData = [:]
          tSprite = sprite(tSN)
          tSpriteData[#blend] = tSprite.blend
          tSpriteData[#loc] = tSprite.loc
          tSpriteData[#flipH] = tSprite.flipH
          tSpriteData[#flipV] = tSprite.flipV
          tSpriteData[#locZ] = tSprite.locZ
          tSpriteData[#ink] = tSprite.ink
          tSpriteData[#rotation] = tSprite.rotation
          tSpriteData[#skew] = tSprite.skew
          tSpriteData[#width] = tSprite.width
          tSpriteData[#height] = tSprite.height
          tSpriteData[#visible] = 1
          tSpriteData[#member] = tSprite.member
          tSpriteData[#foreColor] = tSprite.foreColor
          tSpriteData[#bgColor] = tSprite.bgColor
          tSpriteData[#editable] = tSprite.editable
          tFrameData.addProp(value(t[1][2])[#pName], tSpriteData)
        end if
      end if
    end repeat
    i = i + 1
    go(1)
  end repeat
  tScriptText = "on getCachedScoreData()" & RETURN & "  return " & string(tData) & RETURN & "end" & RETURN
  member("cachedscoredata").scriptText = tScriptText
end