IF OBJECT_ID(N'[dbo].[FNASearchParser]', N'TF') IS NOT NULL
    DROP FUNCTION [dbo].[FNASearchParser]

GO

--select * from [dbo].[FNASearchParser]('counterparty = ABC; broker = cde')

CREATE FUNCTION [dbo].[FNASearchParser]
(@List AS VARCHAR(8000), @table_name VARCHAR(500))
RETURNS @Items TABLE(clmn varchar(500), search_string varchar(500), operator CHAR(2))
AS
BEGIN
	DECLARE @Item				AS VARCHAR(8000)
	DECLARE @Pos				AS INT
	DECLARE @Posi				AS INT
	DECLARE @column				VARCHAR(100)
	DECLARE @searchString		VARCHAR(100)
	DECLARE @operator			CHAR(2)
	DECLARE @second_operator	CHAR(1)
	
	IF(SUBSTRING(LTRIM(RTRIM(@List)), LEN(LTRIM(RTRIM(@List))), 1) = ';')
	BEGIN
		SET @List =  SUBSTRING(LTRIM(RTRIM(@List)), 0, LEN(LTRIM(RTRIM(@List))))
	END

	
	
	WHILE DATALENGTH(@List) > 0
	BEGIN
	    SET @Pos = CHARINDEX(';', @List)
	    
	    IF @Pos = 0
	        SET @Pos = DATALENGTH(@List) + 1
	    
	    SET @Item = LTRIM(RTRIM(LEFT(@List, @Pos -1)))
	    
	    IF @Item <> ''
	    BEGIN
	        --SET @Posi = CHARINDEX('=', @Item)
	        select @posi = CASE 
							   WHEN (CHARINDEX('<', @Item) <> 0) THEN CHARINDEX('<', @Item)
							   WHEN (CHARINDEX('>', @Item) <> 0) THEN CHARINDEX('>', @Item)
							   WHEN (CHARINDEX('=', @Item) <> 0) THEN CHARINDEX('=', @Item)
							   ELSE ''
						   END
	        
	        IF @Posi = 0
	            SET @Posi = DATALENGTH(@Item) + 1
	        
	        SET @column = LTRIM(RTRIM(LEFT(@Item, @Posi -1)))
	        SET @operator = SUBSTRING(@Item, @posi, 1)
	        SET @second_operator = SUBSTRING(@Item, @posi + 1, 1)
	        IF @second_operator = '='
	        BEGIN
	        	SET @operator = LTRIM(RTRIM(@operator)) + LTRIM(RTRIM(@second_operator))
	        	SET @searchString = SUBSTRING(@Item, @Posi + 2, LEN(@item))
	        END
			ELSE
			BEGIN
				SET @searchString = SUBSTRING(@Item, @Posi + 1, LEN(@item))
			END
			
			IF @table_name = 'master_deal_view'
			BEGIN
				IF (@column = 'dealdate' OR @column = 'deal date')
					SET @column = 'deal_date'
				IF @column = 'termstart' OR @column = 'term start'
					SET @column = 'term_start'
				IF @column = 'termend' OR @column = 'term end'
					SET @column = 'term_end'
				IF @column = 'physical financial' OR @column = 'physical/financial'
					SET @column = 'physical_financial'
				IF @column = 'buy sell' OR @column = 'buy/sell'
					SET @column = 'buy_sell'
				IF @column = 'deal category'
					SET @column = 'deal_category'
				IF @column = 'deal type'
					SET @column = 'deal_type'
				IF @column = 'forecast profile'
					SET @column = 'forecast_profile'
				IF @column = 'block definition'
					SET @column = 'block_definition'
				IF @column = 'formula'
					SET @column = 'deal_formula'
				IF @column = 'reference id' OR @column = 'reference_id'
					SET @column = 'deal_id'																												
			END
			ELSE IF @table_name = 'source_counterparty'
			BEGIN
				IF @column = 'counterparty'
					SET @column = 'counterparty_id'
				ELSE IF @column = 'counterparty_id' OR @column = 'counterpartyid' OR @column = 'counterparty id'
					SET @column = 'source_counterparty_id'
			END
	    	
			IF @column = 'deal_date' OR @column = 'term_start' OR @column = 'term_end'
				SET @searchString = '' + @searchString + ''
			ELSE IF (CHARINDEX(' OR ', @searchString) <> 0) OR (CHARINDEX(' AND ', @searchString) <> 0)
				SET @searchString = '' + RTRIM(LTRIM(@searchString)) + ''
			ELSE
				SET @searchString = '"' + @searchString + '"'
																				
	        INSERT INTO @Items VALUES (@column, @searchString, @operator)
	    END
	    
	    SET @List = SUBSTRING(@List, @Pos + DATALENGTH(','), 8000)
	END
	RETURN
END







