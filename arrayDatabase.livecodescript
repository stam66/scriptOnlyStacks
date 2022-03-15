script "arrayDatabase"
local sArrayDatabase

function getArray
   if sArrayDatabase is empty then importTSVfolder //to be replaced by database access
   return sArrayDatabase
end getArray

function getDateList /* return dates[]*///DASHBOARD view
   get getArray()
   return sArrayDatabase["dashboard"]
end getDateList

function getDataForDate pDate /* return dataForDate[mdm], dataForDate[mdm][patient], dataForDate[attendees] */// DASHBOARD SELECTION view 
   local tData, dataForDate, x, temp
   //MDM data list for slected date
   put 0 into x
   put sArrayDatabase["MDMs"] into tData
   repeat for each element tElement in tData
      if  tElement["mdmDate"] = pDate then
         add 1 to x
         put tElement into dataForDate["mdm"][x]
         put getPatientWithID(tElement["kf_patient"]) into temp
         put temp["patient"] into dataForDate["mdm"][x]["patient"]
      end if
   end repeat
   
   //Attendee list for selected date
   put getAttendeesForDate(pDate) into dataForDate["attendees"]
   
   --   put 0 into x
   --   put sArrayDatabase["attendeesJoin"] into tData
   --   repeat for each element tElement in tData
   --      if  tData["date"] = pDate then
   --         put tElement into dataForDate["attendees"][x]
   --         put getAttendeeForID(tElement["kf_attendee"]) into dataForDate["attendees"][x]["attendee"]
   --      end if
   --end repeat
   
   return dataForDate
end getDataForDate

function getMdmArrayForDate pDate
   local tData, tArray, x
   //MDM data list for slected date
   put 0 into x
   put sArrayDatabase["MDMs"] into tData
   repeat for each element tElement in tData
      if  tData["mdmDate"] = pDate then
         add 1 to x
         put tElement into tArray["mdm"][x]
         put getPatientWithID(tElement["cdbRecordID"]) into tArray["mdm"][x]["patient"]
      end if
   end repeat
   return tArray //returns array of mdm's for date with sub-array of patient details for each mdm
end getMdmArrayForDate


function getMdmForMdmID pID /* return  mdmArray[mdm], mdmArray[patient], mdmArray[media], mdmArray[actionpoints], mdmArray[onward] *///MDM view 
   local tData, tArray
   put sArrayDatabase["MDMs"] into tData
   repeat for each element tElement in tData
      if tData["cdbRecordID"] = pID then
         put tElement into tArray["mdm"]
         exit repeat
      end if
   end repeat
   put getPatientWithID(tArray["kf_patient"]) into tArray["patient"]
   put getMediaForMdmID(tArray["mdm"]["cdbRecordID"]) into tArray["media"]
   put getActionPointsForMdmID(tArray["mdm"]["cdbRecordID"]) into tArray["actionPoints"]
   put getOnwardForMdmID (tArray["mdm"]["cdbRecordID"]) into tArray["onward"]
   return tArray
end getMdmForMdmID

function getPatientWithID pID /* return patientArray[patient], patientArray[mdmList] *///PATIENT view
   local tData, tPatientArray, x
   put sArrayDatabase["patients"] into tData
   repeat for each element tElement in tData
      if tElement["cdbRecordID"] = pID then
         put tElement into tPatientArray["patient"]
         exit repeat
      end if
   end repeat
   put 0 into x
   put sArrayDatabase["MDMs"] into tData
   repeat for each element tElement in tData
      if tElement["kf_patient"] = pID then
         add 1 to x
         put tElement into tPatientArray["mdmList"][x]
      end if
   end repeat
   return tPatientArray
end getPatientWithID

function getAttendeesForDate pDate
   local x, tData, tArray
   put 0 into x
   put sArrayDatabase["attendeeJoin"] into tData
   repeat for each element tElement in tData
      if  tElement["date"] = pDate then
         add 1 to x
         put tElement into tArray["attendees"][x]
         put getAttendeeForID(tElement["kf_attendee"]) into tArray["attendees"][x]["attendee"]
      end if
   end repeat
   return tArray //return array of join data with [attendee] for each join
end getAttendeesForDate

function getAttendeeForID pID /*return attendeeArray[] *///Attendee view
   local tData, tArray
   put sArrayDatabase["attendees"] into tData
   repeat for each element tElement in tData
      if tData["cdbRecordID"] = pID then
         put tElement into tArray
         exit repeat
      end if
   end repeat
   return tArray
end getAttendeeForID

function getActionPointsForMdmID pID
   local x, tData, tArray
   put sArrayDatabase["actionPoints"] into tData
   repeat for each element tElement in tData
      if tData["kf_mdm"] = pID then
         add 1 to x
         put tElement into tArray[x]
      end if
   end repeat
   return tArray
