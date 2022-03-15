global gCurrentUserA, gUsersA, gSubjectsA, gCentresA, gAnalysesA
local sAnalysisID, sLoadingFromSaved # sAnalysisID holds the cdbRecordID for cloud db | sLoadingFromSaved prevents updates while loading saved record.

on mouseDown
    # PURPOSE : Hide popup elements on mouseDown in card
    if the mouseLoc is not within the rect of group "scorePopup" then hide group "scorePopup"
    if the visible of widget "Calendar" of me and the mouseLoc is not within the rect of widget "Calendar" of me then
        hide widget "Calendar" of me
    end if
    repeat with x = 1 to the number of groups of this card
        if the short name of group x of this card contains "popover" then hide group x of this card
    end repeat
end mouseDown

on escapeKey
    # PURPOSE : Hide popup elements on escape
    hide widget "Calendar"
    hide group "scorePopup"
    repeat with x = 1 to the number of groups of this card
        if the short name of group x of this card contains "popover" then hide group x of this card
    end repeat
end escapeKey

command setID pCdbRecordID
    set the analysisID of me to pCdbRecordID
    put pCdbRecordID into sAnalysisID
end setID

command setLoadingState pState
    if pState then 
        put true into sLoadingFromSaved
    else
        put false into sLoadingFromSaved
    end if
end setLoadingState

setProp analysisID pCdbRecordID
    showDataForAnalysisID pCdbRecordID
    pass analysisID
end analysisID

on closeCard
    # PURPOSE :  Push changes to cloud then reset interface on this card
    if  cdb_loggedInUser() is not empty then flushDB   
    wait 0 milliseconds with messages
    pass closeCard
end closeCard

on preOpenCard
    show group "menuUserForAdmin"
    revUpdateGeometry
end preOpenCard

on openCard
    # PURPOSE : load data for analysis. If no analysis id specified report error. 
    # if admin status then allow editing of reader and analysis id
    if sAnalysisID is empty then
        --        answer "Data could not be displayed"
    else
        showDataForAnalysisID sAnalysisID
    end if
    if gCurrentUserA["privilegeSet"] = "admin" then
        set the lockText of field "reader" to false
        set the lockText of field "randomisedID" to false
    else
        set the lockText of field "reader" to true
        set the lockText of field "randomisedID" to true
    end if
end openCard

command showDataForAnalysisID pCdbRecordID
    # PURPOSE : reads the data from gAnalysisA that has the cdbRecordID pCdbRecordID
    local tScoreList, tData
    lock screen
    put true into sLoadingFromSaved
    // get data
    filter elements of gAnalysesA where each["cdb"]["cdbRecordID"] = pCdbRecordID into tData
    put tData[the keys of tData] into tData
    put tData["kf_study"] into field "randomisedID" of me
    put tData["reader"] into field "reader" of me
    // Analysis
    set the hilitedItemNames of widget "status" of group "statusGroup" of me to tData["status"]
    wait 10 milliseconds with messages
    put tData["completionDate"] into field "completionDate" of of group "statusGroup" of me
    put tData["reader"] into field "reader" of me
    put tData["kf_study"] into field "randomisedID" of me
    // Function
    put tData["LVEDV"] into field "LVEDV" of group "measurementsGroup" of me
    put tData["LVESV"] into field "LVESV" of group "measurementsGroup" of me
    put tData["GLS"] into field "GLS" of group "measurementsGroup" of me
    put tData["TAPSE"] into field "TAPSE" of group "measurementsGroup" of me
    put getLVEF(tData["LVEDV"], tData["LVESV"]) into field "LVEF" of group "measurementsGroup" of me
    put getLVSV(tData["LVEDV"], tData["LVESV"]) into field "LVSV" of group "measurementsGroup" of me
    set the hilitedItems of widget "severityLV" of group "measurementsGroup" of me to tData["severityLV"]
    // General
    set the hilitedItemNames of widget "quality2D" of group "measurementsGroup" of me to tData["quality2D"]
    set the hilite of button "contrast" of group "measurementsGroup" of me to (tData["contrast"] = 1)
    set the hilitedItemNames of widget "rhythm" of group "measurementsGroup" of me to tData["rhythm"]
    // Valves
    put tData["VC"] into field "vc" of group "measurementsGroup" of me
    put tData["TRvmax"] into field "TRVmax" of group "measurementsGroup" of me
    put tData["LVOTd"] into field "LVOTd" of group "measurementsGroup" of me
    put tData["LVOTv"] into field "LVOTv" of group "measurementsGroup" of me
    set the hilitedItemNames of widget "qualityMR" of group "measurementsGroup" of me to tData["qualityMR"]
    set the hilitedItems of widget "severityMR" of group "measurementsGroup" of me to tData["severityMR"]
    // Segmental
    repeat with x = 1 to 16
        put tData["seg" & x] into item x of tScoreList
    end repeat
    dispatch "batchPopulateSegments" to group "bullseye" of me with tScoreList
    put false into sLoadingFromSaved
end showDataForAnalysisID

function isLoadingSavedData
    return (sLoadingFromSaved = true)
end isLoadingSavedData


