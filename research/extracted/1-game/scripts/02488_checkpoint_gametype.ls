-- Script
property ancestor
property pCheckPoints
property pCheckPointIndex
property p3d
property pArrow
property pHidden
global gMainManager

on new me
  ancestor = script("gameTypeManager").rawNew()
  callAncestor(#new, me)
  pHidden = 0
  p3d = member("3d")
  return me
end
on realStart me
  callAncestor(#realStart, me)
  i = 1
  member("star").preload()
  tStar = p3d.cloneModelFromCastmember("star", "star", member("star"))
  tStar.removeFromWorld()
  tStar.scale(3, 3, 3)
  pCheckPoints = list()
  repeat while 1 = 1
    tGroup = p3d.group("Checkpoint_" & i)
    if voidp(tGroup) then
      exit repeat
    end if
    tmodel = tStar.clone("checkpoint" & i)
    tmodel.worldPosition = tGroup.worldPosition - vector(0, 0, 50)
    tmodel.addToWorld()
    pCheckPoints.append(tmodel)
    i = i + 1
  end repeat
  pCheckPointIndex = 1
  pArrow = script("arrow").new()
  pArrow.pointAt(pCheckPoints[1].worldPosition)
end
on realStart2 me
  callAncestor(#realStart2, me)
  pArrow.spriteReady()
end
on havokUpdate me
  callAncestor(#havokUpdate, me)
  if me.pStopping or pHidden then
    exit
  end if
  if me.pCar.position.distanceTo(pCheckPoints[pCheckPointIndex].worldPosition) < 300 then
    sound(4).play([#member: member("stingcheckpoint")])
    me.passedCheckPoint()
    me.showThisCheckpoint(pCheckPointIndex)
  end if
  if pCheckPointIndex <= pCheckPoints.count then
    pCheckPoints[pCheckPointIndex].rotate(0, 0, 3)
  end if
end
on hideCheckpoints me
  repeat with tCheckPoint in pCheckPoints
    tCheckPoint.visibility = #none
  end repeat
  pHidden = 1
end
on showThisCheckpoint me, tIndex
  repeat with tCheckPoint in pCheckPoints
    tCheckPoint.removeFromWorld()
  end repeat
  pCheckPoints[tIndex].addToWorld()
end
on destroy me
  if objectp(pArrow) then
    pArrow = pArrow.destroy()
  end if
  callAncestor(#destroy, me)
  (the actorList).deleteOne(me)
end