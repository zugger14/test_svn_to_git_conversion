
/****** Object:  StoredProcedure [dbo].[spa_ems_source_model_report]    Script Date: 06/15/2009 20:51:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_source_model_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_source_model_report]
/****** Object:  StoredProcedure [dbo].[spa_ems_source_model_report]    Script Date: 06/15/2009 20:51:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_ems_source_model_report]    
	 @sub_entity_id varchar(500),     
	 @strategy_entity_id varchar(500),     
	 @book_entity_id varchar(500),             		
	 @group_by CHAR(1)='m',-- 'm' -Source Model, 's'- Emissions Sources
	 @generator_id VARCHAR(500) = null,            
	 @source_model_id VARCHAR(500) = null,             
	 @input_id VARCHAR(500)=null
	

AS  
SET NOCOUNT ON           
BEGIN


--###########################################
DECLARE @sql_Where VARCHAR(1000)
DECLARE @Sql_Select VARCHAR(8000)
SET @sql_Where = ''  

------------------------------------------
-------------------------------------------

          
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
			INNER JOIN            
			 Portfolio_hierarchy stra (nolock)            
			 ON book.parent_entity_id = stra.entity_id               
		WHERE 1=1 '            
		IF @sub_entity_id IS NOT NULL            
		  SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' +@sub_entity_id + ') '             
		 IF @strategy_entity_id IS NOT NULL            
		  SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' +@strategy_entity_id + ' ))'            
		  IF @book_entity_id IS NOT NULL            
		  SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_entity_id + ')) '            
		SET @Sql_Select=@Sql_Select+@Sql_Where            

	exec(@Sql_Select)
SET @sql_Where = ''  
	if  @generator_id is not  null
	SET @sql_Where = ' and rg.generator_id in ('  +@generator_id + ')'
	if  @source_model_id is not  null
	SET @sql_Where = ' and esm.ems_source_model_id in ('  +@source_model_id + ')'
	if  @input_id is not  null
	SET @sql_Where = ' and esi.ems_source_input_id in ('  +@input_id + ')'



----#########
	CREATE TABLE #temp_source(
		generator_id INT,
		generator_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		source_model_id INT,
		source_model_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		input_id INT,
		input_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		formula VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		curve_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		Series VARCHAR(100) COLLATE DATABASE_DEFAULT
	)


--CREATE TABLE #temp_final(
--		source_model_id INT,
--		input_name VARCHAR(1000) COLLATE DATABASE_DEFAULT,
--		formula VARCHAR(5000) COLLATE DATABASE_DEFAULT
--	)

	set @Sql_Select=' 
		INSERT INTO #temp_source
		SELECT 
			rg.generator_id,
			rg.[name],
			esm.ems_source_model_id,
			esm.ems_source_model_name,
			esi.ems_source_input_id,
			esi.input_name,
			dbo.FNAFNACurveNames(fe.formula),
			spcd.curve_name,
			sdv.code 
		FROM
			rec_generator rg
			INNER JOIN #ssbm on rg.fas_book_id=#ssbm.fas_book_id 
			INNER JOIN ems_source_model_effective esme on esme.generator_id=rg.generator_id
			INNER JOIN (select max(isnull(effective_date,''1900-01-01'')) effective_date,generator_id FROM 
							ems_source_model_effective WHERE 1=1 group by generator_id) ab
			on esme.generator_id=ab.generator_id and isnull(esme.effective_date,''1900-01-01'')=ab.effective_date
			INNER JOIN ems_source_Model esm on esm.ems_source_model_id=esme.ems_source_model_id
			INNER JOIN ems_input_map eim on eim.source_model_id=esm.ems_source_model_id
			INNER JOIN ems_source_input esi on esi.ems_source_input_id=eim.input_id
			INNER JOIN ems_source_model_detail esmd on esmd.ems_source_Model_id=	esm.ems_source_Model_id
			INNER JOIN ems_source_formula esf on esmd.ems_source_Model_detail_id=	esf.ems_source_Model_detail_id
			LEFT JOIN formula_nested fn on fn.formula_group_id=esf.formula_id
			LEFT JOIN formula_editor fe on fe.formula_id=ISNULL(fn.formula_id,esf.formula_id)
			LEFT JOIN static_data_value sdv ON sdv.value_id=esf.forecast_type
		LEFT JOIN source_price_curve_def spcd on spcd.source_curve_def_id=esmd.curve_id
where 1=1' + @sql_Where 
	--	exec spa_print @Sql_Select
	EXEC(@Sql_Select)

--select * from #temp_source
--
--	SELECT 
--	 dbo.FNAEmissionHyperlink(2,12101400,source_model_name,source_model_id,NULL) [Source Model],	  
--	  REPLACE(REPLACE(REPLACE(REPLACE(RTRIM((SELECT  CAST(row_number() OVER (PARTITION BY source_model_id order by source_model_id) AS VARCHAR) +'. '+generator_name+ cast(generator_id as varchar)+ ' :: ' FROM #temp_source WHERE (source_model_id = Results.source_model_id) GROUP BY source_model_id,generator_name,generator_id FOR XML PATH (''))),'',''),'::','<br>'),'&lt;','<'),'&gt;','>') AS [Source]
--	  --REPLACE(REPLACE( REPLACE(REPLACE(RTRIM((SELECT  CAST(row_number() OVER (PARTITION BY source_model_id order by source_model_id) AS VARCHAR) +'. '+input_name  + ' :: ' FROM #temp_source WHERE (source_model_id = Results.source_model_id) GROUP BY source_model_id,input_name,input_id FOR XML PATH (''))),'',''),'::','<br>'),'&lt;','<'),'&gt;','>') AS Inputs,
--	  --curve_name [Emissions Type],
--	 -- REPLACE(REPLACE(RTRIM((SELECT  CAST(row_number() OVER (PARTITION BY source_model_id,curve_name order by source_model_id) AS VARCHAR) +'. '+formula + ' : ' FROM #temp_source WHERE (source_model_id = Results.source_model_id AND curve_name=Results.curve_name) GROUP BY source_model_id,formula,curve_name  FOR XML PATH (''))),'',''),':','<br>') AS Formula
--	FROM 
--		#temp_source Results
--	GROUP BY 
--		source_model_id,source_model_name,curve_name,dbo.FNAEmissionHyperlink(2,12101400,source_model_name,source_model_id,NULL)

--
	SELECT 
	 dbo.FNAEmissionHyperlink(2,12101400,source_model_name,source_model_id,NULL) [Source Model],	  
	  CAST(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM((SELECT  CAST(row_number() OVER (PARTITION BY source_model_id order by source_model_id) AS VARCHAR) +'. '+dbo.FNAEmissionHyperlink(3,12101510,generator_name,generator_id,'''e''') + ' :: ' FROM #temp_source WHERE (source_model_id = Results.source_model_id) GROUP BY source_model_id,generator_name,generator_id FOR XML PATH (''))),'',''),'::','<br>'),'&lt;','<'),'&gt;','>')  AS VARCHAR(8000)) AS [Source],
	  REPLACE(REPLACE( REPLACE(REPLACE(RTRIM((SELECT  CAST(row_number() OVER (PARTITION BY source_model_id order by source_model_id) AS VARCHAR) +'. '+dbo.FNAEmissionHyperlink(2,12101300,input_name,input_id,NULL)  + ' :: ' FROM #temp_source WHERE (source_model_id = Results.source_model_id) GROUP BY source_model_id,input_name,input_id FOR XML  PATH (''))),'',''),'::','<br>'),'&lt;','<'),'&gt;','>') AS Inputs,
	  curve_name [Emissions Type],
	  Series,

	  REPLACE(REPLACE(RTRIM((SELECT  CAST(row_number() OVER (PARTITION BY source_model_id,curve_name,Series order by source_model_id) AS VARCHAR) +'. '+formula + ' : ' FROM #temp_source WHERE (source_model_id = Results.source_model_id AND curve_name=Results.curve_name AND series=Results.series) GROUP BY source_model_id,formula,curve_name,series  FOR XML PATH (''))),'',''),':','<br>') AS Formula
	FROM 
		#temp_source Results
	GROUP BY 
		source_model_id,source_model_name,curve_name,dbo.FNAEmissionHyperlink(2,12101400,source_model_name,source_model_id,NULL),Series



END












