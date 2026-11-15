-- Script
property pPlaying
property pRightLock
property pLeftLock
property pState
property pCar
property pWheels
property pShift
property pStopped
property pMusicLoops

on new me, tCar, tWheels
  pMusicLoops = []
  repeat with i = 1 to 5
    pMusicLoops.append(member("musicloop" & i))
  end repeat
  pCar = tCar
  pWheels = tWheels
  pLeftLock = 0
  pRightLock = 0
  pPlaying = 0
  pShift = 1
  pStopped = 0
  pState = #middle
  if debugModus() = 0 then
    sound(1).volume = 25
    sound(2).volume = 20
    sound(8).stop()
    sound(8).play([#member: pMusicLoops[random(pMusicLoops.count)]])
    sound(8).fadeTo(75, 500)
  end if
  return me
end
on update me
  if debugModus() = 0 then
    if sound(8).getPlaylist().count < 3 and pStopped = 0 then
      sound(8).queue([#member: pMusicLoops[random(pMusicLoops.count)]])
    end if
  end if
  if pStopped then
    t126 = 0
    t123 = 0
    t124 = 0
  else
    t126 = keyPressed(126) or keyPressed(125)
    t123 = keyPressed(123)
    t124 = keyPressed(124)
  end if
  if t126 and pPlaying = 0 then
    tStart = pCar.getRB().linearVelocity.length * 4 - 150
    sound(1).play([#member: member("CarStart"), #rateShift: pShift, #startTime: max(0, tStart)])
    sound(1).queue([#member: member("CarLoop"), #loopCount: 0, #rateShift: pShift])
    pPlaying = 1
  else
    if pPlaying = 1 and t126 = 0 then
      if sound(1).member = member("carstart") then
        sound(1).play([#member: member("carend"), #startTime: max(0, member("carend").duration - sound(1).currentTime / 2 - 10)])
      else
        sound(1).play([#member: member("CarEnd")])
      end if
      pPlaying = 0
    end if
  end if
  if t123 and pState <> #left then
    sound(2).play([#member: member("carturnleft0" & random(3))])
    pState = #left
  else
    if t124 and pState <> #right then
      sound(2).play([#member: member("carturnright0" & random(3))])
      pState = #right
    end if
  end if
  if t124 = 0 and t123 = 0 and pState <> #middle then
    if pState = #left then
      sound(2).play([#member: member("carturnright0" & random(3))])
    else
      sound(2).play([#member: member("carturnleft0" & random(3))])
    end if
    pState = #middle
  end if
  tShift = 2 - (pWheels[1].pOnGround + pWheels[2].pOnGround) * 0.5 + 0.1
  if pCar.pReversing then
    tShift = 0.2
  end if
  if pShift <> tShift and pPlaying then
    sound(1).play([#member: member("carloop"), #loopCount: 0, #rateShift: tShift])
  end if
  pShift = tShift
end
on stopDriving me
  pStopped = 1
  sound(8).fadeOut(500)
end
on destroy me
  sound(1).stop()
  sound(2).stop()
  pCar = 0
  pWheels = 0
  return 0
end