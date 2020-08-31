IF OBJECT_ID('[dbo].[FNATermBreakdownByGranularity]','tf') IS NOT NULL 
DROP FUNCTION [dbo].[FNATermBreakdownByGranularity] 
GO 

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	Function to breakdown term with dst information according to granularity

	Parameters
	@granularity : Term breakdown by granularity
	@term_start : Term Start
	@term_end : Term End
	@dst_group_value_id : DST Group Value ID. DST information picked for provided dst group defined in configuration.

	Returns: Table with Term Start, Term End and DST information
*/
CREATE FUNCTION [dbo].[FNATermBreakdownByGranularity] 
(
	@granularity INT,
	@term_start DATE,
	@term_end DATE,
	@dst_group_value_id INT = NULL
)
RETURNS @tt TABLE(term_start DATETIME, term_end DATETIME, is_dst INT)
AS
/*
	DECLARE @granularity INT = 989,
	@term_start DATE = '2021-10-31',
	@term_end DATE = '2021-10-31',
	@dst_group_value_id INT --=  102201
	
	DECLARE @tt TABLE(term_start DATETIME, term_end DATETIME, is_dst INT)
--*/
BEGIN

	DECLARE @frequency NCHAR(1), @termstart DATETIME, @termend DATETIME

	SET @frequency = CASE WHEN @granularity = 982 THEN 'h' --hourly
							WHEN @granularity = 989 THEN 't'	--30mins
							WHEN @granularity = 987 THEN 'f'	--15mins
							WHEN @granularity = 994 THEN 'r'	--10mins
							WHEN @granularity = 995 THEN 'z'	--5mins
						ELSE  '' 
					END 
	SET @termstart = CAST(@term_start AS NVARCHAR(10)) + ' 00:00:00.000'
	SET @termend = CAST(@term_end AS NVARCHAR(10)) 
								+ CASE WHEN @granularity = 982 THEN ' 23:00:00.000' --hourly
									 WHEN @granularity = 989 THEN ' 23:30:00.000'	--30mins
									 WHEN @granularity = 987 THEN ' 23:45:00.000'	--15mins
									 WHEN @granularity = 994 THEN ' 23:50:00.000'	--10mins
									 WHEN @granularity = 995 THEN ' 23:55:00.000'	--5mins
									ELSE  '' 
								END 								

	DECLARE @dst TABLE (
		term_start DATETIME, 
		term_end DATETIME, 
		insert_delete CHAR(1)
	)
	
	INSERT INTO @tt(term_start, term_end, is_dst)
	SELECT tb.term_start, tb.term_end, 0 is_sdt
	FROM  dbo.FNATermBreakdown(@frequency, @termstart, @termend) tb
	
	IF @frequency IN ('h', 't', 'f', 'r', 'z') AND @dst_group_value_id IS NOT NULL
	BEGIN
		INSERT INTO @dst (term_start, term_end, insert_delete)
		SELECT tb.term_start, tb.term_end, md.insert_delete
		FROM  @tt tb
			INNER JOIN mv90_dst md
				ON CAST(md.date AS DATE) = CAST(tb.term_start AS DATE)
				AND DATEPART (HOUR , tb.term_end) = md.hour - 1
				AND isNULL(dst_group_value_id,-1) =ISNULL( @dst_group_value_id,-1)

		INSERT INTO  @tt(term_start, term_end, is_dst)
		SELECT term_start, term_end, 1
		FROM @dst d 
		WHERE d.insert_delete = 'i'

		DELETE  t 
		FROM @tt t		
			INNER join @dst d 
			ON t.term_start = d.term_start
				AND d.insert_delete = 'd'
	END 
	
	RETURN
END



