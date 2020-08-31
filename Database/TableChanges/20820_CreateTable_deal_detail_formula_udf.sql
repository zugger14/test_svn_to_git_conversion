SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[deal_detail_formula_udf]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_detail_formula_udf](
    	[deal_detail_formula_udf_id]     INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[source_deal_detail_id]          INT REFERENCES source_deal_detail(source_deal_detail_id) NOT NULL,
    	[udf_template_id]                INT REFERENCES user_defined_fields_template(udf_template_id) NOT NULL,
    	[udf_value]                      VARCHAR(2000) NULL,
    	[create_user]                    VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                      DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                    VARCHAR(50) NULL,
    	[update_ts]                      DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_detail_formula_udf EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_detail_formula_udf]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_detail_formula_udf]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_detail_formula_udf]
ON [dbo].[deal_detail_formula_udf]
FOR UPDATE
AS
    UPDATE deal_detail_formula_udf
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_detail_formula_udf t
      INNER JOIN DELETED u ON t.[deal_detail_formula_udf_id] = u.[deal_detail_formula_udf_id]
GO