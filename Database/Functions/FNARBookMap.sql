/****** Object:  UserDefinedFunction [dbo].[FNARBookMap]    Script Date: 01/11/2011 09:36:22 ******/
IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[FNARBookMap]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[FNARBookMap]
GO

/****** Object:  UserDefinedFunction [dbo].[FNARBookMap]    Script Date: 01/11/2011 09:35:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE FUNCTION [dbo].[FNARBookMap]
(
	@deal_id               INT,
	@level                 INT,
	@contract_id           INT,
	@counterparty_id       INT,
	@aggregation_level     INT
)
RETURNS INT
AS
BEGIN
	DECLARE @book_id INT	
	
	IF @aggregation_level = 19001
	    SELECT @book_id = CASE @level
	                           WHEN 1 THEN source_system_book_id1
	                           WHEN 2 THEN source_system_book_id2
	                           WHEN 3 THEN source_system_book_id3
	                           WHEN 4 THEN source_system_book_id4
	                           ELSE NULL
	                      END
	    FROM   source_deal_header sdh
	    WHERE  sdh.contract_id = @contract_id
	           AND sdh.counterparty_id = @counterparty_id
	ELSE
	    SELECT @book_id = CASE @level
	                           WHEN 1 THEN source_system_book_id1
	                           WHEN 2 THEN source_system_book_id2
	                           WHEN 3 THEN source_system_book_id3
	                           WHEN 4 THEN source_system_book_id4
	                           ELSE NULL
	                      END
	    FROM   source_deal_header sdh
	    WHERE  sdh.source_deal_header_id = @deal_id
	
	RETURN @book_id
END
