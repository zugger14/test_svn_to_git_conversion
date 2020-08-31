SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[storage_contract_location]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[storage_contract_location] (
		[storage_contract_location_id]			INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		[contract_id]									INT REFERENCES contract_group(contract_id) NOT NULL,
		[type]  										INT,
		[location_id]      								INT REFERENCES source_minor_location(source_minor_location_id) NOT NULL,
		[rec_del]      									INT,
		[effective_date]  								DATETIME,
		[mdq]											NUMERIC(38,20),
		[rank]											INT REFERENCES [dbo].[static_data_value] (value_id) NULL,
		[surcharge]										NUMERIC(38,20) NULL,
		[fuel]											NUMERIC(38,20) NULL,
		[fuel_group]									INT NULL,
		[rate]											NUMERIC(38,20) NULL,
		[create_user]    								NVARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]      								DATETIME NULL DEFAULT GETDATE(),
		[update_user]    								NVARCHAR(50) NULL,
		[update_ts]      								DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table storage_contract_location EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_storage_contract_location]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_storage_contract_location]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_storage_contract_location]
ON [dbo].[storage_contract_location]
FOR UPDATE
AS
    UPDATE storage_contract_location
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM storage_contract_location t
    INNER JOIN DELETED u ON t.[storage_contract_location_id] = u.[storage_contract_location_id]
GO