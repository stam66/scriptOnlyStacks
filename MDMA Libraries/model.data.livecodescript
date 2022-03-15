script "model.data"
global gAllData, gUsersA
/*
intention is to have this in binary stack as will contain secure information
purpose is simply to put all of cloud data into a global arrayy
*/

on preOpenStack
   start using stack "controller.utilities"
end preOpenStack


command getAllUsers // data model
   cdb_setLogMode "ignore"
   get cdb_auth("stam66@icloud.com", "globalPasswordForMDMA", "user")
   showMessage "Initialising cloud data..."
   put getUsers("mdma") into gUsersA
end getAllUsers // data model



private command _initialiseApp // app controller
   checkInternetConnectivity
   getAllUsers
end _initialiseApp
