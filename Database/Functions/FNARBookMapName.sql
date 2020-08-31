/****** Object:  UserDefinedFunction [dbo].[FNARBookMapName]    Script Date: 01/11/2011 09:36:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARBookMapName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARBookMapName]
GO

/****** Object:  UserDefinedFunction [dbo].[FNARBookMapName]    Script Date: 01/11/2011 09:35:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE FUNCTION [dbo].[FNARBookMapName] (@deal_id int, -- @deal_id is @source_deal_detail_id
									  @level int)
RETURNS VARCHAR(MAX) AS  
BEGIN 
	DECLARE @book_id INT
	DECLARE @book_name VARCHAR(100)
	 SELECT   @book_id = CASE @level WHEN 1 THEN source_system_book_id1 WHEN 2 THEN  source_system_book_id2
									 WHEN 3 THEN source_system_book_id3 WHEN 4 THEN  source_system_book_id4 ELSE NULL END
	FROM	source_deal_header sdh 
	WHERE sdh.source_deal_header_id=@deal_id
	
	SELECT @book_name = source_book_name FROM
	source_book WHERE source_book_id = @book_id



	RETURN @book_name 
END