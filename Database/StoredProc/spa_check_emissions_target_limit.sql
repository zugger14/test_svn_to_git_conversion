/****** Object:  StoredProcedure [dbo].[spa_check_emissions_target_limit]    Script Date: 06/15/2009 20:52:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_check_emissions_target_limit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_check_emissions_target_limit]
/****** Object:  StoredProcedure [dbo].[spa_check_emissions_target_limit]    Script Date: 06/15/2009 20:52:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_check_emissions_target_limit]
	@sub_entity_id VARCHAR(100)=NULL,
	@strategy_entity_id VARCHAR(100)=NULL,
	@book_entity_id VARCHAR(100)=NULL,
	@generator_id INT=NULL,
	@term DATETIME=NULL	

AS
BEGIN

DECLARE @Sql_Select VARCHAR(5000)
DECLARE @Sql_Where VARCHAR(1000)
SET @Sql_Where=''
	CREATE TABLE #ssbm(                      
		 fas_book_id int,            
		 stra_book_id int,            
		 sub_entity_id int            
	)            

	CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])                  
	CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])                  
	CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])                  

	----------------------------------            
	SET @Sql_Select=            
		'INSERT INTO #ssbm            
		 SELECT                      
			  book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id             
		 FROM            
			 portfolio_hierarchy book (nolock)             
			 INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id               
		WHERE 1=1 '            
		IF @sub_entity_id IS NOT NULL            
		  SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' +@sub_entity_id + ') '             
		IF @strategy_entity_id IS NOT NULL            
		  SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' +@strategy_entity_id + ' ))'            
		IF @book_entity_id IS NOT NULL            
		  SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_entity_id + ')) '            

		SET @Sql_Select=@Sql_Select+@Sql_Where            
	EXEC spa_print @Sql_Select
	exec(@Sql_Select)





	SET @sql_select='
	SELECT * FROM 
		
	(	SELECT 
			ph.entity_name [OpCo],
			dbo.FNAEmissionHyperlink(3,12101500,rg.[name],rg.generator_id,''e'')  as Source,
			spcd.curve_name as [Emissions Type],
			year(ei.term_start) as [Term],
			CAST(SUM(ei.volume) AS DECIMAL(20,2)) as [Inventory],
			CAST(MAX(ei1.volume) AS DECIMAL(20,2)) as [Target],
			MAX(su.uom_name) as [UOM]
		FROM
			emissions_inventory ei
			INNER JOIN rec_generator rg ON ei.generator_id=rg.generator_id
				AND current_forecast<>''t''
			INNER JOIN #ssbm ssbm on ssbm.fas_book_id=rg.fas_book_id
			INNER JOIN source_price_curve_def spcd on ei.curve_Id=spcd.source_curve_def_id
			INNER JOIN source_uom su on su.source_uom_id=ei.uom_id
			INNER JOIN emissions_inventory ei1 on ei1.generator_id=ei.generator_id
				AND ei1.current_forecast=''t'' and ei.curve_id=ei1.curve_id		
				AND ((ei1.frequency=703 AND ei.term_start=ei1.term_start) OR (ei1.frequency=706 AND YEAR(ei.term_start)=YEAR(ei1.term_start)))
			LEFT JOIN static_data_value sd on sd.value_id=ei.forecast_type
			LEFT JOIN portfolio_hierarchy ph on ph.entity_id=rg.legal_entity_value_id
		
		WHERE 1=1'
		+CASE WHEN @term IS NOT NULL THEN ' AND year(ei.term_start)=year('''+CAST(@term AS VARCHAR)+''')' ELSE '' END
		+CASE WHEN @generator_id IS NOT NULL THEN ' AND ei.generator_id='''+CAST(@generator_id AS VARCHAR)+'''' ELSE '' END
		+' GROUP BY ph.entity_name,rg.[name],rg.generator_id,spcd.curve_name,year(ei.term_start)'
		+') a WHERE [Target]<[Inventory]'
	EXEC spa_print @sql_select
	EXEC(@sql_select)
			
END