-- Script
property ancestor
property prange

on new me, tParams
  ancestor = script("valuedisplay").rawNew()
  callAncestor(#new, me, tParams)
  return me
end
on setRange me, tRange
  prange = tRange
end
on setValue me, tvalue, tParams
  if voidp(prange) = 0 then
    tvalue = value(tvalue)
    if voidp(tvalue) = 1 then
      exit
    end if
    tvalue = min(tvalue, prange[2])
    tvalue = max(tvalue, prange[1])
  end if
  callAncestor(#setValue, me, tvalue, tParams)
end