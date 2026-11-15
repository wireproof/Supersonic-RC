-- Script
property ancestor
property pFieldSprite
property pFieldMember
property pCaptionMember
property pCaptionSprite
property pBorderSprite
property pBorderMember
property pLoc
property pEditable
property pValueChangeCallback
property pEditing
property pValueBeforeEdit
property pValidType

on new me, tParams
  if voidp(tParams) then
    tParams = propList()
  end if
  pFieldMember = getDynamicCopy(member("valueDisplayTemplate"))
  if voidp(tParams[#width]) = 0 then
    tRect = pFieldMember.rect
    tRect[3] = tParams[#width]
    pFieldMember.rect = tRect
  end if
  if voidp(tParams[#alignment]) = 0 then
    pFieldMember.alignment = tParams[#alignment]
  end if
  if voidp(tParams[#font]) = 0 then
    pFieldMember.font = tParams[#font]
  end if
  if voidp(tParams[#fontSize]) = 0 then
    pFieldMember.fontSize = tParams[#fontSize]
  end if
  pValidType = tParams[#validType]
  tLoc = point(0, 0)
  if voidp(tParams[#name]) = 0 then
    tLayout = script("sprite").new(tParams)
    tLayout.setVisible(0)
    tLoc = point(tLayout.getLeft(), tLayout.getTop())
  end if
  pValueChangeCallback = tParams[#valueChangeCallback]
  ancestor = script("sprite").rawNew()
  tParams[#name] = VOID
  callAncestor(#new, me, tParams)
  me.setMember(pFieldMember)
  me.setEditable(0)
  pFieldSprite = ancestor
  pBorderSprite = script("sprite").new(tParams)
  pBorderSprite.setInk(36)
  pBorderSprite.setVisible(1)
  pBorderSprite.setLocz(me.getLocz() + 1)
  pBorderSprite.setNeedEvents(0)
  me.makeBorderMember()
  if voidp(tParams[#Caption]) = 0 then
    pCaptionMember = getDynamicCopy(member("valueDisplayCaption"))
    pCaptionMember.text = tParams[#Caption]
    pCaptionSprite = script("sprite").new(tParams)
    pCaptionSprite.setInk(36)
    pCaptionSprite.setMember(pCaptionMember)
    pCaptionSprite.setVisible(1)
    pCaptionSprite.setLocz(me.getLocz())
    if voidp(tParams[#captionalignment]) = 0 then
      pCaptionMember.alignment = tParams[#captionalignment]
    end if
    if voidp(tParams[#captionwidth]) = 0 then
      tY = pCaptionMember.height
      tX = tParams[#captionwidth]
      pCaptionMember.rect = rect(0, 0, tX, tY)
    end if
  end if
  case pValidType of
    #string:
      me.setValue(EMPTY)
    otherwise:
      me.setValue(0)

  end case
  pEditable = 1
  me.setEditable(pEditable)
  me.setLoc(tLoc)
  return me
end
on setFontColor me, tColor
  pFieldMember.color = tColor
end
on setAlignment me, tAlignment
  pFieldMember.alignment = string(tAlignment)
end
on SetWidth me, tWidth
end
on makeBorderMember me
  timage = image(pFieldMember.width + 3, pFieldMember.height + 2, 32)
  timage.draw(0, 0, timage.width - 1, timage.height - 1, [#shapeType: #rect, #color: rgb(0, 0, 0)])
  if ilk(pBorderMember) <> #member then
    pBorderMember = getDynamicSlot()
    new(#bitmap, pBorderMember)
  end if
  pBorderMember.image = timage
  pBorderMember.regPoint = point(0, 0)
  pBorderSprite.setMember(pBorderMember)
  pBorderSprite.correctRectToMember()
end
on setEditable me, tEditable
  pEditable = tEditable
  case pEditable of
    0:
      callAncestor(#setNeedEvents, me, 0)
      pFieldMember.bgColor = rgb(150, 150, 150)
      pFieldMember.editable = 0
    1:
      callAncestor(#setNeedEvents, me, 1)
      pFieldMember.bgColor = rgb(255, 255, 255)
      pFieldMember.editable = 1

  end case
end
on hideborder me
  pBorderSprite.setBlend(0)
end
on showBorder me
  pBorderSprite.setBlend(100)
end
on getFieldSprite me
  return pFieldSprite
end
on setLoc me, tLoc
  pLoc = tLoc
  callAncestor(#setLoc, me, tLoc + point(1, 1))
  pBorderSprite.setLoc(tLoc)
  if voidp(pCaptionSprite) = 0 then
    pCaptionSprite.setLoc(tLoc - point(pCaptionMember.width + 2, 0))
  end if
end
on setLocH me, tLocH
  pLoc[1] = tLocH
  me.setLoc(pLoc)
end
on setLocV me, tLocV
  pLoc[2] = tLocV
  me.setLoc(pLoc)
end
on setValue me, tvalue, tParam
  if pEditing = 1 then
    me.stopEditing(#ignoreupdate)
  end if
  if pEditing = 0 then
    pFieldMember.text = string(tvalue)
  else
    pValueBeforeEdit = tvalue
  end if
end
on aboutToGo1 me, tFrame
  callAncestor(#aboutToGo1, me, tFrame)
  pBorderSprite.aboutToGo1(tFrame)
  if voidp(pCaptionSprite) = 0 then
    pCaptionSprite.aboutToGo1(tFrame)
  end if
end
on aboutToGo2 me, tFrame
  callAncestor(#aboutToGo2, me, tFrame)
  pBorderSprite.aboutToGo2(tFrame)
  if voidp(pCaptionSprite) = 0 then
    pCaptionSprite.aboutToGo2(tFrame)
  end if
end
on getRight me
  return pBorderSprite.getRight() - 1
end
on getTop me
  return pBorderSprite.getTop()
end
on GetValue me
  t = value(pFieldMember.text)
  if voidp(t) then
    t = pFieldMember.text
  end if
  return t
end
on mouseDown me
  callAncestor(#mouseDown, [me])
  if pEditable then
    me.StartEditing()
  end if
end
on StartEditing me
  the keyboardFocusSprite = me.pScoreSprite.spriteNum
  pEditing = 1
  pValueBeforeEdit = value(pFieldMember.text)
end
on keyDown me
  callAncestor(#keyDown, [me])
  if the key = numToChar(13) or the key = numToChar(3) then
    me.stopEditing()
  end if
  case pValidType of
    #integer:
      tKeys = "-0123456789"
    #float:
      tKeys = "-0123456789."
    otherwise:
      tKeys = "abcdefghijklmnopqrstuvwxyz~!@#$%^&*()_+|`1234567890-=\{}[]:;',./<>?" & QUOTE

  end case
  tKeys = tKeys && BACKSPACE & numToChar(28) & numToChar(29) & numToChar(127) & TAB
  if tKeys contains the key then
    pass()
  end if
  abort()
end
on setLocz me, tLocZ
  callAncestor(#setLocz, me, tLocZ)
  pBorderSprite.setLocz(tLocZ + 0.1)
  if objectp(pCaptionSprite) then
    pCaptionSprite.setLocz(tLocZ)
  end if
end
on setRange me, tRange
  callAncestor(#setRange, me, tRange)
  pBorderSprite.setRange(tRange)
  if objectp(pCaptionSprite) then
    pCaptionSprite.setRange(tRange)
  end if
end
on stopEditing me, tParam
  if me.pScoreSprite <> 0 then
    if the keyboardFocusSprite = me.pScoreSprite.spriteNum then
      the keyboardFocusSprite = 0
    end if
  end if
  tvalue = value(pFieldMember.text)
  pEditing = 0
  if paramPresent(tParam, #ignoreupdate) then
    exit
  end if
  case pValidType of
    #integer, #float:
      if ilk(tvalue) = #integer or ilk(tvalue) = #float then
        me.setValue(tvalue)
        call(#valueHasChanged, [me], tvalue)
      else
        pFieldMember.text = string(pValueBeforeEdit)
      end if
    #string:
      me.setValue(pFieldMember.text)

  end case
  doCallback(pValueChangeCallback, tvalue)
end
on setValueChangeCallback me, tCallback
  pValueChangeCallback = tCallback
end
on setVisible me, tVisible, tSpecial
  callAncestor(#setVisible, me, tVisible, tSpecial)
  pBorderSprite.setVisible(tVisible, tSpecial)
  if objectp(pCaptionSprite) then
    pCaptionSprite.setVisible(tVisible, tSpecial)
  end if
end
on setStageOrientation me, tOrientation
  callAncestor(#setStageOrientation, me, tOrientation)
  pBorderSprite.setStageOrientation(tOrientation)
  if objectp(pCaptionSprite) then
    pCaptionSprite.setStageOrientation(tOrientation)
  end if
end
on exitFrame me
  callAncestor(#exitFrame, [me])
  if pEditing then
    if the keyboardFocusSprite <> me.pScoreSprite.spriteNum then
      me.stopEditing()
    end if
  else
    if the keyboardFocusSprite = me.pScoreSprite.spriteNum then
      me.StartEditing()
    end if
  end if
end
on destroy me
  callAncestor(#destroy, me)
  ancestor = 0
  pBorderSprite = pBorderSprite.destroy()
  if objectp(pCaptionSprite) then
    pCaptionSprite.destroy()
  end if
  pFieldMember.erase()
  pBorderMember.erase()
  if voidp(pCaptionMember) = 0 then
    pCaptionMember.erase()
  end if
  return 0
end