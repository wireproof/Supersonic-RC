-- Score Script
property pName

on findSpriteByName me, tName, tReply
  if tName = pName then
    tReply.append(sprite(me.spriteNum))
  end if
end
on getPropertyDescriptionList
  t = [:]
  t.addProp(#pName, [#comment: "Name of sprite", #default: EMPTY, #format: #string])
  return t
end