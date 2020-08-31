
/****** Object:  StoredProcedure [dbo].[spa_sourcedealtemp_detail_paging]    Script Date: 01/30/2012 03:26:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_sourcedealtemp_detail_paging]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_sourcedealtemp_detail_paging]
GO

/****** Object:  StoredProcedure [dbo].[spa_sourcedealtemp_detail_paging]    Script Date: 01/30/2012 03:26:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*

exec spa_sourcedealtemp_paging 'e', NULL,2002, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ''
	Modification History
	Modified By:Pawan KC
	Modified Date:26/03/3009
	Description: Removed option_type from selection and insertion of source_deal_header in the v block
	
	Modification History
	Modified By:Pawan KC
	Modified Date:30/03/3009
	Description: Mapped template_id in the v flag block while inserting the source deal header
*/

--select * from  source_deal_header
--spa_sourcedealtemp_paging 'a',NULL,130363 ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
--,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'5D7AF6D9_273F_471D_8A4D_839E0F8AC6BA'

CREATE PROC [dbo].[spa_sourcedealtemp_detail_paging]
	@flag_pre CHAR(1),
	@book_deal_type_map_id VARCHAR(200)=NULL, 
	@source_deal_header_id INT=NULL,
	@source_system_id INT=NULL,
	@counterparty_id INT=NULL,
	@entire_term_start VARCHAR(10)=NULL,
	@entire_term_end VARCHAR(10)=NULL,
	@source_deal_type_id INT=NULL,
	@deal_sub_type_type_id INT=NULL,
	@deal_category_value_id INT=NULL,
	@trader_id INT=NULL,
	@internal_deal_type_value_id INT=NULL,
	@internal_deal_subtype_value_id INT= NULL,
	@book_id INT=NULL,
	@template_id INT = NULL,
	@term_start VARCHAR(10)=NULL,
	@term_end VARCHAR(10)=NULL,
	@leg INT=NULL,
	@contract_expiration_date VARCHAR(10)=NULL,
	@fixed_float_leg CHAR(1)=NULL,
	@buy_sell_flag CHAR(1)=NULL,
	@curve_id VARCHAR(150)=NULL,
	@fixed_price FLOAT=NULL,
	@fixed_price_currency_id INT=NULL,
	@option_flag CHAR(1)=NULL,
	@option_strike_price FLOAT=NULL,
	@deal_volume NUMERIC(38,20)=NULL,
	@deal_volume_frequency CHAR(1)=NULL,
	@deal_volume_uom_id INT=NULL,
	@block_description VARCHAR(100)=NULL,
	@deal_detail_description VARCHAR(100)=NULL,
	@term_start1 VARCHAR(10)=NULL,
	@term_end1 VARCHAR(10)=NULL,
	@leg1 INT=NULL,
	@formula_id INT=NULL,
	@sell_curve_id INT=NULL,
	@sell_fixed_price FLOAT=NULL,
	@sell_fixed_price_currency_id INT=NULL,
	@sell_option_strike_price FLOAT=NULL,
	@sell_deal_volume FLOAT=NULL,
	@sell_deal_volume_frequency CHAR(1)=NULL,
	@sell_deal_volume_uom_id INT=NULL,
	@sell_fixed_float_leg CHAR(1)=NULL,
	@sell_formula_id INT=NULL,
	@process_id VARCHAR(100)=NULL,
	@deal_date VARCHAR(10)=NULL,
	@frequency_type CHAR(1)=NULL,
	@broker_id INT=NULL,
	@hour_from INT=NULL,
	@hour_to INT=NULL,
	@source_deal_detail_id VARCHAR(1000)=NULL,
	@deal_id VARCHAR(1000)=NULL,
	@physical_financial_flag CHAR(1)=NULL,
	@option_type CHAR(1)=NULL,
	@option_excercise_type CHAR(1)=NULL,
	@options_term_start VARCHAR(20)=NULL,
	@options_term_end VARCHAR(20)=NULL,
	@exercise_date VARCHAR(20)=NULL,
	@round_value CHAR(2)='2',
	@deleted_deal VARCHAR(1)='n',
	@process_id_paging VARCHAR(200)=NULL, 
	@page_size INT =NULL,
	@page_no INT=NULL
AS 	



DECLARE @user_login_id      VARCHAR(50),
        @tempTable          VARCHAR(MAX)

DECLARE @flag               CHAR(1)
DECLARE @max_leg            INT,
        @buy_sell           CHAR(1),
        @label_index        VARCHAR(50),
        @label_price        VARCHAR(50)

DECLARE @field_template_id  INT


DECLARE @udf_field     VARCHAR(5000),
        @udf_value     VARCHAR(MAX),
        @udf_field_id  VARCHAR(MAX)

DECLARE @query2        VARCHAR(MAX)

CREATE TABLE #temp_field_template_id(field_template_id INT)
DECLARE @sql VARCHAR(1000)

SET @sql = '
			INSERT INTO #temp_field_template_id(field_template_id)
			SELECT field_template_id
			FROM ' + CASE WHEN @deleted_deal = 'n' THEN 'source_deal_header' ELSE 'delete_source_deal_header' END + ' sdh
			INNER JOIN dbo.source_deal_header_template tem ON sdh.template_id = tem.template_id
			WHERE  sdh.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(10)) 
		
EXEC (@sql)
SELECT @field_template_id = field_template_id 
FROM #temp_field_template_id

SET @user_login_id=dbo.FNADBUser()

IF @process_id_paging IS NULL
BEGIN
	EXEC spa_print 'test'
	SET @flag = 'i'
	SET @process_id_paging = REPLACE(NEWID(),'-','_')
END
SET @tempTable=dbo.FNAProcessTableName('paging_sourcedealtemp', @user_login_id,@process_id_paging)
EXEC spa_print @tempTable
DECLARE @sqlStmt VARCHAR(MAX)

