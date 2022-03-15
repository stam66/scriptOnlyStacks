on calculateAngleForCircle pCircle -- the long id of the circle
   local x0, y0, deltaX, deltaY, tAngle
   put item 1 of the loc of pCircle into x0
   put item 2 of the loc of pCircle into y0
   put x0 - the mouseH into deltaX
   put y0 - the mouseV into deltaY
   if deltaY = 0 then exit calculateAngleForCircle

   put atan(deltaX/deltaY) into tAngle
   put round(tAngle *(180/pi)) into tAngle
   if deltaY < 0 then // upper
      if tAngle < 0 then put 360 + tAngle into tAngle
   end if
   return tAngle
end calculateAngleForCircle

on updateUI

end updateUI

   if not the uAllowCheck of me then exit myLoop
   lock screen
   put LX0 - the mouseH  into xx
   put the mouseV - LY0 into yy

   if yy > 0 then --upper
      put  atan(xx/yy) into theta
      put round(180*theta/pi) into theta
      if theta < 0 then put 360 + theta into theta
   end if
   if yy < 0 then --lower
      put  atan(xx/yy) into theta
      put round(180*theta/pi) +180 into theta
   end if

    if theta < 345 then ### for range
      set the arcAngle of grc bandOval of grp LgName to theta-10
      set the startAngle of grc bandOval of grp LgName to 255- the arcAngle of grc bandOval of grp LgName
   end if

   if theta >15 and theta < 345 then
      put Theta*pi/180 into tr
     set the loc of grc iOval of grp LgName to LX0-Lr*sin(tr), LY0+Lr*cos(tr)
   end if

   set the numberFormat to the cNumForm of grp LgName

   if theta < 10 then put LoVal into fld "DialVal" of grp LgName
   else if theta > 345 then put HiVal into fld "DialVal" of grp LgName
   else put Lb + Lm*theta into fld "DialVal" of grp LgName
   unlock screen
   send "myLoop" to me in 50 milliseconds
