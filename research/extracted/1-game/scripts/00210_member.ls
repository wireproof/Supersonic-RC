-- Behavior
on mCloneShader memref, shadRef, NewName, exceptions
  if ilk(memref) <> #member then
    alert("Please provide a #shockwave3d member")
    return 0
  end if
  if memref.type <> #shockwave3d then
    alert("Please provide a #shockwave3d member")
    return 0
  end if
  if ilk(exceptions) <> #propList then
    exceptions = [:]
  end if
  if ilk(exceptions.getaProp(#type)) <> #symbol then
    exceptions[#type] = #standard
  end if
  if ilk(shadRef) <> #shader then
    if not stringp(NewName) then
      NewName = "shader1"
    end if
    if NewName.length = 0 then
      NewName = "shader1"
    end if
    NewName = mGetUniqueShaderName(memref, NewName)
    sClone = memref.newShader(NewName, exceptions.type)
    exceptions.deleteProp(#type)
    exCnt = exceptions.count
    repeat with n = 1 to exCnt
      sClone.setaProp(exceptions.getPropAt(n), exceptions[n])
    end repeat
    return sClone
  end if
  if ilk(NewName) <> #string then
    NewName = shadRef.name & "_Clone"
  end if
  if NewName.length = 0 then
    NewName = shadRef.name & "_Clone"
  end if
  dername = mGetUniqueShaderName(memref, NewName)
  dertyp = shadRef.type
  sClone = memref.newShader(dername, dertyp)
  case dertyp of
    #standard:
      val = exceptions.getaProp(#ambient)
      if ilk(val) <> #color then
        val = duplicate(shadRef.ambient)
      end if
      sClone.ambient = val
      val = exceptions.getaProp(#diffuse)
      if ilk(val) <> #color then
        val = duplicate(shadRef.diffuse)
      end if
      sClone.diffuse = val
      val = exceptions.getaProp(#useDiffuseWithTexture)
      if ilk(val) <> #integer then
        val = shadRef.useDiffuseWithTexture
      end if
      sClone.useDiffuseWithTexture = val
      val = exceptions.getaProp(#specular)
      if ilk(val) <> #color then
        val = duplicate(shadRef.specular)
      end if
      sClone.specular = val
      val = exceptions.getaProp(#emissive)
      if ilk(val) <> #color then
        val = duplicate(shadRef.emissive)
      end if
      sClone.emissive = val
      val = exceptions.getaProp(#shininess)
      if ([#integer, #float]).getPos(ilk(val)) = 0 then
        val = shadRef.shininess
      end if
      sClone.shininess = val
      val = exceptions.getaProp(#blend)
      if ([#integer, #float]).getPos(ilk(val)) = 0 then
        val = shadRef.blend
      end if
      sClone.blend = val
      val = exceptions.getaProp(#transparent)
      if ilk(val) <> #integer then
        val = shadRef.transparent
      end if
      sClone.transparent = val
      val = exceptions.getaProp(#renderStyle)
      if ilk(val) <> #symbol then
        val = shadRef.renderStyle
      end if
      sClone.renderStyle = val
      val = exceptions.getaProp(#flat)
      if ilk(val) <> #integer then
        val = shadRef.flat
      end if
      sClone.flat = val
      anz = shadRef.textureList.count
      repeat with m = 1 to anz
        if not voidp(shadRef.textureList[m]) then
          sClone.textureList[m] = shadRef.textureList[m]
          sClone.textureModeList[m] = shadRef.textureModeList[m]
          sClone.wrapTransformList[m] = duplicate(shadRef.wrapTransformList[m])
          sClone.textureTransformList[m] = duplicate(shadRef.textureTransformList[m])
          sClone.blendFunctionList[m] = shadRef.blendFunctionList[m]
          sClone.blendSourceList[m] = shadRef.blendSourceList[m]
          sClone.blendConstantList[m] = shadRef.blendConstantList[m]
          sClone.textureRepeatList[m] = shadRef.textureRepeatList[m]
        end if
      end repeat
    #painter:
      val = exceptions.getaProp(#diffuse)
      if ilk(val) <> #color then
        val = duplicate(shadRef.diffuse)
      end if
      sClone.diffuse = val
      val = exceptions.getaProp(#style)
      if ilk(val) <> #symbol then
        val = shadRef.style
      end if
      sClone.style = val
      val = exceptions.getaProp(#colorSteps)
      if ([#integer, #float]).getPos(ilk(val)) = 0 then
        val = shadRef.colorSteps
      end if
      sClone.colorSteps = val
      val = exceptions.getaProp(#shadowPercentage)
      if ([#integer, #float]).getPos(ilk(val)) = 0 then
        val = shadRef.shadowPercentage
      end if
      sClone.shadowPercentage = val
      val = exceptions.getaProp(#highlightPercentage)
      if ([#integer, #float]).getPos(ilk(val)) = 0 then
        val = shadRef.highlightPercentage
      end if
      sClone.highlightPercentage = val
      val = exceptions.getaProp(#shadowStrength)
      if ([#integer, #float]).getPos(ilk(val)) = 0 then
        val = shadRef.shadowStrength
      end if
      sClone.shadowStrength = val
      val = exceptions.getaProp(#highlightStrength)
      if ([#integer, #float]).getPos(ilk(val)) = 0 then
        val = shadRef.highlightStrength
      end if
      sClone.highlightStrength = val
    #newsprint:
      val = exceptions.getaProp(#diffuse)
      if ilk(val) <> #color then
        val = duplicate(shadRef.diffuse)
      end if
      sClone.diffuse = val
      val = exceptions.getaProp(#brightness)
      if ([#integer, #float]).getPos(ilk(val)) = 0 then
        val = shadRef.brightness
      end if
      sClone.brightness = val
      val = exceptions.getaProp(#density)
      if ([#integer, #float]).getPos(ilk(val)) = 0 then
        val = shadRef.density
      end if
      sClone.density = val
    #engraver:
      val = exceptions.getaProp(#diffuse)
      if ilk(val) <> #color then
        val = duplicate(shadRef.diffuse)
      end if
      sClone.diffuse = val
      val = exceptions.getaProp(#brightness)
      if ([#integer, #float]).getPos(ilk(val)) = 0 then
        val = shadRef.brightness
      end if
      sClone.brightness = val
      val = exceptions.getaProp(#density)
      if ([#integer, #float]).getPos(ilk(val)) = 0 then
        val = shadRef.density
      end if
      sClone.density = val
      val = exceptions.getaProp(#rotation)
      if ([#integer, #float]).getPos(ilk(val)) = 0 then
        val = shadRef.rotation
      end if
      sClone.rotation = val

  end case
  return sClone
end
on mGetUniqueShaderName memref, aName
  n = 1
  NewName = aName
  repeat while not voidp(memref.shader(NewName))
    NewName = aName & n
    n = n + 1
  end repeat
  return NewName
end