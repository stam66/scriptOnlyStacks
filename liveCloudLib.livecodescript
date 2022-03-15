script "liveCloudLib"
global gUsersA

command resetPasswordForUsername pUsername, pProjectName, pFromEmail, pFromName
    # PURPOSE : mechanism for user-actioned password reset.  Assumes there is  a key 'username' added to cdbUsers
    # Also requires a function getEmailForUsername(pUsername) - listed below
    # Emails confirmation to user and if proceeds, resets to a random string password, emailed to user
    local tInputA, tInternalA
    if pUsername is empty then
        Answer "You must provide a username..."
        exit resetPasswordForUsername
    end if
    /////////////////////////////////////
    cdbi_forgotUserAccountPassword getEmailForUsername(pUsername), pProjectName, pFromEmail, pFromName
    /////////////////////////////////////
    if not cdb_result() then
        answer "Failed to reset password:" && cdb_result("response")
        exit resetPasswordForUsername
    else
        answer "An email has been sent to the email address linked with this username. Please check this email account for instuctions to complete the reset."
    end if
end resetPasswordForUsername

function getEmailForUsername pUsername
    # PURPOSE : return email for username
    # REQUIRES : global array gUsersA containg the cdbUsers table
    local tArray
    filter elements of gUsersA where each["username"] = pUsername into tArray
    return tArray[the keys of tArray]["email"]
end getEmailForUsername

function getPrivilegeSet pUsername
    # PURPOSE : return prvilegeSet for username
    local tArray
    filter elements of gUsersA where each["username"] = pUsername into tArray
    return tArray[the keys of tArray]["privilegeSet"]
end getPrivilegeSet

function getCdbRecordIDForUsername pUsername
    # PURPOSE : get a user's cdbRecordID (ie from cdbUsers) corresponding to a userName
    repeat for each element tElement in gUsersA
        if tElement["username"] = pUsername then
            return tElement["cdb"]["cdbRecordID"]
        end if
    end repeat
end getCdbRecordIDForUsername
