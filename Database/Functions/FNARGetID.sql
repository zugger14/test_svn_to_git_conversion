SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNARGetID]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNARGetID]
GO

CREATE FUNCTION [dbo].[FNARGetID](@type VARCHAR(150), @catagory VARCHAR(150), @value VARCHAR(150) )
	RETURNS INT
AS
BEGIN
DECLARE @return_value INT
DECLARE @type_id INT 
DECLARE @source_system_book_type_value_id INT 

IF @type = 'STATIC'
BEGIN
	SELECT @type_id = [type_id]
	FROM   static_data_type
	WHERE  [type_name] = @catagory

	SELECT @return_value = value_id
	FROM   static_data_value
	WHERE  TYPE_ID = @type_id
	       AND code = @value

END

IF @type = 'BOOK'
BEGIN
	SELECT @source_system_book_type_value_id = CASE 
				WHEN group1 = @catagory THEN 50
				WHEN group2 = @catagory THEN 51
				WHEN group3 = @catagory THEN 52
				WHEN group4 = @catagory THEN 53
		   END
	FROM   source_book_mapping_clm 
	
	
	SELECT @return_value = source_book_id
	FROM   source_book
	WHERE  source_system_book_type_value_id = @source_system_book_type_value_id
		   AND source_system_book_id = @value
	
END
RETURN @return_value

END