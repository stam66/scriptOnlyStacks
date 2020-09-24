script "SQLITEDB"
////////// GLOBAL VARIABLES /////////
GLOBAL gDBName

////////// STACK VARIABLES /////////
LOCAL sDatabaseID, sDBPath

////////// SET UP DB LOCATION /////////
function dbPath
   if gDBName is empty then -- stored as global var, set in main stack for now
      answer "No database file name set." & return & "If a recurring issue please contact the developer."
      exit dbPath
   end if
   
   switch the environment
      case "development"
         return "/Users/stam/Documents/Developer/SQLite databases/" &  gDBName 
         break
      case "standalone application" 
      case "mobile" 
         return specialFolderPath("resources") & fDelimiter() & gDBName
         break
   end switch
end dbPath

////// CONNECT SQLITE DATABASE //////
command DBConnect
   local tDatabasePath, tDatabaseID
   put dbPath() into tDatabasePath
   if there is a file tDatabasePath then 
   get revOpenDatabase("sqlite",tDatabasePath,)
   if it is a integer then
      put it into tDatabaseID
   else
      answer "Error connecting to database:" && it
   end if
else
   answer "Database file" && gDBName && "could not be found"
   exit DBConnect
end if

   _DBsetDatabaseID tDatabaseID
end DBConnect


////// PRIVATE: SET STACK VARIABLE //////
private command _DBsetDatabaseID pDatabaseID
   if pDatabaseID is a integer then
      put pDatabaseID into sDatabaseID
   else
      put empty into sDatabaseID
   end if
end _DBsetDatabaseID


////// GET ACTIVE DATABASE CONNECTION ID //////
function DBgetDatabaseID 
   if sDatabaseID is not in revOpenDatabases() then
      DBConnect
   end if
   return sDatabaseID
end DBgetDatabaseID


////// CLOSE DATABASE BY ID //////
command DBcloseDatabase pDatabaseID
   if pDatabaseID is empty then
      put sDatabaseID into pDatabaseID
   end if
   
   if pDatabaseID is not empty then
      revCloseDatabase pDatabaseID
      if the result is not empty then
         answer "Database Error: Error when disconnecting from database." && the result
      else if pDatabaseID is sDatabaseID then
         put empty into sDatabaseID
      end if
   end if
end DBcloseDatabase

////// GET DB CURSOR AS ARRAY //////
function convertSQLcursorToArray pSQL
   local i, tFields,tCursor, tArray
   put revQueryDatabase(sDatabaseID, pSQL ) into tCursor
   put revDatabaseColumnNames(tCursor) into tFields
   put 1 into i
   repeat until revQueryIsAtEnd(tCursor)
      repeat for each item tField in tFields
         put revDatabaseColumnNamed(tCursor, tField) into tArray[i][tField]
      end repeat
      revMoveToNextRecord tCursor
      add 1 to i
   end repeat
   revCloseCursor tCursor   
   return tArray
end convertSQLcursorToArray

////// GET RETURN DELIMITED LIST OF SINGLE FIELD //////
function getReturnDelimitedList  pField pTable
   local tSQL, tFMArray
   put "SELECT DISTINCT" && pField && "FROM" && pTable into tSQL
   put revDataFromQuery(,return, DBgetDatabaseID(), tSQL ) into tFMArray
   return tFMArray //RETURN DELIMITED LIST OF DISCREET VALUES FOR 1 COLUMN
end getReturnDelimitedList

////////// STARTUP /////////
on startup pMode
   switch the environment
      case "development"
         start using "/Users/stam/Documents/Developer/LiveCode SO Stacks/GeneralAlgorithms.livecodescript"
         break
      case "standalone application" -- The stack is running as a standalone application.
      case "mobile" -- The stack is running on a mobile device.
         start using specialFolderPath("resources") & "/GeneralAlgorithms.livecodescript"
         break
   end switch  
end startup
