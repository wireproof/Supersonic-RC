-- Behavior
global gMach8GUIManager

on prepareMovie
  the actorList = []
  MACH8_GUI_PrepareMovie()
end
on stopMovie
  gMach8GUIManager = gMach8GUIManager.destroy()
end
on MACH8_GUI_PrepareMovie
  gMach8GUIManager = script("Mach8GUIManager").new()
  repeat with i = 1 to the number of castMembers of castLib "dynamic"
    member(i, "dynamic").erase()
  end repeat
end
on mach8_go tFrame
  gMach8GUIManager.aboutToGo1(tFrame)
  the updateLock = 1
  go(tFrame)
  gMach8GUIManager.aboutToGo2(tFrame)
  the updateLock = 0
end
on MACH8_UpdateLockedGo tFrame
  gMACH8_UpdateLockedGo_Backup = [the actorList, the frame]
  the actorList = []
  the updateLock = 1
  go(tFrame)
end
on MACH8_UpdateLockedGoBack
  go(gMACH8_UpdateLockedGo_Backup[2])
  the updateLock = 0
  the actorList = gMACH8_UpdateLockedGo_Backup[1]
end
on doCallback tCallback, tMsg
  if voidp(tCallback) = 0 and tCallback <> 0 then
    case ilk(tCallback) of
      #propList:
        if voidp(tMsg) then
          if voidp(tCallback[#msg]) then
            return call(tCallback[#handler], tCallback[#object])
          else
            return call(tCallback[#handler], tCallback[#object], tCallback[#msg])
          end if
        else
          return call(tCallback[#handler], tCallback[#object], tMsg, tCallback[#msg])
        end if
      #instance:
        tCallback.execute(tMsg)

    end case
  end if
end
on getDynamicSlot
  t = the number of castMembers of castLib "dynamic"
  return member(t + 1, "dynamic")
end
on getDynamicCopy tmember
  t = getDynamicSlot()
  tmember.duplicate(t)
  return t
end
on forceType tvalue, tType
  case tType of
    #integer:
      return integer(tvalue)
    #float:
      return float(tvalue)
    otherwise:
      alert("no forcetype support for type")

  end case
end
on assert tCondition, tMessage
  if tCondition = 0 then
    alert(tMessage)
    nothing()
  end if
end