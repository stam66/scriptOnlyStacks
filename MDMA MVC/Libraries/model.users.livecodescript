script "model.users"

local sUsersA, sCurrentUserA

--> Human readable name of current user
function getCurrentUserName
   if sCurrentUserA is empty then
      return empty
   else
      return sCurrentUserA["firstName"] && sCurrentUserA["lastName"]
   end if
end getCurrentUserName

function getUsers pProjectName
   # PURPOSE : get all user data as a numerically keyed array
   local tUsersTableName, tArray
   put cdb_userTableName(pProjectName) into tUsersTableName
   put cdb_read(tUsersTableName, "*", "cloud") into tArray
   return returnNumberedArray(tArray)
end getUsers

command updateUserData pEmail, pDataA
   # PURPOSE : Update user data
   # array that can contain  keys:  firstName, lastName, email, privilegeSet, analyser (PW change is separate)
   if pEmail is empty then put sCurrentUserA["email"] into pEmail
   cdb_updateUserAccount pDataA, pEmail, , false, "CoreLab3" # CDB call - updateUserAccont
   dispatch "hideMessage" to group "messageGroup"
end updateUserData