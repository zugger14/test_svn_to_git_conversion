IF OBJECT_ID(N'spa_createHTMLReportOnSQLStmt', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_createHTMLReportOnSQLStmt]
 GO 





--Generate output on HTML Format
--declare @x varchar(8000)
--exec spa_createHTMLReportOnSQLStmt 'select user_f_name,user_l_name,user_login_id from Application_users','Application Title','User Details','user_f_name,user_l_name,user_login_id','First name,Last name, Login ID','0,0,0','40%,30%,30%',@x out
--print @x ' @x is the output which is in HTML Format

CREATE Proc [dbo].[spa_createHTMLReportOnSQLStmt]
@sqlStmt varchar(1000),
@titleName varchar(1000),
@tableName varchar(1000),
@clmNames varchar(1000),
@clmHeader varchar(1000),
@clmGroupBy varchar(1000), 
@clmWidthPercentage varchar(1000),@outputHTML varchar(8000) output

as
begin
Declare @db_username varchar(50)
Declare @db_userpwd varchar(50)
declare @db_serverName varchar(50)
Declare @db_databaseName varchar(50)
--select @db_userpwd=db_userpwd,@db_ServerName=db_serverName,@db_databaseName=db_databaseName from Connection_String

set @db_userpwd=''
set @db_ServerName= CONVERT(VARCHAR(200), SERVERPROPERTY('ServerName'))
set @db_databaseName=db_name()
set @db_username=dbo.FNADBUser()


Declare @oUpdate int
Declare @resultCode int
Declare @rStr varchar(1000)

EXEC @resultcode  = sp_OACreate 'PSAPRCMGM.DLCProcessControls', @oUpdate OUT 
EXEC @rStr = sp_OAMethod @oUpdate, 'setConnectionString',null,@db_username,@Db_UserPwd,@db_Servername,@db_DatabaseName
EXEC @resultcode = sp_OAMethod @oUpdate, 'createHTMLReportOnSQLStmt',@outputHTML out,@sqlStmt ,@titleName,@tableName,@clmNames,@clmHeader,@clmGroupBy,@clmWidthPercentage
EXEC spa_print @resultCode
EXEC @resultCode = sp_OADestroy @oUpdate
return 
end




