-- Script
property ancestor
property pOtherButton
property pSpinner
property pDirection
property pSpinning
property pLastSpinMouseLoc

on new me, tSpinner, tParams
  pDirection = tParams[#direction]
  tParams[#members] = me.getSpinnerMembers()
  ancestor = script("pulsingbutton").rawNew()
  callAncestor(#new, me, tParams)
  pSpinner = tSpinner
  pSpinning = 0
  me.pPulseMSChart = [300, 100]
  return me
end
on getSpinnerMembers me
  tMembers = [:]
  tMembers[#normal] = member("max_spinner_button_" & string(pDirection) & "_normal")
  tMembers[#rollover] = member("max_spinner_button_" & string(pDirection) & "_normal")
  tMembers[#pressed] = member("max_spinner_button_" & string(pDirection) & "_pressed")
  tMembers[#disabled] = member("max_spinner_button_" & string(pDirection) & "_normal")
  return tMembers
end
on Action me
  case pDirection of
    #up:
      pSpinner.buttonPulse(1)
    #down:
      pSpinner.buttonPulse(-1)

  end case
end
on mouseLeave me
  callAncestor(#mouseLeave, me)
  if me.pEnabled = 0 then
    exit
  end if
  if me.pPressed then
    pSpinner.startSpinning()
  end if
end
on Disable me
  callAncestor(#Disable, me)
  me.setMember(me.pMembers[#disabled])
end
on mouseUp me
  callAncestor(#mouseUp, me)
  pSpinner.stopSpinning()
end
on mouseUpOutSide me
  callAncestor(#mouseUpOutSide, me)
  pSpinner.stopSpinning()
end
on destroy me
  callAncestor(#destroy, me)
  ancestor = 0
  pSpinner = 0
  return 0
end