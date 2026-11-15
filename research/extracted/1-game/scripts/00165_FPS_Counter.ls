-- Script
property pTimes
property pLastMS
property pSampleSize
property pTotal
property pLastUpdate

on beginSprite
  pTimes = []
  pLastMS = the milliSeconds
  pLastUpdate = the milliSeconds
  pSampleSize = 100
end
on exitFrame me
  tMS = the milliSeconds
  tThis = the milliSeconds - pLastMS
  pTimes.append(tThis)
  pTotal = pTotal + tThis
  if pTimes.count > pSampleSize then
    pTotal = pTotal - pTimes[1]
    pTimes.deleteAt(1)
  end if
  pLastMS = the milliSeconds
  if pLastUpdate < tMS - 2000 then
    me.updatemember()
    pLastUpdate = tMS
  end if
end
on updatemember me
  t = 0
  repeat with i in pTimes
    t = t + i
  end repeat
  sprite(me.spriteNum).member.text = 1000 * float(pSampleSize) / pTotal & " Fps"
end