IF OBJECT_ID(N'spa_UpdateAutomaticProcessSQLStmt', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_UpdateAutomaticProcessSQLStmt]
GO 

-- Call VB.net Com
-- Update AutomaticProcess function to create Process_Notes
-- by passing sqlStmt it will generate HTML Format which will be save on Email_Notes.Notes.Attachment
-- to test
--Exec spa_UpdateAutomaticProcessSQLStmt 105,'2003-10-10','testing NEw Com','select user_f_name,user_l_name,user_login_id,user_pwd from Application_users','Application Title','User Details','user_f_name,user_l_name,user_login_id,user_pwd','First name,Last name, Login ID,Password','0,0,0,0','30%,30%,30%,10%'
--Exec spa_UpdateAutomaticProcessSQLStmt 105, '2003-03-31', '', 'select user_f_name, user_l_name, user_login_id from application_users', 'Users', 'Users Detail', 
-- Exec spa_UpdateAutomaticProcessSQLStmt -341, '2003-03-31', '', 'select user_f_name, user_l_name, user_login_id from application_users', 'Users', 'Users Detail', 
--             'user_f_name, user_l_name, user_login_id', 'First Name, Last Name, Login ID', '0, 0, 0', '40%, 30%, 30%'
-- drop Proc spa_UpdateAutomaticProcessSQLStmt
CREATE PROC [dbo].[spa_UpdateAutomaticProcessSQLStmt]
	@internalFunctionId INT = NULL,
	@asOfDate DATETIME = NULL,
	@processCriteria  VARCHAR(1000) = NULL,
	@sqlStmt VARCHAR(1000),
	@titleName VARCHAR(1000),
	@tableName VARCHAR(1000),
	@clmNames VARCHAR(1000),
	@clmHeader VARCHAR(1000),
	@clmGroupBy VARCHAR(1000), 
	@clmWidthPercentage VARCHAR(1000)
AS
BEGIN
	DECLARE @db_username      VARCHAR(50)
	DECLARE @db_userpwd       VARCHAR(50)
	DECLARE @db_serverName    VARCHAR(50)
	DECLARE @db_databaseName  VARCHAR(50)
--select @db_userpwd=db_userpwd,@db_ServerName=db_serverName,@db_databaseName=db_databaseName from Connection_String

SET @db_userpwd = ''
SET @db_ServerName = @@servername
SET @db_databaseName = DB_NAME()
SET @db_username = dbo.FNADBUser()


-- EXEC spa_print @db_ServerName
-- EXEC spa_print @db_databaseName
-- EXEC spa_print @db_username

DECLARE @oUpdate     INT
DECLARE @resultCode  INT
DECLARE @rStr        VARCHAR(1000)
DECLARE @dateStr     VARCHAR(15)

SET @dateStr = dbo.FNAGetSQLStandardDate(@asOfDate)


EXEC @resultcode  = sp_OACreate 'PSAPRCMGM.DLCProcessControls', @oUpdate OUT 
EXEC @rStr = sp_OAMethod @oUpdate, 'setConnectionString',null,@db_username,@Db_UserPwd,@db_Servername,@db_DatabaseName

EXEC @resultcode = sp_OAMethod @oUpdate, 'UpdateAutomaticProcessSQLStmt',null, @internalFunctionid,
				@dateStr, @processCriteria,@sqlStmt ,@titleName,@tableName,@clmNames,@clmHeader,
				@clmGroupBy,@clmWidthPercentage
-- EXEC spa_print @resultCode
-- EXEC spa_print @oUpdate
EXEC @resultCode = sp_OADestroy @oUpdate
END