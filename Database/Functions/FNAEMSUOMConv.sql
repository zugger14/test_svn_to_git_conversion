/****** Object:  UserDefinedFunction [dbo].[FNAEMSUOMConv]    Script Date: 08/20/2009 12:34:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FNAEMSUOMConv]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSUOMConv]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAEMSUOMConv]
	(@from_uom_id INT,
	 @to_uom_id INT	
)
RETURNS FLOAT AS  
BEGIN
	--if convert to uom is not supplied, return 1 so that original value is unchanged
	IF @to_uom_id IS NULL OR @to_uom_id = ''
		RETURN 1
 
	DECLARE @conversion_factor FLOAT
	
	SELECT @conversion_factor = conversion_factor
	FROM   rec_volume_unit_conversion
	WHERE  from_source_uom_id = @from_uom_id
	       AND to_source_uom_id = @to_uom_id
	       AND state_value_id IS NULL
	       AND curve_id IS NULL
	       AND assignment_type_value_id IS NULL
	
	IF @conversion_factor IS NULL
	SELECT @conversion_factor = 1 / NULLIF(conversion_factor, 0)
	FROM   rec_volume_unit_conversion
	WHERE  from_source_uom_id = @to_uom_id
	       AND to_source_uom_id = @from_uom_id
	       AND state_value_id IS NULL
	       AND curve_id IS NULL
	       AND assignment_type_value_id IS NULL
	
	RETURN @conversion_factor
END

