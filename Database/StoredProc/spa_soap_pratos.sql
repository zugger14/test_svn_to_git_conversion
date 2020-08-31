/****** Object:  StoredProcedure [dbo].[spa_soap_pratos]    Script Date: 09/11/2011 06:34:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_soap_pratos]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_soap_pratos]
GO

/****** Object:  StoredProcedure [dbo].[spa_soap_pratos]    Script Date: 09/11/2011 06:34:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[spa_soap_pratos]
	@header_xml		VARCHAR(MAX) = NULL,
	@detail_xml		VARCHAR(MAX) = NULL,
	@udf_xml		VARCHAR(MAX) = NULL,
	@process_staging_table CHAR(1) = 'n',
	@process_id		VARCHAR(50) = NULL, 
	@process		CHAR(1) = 'n' ,
	@formula_xml	VARCHAR(MAX) = NULL,
	@bulk_import	CHAR(1) = 'n'
AS 


/*
drop table #deal_header
drop table #deal_detail
drop table #all_deal_header
drop table #all_deal_detail
drop table #udf
drop table #formula
drop table #vol
drop table #formula_parsed
drop table #import_status
drop table #tmp_erroneous_deals
drop table #error_handler
drop table #affected_deals
drop table #deal_detail_tmp
drop table #latest
drop table #price_without_formula
drop table #formula_udf
drop table #status
drop table #affected_meter
drop table #formula_process_message
drop table #deal_detail_breakdown
drop table #forecast_trigger_deals
drop table #temp_forecast_request


DECLARE @header_xml             VARCHAR(MAX) = NULL,
        @detail_xml             VARCHAR(MAX) = NULL,
        @udf_xml                VARCHAR(MAX) = NULL,
        @process_staging_table  CHAR(1) = 'y',
        @process_id             VARCHAR(50) = NULL, -- '54C21CBF_BA29_4D9D_B4C3_2F09BF4129B1',--'A8924AC2_2940_46D1_9625_B4C2B5350E03',
        @process                CHAR(1) = 'y',
        @formula_xml            VARCHAR(MAX) = NULL,
        @bulk_import            CHAR(1) = 'n'

--*/
-- Temporary Enable Bulk Import
SET @bulk_import ='y'
--SELECT @bulk_import = bulk_import FROM pratos_bulk_import_config



DECLARE @idoc_header            INT 
DECLARE @idoc_detail            INT 
DECLARE @idoc_udf               INT 
--DECLARE @template_id INT 

DECLARE @url                    VARCHAR(500)
DECLARE @desc                   VARCHAR(1000)
DECLARE @errorcode              CHAR(1)

DECLARE @source_deal_header_id  INT

DECLARE @insert_update_flag     CHAR(1)

DECLARE @deals                  VARCHAR(8000)

DECLARE @msg                    VARCHAR(500)
DECLARE @recommendation         VARCHAR(500)

DECLARE @source_deal_id         VARCHAR(50),
        @source_system_id       INT 

SET @source_system_id = 2 

DECLARE @user           VARCHAR(50)
DECLARE @user_login_id  VARCHAR(50)
SET @user_login_id = dbo.FNADBUser()

DECLARE @sql VARCHAR(8000) 
			
------------------------

DECLARE @start_date                    DATETIME,
        @end_date                      DATETIME

DECLARE @dir_path                      VARCHAR(1500),
        @imp_file_name                 VARCHAR(8000),
        @elapsed_time                  INT
		
DECLARE @total_deal_details_processed  INT,
        @total_deals_processed         INT
DECLARE @total_deal_details_found      INT,
        @total_deals_found             INT
		
DECLARE @has_invalid_null_fields       CHAR(1)
SET @has_invalid_null_fields = 'n'


DECLARE @first_run  CHAR(1)
DECLARE @gas_UOM    VARCHAR(20),@nl_gas_UOM VARCHAR(20),@be_gas_UOM VARCHAR(20)
DECLARE @power_UOM  VARCHAR(20)

SET @gas_UOM = 'm3(n,35.17)'
SET @power_UOM = 'kWh'
SET @nl_gas_UOM = 'MJ'
SET @be_gas_UOM = 'kWh'


IF ISNULL(@process_id,'') = ''
BEGIN
	SET @process_id = REPLACE(NEWID(), '-', '_')
	SET @first_run = 'y'
END
ELSE 
	SET @first_run = 'n'

		
DECLARE @import_data_files_audit_id INT 		
		
SET @dir_path = 'Pratos Deal'

SET @errorcode = 'p' 
 			
SET @start_date = GETDATE()


SET @header_xml =  REPLACE(@header_xml,'&','&amp;')
SET @detail_xml =  REPLACE(@detail_xml,'&','&amp;')


IF ISNULL(@process_staging_table,'n')='n'
	SET @imp_file_name = 'Pratos XML'	
ELSE
	SET @imp_file_name = 'Staging Table'


------------------------


/** Create Temporary Tables **/
CREATE TABLE #deal_header (
	temp_id                       INT IDENTITY(1, 1),
	source_system_id              INT,
	source_deal_id                VARCHAR(50) COLLATE DATABASE_DEFAULT,
	source_deal_id_old            VARCHAR(50) COLLATE DATABASE_DEFAULT,

	block_type                    VARCHAR(100) COLLATE DATABASE_DEFAULT,
	block_description             VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[description]                 VARCHAR(100) COLLATE DATABASE_DEFAULT,
	deal_date                     VARCHAR(20) COLLATE DATABASE_DEFAULT,
	counterparty                  VARCHAR(50) COLLATE DATABASE_DEFAULT,
	deal_type                     VARCHAR(50) COLLATE DATABASE_DEFAULT,
	deal_sub_type                 VARCHAR(50) COLLATE DATABASE_DEFAULT,
	option_flag                   CHAR(1) COLLATE DATABASE_DEFAULT,
	source_book_id1               VARCHAR(50) COLLATE DATABASE_DEFAULT,
	source_book_id2               VARCHAR(50) COLLATE DATABASE_DEFAULT,
	source_book_id3               VARCHAR(50) COLLATE DATABASE_DEFAULT,
	source_book_id4               VARCHAR(50) COLLATE DATABASE_DEFAULT,
	description1                  VARCHAR(100) COLLATE DATABASE_DEFAULT,
	description2                  VARCHAR(50) COLLATE DATABASE_DEFAULT,
	description3                  VARCHAR(50) COLLATE DATABASE_DEFAULT,
	deal_category_id              VARCHAR(50) COLLATE DATABASE_DEFAULT,
	trader_name                   VARCHAR(50) COLLATE DATABASE_DEFAULT,
	header_buy_sell_flag          CHAR(1) COLLATE DATABASE_DEFAULT,
	framework                     VARCHAR(50) COLLATE DATABASE_DEFAULT,
	legal_entity                  VARCHAR(50) COLLATE DATABASE_DEFAULT,
	[template]                    VARCHAR(50) COLLATE DATABASE_DEFAULT,
	deal_status                   VARCHAR(50) COLLATE DATABASE_DEFAULT,
	[PROFILE]                     VARCHAR(50) COLLATE DATABASE_DEFAULT,
	fixing                        VARCHAR(50) COLLATE DATABASE_DEFAULT,
	confirm_status                VARCHAR(50) COLLATE DATABASE_DEFAULT,
	reference_deal                VARCHAR(50) COLLATE DATABASE_DEFAULT,
	commodity                     VARCHAR(50) COLLATE DATABASE_DEFAULT,
	percentage_fixed_bsld_onpeak  NUMERIC(38, 20),
	percentage_fixed_offpeak      NUMERIC(38, 20),
	parent_counterparty           VARCHAR(50) COLLATE DATABASE_DEFAULT,
	product                       VARCHAR(100) COLLATE DATABASE_DEFAULT,
	notification_status			  VARCHAR(10) COLLATE DATABASE_DEFAULT,
	msg_format					  VARCHAR(20) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #deal_detail ( 
	temp_id                  INT IDENTITY(1, 1),
	source_system_id         INT,
	source_deal_id           VARCHAR(50) COLLATE DATABASE_DEFAULT,
	term_start               VARCHAR(20) COLLATE DATABASE_DEFAULT,
	term_end                 VARCHAR(20) COLLATE DATABASE_DEFAULT,
	leg                      VARCHAR(50) COLLATE DATABASE_DEFAULT,	--INT
	
	expiration_date          VARCHAR(20) COLLATE DATABASE_DEFAULT,
	fixed_float_leg          CHAR(1) COLLATE DATABASE_DEFAULT,
	buy_sell                 CHAR(1) COLLATE DATABASE_DEFAULT,
	source_curve             VARCHAR(50) COLLATE DATABASE_DEFAULT,
	fixed_price              NUMERIC(38, 20),
	deal_volume              NUMERIC(38, 20),
	volume_frequency         CHAR(1) COLLATE DATABASE_DEFAULT,
	volume_uom               VARCHAR(50) COLLATE DATABASE_DEFAULT,
	physical_financial_flag  CHAR(1) COLLATE DATABASE_DEFAULT,
	location                 VARCHAR(50) COLLATE DATABASE_DEFAULT,
	capacity                 NUMERIC(38, 20),
	fixed_cost               NUMERIC(38, 20),
	fixed_cost_currency      VARCHAR(50) COLLATE DATABASE_DEFAULT,
	formula_currency         VARCHAR(50) COLLATE DATABASE_DEFAULT,
	adder_currency           VARCHAR(50) COLLATE DATABASE_DEFAULT,
	price_currency           VARCHAR(50) COLLATE DATABASE_DEFAULT,
	meter                    VARCHAR(50) COLLATE DATABASE_DEFAULT,
	syv                      NUMERIC(38, 20),
	
	postal_code              VARCHAR(8) COLLATE DATABASE_DEFAULT,
	province                 VARCHAR(100) COLLATE DATABASE_DEFAULT,
	physical_shipper         VARCHAR(50) COLLATE DATABASE_DEFAULT,
	sicc_code                VARCHAR(50) COLLATE DATABASE_DEFAULT,
	profile_code             VARCHAR(50) COLLATE DATABASE_DEFAULT,
	nominatorsapcode         VARCHAR(50) COLLATE DATABASE_DEFAULT,
	forecast_needed          CHAR(1) COLLATE DATABASE_DEFAULT,
	forecasting_group        VARCHAR(50) COLLATE DATABASE_DEFAULT,
	external_profile         VARCHAR(50) COLLATE DATABASE_DEFAULT,
	calculation_method       CHAR(1) COLLATE DATABASE_DEFAULT,
	country                  CHAR(2) COLLATE DATABASE_DEFAULT,
	region                   VARCHAR(50) COLLATE DATABASE_DEFAULT,
	grid                     VARCHAR(50) COLLATE DATABASE_DEFAULT,
	location_group           VARCHAR(20) COLLATE DATABASE_DEFAULT,
	tou_tariff               VARCHAR(100) COLLATE DATABASE_DEFAULT,
	category                 VARCHAR(50) COLLATE DATABASE_DEFAULT,
	volume_multiplier        NUMERIC(38, 20),
	price_uom                VARCHAR(50) COLLATE DATABASE_DEFAULT
)




/** Create Temporary Tables **/
CREATE TABLE #all_deal_header
(
	temp_id                       INT,
	source_system_id              INT,
	source_deal_id                VARCHAR(50) COLLATE DATABASE_DEFAULT,
	source_deal_id_old            VARCHAR(50) COLLATE DATABASE_DEFAULT,

	block_type                    VARCHAR(100) COLLATE DATABASE_DEFAULT,
	block_description             VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[description]                 VARCHAR(100) COLLATE DATABASE_DEFAULT,
	deal_date                     VARCHAR(20) COLLATE DATABASE_DEFAULT,
	counterparty                  VARCHAR(50) COLLATE DATABASE_DEFAULT,
	deal_type                     VARCHAR(50) COLLATE DATABASE_DEFAULT,
	deal_sub_type                 VARCHAR(50) COLLATE DATABASE_DEFAULT,
	option_flag                   CHAR(1) COLLATE DATABASE_DEFAULT,
	source_book_id1               VARCHAR(50) COLLATE DATABASE_DEFAULT,
	source_book_id2               VARCHAR(50) COLLATE DATABASE_DEFAULT,
	source_book_id3               VARCHAR(50) COLLATE DATABASE_DEFAULT,
	source_book_id4               VARCHAR(50) COLLATE DATABASE_DEFAULT,
	description1                  VARCHAR(100) COLLATE DATABASE_DEFAULT,
	description2                  VARCHAR(50) COLLATE DATABASE_DEFAULT,
	description3                  VARCHAR(50) COLLATE DATABASE_DEFAULT,
	deal_category_id              VARCHAR(50) COLLATE DATABASE_DEFAULT,
	trader_name                   VARCHAR(50) COLLATE DATABASE_DEFAULT,
	header_buy_sell_flag          CHAR(1) COLLATE DATABASE_DEFAULT,
	framework                     VARCHAR(50) COLLATE DATABASE_DEFAULT,
	legal_entity                  VARCHAR(50) COLLATE DATABASE_DEFAULT,
	[template]                    VARCHAR(50) COLLATE DATABASE_DEFAULT,
	deal_status                   VARCHAR(50) COLLATE DATABASE_DEFAULT,
	[PROFILE]                     VARCHAR(50) COLLATE DATABASE_DEFAULT,
	fixing                        VARCHAR(50) COLLATE DATABASE_DEFAULT,
	confirm_status                VARCHAR(50) COLLATE DATABASE_DEFAULT,
	reference_deal                VARCHAR(50) COLLATE DATABASE_DEFAULT,
	commodity                     VARCHAR(50) COLLATE DATABASE_DEFAULT,
	percentage_fixed_bsld_onpeak  NUMERIC(38, 20),
	percentage_fixed_offpeak      NUMERIC(38, 20),
	parent_counterparty           VARCHAR(50) COLLATE DATABASE_DEFAULT,
	product                       VARCHAR(100) COLLATE DATABASE_DEFAULT,
	notification_status			  VARCHAR(10) COLLATE DATABASE_DEFAULT		
)

