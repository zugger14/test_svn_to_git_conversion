SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[contract_fees]', N'U') IS  NULL
BEGIN
 CREATE TABLE [dbo].[contract_fees]
  (
	 contract_fees_id INT IDENTITY(1,1)
	,contract_id INT
	,product_type INT
	,charges INT
	,effective_date DATETIME
	,value FLOAT
	,create_user VARCHAR(200) DEFAULT dbo.FNADBUser()
	,create_ts DATETIME DEFAULT GETDATE()
	,update_user VARCHAR(200)
	,update_time DATETIME 
  )
END
ELSE
BEGIN
    PRINT 'Table contract_fees EXISTS'
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_contract_fees_contract_id]')
  				AND parent_object_id = OBJECT_ID(N'[dbo].[contract_fees]'))
BEGIN
	ALTER TABLE [dbo].[contract_fees] ADD CONSTRAINT [FK_contract_fees_contract_id] 
	FOREIGN KEY([contract_id])
	REFERENCES [dbo].[contract_group] ([contract_id])
END

--Update Trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_contract_fees]'))
    DROP TRIGGER [dbo].[TRGUPD_contract_fees]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_contract_fees]
ON [dbo].[contract_fees]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE [dbo].[contract_fees]
        SET update_user = dbo.FNADBUser(), update_time = GETDATE()
        FROM [dbo].[contract_fees] fr
        INNER JOIN DELETED d ON d.contract_fees_id = fr.contract_fees_id
    END
END
GO

