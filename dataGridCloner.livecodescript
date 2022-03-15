script "dataGridCloner"
local sSourceA, sDestinationA, sDestinationCard

command setSource pLongID
    if not _isDataGrid(pLongID) then return "Error - Source is not a data grid!"
    if pLongID is empty then exit to top
    put pLongID into sSourceA["longID"]
    put the dgProp["row template"] of sSourceA["longID"] into sSourceA["rowTemplate"]
    set the itemDel to " of "
    put item -1 of sSourceA["longID"] into sSourceA["mainstack"]
    put item -1 of sSourceA["rowTemplate"] into sSourceA["dgStack"]
    put item -2 of sSourceA["rowTemplate"] into sSourceA["dgCard"]
end setSource

command setDestination pLongID
    if not _isDataGrid(pLongID) then return "Error - Destination is not a data grid!"
    if pLongID is empty then exit to top
    put pLongID into sDestinationA["longID"]
    put the dgProp["row template"] of sDestinationA["longID"] into sDestinationA["rowTemplate"]
    set the itemDel to " of "
    put item -1 of sDestinationA["longID"] into sDestinationA["mainstack"]
    put item -1 of sDestinationA["rowTemplate"] into sDestinationA["dgStack"]
    put item -2 of sDestinationA["rowTemplate"] into sDestinationA["dgCard"]
end setDestination

set setDestinationCard pLongID
	put pLongID into sDestinationCard
end setDestinationCard

function getSource
    return sSourceA
end getSource

function getDestination
    return sDestinationA
end getDestination

function getDestinationCard
	return sDestinationCard
end getDestinationCard

command clearGridData
    put empty into sSourceA
    put empty into sDestinationA
	put empty into sDestinationCard
end clearGridData

command cloneGrid
    local tPropList, tNewDGStack, tProp
    
    if sSourceA is empty or sDestinationA is empty then
        return "error - source or destination not set"
        exit to top
    end if    
    
    set the properties of sDestinationA["longID"] to the properties of sSourceA["longID"]
    set the customProperties["dgProps"] of sDestinationA["longID"] to the customProperties["dgProps"] of sSourceA["longID"]
    //missing dpProps - see https://quality.livecode.com/show_bug.cgi?id=23614
    put "edit mode action control,edit mode action select control,edit mode reorder control,left swipe control,right swipe control,row template" into tPropList
    repeat for each item tItem in tPropList
        set the dgProp[tItem] of sDestinationA["longID"] to the dgProp[tItem] of sSourceA["longID"]
    end repeat
    
    if sSourceA["mainstack"] <> sDestinationA["mainstack"] then 
        if there is a stack(the short name of sSourceA["dgStack"] & "a")  then delete stack(the short name of sSourceA["dgStack"] & "a")
        clone invisible stack sSourceA["dgStack"]
        put the long id of it into tNewDGStack
        set the mainstack of tNewDGStack to sDestinationA["mainstack"]
        set the name of tNewDGStack to the short name of sSourceA["dgStack"] & "a"
        
        repeat for each item tItem in tPropList
            put the dgProp[tItem] of sDestinationA["longID"] into tProp
            put "a" after char -2 of tProp
            set the dgProp[tItem] of sDestinationA["longID"] to tProp
        end repeat
    end if

end cloneGrid

on copyGrid
    local tNewDGStack
    copy sSourceA["longID"] to (field "destinationCard")
    setDestination it
    if sSourceA["mainstack"] <> sDestinationA["mainstack"] then
        if there is a stack(the short name of sSourceA["dgStack"] & "a")  then delete stack(the short name of sSourceA["dgStack"] & "a")
        clone invisible stack sSourceA["dgStack"]
        put the long id of it into tNewDGStack
        set the mainstack of tNewDGStack to sDestinationA["mainstack"]
        set the name of tNewDGStack to the short name of sSourceA["dgStack"] & "a"
        
        local tProp, tPropList
        put "edit mode action control,edit mode action select control,edit mode reorder control," into tPropList
        put "left swipe control,right swipe control,row template" after tPropList
        repeat for each item tItem in tPropList
            put the dgProp[tItem] of sDestinationA["longID"] into tProp
            put "a" after char -2 of tProp
            set the dgProp[tItem] of sDestinationA["longID"] to tProp
        end repeat
    end if
    clearData
end copyGrid

on copyTemplateCard
    local tID
    copy card (sSourceA["dgCard"]) of stack (sSourceA["dgStack"]) to stack (sDestinationA["dgStack"])
    put the long ID of it into tID
    breakpoint
end copyTemplateCard

on copyGridData
    --    dispatch "ResetList" to sDestinationA["longID"]
    set the dgText of sDestinationA["longID"]  to the dgText of sSourceA["longID"]
end copyGridData


private function _isDataGrid pLongID
    if the customProperties["dgProps"] of pLongID is empty then
        return false
    else
        return true
    end if
end _isDataGrid

# missing dgProps - see https://quality.livecode.com/show_bug.cgi?id=23614
/* +/- 'effective' when these dgProps set to empty
text color
text font
text size
text style
visible columns
*/
# formats
/*
group id 2209 of card id 1002 of stack "sourceStack"
group id 1006 of card id 1005 of stack "Data Grid Templates 1646937524257"
*/
# dgProps to change:
/*
edit mode action control      group id 1010 of card id 1005 of stack "Data Grid Templates 1646962961180a"
edit mode action select control      group id 1012 of card id 1005 of stack "Data Grid Templates 1646962961180a"
edit mode reorder control      group id 1014 of card id 1005 of stack "Data Grid Templates 1646962961180a"
left swipe control      group id 1016 of card id 1005 of stack "Data Grid Templates 1646962961180a"
right swipe control      group id 1019 of card id 1005 of stack "Data Grid Templates 1646962961180a"
row template      group id 1006 of card id 1005 of stack "Data Grid Templates 1646962961180a"
*/
