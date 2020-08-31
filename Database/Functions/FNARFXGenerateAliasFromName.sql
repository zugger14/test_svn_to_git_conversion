IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARFXGenerateAliasFromName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARFXGenerateAliasFromName]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================
-- Create date: 2013-04-12 2:40PM
-- Description:	Generates sql compatible name to be used as alias name from the provided name. 
-- Takes first character of ever word separated by space and underscore.
-- ========================================================================
CREATE FUNCTION [dbo].[FNARFXGenerateAliasFromName](@fq_table_name VARCHAR(1000))
RETURNS VARCHAR(100)
AS
BEGIN
/**********************TEST CODE START****************/
	--DECLARE @fq_table_name VARCHAR(1000) = 'test_test - Monthly price plot'

/**********************TEST CODE START****************/
	DECLARE @alias VARCHAR(100)

	--space separated	
	DECLARE @table_name_parts_sc AS TABLE(id INT IDENTITY(1, 1), part VARCHAR(500))
	DECLARE @table_name_parts_final AS TABLE(id INT IDENTITY(1, 1), part VARCHAR(500))
	
	INSERT INTO @table_name_parts_sc(part)
	SELECT scsv.item
	FROM dbo.FNASplit(@fq_table_name, ' ') scsv
	
	--SELECT * FROM @table_name_parts_sc
	
	INSERT INTO @table_name_parts_final(part)
	SELECT scsv.item
	FROM @table_name_parts_sc tnpsc
	OUTER APPLY dbo.FNASplit(tnpsc.part, '_') scsv
	ORDER BY tnpsc.id
	
	--SELECT * FROM @table_name_parts_final
	
	 SELECT @alias = (
			SELECT '' + LEFT(part, 1) 
			FROM @table_name_parts_final tnpf
			WHERE part IS NOT NULL AND part <> '-'
			ORDER BY id
			FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)')	
			
	/*
	* To Prevent the formation of exponential numeric values such as '00000e1' when the alias is generated as 'e' another 'e' is concated to form 
	  '00000ee1' which is non numeric
	*/
	IF @alias IN ('e' , 'd')
	BEGIN
		SET @alias = @alias + 'e'
	END			
	
	RETURN @alias
END

GO

