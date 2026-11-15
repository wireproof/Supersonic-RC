-- Script
property ancestor
property pScroller
property pSlider
property pLastDir

on new me, tScroller, tSlider, tParams
  ancestor = script("pulsingbutton").rawNew()
  tParams = tParams.duplicate()
  if voidp(tParams[#name]) = 0 then
    tParams[#name] = tParams[#name] & "_background"
    tUsingLayout = 0
  else
    case tParams[#orientation] of
      #horizontal:
        tExtention = "hor"
      #vertical:
        tExtention = "vert"

    end case
    tParams[#members] = [#normal: member(tParams[#gfxSet] & "_slider_background_" & tExtention)]
    tUsingLayout = 1
  end if
  callAncestor(#new, me, tParams)
  if tUsingLayout then
    case tParams[#orientation] of
      #horizontal:
        me.SetWidth(tParams[#layout].getWidth())
        me.SetHeight(tParams[#upButton].getHeight())
      #vertical:
        me.SetWidth(tParams[#upButton].getWidth())
        me.SetHeight(tParams[#layout].getHeight())

    end case
  end if
  me.setLoc(point(tParams[#layout].getLeft(), tParams[#layout].getTop()))
  pScroller = tScroller
  pSlider = tSlider
  return me
end
on Action me
  case pSlider.getOrientation() of
    #horizontal:
      tLoc = the mouseH
    #vertical:
      tLoc = the mouseV

  end case
  if tLoc > pSlider.getLoc() then
    tDir = #down
  end if
  if tLoc < pSlider.getLoc() then
    tDir = #up
  end if
  if tLoc = pSlider.getLoc() then
    tDir = pLastDir
  end if
  if pLastDir <> tDir and pLastDir <> VOID then
    me.pPulsesSent = 1
    exit
  end if
  pLastDir = tDir
  pScroller.sliderBackGroundClicked(tDir)
end
on mouseUp me
  pLastDir = VOID
  callAncestor(#mouseUp, me)
end
on mouseUpOutSide me
  pLastDir = VOID
  callAncestor(#mouseUpOutSide, me)
end
on correctRectToMember
end
on destroy me
  callAncestor(#destroy, me)
  ancestor = 0
  pSlider = 0
  pScroller = 0
  return 0
end