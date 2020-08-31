IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_source_price_curve_def_maintain_paging]')
              AND TYPE IN (N'P', N'PC')
   )
    DROP PROCEDURE [dbo].[spa_source_price_curve_def_maintain_paging]
GO 

CREATE PROC [dbo].[spa_source_price_curve_def_maintain_paging]
    @flag as Char(1),	
	@source_curve_def_id int=null,				
	@source_system_id int=null,
	@curve_id varchar(50)=null,
	@curve_name varchar(100)=null,
	@curve_des varchar(500)=null,
	@commodity_id int=null,
	@market_value_id varchar(50)=null,
	@market_value_desc varchar(50)=null,
	@source_currency_id int=null,
	@source_currency_to_id int=null,
	@source_curve_type_value_id int=null,
	@uom_id int=null,
	@proxy_source_curve_def_id int=null,					
	@user_name varchar(50)=null,
	@formula_id int=null,
	@obligation char(1)=Null,
	@fair_value int=null,
	@granularity int=null,
	@risk_bucket_id int=null,
	@exp_calendar_id int=null,
	@reference_curve_id INT = NULL, -- VK05TRM	
	@monthly_index INT = NULL, --BSETRM		
	@program_scope INT=NULL,
	@block_type INT=NULL,
	@block_define_id INT=NULL,
	@curve_definition VARCHAR(max)=NULL,
	@index_group INT = NULL,
	@display_uom_id INT = NULL,
	@derived_flag CHAR(1) = NULL, 
	@process_id_paging VARCHAR(200) = NULL, 
	@page_size INT = NULL,
	@page_no INT = NULL,
	@proxy_curve_id  INT = NULL,
	@settlement_curve_id  INT = NULL,
	@hourly_volume_allocation  INT = NULL,
	@time_zone  INT = NULL,
	@udf_block_group_id  INT = NULL,
	@is_active VARCHAR(1) = NULL,
	@monte_carlo_model_parameter_name VARCHAR(MAX)
	
	
AS 


DECLARE @user_login_id  VARCHAR(50),
        @tempTable      VARCHAR(MAX)
 
DECLARE @flag_paging    CHAR(1)

SET @user_login_id = dbo.FNADBUser()

IF @process_id_paging IS NULL
BEGIN
    SET @flag_paging = 'i'
    SET @process_id_paging = REPLACE(NEWID(), '-', '_')
END

SET @tempTable = dbo.FNAProcessTableName(
        'paging_source_price_curve_def_maintain',
        @user_login_id,
        @process_id_paging
    )

EXEC spa_print @tempTable

DECLARE @sql VARCHAR(MAX)



