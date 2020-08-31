--create table shipper_code_mapping
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[shipper_code_mapping]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[shipper_code_mapping]
	(
	shipper_code_id			INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	counterparty			INT,
	effective_date			DATETIME,
	is_default				CHAR, 
    location                INT,
	shipper_code            VARCHAR(200),
    create_user				VARCHAR(50)  DEFAULT dbo.FNADBUser(),
	create_ts				DATETIME  DEFAULT GETDATE(),
    [update_user]			VARCHAR(50) NULL,
    [update_ts]				DATETIME NULL
	)
END
ELSE
BEGIN 
	PRINT 'Table shipper_code_mapping EXISTS'
END
GO