IF @flag = 'i'
BEGIN
	IF @flag_pre = 's' OR @flag_pre = 'p' OR @flag_pre = 'g'
	BEGIN
		SET @sqlStmt = 'CREATE TABLE ' + @tempTable + ' (
			[sno] INT IDENTITY(1,1), 
			source_deal_detail_id VARCHAR(50),
			term_start VARCHAR(50),
			term_end VARCHAR(50),
			Leg VARCHAR(50),
			contract_expiration_date VARCHAR(50),
			fixed_float_leg VARCHAR(50),
			buy_sell_flag VARCHAR(50),
			curve_type VARCHAR(50),
			Commodity VARCHAR(50),
			physical_financial_flag VARCHAR(50),
			location_id VARCHAR(50),
			curve_id VARCHAR(50),
			deal_volume numeric(38,20),
			deal_volume_frequency VARCHAR(50),
			deal_volume_uom_id VARCHAR(50),
			total_volume numeric(38,20),
			capacity numeric(38,20),
			fixed_price numeric(38,20),
			fixed_cost numeric(38,20),
			fixed_cost_currency_id VARCHAR(50),
			Formula VARCHAR(8000),
			formula_currency_id VARCHAR(50),
			option_strike_price VARCHAR(50),
			price_adder numeric(38,20),
			adder_currency_id VARCHAR(50),
			price_multiplier numeric(38,20),
			multiplier numeric(38,20),
			fixed_price_currency_id VARCHAR(50),
			price_adder2 numeric(38,20),
			price_adder_currency2 VARCHAR(50),
			volume_multiplier2 numeric(38,20),
			meter_id VARCHAR(50),
			pay_opposite VARCHAR(100),
			settlement_date VARCHAR(50),
			block_description VARCHAR(100),
			deal_detail_description VARCHAR(100),
			formula_id VARCHAR(8000),
			day_count_id VARCHAR(50),
			settlement_volume VARCHAR(50),
			location_name VARCHAR(500),
			curve_name VARCHAR(500)	,
			settlement_currency Varchar(20),
			standard_yearly_volume Float,
			price_uom_id VARCHAR(100),
			category  VARCHAR(100),
			profile_code  VARCHAR(100),
			pv_party VARCHAR(100),
			formula_curve_id VARCHAR(100),
			sequence INT,
			insert_or_delete VARCHAR(50),
			[lock_deal_detail] [VARCHAR](50),
			[status] [VARCHAR](50),
			counter INT
		)'
	END
/*
	IF @flag_pre = 'g'
	BEGIN
		SET @sqlStmt = 'CREATE TABLE '+@tempTable+' (
			sno INT IDENTITY(1,1), 
			source_deal_detail_id VARCHAR(50),
			term_start VARCHAR(50),
			term_end VARCHAR(50),
			leg VARCHAR(50),
			contract_expiration_date VARCHAR(50),
			fixed_float_leg VARCHAR(50),
			buy_sell_flag VARCHAR(50),
			physical_financial_flag VARCHAR(50),
			location VARCHAR(150),
			curve_id VARCHAR(50),
			deal_volume VARCHAR(50),
			deal_volume_frequency VARCHAR(50),
			deal_volume_uom_id VARCHAR(50),
			capacity varchar(100),
			fixed_price VARCHAR(50),
			fixed_cost VARCHAR(50),
			fixed_cost_currency_id VARCHAR(50),
			formula_price VARCHAR(8000),
			formula_currency_id VARCHAR(50),
			option_strike_price VARCHAR(50),
			price_adder VARCHAR(8000),
			adder_currency_id VARCHAR(50),
			price_multiplier VARCHAR(50),
			multiplier VARCHAR(50),
			currency VARCHAR(50),
			price_adder2 VARCHAR(50),
			price_adder_currency2 VARCHAR(50),
			volume_multiplier2 VARCHAR(50),
			meter VARCHAR(50),
			pay_opposite varchar(100),
			settlement_date VARCHAR(50),
			block_description VARCHAR(50),
			day_count VARCHAR(50),	
			settlement_currency Varchar(20),
			standard_yearly_volume Float,
			price_uom_id VARCHAR(50),
			category VARCHAR(100),
			profile_code VARCHAR(100),
			pv_party VARCHAR(100)
		)'
	END
	*/
	IF @flag_pre = 'e'
	BEGIN
		SET @sqlStmt = 'CREATE TABLE '+@tempTable+' (
			sno INT IDENTITY(1,1), 
			source_deal_detail_id VARCHAR(50),
			term_start VARCHAR(50),
			term_end VARCHAR(50),
			leg VARCHAR(50),
			contract_expiration_date VARCHAR(50),
			fixed_float_leg VARCHAR(50),
			buy_sell_flag VARCHAR(50),
			curve_type VARCHAR(50),
			commodity VARCHAR(50),
			physical_financial_flag VARCHAR(50),
			location VARCHAR(50),
			curve_id VARCHAR(50),
			deal_volume VARCHAR(50),
			deal_volume_frequency VARCHAR(50),
			deal_volume_uom_id VARCHAR(50),
			total_volume varchar(100),
			position_uom VARCHAR(50),
			capacity varchar(100),
			fixed_price VARCHAR(50),
			fixed_cost VARCHAR(50),
			fixed_cost_currency_id VARCHAR(50),
			formula_price VARCHAR(8000),
			formula_currency_id VARCHAR(50),
			option_strike_price VARCHAR(50),
			price_adder VARCHAR(50),
			adder_currency_id VARCHAR(50),
