-- Behavior
property pSpriteObject

on new me, tSpriteObject
  pSpriteObject = tSpriteObject
  return me
end
on mouseUp me
  call(#spriteMouseUp, [me.pSpriteObject])
  pass()
end
on exitFrame me
  call(#exitFrame, [me.pSpriteObject])
end
on prepareFrame me
  call(#prepareFrame, [me.pSpriteObject])
end
on mouseDown me
  call(#spriteMouseDown, [me.pSpriteObject])
  pass()
end
on mouseEnter me
  call(#spriteMouseEnter, [me.pSpriteObject])
end
on mouseLeave me
  call(#spriteMouseLeave, [me.pSpriteObject])
end
on mouseUpOutSide me
  call(#spriteMouseUpOutside, [me.pSpriteObject])
end
on mouseWithin me
  call(#spriteMouseWithin, [me.pSpriteObject])
end
on keyDown me
  call(#keyDown, [me.pSpriteObject])
  pass()
end
on keyUp me
  call(#keyUp, [me.pSpriteObject])
end
on hyperlinkClicked me, t1, t2, t3, t4
  call(#hyperlinkClicked, [me.pSpriteObject], t1, t2, t3, t4)
end