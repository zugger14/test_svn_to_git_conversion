/****** Object:  UserDefinedFunction [dbo].[FNARWeekDay]    Script Date: 07/23/2009 01:08:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARPeakHours]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARPeakHours]
/****** Object:  UserDefinedFunction [dbo].[FNARPeakHours]    Script Date: 07/23/2009 01:08:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARPeakHours](
	@term_date DATETIME,
	@granularity INT,
	@block_definition INT,
	@block_type INT
)

RETURNS VARCHAR(20) AS
BEGIN

	DECLARE @value FLOAT
		
	


	SELECT 
		@value=SUM(volume_mult) 
	FROM 
		dbo.hour_block_term
	WHERE
		block_type=@block_type
		AND block_define_id=@block_definition	
		AND ((@granularity=980 AND dbo.FNAGetContractMonth(@term_date)=dbo.FNAGetContractMonth(term_date))
			 OR(@granularity=981 AND @term_date=term_date)
			 OR(@granularity=982 AND @term_date=term_date)
			 OR(@granularity=989 AND @term_date=term_date)
			 OR(@granularity=987 AND @term_date=term_date)
			 OR(@granularity=990 AND DATEPART(w,@term_date)=DATEPART(w,@term_date))
			 OR(@granularity=991 AND DATEPART(q,@term_date)=DATEPART(q,@term_date))
			 OR(@granularity=993 AND YEAR(@term_date)=YEAR(@term_date))
		)	 
			
	RETURN @value
END