end getActionPointsForMdmID

function getOnwardForMdmID pID
   local x, tData, tArray
   put sArrayDatabase["onward"] into tData
   repeat for each element tElement in tData
      if tData["kf_mdm"] = pID then
         add 1 to x
         put tElement into tArray[x]
      end if
   end repeat
   return tArray
end getOnwardForMdmID

function getMediaForMdmID pID
   local x, tData, tArray
   put sArrayDatabase["media"] into tData
   repeat for each element tElement in tData
      if tData["kf_mdm"] = pID then
         add 1 to x
         put tElement into tArray[x]
      end if
   end repeat
   return tArray
end getMediaForMdmID

function getMediaForPatientID pID
   local x, tData, tArray
   put sArrayDatabase["media"] into tData
   repeat for each element tElement in tData
      if tData["kf_patient"] = pID then
         add 1 to x
         put tElement into tArray[x]
      end if
   end repeat
   return tArray
end getMediaForPatientID

command importTSVfolder
   local tFile, tFolder
   answer folder "Select the folder containing the .tab files..."
   if it is empty then exit importTSVfolder
   put it into tFolder
   //dashboard -- sorted by date in desc order
   put URL ("File:" & tFolder & fDelimiter() & "dashboard.tab") into tFile
   local newOrder, tCount, tDashboardSorted, tDashboard
   put _importTSVfile(tFile) into tDashboard
   get the keys of tDashboard
   set the useSystemDate to true
   sort lines of it descending datetime by tDashboard[each]["mdmDate"]
   put it into newOrder
   repeat for each line tLine in newOrder
      add 1 to tCount
      put tDashboard[tLine]["mdmDate"] into tDashboardSorted[tCount]["mdmDate"]
      put tDashboard[tLine]["aobText"] into tDashboardSorted[tCount]["aobText"]
      put tDashboard[tLine]["numberOfCases"] into tDashboardSorted[tCount]["numberOfCases"]
      put tDashboard[tLine]["hasPresentation"] into tDashboardSorted[tCount]["hasPresentation"]
      put tDashboard[tLine]["cdbRecordID"] into tDashboardSorted[tCount]["cdbRecordID"]
   end repeat
   put tDashboardSorted into sArrayDatabase["dashboard"]
   
   //patients
   put URL ("File:" & tFolder & fDelimiter() & "patients.tab") into tFile
   put _importTSVfile(tFile) into sArrayDatabase["patients"]
   //actionpoints
   put URL ("File:" & tFolder & fDelimiter() & "actionpoints.tab") into tFile
   put _importTSVfile(tFile) into sArrayDatabase["actionpoints"]
   //attendeesJoin
   put URL ("File:" & tFolder & fDelimiter() & "attendeesJoin.tab") into tFile
   put _importTSVfile(tFile) into sArrayDatabase["attendeeJoin"]
   //attendees
   put URL ("File:" & tFolder & fDelimiter() & "attendees.tab") into tFile
   put _importTSVfile(tFile) into sArrayDatabase["attendees"]
   //onward
   put URL ("File:" & tFolder & fDelimiter() & "onward.tab") into tFile
   put _importTSVfile(tFile) into sArrayDatabase["onward"]
   //media
   put URL ("File:" & tFolder & fDelimiter() & "media.tab") into tFile
   put _importTSVfile(tFile) into sArrayDatabase["media"]
   //mdm
   put URL ("File:" & tFolder & fDelimiter() & "mdm.tab") into tFile
   put _importTSVfile(tFile) into sArrayDatabase["MDMs"]
   //accounts
   put URL ("File:" & tFolder & fDelimiter() & "accounts.tab") into tFile
   put _importTSVfile(tFile) into sArrayDatabase["accounts"]
end importTSVfolder

private function _importTSVfile pFile
   local tFile, oldItemDelimiter, tKeys, tNumKeys, uBound, temp, tArray
   put pFile into tFile
   replace crlf with cr in tFile          -- Win to UNIX
   replace numtochar(13) with cr in tFile -- Mac to UNIX
   put the itemDelimiter into oldItemDelimiter
   set the itemDelimiter to tab
   
   put line 1 of tFile into tKeys
   filter tKeys without empty
   put the number of items of tKeys into tNumKeys
   put line 2 to -1 of tFile into tFile
   put the number of lines of tFile into uBound
   
   repeat with x = 1 to uBound
      repeat with y = 1 to tNumKeys
         put replaceText(item y of line x of tFile, "§", return) into temp
         put replaceText(temp, quote, "") into temp
         put temp into tArray[x][item y of tKeys ]
      end repeat
   end repeat
   set the itemDelimiter to oldItemDelimiter
   return tArray
end _importTSVfile
