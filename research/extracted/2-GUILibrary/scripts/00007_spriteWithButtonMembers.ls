-- Script
property ancestor
property pMembers
property pProceduralButtonData

on new me, tParams
  tSpriteAncestor = tParams[#spriteAncestor]
  if voidp(tSpriteAncestor) then
    tSpriteAncestor = "sprite"
  end if
  ancestor = script(tSpriteAncestor).rawNew()
  callAncestor(#new, me, tParams)
  pMembers = [:]
  me.assignButtonGfx(tParams)
  if voidp(tParams[#loc]) = 0 then
    me.setLoc(tParams[#loc])
  end if
  me.setForeColor(255)
  return me
end
on assignButtonGfx me, tParams
  pMembers = [:]
  if voidp(tParams[#text]) then
    if voidp(tParams[#members]) then
      if voidp(tParams[#member]) = 0 then
        pMembers[#normal] = tParams[#member]
      else
        pMembers[#normal] = me.pMember
      end if
    else
      pMembers = tParams[#members]
    end if
    if voidp(pMembers[#normal]) then
      exit
    end if
    if voidp(pMembers[#rollover]) then
      pMembers[#rollover] = member(pMembers[#normal].name & "Over", pMembers[#normal].castLibNum)
      if pMembers[#rollover] = member(-1, 1) then
        pMembers[#rollover] = pMembers[#normal]
      end if
    end if
    if voidp(pMembers[#pressed]) then
      pMembers[#pressed] = member(pMembers[#normal].name & "Down", pMembers[#normal].castLibNum)
      if pMembers[#pressed] = member(-1, 1) then
        pMembers[#pressed] = pMembers[#normal]
      end if
    end if
    if voidp(pMembers[#disabled]) then
      pMembers[#disabled] = member(pMembers[#normal].name & "Gray", pMembers[#normal].castLibNum)
      if pMembers[#disabled] = member(-1, 1) then
        pMembers[#disabled] = pMembers[#normal]
      end if
    end if
  else
    pMembers = call(#generateButtonMembers, script(tParams[#gfxSet] & "_Gfx_Generator"), tParams)
    pProceduralButtonData = tParams
  end if
  me.setMember(pMembers[#normal])
  me.correctRectToMember()
end
on setNewMembers me, tMembers
  pMembers = tMembers
end
on getProceduralButtonData me
  return pProceduralButtonData
end
on getProcedurallyGenerated me
  return voidp(pProceduralButtonData) = 0
end
on setProceduralButtonData me, tParams
  if voidp(tParams[#width]) = 0 then
    pProceduralButtonData[#width] = tParams[#width]
  end if
  if voidp(tParams[#text]) = 0 then
    pProceduralButtonData[#text] = tParams[#text]
  end if
  me.setNewMembers(call(#generateButtonMembers, script(pProceduralButtonData[#gfxSet] & "_Gfx_Generator"), pProceduralButtonData))
  me.correctRectToMember()
end
on destroy me
  ancestor = callAncestor(#destroy, me)
  return 0
end