/****** Object:  UserDefinedFunction [dbo].[FNAEMS24HrsAverage]    Script Date: 04/07/2010 20:36:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMS24HrsAverage]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMS24HrsAverage]

/****** Object:  UserDefinedFunction [dbo].[FNAEMS24HrsAverage]    Script Date: 04/07/2010 20:36:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAEMS24HrsAverage](
		@generator_id INT,
		@term_start DATETIME,
		@curve_id int
	)

Returns Float
AS
BEGIN

DECLARE @value float
DECLARE @record_type_code INT
DECLARE @record_sub_type_code INT

	SELECT 
		@record_type_code=record_type_code,
		@record_sub_type_code=record_sub_type_code
	FROM
		edr_xml_file_map_detail
	WHERE
		record_data IN(SELECT curve_id FROM source_price_curve_def WHERE source_curve_def_id=@curve_id)

	SELECT @value=AVG(edr_value)
	FROM
			edr_raw_data erd
			INNER JOIN rec_generator rg ON rg.[ID]=erd.facility_id
				  AND rg.[ID2]=erd.unit_id
	WHERE
			rg.generator_id=@generator_id
			AND erd.record_type_code=@record_type_code
			AND erd.sub_type_id=@record_sub_type_code
			AND dbo.FNAGetContractMonth(erd.edr_date)=@term_start		

	return @value

END















