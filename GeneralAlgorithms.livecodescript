script "GeneralAlgorithms"
local sFilePathA //array containing creation dates and filepaths for files examined by traverseFolderDetailed()


/// PURPOSE: RECURSIVELY TRAVERSE FOLDER STRUCTURE AND RETURN A RETURN-DELIMITED LIST OF FILEPATHS 
/// OF ALL FILES WITH GIVEN EXTENSION
Function traverseFolder pFolder, pExt
   local tFileList
   
   set the defaultFolder to pFolder  
   repeat for each line tFile in the files
      set the itemDelimiter to "."
      if the last item of tFile = pExt then
         put the longfilepath of tFile  & return after tFileList
      end if
   end repeat
   
   repeat for each line tFolder in the folders
      if the first char of tFolder is not "." then
         put traverseFolder((pFolder & fDelimiter() & tFolder), pExt)  & return after tFileList
      end if
   end repeat
   
   filter tFileList without empty
   return tFileList
end traverseFolder

---=========================   RECURSIVE FILEPATH ARRAY  ===============================---
/// PURPOSE: CALLS traverseFolderDetailed COMMAND TO ALLOW RECURSION AND THEN RETURN THE ARRAY
/// OPTIONALLY RESET sFilePathArray - if resetArray set to true
function getFilePathArray pFolder, pExt, resetArray
   if resetArray then put empty into sFilePathA
   traverseFolderDetailed pFolder, pExt
   return sFilePathA
end getFilePathArray

/// PURPOSE: RECURSIVELY TRAVERSE FOLDER STRUCURE AND RETURN ARRAY OF [X][CREATION DATE][FILE PATH] 
/// OF ALL FILES WITH THE GIVEN EXTENSION
Command traverseFolderDetailed pFolder, pExt
   local tFileA, tFileName, tFilePath, tFolderPath, tCreationDateSeconds, x, tPath
   set the defaultFolder to pFolder
   put the number of elements of sFilePathA into x
   
   put the detailed files into tFileA
   repeat for each line tFile in tFileA
      set the itemDelimiter to ","
      put URLDecode(tFile) into tFile
      put the first item of tFile into tFileName
      if the first char of tFile is not "." then 
         add 1 to x
         put the defaultFolder & fDelimiter() & tFileName into tFilePath
         set the itemDelimiter to "."
         if the last item of tFileName = pExt then
            put tFilePath into sFilePathA[x]["File Path"]
            ----------
            set the itemDelimiter to ","
            put item 4 of tFile into tCreationDateSeconds
            convert tCreationDateSeconds to short system date
            put tCreationDateSeconds into sFilePathA[x]["Creation Date"]
            ----------
         end if
      end if
   end repeat
   
   repeat for each line tFolder in the folders //recursion
      if "." is not in tFolder then
         put pFolder & fDelimiter() & tFolder into tPath
         traverseFolderDetailed tPath, pExt
      end if
   end repeat
   -- breakpoint
end traverseFolderDetailed
---=======================   END RECURSIVE FILEPATH ARRAY  =============================---


/// PURPOSE: RETURN A PATH DELIMITER APPROPRIATE FOR OS 
function fDelimiter
   if the platform is "Win32" then 
      return backslash
   else
      return slash
   end if
end fDelimiter

/// PURPOSE: RETURN 'TITLECASE' - EACH WORD CAPITALISED
function titleCase pText
   local tPhrase, tTemp
   put pText into tPhrase
   
   repeat for each word tWord in tPhrase
      put toUpper(char 1 of word 1 of tWord) into tTemp
      put toLower(char 2 to -1 of word 1 of tWord) after tTemp
      replace tWord with tTemp in tPhrase
   end repeat
   return tPhrase
end titleCase

/// PURPOSE: CONFIRM SCRIPT-ONLY STACK LOADED (DEV ONLY)
command sanityCheck
   Put "GeneralAlgorithms loaded!"
end sanityCheck

/// PURPOSE: TERNARY OPERATOR
function iif theArg1,theValue1,theValue2 
   if value(theArg1) then
      return theValue1
   else 
      return theValue2
   end if
end iif
