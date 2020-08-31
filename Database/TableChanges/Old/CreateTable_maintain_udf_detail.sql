SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[maintain_udf_detail]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[maintain_udf_detail]
    (
    	[maintain_udf_detail_id]	INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[maintain_udf_header_id]    INT FOREIGN KEY(maintain_udf_header_id) REFERENCES maintain_udf_header(maintain_udf_header_id),
    	[udf_template_id]			INT FOREIGN KEY(udf_template_id) REFERENCES user_defined_fields_template(udf_template_id),
    	[udf_label]					VARCHAR(500) NULL,
    	[udf_default_value]			VARCHAR(500) NULL,
    	[is_update_required]		CHAR(1) NULL,
    	[is_insert_required]		CHAR(1) NULL,
    	[is_disable]				CHAR(1) NULL,
    	[is_hidden]					CHAR(1) NULL,
    	[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]					DATETIME NULL DEFAULT GETDATE(),
    	[update_user]				VARCHAR(50) NULL,
    	[update_ts]					DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table maintain_udf_detail EXISTS'
END
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_maintain_udf_detail]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_maintain_udf_detail]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_maintain_udf_detail]
ON [dbo].[maintain_udf_detail]
FOR UPDATE
AS
    UPDATE maintain_udf_detail
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM maintain_udf_detail t
      INNER JOIN DELETED u ON t.maintain_udf_detail_id = u.maintain_udf_detail_id
GO