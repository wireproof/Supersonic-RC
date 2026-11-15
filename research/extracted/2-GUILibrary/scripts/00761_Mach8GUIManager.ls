-- Script
property pFreeScoreSprites
property pSpriteObjects
property pOutstandingScoreSpritesReferencedByName
property pInterfaceDisableExceptions
property pSpriteBeingDragged
property pMouseManager
property pStageRect
global gMach8GUIManager

on destroy me
  pSpriteObjects = 0
  pFreeScoreSprites = 0
  pOutstandingScoreSpritesReferencedByName = 0
  pObjectBeingDragged = 0
  pMouseManager = pMouseManager.destroy()
  (the actorList).deleteOne(me)
  return 0
end
on new me
  gMach8GUIManager = me
  pSpriteObjects = []
  pFreeScoreSprites = []
  repeat with i = 60 to 280
    sprite(i).puppet = 0
    pFreeScoreSprites.append(sprite(i))
  end repeat
  pOutstandingScoreSpritesReferencedByName = []
  pInterfaceDisableExceptions = #all
  pObjectBeingDragged = VOID
  pMouseManager = script("Mach8MouseManager").new()
  pStageRect = rect(0, 0, (the stage).rect.width, (the stage).rect.height)
  (the actorList).append(me)
  return me
end
on getMouseManager me
  return pMouseManager
end
on getObjectBeingDragged me
  return pSpriteBeingDragged.getRepresentingObject()
end
on StartDrag me, tSpriteBeingDragged
  pSpriteBeingDragged = tSpriteBeingDragged
end
on dragSucceeded me
  if objectp(pSpriteBeingDragged) then
    pSpriteBeingDragged.dragSucceeded()
  end if
  pSpriteBeingDragged = VOID
end
on getSpriteBeingDragged me
  return pSpriteBeingDragged
end
on dragEnded me
  pSpriteBeingDragged = VOID
end
on getDragInProgress me
  return not voidp(pSpriteBeingDragged)
end
on getGloballyDisabled me, tObject
  if pInterfaceDisableExceptions = #all then
    return 0
  end if
  if pInterfaceDisableExceptions.getOne(tObject) <> 0 then
    return 0
  end if
  return 1
end
on disableInterfaceExcept me, tInput
  case ilk(tInput) of
    #instance:
      pInterfaceDisableExceptions = [tInput]
    #list:
      pInterfaceDisableExceptions = tInput
    #void:
      pInterfaceDisableExceptions = []

  end case
end
on enableInterface
  pInterfaceDisableExceptions = #all
end
on spriteObjectReporting me, tSpriteObjectReporting
  pSpriteObjects.append(tSpriteObjectReporting)
end
on spriteObjectDied me, tSpriteObject
  pSpriteObjects.deleteOne(tSpriteObject)
end
on getScoreSprite me, tSpriteObject, tName
  tFreeScoreSprite = pFreeScoreSprites[1]
  pFreeScoreSprites.deleteAt(1)
  tFreeScoreSprite.scriptInstanceList = []
  tFreeScoreSprite.puppet = 1
  return tFreeScoreSprite
end
on returnScoreSprite me, tScoreSprite
  if pOutstandingScoreSpritesReferencedByName.deleteOne(tScoreSprite) = 0 then
    if pFreeScoreSprites.getOne(tScoreSprite) <> 0 then
      put "DUPLICATE SPRITE RETURNED!!"
      exit
    end if
    pFreeScoreSprites.addAt(1, tScoreSprite)
    sort(pFreeScoreSprites)
  end if
  tScoreSprite.puppet = 0
  tScoreSprite.loc = point(-1000, 0)
  tScoreSprite.scriptInstanceList.deleteAll()
end
on stepFrame me
  pMouseManager.stepFrame()
  if (the stage).rect.width <> pStageRect.width or (the stage).rect.height <> pStageRect.height then
    pStageRect[3] = (the stage).rect.width
    pStageRect[4] = (the stage).rect.height
    call(#stageRectChanged, pSpriteObjects, pStageRect)
  end if
end
on aboutToGo1 me, tFrame
  repeat with i in pSpriteObjects.duplicate()
    i.aboutToGo1(tFrame)
  end repeat
end
on aboutToGo2 me, tFrame
  repeat with i in pSpriteObjects.duplicate()
    i.aboutToGo2(tFrame)
  end repeat
end
on getActiveSprites me
  t = []
  repeat with tSprite in pSpriteObjects
    if tSprite.pScoreSprite <> 0 then
      t.append(tSprite)
    end if
  end repeat
  return t
end
on getSpriteObjects me
  return pSpriteObjects
end
on findSpriteByScoreSprite me, tSN
  repeat with i in pSpriteObjects
    if i.pScoreSprite = sprite(tSN) then
      return i
    end if
  end repeat
end