CREATE TABLE #all_deal_detail
(
	temp_id                  INT,
	source_system_id         INT,
	source_deal_id           VARCHAR(50) COLLATE DATABASE_DEFAULT,
	term_start               VARCHAR(20) COLLATE DATABASE_DEFAULT,
	term_end                 VARCHAR(20) COLLATE DATABASE_DEFAULT,
	leg                      VARCHAR(50) COLLATE DATABASE_DEFAULT,	--INT,
	
	expiration_date          VARCHAR(20) COLLATE DATABASE_DEFAULT,
	fixed_float_leg          CHAR(1) COLLATE DATABASE_DEFAULT,
	buy_sell                 CHAR(1) COLLATE DATABASE_DEFAULT,
	source_curve             VARCHAR(50) COLLATE DATABASE_DEFAULT,
	fixed_price              NUMERIC(38, 20),
	deal_volume              NUMERIC(38, 20),
	volume_frequency         CHAR(1) COLLATE DATABASE_DEFAULT,
	volume_uom               VARCHAR(50) COLLATE DATABASE_DEFAULT,
	physical_financial_flag  CHAR(1) COLLATE DATABASE_DEFAULT,
	location                 VARCHAR(50) COLLATE DATABASE_DEFAULT,
	capacity                 NUMERIC(38, 20),
	fixed_cost               NUMERIC(38, 20),
	fixed_cost_currency      VARCHAR(50) COLLATE DATABASE_DEFAULT,
	formula_currency         VARCHAR(50) COLLATE DATABASE_DEFAULT,
	adder_currency           VARCHAR(50) COLLATE DATABASE_DEFAULT,
	price_currency           VARCHAR(50) COLLATE DATABASE_DEFAULT,
	meter                    VARCHAR(50) COLLATE DATABASE_DEFAULT,
	syv                      NUMERIC(38, 20),
	
	postal_code              VARCHAR(8) COLLATE DATABASE_DEFAULT,
	province                 VARCHAR(100) COLLATE DATABASE_DEFAULT,
	physical_shipper         VARCHAR(50) COLLATE DATABASE_DEFAULT,
	sicc_code                VARCHAR(50) COLLATE DATABASE_DEFAULT,
	profile_code             VARCHAR(50) COLLATE DATABASE_DEFAULT,
	nominatorsapcode         VARCHAR(50) COLLATE DATABASE_DEFAULT,
	forecast_needed          CHAR(1) COLLATE DATABASE_DEFAULT,
	forecasting_group        VARCHAR(50) COLLATE DATABASE_DEFAULT,
	external_profile         VARCHAR(50) COLLATE DATABASE_DEFAULT,
	calculation_method       CHAR(1) COLLATE DATABASE_DEFAULT,
	country                  CHAR(2) COLLATE DATABASE_DEFAULT,
	region                   VARCHAR(50) COLLATE DATABASE_DEFAULT,
	grid                     VARCHAR(50) COLLATE DATABASE_DEFAULT,
	location_group           VARCHAR(20) COLLATE DATABASE_DEFAULT,
	tou_tariff               VARCHAR(100) COLLATE DATABASE_DEFAULT,
	category                 VARCHAR(50) COLLATE DATABASE_DEFAULT,
	volume_multiplier        NUMERIC(38, 20),
	price_uom                VARCHAR(50) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #udf
(
	source_system_id  INT,
	source_deal_id    VARCHAR(50) COLLATE DATABASE_DEFAULT,

	field             VARCHAR(500) COLLATE DATABASE_DEFAULT,
	[value]           VARCHAR(8000) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #formula
(
	row_id            INT,	-- IDENTITY(1,1),
	source_system_id  INT,
	source_deal_id    VARCHAR(50) COLLATE DATABASE_DEFAULT,
	term_start        VARCHAR(20) COLLATE DATABASE_DEFAULT,
	term_end          VARCHAR(20) COLLATE DATABASE_DEFAULT,
	leg               VARCHAR(50) COLLATE DATABASE_DEFAULT,	--INT,
	
	formula           VARCHAR(500) COLLATE DATABASE_DEFAULT,
	[value]           NUMERIC(38, 20),
	tariff            VARCHAR(100) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #vol
(
	vol_id            INT,
	source_system_id  INT,
	source_deal_id    VARCHAR(50) COLLATE DATABASE_DEFAULT,
	term_start        VARCHAR(20) COLLATE DATABASE_DEFAULT,
	term_end          VARCHAR(20) COLLATE DATABASE_DEFAULT,
	leg               VARCHAR(50) COLLATE DATABASE_DEFAULT,
	deal_volume       NUMERIC(38, 20)
)

-- ### select the deals whose forecast needs to be triggerd
CREATE TABLE #forecast_trigger_deals
(
	source_deal_id VARCHAR(50) COLLATE DATABASE_DEFAULT
)


IF @first_run = 'y'
BEGIN

	/** Create Temporary Tables **/
	SET @sql = 'CREATE TABLE ' + dbo.FNAProcessTableName('deal_header', @user_login_id, @process_id) + '
	            (
	            	--temp_id INT IDENTITY(1, 1),
	            	source_system_id              INT,
	            	source_deal_id                VARCHAR(50),
	            	source_deal_id_old            VARCHAR(50),

	            	block_type                    VARCHAR(100),
	            	block_description             VARCHAR(100),
	            	[description]                 VARCHAR(100),
	            	deal_date                     VARCHAR(20),
	            	counterparty                  VARCHAR(50),
	            	deal_type                     VARCHAR(50),
	            	deal_sub_type                 VARCHAR(50),
	            	option_flag                   CHAR(1),
	            	source_book_id1               VARCHAR(50),
	            	source_book_id2               VARCHAR(50),
	            	source_book_id3               VARCHAR(50),
	            	source_book_id4               VARCHAR(50),
	            	description1                  VARCHAR(100),
	            	description2                  VARCHAR(50),
	            	description3                  VARCHAR(50),
	            	deal_category_id              VARCHAR(50),
	            	trader_name                   VARCHAR(50),
	            	header_buy_sell_flag          CHAR(1),
	            	framework                     VARCHAR(50),
	            	legal_entity                  VARCHAR(50),
	            	[template]                    VARCHAR(50),
	            	deal_status                   VARCHAR(50),
	            	[profile]                     VARCHAR(50),
	            	fixing                        VARCHAR(50),
	            	confirm_status                VARCHAR(50),
	            	reference_deal                VARCHAR(50),
	            	commodity                     VARCHAR(50),
	            	percentage_fixed_bsld_onpeak  NUMERIC(38, 20),
	            	percentage_fixed_offpeak      NUMERIC(38, 20),
	            	parent_counterparty           VARCHAR(50),
	            	product                       VARCHAR(100),
	            	msg_format					  VARCHAR(50)	
	            )'
	EXEC(@sql)

	SET @sql = 'CREATE TABLE ' + dbo.FNAProcessTableName('deal_detail', @user_login_id, @process_id) + '
	            (
	            	--temp_id INT, 
	            	source_system_id         INT,
	            	source_deal_id           VARCHAR(50),
	            	term_start               VARCHAR(20),
	            	term_end                 VARCHAR(20),
	            	leg                      VARCHAR(50),	--INT,	            	

	            	expiration_date          VARCHAR(20),
	            	fixed_float_leg          CHAR(1),
	            	buy_sell                 CHAR(1),
	            	source_curve             VARCHAR(50),
	            	fixed_price              NUMERIC(38, 20),
	            	deal_volume              NUMERIC(38, 20),
	            	volume_frequency         CHAR(1),
	            	volume_uom               VARCHAR(50),
	            	physical_financial_flag  CHAR(1),
	            	location                 VARCHAR(50),
	            	capacity                 NUMERIC(38, 20),
	            	fixed_cost               NUMERIC(38, 20),
	            	fixed_cost_currency      VARCHAR(50),
	            	formula_currency         VARCHAR(50),
	            	adder_currency           VARCHAR(50),
	            	price_currency           VARCHAR(50),
	            	meter                    VARCHAR(50),
	            	syv                      NUMERIC(38, 20),
		
	            	postal_code              VARCHAR(8),
	            	province                 VARCHAR(100),
	            	physical_shipper         VARCHAR(50),
	            	sicc_code                VARCHAR(50),
	            	profile_code             VARCHAR(50),
	            	nominatorsapcode         VARCHAR(50),
	            	forecast_needed          CHAR(1),
	            	forecasting_group        VARCHAR(50),
	            	external_profile         VARCHAR(50),
	            	calculation_method       CHAR(1),
	            	country                  CHAR(2),
	            	region                   VARCHAR(50),
	            	grid                     VARCHAR(50),
	            	location_group           VARCHAR(20),
	            	tou_tariff               VARCHAR(100),
	            	category                 VARCHAR(50),
	            	volume_multiplier        NUMERIC(38, 20),
	            	price_uom                VARCHAR(50)
	            )'
	EXEC(@sql)

	SET @sql = 'CREATE TABLE ' + dbo.FNAProcessTableName('udf', @user_login_id, @process_id) + '
	            (
	            	source_system_id  INT,
	            	source_deal_id    VARCHAR(50),

	            	field             VARCHAR(500),
	            	[value]           VARCHAR(8000)
	            )'
	EXEC(@sql)

	SET @sql = 'CREATE TABLE ' + dbo.FNAProcessTableName('formula', @user_login_id, @process_id) + '
	            (
	            	row_id            INT,
	            	source_system_id  INT,
	            	source_deal_id    VARCHAR(50),
	            	term_start        VARCHAR(20),
	            	term_end          VARCHAR(20),
	            	leg               VARCHAR(50),
	            	formula           VARCHAR(500),
	            	[value]           NUMERIC(38, 20),
	            	tariff            VARCHAR(100)
	            )'
	EXEC(@sql)
	
	SET @sql = 'CREATE TABLE ' + dbo.FNAProcessTableName('vol', @user_login_id, @process_id) + '
	            (
	            	vol_id            INT,
	            	source_system_id  INT,
	            	source_deal_id    VARCHAR(50),
	            	term_start        VARCHAR(20),
	            	term_end          VARCHAR(20),
	            	leg               VARCHAR(50),
	            	deal_volume       NUMERIC(38, 20)
	            )'
	EXEC(@sql)	
	
	----
	SET @sql = 'INSERT INTO ' + dbo.FNAProcessTableName('deal_header', @user_login_id, @process_id) + ' 
				(
					source_system_id,
					source_deal_id,

					source_deal_id_old,

					block_type,
					block_description,
					[description],
					deal_date,
					counterparty,
					deal_type,
					deal_sub_type,
					option_flag,
					source_book_id1,
					source_book_id2,
					source_book_id3,
					source_book_id4,
					description1,
					description2,
					description3,
					deal_category_id,
					trader_name,
					header_buy_sell_flag,
					framework,
					legal_entity,
					[template],
					deal_status,
					[profile],
					fixing,
					confirm_status,
					reference_deal, 
					commodity,
					percentage_fixed_bsld_onpeak, 
					percentage_fixed_offpeak,
					parent_counterparty ,
					product,
					msg_format
				)
	SELECT 
		source_system_id,
					   source_deal_id,

					   source_deal_id_old,
		
					   block_type,
					   block_description,
					   [description],
					   deal_date,
					   counterparty,
					   deal_type,
					   deal_sub_type,
					   option_flag,
					   source_book_id1,
					   source_book_id2,
					   source_book_id3,
					   source_book_id4,
					   description1,
					   description2,
					   description3,
					   deal_category_id,
					   trader_name,
					   header_buy_sell_flag,
					   framework,
					   legal_entity,
					   [template],
					   deal_status,
					   [profile],
					   fixing,
					   confirm_status,
					   reference_deal,
					   commodity,
					   percentage_fixed_bsld_onpeak,
					   percentage_fixed_offpeak,
					   parent_counterparty,
					   product,
					   msg_format
	FROM #deal_header
	'
	EXEC(@sql)
	
	
	SET @sql = 'INSERT INTO ' + dbo.FNAProcessTableName('deal_detail', @user_login_id, @process_id) + '
				(
					source_system_id,
					source_deal_id,
					term_start,
					term_end,
					leg,

					expiration_date,
					fixed_float_leg,
					buy_sell,
					source_curve,
					fixed_price,
					deal_volume,
					volume_frequency,
					volume_uom,
					physical_financial_flag,
					location,
					capacity,
					fixed_cost,
					fixed_cost_currency,
					formula_currency,
					adder_currency,
					price_currency,
					meter,
					syv,		
		
					postal_code,
					province,
					physical_shipper,
					sicc_code,
					profile_code,
					nominatorsapcode,
					forecast_needed,
					forecasting_group,
					external_profile,
					calculation_method,
					country,
					region,
					grid, 
					location_group,
					tou_tariff, 
					category,
					volume_multiplier, 
					price_uom 
				)
	SELECT 
		source_system_id,
					   source_deal_id,
					   term_start,
					   term_end,
					   leg,

					   expiration_date,
					   fixed_float_leg,
					   buy_sell,
					   source_curve,
					   fixed_price,
					   deal_volume,
					   volume_frequency,
					   volume_uom,
					   physical_financial_flag,
					   location,
					   capacity,
					   fixed_cost,
					   fixed_cost_currency,
					   formula_currency,
					   adder_currency,
					   price_currency,
					   meter,
					   syv,

					   postal_code,
					   province,
					   physical_shipper,
					   sicc_code,
					   profile_code,
					   nominatorsapcode,
					   forecast_needed,
					   forecasting_group,
					   external_profile,
					   calculation_method,
					   country,
					   region,
					   grid,
					   location_group,
					   tou_tariff,
					   category,
					   volume_multiplier,
					   price_uom
	
	FROM #deal_detail
	'
	EXEC(@sql)
	
	
	SET @sql = 'INSERT INTO ' + dbo.FNAProcessTableName('udf', @user_login_id, @process_id) + ' 
				(
					source_system_id,
					source_deal_id,

					field,
					[value]
				)
	SELECT
		source_system_id,
					   source_deal_id,

					   field,
					   [value]
				FROM   #udf '
	EXEC(@sql)
	
	SET @sql = 'INSERT INTO ' + dbo.FNAProcessTableName('formula', @user_login_id, @process_id) + ' 
				(
					row_id,
					source_system_id,
					source_deal_id,
					term_start,
					term_end,
					leg,		
		
					formula,
					[value],
					tariff 	
				)
				SELECT
					row_id,
					source_system_id,
					source_deal_id,
					term_start,
					term_end,
					leg,		
		
					formula,
					[value],
					tariff	
				FROM #formula '
	EXEC(@sql)	
	
	SET @sql = 'INSERT INTO ' + dbo.FNAProcessTableName('vol', @user_login_id, @process_id) + ' 
				(
					vol_id,	
					source_system_id, 
					source_deal_id, 
					term_start,
					term_end, 
					leg,	
					deal_volume
				)
				SELECT 
					vol_id,	
					source_system_id, 
					source_deal_id, 
					term_start,
					term_end, 
					leg,	
					deal_volume
				FROM #vol '
	EXEC(@sql)	
	
END



CREATE TABLE #formula_parsed
(
	source_system_id  INT,
	source_deal_id    VARCHAR(50) COLLATE DATABASE_DEFAULT,
	term_start        VARCHAR(20) COLLATE DATABASE_DEFAULT,
	term_end          VARCHAR(20) COLLATE DATABASE_DEFAULT,
	leg               VARCHAR(50) COLLATE DATABASE_DEFAULT,	--INT,	
	
	formula           VARCHAR(8000) COLLATE DATABASE_DEFAULT,
	tariff            VARCHAR(100) COLLATE DATABASE_DEFAULT
)



--Create temporary table to log import status
CREATE TABLE #import_status
(
	temp_id             INT,
	process_id          VARCHAR(100) COLLATE DATABASE_DEFAULT,
	ErrorCode           VARCHAR(50) COLLATE DATABASE_DEFAULT,
	MODULE              VARCHAR(100) COLLATE DATABASE_DEFAULT,
	Source              VARCHAR(100) COLLATE DATABASE_DEFAULT,
	TYPE                VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[description]       VARCHAR(1000) COLLATE DATABASE_DEFAULT,
	[nextstep]          VARCHAR(250) COLLATE DATABASE_DEFAULT,
	type_error          VARCHAR(500) COLLATE DATABASE_DEFAULT,
	external_type_id    VARCHAR(100) COLLATE DATABASE_DEFAULT,
	field               VARCHAR(500) COLLATE DATABASE_DEFAULT,
	header_detail_flag  CHAR(1) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #tmp_erroneous_deals
(
	deal_id            VARCHAR(200) COLLATE DATABASE_DEFAULT,	-- NOT NULL,
	error_type_code    VARCHAR(100) COLLATE DATABASE_DEFAULT NOT NULL,
	error_description  VARCHAR(500) COLLATE DATABASE_DEFAULT,
	field_name         VARCHAR(100) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #error_handler
(
	error_code      VARCHAR(50) COLLATE DATABASE_DEFAULT,
	MODULE          VARCHAR(100) COLLATE DATABASE_DEFAULT,
	area            VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[status]        VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[MESSAGE]       VARCHAR(500) COLLATE DATABASE_DEFAULT,
	recommendation  VARCHAR(500) COLLATE DATABASE_DEFAULT,
	deal_id         VARCHAR(50) COLLATE DATABASE_DEFAULT,
	fields          VARCHAR(8000) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #affected_deals (source_deal_header_id INT, deal_id VARCHAR(50) COLLATE DATABASE_DEFAULT, [ACTION] CHAR(1) COLLATE DATABASE_DEFAULT)



BEGIN TRY 	
	
	--BEGIN TRAN

	EXEC sp_xml_preparedocument @idoc_header OUTPUT, @header_xml 

	IF @process_staging_table = 'n'
	BEGIN 
		
		IF @process = 'n'
		BEGIN

			INSERT INTO #deal_header (
				source_system_id,
				source_deal_id,
				source_deal_id_old,
				block_type,
				block_description,
				[description],
				deal_date,
				counterparty,
				deal_type,
				deal_sub_type,
				option_flag,
				source_book_id1,
				source_book_id2,
				source_book_id3,
				source_book_id4,
				description1,
				description2,
				description3,
				deal_category_id,
				trader_name,
				header_buy_sell_flag,
				framework,
				legal_entity,
				[template], 
				deal_status,
				[PROFILE], 
				fixing,
				confirm_status,
				reference_deal, 
				commodity, 
				percentage_fixed_bsld_onpeak, 
				percentage_fixed_offpeak, 
				parent_counterparty,
				product,
				msg_format
			)
			SELECT 
				@source_system_id,
				CASE source_deal_id WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE source_deal_id END,
				CASE source_deal_id_old WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE source_deal_id_old END,
				CASE block_type WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE block_type END,
				CASE block_description WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE block_description END,
				CASE [description] WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE [description] END,
				CASE deal_date WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE deal_date END,
				CASE counterparty WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE counterparty END,
				CASE deal_type WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE deal_type END,
				CASE deal_sub_type WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE deal_sub_type END,
				CASE option_flag WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE option_flag END,
				CASE source_book_id1 WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE source_book_id1 END,
				CASE source_book_id2 WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE source_book_id2 END,
				CASE source_book_id3 WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE source_book_id3 END,
				CASE source_book_id4 WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE source_book_id4 END,
				CASE description1 WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE description1 END,
				CASE description2 WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE description2 END,
				CASE description3 WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE description3 END,
				CASE deal_category_id WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE deal_category_id END,
				CASE trader_name WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE trader_name END,
				CASE header_buy_sell_flag WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE CAST(header_buy_sell_flag AS CHAR(1)) END,
				CASE framework WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE framework END,
				CASE legal_entity WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE legal_entity END,
				CASE [template] WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE [template] END, 
				CASE deal_status WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE deal_status END,
				CASE [PROFILE] WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE [PROFILE] END, 
				CASE fixing WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE fixing END,
				CASE confirm_status WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE confirm_status END,
				CASE reference_deal WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE reference_deal END,
				CASE commodity WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE commodity END, 
				CASE percentage_fixed_bsld_onpeak WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE percentage_fixed_bsld_onpeak END,
				CASE percentage_fixed_offpeak WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE percentage_fixed_offpeak END, 
				CASE parent_counterparty WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE parent_counterparty END,
				CASE product WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE product END,
				CASE msg_format WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE msg_format END
			FROM 
			OPENXML(@idoc_header, '/Root/PSRecordset', 2)
			WITH 
			(
				source_deal_id VARCHAR(50) '@source_deal_id',
				source_deal_id_old VARCHAR(50) '@source_deal_id_old',
				block_type VARCHAR(100) '@block_type',
				block_description VARCHAR(100) '@block_description',
				[description] VARCHAR(100) '@description',
				deal_date VARCHAR(20) '@deal_date', 
				counterparty VARCHAR(50) '@counterparty', 
				deal_type VARCHAR(50) '@deal_type',
				deal_sub_type VARCHAR(50) '@deal_sub_type',
				option_flag CHAR(1) '@option_flag', 
				source_book_id1 VARCHAR(50) '@source_book_id1',
				source_book_id2 VARCHAR(50) '@source_book_id2',
				source_book_id3 VARCHAR(50) '@source_book_id3',
				source_book_id4 VARCHAR(50) '@source_book_id4',
				description1 VARCHAR(100) '@description1',
				description2 VARCHAR(50) '@description2',
				description3 VARCHAR(50) '@description3',
				deal_category_id VARCHAR(50) '@deal_category_id', 
				trader_name VARCHAR(50) '@trader_name',
				header_buy_sell_flag CHAR(1) '@buy_sell',
				framework VARCHAR(50) '@framework',
				legal_entity VARCHAR(50) '@legal_entity',
				[template] VARCHAR(50) '@template', 
				deal_status VARCHAR(50) '@deal_status',
				[PROFILE] VARCHAR(50) '@profile', 
				fixing VARCHAR(50) '@fixing', 
				confirm_status VARCHAR(50) '@confirm_status', 
				reference_deal VARCHAR(50) '@reference_deal', 
				commodity VARCHAR(50) '@commodity',
				percentage_fixed_bsld_onpeak VARCHAR(40) '@percentage_fixed_bsld_onpeak', 
				percentage_fixed_offpeak VARCHAR(40) '@percentage_fixed_offpeak', 
				parent_counterparty VARCHAR(50) '@parent_counterparty', 
				product VARCHAR(50) '@product' ,
				msg_format VARCHAR(50) '@msg_format' 
			)
			
			EXEC sp_xml_removedocument @idoc_header
			
			SELECT @source_deal_id = source_deal_id FROM #deal_header 

			EXEC sp_xml_preparedocument @idoc_detail OUTPUT, @detail_xml 
					
			INSERT INTO #deal_detail (
				source_system_id, 
				source_deal_id, 
				term_start, 
				term_end, 
				leg, 

				expiration_date, 
				fixed_float_leg, 
				buy_sell, 
				source_curve, 
				fixed_price, 
				deal_volume, 
				volume_frequency, 
				volume_uom, 
				physical_financial_flag, 
				location, 
				capacity, 
				fixed_cost, 
				fixed_cost_currency, 
				formula_currency, 
				adder_currency, 
				price_currency, 
				meter, 
				syv, 				
				
				postal_code, 
				province, 
				physical_shipper, 
				sicc_code, 
				profile_code, 
				nominatorsapcode, 
				forecast_needed, 
				forecasting_group, 
				external_profile, 
				calculation_method, 
				country, 
				region, 
				grid, 
				location_group, 
				tou_tariff, 
				category,
				volume_multiplier, 
				price_uom 
			)	
			SELECT 
				@source_system_id,
				@source_deal_id,
				CASE term_start WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE term_start END,
				CASE term_end WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE term_end END,
				CASE leg WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE leg END,
				CASE expiration_date WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE expiration_date END,
				CASE fixed_float_leg 
					WHEN 'NULL'		THEN NULL 
					WHEN ''			THEN NULL 
					WHEN 'Fixed'	THEN 'f' 
					WHEN 'Float'	THEN 't' 
					ELSE fixed_float_leg 
				END,
				CASE buy_sell WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE CAST(buy_sell AS CHAR(1)) END,
				CASE source_curve WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE source_curve END,
				CASE fixed_price WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE fixed_price END,
				CASE deal_volume WHEN 'NULL' THEN CAST(0 AS NUMERIC(38,20)) WHEN '' THEN CAST(0 AS NUMERIC(38,20)) ELSE deal_volume END,
				CASE volume_frequency WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE CAST(volume_frequency AS CHAR(1)) END,
				CASE volume_uom WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE volume_uom END,
				CASE physical_financial_flag WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE CAST(physical_financial_flag AS CHAR(1)) END,
				CASE location WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE location END,
				CASE capacity WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE capacity END,
				CASE fixed_cost WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE fixed_cost END,
				CASE fixed_cost_currency WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE fixed_cost_currency END,
				CASE formula_currency WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE formula_currency END,
				CASE adder_currency WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE adder_currency END,
				CASE price_currency WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE price_currency END,
				CASE meter WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE meter END,
				CASE syv WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE syv END, 				
				
				CASE postal_code WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE postal_code END,
				CASE province WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE province END,
				CASE physical_shipper WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE physical_shipper END,
				CASE sicc_code WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE sicc_code END,
				CASE profile_code WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE profile_code END,
				CASE nominatorsapcode WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE nominatorsapcode END,
				CASE forecast_needed WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE LOWER(forecast_needed) END,
				CASE forecasting_group WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE forecasting_group END,
				CASE external_profile WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE external_profile END,
				CASE calculation_method WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE calculation_method END,
				CASE country WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE country END,
				CASE region WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE region END,
				CASE grid WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE grid END,
				CASE location_group WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE location_group END,
				CASE tou_tariff WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE tou_tariff END,
				CASE category WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE category END,
				CASE volume_multiplier WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE volume_multiplier END, 
				CASE price_uom WHEN 'NULL' THEN NULL WHEN '' THEN NULL ELSE price_uom END 
			FROM 
			OPENXML(@idoc_detail, '/Root/PSRecordset', 2)
			WITH 
			( 
				term_start VARCHAR(20) '@term_start',
				term_end VARCHAR(20) '@term_end', 
				leg VARCHAR(20) '@leg',		-- INT
				expiration_date VARCHAR(20) '@expiration_date',
				fixed_float_leg VARCHAR(50) '@fixed_float_leg',		-- CHAR(1)
				buy_sell VARCHAR(20) '@buy_sell',					-- CHAR(1)
				source_curve VARCHAR(50) '@source_curve', 
				fixed_price VARCHAR(40) '@fixed_price',	-- NUMERIC(38,20)
				deal_volume VARCHAR(40) '@deal_volume',	-- NUMERIC(38,20)
				volume_frequency VARCHAR(50) '@volume_frequency',	-- CHAR(1)
				volume_uom VARCHAR(50) '@volume_uom', 
				physical_financial_flag VARCHAR(50) '@physical_financial_flag', -- CHAR(1)
				location VARCHAR(50) '@location',
				capacity VARCHAR(40) '@capacity',		-- NUMERIC(38,20)
				fixed_cost VARCHAR(40) '@fixed_cost',	-- NUMERIC(38,20)
				fixed_cost_currency VARCHAR(50) '@fixed_cost_currency',
				formula_currency VARCHAR(50) '@formula_currency',
				adder_currency VARCHAR(50) '@adder_currency',
				price_currency VARCHAR(50) '@price_currency',
				meter VARCHAR(50) '@meter',
				syv VARCHAR(40) '@syv',	-- FLOAT				
				
				postal_code VARCHAR(8) '@postal_code',
				province VARCHAR(100) '@province',
				physical_shipper VARCHAR(50) '@physical_shipper',
				sicc_code VARCHAR(50) '@sicc_code',
				profile_code VARCHAR(50) '@profile_code',
				nominatorsapcode VARCHAR(50) '@nominatorsapcode',
				forecast_needed CHAR(1) '@forecast_needed',
				forecasting_group VARCHAR(50) '@forecasting_group',
				external_profile VARCHAR(50) '@external_profile',
				calculation_method CHAR(1) '@calculation_method',
				country CHAR(2) '@country',
				region VARCHAR(50) '@region',
				grid VARCHAR(50) '@grid',
				location_group VARCHAR(20) '@location_group',
				tou_tariff VARCHAR(100) '@tou_tariff',
				category VARCHAR(50) '@category',
				volume_multiplier VARCHAR(40) '@volume_multiplier', 
				price_uom VARCHAR(50) '@price_uom'
			)

			EXEC sp_xml_removedocument @idoc_detail		


			EXEC sp_xml_preparedocument @idoc_udf OUTPUT, @udf_xml

			INSERT INTO #udf (
				source_system_id, 
				source_deal_id, 
				field, 
				[value]
			)
			SELECT 
				@source_system_id, 
				@source_deal_id, 
				[key],
				CASE [value] WHEN 'NULL' THEN NULL ELSE [value] END
			FROM OPENXML(@idoc_udf, '/Root/UDF', 2)
			WITH (
				[key] VARCHAR(500),
				[value] VARCHAR(8000) 
			) AS a

			EXEC sp_xml_removedocument @idoc_udf			


			EXEC sp_xml_preparedocument @idoc_detail OUTPUT, @formula_xml

			INSERT INTO #formula (
				row_id, 
				source_system_id, 
				source_deal_id, 
				formula, 
				VALUE, 
				tariff
			)
			SELECT 
				NULL,		--ROW_NUMBER() OVER (PARTITION BY leg ORDER BY term_start, term_end, leg), 
				@source_system_id, 
				@source_deal_id, 
				[key],
				CASE [value] WHEN 'NULL' THEN NULL WHEN '' THEN NULL WHEN '0.00' THEN NULL ELSE [value] END,
				CASE WHEN CHARINDEX('_OFF',[key],0)>1 THEN 'Offpeak' ELSE 'Peak' END  
			FROM OPENXML(@idoc_detail, '/Root/Formula', 2)
			WITH (
				[key] VARCHAR(500),
				[value] VARCHAR(8000) 
			) AS a
			
			EXEC sp_xml_removedocument @idoc_detail

			EXEC sp_xml_preparedocument @idoc_detail OUTPUT, @detail_xml
			
			INSERT INTO #vol (
				vol_id,	
				source_system_id, 
				source_deal_id, 
				term_start,
				term_end, 
				leg,	
				deal_volume
			)
		SELECT DISTINCT
				vol_id,		--ROW_NUMBER() OVER (PARTITION BY leg ORDER BY term_start, term_end, leg), 
				@source_system_id, 
				@source_deal_id, 
				b.term_start, 
				b.term_end, 
				leg, 
				CASE deal_volume WHEN 'NULL' THEN 0 WHEN '' THEN CAST(0 AS NUMERIC(38,20)) ELSE ABS(CAST(deal_volume AS NUMERIC(38,20))) END
				
			FROM OPENXML(@idoc_detail, '/Root/PSRecordset/vol', 2)
			WITH (
				vol_id VARCHAR(20) '@id',		--ROW_NUMBER() OVER (PARTITION BY leg ORDER BY term_start, term_end, leg),  
				term_start VARCHAR(20) '../@term_start',
				term_end VARCHAR(20) '../@term_end', 
				leg VARCHAR(20) '../@leg',		-- INT
				deal_volume VARCHAR(40) '.' -- NUMERIC(38,20) 
			) AS a			
			cross apply (
				select b.term_start, b.term_end from dbo.FNATermBreakdown('m', a.term_start, a.term_end) b 
				where dbo.FNAGetContractMonth(term_start) = CAST(CAST(YEAR(a.term_start) AS VARCHAR) + '-' + vol_id + '-01' AS DATETIME)
				) b
			--WHERE
			--	CAST(CAST(YEAR(a.term_start) AS VARCHAR) + '-' + vol_id + '-01' AS DATETIME)  BETWEEN CAST(a.term_start AS DATETIME) AND CAST(a.term_end AS DATETIME)
			order by vol_id 

			EXEC sp_xml_removedocument @idoc_detail			
			
			
		--####### New logic added on 10th May 2012
		--####### IF message format is short, add the logic to copy the fisrt deal detail logic to rest of the deal detail			
		
		
		UPDATE
			dd
		SET
			dd.term_start = dd_mx.term_start,
			dd.term_end = dd_mx.term_end,
			dd.leg = dd_mx.leg ,
			dd.expiration_date = dd_mx.expiration_date,
			dd.fixed_float_leg = dd_mx.fixed_float_leg ,
			dd.source_curve = dd_mx.source_curve ,
			dd.fixed_price = dd_mx.fixed_price  ,
			dd.deal_volume = dd_mx.deal_volume,
			dd.volume_frequency = dd_mx.volume_frequency,
			dd.physical_financial_flag = dd_mx.physical_financial_flag,
			dd.capacity = dd_mx.capacity,
			dd.fixed_cost = dd_mx.fixed_cost,
			dd.fixed_cost_currency = dd_mx.fixed_cost_currency,
			dd.formula_currency = dd_mx.formula_currency,
			dd.adder_currency = dd_mx.adder_currency,
			dd.price_currency = dd_mx.price_currency,
			dd.meter = dd_mx.meter,
			dd.syv = dd_mx.syv,
			dd.postal_code = dd_mx.postal_code,
			dd.province = dd_mx.province,
			dd.physical_shipper = dd_mx.physical_shipper,
			dd.sicc_code = dd_mx.sicc_code,
			dd.profile_code = dd_mx.profile_code,
			dd.nominatorsapcode = dd_mx.nominatorsapcode,
			dd.forecast_needed = dd_mx.forecast_needed,
			dd.forecasting_group = dd_mx.forecasting_group,
			dd.external_profile = dd_mx.external_profile,
			dd.calculation_method = dd_mx.calculation_method,
			dd.country = dd_mx.country,
			dd.region = dd_mx.region,
			dd.grid = dd_mx.grid,
			dd.location_group = dd_mx.location_group,
			dd.category = dd_mx.category,
			dd.volume_multiplier = dd_mx.volume_multiplier,
			dd.price_uom = dd_mx.price_uom,
			dd.buy_sell = dd_mx.buy_sell,
			dd.volume_uom = dd_mx.volume_uom

		FROM	
			#deal_header dh
			INNER JOIN #deal_detail dd ON dh.source_deal_id = dd.source_deal_id
				AND dh.msg_format = 'short'
			OUTER APPLY
				(
					SELECT
						source_system_id, 
						source_deal_id, 
						MAX(term_start) term_start, 
						MAX(term_end) term_end, 
						MAX(leg)+2 leg, 
						MAX(expiration_date) expiration_date, 
						MAX(fixed_float_leg) fixed_float_leg, 
						MAX(buy_sell) buy_sell, 
						MAX(source_curve) source_curve, 
						MAX(fixed_price) fixed_price, 
						0 deal_volume, 
						MAX(volume_frequency) volume_frequency, 
						MAX(volume_uom) volume_uom, 
						MAX(physical_financial_flag) physical_financial_flag, 
						MAX(capacity) capacity, 
						MAX(fixed_cost) fixed_cost, 
						MAX(fixed_cost_currency) fixed_cost_currency, 
						MAX(formula_currency) formula_currency, 
						MAX(adder_currency) adder_currency, 
						MAX(price_currency) price_currency, 
						MAX(meter) meter, 
						0 syv,					
						MAX(postal_code) postal_code, 
						MAX(province) province, 
						MAX(physical_shipper) physical_shipper, 
						MAX(sicc_code) sicc_code, 
						MAX(profile_code) profile_code, 
						MAX(nominatorsapcode) nominatorsapcode, 
						'n' forecast_needed, 
						MAX(forecasting_group) forecasting_group, 
						MAX(external_profile) external_profile, 
						MAX(calculation_method) calculation_method, 
						MAX(country) country, 
						MAX(region) region, 
						MAX(grid) grid, 
						MAX(location_group) location_group, 
						tou_tariff, 
						MAX(category) category,
						MAX(volume_multiplier) volume_multiplier, 
						MAX(price_uom) price_uom
					FROM
						#deal_detail 
					WHERE
						source_deal_id = dh.source_deal_id
					GROUP BY 
						source_system_id,source_deal_id,tou_tariff	
					) dd_mx		
			WHERE
				dd_mx.source_system_id= dd.source_system_id
				AND dd_mx.source_deal_id= dd.source_deal_id
				AND dd_mx.tou_tariff= dd.tou_tariff
				AND dd.leg IS NULL
				

		---########	
			
		
		-- INSERT UDF Value Capacity CURRENCY from UDF from fixed_cost_currency
		INSERT INTO #udf(source_system_id ,source_deal_id,field,[value])
		SELECT
			dd.source_system_id,dd.source_deal_id,'Currency',MAX(sc.source_currency_id)
		FROM
			#deal_detail dd
			LEFT JOIN source_currency sc ON sc.currency_id = dd.fixed_cost_currency	
		GROUP BY
			dd.source_system_id,dd.source_deal_id
		
		--################### Insert the PRATOS timestamp to the UDF Field
		INSERT INTO #udf(source_system_id ,source_deal_id,field,[value])
		SELECT 
			source_system_id ,source_deal_id,'Pratos_Timestamp',
			--CONVERT(VARCHAR(25),CONVERT(DATETIME,RIGHT(source_deal_id,23),103),121)	
			RIGHT(source_deal_id,23)
		FROM
			#deal_header
					
			
			UPDATE f 
				SET row_id = m.row_id
			FROM #formula f
			LEFT JOIN (
				SELECT   
					ROW_NUMBER() OVER (PARTITION BY SUBSTRING(formula,0,CHARINDEX('(',formula,0)) ORDER BY SUBSTRING(formula,0,CHARINDEX('(',formula,0)),MIN(term_start)) row_id, 
					[formula]	---, term_start, term_end, leg 
				FROM #formula 
				INNER JOIN pratos_formula_mapping pfm ON '('+pfm.source_Formula+')' = LTRIM(RTRIM(  REPLACE(REPLACE(formula,'Formula_Mult_OFF',''), 'Formula_Mult','')  ))			
				WHERE [formula] LIKE 'formula_mult%'
				GROUP BY formula
			) m
			ON f.[formula] = m.[formula]
				

			SET @sql = 'INSERT INTO ' + dbo.FNAProcessTableName('deal_header', @user_login_id, @process_id) + ' 
			(
				source_system_id,
				source_deal_id,

				source_deal_id_old, 

				block_type,
				block_description,
				[description],
				deal_date,
				counterparty,
				deal_type,
				deal_sub_type,
				option_flag,
				source_book_id1,
				source_book_id2,
				source_book_id3,
				source_book_id4,
				description1,
				description2,
				description3,
				deal_category_id,
				trader_name,
				header_buy_sell_flag,
				framework,
				legal_entity,
				[template],
				deal_status,
				[profile],
				fixing,
				confirm_status,
				reference_deal, 
				commodity,
				percentage_fixed_bsld_onpeak, 
				percentage_fixed_offpeak, 
				parent_counterparty,
				product,
				msg_format 
			)
			SELECT 
				source_system_id,
				source_deal_id,

				source_deal_id_old, 

				block_type,
				block_description,
				[description],
				deal_date,
				counterparty,
				deal_type,
				deal_sub_type,
				option_flag,
				source_book_id1,
				source_book_id2,
				source_book_id3,
				source_book_id4,
				description1,
				description2,
				description3,
				deal_category_id,
				trader_name,
				header_buy_sell_flag,
				framework,
				legal_entity,
				[template],
				deal_status,
				[profile],
				fixing,
				confirm_status,
				reference_deal, 
				commodity,
				percentage_fixed_bsld_onpeak, 
				percentage_fixed_offpeak, 
				parent_counterparty,
				product,
				msg_format 
			FROM #deal_header
			'
			EXEC(@sql)
			
			SET @sql = 'INSERT INTO ' + dbo.FNAProcessTableName('deal_detail', @user_login_id, @process_id) + '
			(
				source_system_id,
				source_deal_id,
				term_start,
				term_end,
				leg,

				expiration_date,
				fixed_float_leg,
				buy_sell,
				source_curve,
				fixed_price,
				deal_volume,
				volume_frequency,
				volume_uom,
				physical_financial_flag,
				location,
				capacity,
				fixed_cost,
				fixed_cost_currency,
				formula_currency,
				adder_currency,
				price_currency,
				meter,
				syv,				
				
				postal_code,
				province,
				physical_shipper,
				sicc_code,
				profile_code,
				nominatorsapcode,
				forecast_needed,
				forecasting_group,
				external_profile,
				calculation_method,
				country,
				region, 
				grid, 
				location_group,
				tou_tariff, 
				category,
				volume_multiplier, 
				price_uom
			)
			SELECT 
				source_system_id,
				source_deal_id,
				term_start,
				term_end,
				leg,

				expiration_date,
				fixed_float_leg,
				buy_sell,
				source_curve,
				fixed_price,
				deal_volume,
				volume_frequency,
				volume_uom,
				physical_financial_flag,
				location,
				capacity,
				fixed_cost,
				fixed_cost_currency,
				formula_currency,
				adder_currency,
				price_currency,
				meter,
				syv,				
				
				postal_code,
				province,
				physical_shipper,
				sicc_code,
				profile_code,
				nominatorsapcode,
				forecast_needed,
				forecasting_group,
				external_profile,
				calculation_method,
				country,
				region,
				grid, 
				location_group,
				tou_tariff, 
				category,
				volume_multiplier, 
				price_uom
			FROM #deal_detail
			'
			EXEC(@sql)
			
			
			SET @sql = 'INSERT INTO ' + dbo.FNAProcessTableName('udf', @user_login_id, @process_id) + ' 
			(
				source_system_id,
				source_deal_id,

				field,
				[value]
			)
			SELECT
				source_system_id,
				source_deal_id,

				field,
				CASE WHEN [value] = '''' THEN NULL ELSE [value] END 
			FROM #udf '
			EXEC(@sql)
			
			SET @sql = 'INSERT INTO ' + dbo.FNAProcessTableName('formula', @user_login_id, @process_id) + ' 
			(
				row_id,
				source_system_id,
				source_deal_id,
				term_start,
				term_end,
				leg,				
				
				formula,
				[value],
				tariff	
			)
			SELECT
				row_id,
				source_system_id,
				source_deal_id,
				term_start,
				term_end,
				leg,				
				
				formula,
				[value]	,
				tariff
			FROM #formula '
			EXEC(@sql)	
			
			SET @sql = 'INSERT INTO ' + dbo.FNAProcessTableName('vol', @user_login_id, @process_id) + ' 
			(
				vol_id,	
				source_system_id, 
				source_deal_id, 
				term_start,
				term_end, 
				leg,	
				deal_volume	
			)
			SELECT
				vol_id,	
				source_system_id, 
				source_deal_id, 
				term_start,
				term_end, 
				leg,	
				deal_volume
			FROM #vol '
			EXEC(@sql)				
			
			SELECT @process_id [process_id]
			RETURN 
			
		END
		ELSE	-- if @process = 'y', take data from adiha_process tables
		BEGIN
			
			SET @sql = 'INSERT INTO #deal_header (
				source_system_id, 
				source_deal_id, 

				source_deal_id_old, 

				block_type, 
				block_description, 
				[description],
				deal_date, 
				counterparty, 
				deal_type, 
				deal_sub_type, 
				option_flag, 
				source_book_id1, 
				source_book_id2, 
				source_book_id3, 
				source_book_id4, 
				description1, 
				description2, 
				description3, 
				deal_category_id, 
				trader_name, 
				header_buy_sell_flag, 
				framework, 
				legal_entity, 
				[template], 
				deal_status, 
				[profile], 
				fixing, 
				confirm_status, 
				reference_deal, 
				commodity, 
				percentage_fixed_bsld_onpeak, 
				percentage_fixed_offpeak, 
				parent_counterparty ,
				product,
				msg_format 
			)
			SELECT 
				source_system_id, 
				source_deal_id, 

				source_deal_id_old, 

				block_type, 
				block_description, 
				[description],
				deal_date, 
				counterparty, 
				deal_type, 
				deal_sub_type, 
				option_flag, 
				source_book_id1, 
				source_book_id2, 
				source_book_id3, 
				source_book_id4, 
				description1, 
				description2, 
				description3, 
				deal_category_id, 
				trader_name, 
				header_buy_sell_flag, 
				framework, 
				legal_entity, 
				[template], 
				deal_status, 
				[profile], 
				fixing, 
				confirm_status, 
				reference_deal, 
				commodity, 
				percentage_fixed_bsld_onpeak, 
				percentage_fixed_offpeak, 
				parent_counterparty,
				product,
				msg_format 
			FROM ' + dbo.FNAProcessTableName('deal_header', @user_login_id, @process_id)
			EXEC(@sql)
			
			SET @sql = 'INSERT INTO #deal_detail (
				source_system_id, 
				source_deal_id, 
				term_start, 
				term_end, 
				leg, 

				expiration_date, 
				fixed_float_leg, 
				buy_sell, 
				source_curve, 
				fixed_price, 
				deal_volume, 
				volume_frequency, 
				volume_uom, 
				physical_financial_flag, 
				location, 
				capacity, 
				fixed_cost, 
				fixed_cost_currency, 
				formula_currency, 
				adder_currency, 
				price_currency, 
				meter, 
				syv, 

				postal_code, 
				province, 
				physical_shipper, 
				sicc_code, 
				profile_code, 
				nominatorsapcode, 
				forecast_needed, 
				forecasting_group, 
				external_profile, 
				calculation_method, 
				country, 
				region, 
				grid, 
				location_group, 
				tou_tariff, 
				category,
				volume_multiplier, 
				price_uom
			)
			SELECT 
				source_system_id, 
				source_deal_id, 
				term_start, 
				term_end, 
				leg, 

				expiration_date, 
				fixed_float_leg, 
				buy_sell, 
				source_curve, 
				fixed_price, 
				deal_volume, 
				volume_frequency, 
				volume_uom, 
				physical_financial_flag, 
				location, 
				capacity, 
				fixed_cost, 
				fixed_cost_currency, 
				formula_currency, 
				adder_currency, 
				price_currency, 
				meter, 
				syv, 

				postal_code, 
				province, 
				physical_shipper, 
				sicc_code, 
				profile_code, 
				nominatorsapcode, 
				forecast_needed, 
				forecasting_group, 
				external_profile, 
				calculation_method, 
				country, 
				region, 
				grid, 
				location_group, 
				tou_tariff, 
				category,
				volume_multiplier, 
				price_uom
			FROM ' + dbo.FNAProcessTableName('deal_detail', @user_login_id, @process_id)
			EXEC(@sql)
			
			SET @sql = 'INSERT INTO #udf (
				source_system_id, 
				source_deal_id, 

				field, 
				[value]
			) 
			SELECT 
				source_system_id, 
				source_deal_id, 

				field, 
				[value]
			FROM ' + dbo.FNAProcessTableName('udf', @user_login_id, @process_id)
			EXEC(@sql)
			
			SET @sql = 'INSERT INTO #formula (
				row_id, 
				source_system_id, 
				source_deal_id, 
				term_start, 
				term_end, 
				leg, 

				formula, 
				[value],
				tariff 
			) 
			SELECT 
				row_id, 
				source_system_id, 
				source_deal_id, 
				term_start, 
				term_end, 
				leg, 

				formula, 
				[value],
				tariff 
			FROM ' + dbo.FNAProcessTableName('formula', @user_login_id, @process_id)
			EXEC(@sql)
			
			SET @sql = 'INSERT INTO #vol (
				vol_id,	
				source_system_id, 
				source_deal_id, 
				term_start,
				term_end, 
				leg,	
				deal_volume
			) 
			SELECT 
				vol_id,	
				source_system_id, 
				source_deal_id, 
				term_start,
				term_end, 
				leg,	
				deal_volume
			FROM ' + dbo.FNAProcessTableName('vol', @user_login_id, @process_id)
			EXEC(@sql)			
			
		END
	END 
	ELSE 
	BEGIN
		
		INSERT INTO #deal_header (
			source_system_id, 
			source_deal_id, 
			source_deal_id_old, 

			block_type, 
			block_description, 
			[description], 
			deal_date, 
			counterparty, 
			deal_type, 
			deal_sub_type, 
			option_flag, 
			source_book_id1, 
			source_book_id2, 
			source_book_id3, 
			source_book_id4, 
			description1, 
			description2, 
			description3, 
			deal_category_id, 
			trader_name, 
			header_buy_sell_flag, 
			framework, 
			legal_entity, 
			[template], 
			deal_status, 
			[PROFILE], 
			fixing, 
			confirm_status, 
			reference_deal, 
			commodity, 
			percentage_fixed_bsld_onpeak, 
			percentage_fixed_offpeak, 
			parent_counterparty,
			product,
			notification_status,
			msg_format  
		)
		SELECT 
			source_system_id,
			source_deal_id,
			source_deal_id_old, 
			block_type,
			block_description,
			[description],
			deal_date,
			counterparty,
			deal_type,
			deal_sub_type,
			option_flag,
			source_book_id1,
			source_book_id2,
			source_book_id3,
			source_book_id4,
			description1,
			description2,
			description3,
			deal_category_id,
			trader_name,
			header_buy_sell_flag,
			framework,
			legal_entity,
			[template], 
			deal_status,
			[PROFILE], 
			fixing,
			confirm_status,
			reference_deal, 
			commodity, 
			percentage_fixed_bsld_onpeak,
			percentage_fixed_offpeak, 
			parent_counterparty,
			product,
			notification_status,
			msg_format  
		FROM 
			pratos_stage_deal_header (nolock)	

		SELECT @source_deal_id = source_deal_id FROM #deal_header 

		INSERT INTO #deal_detail (
			source_system_id, 
			source_deal_id, 
			term_start, 
			term_end, 
			leg, 

			expiration_date, 
			fixed_float_leg, 
			buy_sell, 
			source_curve, 
			fixed_price, 
			deal_volume, 
			volume_frequency, 
			volume_uom, 
			physical_financial_flag, 
			location, 
			capacity, 
			fixed_cost, 
			fixed_cost_currency, 
			formula_currency, 
			adder_currency, 
			price_currency, 
			meter, 
			syv, 

			postal_code, 
			province, 
			physical_shipper, 
			sicc_code, 
			profile_code, 
			nominatorsapcode, 
			forecast_needed, 
			forecasting_group, 
			external_profile, 
			calculation_method, 
			country, 
			region, 
			grid, 
			location_group, 
			tou_tariff, 
			category,
			volume_multiplier, 
			price_uom  	
		)	
		SELECT 
			source_system_id,
			source_deal_id,
			term_start,
			term_end,
			leg,
			expiration_date,
			fixed_float_leg,
			buy_sell,
			source_curve,
			fixed_price,
			deal_volume,
			volume_frequency,
			volume_uom,
			physical_financial_flag,
			location,
			capacity,
			fixed_cost,
			fixed_cost_currency,
			formula_currency,
			adder_currency,
			price_currency,
			meter,
			syv,			
			
			postal_code,
			province,
			physical_shipper,
			sicc_code,
			profile_code,
			nominatorsapcode,
			forecast_needed,
			forecasting_group,
			external_profile,
			calculation_method,
			country,
			region, 
			grid, 
			location_group,
			tou_tariff, 
			category,
			volume_multiplier, 
			price_uom 
		FROM 
			pratos_stage_deal_detail (nolock)

		INSERT INTO #udf (
			source_system_id,
			source_deal_id,
			field, 
			[value] 
		)
		SELECT 
			source_system_id,
			source_deal_id,
			field, 
			[value]
		FROM pratos_stage_udf (nolock)

		INSERT INTO #formula (
			row_id, 
			source_system_id,
			source_deal_id, 
			term_start,
			term_end, 
			leg,
			formula,
			[value],
			tariff
		)
		SELECT 
			row_id, 
			source_system_id,
			source_deal_id, 
			term_start,
			term_end, 
			leg,
			formula,
			[value],
			tariff
		FROM pratos_stage_formula (nolock)
		
		INSERT INTO #vol (
			vol_id,	
			source_system_id, 
			source_deal_id, 
			term_start,
			term_end, 
			leg,	
			deal_volume
		)
		SELECT 
			vol_id,	
			source_system_id, 
			source_deal_id, 
			term_start,
			term_end, 
			leg,	
			deal_volume
		FROM pratos_stage_vol (nolock)	 	

	END 


	CREATE INDEX indx_dh on #deal_header ([source_deal_id],[source_system_id],source_deal_id_old)
	CREATE INDEX indx_dd on #deal_detail ([source_deal_id],[source_system_id])
	CREATE INDEX indx_df on #formula ([source_deal_id],[source_system_id])
	CREATE INDEX indx_du on #udf ([source_deal_id],[source_system_id])
	CREATE INDEX indx_dv on #vol ([source_deal_id],[source_system_id])

	IF EXISTS (SELECT 1 FROM #vol)
	BEGIN
	
		
		SELECT * INTO #deal_detail_tmp FROM #deal_detail WHERE 1 = 2			
		
		
		INSERT INTO #deal_detail_tmp (
			source_system_id, 
			source_deal_id, 
			term_start, 
			term_end, 
			leg, 

			expiration_date, 
			fixed_float_leg, 
			buy_sell, 
			source_curve, 
			fixed_price, 
			deal_volume, 
			volume_frequency, 
			volume_uom, 
			physical_financial_flag, 
			location, 
			capacity, 
			fixed_cost, 
			fixed_cost_currency, 
			formula_currency, 
			adder_currency, 
			price_currency, 
			meter, 
			syv, 			
			
			postal_code, 
			province, 
			physical_shipper, 
			sicc_code, 
			profile_code, 
			nominatorsapcode, 
			forecast_needed, 
			forecasting_group, 
			external_profile, 
			calculation_method, 
			country, 
			region, 
			grid, 
			location_group, 
			tou_tariff, 
			category,
			volume_multiplier, 
			price_uom
		)	
		SELECT 
			dd.source_system_id, 
			dd.source_deal_id,
			t.term_start, 
			t.term_end,  
			CASE WHEN dh.msg_format ='Short' THEN ISNULL(v.leg,dd.leg) ELSE ISNULL(v.leg, 1) END,  
			expiration_date, 
			fixed_float_leg, 
			buy_sell, 
			source_curve, 
			fixed_price, 
			ABS(ISNULL(v.deal_volume, 0)), 
			volume_frequency, 
			volume_uom, 
			physical_financial_flag, 
			location, 
			capacity, 
			fixed_cost, 
			fixed_cost_currency, 
			formula_currency, 
			adder_currency, 
			price_currency, 
			meter, 
			syv, 			
			
			postal_code, 
			province, 
			physical_shipper, 
			sicc_code, 
			profile_code, 
			nominatorsapcode, 
			forecast_needed, 
			forecasting_group, 
			external_profile, 
			calculation_method, 
			country, 
			region, 
			grid, 
			location_group, 
			tou_tariff, 
			category,
			volume_multiplier, 
			price_uom	 
		FROM #deal_detail dd
			 INNER JOIN #deal_header dh ON dh.source_deal_id = dd.source_deal_id
		CROSS APPLY (
			SELECT term_start, term_end FROM dbo.FNATermBreakdown('m', term_start, term_end) fb
		) t
		LEFT JOIN #vol v 
			ON v.source_system_id = dd.source_system_id
			AND v.source_deal_id = dd.source_deal_id 
			AND v.leg = dd.leg 
			AND t.term_start = v.term_start
			AND t.term_end = v.term_end 
			
						
		--DELETE FROM #deal_detail 
		
		DELETE dd FROM #deal_detail dd
		INNER JOIN #vol v 
			ON v.source_system_id = dd.source_system_id
			AND v.source_deal_id = dd.source_deal_id

		INSERT INTO #deal_detail (
			source_system_id, 
			source_deal_id, 
			term_start, 
			term_end, 
			leg, 

			expiration_date, 
			fixed_float_leg, 
			buy_sell, 
			source_curve, 
			fixed_price, 
			deal_volume, 
			volume_frequency, 
			volume_uom, 
			physical_financial_flag, 
			location, 
			capacity, 
			fixed_cost, 
			fixed_cost_currency, 
			formula_currency, 
			adder_currency, 
			price_currency, 
			meter, 
			syv, 			
			
			postal_code, 
			province, 
			physical_shipper, 
			sicc_code, 
			profile_code, 
			nominatorsapcode, 
			forecast_needed, 
			forecasting_group, 
			external_profile, 
			calculation_method, 
			country, 
			region, 
			grid, 
			location_group, 
			tou_tariff, 
			category,
			volume_multiplier, 
			price_uom
		)	
		SELECT 
			source_system_id, 
			source_deal_id, 
			term_start, 
			term_end, 
			leg, 

			expiration_date, 
			fixed_float_leg, 
			buy_sell, 
			source_curve, 
			fixed_price, 
			deal_volume, 
			volume_frequency, 
			volume_uom, 
			physical_financial_flag, 
			location, 
			capacity, 
			fixed_cost, 
			fixed_cost_currency, 
			formula_currency, 
			adder_currency, 
			price_currency, 
			meter, 
			syv, 			
			
			postal_code, 
			province, 
			physical_shipper, 
			sicc_code, 
			profile_code, 
			nominatorsapcode, 
			forecast_needed, 
			forecasting_group, 
			external_profile, 
			calculation_method, 
			country, 
			region, 
			grid, 
			location_group, 
			tou_tariff, 
			category,
			volume_multiplier, 
			price_uom
		FROM #deal_detail_tmp
		
	END


	-- Delete all but the latest rows
	--/*
	CREATE TABLE #latest (
		source_deal_id_old  VARCHAR(50) COLLATE DATABASE_DEFAULT,
		dt                  VARCHAR(30) COLLATE DATABASE_DEFAULT,
		[RANK]              INT
	)
	
	UPDATE #deal_header SET source_deal_id_old = source_deal_id WHERE source_deal_id_old IS NULL 

		SET DATEFORMAT dmy;
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + 
			'. (Invalid Deal ID)',
			'Please check your data', 'Deal ID is Invalid', a.source_deal_id, 'DealID is in Invalid Format','d'
		FROM #deal_header a 
		WHERE ISDATE( RIGHT(LTRIM(RTRIM((a.source_deal_id))),23))=0
		
		-- If deal is already in the stagingtable, check which one is the latest
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
		SELECT NULL, @process_id, 'OLD_DEALS', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for id: ' + ISNULL(dh.source_deal_id,'NULL') + '. Deal ' +dh.source_deal_id+ ' is Older)', 
			'Please check your data', 'Older Deals: ' + ISNULL(dh.source_deal_id_old, 'NULL'), dh.source_deal_id,'Deal '+dh.source_deal_id +' ' + 'is Older','h'
		FROM #deal_header dh
			 INNER JOIN pratos_stage_deal_header psdd ON psdd.source_deal_id_old = dh.source_deal_id_old	
		WHERE
			ISDATE( RIGHT(LTRIM(RTRIM((dh.source_deal_id))),23))=1
			AND CONVERT(DATETIME,RIGHT(dh.source_deal_id,23),103)<CONVERT(DATETIME,RIGHT(psdd.source_deal_id,23),103)

		-- If deal is already in the deal table, check which one is the latest
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
		SELECT NULL, @process_id, 'OLD_DEALS', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for id: ' + ISNULL(dh.source_deal_id,'NULL') + '. Deal ' +dh.source_deal_id+ ' is Older)', 
			'Please check your data', 'Older Deals: ' + ISNULL(dh.source_deal_id_old, 'NULL'), dh.source_deal_id,'Deal '+dh.source_deal_id +' ' + 'is Older','h'
		FROM #udf a 
			 INNER JOIN #deal_header dh on a.source_system_id=a.source_system_id
				AND a.source_deal_id=dh.source_deal_id
				AND a.field='Pratos_Timestamp'
			 INNER JOIN source_deal_header sdh On sdh.deal_id=dh.source_deal_id_old
			 INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id=sdh.template_id
				AND uddft.field_name=-5585
			 INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id=sdh.source_deal_header_id
				AND uddft.udf_template_id=uddf.udf_template_id
		WHERE
			ISDATE( RIGHT(LTRIM(RTRIM((dh.source_deal_id))),23))=1
			AND ISDATE(SUBSTRING(uddf.udf_value,7,4)+'-'+SUBSTRING(uddf.udf_value,1,2)+'-'+SUBSTRING(uddf.udf_value,4,2))=1
			--CAST(a.value AS DATETIME)<CAST(uddf.udf_value AS DATETIME)	
			AND CONVERT(DATETIME,RIGHT(a.value,23),103)<CONVERT(DATETIME,RIGHT(uddf.udf_value,23),103)
			
					
		INSERT INTO #latest 
		SELECT	dh1.source_deal_id_old, 
			--LTRIM(REPLACE(REPLACE(MAX(dh1.source_deal_id), dh1.source_deal_id_old,'') ,'_',' ')),
			RIGHT(LTRIM(RTRIM((dh1.source_deal_id))),23), 
			RANK() OVER (PARTITION BY dh1.source_deal_id_old ORDER BY CONVERT(DATETIME, RIGHT(LTRIM(RTRIM(MAX(dh1.source_deal_id))),23), 103) DESC) 
		FROM #deal_header dh1
		     LEFT JOIN #import_status imp ON imp.external_type_id = dh1.source_deal_id
		WHERE ISDATE( RIGHT(LTRIM(RTRIM((dh1.source_deal_id))),23))=1
			  AND imp.external_type_id IS NULL 
		GROUP BY RIGHT(LTRIM(RTRIM((dh1.source_deal_id))),23),dh1.source_deal_id_old
	
		
		SET DATEFORMAT mdy;

	--IF EXISTS(SELECT 1 FROM #latest)
	--BEGIN

		DELETE FROM #latest WHERE [RANK] > 1
		UPDATE #latest SET dt = NULL WHERE dt = '01/01/1900 00:00'			


		DELETE f 
		FROM #deal_header dh 
		INNER JOIN #formula f ON f.source_deal_id = dh.source_deal_id AND f.source_system_id = dh.source_system_id 
		LEFT JOIN #latest lt	
			ON	lt.source_deal_id_old = dh.source_deal_id_old 
			AND ISNULL(lt.dt,'') = RIGHT(LTRIM(RTRIM(dh.source_deal_id)),23)
		WHERE lt.source_deal_id_old IS NULL 

		DELETE u 
		FROM #deal_header dh 
		INNER JOIN #udf u ON u.source_deal_id = dh.source_deal_id AND u.source_system_id = dh.source_system_id 
		LEFT JOIN #latest lt	
			ON	lt.source_deal_id_old = dh.source_deal_id_old 
			AND ISNULL(lt.dt,'') = RIGHT(LTRIM(RTRIM(dh.source_deal_id)),23)
		WHERE lt.source_deal_id_old IS NULL 
			
		DELETE dd 
		FROM #deal_header dh 
		INNER JOIN #deal_detail dd ON dd.source_deal_id = dh.source_deal_id AND dd.source_system_id = dh.source_system_id 
		LEFT JOIN #latest lt	
			ON	lt.source_deal_id_old = dh.source_deal_id_old 
			AND ISNULL(lt.dt,'') = RIGHT(LTRIM(RTRIM(dh.source_deal_id)),23)
		WHERE lt.source_deal_id_old IS NULL 
					
		DELETE dh 
		FROM #deal_header dh 
		LEFT JOIN #latest lt	
			ON	lt.source_deal_id_old = dh.source_deal_id_old 
			AND ISNULL(lt.dt,'') = RIGHT(LTRIM(RTRIM(dh.source_deal_id)),23)
		WHERE lt.source_deal_id_old IS NULL 
	--*/

	--END



	SELECT @deals = COALESCE(@deals + ', ' + source_deal_id_old, source_deal_id_old) FROM #deal_header 
	IF @deals IS NULL
		SELECT @deals = COALESCE(@deals + ', ' + external_type_id, external_type_id) FROM  (SELECT DISTINCT external_type_id FROM #import_status) a


	IF EXISTS (SELECT 1 FROM #deal_header WHERE deal_status = 'delete')
	BEGIN
		
		CREATE TABLE #tmp_error_handler (
			error_code      VARCHAR(50) COLLATE DATABASE_DEFAULT,
			MODULE          VARCHAR(100) COLLATE DATABASE_DEFAULT,
			area            VARCHAR(100) COLLATE DATABASE_DEFAULT,
			[status]        VARCHAR(100) COLLATE DATABASE_DEFAULT,
			[MESSAGE]       VARCHAR(500) COLLATE DATABASE_DEFAULT,
			recommendation  VARCHAR(500) COLLATE DATABASE_DEFAULT
		)

		DECLARE @delete_deals VARCHAR(MAX), @count_delete_deals INT 
		
		SELECT 
			@delete_deals = COALESCE(@delete_deals + ',' + CAST(source_deal_header_id AS VARCHAR), CAST(source_deal_header_id AS VARCHAR))  
		FROM source_deal_header sdh
		INNER JOIN #deal_header dh ON dh.source_deal_id_old = sdh.deal_id AND sdh.source_system_id = @source_system_id
		LEFT JOIN #import_status ims ON ims.external_type_id = dh.source_deal_id
		WHERE dh.deal_status = 'delete'
			  AND ims.external_type_id IS NULL	
		
		SELECT 
			@count_delete_deals = COUNT(*)
		FROM source_deal_header sdh
		INNER JOIN #deal_header dh ON dh.source_deal_id_old = sdh.deal_id AND sdh.source_system_id = @source_system_id
		LEFT JOIN #import_status ims ON ims.external_type_id = dh.source_deal_id
		WHERE dh.deal_status = 'delete'
			  AND ims.external_type_id IS NULL		
		
		-- Set deal locked to 'n' for deals being delete from PRATOS
		UPDATE sdh SET deal_locked = 'n'
		FROM source_deal_header sdh 
		INNER JOIN dbo.SplitCommaSeperatedValues(@delete_deals) csv on csv.Item = sdh.source_deal_header_id
		
		INSERT INTO #tmp_error_handler 
		EXEC spa_sourcedealheader 'd', NULL, NULL, NULL, NULL, NULL, @delete_deals
		
	END 
	

	INSERT INTO #affected_deals (source_deal_header_id, deal_id, [ACTION]) 
	SELECT NULL, source_deal_id, 'd' 
	FROM #deal_header dh
	LEFT JOIN #import_status ims ON ims.external_type_id = dh.source_deal_id
	WHERE deal_status = 'delete'
		   AND ims.external_type_id IS NULL			
	
	
	DELETE dd FROM #deal_detail dd 
	INNER JOIN #deal_header dh ON dh.source_deal_id = dd.source_deal_id AND dh.source_system_id = dd.source_system_id 
	WHERE dh.deal_status = 'delete'
	
	DELETE dh FROM #deal_header dh WHERE deal_status = 'delete'


	INSERT INTO #all_deal_header (
		source_system_id, 
		source_deal_id, 
		source_deal_id_old,

		block_type, 
		block_description, 
		[description], 
		deal_date, 
		counterparty, 
		deal_type, 
		deal_sub_type, 
		option_flag, 
		source_book_id1, 
		source_book_id2, 
		source_book_id3, 
		source_book_id4, 
		description1, 
		description2, 
		description3, 
		deal_category_id, 
		trader_name, 
		header_buy_sell_flag, 
		framework, 
		legal_entity, 
		[template], 
		deal_status, 
		[PROFILE], 
		fixing, 
		confirm_status, 
		reference_deal, 
		commodity, 
		percentage_fixed_bsld_onpeak, 
		percentage_fixed_offpeak, 
		parent_counterparty,
		notification_status  
	)
	SELECT 
		source_system_id, 
		source_deal_id, 
		source_deal_id_old,  

		block_type, 
		block_description, 
		[description], 
		deal_date, 
		counterparty, 
		deal_type, 
		deal_sub_type, 
		option_flag, 
		source_book_id1, 
		source_book_id2, 
		source_book_id3, 
		source_book_id4, 
		description1, 
		description2, 
		description3, 
		deal_category_id, 
		trader_name, 
		header_buy_sell_flag, 
		framework, 
		legal_entity, 
		[template], 
		deal_status, 
		[PROFILE], 
		fixing, 
		confirm_status, 
		reference_deal, 
		commodity, 
		percentage_fixed_bsld_onpeak, 
		percentage_fixed_offpeak, 
		parent_counterparty,
		notification_status  
	FROM #deal_header 
	
	INSERT INTO #all_deal_detail (
		source_system_id, 
		source_deal_id, 
		term_start, 
		term_end, 
		leg, 

		expiration_date, 
		fixed_float_leg, 
		buy_sell, 
		source_curve, 
		fixed_price, 
		deal_volume, 
		volume_frequency, 
		volume_uom, 
		physical_financial_flag, 
		location, 
		capacity, 
		fixed_cost, 
		fixed_cost_currency, 
		formula_currency, 
		adder_currency, 
		price_currency, 
		meter, 
		syv, 		
		
		postal_code, 
		province, 
		physical_shipper, 
		sicc_code, 
		profile_code, 
		nominatorsapcode, 
		forecast_needed, 
		forecasting_group, 
		external_profile, 
		calculation_method, 
		country, 
		region, 
		grid, 
		location_group, 
		tou_tariff, 
		category,
		volume_multiplier, 
		price_uom
	)
	SELECT 
		source_system_id, 
		source_deal_id, 
		term_start, 
		term_end, 
		leg, 

		expiration_date, 
		fixed_float_leg, 
		buy_sell, 
		source_curve, 
		fixed_price, 
		deal_volume, 
		volume_frequency, 
		volume_uom, 
		physical_financial_flag, 
		location, 
		capacity, 
		fixed_cost, 
		fixed_cost_currency, 
		formula_currency, 
		adder_currency, 
		price_currency, 
		meter, 
		syv, 		
		
		postal_code, 
		province, 
		physical_shipper, 
		sicc_code, 
		profile_code, 
		nominatorsapcode, 
		forecast_needed, 
		forecasting_group, 
		external_profile, 
		calculation_method, 
		country, 
		region, 
		grid, 
		location_group, 
		tou_tariff, 
		category,
		volume_multiplier, 
		price_uom
	FROM #deal_detail 
	
	


	--IF EXISTS (SELECT 1 FROM #invalid_null_fields)
	--BEGIN 
		
		/** Catch invalid NULL fields **/
		
		
		-- Header
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
		SELECT	a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
				'Data error for id: ' + ISNULL(a.source_deal_id,'NULL') + '. (source_deal_id should not be NULL)',
				'Please check your data', 'Deal ID should not be NULL', a.source_deal_id, 'source_deal_id','h' 
		FROM #deal_header a 
		WHERE source_deal_id IS NULL	
		
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
		SELECT	a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
				'Data error for id: ' + ISNULL(a.source_deal_id,'NULL') + '. (template should not be NULL)',
				'Please check your data', 'Template should not be NULL', a.source_deal_id, 'template','h' 
		FROM #deal_header a 
		WHERE template IS NULL		
		
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
		SELECT	a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
				'Data error for id: ' + ISNULL(a.source_deal_id,'NULL') + '. (deal_date should not be NULL)',
				'Please check your data','Deal Date should not be NULL', a.source_deal_id, 'deal_date','h' 
		FROM #deal_header a 
		WHERE deal_date IS NULL		
		
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
		SELECT	a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
				'Data error for id: ' + ISNULL(a.source_deal_id,'NULL') + '. (counterparty_id should not be NULL)',
				'Please check your data','Counterparty should not be NULL', a.source_deal_id, 'counterparty_id','h' 
		FROM #deal_header a 
		WHERE counterparty IS NULL			

		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
		SELECT	a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
				'Data error for id: ' + ISNULL(a.source_deal_id,'NULL') + '. (parent_counterparty should not be NULL)',
				'Please check your data','Parent Counterparty should not be NULL', a.source_deal_id, 'parent_counterparty','h' 
		FROM #deal_header a 
		WHERE parent_counterparty IS NULL			

		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
		SELECT	a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
				'Data error for id: ' + ISNULL(a.source_deal_id,'NULL') + '. (deal_type should not be NULL)',
				'Please check your data','Deal Type should not be NULL', a.source_deal_id, 'deal_type','h' 
		FROM #deal_header a 
		WHERE deal_type IS NULL	
	
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
		SELECT	a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
				'Data error for id: ' + ISNULL(a.source_deal_id,'NULL') + '. (option_flag should not be NULL)',
				'Please check your data','Option Flag should not be NULL', a.source_deal_id, 'option_flag','h' 
		FROM #deal_header a 
		WHERE option_flag IS NULL	
				
	
	
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
		SELECT	a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
				'Data error for id: ' + ISNULL(a.source_deal_id,'NULL') + '. (trader_name should not be NULL)',
				'Please check your data' ,'Trader Name should not be NULL', a.source_deal_id, 'trader_name','h'
		FROM #deal_header a 
		WHERE trader_name IS NULL			

		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
		SELECT	a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
				'Data error for id: ' + ISNULL(a.source_deal_id,'NULL') + '. (framework should not be NULL)',
				'Please check your data' ,'Framework should not be NULL', a.source_deal_id, 'framework','h'
		FROM #deal_header a 
		WHERE framework IS NULL	

					

		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
		SELECT	a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
				'Data error for id: ' + ISNULL(a.source_deal_id,'NULL') + '. (profile should not be NULL)',
				'Please check your data' ,'Profile should not be NULL', a.source_deal_id, 'profile','h'
		FROM #deal_header a 
		WHERE [PROFILE] IS NULL
		

		
		
		-- Detail 
		
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + ', term_start: ' + ISNULL(a.term_start,'NULL') +
			', term_end :' + ISNULL(a.term_end,'NULL') + ', Leg: ' + ISNULL(a.Leg,'NULL') +
			'. (term_start should not be NULL)',
			'Please check your data', 'Term Start should not be NULL', a.source_deal_id, 'term_start','d'
		FROM #deal_detail a 
		WHERE term_start IS NULL
		
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + ', term_start: ' + ISNULL(a.term_start,'NULL') +
			', term_end :' + ISNULL(a.term_end,'NULL') + ', Leg: ' + ISNULL(a.Leg,'NULL') +
			'. (term_end should not be NULL)',
			'Please check your data', 'Term End should not be NULL', a.source_deal_id, 'term_end','d'
		FROM #deal_detail a 
		WHERE term_end IS NULL		
		
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + ', term_start: ' + ISNULL(a.term_start,'NULL') +
			', term_end :' + ISNULL(a.term_end,'NULL') + ', Leg: ' + ISNULL(a.Leg,'NULL') +
			'. (leg should not be NULL)',
			'Please check your data', 'Leg should not be NULL', a.source_deal_id, 'leg','d'
		FROM #deal_detail a 
		WHERE leg IS NULL			

	
	
		
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + ', term_start: ' + ISNULL(a.term_start,'NULL') +
			', term_end :' + ISNULL(a.term_end,'NULL') + ', Leg: ' + ISNULL(a.Leg,'NULL') +
			'. (fixed_float_leg should not be NULL)',
			'Please check your data', 'Fixed Float leg should not be NULL', a.source_deal_id, 'fixed_float_leg','d'
		FROM #deal_detail a 
		WHERE fixed_float_leg IS NULL	
		
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + ', term_start: ' + ISNULL(a.term_start,'NULL') +
			', term_end :' + ISNULL(a.term_end,'NULL') + ', Leg: ' + ISNULL(a.Leg,'NULL') +
			'. (buy_sell should not be NULL)',
			'Please check your data', 'Buy/Sell flag should not be NULL', a.source_deal_id, 'buy_sell','d'
		FROM #deal_detail a 
		WHERE buy_sell IS NULL
		
	

		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + ', term_start: ' + ISNULL(a.term_start,'NULL') +
			', term_end :' + ISNULL(a.term_end,'NULL') + ', Leg: ' + ISNULL(a.Leg,'NULL') +
			'. (volume_frequency should not be NULL)',
			'Please check your data', 'Volume Frequency should not be NULL', a.source_deal_id, 'volume_frequency','d'
		FROM #deal_detail a 
			  INNER JOIN #deal_header dh ON dh.source_deal_id =a.source_deal_id
		WHERE volume_frequency IS NULL
			  AND dh.deal_type <> 'Fee'		
			  
			  
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + ', term_start: ' + ISNULL(a.term_start,'NULL') +
			', term_end :' + ISNULL(a.term_end,'NULL') + ', Leg: ' + ISNULL(a.Leg,'NULL') +
			'. (volume_uom should not be NULL)',
			'Please check your data', 'Volume UOM should not be NULL', a.source_deal_id, 'volume_uom','d'
		FROM #deal_detail a 
			  INNER JOIN #deal_header dh ON dh.source_deal_id =a.source_deal_id	
		WHERE volume_uom IS NULL
			  AND dh.deal_type <> 'Fee'		
			  	
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + ', term_start: ' + ISNULL(a.term_start,'NULL') +
			', term_end :' + ISNULL(a.term_end,'NULL') + ', Leg: ' + ISNULL(a.Leg,'NULL') +
			'. (physical_financial_flag should not be NULL)',
			'Please check your data', 'Physical Financial flag should not be NULL', a.source_deal_id, 'physical_financial_flag','d'
		FROM #deal_detail a 
		WHERE physical_financial_flag IS NULL			
				
		INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + ', term_start: ' + ISNULL(a.term_start,'NULL') +
			', term_end :' + ISNULL(a.term_end,'NULL') + ', Leg: ' + ISNULL(a.Leg,'NULL') +
			'. (location should not be NULL for Physical Legs)',
			'Please check your data', 'Location should not be NULL for Physical legs', a.source_deal_id, 'location','d'
		FROM #deal_detail a 
			  INNER JOIN #deal_header dh ON dh.source_deal_id =a.source_deal_id
		WHERE physical_financial_flag = 'p' AND location IS NULL
		      AND dh.deal_type <> 'Fee'		
				
	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + ', term_start: ' + ISNULL(a.term_start,'NULL') +
			', term_end :' + ISNULL(a.term_end,'NULL') + ', Leg: ' + ISNULL(a.Leg,'NULL') +
			'. (Country should not be NULL)',
			'Please check your data', 'Country should not be NULL', a.source_deal_id, 'Country','d'
		FROM #deal_detail a 
		WHERE Country IS NULL

			 	
	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + ', term_start: ' + ISNULL(a.term_start,'NULL') +
			', term_end :' + ISNULL(a.term_end,'NULL') + ', Leg: ' + ISNULL(a.Leg,'NULL') +
			'. (Category should not be NULL)',
			'Please check your data', 'Category should not be NULL', a.source_deal_id, 'Category','d'
		FROM #deal_detail a 
		WHERE Category IS NULL


	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + ', term_start: ' + ISNULL(a.term_start,'NULL') +
			', term_end :' + ISNULL(a.term_end,'NULL') + ', Leg: ' + ISNULL(a.Leg,'NULL') +
			'. (Grid should not be NULL)',
			'Please check your data', 'Grid should not be NULL', a.source_deal_id, 'Grid','d'
		FROM #deal_detail a 
		WHERE Grid IS NULL		



	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + ', term_start: ' + ISNULL(a.term_start,'NULL') +
			', term_end :' + ISNULL(a.term_end,'NULL') + ', Leg: ' + ISNULL(a.Leg,'NULL') +
			'. (Region should not be NULL)',
			'Please check your data', 'Region should not be NULL', a.source_deal_id, 'Region','d'
		FROM #deal_detail a 
			  INNER JOIN #deal_header dh ON dh.source_deal_id =a.source_deal_id
		WHERE region IS NULL							
			  AND dh.deal_type <> 'Fee'		
			  
	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + ', term_start: ' + ISNULL(a.term_start,'NULL') +
			', term_end :' + ISNULL(a.term_end,'NULL') + ', Leg: ' + ISNULL(a.Leg,'NULL') +
			'. (profile_code should not be NULL)',
			'Please check your data', 'profile_code should not be NULL', a.source_deal_id, 'profile_code','d'
		FROM #deal_detail a 
			  INNER JOIN #deal_header dh ON dh.source_deal_id =a.source_deal_id
		WHERE profile_code IS NULL AND physical_financial_flag = 'p'							
			  AND dh.deal_type <> 'Fee'		

	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + ', term_start: ' + ISNULL(a.term_start,'NULL') +
			', term_end :' + ISNULL(a.term_end,'NULL') + ', Leg: ' + ISNULL(a.Leg,'NULL') +
			'. (Province should not be NULL)',
			'Please check your data', 'Province should not be NULL', a.source_deal_id, 'Province','d'
		FROM #deal_detail a 
			  INNER JOIN #deal_header dh ON dh.source_deal_id =a.source_deal_id
		WHERE province IS NULL	AND forecast_needed ='y' AND physical_financial_flag = 'p'
			 AND dh.deal_type <> 'Fee'		
	
	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
		SELECT a.temp_id, @process_id, 'INVALID_NULL_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
			'Data error for source_deal_header_id: ' + ISNULL(a.source_deal_id,'NULL') + ', term_start: ' + ISNULL(a.term_start,'NULL') +
			', term_end :' + ISNULL(a.term_end,'NULL') + ', Leg: ' + ISNULL(a.Leg,'NULL') +
			'. (forecasting_group should not be NULL)',
			'Please check your data', 'forecasting_group should not be NULL', a.source_deal_id, 'forecasting_group','d'
		FROM #deal_detail a 
		WHERE forecasting_group IS NULL	AND forecast_needed ='y' AND physical_financial_flag = 'p'
		
				
		IF EXISTS (SELECT 1 FROM #import_status WHERE ErrorCode = 'INVALID_NULL_FIELD' OR ErrorCode = 'INVALID_FIELD')
			SET @has_invalid_null_fields = 'y'

		
	
	DELETE a FROM
		#deal_header a
		INNER JOIN #import_status b ON a.source_deal_id = b.external_type_id
	WHERE
		 b.ErrorCode IN('INVALID_NULL_FIELD','INVALID_FIELD','OLD_DEALS')
	
	
	
	IF @process_staging_table <> 'y' AND @bulk_import ='y'
	BEGIN
	
		DELETE t FROM pratos_stage_deal_header t (nolock) 
			INNER JOIN #deal_header d ON d.source_deal_id_old = t.source_deal_id_old 
		
		DELETE t FROM pratos_stage_deal_detail t 
			LEFT JOIN pratos_stage_deal_header psdh (nolock) ON psdh.source_deal_id = t.source_deal_id AND psdh.source_system_id = t.source_system_id 
		WHERE
			psdh.source_deal_id IS NULL
			
		DELETE t FROM pratos_stage_udf t 
		LEFT JOIN pratos_stage_deal_header psdh (nolock) ON psdh.source_deal_id = t.source_deal_id AND psdh.source_system_id = t.source_system_id 
		WHERE
			psdh.source_deal_id IS NULL
		
		DELETE t FROM pratos_stage_formula t 
		LEFT JOIN pratos_stage_deal_header psdh (nolock) ON psdh.source_deal_id = t.source_deal_id AND psdh.source_system_id = t.source_system_id 
		WHERE
			psdh.source_deal_id IS NULL
			
		
		DELETE t FROM pratos_stage_vol t 
		LEFT JOIN pratos_stage_deal_header psdh (nolock) ON psdh.source_deal_id = t.source_deal_id AND psdh.source_system_id = t.source_system_id 
		WHERE
			psdh.source_deal_id IS NULL
		

				
		INSERT INTO pratos_stage_deal_header with (rowlock)(
			source_system_id
			, source_deal_id
			, block_type
			, block_description
			--, description
			, deal_date
			, counterparty
			, deal_type
			, deal_sub_type
			, option_flag
			, source_book_id1
			, source_book_id2
			, source_book_id3
			, source_book_id4
			, description1
			, description2
			, description3
			, deal_category_id
			, trader_name
			, header_buy_sell_flag
			, framework
			, legal_entity
			, template
			, deal_status
			, PROFILE
			, fixing
			, confirm_status
			, reference_deal
			, commodity
			, percentage_fixed_bsld_onpeak
			, percentage_fixed_offpeak
			, parent_counterparty 	
			, source_deal_id_old
			, product	
			, notification_status	
			, msg_format
		)
		SELECT DISTINCT 
			source_system_id
			, source_deal_id
			, block_type
			, block_description
			--, description
			, deal_date
			, counterparty
			, deal_type
			, deal_sub_type
			, option_flag
			, source_book_id1
			, source_book_id2
			, source_book_id3
			, source_book_id4
			, description1
			, description2
			, description3
			, deal_category_id
			, trader_name
			, header_buy_sell_flag
			, framework
			, legal_entity
			, template
			, deal_status
			, PROFILE
			, fixing
			, confirm_status
			, reference_deal	
			, commodity
			, percentage_fixed_bsld_onpeak
			, percentage_fixed_offpeak 
			, parent_counterparty 		
			, source_deal_id_old
			, product
			, notification_status
			, msg_format
		FROM #deal_header dh
		LEFT JOIN #import_status ON #import_status.external_type_id = dh.source_deal_id 
		
		
		INSERT INTO pratos_stage_deal_detail with (rowlock)(
			source_system_id
			, source_deal_id
			, term_start
			, term_end
			, leg
			, expiration_date
			, fixed_float_leg
			, buy_sell
			, source_curve
			, fixed_price
			, deal_volume
			, volume_frequency
			, volume_uom
			, physical_financial_flag
			, location
			, capacity
			, fixed_cost
			, fixed_cost_currency
			, formula_currency
			, adder_currency
			, price_currency
			, meter
			, syv
			
			, postal_code
			, province
			, physical_shipper
			, sicc_code
			, profile_code
			, nominatorsapcode
			, forecast_needed
			, forecasting_group
			, external_profile
			, calculation_method
			, country
			, region 
			, grid
			, location_group
			, tou_tariff
			, category
			, volume_multiplier
			, price_uom
		)
		SELECT DISTINCT 
			dd.source_system_id
			, dd.source_deal_id
			, dd.term_start
			, dd.term_end
			, dd.leg
			, dd.expiration_date
			, dd.fixed_float_leg
			, dd.buy_sell
			, dd.source_curve
			, dd.fixed_price
			, dd.deal_volume
			, dd.volume_frequency
			, dd.volume_uom
			, dd.physical_financial_flag
			, dd.location
			, dd.capacity
			, dd.fixed_cost
			, dd.fixed_cost_currency
			, dd.formula_currency
			, dd.adder_currency
			, dd.price_currency
			, dd.meter
			, dd.syv			
			, dd.postal_code
			, dd.province
			, dd.physical_shipper
			, dd.sicc_code
			, dd.profile_code
			, dd.nominatorsapcode
			, dd.forecast_needed
			, dd.forecasting_group
			, dd.external_profile
			, dd.calculation_method
			, dd.country
			, dd.region
			, dd.grid
			, dd.location_group
			, dd.tou_tariff
			, dd.category
			, dd.volume_multiplier
			, dd.price_uom
		FROM #deal_detail dd
		LEFT JOIN #import_status ON #import_status.external_type_id = dd.source_deal_id 
		
		
		INSERT INTO pratos_stage_udf with (rowlock)(
			source_system_id,source_deal_id,field,VALUE
		)
		SELECT DISTINCT 
			source_system_id,source_deal_id,udf.field,VALUE
		FROM #udf udf 
		LEFT JOIN #import_status t ON t.external_type_id = udf.source_deal_id
		
		
		INSERT INTO pratos_stage_formula with (rowlock)(
			row_id,source_system_id,source_deal_id,term_start,term_end,leg,formula,VALUE,tariff
		)
		SELECT DISTINCT 
			row_id,source_system_id,source_deal_id,term_start,term_end,leg,formula,VALUE,f.tariff
		FROM #formula f
		LEFT JOIN #import_status t ON t.external_type_id = f.source_deal_id
		
		
		INSERT INTO pratos_stage_vol with (rowlock)(
			vol_id,	
			source_system_id, 
			source_deal_id, 
			term_start,
			term_end, 
			leg,	
			deal_volume
		)
		SELECT DISTINCT 
			vol_id,	
			source_system_id, 
			source_deal_id, 
			term_start,
			term_end, 
			leg,	
			deal_volume
		FROM #vol vol 
		LEFT JOIN #import_status t ON t.external_type_id = vol.source_deal_id	
		
				
		
	END
	
	
		
	IF @process_staging_table <> 'y' AND @bulk_import ='y'
		GOTO Logging



	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
	SELECT NULL, @process_id, 'MISSING_STATIC_DATA', 'Pratos Data Import', 'Pratos Data Import', 'Data Error', 
		'Data error for id: ' + ISNULL(f.source_deal_id, 'NULL') + '.  formula curve: ' + ISNULL(CAST(f.formula AS VARCHAR(500)), 'NULL')	+ ' not found. ',
		'Please check your data', 'formula curve ' + ISNULL(CAST(f.formula AS VARCHAR(500)), 'NULL') + ' not found', f.source_deal_id, ' formula curve: ' + ISNULL(CAST(f.formula AS VARCHAR(500)), 'NULL'), 'h' 
			
	FROM 
	#formula f
	LEFT JOIN pratos_formula_mapping pfm ON f.formula = 'FORMULA_MULT(' + pfm.source_formula + ')'
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = pfm.curve_id
	WHERE spcd.curve_id IS NULL  AND f.formula IS NOT NULL AND f.formula LIKE '%FORMULA_MULT(%'
	

	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
	SELECT NULL, @process_id, 'MISSING_STATIC_DATA', 'Pratos Data Import', 'Pratos Data Import', 'Data Error', 
		'Data error for id: ' + ISNULL(f.source_deal_id, 'NULL') + '.  formula curve: ' + ISNULL(CAST(f.formula AS VARCHAR(500)), 'NULL')	+ ' not found. ',
		'Please check your data', 'formula curve ' + ISNULL(CAST(f.formula AS VARCHAR), 'NULL') + ' not found', f.source_deal_id, ' formula curve: ' + ISNULL(CAST(f.formula AS VARCHAR(500)), 'NULL'), 'h' 
			
	FROM 
	#formula f
	LEFT JOIN pratos_formula_mapping pfm ON f.formula = 'FORMULA_MULT_OFF(' + pfm.source_formula + ')'
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = pfm.curve_id
	WHERE spcd.curve_id IS NULL  AND f.formula IS NOT NULL AND f.formula LIKE '%FORMULA_MULT_OFF(%'
	
		


	SELECT f.* 
	INTO #price_without_formula
	FROM #formula f
	OUTER APPLY 
	(
		SELECT 
			*   
		FROM #formula f1
		WHERE row_id IS NOT NULL
			AND f1.source_deal_id = f.source_deal_id
			AND f1.source_system_id = f.source_system_id 
			AND f1.tariff = f.tariff 
	) f2 
	WHERE f2.source_system_id IS NULL 	
	

	UPDATE dd 
	SET fixed_price = CASE WHEN dh.fixing IS NOT NULL THEN fe.value ELSE  pwf.value END
	FROM #deal_detail dd
	INNER JOIN #deal_header dh ON 
		dh.source_deal_id = dd.source_deal_id
		AND dh.source_system_id = dd.source_system_id
	LEFT JOIN #price_without_formula pwf 
		ON pwf.source_deal_id = dd.source_deal_id 
		AND pwf.source_system_id = dd.source_system_id
		AND pwf.tariff = ISNULL(NULLIF(dd.tou_tariff,'Baseload'),'Peak')
	LEFT JOIN #formula fe
		ON fe.source_deal_id = dd.source_deal_id 
		AND fe.source_system_id = dd.source_system_id
		AND fe.tariff = ISNULL(NULLIF(dd.tou_tariff,'Baseload'),'Peak') 
		AND fe.formula IN ('Fixed', 'Fixed_Offpeak')		
	

	
		

	/** Parse Formula BEGIN **/

	CREATE TABLE #formula_udf
	(
		source_system_id  INT,
		source_deal_id    VARCHAR(50) COLLATE DATABASE_DEFAULT,
		--term_start VARCHAR(20),
		--term_end VARCHAR(20),
		--leg VARCHAR(50),	--INT,		
		
		field             INT,
		[value]           VARCHAR(8000) COLLATE DATABASE_DEFAULT
	)

	
	INSERT INTO #formula_udf (source_system_id, source_deal_id, [field], [value])
	SELECT DISTINCT  
		t.source_system_id, t.source_deal_id, value_id, [value]
	FROM #formula t
	INNER JOIN static_data_value sdv 
		ON sdv.code = 'Fixed' + CASE WHEN tariff = 'OffPeak' THEN '_Offpeak' ELSE '' END 
		AND TYPE_ID = 5500
	INNER JOIN #deal_header dh ON dh.source_deal_id = t.source_deal_id
		AND dh.source_system_id = t.source_system_id
	WHERE formula IN ('Fixed', 'Fixed_Offpeak') AND row_id IS NULL AND dh.fixing IS NULL
		  AND [value] <>0
	
	
	
	
	IF @bulk_import ='n'
		DELETE f FROM #formula f 
			INNER JOIN #price_without_formula pwf 
			ON pwf.source_deal_id = f.source_deal_id 
			AND pwf.source_system_id = f.source_system_id
			AND pwf.tariff = f.tariff
		
	
	
	INSERT INTO #formula_udf (source_system_id, source_deal_id, [field], [value])
	SELECT DISTINCT source_system_id, source_deal_id, value_id, [value]
	FROM #formula t
	INNER JOIN static_data_value sdv ON sdv.code = 'Weight' +CASE WHEN tariff = 'OffPeak' THEN ' Offpeak' ELSE '' END + CAST(row_id AS VARCHAR) AND TYPE_ID = 5500
	WHERE CHARINDEX('Formula_MULT',formula)>0 AND row_id IS NOT NULL 
	


	DECLARE @listCol_formula VARCHAR(5000)
	
	;WITH CTE AS (
	SELECT 
		t.source_system_id, t.source_deal_id, t.term_start, t.term_end, t.leg, 
		CASE WHEN CHARINDEX('Formula_Mult',t.formula)>0 THEN CASE WHEN pfm.curve_type IS NOT NULL THEN 'dbo.FNA'+pfm.curve_type +'('+CAST(pfm.curve_id AS VARCHAR)+ CASE WHEN pfm.curve_type = 'CurveD' THEN  ',dbo.FNAUDFValue('+ISNULL(CAST(sdv1.value_id AS VARCHAR),'')+')' ELSE '' END +')' ELSE 'dbo.FNALagCurve('+CAST(pfm.curve_id AS VARCHAR)+','+CAST(pfm.relative_year AS VARCHAR)+','+CAST(pfm.strip_month_FROM AS VARCHAR)+','+CAST(pfm.lag_month AS VARCHAR)+','+CAST(pfm.strip_month_to AS VARCHAR)+','+ISNULL(CAST(pfm.currency_id AS VARCHAR),'NULL')+','+ISNULL(CAST(pfm.price_adder AS VARCHAR),'NULL')+ CASE WHEN sdv1.value_id IS NOT NULL THEN ',dbo.FNAUDFValue('+ISNULL(CAST(sdv1.value_id AS VARCHAR),'')+'),' ELSE ',0,' END +ISNULL('''' + CAST(NULLIF(pfm.exp_type,'') + '''' AS VARCHAR),'NULL')+','+ISNULL(CAST(NULLIF(pfm.exp_value,'') AS VARCHAR),'NULL')+')' END
			--WHEN CHARINDEX('Formula_ADD',t.formula)>0 THEN 'dbo.FNAUDFValue('+CAST(sdv.value_id AS VARCHAR)+')'
			WHEN sdv.value_id IS NOT NULL THEN 'dbo.FNAUDFValue('+CAST(sdv.value_id AS VARCHAR)+')'
			ELSE '' END AS FORMULA,
		--CASE WHEN [value]<0 THEN '-' ELSE '+' END AS formula_sign,
		'+' AS formula_sign,
		tariff,ISNULL(row_id,999) row_id  
	FROM
		#formula t
		INNER JOIN #deal_header dh ON dh.source_deal_id = t.source_deal_id
		AND dh.source_system_id = t.source_system_id
		LEFT JOIN pratos_formula_mapping pfm ON '('+pfm.source_Formula+')' = LTRIM(RTRIM(REPLACE(REPLACE(t.formula,'Formula_Mult_OFF',''),'Formula_Mult','')))
		--LEFT JOIN static_data_value sdv ON '('+sdv.code+')' = LTRIM(RTRIM(REPLACE(REPLACE(t.formula,'Formula_ADD_OFF',''),'Formula_ADD',''))) AND sdv.TYPE_ID = 5500
		LEFT JOIN static_data_value sdv ON sdv.code = t.formula AND sdv.TYPE_ID = 5500 AND sdv.code IN ('Fixed', 'Fixed_Offpeak') AND dh.fixing IS NULL
		LEFT JOIN static_data_value sdv1 ON sdv1.code = 'Weight'+CASE WHEN tariff = 'OffPeak' THEN ' Offpeak' ELSE '' END +CAST(row_id AS VARCHAR) AND sdv1.TYPE_ID = 5500          
	WHERE
		t.[value] <>0	
	)
	
			
	INSERT INTO #formula_parsed (source_system_id, source_deal_id, term_start, term_end, leg, formula,tariff)
	SELECT tmp.source_system_id, tmp.source_deal_id, tmp.term_start, tmp.term_end, tmp.leg, (p.con_formula) frm ,tmp.tariff
	FROM CTE tmp
	CROSS APPLY (
		SELECT STUFF(
		(SELECT  formula_sign + LTRIM( formula ) 
		FROM CTE
			WHERE 
			source_deal_id = tmp.source_deal_id
			AND ISNULL(tariff,'Peak') = ISNULL(tmp.tariff,'Peak')
			AND NULLIF(FORMULA,'') IS NOT NULL
		GROUP BY formula_sign + LTRIM( formula )  ORDER BY MAX(row_id)	
		FOR XML PATH('')),1,1,'')  AS con_formula
	) p
	GROUP BY tmp.source_system_id, tmp.source_deal_id, tmp.term_start, tmp.term_end, tmp.leg,p.con_formula,tmp.tariff
	
	
	/** Parse Formula END **/

	------- END OF SECTION 1 --------


	------- BEGINNING OF SECTION 2 --------

	/** Log Import Status BEGIN **/


	
		
	-- DUPLICATE_UDF_FIELD	
	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
	SELECT NULL, @process_id, 'DUPLICATE_UDF_FIELD', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
		'Data error for id: ' + ISNULL(a.source_deal_id,'NULL') + '. (Duplicate UDF field: ' + a.[field] + ')', 
		'Please check your data', 'Duplicate UDF field: ' + ISNULL(a.[field], 'NULL'), a.source_deal_id, ISNULL(a.[field], 'NULL'),'h'
	FROM #udf a 
	GROUP BY source_deal_id, field
	HAVING COUNT(field) > 1
	
				
	-- MISSING_STATIC_DATA	
	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
	SELECT a.temp_id, @process_id, 'MISSING_STATIC_DATA', 'Pratos Data Import', 'Pratos Data Import', 'Data Error',
		'Data error for id: ' + ISNULL(a.source_deal_id,'NULL') + '. (Invalid Data for block_description: ' + a.[block_description] + ')', 
		'Please check your data', 'Block Definition ' + ISNULL(a.[block_description], 'NULL') + ' not found', a.source_deal_id, 'block_description: ' + ISNULL(a.[block_description], 'NULL'),'h'
	FROM #deal_header a 
	LEFT JOIN static_data_value b ON b.code = a.[block_description]
	WHERE  b.value_id IS NULL AND a.[block_description] IS NOT NULL

	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
	SELECT a.temp_id, @process_id,'MISSING_STATIC_DATA','Pratos Data Import','Pratos Data Import','Data Error',
		'Data error for id: ' + ISNULL(a.source_deal_id, 'NULL') + '. (Foreign Key deal_type '+ISNULL(a.deal_type,'NULL')+' is not found)',
		'Please check your data','Deal type '+ ISNULL(a.deal_type,'NULL') + ' not found',a.source_deal_id, 'deal_type: ' + ISNULL(a.deal_type,'NULL'),'h'
	FROM #deal_header a 
	LEFT JOIN source_deal_type b 
		ON b.deal_type_id = a.deal_type 
		AND	b.source_system_id = a.source_system_id 
	WHERE b.deal_type_id IS NULL AND a.deal_type IS NOT NULL 

	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
	SELECT a.temp_id, @process_id,'MISSING_STATIC_DATA','Pratos Data Import','Pratos Data Import','Data Error',
		'Data error for id: ' + ISNULL(a.source_deal_id, 'NULL') + '. (Foreign Key deal_sub_type '+ISNULL(a.deal_sub_type,'NULL')+' is not found)',
		'Please check your data','Deal Sub type '+ ISNULL(a.deal_sub_type,'NULL') + ' not found',a.source_deal_id, 'deal_sub_type: ' + ISNULL(a.deal_sub_type,'NULL'),'h'
	FROM #deal_header a 
	LEFT JOIN source_deal_type b ON b.deal_type_id = a.deal_sub_type AND
	b.source_system_id = a.source_system_id WHERE b.deal_type_id IS NULL AND a.deal_sub_type IS NOT NULL

	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
	SELECT a.temp_id, @process_id,'MISSING_STATIC_DATA','Pratos Data Import','Pratos Data Import','Data Error',
		'Data error for id: ' + ISNULL(a.source_deal_id, 'NULL') + '. (Foreign Key source_book_id1 '+ISNULL(a.source_book_id1,'NULL')+' is not found)',
		'Please check your data','Book1 '+ ISNULL(a.source_book_id1,'NULL') + ' not found',a.source_deal_id, 'source_book_id1: ' + ISNULL(a.source_book_id1,'NULL'),'h'
	FROM #deal_header a 
	LEFT JOIN source_book b 
		ON b.source_system_book_id = a.source_book_id1 
		AND	b.source_system_id = a.source_system_id 
		AND b.source_system_book_type_value_id = 50 
	WHERE b.source_system_book_id IS NULL AND a.source_book_id1 IS NOT NULL 

	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
	SELECT a.temp_id, @process_id,'MISSING_STATIC_DATA','Pratos Data Import','Pratos Data Import','Data Error',
		'Data error for id: ' + ISNULL(a.source_deal_id, 'NULL') + '. (Foreign Key source_book_id2 '+ISNULL(a.source_book_id2,'NULL')+' is not found)',
		'Please check your data' ,'Book2 '+ ISNULL(a.source_book_id2,'NULL') + ' not found',a.source_deal_id, 'source_book_id2: ' + ISNULL(a.source_book_id2,'NULL'),'h'
	FROM #deal_header a 
	LEFT JOIN source_book b 
		ON b.source_system_book_id = a.source_book_id2 
		AND	b.source_system_id = a.source_system_id 
		AND b.source_system_book_type_value_id = 51 
	WHERE b.source_system_book_id IS NULL AND a.source_book_id2 IS NOT NULL

	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
	SELECT a.temp_id, @process_id,'MISSING_STATIC_DATA','Pratos Data Import','Pratos Data Import','Data Error',
		'Data error for id: ' + ISNULL(a.source_deal_id, 'NULL') + '. (Foreign Key source_book_id3 '+ISNULL(a.source_book_id3,'NULL')+' is not found)',
		'Please check your data' ,'Book3 '+ ISNULL(a.source_book_id3,'NULL') + ' not found',a.source_deal_id, 'source_book_id3: ' + ISNULL(a.source_book_id3,'NULL'),'h'
	FROM #deal_header a 
	LEFT JOIN source_book b 
		ON b.source_system_book_id = a.source_book_id3 
		AND	b.source_system_id = a.source_system_id 
		AND b.source_system_book_type_value_id = 52 
	WHERE b.source_system_book_id IS NULL AND a.source_book_id3 IS NOT NULL

	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
	SELECT a.temp_id, @process_id,'MISSING_STATIC_DATA','Pratos Data Import','Pratos Data Import','Data Error',
		'Data error for id: ' + ISNULL(a.source_deal_id, 'NULL') + '. (Foreign Key source_book_id4 '+ISNULL(a.source_book_id4,'NULL')+' is not found)',
		'Please check your data' ,'Book4 '+ ISNULL(a.source_book_id4,'NULL') + ' not found',a.source_deal_id, 'source_book_id4: ' + ISNULL(a.source_book_id4,'NULL'),'h'
	FROM #deal_header a 
	LEFT JOIN source_book b 
		ON b.source_system_book_id = a.source_book_id4 
		AND	b.source_system_id = a.source_system_id 
		AND b.source_system_book_type_value_id = 53 
	WHERE b.source_system_book_id IS NULL AND a.source_book_id4 IS NOT NULL


		


	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag)
	SELECT a.temp_id, @process_id,'MISSING_STATIC_DATA','Pratos Data Import','Pratos Data Import','Data Error',
		'Data error for id: ' + ISNULL(a.source_deal_id, 'NULL') + '. (Foreign Key Template '+ISNULL(a.[template],'NULL')+' is not found)',
		'Please check your data','Template '+ ISNULL(a.[template],'NULL') + ' not found',a.source_deal_id, 'template: ' + ISNULL(a.[template],'NULL'),'h'
	FROM #deal_header a 
	LEFT JOIN source_deal_header_template b 
		ON b.template_name = a.[template]
	WHERE  b.template_name IS NULL AND a.[template] IS NOT NULL


	

	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
	SELECT a.temp_id, @process_id,'MISSING_STATIC_DATA','Pratos Data Import','Pratos Data Import','Data Error',
		'Data error for source_deal_header_id :'+ ISNULL(a.source_deal_id,'NULL')+', term_start:'+ISNULL(a.term_start,'NULL')+
		', term_end :'+ ISNULL(a.term_end,'NULL')+', Leg:'+ISNULL(a.Leg,'NULL')+
		'. Foreign Key volume_uom '+ISNULL(a.volume_uom,'NULL')+' is not found',
		'Please check your data' ,'UOM ID  '+ ISNULL(a.volume_uom,'NULL') + ' not found',a.source_deal_id, 'volume_uom: ' + ISNULL(a.volume_uom,'NULL'),'d'
	FROM #deal_detail a 
	LEFT JOIN source_uom b 
		ON b.uom_id = a.volume_uom 
		AND	b.source_system_id = @source_system_id 
	WHERE b.uom_id IS NULL AND a.volume_uom IS NOT NULL 
	
	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
	SELECT a.temp_id, @process_id,'MISSING_STATIC_DATA','Pratos Data Import','Pratos Data Import','Data Error',
		'Data error for source_deal_header_id :'+ ISNULL(a.source_deal_id,'NULL')+', term_start:'+ISNULL(a.term_start,'NULL')+
		', term_end :'+ ISNULL(a.term_end,'NULL')+', Leg:'+ISNULL(a.Leg,'NULL')+
		'. Foreign Key price_uom '+ISNULL(a.price_uom,'NULL')+' is not found',
		'Please check your data' ,'UOM ID  '+ ISNULL(a.price_uom,'NULL') + ' not found',a.source_deal_id, 'price_uom: ' + ISNULL(a.price_uom,'NULL'),'d'
	FROM #deal_detail a 
	LEFT JOIN source_uom b 
		ON b.uom_id = a.price_uom 
		AND	b.source_system_id = @source_system_id 
	WHERE b.uom_id IS NULL AND a.price_uom IS NOT NULL	
	
	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
	SELECT a.temp_id, @process_id,'MISSING_STATIC_DATA','Pratos Data Import','Pratos Data Import','Data Error',
		'Data error for source_deal_header_id :'+ ISNULL(a.source_deal_id,'NULL')+', term_start:'+ISNULL(a.term_start,'NULL')+
		', term_end :'+ ISNULL(a.term_end,'NULL')+', Leg:'+ISNULL(a.Leg,'NULL')+
		'. Foreign Key price_currency_id '+ISNULL(a.price_currency,'NULL')+' is not found',
		'Please check your data' ,'Currency ID  '+ ISNULL(a.price_currency,'NULL') + ' not found',a.source_deal_id, 'price_currency_id: ' + ISNULL(a.price_currency,'NULL'),'d'
	FROM #deal_detail a 
	LEFT JOIN source_currency b 
		ON b.currency_id = a.price_currency 
		AND	b.source_system_id = @source_system_id 
	WHERE b.currency_id IS NULL AND a.price_currency IS NOT NULL


	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
	SELECT a.temp_id, @process_id,'MISSING_STATIC_DATA','Pratos Data Import','Pratos Data Import','Data Error',
		'Data error for source_deal_header_id :'+ ISNULL(a.source_deal_id,'NULL')+', term_start:'+ISNULL(a.term_start,'NULL')+
		', term_end :'+ ISNULL(a.term_end,'NULL')+', Leg:'+ISNULL(a.Leg,'NULL')+
		'. Foreign Key Adder Currency '+ISNULL(a.adder_currency,'NULL')+' is not found',
		'Please check your data' ,'Currency ID  '+ ISNULL(a.adder_currency,'NULL') + ' not found',a.source_deal_id, 'Adder Currency: ' + ISNULL(a.adder_currency,'NULL'),'d'
	FROM #deal_detail a 
	LEFT JOIN source_currency b 
		ON b.currency_id = a.adder_currency 
		AND	b.source_system_id = @source_system_id 
	WHERE b.currency_id IS NULL AND a.adder_currency IS NOT NULL



	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
	SELECT a.temp_id, @process_id,'MISSING_STATIC_DATA','Pratos Data Import','Pratos Data Import','Data Error',
		'Data error for source_deal_header_id :'+ ISNULL(a.source_deal_id,'NULL')+', term_start:'+ISNULL(a.term_start,'NULL')+
		', term_end :'+ ISNULL(a.term_end,'NULL')+', Leg:'+ISNULL(a.Leg,'NULL')+
		'. Foreign Key Formula Currency '+ISNULL(a.formula_currency,'NULL')+' is not found',
		'Please check your data' ,'Currency ID  '+ ISNULL(a.formula_currency,'NULL') + ' not found',a.source_deal_id, 'Formula Currency: ' + ISNULL(a.formula_currency,'NULL'),'d'
	FROM #deal_detail a 
	LEFT JOIN source_currency b 
		ON b.currency_id = a.formula_currency 
		AND	b.source_system_id = @source_system_id 
	WHERE b.currency_id IS NULL AND a.formula_currency IS NOT NULL
		

	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
	SELECT a.temp_id, @process_id,'MISSING_STATIC_DATA','Pratos Data Import','Pratos Data Import','Data Error',
		'Data error for source_deal_header_id :'+ ISNULL(a.source_deal_id,'NULL')+', term_start:'+ISNULL(a.term_start,'NULL')+
		', term_end :'+ ISNULL(a.term_end,'NULL')+', Leg:'+ISNULL(a.Leg,'NULL')+
		'. Foreign Key Fixed Cost Currency '+ISNULL(a.fixed_cost_currency,'NULL')+' is not found',
		'Please check your data' ,'Currency ID  '+ ISNULL(a.fixed_cost_currency,'NULL') + ' not found',a.source_deal_id, 'Fixed Cost Currency: ' + ISNULL(a.fixed_cost_currency,'NULL'),'d'
	FROM #deal_detail a 
	LEFT JOIN source_currency b 
		ON b.currency_id = a.fixed_cost_currency 
		AND	b.source_system_id = @source_system_id 
	WHERE b.currency_id IS NULL AND a.fixed_cost_currency IS NOT NULL
		


	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
	SELECT a.temp_id, @process_id,'MISSING_STATIC_DATA','Pratos Data Import','Pratos Data Import','Data Error',
		'Data error for source_deal_header_id :'+ ISNULL(a.source_deal_id,'NULL')+', term_start:'+ISNULL(a.term_start,'NULL')+
		', term_end :'+ ISNULL(a.term_end,'NULL')+', Leg:'+ISNULL(a.Leg,'NULL')+
		'. Foreign Key Profile '+ISNULL(a.profile_code,'NULL')+' is not found',
		'Please check your data' ,'Profile Code  '+ ISNULL(a.profile_code,'NULL') + ' not found',a.source_deal_id, 'Profile Code: ' + ISNULL(a.profile_code,'NULL'),'d'
	FROM #deal_detail a 
		LEFT JOIN forecast_profile b 
			ON b.external_id = a.profile_code 
		WHERE b.external_id IS NULL AND a.profile_code IS NOT NULL AND a.physical_financial_flag = 'p'
				
	/** Log Import Status END **/


		
	-- Automatically insert parent counterparty and counterparty if they do not exist
	INSERT INTO source_counterparty(source_system_id, counterparty_id, counterparty_name, counterparty_desc, int_ext_flag)
	SELECT DISTINCT @source_system_id, parent_counterparty, parent_counterparty, parent_counterparty, 'e' FROM #deal_header dh 
	LEFT JOIN source_counterparty sc ON sc.counterparty_id = dh.parent_counterparty AND sc.source_system_id = dh.source_system_id 
	WHERE sc.source_counterparty_id IS NULL AND parent_counterparty IS NOT NULL 

	
	
			
	-- Give Error Message if Book Mapping is missing
	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
	SELECT dd.temp_id,@process_id,'MISSING_STATIC_DATA','Pratos Data Import','Pratos Data Import','Data Error',
		   'Data error for source_deal_header_id :'+ ISNULL(dd.source_deal_id,'NULL')+'. Source Book Mapping not found
		   for Counterparty:'+ISNULL(dh.parent_counterparty,'NULL')+',Country:'+ ISNULL(dd.country,'NULL')+',Grid:'+ ISNULL(dd.grid,'NULL')+',Category:'+ ISNULL(dd.category,'NULL')+',Region:'+ ISNULL(dd.region,'NULL')+'.',
		   'Please check your data' ,'Book Mapping not found',ISNULL(dd.source_deal_id,'NULL'), 'Book Mapping not found for Counterparty:'+ISNULL(dh.parent_counterparty, 'NULL')+',Country:'+ ISNULL(dd.country,'NULL')+',Grid:'+ ISNULL(dd.grid,'NULL')+',Category:'+ ISNULL(dd.category,'NULL')+',Region:'+ ISNULL(dd.region,'NULL')+'.','d'
	FROM #deal_header dh
	INNER JOIN #deal_detail dd  ON dh.source_deal_id = dd.source_deal_id
	LEFT JOIN source_counterparty sc ON sc.counterparty_id = dh.parent_counterparty 
	LEFT JOIN static_data_value sdv1 ON sdv1.code = dd.country AND sdv1.type_id = 14000
	LEFT JOIN static_data_value sdv2 ON sdv2.code = dd.grid AND sdv2.type_id = 18000
	LEFT JOIN static_data_value sdv3 ON sdv3.code = dd.category AND sdv3.type_id = 18100
	LEFT JOIN static_data_value sdv4 ON sdv4.code = dd.region AND sdv4.type_id = 11150
	LEFT JOIN source_commodity com ON com.commodity_id = dh.commodity
	LEFT JOIN pratos_book_mapping pbm 
		ON ISNULL(pbm.counterparty_id, -1) = ISNULL(sc.source_counterparty_id, -1) 
		AND ISNULL(pbm.country_id, -1) = ISNULL(sdv1.value_id, -1) 
		AND ISNULL(pbm.grid_id, -1) = ISNULL(sdv2.value_id, -1)
		AND ISNULL(pbm.category, -1) = ISNULL(sdv3.value_id, -1)	
		AND com.source_commodity_id <> -3
		AND pbm.region IS NULL
	LEFT JOIN pratos_book_mapping pbm1
		ON ISNULL(pbm1.region, -1) = ISNULL(sdv4.value_id, -1) 
		AND ISNULL(pbm1.country_id, -1) = ISNULL(sdv1.value_id, -1) 
		AND ISNULL(pbm1.grid_id, -1) = ISNULL(sdv2.value_id, -1)
		AND ISNULL(pbm1.category, -1) = ISNULL(sdv3.value_id, -1)
		AND ISNULL(pbm1.counterparty_id, -1) = ISNULL(sc.source_counterparty_id, -1) 	
		AND com.source_commodity_id = -3		
	WHERE 
		ISNULL(pbm.[id],pbm1.[id]) IS NULL 


	-- Give Error Message if Index Mapping is missing
	INSERT INTO #import_status(temp_id,process_id,ErrorCode,MODULE,Source,TYPE,[description],nextstep,type_error,external_type_id,field,header_detail_flag) 
	SELECT 	
	dd.temp_id,@process_id,'MISSING_STATIC_DATA','Pratos Data Import','Pratos Data Import','Data Error',
		   'Data error for source_deal_header_id :'+ ISNULL(dd.source_deal_id,'NULL')+'. Index Mapping not found
		   for Location Group:'+ISNULL(dd.location_group,'NULL')+',Grid:'+ ISNULL(dd.grid,'NULL')+',Region:'+ ISNULL(dd.region,'NULL')+',TOU:'+ ISNULL(dd.tou_tariff,'NULL')+',Category:'+ ISNULL(dd.category,'NULL')+',Country:'+ ISNULL(dd.country,'NULL')+'.',
		   'Please check your data', 'Index Mapping not found', dd.source_deal_id, 
		   'Index Mapping not found for Location Group:'+ISNULL(dd.location_group, 'NULL')+',Grid:'+ ISNULL(dd.grid, 'NULL')+',Region:'+ ISNULL(dd.region, 'NULL')+',TOU:'+ ISNULL(dd.tou_tariff, 'NULL')+',Category:'+ ISNULL(dd.category,'NULL')+',Country:'+ ISNULL(dd.country,'NULL')+'.','d'
	FROM #deal_header dh
	INNER JOIN #deal_detail dd  ON dh.source_deal_id = dd.source_deal_id
	LEFT JOIN static_data_value sdv1 ON sdv1.code = dd.grid AND sdv1.type_id = 18000
	LEFT JOIN static_data_value sdv2 ON sdv2.code = dd.region AND sdv2.type_id = 11150
	LEFT JOIN source_major_location smaj ON smaj.location_name = dd.location_group 
	LEFT JOIN static_data_value sdv3 ON sdv3.code = dd.country AND sdv3.type_id = 14000
	LEFT JOIN static_data_value sdv4 ON sdv4.code = dd.category AND sdv4.type_id = 18100
	LEFT JOIN source_commodity sc ON sc.commodity_id = dh.commodity
	LEFT JOIN pratos_source_price_curve_map pspcm 
		ON ISNULL(pspcm.location_group_id, -1) = ISNULL(smaj.source_major_location_id, -1) 
		AND ISNULL(pspcm.grid_value_id, -1) = ISNULL(sdv1.value_id, -1)
		AND ISNULL(pspcm.region, -1) = ISNULL(sdv2.value_id, -1)
		AND ISNULL(pspcm.block_type, -1) = ISNULL(dd.tou_tariff, -1)
		AND NULLIF(pspcm.location_group_id,'') IS NOT NULL
		AND sc.source_commodity_id <> -3
		AND pspcm.category_id IS NULL
		AND pspcm.country_id IS NULL
	LEFT JOIN pratos_source_price_curve_map pspcm1
		ON 
		ISNULL(pspcm1.grid_value_id, -1) = ISNULL(sdv1.value_id, -1) 
		AND ISNULL(pspcm1.region, -1) = ISNULL(sdv2.value_id, -1) 
		AND ISNULL(pspcm1.block_type, -1) = ISNULL(dd.tou_tariff, -1)
		AND NULLIF(pspcm1.location_group_id,'') IS NULL
		AND sc.source_commodity_id <> -3
		AND pspcm1.category_id IS NULL
		AND pspcm1.country_id IS NULL
	LEFT JOIN pratos_source_price_curve_map pspcm2
		ON 
		ISNULL(pspcm2.grid_value_id, -1) = ISNULL(sdv1.value_id, -1) 
		AND ISNULL(pspcm2.region, -1) = ISNULL(sdv2.value_id, -1) 
		AND ISNULL(pspcm2.category_id, -1) = ISNULL(sdv4.value_id, -1)
		AND NULLIF(pspcm2.country_id,-1) = ISNULL(sdv3.value_id, -1)
		AND sc.source_commodity_id = -3 -- JOIN for 'Sustainable Commodity'
		
	WHERE 
		COALESCE(pspcm.[id],pspcm1.[id],pspcm2.[id]) IS NULL 
		AND dh.deal_type <> 'Fee'
	
	
	BEGIN TRAN 
	
		
	IF @bulk_import ='y'
		DELETE f FROM #formula_parsed f 
			INNER JOIN #price_without_formula pwf 
			ON pwf.source_deal_id = f.source_deal_id 
			AND pwf.source_system_id = f.source_system_id
			AND pwf.tariff = f.tariff
			
			
	DELETE dh FROM #import_status i 
	INNER JOIN #deal_header dh ON dh.source_deal_id = i.external_type_id
	
	DELETE dd FROM #import_status i
	INNER JOIN #deal_detail dd ON dd.source_deal_id = i.external_type_id

	SELECT @total_deals_found = COUNT(*) FROM #deal_header 
	SELECT @total_deal_details_found = COUNT(*) FROM #deal_detail 

	EXEC spa_print 'BEGIN main table process'
	IF EXISTS (SELECT 1 FROM #deal_header) AND ((@bulk_import ='y' AND @process_staging_table ='y') OR @bulk_import ='n')
	BEGIN

		/** Automatically Insert Missing Foreign Keys  BEGIN **/
	
		INSERT INTO source_legal_entity (source_system_id, legal_entity_id, legal_entity_name, legal_entity_desc)
		SELECT DISTINCT @source_system_id, a.legal_entity, a.legal_entity, a.legal_entity FROM #deal_header a 
		LEFT JOIN source_legal_entity le 
			ON le.legal_entity_id = a.legal_entity 
			AND le.source_system_id = a.source_system_id 
		WHERE le.legal_entity_id IS NULL AND a.legal_entity IS NOT NULL

		INSERT INTO source_traders(source_system_id, trader_id, trader_name, trader_desc)
		SELECT DISTINCT @source_system_id, a.trader_name, a.trader_name, a.trader_name 
		FROM #deal_header a 
		LEFT JOIN source_traders b 
			ON b.trader_id = a.trader_name 
			AND	b.source_system_id = a.source_system_id 
		WHERE b.trader_id IS NULL

		INSERT INTO contract_group (source_system_id, contract_name, contract_desc, source_contract_id,energy_type,volume_granularity)
		SELECT DISTINCT @source_system_id, a.framework, a.framework, a.framework,'p',980 
		FROM #deal_header a 
		LEFT JOIN contract_group b ON b.contract_name = a.framework AND
		b.source_system_id = a.source_system_id WHERE b.contract_name IS NULL	 
		
		INSERT INTO static_data_value(TYPE_ID, code, description) 
		SELECT DISTINCT 14000, country, country FROM #deal_detail a
		LEFT JOIN static_data_value b ON b.code = a.country AND b.type_id = 14000
		WHERE b.code IS NULL AND a.country IS NOT NULL 
		
		INSERT INTO static_data_value(TYPE_ID, code, description) 
		SELECT DISTINCT 11150, region, region FROM #deal_detail a
		LEFT JOIN static_data_value b ON b.code = a.region AND b.type_id = 11150
		WHERE b.code IS NULL AND a.region IS NOT NULL 
		
		INSERT INTO static_data_value(TYPE_ID, code, description) 
		SELECT DISTINCT 18000, grid, grid FROM #deal_detail a
		LEFT JOIN static_data_value b ON b.code = a.grid AND b.type_id = 18000
		WHERE b.code IS NULL AND a.grid IS NOT NULL 		

		-- add deal detail category, static data
		INSERT INTO static_data_value(TYPE_ID, code, description) 
		SELECT DISTINCT 18100, category, category FROM #deal_detail a
		LEFT JOIN static_data_value b ON b.code = a.category AND b.type_id = 18100
		WHERE b.code IS NULL AND a.category IS NOT NULL 	


		INSERT INTO source_major_location (source_system_id, location_name, location_description)
		SELECT DISTINCT @source_system_id, a.location_group, a.location_group 
		FROM #deal_detail a 
		LEFT JOIN source_major_location b 
			ON b.location_name = a.location_group 
			AND	b.source_system_id = a.source_system_id 
		WHERE b.location_name IS NULL AND a.location_group IS NOT NULL 
		


		--######### If forecast needed then profile = EAN(location), proxy profile = profile_code
		INSERT INTO forecast_profile(external_id,profile_type,available,profile_name,uom_id)
		SELECT 
			DISTINCT location,17500,NULL,location,su.source_uom_id
		FROM
			#deal_detail dd
			LEFT JOIN #udf udf ON dd.source_deal_id = udf.source_deal_id
				AND dd.source_system_id = udf.source_system_id
				AND udf.field = 'IsProfiled'
			LEFT JOIN forecast_profile fp ON dd.location = fp.external_id
			LEFT JOIN #deal_header dh ON dh.source_deal_id = dd.source_deal_id
				AND dh.source_system_id = dd.source_system_id
			LEFT JOIN source_uom su ON su.uom_id = CASE WHEN dh.commodity = 'Gas' THEN @gas_UOM WHEN dh.commodity = 'Power' THEN @power_UOM ELSE NULL END
		WHERE
			udf.value = 'N'		
			AND fp.profile_id IS NULL
			AND dd.physical_financial_flag = 'p'


		--####### find the deals whose volume/syv has changed to trigger forecast	
			INSERT INTO	#forecast_trigger_deals
			SELECT 
				DISTINCT dh.source_deal_id
			FROM
				#deal_detail dd
				LEFT JOIN #deal_header dh On dd.source_deal_id = dh.source_deal_id
				LEFT JOIN source_minor_location sml 
					ON sml.location_name = dh.source_deal_id_old+'_'+dd.location
					AND	sml.source_system_id = @source_system_id	
			WHERE
				dd.physical_financial_flag = 'p' 
				AND ISNULL(sml.forecast_needed,'n') <> ISNULL(dd.forecast_needed,'n')



		UPDATE sml 
		SET location_description = dh.source_deal_id_old+'_'+a.location,
			postal_code = a.postal_code,
			province = a.province,
			physical_shipper = a.physical_shipper,
			sicc_code = a.sicc_code,
			profile_code = a.profile_code,
			nominatorsapcode = a.nominatorsapcode,
			forecast_needed = a.forecast_needed,
			forecasting_group = a.forecasting_group,
			external_profile = a.external_profile,
			calculation_method = a.calculation_method,
			country = sdv1.value_id,
			region = sdv2.value_id, 
			grid_value_id = sdv3.value_id, 
			source_major_location_ID = smjl.source_major_location_ID ,
			profile_id = ISNULL(fp.profile_id,fp2.profile_id),
			proxy_profile_id = fp1.profile_id,
			is_active = 'y'
			
		FROM #deal_detail a 
		LEFT JOIN source_major_location smjl 
			ON smjl.location_name = a.location_group AND smjl.source_system_id = @source_system_id 
		LEFT JOIN static_data_value sdv1 ON sdv1.code = a.country AND sdv1.type_id = 14000
		LEFT JOIN static_data_value sdv2 ON sdv2.code = a.region AND sdv2.type_id = 11150
		LEFT JOIN static_data_value sdv3 ON sdv3.code = a.grid AND sdv3.type_id = 18000
		LEFT JOIN #deal_header dh On a.source_deal_id = dh.source_deal_id
		INNER JOIN source_minor_location sml 
			ON sml.location_name = dh.source_deal_id_old+'_'+a.location
			AND	sml.source_system_id = @source_system_id
		LEFT JOIN #udf udf ON a.source_deal_id = udf.source_deal_id
				AND a.source_system_id = udf.source_system_id
				AND udf.field = 'IsProfiled'
		LEFT JOIN forecast_profile fp ON fp.external_id = a.location AND udf.value = 'N'
		LEFT JOIN forecast_profile fp1 ON fp1.external_id = a.profile_code AND udf.value = 'N'
		LEFT JOIN forecast_profile fp2 ON fp2.external_id = a.profile_code AND udf.value = 'Y'
		WHERE
			a.physical_financial_flag = 'p'
		
			
		INSERT INTO source_minor_location(
			source_system_id, 
			location_name, 
			location_description,
			 
			postal_code,
			province,
			physical_shipper,
			sicc_code,
			profile_code,
			nominatorsapcode,
			forecast_needed,
			forecasting_group,
			external_profile,
			calculation_method,
			country,
			region, 
			grid_value_id, 
			source_major_location_ID,		--location_group 
			profile_id,
			proxy_profile_id,
			is_active
		)
		SELECT DISTINCT 
			@source_system_id, 
			LEFT(dh.source_deal_id_old+'_'+location, 100),  
			LEFT(dh.source_deal_id_old+'_'+location, 500), 	
			a.postal_code,
			MAX(a.province),
			a.physical_shipper,
			a.sicc_code,
			MAX(a.profile_code),
			a.nominatorsapcode,
			a.forecast_needed,
			MAX(a.forecasting_group),
			a.external_profile,
			a.calculation_method,
			sdv1.value_id,					--a.country,
			sdv2.value_id,					--a.region,
			sdv3.value_id,					--a.grid,
			smjl.source_major_location_ID,	--a.location_group	
			MAX(ISNULL(fp.profile_id,fp2.profile_id)),
			MAX(fp1.profile_id),
			'y'
		FROM #deal_detail a JOIN #deal_header dh On a.source_deal_id = dh.source_deal_id
			LEFT JOIN source_major_location smjl 
				ON smjl.location_name = a.location_group AND smjl.source_system_id = @source_system_id 
			LEFT JOIN static_data_value sdv1 ON sdv1.code = a.country AND sdv1.type_id = 14000
			LEFT JOIN static_data_value sdv2 ON sdv2.code = a.region AND sdv2.type_id = 11150
			LEFT JOIN static_data_value sdv3 ON sdv3.code = a.grid AND sdv3.type_id = 18000
			LEFT JOIN source_minor_location sml 
				ON sml.location_name = dh.source_deal_id_old+'_'+a.location
				AND	sml.source_system_id = @source_system_id
			LEFT JOIN #udf udf ON a.source_deal_id = udf.source_deal_id
					AND a.source_system_id = udf.source_system_id
					AND udf.field = 'IsProfiled'
		LEFT JOIN forecast_profile fp ON fp.external_id = a.location AND udf.value = 'N'
		LEFT JOIN forecast_profile fp1 ON fp1.external_id = a.profile_code AND udf.value = 'N'
		LEFT JOIN forecast_profile fp2 ON fp2.external_id = a.profile_code AND udf.value = 'Y'		
		WHERE 
			sml.source_minor_location_id IS NULL AND a.location IS NOT NULL AND a.profile_code IS NOT NULL
			 AND a.physical_financial_flag = 'p'
		GROUP BY dh.source_deal_id_old+'_'+location,
			a.postal_code,
			--a.province,
			a.physical_shipper,a.sicc_code,a.nominatorsapcode,
			a.forecast_needed,
			--a.forecasting_group,
			a.external_profile,a.calculation_method,sdv1.value_id,
			sdv2.value_id,sdv3.value_id,smjl.source_major_location_ID
				 
		/** Automatically Insert Missing Foreign Keys  END **/


	---############# Insert Meter and Mapping	
	-- If is profiled='n', meter_id will be the EAN number
		CREATE TABLE #affected_meter(meter_id INT)
		
		INSERT INTO meter_id(recorderid,[description],counterparty_id,commodity_id,country_id)
		OUTPUT INSERTED.meter_id INTO #affected_meter
		SELECT 
			DISTINCT location,location,MAX(sc.source_counterparty_id),MAX(sc2.source_commodity_id),MAX(sdv.value_id)
		FROM
			#deal_detail dd
			INNER JOIN #deal_header dh ON dh.source_deal_id = dd.source_deal_id
				AND dh.source_system_id = dd.source_system_id
			LEFT JOIN meter_id mi ON dd.location = mi.recorderid
			LEFT JOIN source_counterparty sc ON sc.counterparty_id = dh.parent_counterparty
			LEFT JOIN source_commodity sc2 ON sc2.commodity_id = dh.commodity AND sc2.source_system_id = @source_system_id	
			LEFT JOIN static_data_value sdv ON sdv.code=dd.country AND sdv.type_id=14000
			LEFT JOIN source_commodity com ON com.commodity_id = dh.commodity
			LEFT JOIN static_data_value sdv1 ON sdv1.code=dd.category
			LEFT JOIN static_data_value sdv2 ON sdv2.code=dd.region
			LEFT JOIN static_data_value sdv3 ON sdv3.code=dd.grid
			LEFT JOIN group_meter_mapping gmm ON gmm.counterparty_id=sc.source_counterparty_id
				AND gmm.category_id=sdv1.value_id
				AND gmm.region_id=sdv2.value_id
				AND gmm.grid_id=sdv3.value_id

		WHERE			
			mi.recorderid IS NULL
			AND dd.physical_financial_flag = 'p'
			AND com.source_commodity_id <> -3
			AND gmm.group_meter_mapping_id IS NULL
		GROUP BY location	


---######### If it is redelivery meter, Strip "_R" and insert meter

	INSERT INTO meter_id(recorderid,[description],counterparty_id,commodity_id,country_id,sub_meter_id)
		OUTPUT INSERTED.meter_id INTO #affected_meter
		SELECT 
			DISTINCT REPLACE(location,'_R',''),REPLACE(location,'_R',''),MAX(sc.source_counterparty_id),MAX(sc2.source_commodity_id),MAX(sdv.value_id),MAX(mi1.meter_id)
		FROM
			#deal_detail dd
			INNER JOIN #deal_header dh ON dh.source_deal_id = dd.source_deal_id
				AND dh.source_system_id = dd.source_system_id
			LEFT JOIN meter_id mi ON REPLACE(dd.location ,'_R','') = mi.recorderid
			LEFT JOIN source_counterparty sc ON sc.counterparty_id = dh.parent_counterparty
			LEFT JOIN source_commodity sc2 ON sc2.commodity_id = dh.commodity AND sc2.source_system_id = @source_system_id	
			LEFT JOIN static_data_value sdv ON sdv.code=dd.country AND sdv.type_id=14000
			LEFT JOIN meter_id mi1 ON mi1.recorderid = dd.location
			LEFT JOIN source_commodity com ON com.commodity_id = dh.commodity
			LEFT JOIN static_data_value sdv1 ON sdv1.code=dd.category
			LEFT JOIN static_data_value sdv2 ON sdv2.code=dd.region
			LEFT JOIN static_data_value sdv3 ON sdv3.code=dd.grid
			LEFT JOIN group_meter_mapping gmm ON gmm.counterparty_id=sc.source_counterparty_id
				AND gmm.category_id=sdv1.value_id
				AND gmm.region_id=sdv2.value_id
				AND gmm.grid_id=sdv3.value_id

		WHERE			
			mi.recorderid IS NULL
			AND location LIKE '%_R'
			AND dd.physical_financial_flag = 'p'
			AND com.source_commodity_id <> -3
			AND gmm.group_meter_mapping_id IS NULL
		GROUP BY location	


	--- Insert in the mapping table for the location with forecast(i.e. isprofiled='n')
	INSERT INTO source_minor_location_meter(meter_id,source_minor_location_id)
	SELECT 
			DISTINCT mi.meter_id,sml.source_minor_location_id
	FROM	
			#deal_detail dd
			INNER JOIN #deal_header dh ON dh.source_deal_id = dd.source_deal_id
				AND dh.source_system_id = dd.source_system_id	
			INNER JOIN meter_id mi ON dd.location = mi.recorderid
			INNER JOIN source_minor_location sml ON sml.Location_Name=LEFT(dh.source_deal_id_old+'_'+location, 100)  
			LEFT JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id=sml.source_minor_location_id
			LEFT JOIN source_commodity com ON com.commodity_id = dh.commodity
			LEFT JOIN source_counterparty sc ON sc.counterparty_id = dh.parent_counterparty
			LEFT JOIN static_data_value sdv1 ON sdv1.code=dd.category
			LEFT JOIN static_data_value sdv2 ON sdv2.code=dd.region
			LEFT JOIN static_data_value sdv3 ON sdv3.code=dd.grid
			LEFT JOIN group_meter_mapping gmm ON gmm.counterparty_id=sc.source_counterparty_id
				AND gmm.category_id=sdv1.value_id
				AND gmm.region_id=sdv2.value_id
				AND gmm.grid_id=sdv3.value_id			
	WHERE
		smlm.location_meter_id IS NULL		
		AND com.source_commodity_id <> -3
		AND gmm.group_meter_mapping_id IS NULL

--- ##### Update if exists		
	UPDATE smlm SET smlm.meter_id = m.meter_id
	FROM
	source_minor_location_meter smlm
	INNER JOIN(SELECT 
			DISTINCT mi.meter_id,sml.source_minor_location_id
	FROM	
			#deal_detail dd
			INNER JOIN #deal_header dh ON dh.source_deal_id = dd.source_deal_id
				AND dh.source_system_id = dd.source_system_id	
			INNER JOIN meter_id mi ON dd.location = mi.recorderid
			INNER JOIN source_minor_location sml ON sml.Location_Name=LEFT(dh.source_deal_id_old+'_'+location, 100)  
			LEFT JOIN source_minor_location_meter smlm ON smlm.meter_id=mi.meter_id
				AND smlm.source_minor_location_id=sml.source_minor_location_id
			LEFT JOIN source_commodity com ON com.commodity_id = dh.commodity	
			LEFT JOIN source_counterparty sc ON sc.counterparty_id = dh.parent_counterparty
			LEFT JOIN static_data_value sdv1 ON sdv1.code=dd.category
			LEFT JOIN static_data_value sdv2 ON sdv2.code=dd.region
			LEFT JOIN static_data_value sdv3 ON sdv3.code=dd.grid
			LEFT JOIN group_meter_mapping gmm ON gmm.counterparty_id=sc.source_counterparty_id
				AND gmm.category_id=sdv1.value_id
				AND gmm.region_id=sdv2.value_id
				AND gmm.grid_id=sdv3.value_id			
			
	WHERE
		smlm.location_meter_id IS NULL
		AND com.source_commodity_id <> -3
		AND gmm.group_meter_mapping_id IS NULL
		) m 
		ON smlm.source_minor_location_id=m.source_minor_location_id			
		
			
	-- INSERT in the mapping table for profiled locations
	INSERT INTO source_minor_location_meter(meter_id,source_minor_location_id)
	SELECT 
			DISTINCT gmm.meter_id,sml.source_minor_location_id
	FROM	
			#deal_detail dd
			INNER JOIN #deal_header dh ON dh.source_deal_id = dd.source_deal_id
				AND dh.source_system_id = dd.source_system_id	
			INNER JOIN source_minor_location sml ON sml.Location_Name=LEFT(dh.source_deal_id_old+'_'+location, 100)
			LEFT JOIN source_counterparty sc ON sc.counterparty_id = dh.parent_counterparty  
			LEFT JOIN static_data_value sdv ON sdv.code=dd.region
			LEFT JOIN static_data_value sdv1 ON sdv1.code=dd.category
  		    LEFT JOIN static_data_value sdv2 ON sdv2.type_id=18300 AND sdv1.code ='RWEST NL BV' AND dd.physical_financial_flag='p'
			LEFT JOIN static_data_value sdv3 ON sdv3.code=dd.grid
			LEFT JOIN group_meter_mapping gmm ON gmm.counterparty_id=sc.source_counterparty_id
				AND gmm.region_id=sdv.value_id
				AND gmm.category_id=sdv1.value_id
				--AND gmm.pv_party_id=sdv2.value_id
				AND gmm.grid_id=sdv3.value_id
			LEFT JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id=sml.source_minor_location_id
			LEFT JOIN source_commodity com ON com.commodity_id = dh.commodity
	 WHERE
			smlm.location_meter_id IS NULL				
			AND gmm.meter_id IS NOT NULL
			AND com.source_commodity_id <> -3
	 ---- INSERT the channel as 1 by default

	UPDATE smlm SET smlm.meter_id = m.meter_id
	FROM
	source_minor_location_meter smlm
	INNER JOIN (SELECT 
			DISTINCT gmm.meter_id,sml.source_minor_location_id
		FROM	
				#deal_detail dd
				INNER JOIN #deal_header dh ON dh.source_deal_id = dd.source_deal_id
					AND dh.source_system_id = dd.source_system_id	
				INNER JOIN source_minor_location sml ON sml.Location_Name=LEFT(dh.source_deal_id_old+'_'+location, 100)
				LEFT JOIN source_counterparty sc ON sc.counterparty_id = dh.parent_counterparty  
				LEFT JOIN static_data_value sdv ON sdv.code=dd.region
				LEFT JOIN static_data_value sdv1 ON sdv1.code=dd.category
  				LEFT JOIN static_data_value sdv2 ON sdv2.type_id=18300 AND sdv1.code ='RWEST NL BV' AND dd.physical_financial_flag='p'
				LEFT JOIN static_data_value sdv3 ON sdv3.code=dd.grid
				LEFT JOIN group_meter_mapping gmm ON gmm.counterparty_id=sc.source_counterparty_id
					AND gmm.region_id=sdv.value_id
					AND gmm.category_id=sdv1.value_id
					--AND gmm.pv_party_id=sdv2.value_id
					AND gmm.grid_id=sdv3.value_id
				LEFT JOIN source_minor_location_meter smlm ON smlm.meter_id=gmm.meter_id
					AND smlm.source_minor_location_id=sml.source_minor_location_id
				LEFT JOIN source_commodity com ON com.commodity_id = dh.commodity	
		 WHERE
				smlm.location_meter_id IS NULL				
				AND gmm.meter_id IS NOT NULL
				AND com.source_commodity_id <> -3 ) m
		ON m.source_minor_location_id =smlm.source_minor_location_id

	 INSERT INTO recorder_properties(meter_id,channel,mult_factor,uom_id)
	 SELECT
		mi.meter_id,1,1,CASE WHEN sc.commodity_name = 'Gas' THEN CASE sdv.code  WHEN 'NL' THEN su1.source_uom_id WHEN 'BE' THEN su2.source_uom_id END WHEN sc.commodity_name = 'Power' THEN su3.source_uom_id ELSE NULL END
	  FROM	
		meter_id mi
		INNER JOIN #affected_meter am ON am.meter_id = mi.meter_id
		LEFT JOIN source_commodity sc ON sc.source_commodity_id = mi.commodity_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = mi.country_id AND sdv.type_id=14000
		LEFT JOIN recorder_properties rp ON rp.meter_id=mi.meter_id
		LEFT JOIN source_uom su1 ON su1.uom_id = @nl_gas_UOM
		LEFT JOIN source_uom su2 ON su2.uom_id = @be_gas_UOM
		LEFT JOIN source_uom su3 ON su3.uom_id = @power_UOM
	WHERE
		rp.meter_id IS NULL	  	


	UPDATE rp
		SET rp.uom_id = CASE WHEN sc.commodity_name = 'Gas' THEN CASE sdv.code  WHEN 'NL' THEN su1.source_uom_id WHEN 'BE' THEN su2.source_uom_id END WHEN sc.commodity_name = 'Power' THEN su3.source_uom_id ELSE NULL END
	FROM 
		recorder_properties rp
		INNER JOIN meter_id mi ON mi.meter_id =rp.meter_id
		INNER JOIN #affected_meter am ON am.meter_id = mi.meter_id
		LEFT JOIN source_commodity sc ON sc.source_commodity_id = mi.commodity_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = mi.country_id AND sdv.type_id=14000
		LEFT JOIN source_uom su1 ON su1.uom_id = @nl_gas_UOM
		LEFT JOIN source_uom su2 ON su2.uom_id = @be_gas_UOM
		LEFT JOIN source_uom su3 ON su3.uom_id = @power_UOM

	   	
	/** Insert formula **/
		--INSERT INTO formula_editor (formula, formula_type, system_defined)
		--SELECT DISTINCT fp.formula, 'd', 'n' 
		--FROM #formula_parsed fp
		--LEFT OUTER JOIN formula_editor fe ON fe.formula = fp.formula 
		--WHERE fe.formula_id IS NULL 
		/** Insert formula END **/


		DECLARE @formula VARCHAR(8000), 
				@parsed_formula VARCHAR(MAX)
		
		CREATE TABLE #formula_process_message(ErrorCode VARCHAR(100) COLLATE DATABASE_DEFAULT,Formula VARCHAR(500) COLLATE DATABASE_DEFAULT,Area VARCHAR(100) COLLATE DATABASE_DEFAULT,[Status] VARCHAR(100) COLLATE DATABASE_DEFAULT,[Message] VARCHAR(100) COLLATE DATABASE_DEFAULT,Recommendation VARCHAR(500) COLLATE DATABASE_DEFAULT)
		DECLARE c CURSOR FOR 
			SELECT DISTINCT  dbo.FNAFormulaFormat(fp.formula, 'c')	--, 'd', 'n' 
			FROM 
				 #formula_parsed fp
				 LEFT OUTER JOIN formula_editor fe ON fe.formula = fp.formula
			WHERE fe.formula_id IS NULL 
		
		OPEN c 
		FETCH NEXT FROM c INTO @formula 
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			--SELECT @parsed_formula = dbo.FNAParseFormula(@formula)
			
			
			INSERT INTO #formula_process_message
			EXEC spa_formula_editor 'i', NULL, @formula, 'd', NULL, 'n', NULL, NULL, @parsed_formula, NULL, NULL, NULL
			
			FETCH NEXT FROM c INTO @formula 
		END
		
		CLOSE c
		DEALLOCATE c 



		/* ADD product from PRATOS in internal_portfolio_id column*/
		INSERT INTO source_internal_portfolio (source_system_id, internal_portfolio_id, internal_portfolio_name, internal_portfolio_desc)
		SELECT DISTINCT @source_system_id, a.product, a.product, a.product 
		FROM #deal_header a 
			LEFT JOIN source_internal_portfolio sip 
				ON sip.internal_portfolio_id = a.product 
				AND sip.source_system_id = a.source_system_id 
		WHERE sip.internal_portfolio_id IS NULL AND a.product IS NOT NULL


		-- UPDATE
		--BEGIN
	
			
			
			EXEC spa_print 'BEGIN deal table process'
			--SET @insert_update_flag = 'u'
			
			-- Check if the update deals deal type and term has changed	

			
			SELECT @source_deal_header_id = source_deal_header_id 
			FROM source_deal_header sdh
			INNER JOIN #deal_header dh ON dh.source_deal_id_old = sdh.deal_id AND dh.source_system_id = sdh.source_system_id 

			UPDATE sdh
			SET source_system_id = @source_system_id
				, physical_financial_flag = sdht.physical_financial_flag
				, entire_term_start = min_term_start
				, entire_term_end = max_term_end
				, deal_id = dh.source_deal_id_old
				, block_type = ISNULL(sdv1.value_id,sdht.block_type)	--, block_type
				, block_define_id = ISNULL(sdv2.value_id,sdht.block_define_id)
			--	, description
				, deal_date = CONVERT(VARCHAR(10),dh.deal_date,102)
				, counterparty_id = sc.source_counterparty_id	--, counterparty
				, source_deal_type_id = sdt1.source_deal_type_id	--, deal_type
				, deal_sub_type_type_id = sdt2.source_deal_type_id	--, deal_sub_type
				, option_flag = dh.option_flag
				, source_system_book_id1 = ISNULL(pbm.source_system_book_id1,-1)
				, source_system_book_id2 = ISNULL(pbm.source_system_book_id2,-2)
				, source_system_book_id3 = ISNULL(pbm.source_system_book_id3,-3)
				, source_system_book_id4 = ISNULL(pbm.source_system_book_id4,-4)				
				, description1 = dh.description1
				, description2 = dh.description2
				, description3 = dh.description3
				, deal_category_value_id = ISNULL(sdv3.value_id,475)	--, deal_category_id
				, trader_id = st.source_trader_id	--, trader_name
				, header_buy_sell_flag = LOWER(dh.header_buy_sell_flag)
				, contract_id = cg.contract_id	--, framework
				, legal_entity = sle.source_legal_entity_id
				, template_id = sdht.template_id	--, template
				, deal_status = ISNULL(sdv6.value_id,5604)	--, dh.deal_status
				, internal_desk_id = ISNULL(sdv4.value_id,17300)	--	, profile
				--, product_id = sdv5.value_id	--	, fixing
				, product_id = CASE 
								WHEN fixing IS NULL THEN 4101 -- Original
								ELSE 4100                     -- Price Fixation 
				              END
				, close_reference_id = sdh1.source_deal_header_id 
				, confirm_status_type = sdv7.value_id	--	, confirm_status
				, reference = reference_deal
				, commodity_id = sc2.source_commodity_id
				, update_ts  = GETDATE()			
				, deal_locked = 'y'
				, internal_portfolio_id = sip.source_internal_portfolio_id
				, Pricing = sdd.pricing
				
			OUTPUT INSERTED.source_deal_header_id, INSERTED.deal_id, 'u' INTO #affected_deals
			FROM source_deal_header sdh 
			INNER JOIN #deal_header dh ON dh.source_system_id = sdh.source_system_id AND dh.source_deal_id_old = sdh.deal_id 
			LEFT JOIN static_data_value sdv1 ON sdv1.code = dh.block_type AND sdv1.type_id = 12000
			LEFT JOIN static_data_value sdv2 ON sdv2.code = dh.block_description AND sdv2.type_id = 10018
			LEFT JOIN source_counterparty sc ON sc.counterparty_id = dh.parent_counterparty
			LEFT JOIN source_legal_entity sle ON sle.legal_entity_id = dh.legal_entity
			LEFT JOIN source_deal_type sdt1 ON sdt1.deal_type_id = dh.deal_type
			LEFT JOIN source_deal_type sdt2 ON sdt2.deal_type_id = dh.deal_sub_type
			LEFT JOIN source_book sb1 ON sb1.source_system_book_id = dh.source_book_id1
			LEFT JOIN source_book sb2 ON sb2.source_system_book_id = dh.source_book_id2
			LEFT JOIN source_book sb3 ON sb3.source_system_book_id = dh.source_book_id3
			LEFT JOIN source_book sb4 ON sb4.source_system_book_id = dh.source_book_id4
			LEFT JOIN static_data_value sdv3 ON sdv3.code = dh.deal_category_id AND sdv3.type_id = 475
			LEFT JOIN source_traders st ON st.trader_id = dh.trader_name 
			LEFT JOIN contract_group cg ON cg.contract_name = dh.framework
			LEFT JOIN static_data_value sdv4 ON sdv4.code = dh.profile AND sdv4.type_id = 17300
			--LEFT JOIN static_data_value sdv5 ON sdv5.code = dh.fixing AND sdv5.type_id = 4100
			LEFT JOIN source_deal_header sdh1 ON sdh1.deal_id = dh.fixing AND sdh1.source_system_id = @source_system_id
			LEFT JOIN source_deal_header_template sdht ON sdht.template_name = dh.template
			LEFT JOIN static_data_value sdv6 ON sdv6.code = dh.deal_status AND sdv6.type_id = 5600
			LEFT JOIN static_data_value sdv7 ON sdv7.code = dh.confirm_status AND sdv7.type_id = 17200
			LEFT JOIN source_internal_portfolio sip ON sip.internal_portfolio_id = dh.product
			LEFT JOIN source_commodity sc2 ON sc2.commodity_id = dh.commodity AND sc2.source_system_id = @source_system_id
			
			OUTER APPLY (
				SELECT 
					  MAX(ISNULL(pbm.source_system_book_id1,pbm1.source_system_book_id1)) source_system_book_id1
					, MAX(ISNULL(pbm.source_system_book_id2,pbm1.source_system_book_id2)) source_system_book_id2
					, MAX(ISNULL(pbm.source_system_book_id3,pbm1.source_system_book_id3)) source_system_book_id3
					, MAX(ISNULL(pbm.source_system_book_id4,pbm1.source_system_book_id4)) source_system_book_id4
					, MAX(dd.buy_sell) buy_sell
				FROM #deal_detail dd 
				LEFT JOIN source_counterparty sc2 ON sc2.counterparty_id = dh.parent_counterparty
				LEFT JOIN static_data_value sdv8 ON sdv8.code = dd.country AND sdv8.type_id = 14000
				LEFT JOIN static_data_value sdv9 ON sdv9.code = dd.grid AND sdv9.type_id = 18000
				LEFT JOIN static_data_value sdv10 ON sdv10.code = dd.category AND sdv10.type_id = 18100
				LEFT JOIN static_data_value sdv11 ON sdv11.code = dd.region AND sdv11.type_id = 11150
				LEFT JOIN source_commodity com ON com.commodity_id = dh.commodity				
				LEFT JOIN pratos_book_mapping pbm 
					ON ISNULL(pbm.counterparty_id, -1) = ISNULL(sc2.source_counterparty_id, -1) 
					AND ISNULL(pbm.country_id, -1) = ISNULL(sdv8.value_id, -1) 
					AND ISNULL(pbm.grid_id, -1) = ISNULL(sdv9.value_id, -1)
					AND ISNULL(pbm.category, -1) = ISNULL(sdv10.value_id, -1)				
					AND com.source_commodity_id <> -3
					AND pbm.region IS NULL
				LEFT JOIN pratos_book_mapping pbm1
					ON ISNULL(pbm1.region, -1) = ISNULL(sdv11.value_id, -1) 
					AND ISNULL(pbm1.country_id, -1) = ISNULL(sdv8.value_id, -1) 
					AND ISNULL(pbm1.grid_id, -1) = ISNULL(sdv9.value_id, -1)
					AND ISNULL(pbm1.category, -1) = ISNULL(sdv10.value_id, -1)	
					AND ISNULL(pbm1.counterparty_id, -1) = ISNULL(sc2.source_counterparty_id, -1) 
					AND com.source_commodity_id = -3		
				WHERE dd.source_deal_id = dh.source_deal_id AND dd.source_system_id = dh.source_system_id 
			) pbm
			
			INNER JOIN (
				SELECT dd.source_deal_id,
					MIN(t.term_start) min_term_start, 
					MAX(t.term_end) max_term_end,
					MAX(CASE WHEN fp.formula IS NOT NULL THEN 1603 ELSE NULL END) pricing
				FROM #deal_detail dd 
				LEFT JOIN #vol v 
					ON v.source_system_id = dd.source_system_id
					AND v.source_deal_id = dd.source_deal_id  
					AND v.leg = dd.leg  
				CROSS APPLY (
					SELECT term_start, term_end FROM dbo.FNATermBreakdown('m', dd.term_start, dd.term_end) fb	
				) t
				LEFT JOIN #formula_parsed fp 
					ON fp.source_system_id = dd.source_system_id
					AND fp.source_deal_id = dd.source_deal_id 
					AND ISNULL(fp.tariff,'Peak') = ISNULL(NULLIF(dd.tou_tariff,'Baseload'),'Peak')	
					AND CHARINDEX('CurveD(',fp.formula,0)>0
				GROUP BY dd.source_deal_id
					
			) sdd 
				ON dh.source_deal_id= sdd.source_deal_id	
						
		
				
			UPDATE uddf 
				SET udf_value = udf.value
			FROM #udf udf
			INNER JOIN #deal_header dh ON dh.source_deal_id = udf.source_deal_id AND dh.source_system_id = udf.source_system_id 
			INNER JOIN source_deal_header_template sdht ON sdht.template_name = dh.template 
			INNER JOIN static_data_value sdv ON sdv.code = udf.field AND TYPE_ID = 5500
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_name = sdv.value_id AND uddft.template_id = sdht.template_id
			INNER JOIN source_deal_header sdh ON sdh.deal_id = dh.source_deal_id_old AND sdh.source_system_id = udf.source_system_id 
			INNER JOIN user_defined_deal_fields uddf 
				ON uddf.source_deal_header_id = sdh.source_deal_header_id 
				AND uddf.udf_template_id = uddft.udf_template_id 


			UPDATE uddf 
			SET udf_value = dbo.FNARemoveTrailingZeroes(fu.[value])
			FROM #formula_udf fu
			INNER JOIN #deal_header dh ON dh.source_deal_id = fu.source_deal_id AND dh.source_system_id = fu.source_system_id 
			INNER JOIN source_deal_header sdh ON dh.source_deal_id_old = sdh.deal_id AND fu.source_system_id = sdh.source_system_id
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id AND uddft.field_name = fu.field
			INNER JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id 
				AND uddf.source_deal_header_id = sdh.source_deal_header_id



		--END 
		
				

		-- INSERT
		--IF NOT EXISTS (SELECT * FROM source_deal_header WHERE deal_id = @source_deal_id AND source_system_id = @source_system_id)
		--BEGIN
	
			--SET @insert_update_flag = 'i'
	

			
			
			INSERT INTO source_deal_header(
				source_system_id
				, physical_financial_flag	
				, entire_term_start
				, entire_term_end
				, deal_id
				, block_type
				, block_define_id
			--	, description
				, deal_date
				, counterparty_id
				, source_deal_type_id
				, deal_sub_type_type_id, option_flag
				, source_system_book_id1
				, source_system_book_id2
				, source_system_book_id3
				, source_system_book_id4
				, description1, description2, description3
				, deal_category_value_id
				, trader_id
				, header_buy_sell_flag
				, contract_id
				, legal_entity
				, template_id
				, deal_status
				, internal_desk_id 
				, product_id
				, close_reference_id
				, confirm_status_type
				, reference
				, deal_locked
				, internal_portfolio_id
				, pricing
				, commodity_id
			)
			OUTPUT INSERTED.source_deal_header_id, INSERTED.deal_id, 'i' INTO #affected_deals
			SELECT 
				@source_system_id
				, sdht.physical_financial_flag	
				, min_term_start
				, max_term_end
				, dh.source_deal_id_old
				, ISNULL(sdv1.value_id,sdht.block_type)	--, block_type
				, ISNULL(sdv2.value_id,sdht.block_define_id)
			--	, sdh.description
				,CONVERT(VARCHAR(10),dh.deal_date,102)
				, sc.source_counterparty_id	--, counterparty
				, sdt1.source_deal_type_id	--, deal_type
				, sdt2.source_deal_type_id	--, deal_sub_type
				, dh.option_flag
				, ISNULL(pbm.source_system_book_id1, -1)
				, ISNULL(pbm.source_system_book_id2, -2)
				, ISNULL(pbm.source_system_book_id3, -3)
				, ISNULL(pbm.source_system_book_id4, -4)
				, dh.description1
				, dh.description2
				, dh.description3
				, ISNULL(sdv3.value_id,475)	--, deal_category_id
				, st.source_trader_id	--, trader_name
				, LOWER(dh.header_buy_sell_flag)
				, cg.contract_id	--, framework
				, sle.source_legal_entity_id
				, sdht.template_id	--, template
				, ISNULL(sdv6.value_id,5604)	--, dh.deal_status

				, ISNULL(sdv4.value_id,17300)	--	, profile
				--, sdv5.value_id	--	, fixing
				, CASE 
					WHEN fixing IS NULL THEN 4101 -- Original
					ELSE 4100                     -- Price Fixation 
	              END				-- fixing
				, sdh1.source_deal_header_id	-- close_reference_id
				, sdv7.value_id	--	, confirm_status
				, reference_deal
				, 'y'
				, sip.source_internal_portfolio_id
				, sdd.pricing
				, sc2.source_commodity_id

			FROM #deal_header dh
			LEFT JOIN static_data_value sdv1 ON sdv1.code = dh.block_type AND sdv1.type_id = 12000
			LEFT JOIN static_data_value sdv2 ON sdv2.code = dh.block_description AND sdv2.type_id = 10018
			LEFT JOIN source_counterparty sc ON sc.counterparty_id = dh.parent_counterparty
			LEFT JOIN source_legal_entity sle ON sle.legal_entity_id = dh.legal_entity
			LEFT JOIN source_deal_type sdt1 ON sdt1.deal_type_id = dh.deal_type
			LEFT JOIN source_deal_type sdt2 ON sdt2.deal_type_id = dh.deal_sub_type
			
			LEFT JOIN static_data_value sdv3 
				ON sdv3.code = dh.deal_category_id 
				AND sdv3.type_id = 475
			LEFT JOIN source_traders st ON st.trader_id = dh.trader_name 
			LEFT JOIN contract_group cg ON cg.contract_name = dh.framework
			LEFT JOIN static_data_value sdv4 ON sdv4.code = dh.profile AND sdv4.type_id = 17300
			--LEFT JOIN static_data_value sdv5 ON sdv5.code = dh.fixing AND sdv5.type_id = 4100
			LEFT JOIN source_deal_header sdh1 ON sdh1.deal_id = dh.fixing AND sdh1.source_system_id = @source_system_id 
			LEFT JOIN source_deal_header_template sdht ON sdht.template_name = dh.template
			LEFT JOIN static_data_value sdv6 ON sdv6.code = dh.deal_status AND sdv6.type_id = 5600
			LEFT JOIN static_data_value sdv7 ON sdv7.code = dh.confirm_status AND sdv7.type_id = 17200

			OUTER APPLY (
				SELECT 
					  MAX(ISNULL(pbm.source_system_book_id1,pbm1.source_system_book_id1)) source_system_book_id1
					, MAX(ISNULL(pbm.source_system_book_id2,pbm1.source_system_book_id2)) source_system_book_id2
					, MAX(ISNULL(pbm.source_system_book_id3,pbm1.source_system_book_id3)) source_system_book_id3
					, MAX(ISNULL(pbm.source_system_book_id4,pbm1.source_system_book_id4)) source_system_book_id4
					, MAX(dd.buy_sell) buy_sell
				FROM #deal_detail dd 
					
				LEFT JOIN source_counterparty sc2 ON sc2.counterparty_id = dh.parent_counterparty
				LEFT JOIN static_data_value sdv8 ON sdv8.code = dd.country AND sdv8.type_id = 14000
				LEFT JOIN static_data_value sdv9 ON sdv9.code = dd.grid AND sdv9.type_id = 18000
				LEFT JOIN static_data_value sdv10 ON sdv10.code = dd.category AND sdv10.type_id = 18100
				LEFT JOIN static_data_value sdv11 ON sdv11.code = dd.region AND sdv11.type_id = 11150
				LEFT JOIN source_commodity com ON com.commodity_id = dh.commodity				
				LEFT JOIN pratos_book_mapping pbm 
					ON ISNULL(pbm.counterparty_id, -1) = ISNULL(sc2.source_counterparty_id, -1) 
					AND ISNULL(pbm.country_id, -1) = ISNULL(sdv8.value_id, -1) 
					AND ISNULL(pbm.grid_id, -1) = ISNULL(sdv9.value_id, -1)
					AND ISNULL(pbm.category, -1) = ISNULL(sdv10.value_id, -1)				
					AND com.source_commodity_id <> -3
					AND pbm.region IS NULL
				LEFT JOIN pratos_book_mapping pbm1
					ON ISNULL(pbm1.region, -1) = ISNULL(sdv11.value_id, -1) 
					AND ISNULL(pbm1.country_id, -1) = ISNULL(sdv8.value_id, -1) 
					AND ISNULL(pbm1.grid_id, -1) = ISNULL(sdv9.value_id, -1)
					AND ISNULL(pbm1.category, -1) = ISNULL(sdv10.value_id, -1)
					AND ISNULL(pbm1.counterparty_id, -1) = ISNULL(sc2.source_counterparty_id, -1) 	
					AND com.source_commodity_id = -3		
					
				WHERE dd.source_deal_id = dh.source_deal_id AND dd.source_system_id = dh.source_system_id 
			) pbm

			INNER JOIN (
				SELECT dd.source_deal_id,
					MIN(t.term_start) min_term_start, 
					MAX(t.term_end) max_term_end, 
					MAX(CASE WHEN fp.formula IS NOT NULL THEN 1603 ELSE NULL END) pricing
				FROM #deal_detail dd 
				LEFT JOIN #vol v 
					ON v.source_system_id = dd.source_system_id
					AND v.source_deal_id = dd.source_deal_id  
					AND v.leg = dd.leg  
				CROSS APPLY (
					SELECT term_start, term_end FROM dbo.FNATermBreakdown('m', dd.term_start, dd.term_end) fb	
				) t						
				LEFT JOIN #formula_parsed fp 
				ON fp.source_system_id = dd.source_system_id
					AND fp.source_deal_id = dd.source_deal_id 
					AND ISNULL(fp.tariff,'Peak') = ISNULL(NULLIF(dd.tou_tariff,'Baseload'),'Peak')	
					AND CHARINDEX('CurveD(',fp.formula,0)>0			
				GROUP BY dd.source_deal_id
					
			) sdd 
			ON dh.source_deal_id= sdd.source_deal_id	
			LEFT JOIN source_deal_header sdh ON sdh.source_system_id = dh.source_system_id AND sdh.deal_id = dh.source_deal_id_old 
			LEFT JOIN source_internal_portfolio sip ON sip.internal_portfolio_id = dh.product
			LEFT JOIN source_commodity sc2 ON sc2.commodity_id = dh.commodity AND sc2.source_system_id = @source_system_id
			WHERE sdh.source_deal_header_id IS NULL 
				AND dh.deal_status <> 'delete'
			
			EXEC spa_print 'BEGIN deal detail table process'


			DECLARE @profile_swap VARCHAR(100)
			SET @profile_swap='Swap Profile/Profile Swap'
			---######### Breakdown deal detail to monthly term
			SELECT 
				 dd.source_system_id
				, sdh.source_deal_header_id 
				, term_brk.term_start
				, term_brk.term_end
				, ROW_NUMBER() OVER (PARTITION BY sdh.source_deal_header_id,term_brk.term_start ORDER BY CAST(dd.leg AS INT), sdh.source_deal_header_id, term_brk.term_start, dd.location, COALESCE(spcm.curve_id,pspcm1.curve_id,pspcm2.curve_id)) AS leg
				, term_brk.term_end expiration_date
				, dd.fixed_float_leg
				, dh.header_buy_sell_flag buy_sell
				, COALESCE(spcm.curve_id,pspcm1.curve_id,pspcm2.curve_id) curve_id
				, dd.fixed_price
				, dd.deal_volume
				, volume_frequency
				, su.source_uom_id	--, volume_uom
				, dd.physical_financial_flag
				, CASE WHEN dd.physical_financial_flag = 'p' THEN sml.source_minor_location_id ELSE NULL END AS location_id	--, location
				, dd.capacity
				, dd.fixed_cost
				--, sc1.source_currency_id AS fixed_cost_currency_id	--	, fixed_cost_currency
				, NULL fixed_cost_currency_id
				, sc2.source_currency_id AS formula_currency_id	--	, formula_currency
				, sc3.source_currency_id AS adder_currency_id	--	, adder_currency
				, COALESCE(sc4.source_currency_id,sc2.source_currency_id) AS price_currency_id	--	, price_currency
				--, ISNULL(smlm.meter_id,mtr.meter_id)meter_id	--, meter
				, gmm.meter_id
				, syv
				, fe.formula_id
				, 'y' AS pay_opposite
				, sdv.value_id category
				, ABS(dd.volume_multiplier) multiplier
				, sdh.product_id
				, dd.tou_tariff
				, su2.source_uom_id [price_uom_id]	--dd.price_uom
				, sdv1.value_id [pv_party]
				, sdv_region.value_id region
				, dd.forecast_needed
			INTO
				 #deal_detail_breakdown	
			FROM 
				#deal_detail dd
			INNER JOIN #deal_header dh ON dh.source_deal_id = dd.source_deal_id AND dh.source_system_id = dd.source_system_id
			LEFT JOIN #formula_parsed fp 
				ON fp.source_system_id = dd.source_system_id
				AND fp.source_deal_id = dd.source_deal_id 
				AND ISNULL(fp.tariff,'Peak') = ISNULL(NULLIF(dd.tou_tariff,'Baseload'),'Peak')
			LEFT JOIN (SELECT formula,MIN(formula_id) formula_id FROM formula_editor GROUP BY formula) fe ON fe.formula = fp.formula 
			LEFT JOIN source_price_curve_def spcd ON spcd.curve_id = dd.source_curve
			LEFT JOIN source_uom su ON su.uom_id = dd.volume_uom
			LEFT JOIN source_uom su2 ON su2.uom_id = dd.price_uom
			LEFT JOIN source_minor_location sml ON sml.location_name = dh.source_deal_id_old+'_'+dd.location
			LEFT JOIN source_currency sc1 ON sc1.currency_id = dd.fixed_cost_currency
			LEFT JOIN source_currency sc2 ON sc2.currency_id = dd.formula_currency
			LEFT JOIN source_currency sc3 ON sc3.currency_id = dd.adder_currency
			LEFT JOIN source_currency sc4 ON sc4.currency_id = dd.price_currency
			LEFT JOIN static_data_value sdv ON sdv.code = dd.category AND sdv.type_id = 18100 -- category
			--LEFT JOIN meter_id mtr ON mtr.recorderid = dd.meter
			LEFT JOIN static_data_value sdv2 ON sdv2.code = dd.region AND sdv2.type_id = 11150
			LEFT JOIN static_data_value sdv3 ON sdv3.code = dd.grid AND sdv3.type_id = 18000	
			LEFT JOIN static_data_value sdv_region ON sdv_region.code = dd.region AND sdv_region.type_id = 11150	
			LEFT JOIN static_data_value sdv_country ON sdv_country.code = dd.country AND sdv_country.type_id = 14000	
			LEFT JOIN source_major_location smaj ON smaj.location_name = dd.location_group 
			LEFT JOIN source_commodity com ON com.commodity_id = dh.commodity
			LEFT JOIN pratos_source_price_curve_map spcm 
				ON 	ISNULL(spcm.location_group_id, '') = ISNULL(smaj.source_major_location_id,'') 
				AND ISNULL(spcm.grid_value_id, -1) = ISNULL(sdv3.value_id, -1) 
				AND ISNULL(spcm.region, -1) = ISNULL(sdv2.value_id, -1) 
				AND ISNULL(spcm.block_type, '') = ISNULL(dd.tou_tariff,'') 
				AND NULLIF(spcm.location_group_id,'') IS NOT NULL
				AND com.source_commodity_id <> -3
				AND spcm.category_id IS NULL
				AND spcm.country_id IS NULL
			LEFT JOIN pratos_source_price_curve_map pspcm1
				ON 	ISNULL(pspcm1.grid_value_id, -1) = ISNULL(sdv3.value_id, -1) 
				AND ISNULL(pspcm1.region, -1) = ISNULL(sdv2.value_id, -1) 
				AND ISNULL(pspcm1.block_type, '') = ISNULL(dd.tou_tariff,'') 
				AND NULLIF(pspcm1.location_group_id,'') IS NULL		
				AND com.source_commodity_id <> -3
				AND pspcm1.category_id IS NULL
				AND pspcm1.country_id IS NULL
			LEFT JOIN pratos_source_price_curve_map pspcm2
				ON ISNULL(pspcm2.grid_value_id, -1) = ISNULL(sdv3.value_id, -1) 
				AND ISNULL(pspcm2.region, -1) = ISNULL(sdv2.value_id, -1) 
				AND ISNULL(pspcm2.category_id, -1) = ISNULL(sdv.value_id, -1)
				AND NULLIF(pspcm2.country_id,-1) = ISNULL(sdv_country.value_id, -1)
				AND com.source_commodity_id = -3 -- JOIN for 'Sustainable Commodity'	
							
			LEFT JOIN static_data_value sdv1 ON sdv1.type_id=18300 AND sdv1.code ='RWEST NL BV' AND dd.physical_financial_flag='p'
			LEFT JOIN source_counterparty sc ON sc.counterparty_id = dh.parent_counterparty  
			INNER JOIN #udf udf ON dd.source_deal_id = udf.source_deal_id
				AND dd.source_system_id = udf.source_system_id
				AND udf.field = 'IsProfiled'				
			LEFT JOIN group_meter_mapping gmm ON gmm.counterparty_id=sc.source_counterparty_id
				AND gmm.region_id=sdv2.value_id
				AND gmm.category_id=sdv.value_id
				AND gmm.grid_id=sdv3.value_id
				AND dh.[product]=@profile_swap
				AND udf.value ='Y'
			INNER JOIN source_deal_header sdh ON sdh.deal_id = dh.source_deal_id_old AND sdh.source_system_id = dd.source_system_id 
			CROSS APPLY
				(
					SELECT term_start,term_end FROM dbo.FNATermBreakdown('m',dd.term_start,dd.term_end)
				)	term_brk
				

				
			--####### find the deals whose volume/syv has changed to trigger forecast	
			INSERT INTO	#forecast_trigger_deals
			SELECT 
				DISTINCT dh.source_deal_id
			FROM
				#deal_detail_breakdown dd
				LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = dd.source_deal_header_id
				LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
					AND dd.leg = sdd.Leg
					AND dd.curve_id =sdd.curve_id
					AND dd.term_start = sdd.term_start
				LEFT JOIN #deal_header dh ON dh.source_deal_id_old = sdh.deal_id
				LEFT JOIN #forecast_trigger_deals ftd ON ftd.source_deal_id = dh.source_deal_id
			WHERE
				ftd.source_deal_id IS NULL
				AND dd.physical_financial_flag = 'p' 
				AND (ISNULL(sdd.capacity,0) <> ISNULL(dd.capacity,0) OR
					 ISNULL(sdd.deal_volume,0) <> ISNULL(dd.deal_volume,0) OR 
					 ISNULL(sdd.term_start,'') <> ISNULL(dd.term_start,'') OR
					 ISNULL(sdd.location_id,'') <> ISNULL(dd.location_id,'') OR
					 ISNULL(sdd.physical_financial_flag,'') <> ISNULL(dd.physical_financial_flag,'') 
				 )	
				 

		
			DELETE
				sdd
			FROM 
				source_deal_detail sdd
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id =sdd.source_deal_header_id
				INNER JOIN #deal_header dh ON dh.source_system_id = sdh.source_system_id AND dh.source_deal_id_old = sdh.deal_id 
				LEFT JOIN #deal_detail_breakdown dd
				ON sdd.source_deal_header_id = dd.source_deal_header_id
					AND sdd.term_start = dd.term_start
					AND sdd.term_end = dd.term_end
					AND ISNULL(sdd.location_id,-1) = ISNULL(dd.location_id,-1)
					AND ISNULL(sdd.curve_id,-1) = ISNULL(dd.curve_id,-1)
				--AND sdd.leg = dd.leg
			WHERE dd.source_deal_header_id IS NULL 		
				
				
			-- Update deals
			UPDATE sdd
			SET 
				term_start = dd.term_start
				, term_end = dd.term_end
				, leg = dd.leg
				, contract_expiration_date = dd.expiration_date
				, fixed_float_leg = dd.fixed_float_leg
				, buy_sell_flag = dd.buy_sell
				, curve_id = dd.curve_id
				, fixed_price = dd.fixed_price
				, deal_volume = dd.deal_volume
				, deal_volume_frequency = LOWER(dd.volume_frequency)
				, deal_volume_uom_id = dd.source_uom_id	--, volume_uom
				, physical_financial_flag = dd.physical_financial_flag
				, location_id =dd.location_id	--, location
				, capacity = dd.capacity
				, fixed_cost = dd.fixed_cost
				, fixed_cost_currency_id = dd.fixed_cost_currency_id	--	, fixed_cost_currency
				, formula_currency_id = dd.formula_currency_id	--	, formula_currency
				, adder_currency_id = dd.adder_currency_id	--	, adder_currency
				, fixed_price_currency_id = dd.price_currency_id	--	, price_currency
				, meter_id = dd.meter_id	--, meter
				, standard_yearly_volume = dd.syv
				, formula_id = dd.formula_id
				, pay_opposite = dd.pay_opposite
				, category = dd.category 
				, multiplier = dd.multiplier
				, price_uom_id = dd.price_uom_id	--, volume_uom
				, pv_party =dd.[pv_party]
				, profile_code = dd.region
			FROM source_deal_detail sdd 
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id 
			INNER JOIN #deal_detail_breakdown dd 
				ON 
				dd.source_deal_header_id = sdh.source_deal_header_id 
				--AND dd.leg = sdd.leg
				AND dd.term_start = sdd.term_start
				AND dd.term_end = sdd.term_end 
				AND ISNULL(dd.location_id,-1) = ISNULL(sdd.location_id,-1)
				AND ISNULL(dd.curve_id,-1) = ISNULL(sdd.curve_id,-1)
			WHERE
				dd.product_id <> 4100


			UPDATE sdd
			SET 
				term_start = dd.term_start
				, term_end = dd.term_end
				, leg = dd.leg
				, contract_expiration_date = dd.expiration_date
				, fixed_float_leg = dd.fixed_float_leg
				, buy_sell_flag = dd.buy_sell
				, curve_id = dd.curve_id
				, fixed_price = dd.fixed_price
				, deal_volume = dd.deal_volume
				, deal_volume_frequency = LOWER(dd.volume_frequency)
				, deal_volume_uom_id = dd.source_uom_id	--, volume_uom
				, physical_financial_flag = dd.physical_financial_flag
				, location_id =dd.location_id	--, location
				, capacity = dd.capacity
				, fixed_cost = dd.fixed_cost
				, fixed_cost_currency_id = dd.fixed_cost_currency_id	--	, fixed_cost_currency
				, formula_currency_id = dd.formula_currency_id	--	, formula_currency
				, adder_currency_id = dd.adder_currency_id	--	, adder_currency
				, fixed_price_currency_id = dd.price_currency_id	--	, price_currency
				, meter_id = dd.meter_id	--, meter
				, standard_yearly_volume = dd.syv
				, formula_id = dd.formula_id
				, pay_opposite = dd.pay_opposite
				, category = dd.category 
				, multiplier = dd.multiplier
				, price_uom_id = dd.price_uom_id
				, pv_party =dd.[pv_party]
				, sdd.profile_code=dd.region

			FROM source_deal_detail sdd 
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id 
			INNER JOIN 
			(SELECT 
					dd.source_deal_header_id 
					, dd.term_start
					, dd.term_end
					, MIN(dd.leg) leg
					, MIN(dd.expiration_date)expiration_date
					, MIN(dd.fixed_float_leg)fixed_float_leg
					, MIN(dd.buy_sell)buy_sell
					, (dd.curve_id)curve_id
					, MIN(dd.fixed_price)fixed_price
					, SUM(dd.deal_volume)deal_volume
					, MIN(LOWER(dd.volume_frequency))volume_frequency
					, MIN(dd.source_uom_id)source_uom_id				
					, MIN(dd.physical_financial_flag)physical_financial_flag
					, MIN(dd.location_id)location_id
					, MIN(dd.capacity)capacity
					, MIN(dd.fixed_cost)fixed_cost
					, MIN(dd.fixed_cost_currency_id)fixed_cost_currency_id	
					, MIN(dd.formula_currency_id)formula_currency_id		
					, MIN(dd.adder_currency_id) adder_currency_id		
					, MIN(dd.price_currency_id)	price_currency_id		
					, MIN(dd.meter_id)	meter_id				
					, MIN(dd.syv)syv
					, MIN(dd.formula_id)formula_id
					, MIN(dd.pay_opposite)pay_opposite
					, MIN(dd.category)category
					, MIN(dd.multiplier)multiplier
					, MIN(dd.price_uom_id) price_uom_id
					, MIN(pv_party) pv_party
					, MIN(region) region
				FROM 
					#deal_detail_breakdown  dd
				WHERE dd.product_id = 4100
				GROUP BY dd.source_deal_header_id, dd.term_start, dd.term_end, dd.curve_id
			) dd	
				ON 
				dd.source_deal_header_id = sdh.source_deal_header_id 
				AND dd.leg = sdd.leg
				AND dd.term_start = sdd.term_start
				AND dd.term_end = sdd.term_end 			
		
		

				
			INSERT INTO source_deal_detail (
				source_deal_header_id
				, term_start
				, term_end
				, leg
				, contract_expiration_date
				, fixed_float_leg
				, buy_sell_flag
				, curve_id
				, fixed_price
				, deal_volume
				, deal_volume_frequency
				, deal_volume_uom_id
				, physical_financial_flag
				, location_id
				, capacity, fixed_cost
				, fixed_cost_currency_id
				, formula_currency_id
				, adder_currency_id
				, fixed_price_currency_id
				, meter_id
				, standard_yearly_volume
				, formula_id
				, pay_opposite
				, category
				, multiplier
				, price_uom_id
				, [pv_party]
				, profile_code			
			)
			SELECT 
				 dd.source_deal_header_id 
				, dd.term_start
				, dd.term_end
				, dd.leg 
				, dd.expiration_date
				, dd.fixed_float_leg
				, dd.buy_sell
				, dd.curve_id
				, dd.fixed_price
				, dd.deal_volume
				, LOWER(dd.volume_frequency)
				, dd.source_uom_id	--, volume_uom
				, dd.physical_financial_flag
				, dd.location_id
				, dd.capacity
				, dd.fixed_cost
				, dd.fixed_cost_currency_id	--	, fixed_cost_currency
				, dd.formula_currency_id	--	, formula_currency
				, dd.adder_currency_id 	--	, adder_currency
				, dd.price_currency_id	--	, price_currency
				, dd.meter_id	--, meter
				, dd.syv
				, dd.formula_id
				, dd.pay_opposite
				, dd.category
				, dd.multiplier
				, dd.price_uom_id
				, dd.[pv_party]
				, dd.region
			FROM #deal_detail_breakdown dd
			LEFT JOIN source_deal_detail sdd 
				ON sdd.source_deal_header_id = dd.source_deal_header_id
				AND sdd.term_start = dd.term_start
				AND sdd.term_end = dd.term_end
				--AND sdd.leg = dd.leg
				AND ISNULL(dd.location_id,-1) = ISNULL(sdd.location_id,-1)
				AND ISNULL(dd.curve_id,-1) = ISNULL(sdd.curve_id,-1)
			WHERE sdd.source_deal_detail_id IS NULL 
				AND dd.product_id <> 4100 -- Original : No aggregation

			
			INSERT INTO source_deal_detail (
				source_deal_header_id
				, term_start
				, term_end
				, leg
				, contract_expiration_date
				, fixed_float_leg
				, buy_sell_flag
				, curve_id
				, fixed_price
				, deal_volume
				, deal_volume_frequency
				, deal_volume_uom_id
				, physical_financial_flag
				, location_id
				, capacity, fixed_cost
				, fixed_cost_currency_id
				, formula_currency_id
				, adder_currency_id
				, fixed_price_currency_id
				, meter_id
				, standard_yearly_volume
				, formula_id
				, pay_opposite
				, category
				, multiplier
				, price_uom_id
				, [pv_party]				
				, profile_code
			)
			SELECT 
				 dd.source_deal_header_id 
				, dd.term_start
				, dd.term_end
				, MIN(dd.leg) 
				, MIN(dd.expiration_date)
				, MIN(dd.fixed_float_leg)
				, MIN(dd.buy_sell)
				, MIN(dd.curve_id)
				, MIN(dd.fixed_price)
				, SUM(dd.deal_volume)
				, MIN(LOWER(dd.volume_frequency))
				, MIN(dd.source_uom_id)				--, volume_uom
				, MIN(dd.physical_financial_flag)
				, MIN(dd.location_id)
				, MIN(dd.capacity)
				, MIN(dd.fixed_cost)
				, MIN(dd.fixed_cost_currency_id)	--	, fixed_cost_currency
				, MIN(dd.formula_currency_id)		--	, formula_currency
				, MIN(dd.adder_currency_id) 		--	, adder_currency
				, MIN(dd.price_currency_id)			--	, price_currency
				, MIN(dd.meter_id)					--	, meter
				, MIN(dd.syv)
				, MIN(dd.formula_id)
				, MIN(dd.pay_opposite)
				, MIN(dd.category)
				, MIN(dd.multiplier)
				, MIN(dd.price_uom_id)
				, MIN(dd.[pv_party]) [pv_party]
				, MIN(dd.region) region
			FROM #deal_detail_breakdown dd
			LEFT JOIN source_deal_detail sdd 
				ON sdd.source_deal_header_id = dd.source_deal_header_id
				AND sdd.term_start = dd.term_start
				AND sdd.term_end = dd.term_end
				--AND sdd.leg = dd.leg
			WHERE sdd.source_deal_detail_id IS NULL 
				AND dd.product_id = 4100 -- Fixation : Aggregate by term and tou_tariff for fixation deals
			GROUP BY dd.source_deal_header_id, dd.term_start, dd.term_end, dd.tou_tariff 

			EXEC spa_print 'Finish deal detail table process'			
		
				  
	
			---- UPDATE FIXATIOn ID of fixed deals
			UPDATE sdh	
				SET sdh.close_reference_id = sdh1.source_deal_header_id 
			FROM source_deal_header sdh 
				INNER JOIN #deal_header dh ON dh.source_system_id = sdh.source_system_id AND dh.source_deal_id_old = sdh.deal_id 
				INNER JOIN source_deal_header sdh1 ON sdh1.deal_id = dh.fixing AND sdh1.source_system_id = @source_system_id
			WHERE
				dh.fixing IS NOT NULL	
			
			UPDATE uddf
				SET udf_value = counterparty 
			FROM #deal_header dh
			INNER JOIN source_deal_header sdh 
				ON sdh.deal_id = dh.source_deal_id_old 
				AND sdh.source_system_id = dh.source_system_id 
			INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
			INNER JOIN static_data_value sdv ON sdv.code = 'Customer'
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_name = sdv.value_id AND uddft.template_id = sdht.template_id
			INNER JOIN user_defined_deal_fields uddf
				ON uddf.source_deal_header_id = sdh.source_deal_header_id 
				AND uddf.udf_template_id = uddft.udf_template_id
				
			
			INSERT INTO user_defined_deal_fields
			(
				source_deal_header_id,
				udf_template_id,
				udf_value
			)
			SELECT sdh.source_deal_header_id, uddft.udf_template_id, counterparty 
			FROM #deal_header dh
			INNER JOIN source_deal_header sdh 
				ON sdh.deal_id = dh.source_deal_id_old 
				AND sdh.source_system_id = dh.source_system_id 
			INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
			INNER JOIN static_data_value sdv ON sdv.code = 'Customer'
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_name = sdv.value_id AND uddft.template_id = sdht.template_id
			LEFT JOIN user_defined_deal_fields uddf
				ON uddf.source_deal_header_id = sdh.source_deal_header_id 
				AND uddf.udf_template_id = uddft.udf_template_id
			WHERE uddf.udf_template_id IS NULL 
			
			
				
			INSERT INTO user_defined_deal_fields (source_deal_header_id,udf_template_id,udf_value)
			SELECT DISTINCT sdh.source_deal_header_id, uddft.udf_template_id, dbo.FNARemoveTrailingZeroes(MIN(fu.[value])) 
			FROM #formula_udf fu
			INNER JOIN #deal_header dh ON dh.source_deal_id = fu.source_deal_id AND dh.source_system_id = fu.source_system_id
			INNER JOIN source_deal_header sdh ON sdh.deal_id = dh.source_deal_id_old AND sdh.source_system_id = fu.source_system_id
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id AND uddft.field_name = fu.field
			LEFT JOIN user_defined_deal_fields uddf 
				ON uddf.source_deal_header_id = sdh.source_deal_header_id
				AND uddf.udf_template_id = uddft.udf_template_id 
			WHERE uddf.udf_template_id IS NULL 
			GROUP BY sdh.source_deal_header_id, uddft.udf_template_id 


			INSERT INTO user_defined_deal_fields (source_deal_header_id,udf_template_id,udf_value)
			SELECT sdh.source_deal_header_id,uddft.udf_template_id, udf.value
			FROM #udf udf
			INNER JOIN #deal_header dh ON dh.source_deal_id = udf.source_deal_id AND dh.source_system_id = udf.source_system_id 
			INNER JOIN source_deal_header_template sdht ON sdht.template_name = dh.template 
			INNER JOIN static_data_value sdv ON sdv.code = udf.field AND TYPE_ID = 5500
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_name = sdv.value_id AND uddft.template_id = sdht.template_id
			INNER JOIN source_deal_header sdh ON sdh.deal_id = dh.source_deal_id_old AND sdh.source_system_id = udf.source_system_id
			LEFT JOIN user_defined_deal_fields uddf 
				ON uddf.udf_template_id = uddft.udf_template_id 
				AND uddf.source_deal_header_id = sdh.source_deal_header_id
			WHERE uddf.udf_template_id IS NULL
			
			
		--END 

		-- DELETE FROM user_defined_deal_fields if the template is changed
		DELETE uddf
		FROM
			#deal_header dh
			INNER JOIN source_deal_header sdh ON sdh.deal_id = dh.source_deal_id_old 
			INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN user_defined_deal_fields_template uddfp on uddfp.udf_template_id=uddf.udf_template_id
			LEFT JOIN source_deal_header sdh1 on sdh1.source_deal_header_id = uddf.source_deal_header_id
					AND sdh1.template_id = uddfp.template_id
		WHERE
			  sdh1.source_deal_header_id is null


		----------------------------
		-- Update Confirm Status
		
		INSERT confirm_status (
			source_deal_header_id,
			TYPE,
			as_of_date,  
			comment1, 
			comment2,  
			confirm_id 
		)
		SELECT 
			source_deal_header_id, 
			sdh.confirm_status_type,
			@start_date, 
			NULL, 
			NULL, 
			NULL 
		FROM source_deal_header sdh
		INNER JOIN #deal_header dh 
			ON dh.source_deal_id_old = sdh.deal_id AND dh.source_system_id = sdh.source_system_id 
			

		UPDATE csr 
		SET comment1 = '',
			comment2 = '',
			confirm_id = '',				
			as_of_date = @start_date,
			TYPE = sdh.confirm_status_type 
		FROM confirm_status_recent csr
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = csr.source_deal_header_id
		INNER JOIN #deal_header dh ON dh.source_deal_id_old = sdh.deal_id AND dh.source_system_id = sdh.source_system_id 


		INSERT confirm_status_recent(
			source_deal_header_id,
			TYPE,
			as_of_date,  
			comment1, 
			comment2,  
			confirm_id 
		)
		SELECT 
			sdh.source_deal_header_id, 
			sdh.confirm_status_type,
			@start_date, 
			NULL,
			NULL,
			NULL 
		FROM source_deal_header sdh
		INNER JOIN #deal_header dh 
			ON dh.source_deal_id_old = sdh.deal_id AND dh.source_system_id = sdh.source_system_id 
		LEFT JOIN confirm_status_recent csr 
			ON csr.source_deal_header_id = sdh.source_deal_header_id 
		WHERE csr.source_deal_header_id IS NULL 
			
		
		
		--##### DELETE from staging table which are successfully processed
		DELETE t FROM pratos_stage_deal_header t (nolock) 
			INNER JOIN #deal_header d ON d.source_deal_id_old = t.source_deal_id_old 
		
		DELETE t FROM pratos_stage_deal_detail t 
			LEFT JOIN pratos_stage_deal_header psdh (nolock) ON psdh.source_deal_id = t.source_deal_id AND psdh.source_system_id = t.source_system_id 
		WHERE
			psdh.source_deal_id IS NULL
			
		DELETE t FROM pratos_stage_udf t 
		LEFT JOIN pratos_stage_deal_header psdh (nolock) ON psdh.source_deal_id = t.source_deal_id AND psdh.source_system_id = t.source_system_id 
		WHERE
			psdh.source_deal_id IS NULL
		
		DELETE t FROM pratos_stage_formula t 
		LEFT JOIN pratos_stage_deal_header psdh (nolock) ON psdh.source_deal_id = t.source_deal_id AND psdh.source_system_id = t.source_system_id 
		WHERE
			psdh.source_deal_id IS NULL
			
		
		DELETE t FROM pratos_stage_vol t 
		LEFT JOIN pratos_stage_deal_header psdh (nolock) ON psdh.source_deal_id = t.source_deal_id AND psdh.source_system_id = t.source_system_id 
		WHERE
			psdh.source_deal_id IS NULL


		
		-- Generate Nominator request string 
	DECLARE @max_request_id INT 
	SELECT @max_request_id = ISNULL(MAX(request_id),0) FROM import_data_request_status_log 
	SET @end_date = GETDATE()
	
		
		SELECT DISTINCT 
			@process_id process_id,
			4035 module_type,
			@process_id + '_' + REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20),GETDATE(),20),'-',''),':',''),' ','') + '.txt' request_file_name,
			NULL [request_time],
			COALESCE(fp.external_id,fp1.external_id,'') + ';' +		-- SiteID
				
				CONVERT(VARCHAR(20),entire_term_start,103) + ' ' + 
				CASE 
					WHEN spcd.commodity_id=-1 THEN '06:00'	-- Gas
					WHEN spcd.commodity_id=-2 THEN '00:00'	-- Power
					ELSE ''
				END	+ ';' + --'1/1/2011 00:00:00' + ';' +	--cast(entire_term_start as varchar) + ';' +	-- Start Date
				CONVERT(VARCHAR(20),DATEADD(d,1,entire_term_end),103) + ' ' + 
				CASE 
					WHEN spcd.commodity_id=-1 THEN '06:00'	-- Gas
					WHEN spcd.commodity_id=-2 THEN '00:00'	-- Power
					ELSE ''
				END	+ ';' +		--cast(entire_term_end as varchar) + ';' +	-- End Date
				COALESCE(udf.Customer, '') + ';' +	-- Site Name
				'F' + ';' +		-- FI
				CASE sdh.header_buy_sell_flag WHEN 's' THEN '0' ELSE '1' END + ';' +		-- Generator : Sell:0, Buy:1
				'1' + ';' +		-- SU
				CAST(COALESCE(dd.province,'') AS VARCHAR) + ';' + 				-- Subregion				
				'1' + ';' +		-- MPAN Count
				';' +			-- Interrupt Notice
				';' +			-- Interrupt Count
				';' +			-- Allowed Interrupts
				CAST(COALESCE(dbo.FNARemoveTrailingZero(sdd.standard_yearly_volume),'') AS VARCHAR(50))	+ ';' + -- Annual Consumption (AC)
				--CAST(COALESCE(sdd.standard_yearly_volume,'') AS VARCHAR(50))	+ ';' + -- Annual Consumption (AC)
				COALESCE(CAST(dbo.FNARemoveTrailingZero(sdd.capacity) AS VARCHAR),'') +	';' +		-- MEC 				
				CAST(COALESCE(dd.profile_code,'') AS VARCHAR) + ';' + 		-- SICC
				'NA' + ';' + 			-- Loss Band
				CAST(COALESCE(dd.forecasting_group,'') AS VARCHAR) + ';' +				-- Group 
				COALESCE(fp.external_id,fp1.external_id,'') + ';' +		-- Group Code
				CASE 
					WHEN is_profile='y' THEN '0'
					ELSE '1'
				END	-- + ';' +	-- IsIndustrial
		--		''					-- Tariff
				request_string,
			NULL response_time,
			NULL response_file_name,
			NULL response_status,
			LOWER(dh.commodity) + ',' + LOWER(dh.header_buy_sell_flag) [description],
			ISNULL(fp.profile_id,fp1.profile_id) key_value,
			@end_date [as_of_date],
			NULL data_file_name,
			NULL data_update_time,
			NULL data_update_status,
			sml.source_minor_location_id location_id,
			sdh.source_deal_header_id,
			LOWER(dh.commodity) commodity_name 
		INTO
			#temp_forecast_request	
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
		LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
		LEFT OUTER JOIN forecast_profile fp ON fp.profile_id = sml.profile_id
		LEFT OUTER JOIN forecast_profile fp1 ON fp1.profile_id = sml.proxy_profile_id
		LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
		
		OUTER APPLY (
			SELECT source_deal_header_id, Exit_Point_EAN, Postal_Code, is_profile, Delivery_Type, Standard_Profile, Customer FROM 
			(
				SELECT 
					uddf.source_deal_header_id, sdv.code, uddf.udf_value
				FROM user_defined_deal_fields uddf 
				INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = uddf.udf_template_id 
				INNER JOIN static_data_value sdv ON sdv.value_id = uddft.field_name
				WHERE source_deal_header_id = sdh.source_deal_header_id 
			) u
			PIVOT
			(
				MAX(udf_value) FOR code IN (Exit_Point_EAN, Postal_Code, is_profile, Delivery_Type, Standard_Profile, Customer)
			) upvt
			
		) udf 
		
		INNER JOIN #deal_header dh 
			ON dh.source_deal_id_old = sdh.deal_id 
			AND dh.source_system_id = sdh.source_system_id 
			AND dh.deal_status NOT IN('delete','Cancelled')
		INNER JOIN #deal_detail dd 
			ON dd.source_system_id = dh.source_system_id 
			AND dd.source_deal_id = dh.source_deal_id 
			AND dd.leg = sdd.Leg 
			AND dd.forecast_needed ='y'
			AND dd.physical_financial_flag = 'p'
		INNER JOIN #forecast_trigger_deals	ftd ON ftd.source_deal_id = dh.source_deal_id 
		
	INSERT INTO import_data_request_status_log (
		[request_id],
		process_id,module_type,request_file_name,request_time,request_string,response_time,response_file_name,response_status,description,key_value,as_of_date,data_file_name,data_update_time,data_update_status
	)
	SELECT ROW_NUMBER() OVER (ORDER BY @process_id) + @max_request_id [request_id], 
		process_id,module_type,request_file_name,request_time,request_string,response_time,response_file_name,response_status,description,key_value,as_of_date,data_file_name,data_update_time,data_update_status
	FROM
	(
		SELECT DISTINCT process_id,module_type,request_file_name,request_time,request_string,response_time,response_file_name,response_status,description,key_value,as_of_date,data_file_name,data_update_time,data_update_status
		FROM #temp_forecast_request
	) a		
	---------------------------------------------------------------------------------------------------
	
	INSERT INTO pratos_nominator_request_log(source_deal_header_id,location_id ,profile_id,[file_name],create_ts)
	SELECT 
		DISTINCT 
			source_deal_header_id,
			location_id ,
			key_value,
			commodity_name+'_'+@process_id+'.txt' [file_name],
			GETDATE()
	FROM
		#temp_forecast_request

	END 

	COMMIT

		---------------------------------------------------------------------------------------------------
 ------------------- Diable Position calculation and audit log temporarily
	IF EXISTS (SELECT 1 FROM #deal_header) --AND @bulk_import ='n'
	BEGIN
		
		DECLARE @report_position_deals VARCHAR(300)
		SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@process_id)


		EXEC ('IF OBJECT_ID(''' + @report_position_deals + ''',''U'') IS NOT NULL 
			DROP TABLE ' + @report_position_deals + ' 
			
			CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')  
		
		SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id, [action])
			SELECT source_deal_header_id, action FROM #affected_deals WHERE action IN (''i'', ''u'')'
		EXEC (@sql)




		DECLARE @spa VARCHAR(8000)
		DECLARE @job_name VARCHAR(100)

		
		IF EXISTS (SELECT 1 FROM #affected_deals)
		BEGIN
			--SET @spa = 'spa_update_deal_total_volume NULL,''' + CAST(@process_id AS VARCHAR(50)) + ''''
			SET @spa = 'spa_calc_deal_position_breakdown NULL,''' + CAST(@process_id AS VARCHAR(50)) + ''''
			SET @job_name = 'calc_position_' + @process_id 
			EXEC spa_run_sp_as_job @job_name, @spa, 'spa_calc_deal_position_breakdown', @user_login_id 
		END

		UPDATE sdh
		SET sdh.confirm_status_type = 17200
		FROM   source_deal_header sdh
		       INNER JOIN #affected_deals dd ON  dd.source_deal_header_id = sdh.source_deal_header_id
		
		UPDATE sdd
		SET    price_multiplier = CASE WHEN sdd.price_multiplier IS NULL THEN 1 ELSE sdd.price_multiplier END,
		       sdd.volume_multiplier2 = CASE WHEN sdd.volume_multiplier2 IS NULL THEN 1 ELSE sdd.volume_multiplier2 END,
		       sdd.multiplier = CASE WHEN sdd.multiplier IS NULL THEN 1 ELSE sdd.multiplier END,
		       sdd.settlement_date = CASE WHEN sdd.settlement_date IS NULL THEN sdd.term_end ELSE sdd.settlement_date END
		FROM   source_deal_detail sdd
		       INNER JOIN #affected_deals dd ON  dd.source_deal_header_id = sdd.source_deal_header_id		
			

		--EXEC spa_source_deal_detail_hour 'i',@source_deal_header_id	-- the 'i' flag is not present in spa_source_deal_detail_hour (only 's' and 'u')

		DECLARE @affected_deals_list_i VARCHAR(8000), @affected_deals_list_u  VARCHAR(8000)
		
		SELECT @affected_deals_list_i = COALESCE(@affected_deals_list_i + ',' + CAST(source_deal_header_id AS VARCHAR), CAST(source_deal_header_id AS VARCHAR)) 
		FROM #affected_deals WHERE [ACTION] IN ('i')
		
		SELECT @affected_deals_list_u = COALESCE(@affected_deals_list_u + ',' + CAST(source_deal_header_id AS VARCHAR), CAST(source_deal_header_id AS VARCHAR)) 
		FROM #affected_deals WHERE [ACTION] IN ('u')
		EXEC spa_print @affected_deals_list_i
		EXEC spa_print @affected_deals_list_u
		set @spa = '';
		--select @affected_deals_list
		IF @affected_deals_list_i IS NOT NULL
		BEGIN
			SET @spa = 'spa_insert_update_audit ''i'',''' + @affected_deals_list_i + ''';'
		END
		IF @affected_deals_list_i IS NULL AND @affected_deals_list_u IS NOT NULL
		BEGIN
			SET @spa = 'spa_insert_update_audit ''u'',''' + @affected_deals_list_u + ''''
		END
		IF @affected_deals_list_i IS NOT NULL AND @affected_deals_list_u IS NOT NULL
		BEGIN
			SET @spa = @spa + 'exec spa_insert_update_audit ''u'',''' + @affected_deals_list_u + ''''
		END
		---------------------------------------------------------------------------------------------------
		IF @affected_deals_list_i IS NOT NULL OR @affected_deals_list_u IS NOT NULL
		BEGIN		
			SET @job_name = 'spa_insert_update_audit_' + @process_id
			EXEC spa_run_sp_as_job @job_name, @spa,'spa_insert_update_audit' ,@user_login_id
		END 
			
	END 

	

	Logging:

	--IF @total_deal_details_processed - ISNULL(@total_deal_details_found, 0) > 0
	--	SET @errorcode='e'
	--ELSE
	--BEGIN
	--	SET @errorcode='s'
	--END

	DECLARE @errorcode_msgbrd CHAR(1)
	DECLARE @has_staging_table_data CHAR(1)
	
	
	IF EXISTS(SELECT * FROM #import_status WHERE [type] LIKE '%Error%')
		SET @errorcode_msgbrd = 'e'
	ELSE
		SET @errorcode_msgbrd = 's'
	 	

	SELECT @total_deal_details_found = COUNT(*) FROM #all_deal_detail dd
	INNER JOIN #all_deal_header dh ON dh.source_deal_id = dd.source_deal_id AND dh.source_system_id = dd.source_system_id
	INNER JOIN #affected_deals af ON af.deal_id = dh.source_deal_id_old 
	WHERE
		((dh.notification_status IS NULL AND @errorcode_msgbrd = 'e') OR @errorcode_msgbrd = 's')
		
	SELECT @total_deal_details_processed = COUNT(*) FROM #all_deal_detail dd
		INNER JOIN #all_deal_header dh ON dh.source_deal_id = dd.source_deal_id AND dh.source_system_id = dd.source_system_id
	WHERE
		((dh.notification_status IS NULL AND @errorcode_msgbrd = 'e') OR @errorcode_msgbrd = 's')


	IF EXISTS (SELECT * FROM #import_status WHERE ErrorCode NOT IN ('MISSING_STATIC_DATA','OLD_DEALS'))
		SET @errorcode = 'e'
	ELSE 
		SET @errorcode = 's'

		


	IF EXISTS (
		SELECT 1 FROM pratos_stage_deal_header psdh (nolock) 
		INNER JOIN #all_deal_header adh 
		ON ISNULL(adh.source_deal_id_old, psdh.source_deal_id) = ISNULL(psdh.source_deal_id_old, psdh.source_deal_id)
	) AND @bulk_import = 'n'
	BEGIN 
		SET @has_staging_table_data = 'y'
	END 
	ELSE 
	BEGIN
		SET @has_staging_table_data = 'n'
	END
	


	IF @process_staging_table = 'y' AND @total_deal_details_processed = 0
	BEGIN
		 RETURN
	END

	
	INSERT INTO source_system_data_import_status (process_id,code,MODULE,source,TYPE,[description],recommendation) 
	SELECT 
		@process_id,
		CASE WHEN @errorcode_msgbrd='e' THEN 'Error' ELSE 'Success' END,
		--'Success', 
		CASE WHEN ISNULL(@process_staging_table,'n')='n' THEN 'Pratos Interface' ELSE 'Staging Table' END,
		'Pratos Data Import',		
		'Import',			
		CAST(COUNT(DISTINCT idh.source_deal_id) AS VARCHAR) 
		+ ' out of ' 
		+ CAST(COUNT(DISTINCT dh.source_deal_id) AS VARCHAR) 
		+ ' deal(s) imported. (' 
		+ CAST(COUNT(idh.source_deal_id) AS VARCHAR)
		+ ' out of '
		+ CAST(COUNT(dh.source_deal_id) AS VARCHAR)
		+ ' deal details imported.) Total volume imported is '
		+ CASE WHEN MAX(imp.ErrorCode) = 'INVALID_NULL_FIELD' THEN '0' ELSE  CAST(LTRIM(STR(ISNULL(SUM(idd.deal_volume), 0), 18, 2)) AS VARCHAR) END
		+ ' out of '
		+ CAST(LTRIM(STR(ISNULL(SUM(dd.deal_volume), 0), 18, 2)) AS VARCHAR)
		
		+ CASE WHEN @has_staging_table_data = 'y' THEN ' <i>(Some data imported into PRATOS staging tables.)</i>' ELSE '' END 
		+ '<br>Deal(s): ' + ISNULL(@deals, 'NULL')
		,
		
		CASE WHEN @errorcode_msgbrd='e' THEN 'Please Check your data' ELSE 'N/A' END
		
	FROM #all_deal_header dh
	INNER JOIN #all_deal_detail dd ON dd.source_deal_id = dh.source_deal_id 
	LEFT JOIN #deal_header idh ON idh.source_deal_id = dh.source_deal_id 
	LEFT JOIN #deal_detail idd 
		ON idd.source_deal_id = dd.source_deal_id 
		AND idd.term_start = dd.term_start
		AND idd.term_end = dd.term_end 
		AND idd.leg = dd.leg 
		AND ISNULL(idd.location,-1) = ISNULL(dd.location,-1)
	LEFT JOIN #import_status imp ON imp.external_type_id = dh.source_deal_id
	WHERE
		((dh.notification_status IS NULL AND @errorcode_msgbrd = 'e') OR @errorcode_msgbrd = 's')
	HAVING COUNT(DISTINCT dh.source_deal_id) > 0

	UNION ALL 

	SELECT @process_id,	
		CASE WHEN @errorcode_msgbrd='e' THEN 'Error' ELSE 'Success' END,
		'Pratos',
		'Pratos Data Import',
		'Import',
		CAST(@count_delete_deals AS VARCHAR) + ' deal(s) have been deleted.',  
		'N/A'
	WHERE @count_delete_deals > 0
	
	UNION
	
	SELECT DISTINCT
		@process_id,
		'Error',
		'Pratos Interface',
		'Pratos Data Import',		
		'Import',			
		'Deal(s): ' + ISNULL(external_type_id, 'NULL') +' is Older.',		
		'Please Check your data' 
		
	FROM
		#import_status imp 
	WHERE
		[ErrorCode]='OLD_DEALS'

	
	
	--IF NOT EXISTS (SELECT 1 FROM source_system_data_import_status WHERE process_id = @process_id)
	--BEGIN
	--	INSERT INTO source_system_data_import_status (process_id,code,MODULE,source,TYPE,[description],recommendation) 
	--	SELECT 
	--		@process_id,
	--		'Error',	--CASE WHEN @errorcode='e' THEN 'Error' ELSE 'Success' END,
	--		'Pratos',
	--		'Pratos Data Import',
	--		'Import',
	--		'No Data Found',
	--		'N/A'
	
	--RETURN
	--END	
	
	


	INSERT INTO source_system_data_import_status_detail (process_id, source, TYPE, [description], type_error)
	SELECT DISTINCT @process_id, source, ErrorCode, [description], type_error FROM #import_status

	
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''

	SELECT @desc = '<a target="_blank" href="' + @url + '">' 
		+ 'Deal Import from PRATOS' 
		+ CASE @process_staging_table WHEN 'y' THEN ' staging tables' ELSE '' END
		+ ' completed' 
		+ CASE @process_staging_table WHEN 'n' THEN ' for deal: ' + ISNULL(@deals,'NULL') ELSE '' END 
		+ CASE WHEN (@errorcode_msgbrd = 'e') THEN ' (ERRORS found)' ELSE '' END + '.</a>'

 					
	DECLARE list_user CURSOR FOR 
		SELECT DISTINCT application_users.user_login_id	
			FROM dbo.application_role_user 
				INNER JOIN dbo.application_security_role 
					ON dbo.application_role_user.role_id = dbo.application_security_role.role_id 
				INNER JOIN dbo.application_users 
					ON dbo.application_role_user.user_login_id = dbo.application_users.user_login_id
				WHERE (dbo.application_users.user_active = 'y') AND (dbo.application_security_role.role_type_value_id = 2) 		
					--AND application_users.user_login_id <> @user_login_id			
				GROUP BY dbo.application_users.user_login_id,  dbo.application_users.user_emal_add
	OPEN list_user
		FETCH NEXT FROM list_user INTO @user
		WHILE @@FETCH_STATUS = 0
		BEGIN		
			EXEC spa_message_board 'u', @user, NULL, 'Pratos Data Import', @desc, '', '', @errorcode_msgbrd, NULL, NULL, @process_id, NULL, 'n', NULL, 'n'
			FETCH NEXT FROM list_user INTO 	@user
		END
	CLOSE list_user
	DEALLOCATE list_user
	
	
	--EXEC  spa_message_board 'u', @user_login_id, NULL, 'Pratos Data Import', @desc, '', '', @errorcode, NULL, NULL, @process_id, NULL, NULL, NULL, 'y'


	SET @end_date = GETDATE()
	SET @elapsed_time = DATEDIFF(s,@start_date,@end_date) 
	

	-------- END OF SECTION 2 ---------

	-- Update notification statuc in staging table
	IF @process_staging_table = 'y'
		UPDATE psdh SET psdh.notification_status ='Notified' FROM pratos_stage_deal_header psdh 
		INNER JOIN #all_deal_header dh ON dh.source_deal_id = psdh.source_deal_id

	
	--UPDATE import_data_files_audit
	--SET as_of_date = @end_date, 
	--	status = @errorcode_msgbrd,
	--	elapsed_time = @elapsed_time
	--WHERE id = @import_data_files_audit_id
	
	
		INSERT INTO import_data_files_audit (
			dir_path,
			imp_file_name,
			as_of_date,
			status,
			elapsed_time,
			process_id,
			source_system_id
		  )
		VALUES (
			@dir_path,
			@imp_file_name,
			@end_date,
			@errorcode_msgbrd,
			@elapsed_time,
			@process_id,
			@source_system_id
		  )

		SET @import_data_files_audit_id = SCOPE_IDENTITY()
			

		
	DECLARE @missing_static_data_fields VARCHAR(8000)
	
	IF @errorcode = 's'
	BEGIN
		IF @has_staging_table_data = 'y'
		BEGIN
			SELECT @missing_static_data_fields = COALESCE(@missing_static_data_fields + '. ' + field, field) FROM #import_status WHERE ErrorCode = 'MISSING_STATIC_DATA' GROUP BY field

			SELECT DISTINCT ISNULL(psdh.source_deal_id_old, psdh.source_deal_id) source_deal_id 
			INTO #tmp_deals 			  
			FROM pratos_stage_deal_header psdh (nolock) 
				INNER JOIN #all_deal_header adh 
				ON ISNULL(adh.source_deal_id_old, psdh.source_deal_id) = ISNULL(psdh.source_deal_id_old, psdh.source_deal_id)
			GROUP BY ISNULL(psdh.source_deal_id_old, psdh.source_deal_id)
			ORDER BY ISNULL(psdh.source_deal_id_old, psdh.source_deal_id)
			
			SET @deals = NULL 							
			SELECT @deals = COALESCE(@deals + ',' + source_deal_id, source_deal_id)	FROM #tmp_deals 
			
			SET @msg = 'Successfully processed all deals'
			SET @recommendation = 'Deal(s) ' + ISNULL(@deals ,'') + ' imported into staging table. MISSING_STATIC_DATA: ' + ISNULL(@missing_static_data_fields, '')									
		END 
		ELSE
		BEGIN
			SET @msg = 'Successfully processed all deals'
			SET @recommendation = ''
		END
		
		
		INSERT INTO #error_handler (
			error_code, 
			MODULE,
			area,
			[status],
			[MESSAGE],
			recommendation
		)
		EXEC spa_ErrorHandler 0,  
			'Pratos Interface',  
			'spa_soap_pratos',  
			'Success',  
			@msg,  
			@recommendation 	
		
	END
	ELSE
	BEGIN
	
		DECLARE @errors VARCHAR(8000)
		DECLARE @invalid_null_fields VARCHAR(8000),
				@duplicate_udf_fields VARCHAR(8000)
	
		SELECT @deals = COALESCE(@deals + ', ' + deal_id, deal_id) FROM #tmp_erroneous_deals 
		
		SELECT @invalid_null_fields = COALESCE(@invalid_null_fields + ', ' + field, field) FROM #import_status WHERE ErrorCode = 'INVALID_NULL_FIELD' GROUP BY field 
		SELECT @missing_static_data_fields = COALESCE(@missing_static_data_fields + '. ' + field, field) FROM #import_status WHERE ErrorCode = 'MISSING_STATIC_DATA' GROUP BY field 
		SELECT @duplicate_udf_fields = COALESCE(@duplicate_udf_fields + '. ' + field, field) FROM #import_status WHERE ErrorCode = 'DUPLICATE_UDF_FIELD' GROUP BY field
		
		IF @has_invalid_null_fields = 'y' 
			OR @duplicate_udf_fields IS NOT NULL 
		BEGIN
			SET @msg = 'Successfully processed all deals (with errors)'
			SET @recommendation = 'Error inserting deals.' 
									+ ISNULL(' INVALID_NULL_FIELD: ' + @invalid_null_fields, '') 
									+ ISNULL(' MISSING_STATIC_DATA: ' + @missing_static_data_fields, '')
									+ ISNULL(' DUPLICATE_UDF_FIELD: ' + @duplicate_udf_fields, '')
		END	
		ELSE 
		BEGIN
			SET @msg = 'Successfully processed all deals (with errors)'
			SET @recommendation = 'Deal(s) ' + @deals + ' imported into staging table. MISSING_STATIC_DATA: ' + @missing_static_data_fields									
		END
		
	

		--INSERT INTO #status
		--SELECT i.external_type_id, ErrorCode, MAX(fields) fields
		--FROM #import_status i
		--CROSS APPLY (
		--	SELECT STUFF(
		--	(SELECT DISTINCT ', ' + field FROM #import_status 
		--	WHERE external_type_id = i.external_type_id 
		--	AND ErrorCode = i.ErrorCode
		--	FOR XML PATH('')),1,2,'') fields
		--) p
		--GROUP BY i.external_type_id, ErrorCode 


		INSERT INTO #error_handler (
			error_code, 
			MODULE,
			area,
			[status],
			[MESSAGE],
			recommendation
		)						
		EXEC spa_ErrorHandler -1,  
			'Pratos Interface',  
			'spa_soap_pratos',  
			'Error',  
			@msg,  
			@recommendation 
			
		
		--INSERT INTO #error_handler (
		--	error_code, 
		--	deal_id, 
		--	fields
		--)
		--SELECT 'Error', external_type_id, MIN(f) FROM #status s
		--CROSS APPLY (
		--	SELECT STUFF ((SELECT ', ' + ErrorCode + ': ' + fields FROM #status 
		--	WHERE external_type_id = s.external_type_id 
		--	FOR XML PATH('')),1,2,'') f
		--) p 
		--GROUP BY external_type_id 
		
		
	END
	
	
	
	CREATE TABLE #status (
		external_type_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
		ErrorCode VARCHAR(100) COLLATE DATABASE_DEFAULT,
		fields VARCHAR(1000) COLLATE DATABASE_DEFAULT
	)
	
	INSERT INTO #status
	SELECT i.external_type_id, ErrorCode, LEFT(MAX(fields), 1000) fields
	FROM #import_status i
	CROSS APPLY (
		SELECT STUFF(
		(SELECT DISTINCT ', ' + field FROM #import_status 
		WHERE external_type_id = i.external_type_id 
		AND ErrorCode = i.ErrorCode
		FOR XML PATH('')),1,2,'') fields
	) p
	GROUP BY i.external_type_id, ErrorCode 
	
	
	INSERT INTO #error_handler (
		error_code, 
		deal_id, 
		fields
	)
	SELECT --CASE WHEN @errorcode = 's' THEN 'Success' ELSE 'Error' END
		CASE 
			WHEN @errorcode = 's' THEN 'Success' 
			WHEN @errorcode = 'e' AND psdh.source_deal_id IS NOT NULL THEN 'Success'
			ELSE 'Error'
		END
		, external_type_id, MIN(f) 
	FROM #status s
	CROSS APPLY (
		SELECT STUFF ((SELECT ', ' + ErrorCode + ': ' + fields FROM #status 
		WHERE external_type_id = s.external_type_id 
		FOR XML PATH('')),1,2,'') f
	) p 
	LEFT JOIN pratos_stage_deal_header psdh (nolock) ON psdh.source_deal_id = s.external_type_id AND @bulk_import = 'n'
	GROUP BY external_type_id, psdh.source_deal_id
	
				
	
END TRY 
BEGIN CATCH 

	
	SET @desc = ERROR_MESSAGE()
	SET @errorcode = 'e'
	
	SELECT @deals = COALESCE(@deals + ', ' + source_deal_id, source_deal_id) FROM #deal_header 
	

	IF @@TRANCOUNT > 0
		ROLLBACK
		
	SET @msg = 'Deal Import for PRATOS ' + ISNULL('deals ' + @deals, '') + ' failed. (' + @desc + ')'

	SET @end_date = GETDATE()
	SET @elapsed_time = DATEDIFF(s,@start_date,@end_date) 
	
	UPDATE import_data_files_audit
	SET as_of_date = @end_date, 
		status = @errorcode,
		elapsed_time = @elapsed_time
	WHERE id = @import_data_files_audit_id
	
	DECLARE list_user CURSOR FOR 
		SELECT application_users.user_login_id	
			FROM dbo.application_role_user 
				INNER JOIN dbo.application_security_role 
					ON dbo.application_role_user.role_id = dbo.application_security_role.role_id 
				INNER JOIN dbo.application_users 
					ON dbo.application_role_user.user_login_id = dbo.application_users.user_login_id
				WHERE (dbo.application_users.user_active = 'y') AND (dbo.application_security_role.role_type_value_id = 2) 							
				GROUP BY dbo.application_users.user_login_id,  dbo.application_users.user_emal_add
	OPEN list_user
		FETCH NEXT FROM list_user INTO @user
		WHILE @@FETCH_STATUS = 0
		BEGIN					
			EXEC spa_message_board 'i', @user, NULL, 'Pratos Data Import', @msg, '', '', @errorcode, NULL, NULL, @process_id
			FETCH NEXT FROM list_user INTO 	@user
		END
	CLOSE list_user
	DEALLOCATE list_user
		

	INSERT INTO #error_handler (
		error_code, 
		module,
		area,
		[status],
		[message],
		recommendation
	)
	EXEC spa_ErrorHandler -1,  
		 'Pratos Interface',  
		 'spa_soap_pratos',  
		 'Error',  
		 'Error importing deal. Please check your messageboard.',
		 @desc  
		 
	SELECT 
			CASE error_code WHEN 'Success' THEN 'S' WHEN 'Error' THEN 'E' ELSE 'I' END AS ErrorCode, 
			MODULE,
			area,
			[status],
			[MESSAGE],
			recommendation,
			deal_id,
			fields
	FROM #error_handler ORDER BY deal_id		 
	
	RETURN 
	
END CATCH 


IF NOT EXISTS(select * from #affected_deals) AND @bulk_import = 'y'
	INSERT INTO #affected_deals(source_deal_header_id , deal_id , [ACTION])
	SELECT DISTINCT -1,dh.source_deal_id,'u'
	FROM
		#deal_header dh
		LEFT JOIN #import_status
		ON #import_status.external_type_id = dh.source_deal_id 
		WHERE ErrorCode NOT IN ('DUPLICATE_UDF_FIELD','INVALID_NULL_FIELD') OR #import_status.external_type_id IS NULL
		
ELSE
	UPDATE ad 
	SET deal_id = dh.source_deal_id 
	FROM #affected_deals ad
	INNER JOIN #deal_header dh ON dh.source_deal_id_old = ad.deal_id 



INSERT INTO #error_handler 
SELECT 'Success', NULL, NULL, NULL, NULL, NULL, deal_id, 
CASE [ACTION]  
	WHEN 'i' THEN 'Deal Successfully Inserted'
	WHEN 'u' THEN 'Deal Successfully Updated'
	WHEN 'd' THEN 'Deal Successfully Deleted'
END 
FROM #affected_deals 

IF @process_staging_table <> 'y'
BEGIN
	SELECT 
			CASE error_code WHEN 'Success' THEN 'S' WHEN 'Error' THEN 'E' ELSE 'I' END AS ErrorCode, 
			MODULE,
			area,
			[status],
			[MESSAGE],
			recommendation,
			deal_id,
			fields
	FROM #error_handler ORDER BY deal_id	
END

/************************************* Object: 'spa_soap_pratos' END *************************************/
