-- Script
property ancestor
property pText
property pwidth

on new me, tParams
  tParams[#gfxSet] = "3DPI"
  ancestor = script("togglebutton").rawNew()
  callAncestor(#new, me, tParams)
  return me
end
on setText me, tText
  pText = tText
  repeat with tmember in me.pMembers
    tmember.erase()
  end repeat
  tMembers = script("3DPI_Gfx_Generator").generateButtonMembers([#text: pText, #width: pwidth])
  me.setNewMembers(tMembers)
end
on setButtonWidth me, tWidth
  pwidth = tWidth
  repeat with tmember in me.pMembers
    tmember.erase()
  end repeat
  tMembers = script("3DPI_Gfx_Generator").generateButtonMembers([#text: pText, #width: pwidth])
  me.setNewMembers(tMembers)
end
on select me
  callAncestor(#select, me)
end
on deselect me
  callAncestor(#deselect, me)
end
on destroy me
  repeat with tmember in me.pMembers
    tmember.erase()
  end repeat
  callAncestor(#destroy, me)
  ancestor = 0
end