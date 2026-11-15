-- Script
property pHandler
property pObject
property P1
property P2
property p3
property p4
property p5

on new me, tHandler, tObject, t1, t2, t3, t4, t5
  pHandler = tHandler
  pObject = tObject
  P1 = t1
  P2 = t2
  p3 = t3
  p4 = t4
  p5 = t5
  return me
end
on execute me, t1, t2, t3, t4, t5
  if voidp(P1) then
    call(pHandler, pObject, t1, t2, t3, t4, t5)
  else
    call(pHandler, pObject, P1, P2, p3, p4, p5)
  end if
end
on destroy me
  pHandler = 0
  pObject = 0
  P1 = 0
  P2 = 0
  p3 = 0
  p4 = 0
  p5 = 0
  return 0
end