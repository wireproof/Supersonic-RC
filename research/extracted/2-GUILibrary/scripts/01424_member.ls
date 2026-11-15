-- Behavior
on paramPresent tInput, tParam
  case ilk(tInput) of
    #list:
      if tInput.getOne(tParam) <> 0 then
        return 1
      end if
      return 0

  end case
  return tInput = tParam
end
on nextMember tmember
  return member(the memberNum of tmember + 1, the castLibNum of tmember)
end