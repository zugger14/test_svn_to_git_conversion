SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[udf_group]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[udf_group] (
		[udf_group_id]    INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
		[group_id]        INT REFERENCES static_data_value(value_id) NOT NULL,
		[udf_template_id] INT REFERENCES user_defined_fields_template (udf_template_id) NOT NULL,
		[create_user]     VARCHAR(50) NULL DEFAULT [dbo].[FNADBUser](),
		[create_ts]       DATETIME NULL DEFAULT GETDATE(),
		[update_user]     VARCHAR(50) NULL,
		[update_ts]       DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table udf_group EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_udf_group]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_udf_group]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_udf_group]
ON [dbo].[udf_group]
FOR UPDATE
AS
    UPDATE udf_group
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM udf_group t
      INNER JOIN DELETED u ON t.[udf_group_id] = u.[udf_group_id]
GO