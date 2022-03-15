script "MDM model"
global gAllData
-------------------------------------------------------------------------------------------
--> populate dashboard data grids <--
-------------------------------------------------------------------------------------------
function getAllDates     # returns dates as array including number of cases and if presentation
    return sortArray(gAllData["dashboard"], "descending", "datetime", "mdmDate", "true")
end getAllDates

function getCasesForDate pDate
    # returns cases for selcted date - note that his includes all mdm data and primary key for patient data
    local tDataA
    filter elements of  gAllData["mdm"]  where each["mdmDate"] = pDate into tDataA
    return tDataA
end getCasesForDate

function getRecordForID pTable, pID // the cdbRecordID
    # PURPOSE : retrieve a record frm the global array gAllData, passing the table gAllData[<tableName>]  and the unique ID stored in gAllData[<tableName>]["cdb"]["cdbRecordID"]
    # RETURNS : sub-array  with all record data,  indexed with the index in gAllData[<tableName>], eg gAllData["patients"][123][{array}] -> [123][{array}] 
    local tDataA
    filter elements of gAllData[pTable] where each["cdb"]["cdbRecordID"] = pID into tDataA
    return tDataA
end getRecordForID

function getSubArrayForKey pTable, pKey, pValue // attempt to generalise the above
    local tDataA
    filter elements of gAllData[pTable] where each [pKey] = pValue into tDataA
    return tDataA
end getSubArrayForKey

command populateAttendeeListForDateIndex pIndex
    local tDataA
    put the dgDataOfIndex[pIndex] of group "dates" into tDataA
    set the dgText of group "attendees" of me to tDataA["attendeesKeyList"]
end populateAttendeeListForDateIndex

function getUnlistedAttendees // list IDs of attendees not added to attendee list already
    local tAttendeesA, tList, tUnaddedList
    put gAllData["attendees"] into tAttendeesA
    put the dgText of group "attendees" into tList
    repeat for each element tElement in tAttendeesA
        if tElement["cdb"]["cdbRecordID"] is not in tList then put tElement["cdb"]["cdbRecordID"] & return after tUnaddedList
    end repeat
    delete the last char of tUnaddedList
    return tUnaddedList
end getUnlistedAttendees
-------------------------------------------------------------------------------------------
--> end <--
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
--> get/set field in the editAttendeePopover group (Dashboard) <--
-------------------------------------------------------------------------------------------
on populateAttendeeFields pID
    local tDataA
    if pID is empty then exit populateAttendeeFields
    put getRecordForID("attendees", pID)  into tDataA
    set the label of button "salutation" of group "editAttendeePopover" to tDataA[the keys of tDataA]["salutation"]
    set the text of field "firstName" of group "editAttendeePopover" to tDataA[the keys of tDataA]["firstName"]
    set the text of field "lastName" of group "editAttendeePopover" to tDataA[the keys of tDataA]["lastName"]
    set the text of field "title" of group "editAttendeePopover" to tDataA[the keys of tDataA]["title"]
end  populateAttendeeFields

on updateAttendeeFields
    local tCdbRecordID, tDataA
    if tDataA is empty then exit updateAttendeeFields
    put gAllData["attendees"][the keys of tDataA]["cdb"]["cdbRecordID"] into tCdbRecordID
    put the label of button "salutation" of group "editAttendeePopover" into gAllData["attendees"][the keys of tDataA]["salutation"]
    put field "firstName" of group "editAttendeePopover" into gAllData["attendees"][the keys of tDataA]["firstName"]
    put field "lastName" of group "editAttendeePopover" into gAllData["attendees"][the keys of tDataA]["lastName"]
    put field "title" of group "editAttendeePopover" into gAllData["attendees"][the keys of tDataA]["title"]
    put "UPDATE" into gAllData["attendees"][the keys of tDataA]["TODO"]
    populateAttendeeListForDateIndex the dgHilitedIndex of group "dates"
end updateAttendeeFields
-------------------------------------------------------------------------------------------
--> end <--
-------------------------------------------------------------------------------------------
