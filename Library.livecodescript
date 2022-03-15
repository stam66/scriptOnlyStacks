script "Library"
function getStackVersion
    # PURPOSE : reads the custom prop stackVersion of the stack. This is in format: majorVersion.minorVersion.RCversion.betaVersion
    # If in beta, RVversion should be 0. If in RC, beta version should be 0. Will return string such as "1.1 RC4," or "0.9 b1"
    local tNumVersion, tTextVersion
    put the stackVersion of me into tNumVersion
    set the itemdelimiter to "."
    put item 1 of tNumVersion into item 1 of tTextVersion
    put item 2 of tNumVersion into item 2 of tTextVersion
    if item 3 of tNumVersion > 0 then 
        put " RC" & item 3 of tNumVersion after tTextVersion
    else if item 4 of tNumVersion > 0 then
        put " b" & item 4 of tNumVersion after tTextVersion
    end if
    return tTextVersion
end getStackVersion

function returnNumberedArray pArray
    # PURPOSE : returns a numerically keyed version of the array provided
    local x, tArray
    repeat for each element tElement in pArray
        add 1 to x
        put tElement into tArray[x]
    end repeat
    return tArray
end returnNumberedArray

function getDateFromSQLDate pDate 
    # PURPOSE : Returns the SYSTEM DATE corresponding to the SQL date provided
    local tDate
    put replaceText(pDate, "-", ",") & ",0,0,0,0" after tDate
    convert tDate to system date
    return tDate
end getDateFromSQLDate

function getSQLDateFromDate pDate 
    # PURPOSE takes the system date provided and returns a SQLDate formated date
    local tDate
    convert pDate from system date to dateitems
    put replaceText(item 1 to 3 of pDate, ",", "-") into tDate
    return tDate
end getSQLDateFromDate

function getLVEF pEDV, pESV
    # PURPOSE : return LVEF for volumes, rounded to 2 decimals
    if pEDV is empty or pESV is empty then
        return ""
    else
        if pEDV > 10 and pESV > 10 then return round(100 * (pEDV-pESV)/pEDV, 2)
    end if
end getLVEF

function getLVSV pEDV, pESV
    # PURPOSE : return stroke volume for volumes
    if pEDV is empty or pESV is empty then
        return ""
    else
        if pEDV > 10 and pESV > 10 then return pEDV-pESV
    end if
end getLVSV

command filterGrid pFilter, pKey, pDataGrid, pDescriptor
    # PURPOSE : Generic datagid filtering. Assumes the whole data set is stored in the DG's 'allData' custom property. Also returns a 'count' using pDescriptor for text
    #pDataGrid =  long id of data grid. pDescriptor used for counts, pDescriptor = the item being counted (eg 'analyses', or 'studies') counts are in 'the result'
    local tDataA
    if pFilter is empty then 
        set the dgData of pDataGrid to the allData of pDataGrid
    else
        put the allData of pDataGrid into tDataA
        filter elements of tDataA where each[pKey] contains pFilter
        set the dgData of pDataGrid to tDataA
    end if
    return the number of lines of the dgText of pDataGrid && pDescriptor
end filterGrid

command filterGridWithKeyValue pGrid, pKey, pValue, pMode// pGrid = long id of data grid ; pMode = equal  | notEqual | match
    # PURPOSE : Generic data grid filter for qualitative matching (equal, not equa, contains)
    # PURPOSE : Generic datagid filtering. Assumes the whole data set is stored in the DG's 'allData' custom property. Also returns a 'count' using pDescriptor for text
    #pDataGrid =  long id of data grid. pDescriptor used for counts, pDescriptor = the item being counted (eg 'analyses', or 'studies') counts are in 'the result'
    -- TODO : Careful review prior to removing filterGrid. Probable overlap with 'filterGrid' which is likely a the subset 'match' of this command. 
    local tDataA
    put the allData of pGrid into tDataA
    if pMode = "notEqual" then
        filter elements of tDataA where each[pKey] <> pValue
    else if pMode = "equal" then
        filter elements of tDataA where each[pKey] = pValue
    else if pMode = "match" then
        filter elements of tDataA where each[pKey] contains pValue
    end if
    set the dgData of pGrid to tDataA
end filterGridWithKeyValue

command updateKeyInArray pArray, pKeyName, pOldValue, pNewValue
    #PURPOSE : Replace value in a key with a new value - eg update reader in gAnalysesA when reader's name is modified in gUsersA
    # finds all records with old value and then replaces old value with new value in found records, marks array element for update
    local tArray, tKeys
    dispatch "showMessage" to group "messageGroup" with "Updating local data..."
    filter elements of pArray where each[pKeyName] = pOldValue into tArray
    put the keys of tArray into tKeys
    repeat for each line tKey in tKeys
        put pNewValue into pArray[tKey][pKeyName]
        if pArray[tKey]["TODO"] <> "NEW" then put "UPDATE" into pArray[tKey]["TODO"]
    end repeat
    dispatch "hideMessage" to group "messageGroup"
end updateKeyInArray

function getRandomPassword pLength
    # PURPOSE : returns random string of pLength chars containg upper and/or lower case chars
    local tPass, temp, x
    repeat while x < pLength
        put random(122) into temp
        if (temp > 47  and temp < 58) or (temp > 64 and temp < 91) or (temp > 96 and temp < 123) then
            add 1 to x
            put numToCodepoint(temp) after tPass
        end if
    end repeat
    return tPass
end getRandomPassword

function isValidEmailFormat pEmail
    # PURPOSE : returns boolean describing valilidty of  email provided
    return matchText(pEmail,"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
end isValidEmailFormat

function sortArray @pArray, pDirection, pSortType, pKey, pUseSystemDate
    # PURPOSE : Returns a numerical indexed array with with the sort order requested. See notes below.
    /*
    - only pArray is mandatory, other params can be passed as ‘empty’ or “”
    - permissible values for pDirection are: ascending, descending or empty
    - permissible values for pSortType are: international, numeric, datetime, text, binary or empty
    - if pDirection is passed as “” or ‘empty’, it will default to ascending
    - if pSortType is passed as “” or ‘empty’ it will default to text
    - passing pKey as “” or empty will treat the array as a 1-dimensional array, passing the name of the key will sort it as a multidimensional array
    - passing empty pUseSystemDate will default to false / / US date format
    */
    local tNextIndex, tSortedArray, tSortText
    get the keys of pArray
    if pUseSystemDate is not empty then set the useSystemDate to pUseSystemDate
    put "sort lines of it [[pDirection]] [[pSortType]] by pArray[each]" into tSortText //1-dimensional array
    if pKey is not empty then put "[pKey]" after tSortText //multidimensional array
    do merge(tSortText)
    repeat for each line tKey in it
        add 1 to tNextIndex
        put pArray[tKey] into tSortedArray[tNextIndex]
    end repeat
    return tSortedArray
end sortArray

function getTitleCase pText
    local tText
    repeat with x = 1 to the number of words in pText
        put toUpper(char 1 of word x of pText) into char 1 of word x of pText
    end repeat
    return pText
end getTitleCase

