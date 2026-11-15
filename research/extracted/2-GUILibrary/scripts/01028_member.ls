-- Behavior
on showAll
  repeat with i = 1 to 200
    sprite(i).visible = 1
  end repeat
end
on sign tNumber
  if tNumber >= 0 then
    return 1
  end if
  return -1
end