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

/// PURPOSE: RETURN AGE AT CURRENT DATE OR OPTIONALLY AT A DIFFERENT DATE
function getAge pDOB, pOptionalEndDate
   local  tDobMonth, tDobDay, tDobYear, tEndMonth, tEndDay,  tEndYear, tAgeInYears
   if pDOB is empty then exit getAge
   set the itemDelimiter to "/"
   put item 1 of pDOB into tDobDay
   put item 2 of pDOB into tDobMonth
   put item 3 of pDOB into tDobYear

   if pOptionalEndDate is empty then
      set the itemDelimiter to ","
      convert the seconds to dateItems
      put item 1 of it into tEndYear
      put item 2 of it into tEndMonth
      put item 3 of it into tEndDay
   else
      put item 1 of pOptionalEndDate into tEndDay
      put item 2 of pOptionalEndDate into tEndMonth
      put item 3 of pOptionalEndDate into tEndYear
      set the itemDelimiter to ","
   end if

   put tEndYear - tDobYear into tAgeInYears
   if ( tEndMonth < tDobMonth) or ((tEndMonth = tDobMonth) and (tEndDay < tDobDay)) then subtract 1 from tAgeInYears

   return tAgeInYears
end getAge

//PURPOSE: GET RBG TRIPLET FROM COLOR NAME/CONSTANT
/*taken from: https://lessons.livecode.com/m/2592/l/125746-translating-a-color-name-to-an-rgb-numeric-triplet*/
function RGBFromColorName pColorName
   local tRGBColor
   if pColorName is not a color then return "Error: not a color"
   create invisible button
   if the result is not empty then return "Error"
   set the backgroundColor of last button to pColorName
   set the foregroundColor of last button to pColorName
   set the backgroundPixel of last button to the backgroundPixel of last button
   put the backgroundColor of last button into tRGBColor
   delete last button
   send "choose browse tool" to me in 10 milliseconds
   return tRGBColor
end RGBFromColorName

//PURPOSE: INVERT A COLOUR
/*Takes an RGB triplet and returns the inverse*/
function invertColor pRGBColor
   local tR, tG, tB, tInvR, tInvG, tInvB, tInvertedColor
   put item 1 of pRGBColor into tR
   put item 2 of pRGBColor into tG
   put item 3 of pRGBColor into tB
   put 255- tR into tInvR
   put 255 - tG into tInvG
   put 255 - tB into tInvB
   put tInvR into item 1 of tInvertedColor
   put tInvG into item 2 of tInvertedColor
   put tInvB into item 3 of tInvertedColor
   return tInvertedColor
end invertColor

//PURPOSE: DETERMINES IF COLOUR IS LIGHT OR DARK AND RETURNS THE APPROPRIATE TEXT COLOUR (IE DARK BG -> WHITE TEXT, LIGHT GB ->BLACK TEXT )
/*convert RBG to YIQ, which takes into account visual impact of each channel
inspired by https://24ways.org/2010/calculating-color-contrast/
see also https://en.wikipedia.org/wiki/YIQ  */
function getContrastYIQ pRGBtriplet //
   local tR, tG, tB, YIQ
   put item 1 of pRGBtriplet into tR
   put item 2 of pRGBtriplet into tG
   put item 3 of pRGBtriplet into tB
   put ((tR * 299) + (tG * 587) + (tB * 114))/1000 into YIQ
   return iif(YIQ >= 128, "Black", "White")
   --   if YIQ >= 128 then  //light colour
   --      return "black"
   --   else //dark colour
   --      return "white"
   --   end if
end getContrastYIQ

function getPropsForObject pObject//long id
   local myArray
   put the properties of pObject into myArray
   combine myArray using return and ": "
   return myArray
end getPropsForObject

//PURPOSE: sort 1-dimentional and multidimensional arrays by any sortDirectiona and sortType
/*
Accepted sortDirection params: Ascending, Descending, or empty (-> defaults Ascending)
Accepted sortType params: International, Numeric, DateTime, Text, Binary, or empty (-> defaults to Text)
pass pKey as empty or "" to sort 1-dimensional array
 */
function sortArray @pArray, pDirection, pSortType, pKey
   local tNextIndex, tSortedArray, tSortText
   if (pDirection is not in "ascending,descending" and pDirection is not empty) or \
         ( pSortType is not in "international,numeric,datetime,text,binary" and pSortType is not empty) then
      answer "Malformed parameters - sortDirection must be either Ascending, Descending or empty." & return & \
            "sortType must be either 'international', 'numeric', 'datetime', 'text',  'binary' or empty."
      return pArray
   end if
   get the keys of pArray
   put "sort lines of IT [[pDirection]] [[pSortType]] by pArray[each]" into tSortText //1-dimensional array
   if pKey is not empty then put "[pKey]" after tSortText //mutidimensional array
   do merge(tSortText)
   repeat for each line tKey in IT
      add 1 to tNextIndex
      put pArray[tKey] into tSortedArray[tNextIndex]
   end repeat
   return tSortedArray
end sortArray
