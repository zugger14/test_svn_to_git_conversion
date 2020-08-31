SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[contract_price]', N'U') IS  NULL
BEGIN
 CREATE TABLE [dbo].[contract_price]
  (
	 ID INT IDENTITY(1,1)
	,contract_id INT
	,curve_id INT
	,product INT
	,[description] VARCHAR(500)
	,create_user VARCHAR(200) DEFAULT dbo.FNADBUser()
	,create_ts DATETIME DEFAULT GETDATE()
	,update_user VARCHAR(200)
	,update_time DATETIME 
  )
END
ELSE
BEGIN
    PRINT 'Table contract_price EXISTS'
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_contract_price_contract_id]')
  				AND parent_object_id = OBJECT_ID(N'[dbo].[contract_price]'))
BEGIN
	ALTER TABLE [dbo].[contract_price] ADD CONSTRAINT [FK_contract_price_contract_id] 
	FOREIGN KEY([contract_id])
	REFERENCES [dbo].[contract_group] ([contract_id])
END


IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_contract_price_curve_id]')
  				AND parent_object_id = OBJECT_ID(N'[dbo].[contract_price]'))
BEGIN
	ALTER TABLE [dbo].[contract_price] ADD CONSTRAINT [FK_contract_price_curve_id] 
	FOREIGN KEY([curve_id])
	REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
END

--Update Trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_contract_price]'))
    DROP TRIGGER [dbo].[TRGUPD_contract_price]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_contract_price]
ON [dbo].[contract_price]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE [dbo].[contract_price]
        SET update_user = dbo.FNADBUser(), update_time = GETDATE()
        FROM [dbo].[contract_price] fr
        INNER JOIN DELETED d ON d.id = fr.id
    END
END
GO

