-- Script
property pEpsilon
property pGridOrigin
property pSectorWidth
property pSectorHeight
property pSectors
property pSoup
property pSubDivisions

on new me, tStored
  pEpsilon = 1e-05
  p3d = member("3d")
  pSubDivisions = 50
  if voidp(tStored) = 0 then
    pSectors = tStored[#sectors]
    pSubDivisions = tStored[#subdivisions]
    pSectorWidth = tStored[#sectorwidth]
    pSectorHeight = tStored[#sectorheight]
    pGridOrigin = tStored[#gridorigin]
  else
    repeat with i = 1 to p3d.model.count
      p3d.model[i].addModifier(#meshDeform)
      p3d.model[i].removeFromWorld()
    end repeat
    updateStage()
    pSoup = []
    repeat with i = 1 to p3d.model.count
      x = p3d.model[i].getWorldTransform()
      repeat with tMesh = 1 to p3d.model[i].meshDeform.mesh.count
        tVL = p3d.model[i].meshDeform.mesh[tMesh].vertexList
        repeat with tFace = 1 to p3d.model[i].meshDeform.mesh[tMesh].face.count
          tFaceList = p3d.model[i].meshDeform.mesh[tMesh].face[tFace]
          t1 = x * tVL[tFaceList[1]] + vector()
          t2 = x * tVL[tFaceList[2]] + vector()
          t3 = x * tVL[tFaceList[3]] + vector()
          pSoup.append(t1)
          pSoup.append(t2 - t1)
          pSoup.append(t3 - t1)
        end repeat
      end repeat
    end repeat
    me.makeSectorSoup(pSoup)
  end if
  repeat with y = 1 to pSectors.count
    repeat with x = 1 to pSectors[1].count
      tSoup = pSectors[y][x].duplicate()
      tNewMesh = p3d.newMesh("soup_" & x & "_" & y, tSoup.count / 3, tSoup.count, 0, 0, 0)
      repeat with i = 0 to tSoup.count / 3 - 1
        tSoup[i * 3 + 2] = tSoup[i * 3 + 1] + tSoup[i * 3 + 2]
        tSoup[i * 3 + 3] = tSoup[i * 3 + 1] + tSoup[i * 3 + 3]
        tNewMesh.face[i + 1].vertices = [i * 3 + 1, i * 3 + 2, i * 3 + 3]
      end repeat
      tNewMesh.vertexList = tSoup
      tNewMesh.generateNormals(#flat)
      tNewMesh.build()
      tSoupModel = p3d.newModel("souppie_" & x & "_" & y, tNewMesh)
      tSoupModel.removeFromWorld()
    end repeat
  end repeat
  return me
end
on exportSoup me
  tvalue = propList()
  tvalue[#sectors] = pSectors
  tvalue[#subdivisions] = pSubDivisions
  tvalue[#sectorwidth] = pSectorWidth
  tvalue[#sectorheight] = pSectorHeight
  tvalue[#gridorigin] = pGridOrigin
  tText = "on getStoredSoup" & RETURN & "return " & string(tvalue) & RETURN & "end"
  member("storedsoup").scriptText = tText
end
on makeSectorSoup me, tSoup
  tMaxX = -the maxinteger
  tMaxY = -the maxinteger
  tMinX = the maxinteger
  tMinY = the maxinteger
  repeat with i in tSoup
    tMinX = min(tMinX, i.x)
    tMinY = min(tMinY, i.y)
    tMaxX = max(tMaxX, i.x)
    tMaxY = max(tMaxY, i.y)
  end repeat
  pGridOrigin = point(tMinX, tMinY)
  pSectorWidth = (tMaxX - tMinX) / pSubDivisions
  pSectorHeight = (tMaxY - tMinY) / pSubDivisions
  pSectors = []
  repeat with tX = 0 to pSubDivisions - 1
    tRow = []
    pSectors.append(tRow)
    repeat with tY = 0 to pSubDivisions - 1
      tSector = rect(0, 0, 0, 0)
      tSector[1] = tMinX + tX * pSectorWidth
      tSector[2] = tMinY + tY * pSectorHeight
      tSector[3] = tMinX + (tX + 1) * pSectorWidth
      tSector[4] = tMinY + (tY + 1) * pSectorHeight
      put tSector
      tSectorSoup = []
      repeat with i = 0 to pSoup.count / 3 - 1
        if polyInsideSector(pSoup[i * 3 + 1], pSoup[i * 3 + 2], pSoup[i * 3 + 3], tSector) then
          tSectorSoup.append(pSoup[i * 3 + 1])
          tSectorSoup.append(pSoup[i * 3 + 2])
          tSectorSoup.append(pSoup[i * 3 + 3])
        end if
      end repeat
      put tSectorSoup.count
      tRow.append(tSectorSoup)
    end repeat
  end repeat
end
on floor tNumber
  return integer(tNumber - 0.5)
end
on modelsUnderRay me, tStart, tDirection
  tOffsets = tStart - mv(pGridOrigin)
  tX = floor(tOffsets.x / pSectorWidth)
  tY = floor(tOffsets.y / pSectorHeight)
  tPolies = pSectors[tX + 1][tY + 1]
  tClosest = the maxinteger
  repeat with i = 0 to tPolies.count / 3 - 1
    t = RayTriangleIntersect(tStart, tDirection, tPolies[i * 3 + 1], tPolies[i * 3 + 2], tPolies[i * 3 + 3], tClosest)
    if vectorp(t) then
      tDist = tStart.distanceTo(t)
      if tDist < tClosest then
        tClosest = tDist
        tIsect = t
      end if
    end if
  end repeat
  return tIsect
end
on polyInsideSector tBase, tEdge1, tEdge2, tSector
  if MP(tBase).inside(tSector) then
    return 1
  end if
  if MP(tBase + tEdge1).inside(tSector) then
    return 1
  end if
  if MP(tBase + tEdge2).inside(tSector) then
    return 1
  end if
  tTriangle = [tBase.duplicate(), tBase + tEdge1, tBase + tEdge2]
  tTriangle[1].z = 0
  tTriangle[2].z = 0
  tTriangle[3].z = 0
  if PointInsideTriangle(point(tSector[1], tSector[2]), tTriangle) then
    PointInsideTriangle(point(tSector[1], tSector[2]), tTriangle)
    return 1
  end if
  if PointInsideTriangle(point(tSector[3], tSector[2]), tTriangle) then
    PointInsideTriangle(point(tSector[3], tSector[2]), tTriangle)
    return 1
  end if
  if PointInsideTriangle(point(tSector[1], tSector[4]), tTriangle) then
    PointInsideTriangle(point(tSector[1], tSector[4]), tTriangle)
    return 1
  end if
  if PointInsideTriangle(point(tSector[3], tSector[4]), tTriangle) then
    PointInsideTriangle(point(tSector[3], tSector[4]), tTriangle)
    return 1
  end if
  if LineLineIntersect(tTriangle[1], tTriangle[2], point(tSector[1], tSector[2]), point(tSector[3], tSector[2])) then
    return 1
  end if
  if LineLineIntersect(tTriangle[1], tTriangle[2], point(tSector[3], tSector[2]), point(tSector[3], tSector[4])) then
    return 1
  end if
  if LineLineIntersect(tTriangle[1], tTriangle[2], point(tSector[3], tSector[4]), point(tSector[1], tSector[4])) then
    return 1
  end if
  if LineLineIntersect(tTriangle[1], tTriangle[2], point(tSector[1], tSector[4]), point(tSector[1], tSector[2])) then
    return 1
  end if
  if LineLineIntersect(tTriangle[1], tTriangle[3], point(tSector[1], tSector[2]), point(tSector[3], tSector[2])) then
    return 1
  end if
  if LineLineIntersect(tTriangle[1], tTriangle[3], point(tSector[3], tSector[2]), point(tSector[3], tSector[4])) then
    return 1
  end if
  if LineLineIntersect(tTriangle[1], tTriangle[3], point(tSector[3], tSector[4]), point(tSector[1], tSector[4])) then
    return 1
  end if
  if LineLineIntersect(tTriangle[1], tTriangle[3], point(tSector[1], tSector[4]), point(tSector[1], tSector[2])) then
    return 1
  end if
  if LineLineIntersect(tTriangle[3], tTriangle[2], point(tSector[1], tSector[2]), point(tSector[3], tSector[2])) then
    return 1
  end if
  if LineLineIntersect(tTriangle[3], tTriangle[2], point(tSector[3], tSector[2]), point(tSector[3], tSector[4])) then
    return 1
  end if
  if LineLineIntersect(tTriangle[3], tTriangle[2], point(tSector[3], tSector[4]), point(tSector[1], tSector[4])) then
    return 1
  end if
  if LineLineIntersect(tTriangle[3], tTriangle[2], point(tSector[1], tSector[4]), point(tSector[1], tSector[2])) then
    return 1
  end if
  return 0
end
on SameSide P1, P2, a, b
  cp1 = (b - a).cross(P1 - a)
  cp2 = (b - a).cross(P2 - a)
  if cp1.dot(cp2) > 0 then
    return 1
  end if
  return 0
end
on PointInsideTriangle tPoint, tTriangle
  tVector = mv(tPoint)
  if SameSide(tVector, tTriangle[3], tTriangle[1], tTriangle[2]) = 0 then
    return 0
  end if
  if SameSide(tVector, tTriangle[1], tTriangle[2], tTriangle[3]) = 0 then
    return 0
  end if
  if SameSide(tVector, tTriangle[2], tTriangle[3], tTriangle[1]) = 0 then
    return 0
  end if
  return 1
end
on MP tVector
  return point(tVector[1], tVector[2])
end
on mv tPoint
  return vector(tPoint[1], tPoint[2], 0)
end
on RayTriangleIntersect tOrig, tDir, tVert0, tEdge1, tEdge2, tMaxDistance
  pvec = tDir.cross(tEdge2)
  tDet = tEdge1.dot(pvec)
  if tDet < pEpsilon then
    return 0
  end if
  tVec = tOrig - tVert0
  qvec = tVec.cross(tEdge1)
  tt = tEdge2.dot(qvec) / tDet
  if tt < 0 then
    return 0
  end if
  if tt > tMaxDistance then
    return 0
  end if
  tU = tVec.dot(pvec)
  if tU < 0.0 or tU > tDet then
    return 0
  end if
  tV = tDir.dot(qvec)
  if tV < 0 or tU + tV > tDet then
    return 0
  end if
  tU = tU / tDet
  tV = tV / tDet
  return tVert0 + tU * tEdge1 + tV * tEdge2
end
on check_tri_clock_dir pt1, pt2, pt3
  test = (pt2[1] - pt1[1]) * (pt3[2] - pt1[2]) - (pt3[1] - pt1[1]) * (pt2[2] - pt1[2])
  if test > 0 then
    return #COUNTER_CLOCKWISE
  else
    if test < 0 then
      return #CLOCKWISE
    else
      return #line
    end if
  end if
end
on LineLineIntersect l1p1, l1p2, l2p1, l2p2
  test1_a = check_tri_clock_dir(l1p1, l1p2, l2p1)
  test1_b = check_tri_clock_dir(l1p1, l1p2, l2p2)
  if test1_a <> test1_b then
    test2_a = check_tri_clock_dir(l2p1, l2p2, l1p1)
    test2_b = check_tri_clock_dir(l2p1, l2p2, l1p2)
    if test2_a <> test2_b then
      return 1
    end if
  end if
  return 0
end