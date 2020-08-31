/****** Object:  UserDefinedFunction [dbo].[FNARTotalVolm]    Script Date: 01/07/2011 17:49:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARTotalVolm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARTotalVolm]

GO
/****** Object:  UserDefinedFunction [dbo].[FNARTotalVolm]    Script Date: 01/07/2011 17:50:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARTotalVolm](
	@term_start DATETIME,
	@book_mapi_id1 INT,
	@book_mapi_id2 INT,
	@book_mapi_id3 INT,
	@book_mapi_id4 INT,
	@deal_type INT	
)

RETURNS FLOAT AS
BEGIN
DECLARE @total_volume FLOAT

	SELECT @total_volume = (sdd.total_volume)			
	FROM
			source_deal_header sdh	
			INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1=ssbm.source_system_book_id1     		                        
				AND sdh.source_system_book_id2=ssbm.source_system_book_id2                             
				AND sdh.source_system_book_id3=ssbm.source_system_book_id3                             
				AND sdh.source_system_book_id4=ssbm.source_system_book_id4                             
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=sdh.source_deal_header_id
		WHERE 1=1 
			AND sdh.source_system_book_id1 = ISNULL(@book_mapi_id1,sdh.source_system_book_id1)
			AND sdh.source_system_book_id2 = ISNULL(@book_mapi_id2,sdh.source_system_book_id2)
			AND sdh.source_system_book_id3 = ISNULL(@book_mapi_id3,sdh.source_system_book_id3)
			AND sdh.source_system_book_id4 = ISNULL(@book_mapi_id4,sdh.source_system_book_id4)
			AND sdh.source_deal_type_id = ISNULL(@deal_type,sdh.source_deal_type_id)
			AND sdd.term_start = @term_start
		
	RETURN ISNULL(@total_volume,0)
END


