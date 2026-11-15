-- Script
property ancestor
property pTop
property pBase
property pBottom
property pSlider
property pLoc
property pOrientation

on new me, tSlider, tParams
  tRange = tParams[#range]
  if tParams[#name] <> VOID then
    tTopName = tParams[#name] & "_top"
    tBaseName = tParams[#name] & "_base"
    tBottomName = tParams[#name] & "_bottom"
    tUsingLayoutSprite = 0
  else
    tUsingLayoutSprite = 1
  end if
  ancestor = script("sprite").rawNew()
  callAncestor(#new, me, [#name: tTopName, #range: tRange])
  me.setNeedEvents(1)
  pTop = ancestor
  ancestor = script("sprite").rawNew()
  callAncestor(#new, me, [#name: tBaseName, #range: tRange])
  me.setNeedEvents(1)
  pBase = ancestor
  ancestor = script("sprite").rawNew()
  callAncestor(#new, me, [#name: tBottomName, #range: tRange])
  me.setNeedEvents(1)
  pBottom = ancestor
  ancestor = pBase
  me.setStageOrientation([#middle, #middle])
  pOrientation = tParams[#orientation]
  if tUsingLayoutSprite then
    case pOrientation of
      #horizontal:
        tExtention = "hor"
      #vertical:
        tExtention = "vert"

    end case
    pTop.setMember(member(tParams[#gfxSet] & "_slider_top_" & tExtention))
    pBase.setMember(member(tParams[#gfxSet] & "_slider_base_" & tExtention))
    pBottom.setMember(member(tParams[#gfxSet] & "_slider_bottom_" & tExtention))
  end if
  pSlider = tSlider
  gTest = me
  return me
end
on setStageOrientation me, tOrientation
  pTop.setStageOrientation(tOrientation)
  pBase.setStageOrientation(tOrientation)
  pBottom.setStageOrientation(tOrientation)
end
on stageRectChanged me, t1, t2, t3
  call(#stageRectChanged, [pTop, pBase, pBottom], t1, t2, t3)
end
on destroy me
  pTop = pTop.destroy()
  pBottom = pBottom.destroy()
  pBase = pBase.destroy()
  pSlider = 0
  return 0
end
on mouseDown me
  pSlider.mouseDown()
end
on mouseUp me
  pSlider.mouseUp()
end
on mouseUpOutSide me
  pSlider.mouseUp()
end
on exitFrame me
end
on setVisible me, tVisible
  pTop.setVisible(tVisible)
  pBase.setVisible(tVisible)
  pBottom.setVisible(tVisible)
end
on setSize me, tSize
  case pOrientation of
    #horizontal:
      pBase.SetWidth(tSize - pTop.getWidth() - pBottom.getWidth())
    #vertical:
      pBase.SetHeight(tSize - pTop.getHeight() - pBottom.getHeight())

  end case
  me.position()
end
on setLoc me, tLoc
  pLoc = tLoc
  me.position()
end
on setLocH me, tLocH
  call(#setLocH, [pTop, pBase, pBottom], tLocH)
end
on setLocV me, tLocV
  call(#setLocV, [pTop, pBase, pBottom], tLocV)
end
on setLocz me, tLocZ
  call(#setLocz, [pTop, pBase, pBottom], tLocZ)
end
on setInk me, tInk
  call(#setInk, [pTop, pBase, pBottom], tInk)
end
on position me
  case pOrientation of
    #horizontal:
      pTop.setLocH(pLoc)
      pBase.setLocH(pLoc + pTop.getWidth())
      pBottom.setLocH(pLoc + pTop.getWidth() + pBase.getWidth())
    #vertical:
      pTop.setLocV(pLoc)
      pBase.setLocV(pLoc + pTop.getHeight())
      pBottom.setLocV(pLoc + pTop.getHeight() + pBase.getHeight())

  end case
end
on getMinimumSize
  case pOrientation of
    #horizontal:
      tMax = pTop.getWidth() + pBottom.getWidth()
    #vertical:
      tMax = pTop.getHeight() + pBottom.getHeight()

  end case
  return max(tMax, 6)
end
on aboutToGo1 me, tFrame
  ancestor = pTop
  callAncestor(#aboutToGo1, me, tFrame)
  ancestor = pBase
  callAncestor(#aboutToGo1, me, tFrame)
  ancestor = pBottom
  callAncestor(#aboutToGo1, me, tFrame)
  ancestor = pBase
end
on aboutToGo2 me, tFrame
  ancestor = pTop
  callAncestor(#aboutToGo2, me, tFrame)
  ancestor = pBase
  callAncestor(#aboutToGo2, me, tFrame)
  ancestor = pBottom
  callAncestor(#aboutToGo2, me, tFrame)
  ancestor = pBase
end