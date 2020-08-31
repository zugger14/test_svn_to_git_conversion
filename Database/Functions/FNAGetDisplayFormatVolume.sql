/****** Object:  UserDefinedFunction [dbo].[FNAGetDisplayFormat]    Script Date: 04/29/2012 11:43:08 ******/
IF OBJECT_ID('FNAGetDisplayFormatVolume') IS NOT NULL
	DROP FUNCTION dbo.[FNAGetDisplayFormatVolume]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetDisplayFormatVolume] (@source_value VARCHAR(100),@display_format INT,@template_id INT,@field_name VARCHAR(100)) 
RETURNS VARCHAR(100) 
AS  
BEGIN
/*
SELECT dbo.FNAGetDisplayFormatVolume(222222,NULL,264,'volume_left')
SELECT dbo.FNAGetDisplayFormatVolume('4515.00000000', null, 264, 'deal_volume')	
*/
DECLARE @ret_val VARCHAR(100)

IF @template_id IS NOT NULL
BEGIN
	
	SELECT @display_format = d.display_format 
	--SELECT d.display_format
	FROM maintain_field_deal m 
	INNER JOIN maintain_field_template_detail d ON m.field_id = d.field_id 
	INNER JOIN dbo.source_deal_header_template st ON st.field_template_id = d.field_template_id 
		AND st.template_id = @template_id
	WHERE m.farrms_field_id = @field_name AND m.header_detail = 'd' 
END

IF @source_value IS NOT NULL
BEGIN
	SELECT @ret_val = CASE ISNULL(@display_format,1)
			WHEN 19204 THEN	
				--@source_value
				dbo.FNAAddThousandSeparator(@source_value)
			ELSE @source_value
		END
END
ELSE
	SET @ret_val = @source_value

	RETURN @ret_val	
END

