SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[maintain_udf_header]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[maintain_udf_header]
    (
    [maintain_udf_header_id]         INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    [maintain_udf_header_name]       VARCHAR(100) NOT NULL,
    [sequence_number]				 INT NOT NULL,
    [udf_module_id]					 INT NULL FOREIGN KEY (udf_module_id) REFERENCES static_data_value(value_id),	
    [create_user]					 VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]						 DATETIME NULL DEFAULT GETDATE(),
    [update_user]					 VARCHAR(50) NULL,
    [update_ts]						 DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table maintain_udf_header EXISTS'
END
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_maintain_udf_header]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_maintain_udf_header]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_maintain_udf_header]
ON [dbo].[maintain_udf_header]
FOR UPDATE
AS
    UPDATE maintain_udf_header
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM maintain_udf_header t
      INNER JOIN DELETED u ON t.maintain_udf_header_id = u.maintain_udf_header_id
GO