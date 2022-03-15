script "liveCloudLib"
global gCDBAuthKey, gLibPath

on preOpenStack
    initialiseCloud
end preOpenStack

function returnLibPath
    local tPath
    put the filename of stack "liveCloud" into tPath
    set the itemDelimiter to slash
    delete the last item of tPath
    return tPath & slash
end returnLibPath

on initialiseCloud
    if gLibPath is empty then put returnLibPath() into gLibPath
    initializeCanelaDB
end initialiseCloud



command initializeCanelaDB
    local tLibraryPath
    put "3570fb24fcc64174ba1f935998f1d98d" into gCDBAuthKey
    set the itemDel to "/"
    wait 0 milliseconds with messages ## GIVE THE ENGINE A CHANCE TO SPIN UP
    put gLibPath into tLibraryPath
    
    --START CanelaDB
    csi_verifyLibraries tLibraryPath
    
    try
        start using stack (tLibraryPath & "CDB_Header.lib")
        start using stack (tLibraryPath & "CDB_Starter.lib")
    catch tError
        answer "We encountered an error while initializing CanelaDB:" && tError
        exit to top
    end try
    
    --SET OPTIONAL LOGGING MODE
    cdb_SetLogMode "message box"
    
    --LOAD INTERNAL CACHING TABLE
    cdb_loadTable "cdbCache"
end initializeCanelaDB


command csi_verifyLibraries pPath
    local tData, tHashed, tPath, tStackNames
    
    put pPath into tPath
    put files(tPath) into tStackNames
    filter tStackNames without ".*"
    filter tStackNames without empty
    
    repeat for each line xStackName in tStackNames
        switch
            case xStackName = "CDB_Starter.lib"
                put url ("binfile:" & tPath & xStackName) into tData
                put base64Encode(md5Digest(tData)) into tHashed
                if tHashed <> "sSXn9bnfj0oLsfFz5qbBhw==" then
                    throw "Error, CDB_Starter checksum did not match."
                end if
                break
                
            case xStackName = "CDB_Header.lib"
                put url ("binfile:" & tPath & xStackName) into tData
                put base64Encode(md5Digest(tData)) into tHashed
                if tHashed <> "nkmsEqZbgfsQJqqCUvJbJw==" then
                    throw "Error, CDB_Header checksum did not match."
                end if
                break
        end switch
    end repeat
end csi_verifyLibraries
