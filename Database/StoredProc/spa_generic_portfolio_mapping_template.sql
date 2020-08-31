
IF OBJECT_ID(N'[dbo].[spa_generic_portfolio_mapping_template]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_generic_portfolio_mapping_template]
GO 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_generic_portfolio_mapping_template]
    @flag								CHAR(1)
	, @mapping_source_id				INT	-- sdv 23200 - Maintain Limit, 23202 - Portfolio Group, 23201 - Whatif
	, @mapping_source_value_id			INT = NULL
	, @xml								NVARCHAR(MAX)	-- portfolio details like Portfolio,Deal,Filters 

AS
--/*
--DECLARE @flag CHAR(1) ='i'
--, @mapping_source_id INT =23200
--, @mapping_source_value_id INT = 4 -- limit id
--, @xml NVARCHAR(MAX) ='<Root>
--	<MappingXML  sub_book_id="" deal_ids="" trader="131,132" commodity_id="233,284" deal_type_id="" counterparty_id="" fixed_term="0" term_start="" term_end="" relative_term="0" starting_month="0" no_of_month="0"></MappingXML>
--</Root>'
----*/
SET NOCOUNT ON	

DECLARE @xml_table_name VARCHAR(200)
	, @sql VARCHAR(MAX)
	, @mapping_source_detail VARCHAR(MAX)
	, @col_list_header  VARCHAR(MAX)
	, @portfolio_mapping_source_id INT


