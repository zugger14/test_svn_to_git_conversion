IF OBJECT_ID('spa_check_openrowset_connection') IS NOT NULL
	DROP  PROCEDURE [dbo].[spa_check_openrowset_connection]
GO


-- =============================================  
-- Create date: 2008-10-12 03:40PM  
-- Description: Checks the connection to openrowset destination server executing SELECT 1 query  
-- Params:  
-- @success bit OUTPUT - 1:Connection OK, 0:Connection failed  
  
-- =============================================  
CREATE PROCEDURE [dbo].[spa_check_openrowset_connection]  
(  
 @success bit OUTPUT  
)  
AS  
BEGIN  
   
 DECLARE @sql varchar(1000)  
 exec spa_print 'Checking OpenRowSet connection.'  
 --sql version  
-- SET @sql = 'SELECT * FROM ' + dbo.FNARowSet('SELECT 1')  
-- --oracle version  
 SET @sql = 'SELECT * FROM ' + dbo.FNARowSet('SELECT 1 FROM dual')  
  
 BEGIN TRY  
  EXEC(@sql)  
 END TRY  
 BEGIN CATCH  
  SET @success = 0  
  RETURN  
 END CATCH;  
  
 SET @success = 1  
  
END  
  
  
  