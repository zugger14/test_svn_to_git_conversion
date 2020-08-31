IF OBJECT_ID('[dbo].[FNATermBreakdownDST]','tf') IS NOT NULL 
DROP FUNCTION [dbo].[FNATermBreakdownDST] 
GO 

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
 --select * from [FNATermBreakdownDST]('h', '2016-10-30', '2016-10-31')

-- ===========================================================================================================
-- Author: Dewanand Manandhar
-- Create date: 2016-12-08
-- Description: Breakdown term and handles DST
 
-- Params:
-- returns @tt TABLE(term_start DATETIME, term_end DATETIME, is_dst INT)
-- ===========================================================================================================

CREATE FUNCTION [dbo].[FNATermBreakdownDST] 
(
	@frequency CHAR(1),
	@term_start DATETIME,
	@term_end DATETIME,
	@dst_group_value_id INT
)
RETURNS @tt TABLE(term_start DATETIME, term_end DATETIME, is_dst INT)
AS
BEGIN

	DECLARE @dst TABLE (
		term_start DATETIME, 
		term_end DATETIME, 
		insert_delete CHAR(1)
	)

	INSERT INTO @tt(term_start, term_end, is_dst)
	SELECT tb.term_start, tb.term_end, 0 is_sdt
	FROM  dbo.FNATermBreakdown(@frequency, @term_start, @term_end) tb

	IF @frequency IN ('h', 't', 'f', 'r', 'z')
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



