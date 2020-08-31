IF OBJECT_ID(N'dbo.spa_rfx_grab_data_source_columns', N'P') IS NOT NULL
	DROP PROCEDURE dbo.spa_rfx_grab_data_source_columns
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================================================
-- Create date: 2012-09-11
-- Author : ssingh@pioneersolutionsglobal.com
-- Description: Retrieves column inforamtion of the data_source_id passed from the application. 
               
-- Params:
-- @data_source_id				INT			  : data_source_id of the source
-- @data_source_process_id		VARCHAR(50) : process_id passed 
-- @criteria					VARCHAR(5000) : parameter AND their values 
-- @@with_criteria              CHAR(1): 'n':criteria not provided , 'y': criteria provided
--                                      while calling this procedure this value is always passed as 'n' by default.
--                                      In the CASE where
--                                      1. The source contains refered view binded by {} THEN the underlying complete sql is passed to the php
--											which list the criteria involved AND calls this sp again with 'y' value.
-- ============================================================================================================================

CREATE PROCEDURE [dbo].[spa_rfx_grab_data_source_columns]
	@data_source_id					INT 
	, @data_source_process_id		VARCHAR(100) = NULL
	, @criteria						VARCHAR(5000) = NULL
	, @data_source_tsql				VARCHAR(MAX) = NULL
	, @with_criteria                CHAR(1) = 'y'
	, @call_from					VARCHAR(100) = NULL
