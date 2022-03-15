script "controller.app"

local sCanelaPath, sLibPath, sDevPath

on preOpenStack
	get getDevPath()
	get getCanelaLibPath()
	get getProjectLibPath()
	get getLibraryPath() --> run last, as requires getDevPath()

	start using stack(sLibPath & "/MDMA Libraries/controller.utilities.livecodescript")
	start using stack(sLibPath & "/MDMA Libraries/model.dashboard.livecodescript")
	start using stack(sLibPath & "/MDMA Libraries/model.mdm.livecodescript")
	start using stack(sLibPath & "/MDMA Libraries/model.patients.livecodescript")
	start using stack(sLibPath & "/MDMA Libraries/model.data.livecodescript")
	start using stack(sLibPath & "skLib")

end preOpenStack


--> get location of script only stacks in dev environment
function getDevPath
	put specialFolderPath("documents") & "/Developer/scriptOnlyStacks/" into sDevPath
	return sDevPath
end getDevPath

--> get location of canela files. For this project they should be stored in /Documents/<short nmame>/CanelaDB/Libraries
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

--> get location of lib files; if dev then return getDevPath() otherwise point to Resources/Library for standalones
function getLibraryPath
	if the environment is "development" then
		put sDevPath into sLibPath
	else
		put specialFolderPath("resources") & "/Libraries/" into sLibPath
	end if
	return sLibPath
end getLibraryPath

function getUserProjectLibPath
	local tPath
	if the environment is "development" then

	else
		put item 1 to - 3 of getCanelaLibPath() into tPath
		return tPath & "/Libraries"
	end if
end getUserProjectLibPath

