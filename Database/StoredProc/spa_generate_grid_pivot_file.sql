
IF OBJECT_ID(N'[dbo].[spa_generate_grid_pivot_file]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_generate_grid_pivot_file]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: bmaharjan@pioneersolutionsglobal.com
-- Create date: 2016-08-18
-- Description: Generates the pivot file for grid pivot.

-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_generate_grid_pivot_file]    
	@grid_name			VARCHAR(100) = NULL
	, @exec_sql			NVARCHAR(MAX) = NULL
	, @col_script		NVARCHAR(MAX) = NULL
	, @index			INT = 1
	, @primary_key		VARCHAR(100) = NULL
AS
SET NOCOUNT ON 

BEGIN
    DECLARE @SQL NVARCHAR(MAX)
	DECLARE @shared_path VARCHAR(300)
	DECLARE @file_name VARCHAR(300)
	DECLARE @full_file_path VARCHAR(300)
	DECLARE @grid_label NVARCHAR(100) = ''
	DECLARE @grouping_columns NVARCHAR(300)
	
    DECLARE @process_id			VARCHAR(200) = dbo.FNAGetNewId()
    DECLARE @user_name          VARCHAR(100) = dbo.FNADBUser()
	DECLARE @output_table		VARCHAR(300) = dbo.FNAProcessTableName('grid_output_table', @user_name, @process_id)
    
	SELECT @shared_path = document_path FROM connection_string
	
	IF @index = 0
	BEGIN
		IF @grid_name='Tagging_Audit_Report'
		BEGIN
			SET @exec_sql += ', @batch_process_id=''' + @process_id + ''''
		END
		ELSE IF  @grid_name='Data_Import/Export_Audit_Report'
		BEGIN
			SET @grid_name = 'Data_Import_Export_Audit_Report'
			SET @exec_sql += ', @batch_process_id=''' + @process_id + ''', @enable_paging = 1'
		END
		ELSE IF  @grid_name='User_Activity_Log_Report'
		BEGIN
			SET @exec_sql += ', @batch_process_id=''' + @process_id + ''', @enable_paging = 1'
		END
		ELSE IF @grid_name='Fair_Value_Disclosure_Report'
		BEGIN
			SET @exec_sql += ', '''+@process_id + ''', ''1'''
		END
		ELSE
		BEGIN
			SET @exec_sql += ', @batch_process_id=''' + @process_id + ''', @enable_paging = 1'
		END
		
		IF OBJECT_ID('tempdb..#tmp_return_data') IS NOT NULL
			DROP TABLE #tmp_return_data
		CREATE TABLE #tmp_return_data (total_row INT, process_id VARCHAR(300) COLLATE DATABASE_DEFAULT)
		
		IF @grid_name = 'Lifecycle_of_Transactions'
		BEGIN 
			EXEC(@exec_sql)
		END
		ELSE
		BEGIN
			INSERT INTO #tmp_return_data
			EXEC(@exec_sql) 
		END
		
		
		SET @output_table = dbo.FNAProcessTableName('batch_report', @user_name, @process_id) 
	END
	ELSE
	BEGIN
		IF @grid_name IS NOT NULL
		BEGIN
			SELECT	@grid_label = ISNULL(grid_label, grid_name),
					@grouping_columns = grouping_column 
			FROM adiha_grid_definition WHERE grid_name = @grid_name

			IF @exec_sql IS NULL OR @exec_sql = ''
				SELECT	@exec_sql = load_sql
				FROM adiha_grid_definition WHERE grid_name = @grid_name
		END

		IF @index = -1 AND @grouping_columns IS NOT NULL
		BEGIN
			DECLARE @count INT
			DECLARE @addition_col VARCHAR(500)
			SELECT @count = COUNT(1) -1 FROM  dbo.SplitCommaSeperatedValues(@grouping_columns)
			
			SELECT @addition_col = STUFF((SELECT TOP(@count) ',' +  CAST(a.item AS VARCHAR) + ' VARCHAR(500) ' FROM dbo.SplitCommaSeperatedValues(@grouping_columns) a
									FOR XML PATH('')), 1, 1, '')
			SET @col_script = @addition_col + ',' + @col_script
		END

		IF @exec_sql IS NOT NULL
		BEGIN
			IF @grid_name = 'nomination_schedule_grid'
			BEGIN
				SET @col_script = '[Path] VARCHAR(500),
									[Flow Date] VARCHAR(500),
									[Single Path] VARCHAR(500),
									[Deal ID] VARCHAR(500),
									[Nom Rec Vol] VARCHAR(500),
									[Shrinkage] VARCHAR(500),
									[Nom Del Vol] VARCHAR(500),
									[Schedule Rec Vol] VARCHAR(500),
									[Schedule Del Vol] VARCHAR(500),
									[Actual Rec Vol] VARCHAR(500),
									[Actual Del Vol] VARCHAR(500),
									[Rec Location] VARCHAR(500),
									[Del Location] VARCHAR(500),
									[Contract] VARCHAR(500),
									[Pipeline] VARCHAR(500),
									[Nom Group] VARCHAR(500),
									[Path Priority] VARCHAR(500),
									[Rec Priority] VARCHAR(500),
									[Del Priority] VARCHAR(500),
									[UOM] VARCHAR(500)'
			END
			
			IF @grid_name = 'view_price_grid'
			BEGIN
				SET @col_script = '	[Source Curve Def ID] VARCHAR(500),
									[Curve ID] VARCHAR(500),
									[Curve Name] VARCHAR(500),
									[Curve Source] VARCHAR(500), 
									[As of Date] VARCHAR(500), 
									[Maturity Date] VARCHAR(500),
									[Hour] VARCHAR(500),
									[DST] VARCHAR(500),
									[Curve Value] VARCHAR(500),
									[Bid Value] VARCHAR(500),
									[Ask Value] VARCHAR(500)'
			END

			IF @grid_name = 'available_pipeline_capacity_grid'
			BEGIN
				SET @col_script = '	[ID]				VARCHAR(500),
									[Effective Date]	VARCHAR(500),
									[Debt Rating]		VARCHAR(500),
									[Recovery]			VARCHAR(500), 
									[Rate]				VARCHAR(500)'
			END

			IF @grid_name = 'view_recovery_rate_m'
			BEGIN
				SET @col_script = '	[ID]				VARCHAR(500),
									[Effective Date]	VARCHAR(500),
									[Debt Rating]		VARCHAR(500),
									[Recovery]			VARCHAR(500), 
									[Rate]				VARCHAR(500), 
									[Month]				VARCHAR(500)'
			END

			IF @grid_name = 'view_volatility_grid'
			BEGIN
				SET @col_script = '	[ID] VARCHAR(500),
									[Curve ID] VARCHAR(500),
									[Curve Name] VARCHAR(500),
									[Curve Source] VARCHAR(500), 
									[As of Date] VARCHAR(500), 
									[Maturity Date] VARCHAR(500),
									[Volatility Value] VARCHAR(500)'
			END

			IF @grid_name = 'view_correlation_grid'
			BEGIN
				SET @col_script = '	[ID] VARCHAR(500),
									[Curve ID From] VARCHAR(500),
									[Curve ID To] VARCHAR(500),
									[Term From] VARCHAR(500),
									[Term To] VARCHAR(500), 
									[As of Date] VARCHAR(500), 
									[Curve Source] VARCHAR(500),
									[Value] VARCHAR(500)'
			END

			IF @grid_name = 'view_expected_return_grid'
			BEGIN
				SET @col_script = '	[ID] VARCHAR(500),
									[Curve ID] VARCHAR(500),
									[Curve Name] VARCHAR(500),
									[Curve Source] VARCHAR(500), 
									[As of Date] VARCHAR(500), 
									[Maturity Date] VARCHAR(500),
									[Expected Return Value] VARCHAR(500)'
			END

			IF @grid_name = 'view_default_probability_m'
			BEGIN
				SET @col_script = '	[ID] VARCHAR(500), 
									[Maturity Date] VARCHAR(500),
									[Debt Rating] VARCHAR(500),
									[Probability] VARCHAR(500),
									[Month]	VARCHAR(500)'
			END

			IF @grid_name = 'view_default_probability'
			BEGIN
				SET @col_script = '	[ID] VARCHAR(500), 
									[Maturity Date] VARCHAR(500),
									[Debt Rating] VARCHAR(500),
									[Probability] VARCHAR(500)'
			END
			
			IF @grid_name = 'view_recovery_rate'
			BEGIN
				SET @col_script = '	[ID]				VARCHAR(500),
									[Effective Date]	VARCHAR(500),
									[Debt Rating]		VARCHAR(500),
									[Recovery]			VARCHAR(500), 
									[Rate]				VARCHAR(500)'
			END
			
			IF @grid_name = 'trueup_summary' --Customize the header to split the column name which is combined in tree grid. i.e. [Month/Charge Type]
			BEGIN
				SET @col_script = '	[Month] VARCHAR(500),
									[Charge Type] VARCHAR(500),
									[System ID] VARCHAR(500),
									[Amount] VARCHAR(500), 
									[Currency] VARCHAR(500), 
									[Volume] VARCHAR(500),
									[UOM] VARCHAR(500),
									[Accounting Status] VARCHAR(500),
									[Finalized Date] VARCHAR(500)'
							
			END

			IF @grid_name = 'grid_setup_counterparty'  -- For Setup Counterparty UI
			BEGIN
				SET @col_script = '	[Parent Counterparty] VARCHAR(500),
									[Counterparty] VARCHAR(500),
									[System ID] VARCHAR(500),
									[Counterparty ID] VARCHAR(500), 
									[Description] VARCHAR(500), 
									[Counterparty Type] VARCHAR(500),
									[Entity Type] VARCHAR(500),
									[Customer Duns No.] VARCHAR(500),
									[Tax ID] VARCHAR(500),
									[Active] VARCHAR(500),
									[Title] VARCHAR(500),
									[Contact Name] VARCHAR(500),
									[Address 1] VARCHAR(500),
									[Address 2] VARCHAR(500),
									[Phone Number] VARCHAR(500),
									[Fax] VARCHAR(500),
									[Delivery Method] VARCHAR(500),
									[Type ID] VARCHAR(500),
									[Privilege] VARCHAR(500),
									[Notes] VARCHAR(500)
									'
			
			END

			
			IF @grid_name = 'counterparty_credit_limits'  
			BEGIN
				SET @col_script = '	[Internal Counterparty] VARCHAR(500),
									[Limit ID] VARCHAR(500),
									[System ID] VARCHAR(500),
									[Contract] VARCHAR(500), 
									[Counterparty] VARCHAR(500), 
									[Effective Date] VARCHAR(500),
									[Currency] VARCHAR(500),
									[Credit Limit] VARCHAR(500),
									[Credit Limit To Us] VARCHAR(500),
									[Maximum Threshold] VARCHAR(500),
									[Minimum Threshold] VARCHAR(500),
									[Tenor Limit] VARCHAR(500),
									[Limit Status] VARCHAR(500)
									'		
			END

			IF @grid_name = 'settlement_checkout'  
			BEGIN
				SET @col_script = '	[Charges]                    VARCHAR(1000),
									[Group2]                    VARCHAR(1000),
									[Group3]                    VARCHAR(1000),
									[Group4]                    VARCHAR(1000),
									[Group5]      VARCHAR(1000),
									[validation_status]      VARCHAR(1000),
									[Counterparty]      VARCHAR(1000),
									[Deal Reference]      VARCHAR(1000),
									[Ticket Number]      VARCHAR(1000),
									[Leg]      VARCHAR(1000),
									[Match Group ID]      VARCHAR(1000),
									[Shipment ID]      VARCHAR(1000),
									[Deal ID]      VARCHAR(1000),
									[Deal Detail ID]      VARCHAR(1000),
									[Ticket ID]      VARCHAR(1000),
									[Counterparty ID]      VARCHAR(1000),
									[Contract ID]      VARCHAR(1000),
									[Deal Charge Type ID]      VARCHAR(1000),
									[Contract Charge Type ID]      VARCHAR(1000),
									[Currency ID]      VARCHAR(1000),
									[Volume UOM ID]      VARCHAR(1000),
									[Contract]      VARCHAR(1000),
									[Deal Type]      VARCHAR(1000),
									[Buy Sell]      VARCHAR(1000),
									[As of Date]      VARCHAR(1000),
									[Term Start]      VARCHAR(1000),
									[Term End]      VARCHAR(1000),
									[Movement Date]      VARCHAR(1000),
									[Deal Volume]      VARCHAR(1000),
									[Schedule Volume]      VARCHAR(1000),
									[Actual Volume]      VARCHAR(1000),
									[Settlement Volume]      VARCHAR(1000),
									[Volume UOM]      VARCHAR(1000),
									[Price]      VARCHAR(1000),
									[Amount]      VARCHAR(1000),
									[Status]      VARCHAR(1000),
									[Currency]      VARCHAR(1000),
									[Pricing Status]      VARCHAR(1000),
									[Product]      VARCHAR(1000),
									[Charge Type Alias]      VARCHAR(1000),
									[PNL Line Item]      VARCHAR(1000),
									[Invoicing Charge Type]      VARCHAR(1000),
									[Charge Type Alias ID]      VARCHAR(1000),
									[PNL Line Item ID]      VARCHAR(1000),
									[Invoicing Charge Type ID]      VARCHAR(1000),
									[Debit GL Number]      VARCHAR(1000),
									[Credit GL Number]      VARCHAR(1000),
									[Payment Dr GL Code]      VARCHAR(1000),
									[Payment Cr GL Code]      VARCHAR(1000),
									[Invoice ID]      VARCHAR(1000),
									[Price Value]      VARCHAR(1000),
									[Amount Value]      VARCHAR(1000),
									[Settlement Volume Value]      VARCHAR(1000),
									[Index Fees ID]      VARCHAR(1000),
									[Settlement Checkout ID]      VARCHAR(1000),
									[Est Post GL ID]      VARCHAR(1000),
									[Stmt Invoice ID]      VARCHAR(1000),
									[Type]      VARCHAR(1000),
									[Payment Received]      VARCHAR(1000),
									[Payment Status]      VARCHAR(1000),
									[Payment Variance]      VARCHAR(1000),
									[Payment Date] VARCHAR(500)' 
			END
			
			SET @sql =  'CREATE TABLE ' + @output_table + ' (' + @col_script + ')
						INSERT INTO ' + @output_table + ' ' + REPLACE(@exec_sql, '<ID>', ISNULL(@primary_key, ''))
			EXEC(@sql)
		END
	END

	SET @file_name = ISNULL(CASE WHEN @grid_name = '' THEN NULL ELSE @grid_name END, 'grid_pivot_') + convert(varchar(30), getdate(),112) + replace(convert(varchar(30), getdate(),108),':','') + '.csv'
	SET @full_file_path = @shared_path + '\temp_Note\' + @file_name
	SET @full_file_path = replace(@full_file_path, '/' ,'_' )

	DECLARE @result NVARCHAR(1024)
	EXEC spa_export_to_csv @output_table, @full_file_path, 'y', ',', 'n','y','y','n',@result OUTPUT

	IF @result = 1
		SELECT 'Success' [ErrorCode], @file_name [FileName], @grid_label [GridLabel]
	ELSE
		SELECT 'Error' [ErrorCode], @file_name [FileName], @grid_label [GridLabel]
END

GO