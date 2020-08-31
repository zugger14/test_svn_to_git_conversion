IF EXISTS ( SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FNAGetUserDefinedValue]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT') )
    DROP FUNCTION [dbo].[FNAGetUserDefinedValue]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetUserDefinedValue] (@udf_module_id INT, @udf_template_id INT)
RETURNS INT
AS
BEGIN
	RETURN 1
END
