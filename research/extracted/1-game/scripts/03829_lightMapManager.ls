-- Script
property pStep

on new me
  pStep = 0
  gJo = me
  if the runMode <> "Plugin" and 1 then
    member("UV_Lightmap_UVs").scriptText = getPref("lightmapinfo")
  end if
  tmember = member("3d")
  tUVs = getUVs_UV_Lightmap()
  tLightMaps = []
  repeat with tmodel in tUVs
    tLightmap = tmodel[#lightmap]
    if tLightMaps.getOne(tLightmap) = 0 then
      tLightMaps.append(tmodel[#lightmap])
    end if
  end repeat
  if the runMode <> "Plugin" and 1 then
    repeat with tLightmap in tLightMaps
      t = getDynamicSlot()
      t.importFileInto(tLightmap & "LightingMap.bmp")
      t.name = tLightmap & "LightingMap"
    end repeat
  end if
  repeat with i = 1 to tmember.model.count
    tmodel = tmember.model[i]
    if voidp(tUVs.getaProp(tmodel.name)) then
      next repeat
    end if
    if voidp(tUVs.getaProp(tmodel.name).getaProp("lightmap")) then
      next repeat
    end if
    repeat with ii = 1 to tmodel.shaderList.count
      tmodel.shaderList[ii] = mCloneShader(tmember, tmodel.shaderList[ii])
      tLightMapName = tUVs[tmodel.name][#lightmap] & "LightingMap"
      ttexture = tmember.texture(tLightMapName)
      if voidp(ttexture) then
        ttexture = tmember.newTexture(tLightMapName, #fromCastMember, member(tLightMapName))
        ttexture.renderFormat = #rgba8880
      end if
      tmodel.shaderList[ii].textureList[2] = ttexture
      tmodel.shaderList[ii].useDiffuseWithTexture = 1
      if tmodel.shaderList[ii].textureList[1] = VOID then
        tmodel.shaderList[ii].useDiffuseWithTexture = 1
      end if
      if tmodel.shaderList[ii].textureList[1].name = "DefaultTexture" then
        tmodel.shaderList[ii].textureList[1] = VOID
      end if
    end repeat
  end repeat
  p3d = member("3d")
  tshader = p3d.shader("column")
  tshader.ambient = rgb(0, 0, 0)
  tshader.diffuse = rgb("111133")
  tshader.specular = rgb(5, 5, 5)
  tshader.useDiffuseWithTexture = 1
  tshader = p3d.shader("Ex_Main_02")
  tshader.ambient = rgb(0, 0, 0)
  tshader.diffuse = rgb("111133")
  tshader.specular = rgb(5, 5, 5)
  tshader.useDiffuseWithTexture = 1
  tshader = p3d.shader("D_Clone")
  tshader.ambient = rgb(0, 0, 0)
  tshader.specular = rgb(10, 10, 10)
  tshader.diffuse = rgb("441111")
  tshader.textureList[2] = VOID
  return me
end
on doApplyUVs me
  tUVs = getUVs_UV_Lightmap()
  tmember = member("3d")
  t = tmember.camera[1].worldPosition
  tmember.camera[1].worldPosition = vector(0, 0, 50000)
  tmember.camera[1].pointAt(vector())
  set the stageColor to the stageColor
  me.applyUVs(tUVs, 2)
  tmember.camera[1].worldPosition = t
end
on stepFrame me
  exit
  if the controlDown = 0 then
    exit
  end if
  me.doApplyUVs()
  repeat while the controlDown
  end repeat
end
on applyUVs me, tUVs, tMappingChannel
  tmember = member("3d")
  repeat with i = 1 to tmember.model.count
    tmodel = tmember.model[i]
    if voidp(tUVs[tmodel.name]) then
      next repeat
    end if
    tModelUVs = tUVs[tmodel.name][#uvs]
    tmodel.resource.lod.auto = 0
    tmodel.resource.lod.level = 100
    tmodel.addModifier(#meshDeform)
    repeat with tMesh = 1 to tmodel.meshDeform.mesh.count
      tMeshUVs = tModelUVs[tMesh]
      repeat while tmodel.meshDeform.mesh[tMesh].textureLayer.count < tMappingChannel
        tmodel.meshDeform.mesh[tMesh].textureLayer.add()
        tCount = tmodel.meshDeform.mesh[tMesh].textureLayer.count
      end repeat
      if tmodel.shaderList[tMesh].textureList[1] = VOID then
        tmodel.meshDeform.mesh[tMesh].textureLayer[1].textureCoordinateList = tMeshUVs
        put "putting in bullshit uv's in first layer for model: " & tmodel.name & " mesh: " & tMesh
      else
      end if
      tmodel.meshDeform.mesh[tMesh].textureLayer[tMappingChannel].textureCoordinateList = tMeshUVs
    end repeat
  end repeat
end
on extractUVsFrom tUVSource
  tmember = member("geometry")
  tBigLists = constructBigLists(tUVSource)
  tStoredUVs = [:]
  repeat with i = 1 to tmember.model.count
    tSkipModel = 0
    tMeshUVs = []
    tModelInfo = [#uvs: tMeshUVs]
    tmodel = tmember.model[i]
    tmodel.resource.lod.auto = 0
    tmodel.resource.lod.level = 100
    tmodel.addModifier(#meshDeform)
    tModelXForm = tmodel.getWorldTransform()
    repeat with tMesh = 1 to tmodel.meshDeform.mesh.count
      tNewUVs = tmodel.meshDeform.mesh[tMesh].textureCoordinateList
      tMyVertexList = tmodel.meshDeform.mesh[tMesh].vertexList
      repeat with o = 1 to tmodel.meshDeform.mesh[tMesh].face.count
        tFace = tmodel.meshDeform.mesh[tMesh].face[o]
        tResult = mapFaceToFace(tFace, tMyVertexList, tModelXForm, tBigLists)
        tFaceIndex = tResult[#faceIndex]
        tEpsilon2 = 0.5
        tTries = 1
        repeat while tFaceIndex = "error"
          tEpsilon2 = tEpsilon2 * 2
          debugPut("mapping failed. model:" & tmodel.name & "  mesh:" & tMesh & " face:" & o & " now trying tEpsilon=" & tEpsilon2)
          tResult = mapFaceToFace(tFace, tMyVertexList, tModelXForm, tBigLists, tEpsilon2)
          tFaceIndex = tResult[#faceIndex]
        end repeat
        if tSkipModel then
          exit repeat
        end if
        if voidp(tModelInfo[#lightmap]) then
          tModelInfo[#lightmap] = tResult[#model]
        else
          if tModelInfo[#lightmap] <> tResult[#model] then
            alert(tmodel & " has mapped onto both " & tModelInfo[#lightmap] & " and onto " & tResult[#model])
            tSkipModel = 1
            exit repeat
          end if
        end if
        tLightMapList = tBigLists[tModelInfo[#lightmap]]
        tNewUVs[tFace[1]] = tLightMapList[#uv][tLightMapList[#f][tFaceIndex][1]]
        tNewUVs[tFace[2]] = tLightMapList[#uv][tLightMapList[#f][tFaceIndex][2]]
        tNewUVs[tFace[3]] = tLightMapList[#uv][tLightMapList[#f][tFaceIndex][3]]
      end repeat
      repeat with q = 1 to tNewUVs.count
        if tNewUVs[q] = 0 then
          tNewUVs[q] = [0, 0]
        end if
      end repeat
      tMeshUVs.append(tNewUVs)
      if tSkipModel then
        exit repeat
      end if
    end repeat
    if tSkipModel = 0 then
      tStoredUVs.addProp(tmodel.name, tModelInfo)
    end if
  end repeat
  tScript = member(tUVSource.name & "_UVs")
  if tScript.type = #empty then
    tScript = new(#script)
    tScript.scriptType = #movie
    tScript.name = tUVSource.name & "_UVs"
  end if
  tScript.scriptText = "on getUVs_" & tUVSource.name & RETURN & "return " & string(tStoredUVs) & RETURN & "end" & RETURN
end
on constructBigLists tmember
  tModelInfo = propList()
  repeat with i = 1 to tmember.model.count
    tUVs = []
    tVertices = []
    tFaces = []
    tmodel = tmember.model[i]
    tmodel.resource.lod.auto = 0
    tmodel.resource.lod.level = 100
    tmodel.addModifier(#meshDeform)
    tWorldXForm = tmodel.getWorldTransform()
    repeat with tMesh = 1 to tmodel.meshDeform.mesh.count
      tOffset = [tUVs.count, tUVs.count, tUVs.count]
      repeat with o = 1 to tmodel.meshDeform.mesh[tMesh].textureCoordinateList.count
        tUVs.append(tmodel.meshDeform.mesh[tMesh].textureCoordinateList[o])
        tVertices.append(tWorldXForm * tmodel.meshDeform.mesh[tMesh].vertexList[o] + vector())
      end repeat
      repeat with o = 1 to tmodel.meshDeform.mesh[tMesh].face.count
        tFaces.append(tmodel.meshDeform.mesh[tMesh].face[o] + tOffset)
      end repeat
    end repeat
    if tFaces.count = 0 then
      put "huh 0 faces"
      exit
    end if
    tModelInfo.addProp(tmodel.name, [#uv: tUVs, #v: tVertices, #f: tFaces])
  end repeat
  return tModelInfo
end
on mapFaceToFace tFace, tMyVertexList, tMyVertexListXForm, tLightMapsInfo, tEpsilon
  if voidp(tEpsilon) then
    tEpsilon = 0.5
  end if
  tFaceVertices = [tMyVertexListXForm * tMyVertexList[tFace[1]], tMyVertexListXForm * tMyVertexList[tFace[2]], tMyVertexListXForm * tMyVertexList[tFace[3]]]
  repeat with i = 1 to 3
    tFaceVertices[i] = tFaceVertices[i] + vector()
  end repeat
  repeat with o = 1 to tLightMapsInfo.count
    tLightmap = tLightMapsInfo[o]
    tLightmapFaces = tLightmap[#f]
    tLightmapVertices = tLightmap[#v]
    tLightMapName = tLightMapsInfo.getPropAt(o)
    repeat with i1 = 1 to tLightmapFaces.count
      tOK = 0
      if tFaceVertices[1].distanceTo(tLightmapVertices[tLightmapFaces[i1][1]]) < tEpsilon then
        tOK = 1
      end if
      if tFaceVertices[2].distanceTo(tLightmapVertices[tLightmapFaces[i1][1]]) < tEpsilon then
        tOK = 1
      end if
      if tFaceVertices[3].distanceTo(tLightmapVertices[tLightmapFaces[i1][1]]) < tEpsilon then
        tOK = 1
      end if
      if tOK = 0 then
        next repeat
      end if
      tOK = 0
      if tFaceVertices[1].distanceTo(tLightmapVertices[tLightmapFaces[i1][2]]) < tEpsilon then
        tOK = 1
      end if
      if tFaceVertices[2].distanceTo(tLightmapVertices[tLightmapFaces[i1][2]]) < tEpsilon then
        tOK = 1
      end if
      if tFaceVertices[3].distanceTo(tLightmapVertices[tLightmapFaces[i1][2]]) < tEpsilon then
        tOK = 1
      end if
      if tOK = 0 then
        next repeat
      end if
      tOK = 0
      if tFaceVertices[1].distanceTo(tLightmapVertices[tLightmapFaces[i1][3]]) < tEpsilon then
        tOK = 1
      end if
      if tFaceVertices[2].distanceTo(tLightmapVertices[tLightmapFaces[i1][3]]) < tEpsilon then
        tOK = 1
      end if
      if tFaceVertices[3].distanceTo(tLightmapVertices[tLightmapFaces[i1][3]]) < tEpsilon then
        tOK = 1
      end if
      if tOK = 0 then
        next repeat
      end if
      return [#faceIndex: i1, #model: tLightMapName]
    end repeat
  end repeat
  return [#faceIndex: "error"]
end
on debugPut tMsg
  if the runMode = "Author" then
    put tMsg
  else
    setPref("facemaplog", getPref("facemaplog") & RETURN & tMsg)
  end if
end