-- Script
property pSpinner
property pNumberDisplay
property pValue
property pStep
property prange
property pValueChangeCallback
property pValueType

on new me, tParams
  pValue = 0.0
  prange = [-the maxinteger, the maxinteger]
  tSpinnerSpeed = 1
  pValueType = #float
  if voidp(tParams[#default]) = 0 then
    pValueType = ilk(tParams[#default])
  end if
  if voidp(tParams[#valueType]) = 0 then
    pValueType = tParams[#valueType]
  end if
  case pValueType of
    #float:
      pStep = 0.1
    #integer:
      pStep = 1

  end case
  if voidp(tParams[#default]) = 0 then
    pValue = tParams[#default]
  end if
  if voidp(tParams[#valueRange]) = 0 then
    prange = tParams[#valueRange]
  end if
  if voidp(tParams[#step]) = 0 then
    pStep = tParams[#step]
  end if
  if voidp(tParams[#spinnerspeed]) = 0 then
    tSpinnerSpeed = tParams[#spinnerspeed]
  end if
  tValueChangeCallBackToSet = tParams[#valueChangeCallback]
  tParams[#editable] = 1
  tParams[#valueChangeCallback] = script("callback").new(#setValue, me)
  tParams[#validType] = pValueType
  pNumberDisplay = script("numberDisplay").new(tParams)
  tParams[#speed] = tSpinnerSpeed
  pSpinner = script("spinner").new(script("callback").new(#buttonPulse, me), tParams)
  me.setValue(pValue)
  me.alignButtons()
  pValueChangeCallback = tValueChangeCallBackToSet
  return me
end
on setValueChangeCallback me, tValueChangeCallback
  pValueChangeCallback = tValueChangeCallback
end
on buttonPulse me, tAmount
  tOldValue = pValue
  tvalue = pValue + pStep * tAmount
  me.setValue(tvalue, #forceOutOfEdit)
  if pValue <> tOldValue then
    return 1
  else
    return 0
  end if
end
on setValue me, tvalue, tParam
  tOldValue = pValue
  pValue = forceType(min(max(tvalue, prange[1]), prange[2]), pValueType)
  pNumberDisplay.setValue(pValue, tParam)
  if tOldValue <> pValue and paramPresent(tParam, #dontupdate) = 0 then
    call(#valueChanged, [me], pValue)
    doCallback(pValueChangeCallback, pValue)
  end if
end
on GetValue me
  return pValue
end
on setLoc me, tLoc
  pNumberDisplay.setLoc(tLoc)
  me.alignButtons()
end
on setLocz me, tLocZ
  pNumberDisplay.setLocz(tLocZ)
  pSpinner.setLocz(tLocZ)
end
on alignButtons me
  tSpinnerLoc = point(pNumberDisplay.getRight(), pNumberDisplay.getTop())
  pSpinner.setLoc(tSpinnerLoc)
end
on setEditable me, tEditable
  pNumberDisplay.setEditable(tEditable)
  case tEditable of
    0:
      pSpinner.Disable()
    1:
      pSpinner.enable()

  end case
end
on setVisible me, tVisible
  pNumberDisplay.setVisible(tVisible)
  pSpinner.setVisible(tVisible)
end
on setStep me, tStep
  pStep = tStep
end
on setSpinnerSpeed me, tSpeed
  pSpinner.setSpeed(tSpeed)
end
on setRange me, tRange
  prange = tRange
  me.setValue(pValue)
end
on destroy me
  pSpinner = pSpinner.destroy()
  pNumberDisplay = pNumberDisplay.destroy()
  pValueChangeCallback = 0
  return 0
end