AS
/*-------------------------------------------------Test Script-------------------------------------------------------*/
/*
 DECLARE 
	@data_source_id					INT =5
	, @data_source_process_id		VARCHAR(100) = '2B3207CC_04F0_42DF_9992_4A1295887DEE' 
	, @criteria						VARCHAR(5000) = ''
	, @data_source_tsql				VARCHAR(MAX) = ''
	, @with_criteria CHAR(1) = 'y'
		, @call_from VARCHAR(100) = 'ds_view'
--*/
/*-------------------------------------------------Test Script END -------------------------------------------------------*/
	SET NOCOUNT ON
	--DECLARE @data_source_tsql   VARCHAR(MAX)
	DECLARE @data_source_alias				VARCHAR(50)
	DECLARE @data_source_process_table_name VARCHAR(200)

	IF NULLIF(@data_source_process_id, 'NULL') IS NULL 
	BEGIN 
		SET @data_source_process_id = dbo.FNAGetNewID();
	END 

	IF @call_from = 'ds_view'
	BEGIN
		SELECT dsc.data_source_column_id [column_id],
				dsc.name [column_name],
				dsc.alias [ALIAS],
				dsc.reqd_param [reqd_param],
				dsc.append_filter [append_filter],
				dsc.datatype_id [data_type],
				dsc.datatype_id [data_type],
				dsc.widget_id [widget_id],
				dsc.param_default_value [param_default_value],
				dsc.param_data_source [param_data_source],
				dsc.tooltip,
				dsc.column_template,
				dsc.key_column,
				dsc.required_filter required_filter
		FROM   data_source ds
		INNER JOIN data_source_column dsc 
			ON  ds.data_source_id = dsc.source_id		
		WHERE  ds.data_source_id = @data_source_id 
			ORDER BY dsc.alias
					,dsc.name
		RETURN
	END
		
	IF NULLIF(@data_source_tsql, '') IS NULL
	BEGIN
		SELECT @data_source_tsql = ds.[tsql], @data_source_alias = ds.alias 
		FROM data_source ds
		WHERE ds.data_source_id = @data_source_id	
	END
	ELSE 
	BEGIN
		SET @data_source_alias = ''
	END

	/** CREATE PROCESS TABLE FOR FORMULA BASED VIEW DATA SOURCE - START **/
	------ check if view category is Functions and it has filter defined @formula_table
	IF (CHARINDEX('formula_input_table', @criteria, 0) > 0)
	BEGIN
		---replace 1900 value by predefined process table name, and this will be created as below table definition and hence the sp using this table as a parameter will execute successfully.
		SET @criteria = REPLACE(@criteria, 'formula_input_table = 1900', 'formula_input_table = adiha_process.dbo.formula_input_table_1900')
		
		IF OBJECT_ID('adiha_process.dbo.formula_input_table_1900') IS NULL
		BEGIN
			CREATE TABLE adiha_process.dbo.formula_input_table_1900 (
				rowid INT IDENTITY(1,1),
				counterparty_id INT,
				contract_id INT,
				curve_id INT,
				prod_date DATETIME,
				as_of_date DATETIME,
				volume FLOAT,
				onPeakVolume FLOAT,
				source_deal_header_id INT,
				source_deal_detail_id INT,
				formula_id INT,
				invoice_Line_item_id INT,           
				invoice_line_item_seq_id INT,
				price FLOAT,           
				granularity INT,
				volume_uom_id INT,
				generator_id INT,
				[Hour] INT,
				[mins] INT,
				is_dst INT,
				commodity_id INT,
				meter_id INT,
				curve_source_value_id INT,
				calc_aggregation INT,
				term_start DATETIME,
				term_end DATETIME,
				ticket_it INT,
				shipment_id INT
			)
		END
		
	END


	/** CREATE PROCESS TABLE FOR FORMULA BASED VIEW DATA SOURCE - END **/
	
	SET @data_source_process_table_name = REPLACE(dbo.FNAProcessTableName('report_dataset_' + @data_source_alias, dbo.FNADBUser(), @data_source_process_id), 'adiha_process.dbo.', '')   
	
	EXEC [dbo].[spa_rfx_handle_data_source]
	     @data_source_tsql,
	     @data_source_alias,
	     @criteria,
	     @data_source_process_id
	     , 1 --@handle_single_line_sql			
	     , 1 --@validate				
	     , NULL
         , @with_criteria

	IF @with_criteria = 'y'
	BEGIN
		IF EXISTS(
			SELECT TOP 1 1
			FROM   adiha_process.INFORMATION_SCHEMA.[COLUMNS]
			WHERE  TABLE_NAME = @data_source_process_table_name 
				AND COLUMN_NAME = 'error_status' 
		)
		BEGIN
			EXEC('SELECT error_status, error_msg, error_line from adiha_process.dbo.' + @data_source_process_table_name)
		END
		ELSE 
		BEGIN
			SELECT ds_saved.[column_id],
				   c.column_name,
				   ISNULL(ds_saved.[alias], 
				   CASE c.column_name
					WHEN 'counterparty_id' THEN	'Counterparty ID'
					WHEN 'counterparty_name' THEN 'Counterparty'
					WHEN 'counterparty_code' THEN 'Counterparty Code'
					WHEN 'source_deal_header_id' THEN 'Deal ID'
					WHEN 'deal_id' THEN 'Reference ID'
					WHEN 'curve_id' THEN 'Curve ID'
					WHEN 'curve_name' THEN 'Index'
					WHEN 'curve_code' THEN 'Curve Code'
					WHEN 'as_of_date' THEN 'As of Date'
					WHEN 'to_as_of_date' THEN 'As of Date To'
					WHEN 'group1' THEN 'Book ID1'
					WHEN 'group2' THEN 'Book ID2'
					WHEN 'group3' THEN 'Book ID3'
					WHEN 'group4' THEN 'Book ID4'
					WHEN 'sub_id' THEN 'Subsidiary ID'
					WHEN 'sub' THEN 'Subsidiary'
					WHEN 'stra_id' THEN 'Strategy ID'
					WHEN 'stra' THEN 'Strategy'
					WHEN 'book_id' THEN 'Book ID'
					WHEN 'book' THEN 'Book'
					WHEN 'sub_book_id' THEN 'Sub Book ID'
					WHEN 'sub_book' THEN 'Sub Book'
					WHEN 'physical_financial_flag' THEN 'Physical Financial'
					WHEN 'buy_sell_flag' THEN 'Buy Sell'
					WHEN 'location_id' THEN 'Location ID'
					WHEN 'volume_uom' THEN 'Volume UOM'
					WHEN 'trader_id' THEN 'Trader ID'
					WHEN 'contract_id' THEN 'Contract ID'
					ELSE dbo.FNAInitCap(REPLACE(c.column_name, '_', ' '))
				   END)  [alias],
				   ds_saved.[reqd_param],
				   ds_saved.[append_filter],
				   c.DATA_TYPE [data_type],
				   rdt.report_datatype_id [datatype_id],
				   ds_saved.[widget_id],
				   ds_saved.[param_default_value],
				   ds_saved.[param_data_source],
				   ds_saved.tooltip,
				   ds_saved.column_template,
				   ds_saved.key_column,
				   ds_saved.[required_filter] [required_filter]

			FROM (
				SELECT COLUMN_NAME,
					   DATA_TYPE
				FROM   adiha_process.INFORMATION_SCHEMA.[COLUMNS]
				WHERE  TABLE_NAME = @data_source_process_table_name
			) c 
			INNER JOIN report_datatype rdt ON rdt.name = 
				CASE c.DATA_TYPE
					WHEN 'NCHAR' THEN 'CHAR'
					WHEN 'NVARCHAR' THEN 'VARCHAR'
					WHEN 'TEXT' THEN 'VARCHAR'
					WHEN 'NTEXT' THEN 'VARCHAR'
					WHEN 'XML' THEN 'VARCHAR'
					WHEN 'BIT' THEN 'INT'
					WHEN 'TINYINT' THEN 'INT'
					WHEN 'SMALLINT' THEN 'INT'
					WHEN 'BIGINT' THEN 'INT'
					WHEN 'BINARY' THEN 'INT'
					WHEN 'VARBINARY' THEN 'INT'
					WHEN 'REAL' THEN 'INT'
					WHEN 'DATETIME2' THEN 'DATETIME'
					WHEN 'DATETIMEOFFSET' THEN 'DATETIME'
					WHEN 'SMALLDATETIME' THEN 'DATETIME'
					WHEN 'DATE' THEN 'DATETIME'
					WHEN 'TIME' THEN 'DATETIME'
					WHEN 'TIMESTAMP' THEN 'DATETIME'
					WHEN 'NUMERIC' THEN 'FLOAT'
					WHEN 'DECIMAL' THEN 'FLOAT'
					WHEN 'MONEY' THEN 'FLOAT'
					WHEN 'SMALLMONEY' THEN 'FLOAT'
					ELSE c.DATA_TYPE			
				END
			LEFT JOIN (
				SELECT dsc.data_source_column_id [column_id],
					   dsc.name [column_name],
					   dsc.alias [ALIAS],
					   dsc.reqd_param [reqd_param],
					   dsc.append_filter [append_filter],
					   dsc.widget_id [widget_id],
					   dsc.param_default_value [param_default_value],
					   dsc.param_data_source [param_data_source],
					   ds.alias AS [source_alias],
					   dsc.tooltip,
					   dsc.column_template,
					   dsc.key_column,
					   dsc.required_filter [required_filter]
				FROM   data_source ds
				INNER JOIN data_source_column dsc 
					ON  ds.data_source_id = dsc.source_id
				WHERE  ds.data_source_id = @data_source_id
			) ds_saved 
			ON ds_saved.column_name = c.COLUMN_NAME
			ORDER BY ds_saved.[alias]
				, c.column_name	
		END
			
	END
	