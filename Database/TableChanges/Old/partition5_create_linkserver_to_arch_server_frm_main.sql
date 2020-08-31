-- ===============================================================================================================
-- Create date: 2012-03-01
-- Description:	This script will create server link 
-- @server = Name of Linked server 
-- @datasrc = Name of server to be linked 

-- 
-- ===============================================================================================================
IF  EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'FARRMSARCH')EXEC master.dbo.sp_dropserver @server=N'FARRMSARCH', @droplogins='droplogins'
GO
EXEC sp_addlinkedserver   
   @server = 'FARRMSARCH',	--TODO: change
   @srvproduct = '',
   @provider = 'SQLNCLI', 
   @datasrc = 'test'	--TODO: change
GO

EXEC sp_addlinkedsrvlogin 'FARRMSARCH', 'false', NULL, 'farrms_admin', '321'
GO


EXEC sp_serveroption @server = 'FARRMSARCH', @optname = 'rpc', @optvalue = 'true'
EXEC sp_serveroption @server = 'FARRMSARCH', @optname = 'rpc out', @optvalue = 'true'