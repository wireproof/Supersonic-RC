-- Behavior
on generateButtonMembers tParams, t
  if ilk(tParams) = #script then
    tParams = t
  end if
  tImages = [:]
  tXBorder = 3
  tYBorder = 3
  tTextGenerator = member("3dpi_textButtonTextGenerator")
  tWidth = tParams[#text].char.count * 10
  if voidp(tParams[#width]) = 0 then
    tWidth = tParams[#width]
    tMaxWidth = tWidth
  else
    tMaxWidth = 100
  end if
  tTextGenerator.width = min(tWidth, tMaxWidth)
  tTextGenerator.text = tParams[#text]
  tImageRect = rect(0, 0, tTextGenerator.width + tXBorder * 2, tTextGenerator.height - 2 + tYBorder * 2)
  tMembers = [:]
  timage = generateEmptyButton(#normal, tImageRect.width, tImageRect.height)
  timage.copyPixels(tTextGenerator.image, rect(tXBorder, tYBorder - 1, tXBorder, tYBorder - 1) + tTextGenerator.rect, tTextGenerator.rect)
  tMembers[#normal] = getDynamicSlot()
  new(#bitmap, tMembers[#normal])
  tMembers[#normal].image = timage
  tMembers[#rollover] = tMembers[#normal]
  timage = generateEmptyButton(#pressed, tImageRect.width, tImageRect.height)
  timage.copyPixels(tTextGenerator.image, rect(tXBorder, tYBorder - 1, tXBorder, tYBorder - 1) + tTextGenerator.rect, tTextGenerator.rect)
  tMembers[#pressed] = getDynamicSlot()
  new(#bitmap, tMembers[#pressed])
  tMembers[#pressed].image = timage
  timage = generateEmptyButton(#disabled, tImageRect.width, tImageRect.height)
  timage.copyPixels(tTextGenerator.image, rect(tXBorder, tYBorder - 1, tXBorder, tYBorder - 1) + tTextGenerator.rect, tTextGenerator.rect)
  tMembers[#disabled] = getDynamicSlot()
  new(#bitmap, tMembers[#disabled])
  tMembers[#disabled].image = timage
  repeat with tmember in tMembers
    tmember.regPoint = point(0, 0)
  end repeat
  return tMembers
end
on generateEmptyButton tstate, tWidth, tHeight
  case tstate of
    #normal:
      return generateEmptyButtonNormal(tWidth, tHeight)
    #rollover:
      return generateEmptyButtonNormal(tWidth, tHeight)
    #pressed:
      return generateEmptyButtonPressed(tWidth, tHeight)
    #disabled:
      return generateEmptyButtonDisabled(tWidth, tHeight)

  end case
end
on generateEmptyButtonNormal tWidth, tHeight
  timage = image(tWidth, tHeight, 32)
  timage.fill(0, 0, timage.width - 1, timage.height, rgb(207, 207, 207))
  timage.draw(0, 0, timage.width - 1, 0, rgb(107, 107, 107))
  timage.draw(0, 0, 0, timage.height, rgb(107, 107, 107))
  timage.draw(0, timage.height - 1, timage.width - 1, timage.height - 1, rgb(45, 45, 45))
  timage.draw(timage.width - 1, 0, timage.width - 1, timage.height, rgb(45, 45, 45))
  timage.draw(2, timage.height - 2, timage.width - 2, timage.height - 2, rgb(115, 115, 115))
  timage.draw(timage.width - 2, 2, timage.width - 2, timage.height - 1, rgb(115, 115, 115))
  timage.draw(3, timage.height - 3, timage.width - 3, timage.height - 3, rgb(157, 157, 157))
  timage.draw(timage.width - 3, 3, timage.width - 3, timage.height - 2, rgb(157, 157, 157))
  timage.draw(2, 2, timage.width - 3, 2, rgb(255, 255, 255))
  timage.draw(2, 2, 2, timage.height - 3, rgb(255, 255, 255))
  return timage
end
on generateEmptyButtonPressed tWidth, tHeight
  timage = image(tWidth, tHeight, 32)
  timage.fill(0, 0, timage.width - 1, timage.height, rgb(149, 149, 149))
  timage.draw(0, 0, timage.width - 1, 0, rgb(0, 0, 0))
  timage.draw(0, 0, 0, timage.height, rgb(0, 0, 0))
  timage.draw(0, timage.height - 1, timage.width - 1, timage.height - 1, rgb(45, 45, 45))
  timage.draw(timage.width - 1, 0, timage.width - 1, timage.height, rgb(45, 45, 45))
  timage.draw(2, timage.height - 2, timage.width - 2, timage.height - 2, rgb(36, 36, 36))
  timage.draw(timage.width - 2, 2, timage.width - 2, timage.height - 1, rgb(36, 36, 36))
  timage.draw(1, 1, timage.width - 2, 1, rgb(81, 81, 81))
  timage.draw(1, 1, 1, timage.height - 2, rgb(81, 81, 81))
  return timage
end
on generateEmptyButtonDisabled tWidth, tHeight
  timage = image(tWidth, tHeight, 32)
  timage.fill(0, 0, timage.width - 1, timage.height, rgb(231, 231, 231))
  timage.draw(0, 0, timage.width, timage.height, [#shapeType: #rect, #color: rgb(173, 173, 173)])
  return timage
end