-- ===============================================================================================================
-- Create date: 2012-03-01
-- Description:	This script will create server link 
-- @server = Name of Linked server 
-- @datasrc = Name of server to be linked 

-- 
-- ===============================================================================================================
IF  EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'FARRMSMAIN')EXEC master.dbo.sp_dropserver @server=N'FARRMSMAIN', @droplogins='droplogins'
GO
EXEC sp_addlinkedserver   
   @server='FARRMSMAIN',	--TODO: change
   @srvproduct='',
   @provider='SQLNCLI', 
   @datasrc='langtang\instance2008'	--TODO: change
GO

EXEC sp_addlinkedsrvlogin 'FARRMSMAIN', 'false', NULL, 'farrms_admin', 'Admin2929'
GO


EXEC sp_serveroption @server='FARRMSMAIN', @optname='rpc', @optvalue='true'
EXEC sp_serveroption @server='FARRMSMAIN', @optname='rpc out', @optvalue='true'