IF @flag_paging = 'i'
BEGIN
    IF @flag = 's'
    BEGIN
        SET @sql = 'CREATE TABLE ' + @tempTable + 
            ' (
			sno INT IDENTITY(1,1), 
			
			ID VARCHAR(50),
			[System] VARCHAR(50),
			Description VARCHAR(200),
			[Curve ID] VARCHAR(100),		
			Name VARCHAR(200),			
			[Commodity] VARCHAR(100),
			[Market Value ID] VARCHAR(200),
			[Market Value Description]VARCHAR(200),
			[Currency] VARCHAR(100),
			[Currency To] VARCHAR(100),
			[Source Curve Type Value] VARCHAR(500),
			[UOM] VARCHAR(100),
			[Proxy Source Curve] VARCHAR(100),
			[Formula] INT,
			[Obligation] VARCHAR(50),
			[Sort Order] INT,
			[FV Level] VARCHAR(500),
			[Created Date] VARCHAR(50),
			[Created User] VARCHAR(50),
			[Updated User] VARCHAR(50),
			[Updated Date] VARCHAR(50),
			[Granularity] VARCHAR(500),
			[Expiry Calendar] VARCHAR(500),
			[Risk Bucket] VARCHAR(100),
			[Reference Curve] VARCHAR(100),
			[Monthly Index] VARCHAR(100),
			[Program Scope] VARCHAR(500),
			[Curve Definition] VARCHAR(MAX),
			[Block Type] VARCHAR(500),
			[Block Define] VARCHAR(500),
			[Index Group] VARCHAR(500),
			[Display UOM] VARCHAR(100),
			[Proxy Curve] VARCHAR(100),
			[Hourly Volume Allocation] VARCHAR(500),
			[Settlement Curve] VARCHAR(100),
			[Time Zone] VARCHAR(60), 
			[UDF BLOCK GROUP] VARCHAR(500),
			[Is Active] CHAR(1),
			[Ratio Option] VARCHAR(500),
			[Curve TOU] VARCHAR(500),
			[Proxy Curve ID3] VARCHAR(100),
			[AS of Date Current Month] VARCHAR(100),
			[Simulation Model] VARCHAR(500)
		)'
        
        EXEC spa_print @sql 
        EXEC (@sql)
        
        
        SET @sql = 'INSERT ' + @tempTable + 
            '(
			ID,
			[System],
			[Curve ID],
			Name,
			Description,		
			[Commodity],
			[Market Value ID],
			[Market Value Description],
			[Currency],
			[Currency To],
			[Source Curve Type Value],
			[UOM],
			[Proxy Source Curve],
			[Formula],
			[Obligation],
			[Sort Order],
			[FV Level],
			[Created Date],
			[Created User],
			[Updated User],
			[Updated Date],
			[Granularity],
			[Expiry Calendar],
			[Risk Bucket],
			[Reference Curve],
			[Monthly Index],
			[Program Scope],
			[Curve Definition],
			[Block Type],
			[Block Define],
			[Index Group],
			[Display UOM],
			[Proxy Curve],
			[Hourly Volume Allocation],
			[Settlement Curve],
			[Time Zone], 
			[UDF BLOCK GROUP],
			[Is Active],
			[Ratio Option],
			[Curve TOU],
			[Proxy Curve ID3],
			[AS of Date Current Month],
			[Simulation Model]
			)' +
            ' EXEC spa_source_price_curve_def_maintain ' +
				dbo.FNASingleQuote(@flag) + ',' +
				dbo.FNASingleQuote(@source_curve_def_id) + ',' +
				dbo.FNASingleQuote(@source_system_id) + ',' +
				dbo.FNASingleQuote(@curve_id) + ',' +
				dbo.FNASingleQuote(@curve_name) + ',' +
				dbo.FNASingleQuote(@curve_des) + ',' +
				dbo.FNASingleQuote(@commodity_id) + ',' +
				dbo.FNASingleQuote(@market_value_id) + ',' +
				dbo.FNASingleQuote(@market_value_desc) + ',' +
				dbo.FNASingleQuote(@source_currency_id) + ',' +
				dbo.FNASingleQuote(@source_currency_to_id) + ',' +
				dbo.FNASingleQuote(@source_curve_type_value_id) + ',' +
				dbo.FNASingleQuote(@uom_id) + ',' +
				dbo.FNASingleQuote(@proxy_source_curve_def_id) + ',' +
				dbo.FNASingleQuote(@user_name) + ',' +
				dbo.FNASingleQuote(@formula_id) + ',' +
				dbo.FNASingleQuote(@obligation) + ',' +
				dbo.FNASingleQuote(@fair_value) + ',' +
				dbo.FNASingleQuote(@granularity) + ',' +
				dbo.FNASingleQuote(@risk_bucket_id) + ',' +
				dbo.FNASingleQuote(@exp_calendar_id) + ',' +
				dbo.FNASingleQuote(@reference_curve_id) + ',' +
				dbo.FNASingleQuote(@monthly_index) + ',' +
				dbo.FNASingleQuote(@program_scope) + ',' +
				dbo.FNASingleQuote(@block_type) + ',' +
				dbo.FNASingleQuote(@block_define_id) + ',' +
				dbo.FNASingleQuote(@curve_definition) + ',' +
				dbo.FNASingleQuote(@index_group) + ',' +
				dbo.FNASingleQuote(@display_uom_id) + ',' +
				dbo.FNASingleQuote(@derived_flag) + ',' +
				dbo.FNASingleQuote(@proxy_curve_id) + ',' +
				dbo.FNASingleQuote(@settlement_curve_id) + ',' +
				dbo.FNASingleQuote(@hourly_volume_allocation) + ',' +
				dbo.FNASingleQuote(@time_zone) + ',' +
				dbo.FNASingleQuote(@udf_block_group_id) + ',' +
				dbo.FNASingleQuote(@is_active) +   ',' +
				dbo.FNASingleQuote(@monte_carlo_model_parameter_name)
				
        
        EXEC spa_print @sql 
        EXEC (@sql)
        
        SET @sql = 'select count(*) TotalRow,''' + @process_id_paging + ''' process_id  from ' + @tempTable
        
        EXEC spa_print @sql
        EXEC (@sql)
    END
   
END

ELSE
BEGIN
	
	DECLARE @row_from INT, @row_to INT 
	SET @row_to = @page_no * @page_size 
	IF @page_no > 1 
	SET @row_from = ((@page_no-1) * @page_size) + 1
	ELSE 
	SET @row_from = @page_no

    IF @flag = 's'
    BEGIN
        SET @sql = 
            'SELECT 
				ID,
				Name,
				Description,
				System,
				[Created Date],
				[Created User],
				[Updated User],
				[Updated Date],
				[Is Active]
	          FROM ' + @tempTable
            + ' WHERE sno BETWEEN ' + CAST(@row_from AS VARCHAR) + ' AND ' + 
            CAST(@row_to AS VARCHAR) + ' ORDER BY sno ASC'
            
		EXEC spa_print @sql 
		EXEC (@sql)               
    END
END