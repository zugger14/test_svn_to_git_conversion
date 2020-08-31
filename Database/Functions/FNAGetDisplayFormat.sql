IF OBJECT_ID('FNAGetDisplayFormat') IS NOT NULL
DROP FUNCTION dbo.FNAGetDisplayFormat
GO

CREATE FUNCTION dbo.FNAGetDisplayFormat (@source_value DateTime,@display_format INT,@template_id INT,@field_name VARCHAR(100)) 
	RETURNS VARCHAR(30) 
AS  
BEGIN

--SELECT dbo.FNAGetDisplayFormat('2011-01-01 00:00:00.000',NULL,353,'term_end')

--declare @source_value datetime='2011-01-01 00:00:00.000',@display_format int=null,@template_id int=292,@field_name varchar(100)='term_start'
	
	DECLARE @ret_val VARCHAR(30)

	IF @template_id IS NOT NULL
	BEGIN
		SELECT @display_format=d.display_format 
		FROM maintain_field_deal m 
		INNER JOIN maintain_field_template_detail d ON m.field_id=d.field_id 
		INNER JOIN dbo.source_deal_header_template st ON st.field_template_id=d.field_template_id 
			AND st.template_id = @template_id
		WHERE m.farrms_field_id = @field_name AND m.header_detail = 'd' 
	END

	IF ISDATE(@source_value) = 1
	BEGIN
		SELECT @ret_val = CASE ISNULL(@display_format, 1)
				WHEN 19201 THEN	--first day of month
						dbo.fnadateformat(CONVERT(VARCHAR(8),@source_value,120) + '01')	
				--when 19202 then	--last day of year
				--		cast(year(@source_value) as varchar)	
				--when 19203 then	--last day of month
				--		dbo.fnadateformat(dateadd(day,-1,convert(varchar(8),dateadd(month,1,@source_value),120)+ '01'))						
				WHEN 19203 THEN	--first day of year
						dbo.fnadateformat(CONVERT(VARCHAR(5), @source_value,120) + '01-01')						
				--when 19205 then	--last day of year
				--		dbo.fnadateformat(dateadd(day,-1,cast(year(@source_value)+1  as varchar)+ '-01-01')	)
				WHEN 19202 THEN	-- year
						CONVERT(VARCHAR(4), @source_value,120)	
				ELSE dbo.fnadateformat(@source_value)
			END
	END
	ELSE
		SET @ret_val = @source_value

	RETURN @ret_val	
END