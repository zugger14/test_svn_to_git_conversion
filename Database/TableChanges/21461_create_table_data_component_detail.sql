SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[data_component_detail]', N'U') IS  NULL
BEGIN
 CREATE TABLE [dbo].[data_component_detail]
  (
	 data_component_detail_id INT IDENTITY(1,1)
	,contract_group_detail_id INT FOREIGN KEY REFERENCES contract_group_detail(ID) NOT NULL
	,data_component_id INT FOREIGN KEY REFERENCES data_component(data_component_id) NOT NULL
	,[value] VARCHAR(MAX) NULL
	,[granularity] INT NULL
	,create_user VARCHAR(200) DEFAULT dbo.FNADBUser()
	,create_ts DATETIME DEFAULT GETDATE()
	,update_user VARCHAR(200)
	,update_ts DATETIME 
  )
END
ELSE
BEGIN
    PRINT 'Table Data Component Detail EXISTS'
END
GO

--Update Trigger

IF OBJECT_ID('[dbo].[TRGUPD_data_component_detail]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_data_component_detail]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_data_component_detail]
ON [dbo].[data_component_detail]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE [dbo].[data_component_detail]
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM [dbo].[data_component_detail] dcd
        INNER JOIN DELETED d ON d.data_component_detail_id = dcd.data_component_detail_id
    END
END
GO