IF @flag IN ('i', 'u')
BEGIN
	IF NULLIF(@xml, '') IS NOT NULL
	BEGIN
		IF OBJECT_ID('tempdb..#xml_process_table_name') is not null DROP TABLE #xml_process_table_name
	
		CREATE TABLE #xml_process_table_name(table_name VARCHAR(200) COLLATE DATABASE_DEFAULT  )

		INSERT INTO #xml_process_table_name EXEC spa_parse_xml_file 'b', NULL, @xml
		SELECT @xml_table_name = table_name FROM #xml_process_table_name
		--select * from #xml_process_table_name

		--collect dynamic coulmn name	
		SELECT @col_list_header = COALESCE(''  + @col_list_header + ',', '') + '' + 
				COLUMN_NAME + '  VARCHAR(MAX) '
		FROM   adiha_process.INFORMATION_SCHEMA.[COLUMNS] c
		WHERE  'adiha_process.dbo.' + TABLE_NAME = @xml_table_name
				AND c.COLUMN_NAME <> 'ROWID'
		ORDER BY
				ORDINAL_POSITION
		--select 'column name', @col_list_header
		
	
		SET @mapping_source_detail = dbo.FNAProcessTableName('mapping_source_detail_', dbo.FNADBUser(),dbo.FNAGetNewID())
		EXEC ('CREATE TABLE ' + @mapping_source_detail + '(' + @col_list_header + ')')
		EXEC('INSERT INTO ' + @mapping_source_detail + ' SELECT * FROM ' +  @xml_table_name)		
		
	END
	ELSE
	RETURN
		
	--if data on portfolio_mapping_source does not exist then insert
		IF NOT EXISTS(SELECT 1 FROM portfolio_mapping_source pms WHERE pms.mapping_source_value_id = @mapping_source_id AND pms.mapping_source_usage_id = @mapping_source_value_id)
		BEGIN
			INSERT INTO portfolio_mapping_source
			(
				mapping_source_value_id,
				mapping_source_usage_id
			)
			VALUES
			(
				@mapping_source_id,
				@mapping_source_value_id
			)
		END

		SELECT @portfolio_mapping_source_id = portfolio_mapping_source_id 
		FROM portfolio_mapping_source 
		WHERE mapping_source_value_id = @mapping_source_id AND mapping_source_usage_id = @mapping_source_value_id
		
		--portfolio_group_id is optional component. So need to check its existence before inserting/updating into physical table.
		IF EXISTS(SELECT 1
					FROM   adiha_process.INFORMATION_SCHEMA.[COLUMNS] c
					WHERE  'adiha_process.dbo.' + TABLE_NAME = @mapping_source_detail
							AND c.COLUMN_NAME IN ('portfolio_group_id')
					)
		BEGIN
			EXEC('UPDATE a SET portfolio_group_id =  NULLIF(x.portfolio_group_id, '''') FROM portfolio_mapping_source a CROSS JOIN  ' + @mapping_source_detail + ' x 
				WHERE  a.portfolio_mapping_source_id = ' + @portfolio_mapping_source_id)

		END	

		--Delete existing record for given source id of source
		DELETE FROM   portfolio_mapping_book WHERE  portfolio_mapping_source_id = @portfolio_mapping_source_id
		DELETE FROM   portfolio_mapping_deal WHERE  portfolio_mapping_source_id = @portfolio_mapping_source_id
		DELETE FROM   portfolio_mapping_commodity WHERE  portfolio_mapping_source_id = @portfolio_mapping_source_id
		DELETE FROM   portfolio_mapping_trader WHERE  portfolio_mapping_source_id = @portfolio_mapping_source_id
		DELETE FROM   portfolio_mapping_counterparty WHERE  portfolio_mapping_source_id = @portfolio_mapping_source_id
		DELETE FROM   portfolio_mapping_deal_type WHERE  portfolio_mapping_source_id = @portfolio_mapping_source_id
		DELETE FROM   portfolio_mapping_tenor WHERE  portfolio_mapping_source_id = @portfolio_mapping_source_id

		--Tenor filter is optional component. So need to check its existence before inserting into physical table.
			IF EXISTS(SELECT 1
						FROM   adiha_process.INFORMATION_SCHEMA.[COLUMNS] c
						WHERE  'adiha_process.dbo.' + TABLE_NAME = @mapping_source_detail
								AND c.COLUMN_NAME IN ('fixed_term'
												, 'term_start'
												, 'term_end'
												, 'relative_term'
												, 'starting_month'
												, 'no_of_month')
						)
			BEGIN
				SET @sql = 'INSERT INTO portfolio_mapping_tenor
							(
								portfolio_mapping_source_id,
								fixed_term,
								term_start,
								term_end,
								relative_term,
								starting_month,
								no_of_month
							)
							SELECT ' + CAST(@portfolio_mapping_source_id AS VARCHAR(8)) + ' 
								, fixed_term
								, NULLIF(term_start, '''')
								, NULLIF(term_end, '''')
								, relative_term
								, NULLIF(starting_month, '''')
								, NULLIF(no_of_month, '''')
							FROM ' + @mapping_source_detail

				--PRINT ' portfolio_mapping_tenor : ' + @sql
				EXEC(@sql)
			END
			
			
			--Only for compulsory component list.
			SET @sql = 'INSERT INTO portfolio_mapping_book (portfolio_mapping_source_id, [entity_id])
						SELECT ' + CAST(@portfolio_mapping_source_id as varchar) + ' , i.item FROM ' + @mapping_source_detail + ' rs_main 
						CROSS APPLY dbo.SplitCommaSeperatedValues(rs_main.sub_book_id) as i'

			--PRINT ' portfolio_mapping_book : ' + @sql
			EXEC(@sql)
			
			SET @sql = 'INSERT INTO portfolio_mapping_deal (portfolio_mapping_source_id, deal_id)
						SELECT ' + CAST(@portfolio_mapping_source_id as varchar) + ' , i.item FROM ' + @mapping_source_detail + ' rs_main 
						CROSS APPLY dbo.SplitCommaSeperatedValues(rs_main.deal_ids) as i'

			--PRINT ' portfolio_mapping_deal : ' + @sql
			EXEC(@sql)
					
			SET @sql = 'INSERT INTO portfolio_mapping_trader (portfolio_mapping_source_id, trader_id)
						SELECT ' + CAST(@portfolio_mapping_source_id as varchar) + ' , i.item FROM ' + @mapping_source_detail + ' rs_main 
						CROSS APPLY dbo.SplitCommaSeperatedValues(rs_main.trader) as i'

			--PRINT ' portfolio_mapping_trader : ' + @sql
			EXEC(@sql)
			
			SET @sql = 'INSERT INTO portfolio_mapping_counterparty (portfolio_mapping_source_id, counterparty_id)
						SELECT ' + CAST(@portfolio_mapping_source_id as varchar) + ' , i.item FROM ' + @mapping_source_detail + ' rs_main 
						CROSS APPLY dbo.SplitCommaSeperatedValues(rs_main.counterparty_id) as i'

			--PRINT ' portfolio_mapping_counterparty : ' + @sql
			EXEC(@sql)
			
			
			SET @sql = 'INSERT INTO portfolio_mapping_commodity (portfolio_mapping_source_id, commodity_id)
						SELECT ' + CAST(@portfolio_mapping_source_id as varchar) + ' , i.item FROM ' + @mapping_source_detail + ' rs_main 
						CROSS APPLY dbo.SplitCommaSeperatedValues(rs_main.commodity_id) as i'

			--PRINT ' portfolio_mapping_commodity : ' + @sql
			EXEC(@sql)

			SET @sql = 'INSERT INTO portfolio_mapping_deal_type (portfolio_mapping_source_id, deal_type_id)
						SELECT ' + CAST(@portfolio_mapping_source_id as varchar) + ' , i.item FROM ' + @mapping_source_detail + ' rs_main 
						CROSS APPLY dbo.SplitCommaSeperatedValues(rs_main.deal_type_id) as i'

			--PRINT ' portfolio_mapping_deal_type : ' + @sql
			EXEC(@sql)
END --ends flag i/u