--			multiplier VARCHAR(50),
			volume_multiplier VARCHAR(50),
			price_multiplier VARCHAR(50),
			currency VARCHAR(50),
			price_adder2 VARCHAR(50),
			price_adder_currency2 VARCHAR(50),
			volume_multiplier2 VARCHAR(50),
			meter VARCHAR(50),
			pay_opposite varchar(100),
			settlement_date VARCHAR(50),
			--block_description VARCHAR(100),
			--deal_detail_description VARCHAR(100),
			formula_id VARCHAR(8000),
			settlement_currency Varchar(20),
			standard_yearly_volume FLOAT,
			price_uom_id VARCHAR(50),
			category VARCHAR(100),
			profile_code VARCHAR(100),
			pv_party VARCHAR(100)
			--day_count VARCHAR(50)	
		)'
	END
	exec spa_print @sqlStmt
	EXEC(@sqlStmt)
	
	SET @udf_field = ''
	SET @udf_value = ''
	SET @udf_field_id = ''
	
	SELECT @udf_field = @udf_field + '[udf___' + CAST(udf_temp.udf_template_id AS VARCHAR) + '] VARCHAR(100),',
	       @udf_value = @udf_value + '[udf___' + CAST(udf_temp.udf_template_id AS VARCHAR) + '] = u.[' + CAST(udf_temp.udf_template_id AS VARCHAR) + '],',
	       @udf_field_id = @udf_field_id + '[' + CAST(d.field_id AS VARCHAR) + '],'
	FROM   maintain_field_template_detail d
	       JOIN user_defined_fields_template udf_temp
	            ON  d.field_id = udf_temp.udf_template_id
	       JOIN user_defined_deal_fields_template uddft
	            ON  uddft.udf_user_field_id = udf_temp.udf_template_id
	            AND uddft.template_id = @template_id
	WHERE  udf_or_system = 'u'
	       AND udf_temp.udf_type = 'd'
	       AND d.field_template_id = @field_template_id
	       AND uddft.leg = 1


	IF LEN(@udf_field) > 1
	BEGIN
	    SET @udf_field = LEFT(@udf_field, LEN(@udf_field) -1)
	    SET @udf_value = LEFT(@udf_value, LEN(@udf_value) -1) 
	    SET @udf_field_id = LEFT(@udf_field_id, LEN(@udf_field_id) -1) 
	    
	    EXEC ('ALTER TABLE ' + @tempTable + ' ADD ' + @udf_field)
	END 
	


