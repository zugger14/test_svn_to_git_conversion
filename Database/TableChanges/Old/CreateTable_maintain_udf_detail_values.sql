SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[maintain_udf_detail_values]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[maintain_udf_detail_values]
    (
    [maintain_udf_detail_values_id]     INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    [maintain_udf_detail_id]			INT NOT NULL FOREIGN KEY(maintain_udf_detail_id) REFERENCES maintain_udf_detail(maintain_udf_detail_id),
    [module_object_id]					INT NOT NULL,
    [udf_values]						VARCHAR NULL,	
    [create_user]						VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]							DATETIME NULL DEFAULT GETDATE(),
    [update_user]						VARCHAR(50) NULL,
    [update_ts]							DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table maintain_udf_detail_values EXISTS'
END
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_maintain_udf_detail_values]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_maintain_udf_detail_values]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_maintain_udf_detail_values]
ON [dbo].[maintain_udf_detail_values]
FOR UPDATE
AS
    UPDATE maintain_udf_detail_values
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM maintain_udf_detail_values t
      INNER JOIN DELETED u ON t.maintain_udf_detail_values_id = u.maintain_udf_detail_values_id
GO