command updateAnalysisData 
    # PURPOSE : updates gAnalysisA if sLoadingFromSaved is false and marks the array element as needing update on cloud
    local tIndex, tArray, tSegmentsA, tState
    put sLoadingFromSaved into tState
    if sLoadingFromSaved then exit updateAnalysisData // do not update any databases if just loading saved data
    // 
    filter elements of gAnalysesA where each["cdb"]["cdbRecordID"] = sAnalysisID into tArray
    put the keys of tArray into tIndex
    put field "reader" into gAnalysesA[tIndex]["reader"]
    // Analysis
    if the hilitedItemNames of widget "status" of group "statusGroup" of card "analysis"= "Not Started" and the clickLoc is not within the rect of widget "status" then \
          set the hilitedItemNames of widget "status" of group "statusGroup" of card "analysis" to "In Progress"
    put the hilitedItemNames of widget "status" of group "statusGroup" of card "analysis" into gAnalysesA[tIndex]["Status"]
    put field "completionDate" into gAnalysesA[tIndex]["completionDate"]
    // Function
    put field "LVEDV" into gAnalysesA[tIndex]["LVEDV"]
    put field "LVESV" into gAnalysesA[tIndex]["LVESV"]
    put field "GLS" into gAnalysesA[tIndex]["GLS"]
    put field "TAPSE" into gAnalysesA[tIndex]["TAPSE"]
    put field "LVEF" into gAnalysesA[tIndex]["LVEF"]
    put field "LVSV" into gAnalysesA[tIndex]["LVSV"]
    // General
    if the hilite of button "contrast" then put 1 into gAnalysesA[tIndex]["contrast"]
    else put 0 into gAnalysesA[tIndex]["contrast"]
    put the hilitedItemNames of widget "quality2D" into gAnalysesA[tIndex]["quality2D"]
    put the hilitedItemNames of widget "rhythm" into gAnalysesA[tIndex]["rhythm"]
    // Valves
    put the hilitedItemNames of widget "qualityMR" into gAnalysesA[tIndex]["qualityMR"]
    put the hilitedItems of widget "severityMR" into gAnalysesA[tIndex]["severityMR"]
    put field "vc" into gAnalysesA[tIndex]["vc"]
    put field "TRVmax" into gAnalysesA[tIndex]["TRvmax"]
    put field "LVOTd" into gAnalysesA[tIndex]["LVOTd"]
    put field "LVOTv" into gAnalysesA[tIndex]["LVOTv"]
    // Segmetnal
    put the uSegments of group "bullseye" into tSegmentsA
    repeat with x = 1 to 16
        put tSegmentsA[x]["score"] into gAnalysesA[tIndex]["seg" & x] 
    end repeat  
    put field "LVEFbyWMSI1" into gAnalysesA[tIndex]["LVEFbyWMSI1"]
    put field "LVEFbyWMSI2" into gAnalysesA[tIndex]["LVEFbyWMSI2"]
    put field "WMSI" into gAnalysesA[tIndex]["WMSI"]
    // mark for update
    if gAnalysesA[tIndex]["TODO"] <> "NEW" then put "UPDATE" into gAnalysesA[tIndex]["TODO"]
    dispatch "showState" to group "cloudSyncGroup" of me with "cloudNotSynced"
end updateAnalysisData

command resetAnalysisData bReset 
    # PURPOSE : reset all fields to blank state
    # bReset: If true, resets data for current record; does not alter StudyID, reader or sAnalysisID(which is the cdbRecordID for the analysis)
    # bReset: if false, blanks all fields  & sAnalysisID
    local tScoreList, tState
    put sLoadingFromSaved into tState
    put true into sLoadingFromSaved // prevent DB updates
    // identifying data 
    if not bReset then
        put empty into sAnalysisID
        put empty into field "randomisedID"
        put empty into field "reader"
        set the hilitedItemNames of widget "status" to empty // resetting screen for next use
    end if
    set the hilitedItemNames of widget "status" to "Not Started" 
    // general
    put empty into field "completiondate"
    set the hilite of button "contrast" to false
    set the hilitedItemNames of widget "Quality2D" to empty
    set the hilitedItemNames of widget "rhythm" to empty
    //LV
    set the hilitedItemNames of widget "severityLV" to empty
    put empty into field "lvedv"
    put empty into field "lvesv"
    put empty into field "lvsv"
    put empty into field "LVEF"
    put empty into field "gls"
    dispatch "initBullseyeCustomProps" to group "bullseye"
    //valves
    set the hilitedItemNames of widget "QualityMR" to empty
    set the hilitedItemNames of widget "severityMR" to empty
    put empty into field "vc"
    put empty into field "lvotd"
    put empty into field "lvotv"
    put empty into field "tapse"
    put empty into field "trvmax"
    //
    put tState into sLoadingFromSaved
end resetAnalysisData

command updateAnalysedCount
    # PURPOSE : increment or decrement <stage>Analysed key in gSubjectsA for this subject. Value cannot go below 0
    # <stage>Analysed is incremented every time an analysis for this stage of this subejct is marked as 'completed'
    local tIndex, tStage, tIncrement, tIdentifier
    put char 1 to -2 of field "randomisedID" into tIdentifier
    put getSubjectIndexForIdentifier(tIdentifier) into tIndex
    put getStageForID(field "randomisedID") into tStage
    if the visible of field "completionDate" then 
        put 1 into tIncrement
    else
        put -1 into tIncrement
    end if
    put gSubjectsA[tIndex][tStage & "Analysed"] + tIncrement into gSubjectsA[tIndex][tStage & "Analysed"]
    if gSubjectsA[tIndex][tStage & "Analysed"] < 0 then put 0 into gSubjectsA[tIndex][tStage & "Analysed"]
    
    if  gSubjectsA[tIndex]["TODO"] <> "NEW" then put "UPDATE" into gSubjectsA[tIndex]["TODO"]
    dispatch "showState" to group "cloudSyncGroup" with "cloudNotSynced"
end updateAnalysedCount


on closeStackRequest 
    answer "Quit application?" with "No" or "Quit"
    if it is "Quit" then 
        if the environment is not "development" then quit
        pass closeStackRequest
    end if
end closeStackRequest

