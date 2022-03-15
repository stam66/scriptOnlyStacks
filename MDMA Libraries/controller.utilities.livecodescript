script "controller.utilities"

on checkInternetStatus
   if not cdb_checkInternetStatus() then
      answer "The cloud server cannot be reached - please check your internet connection." with "Try again" and "Quit"
      if it is "Try again" then
         wait 1 second with messages
         checkInternetStatus
      else
         quit
      end if
   else
      return true
   end if
end checkInternetStatus

function getStackVersion pVersion 
   # pass the stackVersion custom prop of the stack, get human readable text
   # if there is a version >0 in the 3rd item, it's an RC version, if the 4th item > 0 then it's a beta version
   # eg: 4.31.0.1 = 4.31 beta1, 4.31.2.0 = 4.31 RC2
   local tTextVersion
   set the itemdelimiter to "."
   put item 1 of pVersion into item 1 of tTextVersion
   put item 2 of pVersion into item 2 of tTextVersion
   if item 3 of pVersion > 0 then
      put " RC" & item 3 of pVersion after tTextVersion
   else if item 4 of pVersion > 0 then
      put " b" & item 4 of pVersion after tTextVersion
   end if
   return tTextVersion  
end getStackVersion

on stackTest
    get getDevPath()
    breakpoint
end stackTest

## MessageGroup handlers
on showMessage pMessage
   set the text of field "message" of group "messageGroup" to pMessage
   set the visible of group "messageGroup" to true
end showMessage

on hideMessage
   set the visible of group "messageGroup" to false
   set the text of field "message" of group "messageGroup" to "<Message>"
end hideMessage
## end messageGroup handlers

on mouseDown
   if (the short name of the target is "messageGroup") then hideMessage
   
   pass mouseDown
end mouseDown
