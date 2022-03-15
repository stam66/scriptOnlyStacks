script "controller.app"
local sCanelaPath, sLibPath, sDevPath

on preOpenStack
   get getDevPath()
   get getCanelaLibPath()  
   get getLibraryPath()
   
   start using stack (getLibraryPath() & "/controller.utilities.livecodescript")
end preOpenStack


function getDevPath
   put specialFolderPath("documents") & "/Developer/scriptOnlyStacks/" into sDevPath
   return sDevPath
end getDevPath


function getCanelaLibPath
   local tPath
   put specialFolderPath("documents") & "/MDM Assistant/" & the meetingShortName of this stack & "/CanelaDB/Libraries/" into tPath
   if there is a folder tPath then 
      put tpath into sCanelaPath
      return sCanelaPath
   else 
      return false
   end if
end getCanelaLibPath


function getLibraryPath
   if not getCanelaLibPath() then return "Error - CanelaDB libraries not found"
   if the environment is "developement" then
      put sDevPath into sLibPath
   else
      set the itemdel to slash
      put item 1 to -3 of sCanelaPath & "/Libraries/" into sLibPath
   end if
   return sLibPath
end getLibraryPath

--private command _initStacks
--   local tDevPath, tPath


--   put gLibPath & "liveCloud.livecode" into tPath
--   if there is a file tPath then 
--      start using stack tPath
--   else
--      answer "Error accessing liveCloud lib"
--   end if
--   initialiseCloud

--   if the environment is "development" then 
--      put tDevPath & "skLib" into tPath
--   else
--      put gLibpath & "skLib" into tPath
--   end if

--   try
--      start using stack tPath
--   catch e
--      answer "Error accessing the skLib library:" && e
--   end try

--end _initStacks
