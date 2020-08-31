SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[maintain_field_template_group_detail]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[maintain_field_template_group_detail] (
    	[group_id]				  INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[group_name]			  VARCHAR(200) NULL,
    	[field_template_id]		  INT NULL REFERENCES maintain_field_template(field_template_id),
    	[seq_no]				  INT,
    	[default_tab]			  BIT DEFAULT(0),
    	[create_user]             VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]               DATETIME NULL DEFAULT GETDATE(),
    	[update_user]             VARCHAR(50) NULL,
    	[update_ts]               DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table maintain_field_template_group_detail EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_maintain_field_template_group_detail]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_maintain_field_template_group_detail]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_maintain_field_template_group_detail]
ON [dbo].[maintain_field_template_group_detail]
FOR UPDATE
AS
    UPDATE maintain_field_template_group_detail
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM maintain_field_template_group_detail t
      INNER JOIN DELETED u ON t.[group_id] = u.[group_id]
GO