--	INSERT @tempTable 	
--	exec spa_sourcedealtemp 's',  NULL,  14153,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL, NULL, NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL, NULL, NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'TermStart',NULL,NULL,NULL, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  ,10

	IF @flag_pre = 'e'
		BEGIN
			SET @sqlStmt = '
	INSERT ' + @tempTable + '(
				source_deal_detail_id,
				term_start,
				term_end,
				leg,
				contract_expiration_date,
				fixed_float_leg,
				buy_sell_flag,
				curve_type,
				commodity,
				physical_financial_flag,
				location,
				curve_id,
				deal_volume,
				deal_volume_frequency,
				deal_volume_uom_id,
				total_volume,
				position_uom,
				capacity,
				fixed_price,
				fixed_cost,
				fixed_cost_currency_id,
				formula_price,
				formula_currency_id,
				option_strike_price,
				price_adder,
				adder_currency_id,
				volume_multiplier,
				price_multiplier,
--				multiplier,	
				currency,
				price_adder2,
				price_adder_currency2,
				volume_multiplier2,
				meter,
				pay_opposite,
				settlement_date,
				--block_description,
				--deal_detail_description,
				formula_id,
				settlement_currency,
				standard_yearly_volume,
				price_uom_id,
				category,
				profile_code,
				pv_party
				--day_count
			)' +
			' exec spa_sourcedealtemp_detail ' + 
			+ dbo.FNASingleQuote(@flag_pre) + ',' +
			dbo.FNASingleQuote(@book_deal_type_map_id) + ',' +
			dbo.FNASingleQuote(@source_deal_header_id) + ',' +
			dbo.FNASingleQuote(@source_system_id) + ',' +
			dbo.FNASingleQuote(@counterparty_id) + ',' +
			dbo.FNASingleQuote(@entire_term_start) + ',' +
			dbo.FNASingleQuote(@entire_term_end) + ',' +
			dbo.FNASingleQuote(@source_deal_type_id) + ',' +
			dbo.FNASingleQuote(@deal_sub_type_type_id) + ',' +
			dbo.FNASingleQuote(@deal_category_value_id) + ',' +
			dbo.FNASingleQuote(@trader_id) + ',' +
			dbo.FNASingleQuote(@internal_deal_type_value_id) + ',' +
			dbo.FNASingleQuote(@internal_deal_subtype_value_id) + ',' +
			dbo.FNASingleQuote(@book_id) + ',' +
			dbo.FNASingleQuote(@template_id) + ',' +
			dbo.FNASingleQuote(@term_start) + ',' +
			dbo.FNASingleQuote(@term_end) + ',' +
			dbo.FNASingleQuote(@leg) + ',' +
			dbo.FNASingleQuote(@contract_expiration_date) + ',' +
			dbo.FNASingleQuote(@fixed_float_leg) + ',' +
			dbo.FNASingleQuote(@buy_sell_flag) + ',' +
			dbo.FNASingleQuote(@curve_id) + ',' +
			dbo.FNASingleQuote(@fixed_price) + ',' +
			dbo.FNASingleQuote(@fixed_price_currency_id) + ',' +
			dbo.FNASingleQuote(@option_flag) + ',' +
			dbo.FNASingleQuote(@option_strike_price) + ',' +
			dbo.FNASingleQuote(@deal_volume) + ',' +
			dbo.FNASingleQuote(@deal_volume_frequency) + ',' +
			dbo.FNASingleQuote(@deal_volume_uom_id) + ',' +
			dbo.FNASingleQuote(@block_description) + ',' +
			dbo.FNASingleQuote(@deal_detail_description) + ',' +
			dbo.FNASingleQuote(@term_start1) + ',' +
			dbo.FNASingleQuote(@term_end1) + ',' +
			dbo.FNASingleQuote(@leg1) + ',' +
			dbo.FNASingleQuote(@formula_id) + ',' +
			dbo.FNASingleQuote(@sell_curve_id) + ',' +
			dbo.FNASingleQuote(@sell_fixed_price) + ',' +
			dbo.FNASingleQuote(@sell_fixed_price_currency_id) + ',' +
			dbo.FNASingleQuote(@sell_option_strike_price) + ',' +
			dbo.FNASingleQuote(@sell_deal_volume) + ',' +
			dbo.FNASingleQuote(@sell_deal_volume_frequency) + ',' +
			dbo.FNASingleQuote(@sell_deal_volume_uom_id) + ',' +
			dbo.FNASingleQuote(@sell_fixed_float_leg) + ',' +
			dbo.FNASingleQuote(@sell_formula_id) + ',' +
			dbo.FNASingleQuote(@process_id) + ',' +
			dbo.FNASingleQuote(@deal_date) + ',' +
			dbo.FNASingleQuote(@frequency_type) + ',' +
			dbo.FNASingleQuote(@broker_id) + ',' +
			dbo.FNASingleQuote(@hour_from) + ',' +
			dbo.FNASingleQuote(@hour_to) + ',' +
			dbo.FNASingleQuote(@source_deal_detail_id) + ',' +
			dbo.FNASingleQuote(@deal_id) + ',' +
			dbo.FNASingleQuote(@physical_financial_flag) + ',' +
			dbo.FNASingleQuote(@option_type) + ',' +
			dbo.FNASingleQuote(@option_excercise_type) + ',' +
			dbo.FNASingleQuote(@options_term_start) + ',' +
			dbo.FNASingleQuote(@options_term_end) + ',' +
			dbo.FNASingleQuote(@exercise_date) + ',' +
			dbo.FNASingleQuote(@round_value)+','+
			dbo.FNASingleQuote(@deleted_deal)
		
		END 
	ELSE 
		BEGIN 

			SET @sqlStmt = '
		INSERT ' + @tempTable + '(
			source_deal_detail_id,
			term_start,
			term_end,
			Leg,
			contract_expiration_date,
			fixed_float_leg,
			buy_sell_flag,
			curve_type,
			Commodity,
			physical_financial_flag,
			location_id,
			curve_id,
			deal_volume,
			deal_volume_frequency,
			deal_volume_uom_id,
			total_volume,
			capacity,
			fixed_price,
			fixed_cost,
			fixed_cost_currency_id,
			Formula,
			formula_currency_id,
			option_strike_price,
			price_adder,
			adder_currency_id,
			price_multiplier,
			multiplier,
			fixed_price_currency_id,
			price_adder2,
			price_adder_currency2,
			volume_multiplier2,
			meter_id,
			pay_opposite,
			settlement_date,
			block_description,
			deal_detail_description,
			formula_id,
			day_count_id,
			--settlement_volume,
			location_name,
			curve_name,
			settlement_currency,
			standard_yearly_volume,
			price_uom_id,
			category ,
			profile_code ,
			pv_party,
			formula_curve_id,
			[lock_deal_detail],
			[status],
			counter					
			)' +
				' exec spa_sourcedealtemp_detail ' + 
				+ dbo.FNASingleQuote(@flag_pre) + ',' +
				dbo.FNASingleQuote(@book_deal_type_map_id) + ',' +
				dbo.FNASingleQuote(@source_deal_header_id) + ',' +
				dbo.FNASingleQuote(@source_system_id) + ',' +
				dbo.FNASingleQuote(@counterparty_id) + ',' +
				dbo.FNASingleQuote(@entire_term_start) + ',' +
				dbo.FNASingleQuote(@entire_term_end) + ',' +
				dbo.FNASingleQuote(@source_deal_type_id) + ',' +
				dbo.FNASingleQuote(@deal_sub_type_type_id) + ',' +
				dbo.FNASingleQuote(@deal_category_value_id) + ',' +
				dbo.FNASingleQuote(@trader_id) + ',' +
				dbo.FNASingleQuote(@internal_deal_type_value_id) + ',' +
				dbo.FNASingleQuote(@internal_deal_subtype_value_id) + ',' +
				dbo.FNASingleQuote(@book_id) + ',' +
				dbo.FNASingleQuote(@template_id) + ',' +
				dbo.FNASingleQuote(@term_start) + ',' +
				dbo.FNASingleQuote(@term_end) + ',' +
				dbo.FNASingleQuote(@leg) + ',' +
				dbo.FNASingleQuote(@contract_expiration_date) + ',' +
				dbo.FNASingleQuote(@fixed_float_leg) + ',' +
				dbo.FNASingleQuote(@buy_sell_flag) + ',' +
				dbo.FNASingleQuote(@curve_id) + ',' +
				dbo.FNASingleQuote(@fixed_price) + ',' +
				dbo.FNASingleQuote(@fixed_price_currency_id) + ',' +
				dbo.FNASingleQuote(@option_flag) + ',' +
				dbo.FNASingleQuote(@option_strike_price) + ',' +
				dbo.FNASingleQuote(@deal_volume) + ',' +
				dbo.FNASingleQuote(@deal_volume_frequency) + ',' +
				dbo.FNASingleQuote(@deal_volume_uom_id) + ',' +
				dbo.FNASingleQuote(@block_description) + ',' +
				dbo.FNASingleQuote(@deal_detail_description) + ',' +
				dbo.FNASingleQuote(@term_start1) + ',' +
				dbo.FNASingleQuote(@term_end1) + ',' +
				dbo.FNASingleQuote(@leg1) + ',' +
				dbo.FNASingleQuote(@formula_id) + ',' +
				dbo.FNASingleQuote(@sell_curve_id) + ',' +
				dbo.FNASingleQuote(@sell_fixed_price) + ',' +
				dbo.FNASingleQuote(@sell_fixed_price_currency_id) + ',' +
				dbo.FNASingleQuote(@sell_option_strike_price) + ',' +
				dbo.FNASingleQuote(@sell_deal_volume) + ',' +
				dbo.FNASingleQuote(@sell_deal_volume_frequency) + ',' +
				dbo.FNASingleQuote(@sell_deal_volume_uom_id) + ',' +
				dbo.FNASingleQuote(@sell_fixed_float_leg) + ',' +
				dbo.FNASingleQuote(@sell_formula_id) + ',' +
				dbo.FNASingleQuote(@process_id) + ',' +
				dbo.FNASingleQuote(@deal_date) + ',' +
				dbo.FNASingleQuote(@frequency_type) + ',' +
				dbo.FNASingleQuote(@broker_id) + ',' +
				dbo.FNASingleQuote(@hour_from) + ',' +
				dbo.FNASingleQuote(@hour_to) + ',' +
				dbo.FNASingleQuote(@source_deal_detail_id) + ',' +
				dbo.FNASingleQuote(@deal_id) + ',' +
				dbo.FNASingleQuote(@physical_financial_flag) + ',' +
				dbo.FNASingleQuote(@option_type) + ',' +
				dbo.FNASingleQuote(@option_excercise_type) + ',' +
				dbo.FNASingleQuote(@options_term_start) + ',' +
				dbo.FNASingleQuote(@options_term_end) + ',' +
				dbo.FNASingleQuote(@exercise_date) + ',' +
				dbo.FNASingleQuote(@round_value)+','+
			dbo.FNASingleQuote(@deleted_deal) +',''y'''
		END 

	EXEC spa_print @sqlStmt
	EXEC(@sqlStmt)	

	 SELECT udf_user_field_id,
	        uddf.source_deal_detail_id,
	        CASE 
	             WHEN udft.Field_type = 'a' THEN dbo.FNADateFormat(uddf.udf_value) 
	             ELSE uddf.udf_value
	        END udf_value INTO #temp_uddf1
	 FROM   user_defined_deal_detail_fields uddf
	        JOIN user_defined_deal_fields_template udft
	             ON  uddf.udf_template_id = udft.udf_template_id
	        JOIN source_deal_detail sdd
	             ON  sdd.source_deal_detail_id = uddf.source_deal_detail_id
	 WHERE  sdd.source_deal_header_id = @source_deal_header_id

	
	
	IF @udf_value <> '' AND @udf_field_id <> ''
	BEGIN
		SET @query2 = 'update ' + @tempTable + ' SET ' + @udf_value + ' 
		from ' + @tempTable + ' t join (
		SELECT * FROM 
		( select source_deal_detail_id,udf_user_field_id,udf_value from #temp_uddf1   
		) src  
		PIVOT (max(udf_value) FOR udf_user_field_id 
		IN (' + @udf_field_id + ')) AS pvt) u 
		on t.source_deal_detail_id=u.source_deal_detail_id
		'
		
		exec spa_print @query2
		EXEC (@query2)
	END

	SET @sqlStmt = 'UPDATE ' + @tempTable + ' SET sequence = sno, insert_or_delete = ''normal''' 
	EXEC(@sqlStmt)

	SET @sqlStmt = 'select count(*) TotalRow,''' + @process_id_paging + ''' process_id  from ' + @tempTable	
	EXEC spa_print @sqlStmt
	EXEC (@sqlStmt)

END
ELSE 
BEGIN
	EXEC spa_print 'i am here'

	DECLARE @row_from INT, @row_to INT 
	SET @row_to = @page_no * @page_size 
	IF @page_no > 1 
		SET @row_from = ((@page_no-1) * @page_size) + 1
	ELSE 
		SET @row_from = @page_no
		
	SELECT @max_leg=MAX(leg),@buy_sell=MAX(buy_sell_flag) FROM source_deal_detail 
	WHERE source_deal_header_id=@source_deal_header_id
	SET @label_index='Index'
	SET @label_price='Price'
	
	IF @max_leg=1 AND @buy_sell='b'
	BEGIN
		SET @label_index='Buy Index'
		SET @label_price='Price'
	END
	ELSE IF @max_leg=1 AND @buy_sell='s'
	BEGIN
		SET @label_index='Sell Index'
		SET @label_price='Price'
	END
	

	IF @flag_pre = 'e'
	BEGIN
		SET @sqlStmt = 'SELECT 
							source_deal_detail_id [ID],
							term_start [Term Start],
							term_end [Term End],
							leg [Leg],
							contract_expiration_date [Expiration Date],
							fixed_float_leg [Fixed Float],
							buy_sell_flag [BuySell],
							curve_type [Curve Type],
							commodity [Commodity],
							CASE WHEN physical_financial_flag = ''p'' THEN ''Physical'' ELSE ''Financial'' END AS [PhysicalFinancial],
						--	physical_financial_flag [PhysicalFinancial],
							location [Location Name],
							curve_id AS ['+@label_index+'],
							dbo.FNARemoveTrailingZeroes(deal_volume) [Volume],
							deal_volume_frequency [Frequency],
							deal_volume_uom_id [Volume UOM],
							total_volume [TotalVolume],
							position_uom [Position UOM],
							capacity [Capacity],
							dbo.FNARemoveTrailingZeroes(fixed_price) ['+@label_price+'],
							dbo.FNARemoveTrailingZeroes(fixed_cost) [Fixed Cost],
							fixed_cost_currency_id [Fixed Cost Currency],
							dbo.FNARemoveTrailingZeroes(formula_price) [Formula Price],
							formula_currency_id [Formula Currency],
							dbo.FNARemoveTrailingZeroes(option_strike_price) [OptStrikePrice],
							dbo.FNARemoveTrailingZeroes(price_adder) [PriceAdder],
							adder_currency_id [Adder Currency],	
							dbo.FNARemoveTrailingZeroes(volume_multiplier) [Volume Multiplier],
							dbo.FNARemoveTrailingZeroes(price_multiplier) [Price Multiplier],
--							dbo.FNARemoveTrailingZeroes(multiplier) [Price Multiplier],
							currency [Price Currency],
							dbo.FNARemoveTrailingZeroes(price_adder2) [PriceAdder2],
							price_adder_currency2 [Adder Currency2],	
							dbo.FNARemoveTrailingZeroes(volume_multiplier2) [VolumeMultiplier2],
							meter [Meter],
							pay_opposite [PayOpposite],
							settlement_date [Payment Date],
							--block_description [block_description],
							--deal_detail_description [HourEnding],
							formula_id [Formula]
							--day_count [DayCount]
							,Settlement_Currency [Sett.Currency],
							Standard_Yearly_Volume [SYV],
							price_uom_id [Price UOM],
							Category,
							profile_code [Profile],
							pv_party [PV Party],
							[lock_deal_detail],
							[status]
							--,enable_lock_deal
						FROM ' + @tempTable 
							+' WHERE sno BETWEEN '+ CAST(@row_from AS VARCHAR) +' AND '+ CAST(@row_to AS VARCHAR)+ ' ORDER BY sno ASC'
								
					EXEC spa_print  @sqlStmt	
					EXEC(@sqlStmt)
			
	END
	ELSE IF @flag_pre = 'p'
	BEGIN

	CREATE TABLE #tempDeal(
							[source_deal_detail_id] [INT] NOT NULL,
							[source_deal_header_id] [INT] NOT NULL,
							[term_start] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
							[term_end] VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL,
							[Leg] [INT]  NULL,
							[contract_expiration_date] VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL,
							[fixed_float_leg] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
							[buy_sell_flag] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
							[curve_id] VARCHAR(150) COLLATE DATABASE_DEFAULT NULL,
							[fixed_price] [NUMERIC](38, 20) NULL,
							[fixed_price_currency_id] [INT] NULL,
							[option_strike_price] [NUMERIC](38, 20) NULL,
							[deal_volume] [NUMERIC](38, 20) NULL,
							[deal_volume_frequency] [CHAR](1) COLLATE DATABASE_DEFAULT  NULL,
							[deal_volume_uom_id] [INT]  NULL,
							[block_description] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
							[deal_detail_description] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
							[formula_id] VARCHAR(500) COLLATE DATABASE_DEFAULT NULL,
							[volume_left] [FLOAT] NULL,
							[settlement_volume] [FLOAT] NULL,
							[settlement_uom] [INT] NULL,
							[create_user] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
							[create_ts] [DATETIME] NULL,
							[update_user] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
							[update_ts] [DATETIME] NULL,
							[price_adder] [NUMERIC](38, 20) NULL,
							[price_multiplier] [NUMERIC](38, 20) NULL,
							[settlement_date] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
							[day_count_id] [INT] NULL,
							[location_id] VARCHAR(500) COLLATE DATABASE_DEFAULT NULL,
							[meter_id] [INT] NULL,
							[physical_financial_flag] [CHAR](1) COLLATE DATABASE_DEFAULT NULL,
							[Booked] [CHAR](1) COLLATE DATABASE_DEFAULT NULL,
							[process_deal_status] [INT] NULL,
							[fixed_cost] [NUMERIC](38, 20) NULL,
							[multiplier] [NUMERIC](38, 20) NULL,
							[adder_currency_id] [INT] NULL,
							[fixed_cost_currency_id] [INT] NULL,
							[formula_currency_id] [INT] NULL,
							[price_adder2] [NUMERIC](38, 20) NULL,
							[price_adder_currency2] [INT] NULL,
							[volume_multiplier2] [NUMERIC](38, 20) NULL,
							[total_volume] [NUMERIC](38, 20) NULL,
							[pay_opposite] [VARCHAR](1) COLLATE DATABASE_DEFAULT NULL,
							[capacity] [NUMERIC](38, 20) NULL,
							[settlement_currency] [INT] NULL,
							[standard_yearly_volume] [FLOAT] NULL,
							[formula_curve_id] [INT] NULL,
							[price_uom_id] [INT] NULL,
							[category] [INT] NULL,
							[profile_code] [INT] NULL,
							[pv_party] [INT] NULL,
							[SEQUENCE] [INT] NULL,
							[insert_or_delete] [VARCHAR](50) COLLATE DATABASE_DEFAULT,
							[row_id] INT,
							[lock_deal_detail] [VARCHAR](50) COLLATE DATABASE_DEFAULT,
							[status] [VARCHAR](50) COLLATE DATABASE_DEFAULT
							,[counter] INT 
								)
		DECLARE @source_deal_header_v VARCHAR(50)
		SET @source_deal_header_v = CAST(@source_deal_header_id AS VARCHAR)

		SET @sqlStmt = ' INSERT INTO #tempDeal (
                      [source_deal_detail_id]
					  , [source_deal_header_id]
					  , [term_start]
					  , [term_end]
					  , [Leg]
					  , [contract_expiration_date]
					  , [fixed_float_leg]
					  , [buy_sell_flag]
					  , [curve_id]
					  , [fixed_price]
					  , [fixed_price_currency_id]
					  , [option_strike_price]
					  , [deal_volume]
					  , [deal_volume_frequency]
					  , [deal_volume_uom_id]
					  , [block_description]
					  , [deal_detail_description]
					  , [formula_id]
					  , [volume_left]
					  , [settlement_volume]
					  , [settlement_uom]
					  , [create_user]
					  , [create_ts]
					  , [update_user]
					  , [update_ts]
					  , [price_adder]
					  , [price_multiplier]
					  , [settlement_date]
					  , [day_count_id]
					  , [location_id]
					  , [meter_id]
					  , [physical_financial_flag]
					  , [Booked]
					  , [process_deal_status]
					  , [fixed_cost]
					  , [multiplier]
					  , [adder_currency_id]
					  , [fixed_cost_currency_id]
					  , [formula_currency_id]
					  , [price_adder2]
					  , [price_adder_currency2]
					  , [volume_multiplier2]
					  , [total_volume]
					  , [pay_opposite]
					  , [capacity]
					  , [settlement_currency]
					  , [standard_yearly_volume]
					  , [formula_curve_id]
					  , [price_uom_id]
					  , [category]
					  , [profile_code]
					  , [pv_party]
					  , [sequence]
					  , [insert_or_delete]
					  , [row_id]
					  , [lock_deal_detail]
					  , [status]
					  , [counter]
						)   
				SELECT a.source_deal_detail_id [ID],
					   '+@source_deal_header_v +',
					   dbo.FNADateFormat(a.term_start) [Term Start],
					   dbo.FNADateFormat(a.term_end) [Term End],
					   a.[Leg],
					   dbo.FNADateFormat(a.contract_expiration_date) [Expire Date],
					  -- CASE 
							--WHEN a.fixed_float_leg = ''Fixed'' THEN ''f''
							--ELSE ''t''
					  -- END [Fixed/Float],
					  a.fixed_float_leg,
					  -- CASE 
							--WHEN a.buy_sell_flag = ''Sell(Pay)'' THEN ''s''
							--ELSE ''b''
					  -- END [Buy/Sell],
					  a.buy_sell_flag,
					   a.curve_id as  ['+@label_index+'],
					   --spcd.[curve_name]  as  ['+@label_index+'],
					   dbo.FNARemoveTrailingZeroes(a.[fixed_price]) [Fixed Price],
					   a.fixed_price_currency_id [Fixed Price Currency],
					   dbo.FNARemoveTrailingZeroes(a.option_strike_price) [Option Strike Price],
					   dbo.FNARemoveTrailingZeroes(ROUND(a.deal_volume, ' + @round_value + ')) [Deal Volume],
					   a.deal_volume_frequency [Volume Frequency],
					   a.deal_volume_uom_id [Volume UOM],
					   a.block_description [Block Description],
					   a.deal_detail_description [Detail Description],
					   a.formula_id [Formula ID],
					   NULL [volume_left],
					   a.settlement_volume [Settlement Volume],
					   NULL [settlement_uom],
					   NULL [create_user],
					   NULL [create_ts],
					   NULL [update_user],
					   NULL [update_ts],
					   a.price_adder [Price Adder],
					   a.price_multiplier [Price Multiplier],
					   dbo.FNADateFormat(a.settlement_date) [Settlement Date],
					   a.day_count_id [Day Count],
					   a.location_id [Location],
					   a.meter_id [Meter],
					   a.physical_financial_flag [Physical/Financial],
					   NULL [Booked],
					   NULL [process_deal_status],
					   a.fixed_cost [Fixed Cost],
					   a.multiplier [Multiplier],
					   a.adder_currency_id [Adder Currency],
					   a.fixed_cost_currency_id [Fixed Cost Currency],
					   a.formula_currency_id [Formula Currency],
					   a.price_adder2 [Price Adder2],
					   a.price_adder_currency2 [Price Adder Currency2],
					   a.volume_multiplier2 [Volume Multiplier2],
					   dbo.FNARemoveTrailingZeroes(ROUND(a.total_volume, ' + @round_value + '))  [Total Volume],
					   a.pay_opposite [Pay Opposite],
					   a.[Capacity],
					   a.settlement_currency [Settlement Currency],
					   a.standard_yearly_volume [Standard Yearly Volume],
					   a.formula_curve_id [Formula Curve ID],
					   a.price_uom_id [Price UOM],
					   a.category [Category],
					   a.profile_code [Profile Code],
					   a.pv_party [Pv Party],
					   a.[sequence],
					   a.[insert_or_delete],
					   ROW_NUMBER() OVER(ORDER BY sequence ASC, sno) row_id
					   , [lock_deal_detail] 
					   , [status]
					   , 0 [counter]
						 FROM ' + @tempTable + ' a  '

						-- FROM ' + @tempTable +' a     WHERE row_id BETWEEN '+ cast(@row_from as varchar) +' AND '+ cast(@row_to as varchar)+ ' ORDER BY sequence, sno ASC'

		EXEC spa_print '-------------------------------------------'
		EXEC spa_print @tempTable
		EXEC spa_print @row_from
		EXEC spa_print @row_to
		EXEC spa_print @round_value
		EXEC spa_print @label_index
		EXEC spa_print @source_deal_header_v
		EXEC spa_print '-------------------------------------------'
		EXEC (@sqlStmt)			 
		
		DELETE FROM #tempDeal WHERE row_id NOT  BETWEEN @row_from AND @row_to
	
		SET @sql = '
					INSERT INTO #temp_field_template_id(field_template_id)
					SELECT field_template_id
					FROM ' + CASE WHEN @deleted_deal = 'n' THEN 'source_deal_header' ELSE 'delete_source_deal_header' END + ' sdh
					INNER JOIN dbo.source_deal_header_template tem ON sdh.template_id = tem.template_id
					WHERE  sdh.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(10)) 
		
		EXEC(@sql)
		
		SELECT @field_template_id = field_template_id 
		FROM #temp_field_template_id
		
		SET @udf_field = ''
		SET @udf_value = ''
		SET @udf_field_id = ''
		
		
			SELECT @udf_field = @udf_field + ' [udf___' + CAST(udf_temp.udf_template_id AS VARCHAR(100)) + '] varchar(100),',

				   @udf_value = @udf_value + '[udf___' + CAST(udf_temp.udf_template_id AS VARCHAR(100)) + ']=u.[udf___' + CAST(udf_temp.udf_template_id AS VARCHAR(100)) + '],',
				   @udf_field_id = @udf_field_id + '[' + CAST(d.field_id AS VARCHAR(100)) + '],'
			FROM   maintain_field_template_detail d
				   JOIN user_defined_fields_template udf_temp
						ON  d.field_id = udf_temp.udf_template_id
				   JOIN user_defined_deal_fields_template uddft
						ON  uddft.udf_user_field_id = udf_temp.udf_template_id
						AND uddft.template_id = @template_id
			WHERE  udf_or_system = 'u'
				   AND udf_temp.udf_type = 'd'
				   AND d.field_template_id = @field_template_id
				   AND uddft.leg = 1
			

			IF LEN(@udf_field) > 1
			BEGIN
				SET @udf_field = LEFT(@udf_field, LEN(@udf_field) -1)
				SET @udf_value = LEFT(@udf_value, LEN(@udf_value) -1) 
				SET @udf_field_id = LEFT(@udf_field_id, LEN(@udf_field_id) -1) 
			     
			    
				EXEC ('ALTER TABLE #tempDeal add ' + @udf_field)
			END 
		
			SELECT udf_user_field_id,
					uddf.source_deal_detail_id,
					CASE 
						 WHEN udft.Field_type = 'a' THEN dbo.FNADateFormat(uddf.udf_value) 
						 ELSE uddf.udf_value
					END udf_value INTO #temp_uddf
			FROM   user_defined_deal_detail_fields uddf
			INNER JOIN user_defined_deal_fields_template udft ON  uddf.udf_template_id = udft.udf_template_id
			INNER JOIN source_deal_detail sdd ON  sdd.source_deal_detail_id = uddf.source_deal_detail_id
			WHERE  sdd.source_deal_header_id = @source_deal_header_id
    
			IF @udf_value <> '' AND @udf_field_id <> ''
			BEGIN
				SET @query2 = 'UPDATE #tempDeal 
								SET ' + @udf_value + ' 
								FROM #tempDeal t 
								INNER JOIN ' + @tempTable + ' u
								ON t.source_deal_detail_id = u.source_deal_detail_id'
				
				exec spa_print @query2
				EXEC (@query2)
			END
					
			DECLARE @sql_pre          VARCHAR(MAX),
			        @farrms_field_id  VARCHAR(100),
			        @default_label    VARCHAR(100)
			
			SET @sql_pre = ''
			DECLARE dealCur CURSOR FORWARD_ONLY READ_ONLY 
			FOR
			    SELECT farrms_field_id,
			           default_label
			    FROM   (   -- in this cursor both update_required and hidden fields need to be included.
						   -- SO don't exclude them	
						   -- case in deal_update_seq_no is used to select source_deal_detail_id at first column.
			               SELECT f.farrms_field_id,
			                      ISNULL(d.field_caption, f.default_label) default_label,
			                      deal_update_seq_no
			               FROM   maintain_field_template_detail d
			                      JOIN maintain_field_deal f
			                           ON  d.field_id = f.field_id
			               WHERE  f.header_detail = 'd'
			                      AND d.field_template_id = @field_template_id
			                      AND ISNULL(d.udf_or_system, 's') = 's'
			                      --AND ISNULL(d.update_required, 'n') = 'y' 
			                      --AND d.hide_control = 'n'					             
			               UNION ALL 
			               SELECT DISTINCT '[udf___' + CAST(d.field_id AS VARCHAR) + ']',
			                      ISNULL(d.field_caption, f.Field_label) default_label,
			                      d.deal_update_seq_no
			               FROM   maintain_field_template_detail d
			                      JOIN user_defined_fields_template f
			                           ON  d.field_id = f.udf_template_id
			                      JOIN user_defined_deal_fields_template uddft
			                           ON  uddft.udf_user_field_id = f.udf_template_id
			                           AND uddft.template_id = @template_id
			               WHERE  d.field_template_id = @field_template_id
			                      AND f.udf_type = 'd'
			                      AND d.udf_or_system = 'u'
			                      --AND ISNULL(d.update_required, 'n') = 'y' 
			                      --AND d.hide_control = 'n' 
			           ) l
			    ORDER BY
			           ISNULL(l.deal_update_seq_no, 10000) 
			
			OPEN dealCur
			FETCH NEXT FROM dealCur INTO @farrms_field_id,@default_label
			WHILE @@FETCH_STATUS = 0
			BEGIN
				--IF  @data_type LIKE 'numeric%' OR @data_type LIKE 'int%' OR @data_type LIKE 'float%'
				--	SET @sql_pre=@sql_pre+' dbo.FNARemoveTrailingZeroes('+ @farrms_field_id +' ) AS ['+ @default_label +'],'
				--ELSE 
					SET @sql_pre=@sql_pre+' '+ @farrms_field_id +' AS ['+ @default_label +'],'
								
			FETCH NEXT FROM dealCur INTO @farrms_field_id,@default_label
			END
			CLOSE dealCur
			DEALLOCATE dealCur
			IF LEN(@sql_pre)>1
			BEGIN
				SET @sql_pre=LEFT(@sql_pre,LEN(@sql_pre)-1)
			END 
		
		exec spa_print 'SELECT ', @sql_pre, ', sequence, insert_or_delete  FROM #tempDeal order by row_id'
		EXEC('SELECT '+ @sql_pre +', sequence, insert_or_delete, counter  FROM #tempDeal order by row_id')
	END		
END

GO
