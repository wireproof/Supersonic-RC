-- Script
property pSelectLevelManager
property pDrivingManager
property pTitleManager
property pHelpManager

on new me
  pSelectLevelManager = script("selectLevelManager").new()
  pDrivingManager = script("drivingManager").new()
  pTitleManager = script("titlemanager").new()
  pHelpManager = script("helpmanager").new()
  script("sprite").new([#range: ["loading"], #name: "text"])
  if debugModus() then
    return pSelectLevelManager.start()
  end if
  pTitleManager.start()
  return me
end
on getSelectLevelManager me
  return pSelectLevelManager
end
on getDrivingManager me
  return pDrivingManager
end
on getHelpManager me
  return pHelpManager
end
on destroy me
  if objectp(pSelectLevelManager) then
    pSelectLevelManager = pSelectLevelManager.destroy()
  end if
  if objectp(pDrivingManager) then
    pDrivingManager = pDrivingManager.destroy()
  end if
end