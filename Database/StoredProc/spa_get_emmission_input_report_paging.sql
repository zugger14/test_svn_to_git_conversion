IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_get_emmission_input_report_paging]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_get_emmission_input_report_paging]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go






-- =====================================================================================================================================
-- Author:<Sudeep Lamsal>
-- Created date: <8th April, 2010>
-- Last Update date: <>
-- Update By: <>
-- Description:	<>
-- =======================================================================================================================================

--CREATE PROCEDURE [dbo].[spa_get_emmission_input_report_paging]
CREATE PROCEDURE [dbo].[spa_get_emmission_input_report_paging]
	@Plot char(1),
	@generator_id VARCHAR(200),
	@curve_id int=NULL,
	@convert_uom_id int=NULL,
	@as_of_date VARCHAR(50),
	@term_start VARCHAR(50),--Datetime=NULL,
	@term_end VARCHAR(50),--Datetime=NULL
	@sub_entity_id varchar(100)=null,
	@strategy_entity_id varchar(100),
	@book_entity_id varchar(100)=null,
	@generator_group_name varchar(500)=null,
	--- EXTRA FILTERS --
	@technology int = null,
	@fuel_value_id int=null,
	@technology_sub_type int=null,
	@fuel_type int=null,
	@ems_book_id varchar(200)=null,
	@reduction_type int = NULL, 
	@reduction_sub_type int = NULL,
	@udf_source_sink_group int=null,
	@udf_group1 int=null,
	@udf_group2 int=null,
	@udf_group3 int=null,
	---- Add New Parameters in this block -----
	@period_frequency INT = 704,
	---- END (Add New Parameters) -----
	------- DRILL DOWN -------
	@drill_term_start varchar(50)=null,
	@drill_curve_id VARCHAR(100)=NULL,
	------- NEW Filters -----
	@show_value_id int=null,
	@forecast_type int=null,
	------- Paging -----------
	@process_id varchar(MAX)=NULL, 
	@page_size int =NULL,
	@page_no int=NULL
	
AS
	SET NOCOUNT ON 
	DECLARE @user_login_id varchar(max)
	DECLARE @tempTable varchar(max) 
	DECLARE @flag char(1)
	DECLARE @sqlStmt varchar(MAX)
	
	SET @user_login_id=dbo.FNADBUser()

	IF @process_id is NULL
	BEGIN
		SET @flag='i'
		SET @process_id=REPLACE(newid(),'-','_')
	END
	SET @tempTable=dbo.FNAProcessTableName('paging_temp_inputLimit_Report', @user_login_id,@process_id)
	
	--
	if @flag='i'
	BEGIN
		if ((@Plot = 'n') OR (@Plot = 'v'))
			SET @sqlStmt='CREATE TABLE '+ @tempTable+'( 
				sno INT  identity(1,1) NOT NULL
				,source_sink_name VARCHAR(500) NULL
				,ems_source_model_name VARCHAR(100) NULL
				,curve_name VARCHAR(100) NULL
				,term_start VARCHAR(100) NULL
				,limit_definition VARCHAR(500) NULL
				,source_series_type VARCHAR(100)
				,output_value FLOAT NULL
				,lower_limit_value FLOAT NULL
				,upper_limit_value FLOAT NULL
				,uom_name VARCHAR(100) NULL
				,Violation CHAR(1) NULL
				)'
		EXEC(@sqlStmt)
		set @sqlStmt=' INSERT INTO '+@tempTable+'
		exec  spa_get_emmission_input_report '+ 
		dbo.FNASingleQuote(@Plot) +','+
		dbo.FNASingleQuote(@generator_id) +','+
		dbo.FNASingleQuote(@curve_id) +','+
		dbo.FNASingleQuote(@convert_uom_id) +','+
		dbo.FNASingleQuote(@as_of_date) +','+
		dbo.FNASingleQuote(@term_start) +','+
		dbo.FNASingleQuote(@term_end) +','+
		dbo.FNASingleQuote(@sub_entity_id) +','+
		dbo.FNASingleQuote(@strategy_entity_id) +','+
		dbo.FNASingleQuote(@book_entity_id) +','+
		dbo.FNASingleQuote(@generator_group_name) +','+
		dbo.FNASingleQuote(@technology) +','+
		dbo.FNASingleQuote(@fuel_value_id) +','+
		dbo.FNASingleQuote(@technology_sub_type) +','+
		dbo.FNASingleQuote(@fuel_type) +','+
		dbo.FNASingleQuote(@ems_book_id) +','+
		dbo.FNASingleQuote(@reduction_type) +','+
		dbo.FNASingleQuote(@reduction_sub_type) +','+
		dbo.FNASingleQuote(@udf_source_sink_group) +','+
		dbo.FNASingleQuote(@udf_group1) +','+
		dbo.FNASingleQuote(@udf_group2) +','+
		dbo.FNASingleQuote(@udf_group3) +','+
		dbo.FNASingleQuote(@period_frequency) +','+
		dbo.FNASingleQuote(@drill_term_start) +','+
		dbo.FNASingleQuote(@drill_curve_id)+','+
		dbo.FNASingleQuote(@show_value_id) +','+
		dbo.FNASingleQuote(@forecast_type)
		--print @sqlStmt
		exec(@sqlStmt)	
		
		set @sqlStmt='select count(*) TotalRow,'''+@process_id +''' process_id  from '+ @tempTable
		EXEC spa_print @sqlStmt
		exec(@sqlStmt)
	END
	ELSE
	BEGIN
		DECLARE @row_to int
		DECLARE @row_from int
		SET @row_to=@page_no * @page_size
		IF @page_no > 1 
			SET @row_from =((@page_no-1) * @page_size)+1
		ELSE
			SET @row_from =@page_no

		--PRINT @row_from
		EXEC spa_print @row_to
	END
DECLARE @call_from varchar(5)

	SET @call_from = 's'
	if ((@Plot = 'n') OR (@Plot = 'v'))
		Begin
			set @sqlStmt=
			'SELECT
				source_sink_name AS [Source/Sink Name]
				,ems_source_model_name AS [Source Model Name]
				,curve_name AS [Pollutant]
				,term_start AS [Term]
				,limit_definition AS [Limit Definition]
				,source_series_type AS [Series Type]
				,output_value AS [Sample Value]
				,lower_limit_value AS [Lower Limit]
				,upper_limit_value AS [Upper Limit]
				,uom_name AS [Unit of Measure]
				,Violation 
			FROM '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'
		End
	
		--PRINT @sqlStmt
		EXEC(@sqlStmt)



