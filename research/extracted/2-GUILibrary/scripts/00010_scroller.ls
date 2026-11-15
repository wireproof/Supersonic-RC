-- Script
property pUpButton
property pDownButton
property pSlider
property pSliderBackground
property pContentInterface
property pScrollOffset
property pTotalItems
property pItemsPerPage

on new me, tContentInterface, tParams
  pContentInterface = tContentInterface
  pScrollOffset = 0
  pItemsPerPage = tParams[#itemsPerPage]
  if tParams[#layoutSprite] <> VOID then
    tLayOutParams = [#name: tParams[#layoutSprite], #range: tParams[#range]]
    tLayout = script("sprite").new(tLayOutParams)
    tLayout.setVisible(0)
    tLayout.setStageOrientation([#middle, #middle])
    if tLayout.getWidth() > tLayout.getHeight() then
      pOrientation = #horizontal
      tUpButtonMember = member(tParams[#gfxSet] & "_scrollbutton_left")
      tDownButtonMember = member(tParams[#gfxSet] & "_scrollbutton_right")
    else
      pOrientation = #vertical
      tUpButtonMember = member(tParams[#gfxSet] & "_scrollbutton_up")
      tDownButtonMember = member(tParams[#gfxSet] & "_scrollbutton_down")
    end if
    tMembers = [:]
    tMembers[#normal] = tUpButtonMember
    pUpButton = script("pulsingbutton").new([#members: tMembers, #range: tParams[#range], #actionCallback: script("callback").new(#upButtonClicked, me)])
    pUpButton.setLocH(tLayout.getLeft() + tMembers[#normal].regPoint[1])
    pUpButton.setLocV(tLayout.getTop() + tMembers[#normal].regPoint[2])
    pUpButton.setLocz(tLayout.getLocz())
    tMembers = [:]
    tMembers[#normal] = tDownButtonMember
    pDownButton = script("pulsingbutton").new([#members: tMembers, #range: tParams[#range], #actionCallback: script("callback").new(#downButtonClicked, me)])
    case pOrientation of
      #horizontal:
        pDownButton.setLocH(tLayout.getRight() + tMembers[#normal].regPoint[1] - tMembers[#normal].width)
        pDownButton.setLocV(tLayout.getTop() + tMembers[#normal].regPoint[2])
      #vertical:
        pDownButton.setLocH(tLayout.getLeft() + tMembers[#normal].regPoint[1])
        pDownButton.setLocV(tLayout.getBottom() + tMembers[#normal].regPoint[2] - tMembers[#normal].height)

    end case
    pDownButton.setLocz(tLayout.getLocz())
    pSlider = script("slider").new(me, pUpButton, pDownButton, tParams)
    tParams[#upButton] = pUpButton
    tParams[#layout] = tLayout
    pSliderBackground = script("sliderbackground").new(me, pSlider, tParams)
    pSliderBackground.setLocz(tLayout.getLocz() - 1)
  else
    tName = tParams[#name]
    tRange = tParams[#range]
    pUpButton = script("pulsingbutton").new([#name: tName & "_up", #range: tRange, #actionCallback: script("callback").new(#upButtonClicked, me)])
    pDownButton = script("pulsingbutton").new([#name: tName & "_down", #range: tRange, #actionCallback: script("callback").new(#downButtonClicked, me)])
    pSlider = script("slider").new(me, pUpButton, pDownButton, tName, tRange, pItemsPerPage)
    pSliderBackground = script("sliderbackground").new(me, pSlider, tName, tRange)
  end if
  pSliderBackground.setBlend(0)
  me.updateButtonStates()
  return me
end
on setLocz me, tLocZ
  pUpButton.setLocz(tLocZ)
  pDownButton.setLocz(tLocZ)
  pSlider.setLocz(tLocZ)
  pSliderBackground.setLocz(tLocZ - 1)
end
on setStageOrientation me, tOrientation
  call(#setStageOrientation, [pUpButton, pDownButton, pSliderBackground], tOrientation)
end
on newTotalItems me, tTotalItems
  pTotalItems = tTotalItems
  pScrollOffset = min(pScrollOffset, max(0, pTotalItems - pItemsPerPage))
  me.updateButtonStates()
  if pTotalItems <= pItemsPerPage then
    me.setVisible(1)
  else
    me.setVisible(1)
  end if
end
on setItemsPerPage me, tItemsPerPage
  pItemsPerPage = tItemsPerPage
  me.ScrollTo(pScrollOffset)
  if pTotalItems <= pItemsPerPage then
    me.setVisible(1)
  else
    me.setVisible(1)
  end if
end
on ScrollTo me, tScrollOffset
  pScrollOffset = tScrollOffset
  pScrollOffset = min(pScrollOffset, max(0, pTotalItems - pItemsPerPage))
  me.updateButtonStates()
end
on upButtonClicked me
  assert(pScrollOffset > 0, "got upButtonClicked while being at the top")
  pScrollOffset = pScrollOffset - 1
  pContentInterface.ScrollTo(pScrollOffset)
  me.updateButtonStates()
end
on downButtonClicked me
  assert(pScrollOffset < pTotalItems - pItemsPerPage, "got downButtonClicked while being at the bottom")
  pScrollOffset = pScrollOffset + 1
  pContentInterface.ScrollTo(pScrollOffset)
  me.updateButtonStates()
end
on sliderBackGroundClicked me, tDirection
  case tDirection of
    #up:
      pScrollOffset = max(0, pScrollOffset - pItemsPerPage)
    #down:
      pScrollOffset = min(pTotalItems - pItemsPerPage, pScrollOffset + pItemsPerPage)

  end case
  pContentInterface.ScrollTo(pScrollOffset)
  me.updateButtonStates()
end
on sliderMoving me, tPercentage
  pScrollOffset = figureOutScrollOffsetForPercentage(tPercentage)
  pContentInterface.ScrollTo(pScrollOffset)
  me.updateButtonStates(#dontupdateslider)
end
on sliderStoppedMoving me
  pSlider.update(pScrollOffset, pTotalItems)
end
on updateButtonStates me, tParam
  tEnableBackGround = 0
  if pScrollOffset = 0 then
    pUpButton.Disable()
  else
    pUpButton.enable()
    tEnableBackGround = 1
  end if
  if pScrollOffset < pTotalItems - pItemsPerPage then
    pDownButton.enable()
    tEnableBackGround = 1
  else
    pDownButton.Disable()
  end if
  if paramPresent(tParam, #dontupdateslider) = 0 then
    pSlider.update(pScrollOffset, pTotalItems)
  end if
  if tEnableBackGround = 0 then
    pSliderBackground.Disable()
  else
    pSliderBackground.enable()
  end if
  pUpButton.setVisible(0, #hibernate)
  pDownButton.setVisible(0, #hibernate)
end
on figureOutScrollOffsetForPercentage tPercentage
  tOffset = (pTotalItems - pItemsPerPage) * tPercentage
  return integer(tOffset)
end
on getScrollOffset me
  return pScrollOffset
end
on getItemsPerPage me
  return pItemsPerPage
end
on setVisible me, tVisible
  pSlider.setVisible(tVisible)
  pUpButton.setVisible(0)
  pDownButton.setVisible(0)
  pSliderBackground.setVisible(tVisible)
end
on destroy me
  pSlider = pSlider.destroy()
  pSliderBackground = pSliderBackground.destroy()
  pUpButton = pUpButton.destroy()
  pDownButton = pDownButton.destroy()
  pContentInterface = 0
  return 0
end