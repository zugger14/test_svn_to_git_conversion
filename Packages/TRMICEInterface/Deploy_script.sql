
DECLARE @library_path VARCHAR(1024) = 'D:\Applications\TRMTracker\Branches\TRMTracker_Trunk\Packages\TRMICEInterface\TRMICEInterface\bin\Debug\' -- Assembly DLL File path

-- Check if CLR configuration is enabled or not if not enable it 
IF EXISTS (SELECT * FROM sys.configurations WHERE name = 'clr enabled' AND [value] = 0)
BEGIN
	EXEC sp_CONFIGURE 'show advanced options' , '1'
	RECONFIGURE;
	EXEC sp_CONFIGURE 'clr enabled' , '1'
	RECONFIGURE
	PRINT '2. CLR configuration enabled'
END
ELSE
	PRINT '2. CLR configuration enabled already.'

-- Database must be TRUSTWORTHY 
DECLARE @db_name VARCHAR(255) = DB_NAME()
IF EXISTS(SELECT is_trustworthy_on FROM sys.databases  WHERE name = @db_name AND is_trustworthy_on = 0)
BEGIN
	EXEC ('USE MASTER; ALTER DATABASE ' + @db_name + ' SET trustworthy ON; USE ' + @db_name )
	PRINT '3. Database TRUSTWORTHY option set to TRUE'
END
ELSE
	PRINT + '3. ' +  @db_name +  ' is TRUSTWORTHY already.'

IF OBJECT_ID('spa_TRMICEInterface') IS NOT NULL
	DROP PROC [spa_TRMICEInterface]

IF OBJECT_ID('spa_TRMICESecurityDefinition') IS NOT NULL
	DROP PROC [spa_TRMICESecurityDefinition]

--DROP PROC spa_TRMICEStopInterface


IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'TRMICEInterface')
		DROP ASSEMBLY TRMICEInterface


--IF EXISTS(SELECT 1 FROM sys.assemblies a WHERE [name] LIKE 'QuickFix')
--		DROP ASSEMBLY QuickFix


--CREATE ASSEMBLY QuickFix
--	FROM @library_path +'QuickFix.dll'
--	WITH PERMISSION_SET = UNSAFE	


CREATE ASSEMBLY TRMICEInterface
	FROM @library_path +'TRMICEInterface.dll'
	WITH PERMISSION_SET = UNSAFE	



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO  
CREATE PROC [dbo].[spa_TRMICEInterface]
(
	@as_of_date NVARCHAR(MAX),@confile_file_path NVARCHAR(MAX),@username NVARCHAR(MAX),@password NVARCHAR(MAX), @process_table NVARCHAR(MAX), @log_file_name NVARCHAR(MAX), @debugmode NVARCHAR(MAX)
)
AS
	EXTERNAL NAME TRMICEInterface.[TRMICEInterface.TradeClientApp].ImportICEDeal
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO  
CREATE PROC [dbo].[spa_TRMICESecurityDefinition]
(
	@security_id NVARCHAR(MAX),@confile_file_path NVARCHAR(MAX),@username NVARCHAR(MAX),@password NVARCHAR(MAX), @process_table NVARCHAR(MAX), @log_file_name NVARCHAR(MAX), @debugmode NVARCHAR(MAX)
)
AS
	EXTERNAL NAME TRMICEInterface.[TRMICEInterface.TradeClientApp].ImportSecurityDefinition
GO


--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO  
--CREATE PROC [dbo].[spa_TRMICEStopInterface]
--(
--	@confile_file_path NVARCHAR(MAX)
--)
--AS
--	EXTERNAL NAME TRMICEInterface.[TRMICEInterface.TradeClientApp].ImportSecurityDefinition
--GO

/* - test

exec [spa_TRMICEInterface] '2017-01-11','D:\\Temp\\FIX\\tradeclient.cfg','mem-dcfx','Memphis.23','adiha_process.dbo.IceInterface','D:\\Temp\\FIX\\logfile\\',0

exec [spa_TRMICESecurityDefinition] '305','D:\\Temp\\FIX\\tradeclient.cfg','mem-dcfx','Memphis.23','adiha_process.dbo.ice_security_definition','D:\\Temp\\FIX\\logfile\\','0'


select * from adiha_process.dbo.testing order by trade_date desc

DELETE FROM adiha_process.dbo.IceInterface
DELETE FROM adiha_process.dbo.ice_security_definition

select distinct product FROM adiha_process.dbo.IceInterface

select * from adiha_process.dbo.IceInterface
select * from adiha_process.dbo.ice_security_definition where [hubalias]='TGT-Mainline'

select * from adiha_process.dbo.ice_security_definition where productid IN(1545404,5113703)


delete from adiha_process.dbo.ice_security_definition



select * from clr_error_log
delete from clr_error_log

DROP TABLE adiha_process.dbo.ice_security_definition

CREATE TABLE adiha_process.dbo.ice_security_definition(
	ProductID VARCHAR(5000), 
	ExchangeName VARCHAR(5000), 
	ProductName VARCHAR(5000),
	Granularity VARCHAR(100), 
	TickValue VARCHAR(100), 
	UOM VARCHAR(100), 
	HubName VARCHAR(5000), 
	Currency VARCHAR(100),
	CFICode VARCHAR(5000),
	HubAlias VARCHAR(5000)
)


*/
