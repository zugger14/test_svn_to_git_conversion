

IF OBJECT_ID(N'spa_UpdateFromXml', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_UpdateFromXml]
GO 

/****** Object:  StoredProcedure [dbo].[spa_UpdateFromXml]    Script Date: 01/30/2012 01:30:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[spa_UpdateFromXml]  
 @xmlValue					TEXT,  
 @process_id				VARCHAR(200),  
 @call_from					VARCHAR(10)=NULL,-- call from settlement  
 @source_deal_header_id 	INT = NULL,  
 @not_confirmed				CHAR(1),  -- Deal Confirm Status  
 @deal_date					VARCHAR(20) = NULL,  
 @save						CHAR(1) = 'n' ,
 @deal_rules				INT = NULL,
 @called_update				INT = 0 ,
 @deal_status_deal			INT = NULL,
 @header_buy_sell_flag		CHAR(1) = NULL
 
AS  
 /*
declare @xmlValue varchar(max),  
 @process_id VARCHAR(200),  
 @call_from varchar(10),-- call from settlement  
 @source_deal_header_id INT ,  
 @not_confirmed CHAR(1),  -- Deal Confirm Status  
 @deal_date varchar(20) ,  
 @save CHAR(1)  
, @deal_rules				INT = NULL,
@called_update				INT = 0 ,
 @deal_status_deal			INT = NULL,
 @header_buy_sell_flag		CHAR(1) = NULL

  --select * from source_deal_header where source_deal_header_id= 2630
  
  
select  @xmlValue ='<Root><PSRecordset  term_start= "02/01/2014" term_end= "02/01/2014" buy_sell_flag= "s" location_id= "15" meter_id= "33" curve_id= "647" deal_volume= "900" deal_volume_frequency= "d" deal_volume_uom_id= "6" settlement_date= "02/01/2014" lock_deal_detail= "" status= "" source_deal_detail_id= "17271" Leg= "1" fixed_float_leg= "t" deal_detail_description= "Transportation->Schedule->FROM" pay_opposite= "N" contract_expiration_date= "02/01/2014" fixed_price_currency_id= "1" physical_financial_flag= "p" fixed_price= "" sequence= "1" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "02/01/2014" term_end= "02/01/2014" buy_sell_flag= "b" location_id= "5" meter_id= "4" curve_id= "3" deal_volume= "985" deal_volume_frequency= "d" deal_volume_uom_id= "6" settlement_date= "02/01/2014" lock_deal_detail= "" status= "" source_deal_detail_id= "17272" Leg= "2" fixed_float_leg= "t" deal_detail_description= "Transportation->Schedule->To" pay_opposite= "N" contract_expiration_date= "02/01/2014" fixed_price_currency_id= "1" physical_financial_flag= "p" fixed_price= "" sequence= "2" insert_or_delete= "normal" counter= "0"></PSRecordset></Root>'
SET @process_id=null  
set @call_from=null-- call from settlement  
SET @source_deal_header_id =2630 
set @not_confirmed ='y'  -- Deal Confirm Status  
set @deal_date= '02/01/2014'
set @save ='y'  
  
drop table #ztbl_xmlvalue  
drop table #tbl_olddata  
drop table #scs_error_handler  
drop table #handle_sp_return_update  
drop table #temp_to_insert
drop table #ztbl_final

drop table #temp_to_delete











--*/  

SET NOCOUNT ON  
DECLARE @sql								VARCHAR(8000),
		@tempdetailtable					VARCHAR(100),
		@user_login_id						VARCHAR(100),
		@convert_uom_id						INT,
		@convert_settlement_uom_id			INT,
		@count_new							INT,
		@count_unchanged					INT,
		@url								VARCHAR(5000), 
		@job_name							VARCHAR(100),
		@spa								VARCHAR(8000)   
 DECLARE @start_ts DATETIME
 SELECT  @start_ts = isnull(min(create_ts),GETDATE()) from import_data_files_audit where process_id = @process_id 
  
SET @convert_uom_id = 24  
SET @convert_settlement_uom_id = 27  
  
SET @user_login_id = dbo.FNADBUser()  
  
CREATE TABLE #handle_sp_return_update(  
   [ErrorCode]			VARCHAR(100) COLLATE DATABASE_DEFAULT ,  
   [MODULE]				VARCHAR(500) COLLATE DATABASE_DEFAULT ,  
   [Area]				VARCHAR(100) COLLATE DATABASE_DEFAULT ,  
   [Status]				VARCHAR(100) COLLATE DATABASE_DEFAULT ,  
   [MESSAGE]			VARCHAR(500) COLLATE DATABASE_DEFAULT ,  
   [Recommendation]		VARCHAR(500) COLLATE DATABASE_DEFAULT     
  )    
  
DECLARE @doc VARCHAR(1000)  
  
--Calculate MTM from Deal options. 0 means do not calculate, 1 calculate  
DECLARE @calculate_MTM_from_deal INT 
 SELECT    
  @calculate_MTM_from_deal =  var_value  
 FROM  
   adiha_default_codes_values  
 WHERE       
  (instance_no = 1) AND (default_code_id = 41) AND (seq_no = 1)  
  
 
--EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlValue  
  
DECLARE @format				VARCHAR(20)  
DECLARE @date_style			INT   
DECLARE @ztbl_fields		VARCHAR(MAX)
DECLARE @ztbl_fields_select VARCHAR(MAX)
  
SELECT @format = date_format
FROM   APPLICATION_USERS AU
       INNER JOIN REGION r
            ON  r.region_id = AU.region_id
            AND AU.user_login_id = dbo.FNADBUser()  
  
  
SET @date_style = CASE    
					  WHEN (@format = 'mm/dd/yyyy') THEN 102  
					  WHEN (@format = 'mm-dd-yyyy') THEN 110  
					  WHEN (@format = 'dd/mm/yyyy') THEN 103  
					  WHEN (@format = 'dd.mm.yyyy') THEN 104  
					  WHEN (@format = 'dd-mm-yyyy') THEN 105  
				  END  
  
 SELECT @ztbl_fields = COALESCE(@ztbl_fields + ',', '') + mfd.farrms_field_id,
		@ztbl_fields_select = COALESCE(@ztbl_fields_select + ',', '') +
		CASE 
             WHEN mfd.data_type = 'int' OR mfd.data_type = 'float' OR mfd.data_type = 'numeric' THEN 'NULLIF(' + mfd.farrms_field_id + ', '''') AS ' + mfd.farrms_field_id
		     ELSE mfd.farrms_field_id
		END 
FROM    maintain_field_template_detail mftd 
        INNER JOIN maintain_field_deal mfd
             ON  mftd.field_id = mfd.field_id
             AND mftd.field_group_id IS NULL
        INNER JOIN source_deal_header_template sdht
             ON  mftd.field_template_id = sdht.field_template_id
        INNER JOIN source_deal_header sdh
             ON  sdh.template_id = sdht.template_id
 WHERE  sdh.source_deal_header_id = @source_deal_header_id
        AND mftd.udf_or_system = 's'

DECLARE @ztbl_fields_xml		VARCHAR(MAX) 
DECLARE @ztbl_fields_datatype	VARCHAR(MAX)

SELECT @ztbl_fields_xml = COALESCE(+ @ztbl_fields_xml + ',', '') + mfd.farrms_field_id 
       + ' ' + ISNULL(
           CASE 
                WHEN mfd.data_type IN ('datetime', 'numeric') THEN 'varchar(100)'
                ELSE mfd.data_type
           END, ''
       ) 
       + CASE 
              WHEN mfd.data_type IN ('varchar', 'char') THEN '(100)'
              ELSE ''
         END
		+ ' ' + '''@' + mfd.farrms_field_id +''''
FROM    maintain_field_template_detail mftd 
       INNER JOIN maintain_field_deal mfd
            ON  mftd.field_id = mfd.field_id
            AND mftd.field_group_id IS NULL
       INNER JOIN source_deal_header_template sdht
            ON  mftd.field_template_id = sdht.field_template_id
       INNER JOIN source_deal_header sdh
            ON  sdh.template_id = sdht.template_id
WHERE  sdh.source_deal_header_id = @source_deal_header_id
       AND mftd.udf_or_system = 's'

SELECT @ztbl_fields_datatype = COALESCE(+ @ztbl_fields_datatype + ',', '') + mfd.farrms_field_id 
       + ' ' + ISNULL(
           CASE 
                WHEN mfd.data_type IN ('datetime', 'numeric') THEN 
                     'varchar(100)'
                ELSE mfd.data_type
           END, ''
       ) 
       + CASE 
              WHEN mfd.data_type IN ('varchar', 'char') THEN '(100)'
              ELSE ''
         END
FROM    maintain_field_template_detail mftd 
       INNER JOIN maintain_field_deal mfd
            ON  mftd.field_id = mfd.field_id
            AND mftd.field_group_id IS NULL
       INNER JOIN source_deal_header_template sdht
            ON  mftd.field_template_id = sdht.field_template_id
       INNER JOIN source_deal_header sdh
            ON  sdh.template_id = sdht.template_id
WHERE  sdh.source_deal_header_id = @source_deal_header_id
       AND mftd.udf_or_system = 's'

DECLARE @sql_xml            VARCHAR(MAX),
        @field_template_id  INT,
        @template_id        INT

SELECT @field_template_id = field_template_id,
       @template_id = sdh.template_id
FROM   dbo.source_deal_header_template t
       JOIN source_deal_header sdh
            ON  t.template_id = sdh.template_id
WHERE  sdh.source_deal_header_id = @source_deal_header_id

DECLARE @update_fields VARCHAR(8000)
			
SELECT @update_fields = MAX(srd.update_fields_detail)
FROM   source_deal_header sdh
       INNER JOIN source_deal_header_template sdht
            ON  sdh.template_id = sdht.template_id
       INNER JOIN status_rule_header srh
            ON  sdht.deal_rules = srh.status_rule_id
       INNER JOIN status_rule_detail srd
            ON  srh.status_rule_id = srd.status_rule_id
WHERE  sdh.source_deal_header_id = @source_deal_header_id
GROUP BY
       sdh.source_deal_header_id

DECLARE @all_columns VARCHAR(MAX)

CREATE TABLE #ztbl_xmlvalue (id INT  IDENTITY(1,1))

SET @sql = 'ALTER TABLE #ztbl_xmlvalue ADD ' + @ztbl_fields_datatype + ', deal_change_status_unique VARCHAR(100), sequence INT, counter INT'
EXEC spa_print @sql
EXEC(@sql)

CREATE TABLE #ztbl_final
(
	source_deal_detail_id     VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	source_deal_header_id     VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	term_start                VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	term_end                  VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	Leg                       VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	contract_expiration_date  VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	fixed_float_leg           VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	buy_sell_flag             VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	curve_id                  VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	fixed_price               VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	fixed_price_currency_id   VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	option_strike_price       VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	deal_volume               VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	deal_volume_frequency     VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	deal_volume_uom_id        VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	block_description         VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	deal_detail_description   VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	formula_id                VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	volume_left               VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	settlement_volume         VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	settlement_uom            VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	create_user               VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	create_ts                 VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	update_user               VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	update_ts                 VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	price_adder               VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	price_multiplier          VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	settlement_date           VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	day_count_id              VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	location_id               VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	meter_id                  VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	physical_financial_flag   VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	Booked                    VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	process_deal_status       VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	fixed_cost                VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	multiplier                VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	adder_currency_id         VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	fixed_cost_currency_id    VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	formula_currency_id       VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	price_adder2              VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	price_adder_currency2     VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	volume_multiplier2        VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	total_volume              VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	pay_opposite              VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	capacity                  VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	settlement_currency       VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	standard_yearly_volume    VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	formula_curve_id          VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	price_uom_id              VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	category                  VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	profile_code              VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	pv_party                  VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	deal_change_status_unique VARCHAR(100) COLLATE DATABASE_DEFAULT , --this column is to check for if deal detail is deleted or inserted from front end
	SEQUENCE				  VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	[lock_deal_detail] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
	[status] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL	,
	[counter] INT 								  		
)

DECLARE @qry1		NVARCHAR(MAX), 
		@param1		NVARCHAR(50),
		@idoc		INT 

-- update header_buy_sell flag if header_buy_sell flag is changed
DECLARE @header_buy_sell_change		CHAR(1)
DECLARE @is_update_required			CHAR(1)
DECLARE @old_header_buy_sell_flag	CHAR(1)

SET @header_buy_sell_change = 'n'

SELECT @old_header_buy_sell_flag = sdh.header_buy_sell_flag
FROM   source_deal_header sdh
WHERE  sdh.source_deal_header_id = @source_deal_header_id

SELECT @is_update_required = mftd.update_required
FROM maintain_field_template_detail mftd
INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
WHERE  mftd.field_template_id = @field_template_id
       AND mftd.udf_or_system = 's'
	   AND mfd.farrms_field_id = 'buy_sell_flag'
	   AND mfd.header_detail = 'd'

IF @old_header_buy_sell_flag <> @header_buy_sell_flag
	SET @header_buy_sell_change = 'y'

SET @ztbl_fields = @ztbl_fields + ', deal_change_status_unique, sequence, counter'
SELECT @qry1 ='
			INSERT INTO #ztbl_xmlvalue( ' + @ztbl_fields + ' )
			SELECT ' + @ztbl_fields_select + ', deal_change_status_unique, sequence, counter 
			FROM   OPENXML (@idoc, ''/Root/PSRecordset'',2)
			WITH ( ' + @ztbl_fields_xml + ',deal_change_status_unique VARCHAR(100) ''@deal_change_status_unique'',sequence VARCHAR(100) ''@sequence'',counter VARCHAR(100) ''@counter'')'

EXEC spa_print @qry1

SELECT @param1 = N'@idoc INT'
EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlValue
EXEC sp_executesql @qry1, @param1, @idoc
EXEC sp_xml_removedocument @idoc


-----------------------------------Start of Min and Max value validation-------------------------------------------------

DECLARE @IntVariable INT;
DECLARE @SQLString NVARCHAR(MAX);
DECLARE @ParmDefinition NVARCHAR(MAX);
DECLARE @return CHAR(1);

SET @IntVariable = 197;   
DECLARE @fields VARCHAR(1000)

SELECT 
       @fields = COALESCE(@fields + ',', ' ' ) + cast(mfd.farrms_field_id AS VARCHAR(30))
      
FROM   maintain_field_template_detail mftd
       INNER JOIN maintain_field_deal mfd
            ON  mftd.field_id = mfd.field_id
            AND mftd.udf_or_system = 's'
            AND mfd.header_detail = 'd'
WHERE  mftd.field_template_id = @field_template_id
       AND (NULLIF(mftd.min_value, 0) IS NOT NULL OR NULLIF(mftd.max_value, 0) IS NOT NULL)

SET @SQLString =  '
			DECLARE @error_field VARCHAR(100)
			DECLARE @min_value FLOAT
			DECLARE @max_value FLOAT
			DECLARE @msg VARCHAR(1000)
			
			SELECT @error_field = mfd.default_label,
					@min_value = mftd.min_value,
					@max_value = mftd.max_value
			FROM   maintain_field_template_detail mftd
			       INNER JOIN maintain_field_deal mfd
			            ON  mftd.field_id = mfd.field_id
			            AND mftd.udf_or_system = ''s''
			            AND mfd.header_detail = ''d''
			       INNER JOIN (
			                SELECT ' +  @fields + '
			                FROM   #ztbl_xmlvalue
			            )p
			            UNPIVOT(col_value FOR field IN (' +  @fields + ')) AS 
			            unpvt
			            ON  unpvt.field = mfd.farrms_field_id
			            AND (
			                    unpvt.col_value < mftd.min_value
			                    OR unpvt.col_value > mftd.max_value
			                )
			WHERE  mftd.field_template_id = ' + CAST(@field_template_id AS VARCHAR(10)) + '
			       AND (mftd.min_value IS NOT NULL OR mftd.max_value IS NOT NULL)
			
			IF @error_field IS NOT NULL 
				SET @msg = ''The value for '' + cast(@error_field as varchar(100)) + '' should be between '' + cast(@min_value as varchar(100)) + '' and '' + cast(@max_value as varchar(100)) + ''.'' 
			
			SET @max_titleOUT = 0
			IF  @msg IS NOT NULL 
			BEGIN
				EXEC spa_ErrorHandler -1, ''Error'', 
								''spa_InsertDealXmlBlotter'', ''DB Error'', 
								@msg, @msg						
				
				SET @max_titleOUT = 1	
			END
			
   '
   SET @ParmDefinition = N'@level tinyint, @max_titleOUT varchar(30) OUTPUT';
EXEC spa_print '---------------------------------------------------------------------------------------'

EXECUTE sp_executesql @SQLString, @ParmDefinition, @level = @IntVariable, @max_titleOUT=@return OUTPUT;

--Return if column value is not between min and max value
IF @return = 1
    RETURN 

-----------------------------------End of Min and Max value validation-------------------------------------------------


SET @sql = 'INSERT INTO #ztbl_final ( ' + @ztbl_fields + ')
			SELECT ' + @ztbl_fields + ' FROM #ztbl_xmlvalue'


EXEC spa_print @sql
EXEC(@sql)

UPDATE #ztbl_final SET capacity = NULL WHERE capacity = ''  
UPDATE #ztbl_final SET curve_id = NULL WHERE curve_id = ''  
UPDATE #ztbl_final SET price_adder = NULL WHERE price_adder = ''  
UPDATE #ztbl_final SET price_adder2 = NULL WHERE price_adder2 = ''  
UPDATE #ztbl_final SET fixed_price = NULL WHERE fixed_price = ''  
UPDATE #ztbl_final SET location_id = NULL WHERE physical_financial_flag = 'f'  
UPDATE #ztbl_final SET fixed_cost = NULL WHERE fixed_cost = ''  
UPDATE #ztbl_final SET option_strike_price = NULL WHERE option_strike_price = ''  
UPDATE #ztbl_final SET volume_multiplier2 = NULL WHERE volume_multiplier2 = ''  
UPDATE #ztbl_final SET multiplier = NULL WHERE multiplier = ''  
UPDATE #ztbl_final SET price_multiplier = NULL WHERE price_multiplier = ''
UPDATE #ztbl_final SET settlement_currency = NULL WHERE settlement_currency = ''
UPDATE #ztbl_final SET standard_yearly_volume = NULL WHERE standard_yearly_volume = ''  
UPDATE #ztbl_final SET price_uom_id = NULL WHERE price_uom_id = ''  
UPDATE #ztbl_final SET category = NULL WHERE category = ''
UPDATE #ztbl_final SET profile_code = NULL WHERE profile_code = ''
UPDATE #ztbl_final SET pv_party = NULL WHERE pv_party = ''  
UPDATE #ztbl_final SET leg = 1 WHERE leg = '' OR leg IS NULL 
UPDATE #ztbl_final SET pay_opposite = 'Y' WHERE pay_opposite <> 'n' OR pay_opposite IS NULL


IF @header_buy_sell_change = 'y' AND @is_update_required = 'n'
BEGIN
	UPDATE t   
	SET    t.buy_sell_flag = CASE 
	                            WHEN sdd.buy_sell_flag = 'b' THEN 's'
	                            ELSE 'b'
	                       END
	FROM #ztbl_final t
           INNER JOIN source_deal_detail sdd
                ON  sdd.source_deal_detail_id = t.source_deal_detail_id
END

DECLARE @source_deal_detail_tmp VARCHAR(300)  
	
IF @process_id IS NOT NULL AND @process_id <> 'undefined'
BEGIN
    SET @user_login_id = dbo.FNADBUser()  
    SET @source_deal_detail_tmp = dbo.FNAProcessTableName('paging_sourcedealtemp', @user_login_id, @process_id)
END
ELSE
BEGIN
    SET @source_deal_detail_tmp = 'source_deal_detail'
END
------ Inserted added and deleted row into  #temp_to_insert and #temp_to_delete respectively------------------------
SELECT 
	   zf.source_deal_detail_id,
	   @source_deal_header_id source_deal_header_id,
       zf.term_start,
       zf.term_end,
       zf.Leg,
       zf.contract_expiration_date,
       zf.fixed_float_leg,
       zf.buy_sell_flag,
       zf.curve_id,
       zf.fixed_price,
       zf.fixed_price_currency_id,
       zf.option_strike_price,
       zf.deal_volume,
       zf.deal_volume_frequency,
       zf.deal_volume_uom_id,
       zf.block_description,
       zf.deal_detail_description,
       zf.formula_id,
       zf.volume_left,
       zf.settlement_volume,
       zf.settlement_uom,
       zf.create_user,
       zf.create_ts,
       zf.update_user,
       zf.update_ts,
       zf.price_adder,
       zf.price_multiplier,
       zf.settlement_date,
       zf.day_count_id,
       zf.location_id,
       zf.meter_id,
       zf.physical_financial_flag,
       zf.Booked,
       zf.process_deal_status,
       zf.fixed_cost,
       zf.multiplier,
       zf.adder_currency_id,
       zf.fixed_cost_currency_id,
       zf.formula_currency_id,
       zf.price_adder2,
       zf.price_adder_currency2,
       zf.volume_multiplier2,
       zf.pay_opposite,
       zf.capacity,
       zf.settlement_currency,
       zf.standard_yearly_volume,
       zf.formula_curve_id,
       zf.price_uom_id,
       zf.category,
       zf.profile_code,
       zf.pv_party,
       zf.sequence,
       zf.deal_change_status_unique insert_or_delete,
       zf.[counter]
       INTO #temp_to_insert
FROM   #ztbl_final zf
WHERE  zf.deal_change_status_unique = 'added_row'


SET @sql = 'INSERT INTO #temp_to_insert (  
					   source_deal_detail_id, 
					   source_deal_header_id,
					   term_start,
					   term_end,
					   Leg,
					   contract_expiration_date,
					   fixed_float_leg,
					   buy_sell_flag,
					   curve_id,
					   fixed_price,
					   fixed_price_currency_id,
					   option_strike_price,
					   deal_volume,
					   deal_volume_frequency,
					   deal_volume_uom_id,
					   block_description,
					   deal_detail_description,
					   formula_id,
					   --volume_left,
					   settlement_volume,
					   --settlement_uom,
					   --create_user,
					   --create_ts,
					   --update_user,
					   --update_ts,
					   price_adder,
					   price_multiplier,
					   settlement_date,
					   day_count_id,
					   location_id,
					   meter_id,
					   physical_financial_flag,
					   --Booked,
					   --process_deal_status,
					   fixed_cost,
					   multiplier,
					   adder_currency_id,
					   fixed_cost_currency_id,
					   formula_currency_id,
					   price_adder2,
					   price_adder_currency2,
					   volume_multiplier2,
					   pay_opposite,
					   capacity,
					   settlement_currency,
					   standard_yearly_volume,
					   formula_curve_id,
					   price_uom_id,
					   category,
					   profile_code,
					   pv_party,
					   sequence,
					   insert_or_delete,
					   counter
					)
					SELECT
					   sddt.source_deal_detail_id,
					   ' + CAST(@source_deal_header_id AS VARCHAR(10)) + ' AS source_deal_header_id,
					   sddt.term_start,
					   sddt.term_end,
					   sddt.Leg,
					   sddt.contract_expiration_date,
					   sddt.fixed_float_leg,
					   sddt.buy_sell_flag,
					   sddt.curve_id,
					   sddt.fixed_price,
					   sddt.fixed_price_currency_id,
					   sddt.option_strike_price,
					   sddt.deal_volume,
					   sddt.deal_volume_frequency,
					   sddt.deal_volume_uom_id,
					   sddt.block_description,
					   sddt.deal_detail_description,
					   sddt.formula_id,
					   --sddt.volume_left,
					   sddt.settlement_volume,
					   --sddt.settlement_uom,
					   --sddt.create_user,
					   --sddt.create_ts,
					   --sddt.update_user,
					   --sddt.update_ts,
					   sddt.price_adder,
					   sddt.price_multiplier,
					   sddt.settlement_date,
					   sddt.day_count_id,
					   sddt.location_id,
					   sddt.meter_id,
					   sddt.physical_financial_flag,
					   --sddt.Booked,
					   --sddt.process_deal_status,
					   sddt.fixed_cost,
					   sddt.multiplier,
					   sddt.adder_currency_id,
					   sddt.fixed_cost_currency_id,
					   sddt.formula_currency_id,
					   sddt.price_adder2,
					   sddt.price_adder_currency2,
					   sddt.volume_multiplier2,
					   sddt.pay_opposite,
					   sddt.capacity,
					   sddt.settlement_currency,
					   sddt.standard_yearly_volume,
					   sddt.formula_curve_id,
					   sddt.price_uom_id,
					   sddt.category,
					   sddt.profile_code,
					   sddt.pv_party,
					   sddt.sequence,
					   sddt.insert_or_delete,
					   sddt.counter					
					FROM ' + @source_deal_detail_tmp + ' sddt
					LEFT JOIN #temp_to_insert tti on sddt.source_deal_detail_id = tti.source_deal_detail_id
					WHERE sddt.insert_or_delete = ''added_row''
					      AND tti.source_deal_detail_id IS NULL'
		
   
EXEC(@sql)

SELECT 
	   zf.source_deal_detail_id,
	   @source_deal_header_id source_deal_header_id,
       zf.term_start,
       zf.term_end,
       zf.Leg,
       zf.contract_expiration_date,
       zf.fixed_float_leg,
       zf.buy_sell_flag,
       zf.curve_id,
       zf.fixed_price,
       zf.fixed_price_currency_id,
       zf.option_strike_price,
       zf.deal_volume,
       zf.deal_volume_frequency,
       zf.deal_volume_uom_id,
       zf.block_description,
       zf.deal_detail_description,
       zf.formula_id,
       zf.volume_left,
       zf.settlement_volume,
       zf.settlement_uom,
       zf.create_user,
       zf.create_ts,
       zf.update_user,
       zf.update_ts,
       zf.price_adder,
       zf.price_multiplier,
       zf.settlement_date,
       zf.day_count_id,
       zf.location_id,
       zf.meter_id,
       zf.physical_financial_flag,
       zf.Booked,
       zf.process_deal_status,
       zf.fixed_cost,
       zf.multiplier,
       zf.adder_currency_id,
       zf.fixed_cost_currency_id,
       zf.formula_currency_id,
       zf.price_adder2,
       zf.price_adder_currency2,
       zf.volume_multiplier2,
       zf.pay_opposite,
       zf.capacity,
       zf.settlement_currency,
       zf.standard_yearly_volume,
       zf.formula_curve_id,
       zf.price_uom_id,
       zf.category,
       zf.profile_code,
       zf.pv_party,
       zf.sequence,
       zf.deal_change_status_unique insert_or_delete,
       zf.[counter]
       INTO #temp_to_delete
FROM   #ztbl_final zf
WHERE  zf.deal_change_status_unique = 'deleted_row'

SET @sql = 'INSERT INTO #temp_to_delete (  
					   source_deal_detail_id, 
					   source_deal_header_id,
					   term_start,
					   term_end,
					   Leg,
					   contract_expiration_date,
					   fixed_float_leg,
					   buy_sell_flag,
					   curve_id,
					   fixed_price,
					   fixed_price_currency_id,
					   option_strike_price,
					   deal_volume,
					   deal_volume_frequency,
					   deal_volume_uom_id,
					   block_description,
					   deal_detail_description,
					   formula_id,
					   --volume_left,
					   settlement_volume,
					   --settlement_uom,
					   --create_user,
					   --create_ts,
					   --update_user,
					   --update_ts,
					   price_adder,
					   price_multiplier,
					   settlement_date,
					   day_count_id,
					   location_id,
					   meter_id,
					   physical_financial_flag,
					   --Booked,
					   --process_deal_status,
					   fixed_cost,
					   multiplier,
					   adder_currency_id,
					   fixed_cost_currency_id,
					   formula_currency_id,
					   price_adder2,
					   price_adder_currency2,
					   volume_multiplier2,
					   pay_opposite,
					   capacity,
					   settlement_currency,
					   standard_yearly_volume,
					   formula_curve_id,
					   price_uom_id,
					   category,
					   profile_code,
					   pv_party,
					   sequence,
					   insert_or_delete,
					   [counter]
					)
					SELECT
					   sddt.source_deal_detail_id,
					   ' + CAST(@source_deal_header_id AS VARCHAR(10)) + ' AS source_deal_header_id,
					   sddt.term_start,
					   sddt.term_end,
					   sddt.Leg,
					   sddt.contract_expiration_date,
					   sddt.fixed_float_leg,
					   sddt.buy_sell_flag,
					   sddt.curve_id,
					   sddt.fixed_price,
					   sddt.fixed_price_currency_id,
					   sddt.option_strike_price,
					   sddt.deal_volume,
					   sddt.deal_volume_frequency,
					   sddt.deal_volume_uom_id,
					   sddt.block_description,
					   sddt.deal_detail_description,
					   sddt.formula_id,
					   --sddt.volume_left,
					   sddt.settlement_volume,
					   --sddt.settlement_uom,
					   --sddt.create_user,
					   --sddt.create_ts,
					   --sddt.update_user,
					   --sddt.update_ts,
					   sddt.price_adder,
					   sddt.price_multiplier,
					   sddt.settlement_date,
					   sddt.day_count_id,
					   sddt.location_id,
					   sddt.meter_id,
					   sddt.physical_financial_flag,
					   --sddt.Booked,
					   --sddt.process_deal_status,
					   sddt.fixed_cost,
					   sddt.multiplier,
					   sddt.adder_currency_id,
					   sddt.fixed_cost_currency_id,
					   sddt.formula_currency_id,
					   sddt.price_adder2,
					   sddt.price_adder_currency2,
					   sddt.volume_multiplier2,
					   sddt.pay_opposite,
					   sddt.capacity,
					   sddt.settlement_currency,
					   sddt.standard_yearly_volume,
					   sddt.formula_curve_id,
					   sddt.price_uom_id,
					   sddt.category,
					   sddt.profile_code,
					   sddt.pv_party,
					   sddt.sequence,
					   sddt.insert_or_delete,
					   sddt.[counter]					
					FROM ' + @source_deal_detail_tmp + ' sddt
					LEFT JOIN #temp_to_delete ttd on sddt.source_deal_detail_id = ttd.source_deal_detail_id
					WHERE sddt.insert_or_delete = ''deleted_row''
					      AND ttd.source_deal_detail_id IS NULL'


EXEC(@sql)



------ END OF Inserted added and deleted row into  #temp_to_insert and #temp_to_delete respectively------------------------


SELECT source_deal_detail_id,
       item1,
       u.item INTO #fields
FROM   (
           SELECT source_deal_detail_id,
                  ISNULL(term_start, '1900-1-1')term_start,
                  ISNULL(term_end, '1900-1-1') term_end,
                  ISNULL(leg, -1) leg,
                  ISNULL(contract_expiration_date, -1) contract_expiration_date,
                  ISNULL(fixed_float_leg, -1) fixed_float_leg,
                  ISNULL(buy_sell_flag, -1) buy_sell_flag,
                  ISNULL(physical_financial_flag, -1) physical_financial_flag,
                  ISNULL(location_id, -1) location_id,
                  ISNULL(curve_id, -1) curve_id,
                  ISNULL(deal_volume, -1) deal_volume,
                  ISNULL(deal_volume_frequency, -1) deal_volume_frequency,
                  ISNULL(deal_volume_uom_id, -1) deal_volume_uom_id,
                  ISNULL(capacity, -1) capacity,
                  ISNULL(fixed_price, -1) fixed_price,
                  ISNULL(fixed_cost, -1) fixed_cost,
                  ISNULL(fixed_cost_currency_id, -1) fixed_cost_currency_id,
                  ISNULL(formula_id, -1) formula_id,
                  ISNULL(formula_currency_id, -1) formula_currency_id,
                  ISNULL(option_strike_price, -1) option_strike_price,
                  ISNULL(price_adder, -1) price_adder,
                  ISNULL(adder_currency_id, -1) adder_currency_id,
                  ISNULL(multiplier, -1) multiplier,
                  ISNULL(price_multiplier, -1) price_multiplier,
                  ISNULL(fixed_price_currency_id, -1) fixed_price_currency_id,
                  ISNULL(price_adder2, -1) price_adder2,
                  ISNULL(price_adder_currency2, -1) price_adder_currency2,
                  ISNULL(volume_multiplier2, -1) volume_multiplier2,
                  ISNULL(meter_id, -1) meter_id,
                  ISNULL(pay_opposite, -1) pay_opposite,
                  ISNULL(settlement_date, -1) settlement_date,
                  ISNULL(block_description, -1) block_description,
                  ISNULL(settlement_currency, -1) settlement_currency,
                  ISNULL(standard_yearly_volume, -1) standard_yearly_volume,
                  ISNULL(price_uom_id, -1) price_uom_id,
                  ISNULL(category, -1) category,
                  ISNULL(profile_code, -1) profile_code,
                  ISNULL(pv_party, -1) pv_party
           FROM   #ztbl_final
       ) zx
       UNPIVOT(
           item FOR item1 IN (term_start, term_end, leg, 
                             contract_expiration_date, fixed_float_leg, 
                             buy_sell_flag, physical_financial_flag, location_id, 
                             curve_id, deal_volume, deal_volume_frequency, 
                             deal_volume_uom_id, capacity, fixed_price, 
                             fixed_cost, fixed_cost_currency_id, formula_id, 
                             formula_currency_id, option_strike_price, 
                             price_adder, adder_currency_id, multiplier, 
                             price_multiplier, fixed_price_currency_id, 
                             price_adder2, price_adder_currency2, 
                             volume_multiplier2, meter_id, pay_opposite, 
                             settlement_date, block_description, 
                             settlement_currency, standard_yearly_volume, 
                             price_uom_id, category, profile_code, pv_party)
       )
U 

IF OBJECT_ID('tempdb..#fields_final') IS NOT NULL 
DROP TABLE #fields_final

CREATE TABLE #fields_final
(
	item            VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	val             VARCHAR(1000) COLLATE DATABASE_DEFAULT ,
	deal_detail_id  INT
)
INSERT INTO #fields_final
  (
    item,
    val,
    deal_detail_id
  )
SELECT f.item1,
       f.item,
       f.source_deal_detail_id
FROM   #fields f
       INNER JOIN dbo.splitcommaseperatedvalues(@update_fields) scsv
			ON f.item1 = scsv.item 

SELECT '(' + CASE 
                  WHEN item IN ('term_start', 'term_end') THEN 'isnull(' + item + ',''1900-1-1'')'
                  ELSE 'ISNULL(' + item + ',-1)'
             END + ' <> ''' + LTRIM(RTRIM(val)) + ''' AND source_deal_detail_id = ' + CAST(deal_detail_id AS VARCHAR(15)) + 
       ')' col
       INTO #fields_list
FROM   #fields_final 

DECLARE @update_fields_final VARCHAR(MAX), @call_update INT 
SET @call_update = 0

SELECT @update_fields_final = STUFF(
           (
               (
                   SELECT ' OR ' + CAST(col AS VARCHAR(MAX))
                   FROM   #fields_list FOR XML PATH(''),
                          ROOT('MyString'),
                          TYPE
				 ).value('/MyString[1]','varchar(max)')
           ),
           1,
           4,
           ''
       ) 

DECLARE @sql1 VARCHAR(MAX)

CREATE TABLE #RESULT(id INT)
SET @sql1 = 'INSERT INTO #result SELECT 1 FROM source_deal_detail WHERE (' + @update_fields_final + ') '
EXEC spa_print @sql1 
EXEC(@sql1)

IF EXISTS(SELECT 1 FROM #RESULT)
BEGIN
	SET @call_update = 1
END

DECLARE @udf_field            VARCHAR(MAX),
        @udf_xml_field        VARCHAR(MAX),
        @udf_add_field        VARCHAR(MAX),
        @udf_add_field_label  VARCHAR(MAX),
        @udf_update           VARCHAR(MAX),
        @udf_from_ut_table    VARCHAR(MAX)

SELECT @udf_field = COALESCE(@udf_field + ',', '') + 'UDF___' + CAST(udft.udf_user_field_id AS VARCHAR),
       @udf_add_field = COALESCE(@udf_add_field + ',', '') + 'UDF___' + CAST(udft.udf_user_field_id AS VARCHAR) 
       + ' varchar(150)',
       @udf_xml_field = COALESCE(@udf_xml_field + ',', '') + 'UDF___' + CAST(udft.udf_user_field_id AS VARCHAR) 
       + ' varchar(150) ''@udf___' + CAST(udft.udf_user_field_id AS VARCHAR) + 
       '''',
       @udf_add_field_label = COALESCE(@udf_add_field_label + ',', '') + '[UDF___' + CAST(udft.udf_user_field_id AS VARCHAR) + ']',
       @udf_from_ut_table = COALESCE(@udf_from_ut_table + ',', '') + ' ut.[UDF___' + CAST(udft.udf_user_field_id AS VARCHAR) + ']',
       @udf_update = COALESCE(@udf_update + ',', '') + 'sddt.[UDF___' + CAST(udft.udf_user_field_id AS VARCHAR) + '] = ut.UDF___' + CAST(udft.udf_user_field_id AS VARCHAR) 
FROM   maintain_field_template_detail d
       JOIN user_defined_fields_template udf_temp
            ON  d.field_id = udf_temp.udf_template_id
       JOIN user_defined_deal_fields_template udft
            ON  udft.udf_user_field_id = udf_temp.udf_template_id
            AND udft.template_id = @template_id
WHERE  udf_or_system = 'u'
       AND udf_temp.udf_type = 'd'
       AND field_template_id = @field_template_id
       AND udft.leg = 1
       
SET @udf_field = @udf_field + ',source_deal_detail_id'
SET @udf_xml_field = @udf_xml_field + ',source_deal_detail_id int ''@source_deal_detail_id'''
SET @udf_add_field = @udf_add_field + ',source_deal_detail_id int'
SET @udf_add_field_label = @udf_add_field_label + ',source_deal_detail_id' 
SET @udf_from_ut_table = @udf_from_ut_table + ', ut.source_deal_detail_id' 

DECLARE @udf_table VARCHAR(200)
SET @udf_table = dbo.FNAProcessTableName('deal_detail_udf', @user_login_id, REPLACE(NEWID(), '-', '_'))
	
DECLARE @idoc2 INT
DECLARE @qry NVARCHAR(4000), @param NVARCHAR(50)
SELECT @qry = 'SELECT ' + @udf_field + ' INTO ' + @udf_table + '
				FROM   OPENXML (@idoc2, ''/Root/PSRecordset'',2)
				WITH ( '+@udf_xml_field+')'

SELECT @param = N'@idoc2 INT'
EXEC sp_xml_preparedocument @idoc2 OUTPUT, @xmlValue
EXEC sp_executesql @qry, @param, @idoc2
EXEC sp_xml_removedocument @idoc2
  
DECLARE @deal_status_from INT

SELECT @deal_status_from = sdh.deal_status
FROM   source_deal_header sdh
WHERE  sdh.source_deal_header_id = @source_deal_header_id 


--PRINT '-----------------------------------------------------'
-- EXEC spa_print  @qry
	
IF dbo.FNAAppAdminRoleCheck(dbo.FNADBUser()) = 0 AND @deal_rules IS NOT NULL AND @deal_status_from <> @deal_status_deal --dbo.FNADBUser() <> (SELECT dbo.FNAAppAdminID())
BEGIN
	IF NOT EXISTS (
		SELECT dsp.deal_status_ID
		FROM   deal_status_privileges dsp
			   LEFT JOIN application_role_user aru ON  dsp.role_id = aru.role_id
			   LEFT JOIN application_users au ON  aru.user_login_id = au.user_login_id
			   INNER JOIN deal_status_privilege_mapping dspm ON  dspm.deal_status_privilege_mapping_id = dsp.deal_status_ID
		WHERE  (dsp.[user_id] = dbo.FNADBUser() OR au.user_login_id = dbo.FNADBUser() )
			   AND (dspm.from_status_value_id = @deal_status_from OR dspm.from_status_value_id IS NULL)
		GROUP BY dspm.to_status_value_id, dsp.deal_status_ID
		HAVING dspm.to_status_value_id IN (@deal_status_deal) OR dspm.to_status_value_id IS NULL
	)
	BEGIN
		EXEC spa_ErrorHandler -1,
			 'Source Deal Header table',
			 'spa_sourcedealheader',
			 'DB Error',
			 'The deal status selected does not have privilege for the operation.',
			 'The deal status selected does not have privilege for the operation.'
		RETURN 
	END
END 
					

DECLARE @report_position_deals		VARCHAR(300)
DECLARE @report_position_process_id VARCHAR(500) 
 
SET @report_position_process_id = REPLACE(NEWID(),'-','_')   
SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@report_position_process_id)  

EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')  

IF NOT EXISTS (  
 SELECT 1 FROM source_deal_detail sdd   
	 INNER JOIN #ztbl_final z  
		  ON  dbo.FNAStdDate(z.term_start)  = sdd.term_start   
		  AND dbo.FNAStdDate(z.term_end) = sdd.term_end   
		  AND CAST(z.leg AS INT) = sdd.leg   
		  AND ISNULL(sdd.buy_sell_flag ,'b')  = ISNULL(z.buy_sell_flag ,'b') 
		  AND ISNULL(sdd.formula_id,-1)=ISNULL(CAST(z.formula_id AS INT) ,'-1')
		  AND ISNULL(sdd.curve_id,-1)=ISNULL(CAST(z.curve_id AS INT),'-1')  
		  AND ISNULL(sdd.location_id,-1)=ISNULL(CAST(z.location_id AS INT) ,'-1')
		  AND ISNULL(sdd.deal_volume,0) = ISNULL(CAST(z.deal_volume AS NUMERIC(38,20)),'0')  
		  AND ISNULL(sdd.deal_volume_frequency,'m') = ISNULL(z.deal_volume_frequency,'m')  
		  AND ISNULL(sdd.multiplier,1) = ISNULL(CAST(z.multiplier AS NUMERIC(38,20)),'1')  
		  AND ISNULL(sdd.volume_multiplier2,1) = ISNULL(CAST(z.volume_multiplier2 AS NUMERIC(38,20)) , '1')  
		  AND ISNULL(sdd.pay_opposite,'x') = ISNULL(z.pay_opposite,'x')  
 WHERE sdd.source_deal_header_id = @source_deal_header_id   
)  
BEGIN   
 SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) SELECT ' + CAST(@source_deal_header_id AS VARCHAR) + ',''u'''  
 EXEC spa_print @sql   
 EXEC (@sql)   
END  


--#########################################  
-- Logic Added to see if the deal is already assigned or the updated deal is an assigned deal.  
--#########################################  
  
--##### Fisrt check to see if the Deal has been manually assigned and volume is changed. If so then Give error  
    
    
IF EXISTS  
 (  
 SELECT *   
 FROM #ztbl_final tmp  
		INNER JOIN source_deal_detail sdd ON CAST(tmp.source_deal_detail_id AS INT)=  sdd.source_deal_detail_id  
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id  
		INNER JOIN assignment_audit assign ON assign.source_deal_header_id_from = sdd.source_deal_detail_id  
		LEFT JOIN rec_generator rg ON  rg.generator_id = sdh.generator_id   
		LEFT JOIN rec_generator_assignment gen_assign  
			ON rg.generator_id = gen_assign.generator_id AND  
			 ((sdd.term_start BETWEEN gen_assign.term_start AND gen_assign.term_end) OR  
			 (sdd.term_end BETWEEN gen_assign.term_start AND gen_assign.term_end))    
 WHERE 1 = 1  
    AND sdd.deal_volume <> sdd.volume_left AND sdd.deal_volume > 0    
    AND assign.assigned_by <> 'Auto Assigned'    
    AND assign.assigned_volume <> 0  
 )  
 BEGIN
	 SELECT   
		@source_deal_header_id = sdd.source_deal_header_id   
	 FROM source_deal_detail sdd   
		 INNER JOIN #ztbl_final z  
			ON CAST(z.source_deal_detail_id AS INT)= sdd.source_deal_detail_id   
	    
	   SET @url = '<a href="../../dev/spa_html.php?spa=exec spa_create_lifecycle_of_recs '''+ dbo.FNADateFormat(GETDATE()) +''',NULL,'+CAST(@source_deal_header_id AS VARCHAR)+'">Click here...</a>'  
	  
	   SELECT	'Error' ErrorCode, 
				'Source Deal Detail' MODULE,   
				'spa_UpdateFromXml' Area, 
				'Error' Status,   
				'Deal ID: ' + CAST(@source_deal_header_id AS VARCHAR) + ' is already assigned, Please remove all the assigned deals first to Update .<br> Please view this report ' + @url MESSAGE, 
				'' Recommendation  
	  RETURN  
 END  

--## Check to see if the deal is assigned deal. If so then give error  
IF EXISTS  
 (SELECT * FROM #ztbl_final tmp  
     INNER JOIN source_deal_detail sdd ON CAST(tmp.source_deal_detail_id AS INT) = sdd.source_deal_detail_id  
     INNER JOIN assignment_audit assign ON assign.source_deal_header_id = sdd.source_deal_detail_id  
 )  
 BEGIN  
  
  
  SELECT @source_deal_header_id=source_deal_header_id   
    FROM source_deal_detail sdd WHERE source_deal_detail_id IN(SELECT source_deal_detail_id FROM #ztbl_final)  
  
    SET @url='<a href="../../dev/spa_html.php?spa=exec spa_create_lifecycle_of_recs '''+ dbo.FNADateFormat(GETDATE()) +''',NULL,'+CAST(@source_deal_header_id AS VARCHAR)+'">Click here...</a>'  
    SELECT  'Error' ErrorCode, 
			'Source Deal Detail' MODULE,   
			'spa_UpdateFromXml' Area, 
			'Error' Status,   
			'Deal ID: '+ CAST(@source_deal_header_id AS VARCHAR) + ' is an assigned deal. You cannot update the assigned deal ' MESSAGE, 
			'' Recommendation  
  RETURN   
  
 END  
----#################################  
 

CREATE TABLE #tbl_olddata  
(  
	source_deal_detail_id		INT,  
	term_start					DATETIME,  
	term_end					DATETIME,  
	leg							INT,  
	contract_expiration_date	DATETIME,  
	fixed_float_leg				CHAR(1) COLLATE DATABASE_DEFAULT ,  
	buy_sell_flag				CHAR(1) COLLATE DATABASE_DEFAULT ,  
	physical_financial_flag		VARCHAR(100) COLLATE DATABASE_DEFAULT ,  
	location_id					INT,  
	curve_id					VARCHAR(100) COLLATE DATABASE_DEFAULT ,  
	deal_volume					NUMERIC(30,10),  
	deal_volume_frequency		CHAR(1) COLLATE DATABASE_DEFAULT ,  
	deal_volume_uom_id			VARCHAR(100) COLLATE DATABASE_DEFAULT ,  
	capacity					FLOAT,  
	fixed_price					NUMERIC(30,10),  
	fixed_cost					FLOAT,  
	fixed_cost_currency_id		INT,  
	formula_id					VARCHAR(100) COLLATE DATABASE_DEFAULT ,  
	formula_currency_id			INT,  
	option_strike_price			FLOAT,      
	price_adder					FLOAT,  
	adder_currency_id			INT,  
	price_multiplier			FLOAT,  
	multiplier					FLOAT,  
	fixed_price_currency_id		VARCHAR(100) COLLATE DATABASE_DEFAULT ,  
	price_adder2				FLOAT,  
	price_adder_currency2		INT,  
	volume_multiplier2			FLOAT,  
	meter_id					INT,  
	pay_opposite				VARCHAR(100) COLLATE DATABASE_DEFAULT ,  
	settlement_date				DATETIME,  
	block_description			VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	price_uom_id				INT,  
	category					INT,
	profile_code				INT, 
	pv_party					INT,
	lock_deal_detail			CHAR(1) COLLATE DATABASE_DEFAULT ,
	[status]					INT,
	[counter] INT
)  
   
      
 
   
SET @sql=  
		'  
		insert into #tbl_olddata(source_deal_detail_id ,  
							term_start,  
							term_end  ,  
							leg,  
							contract_expiration_date ,  
							fixed_float_leg ,  
							buy_sell_flag  ,  
							physical_financial_flag,  
							location_id ,  
							curve_id  ,  
							deal_volume ,  
							deal_volume_frequency ,  
							deal_volume_uom_id,  
							capacity ,  
							fixed_price,  
							fixed_cost ,  
							fixed_cost_currency_id ,  
							formula_id ,  
							formula_currency_id ,  
							option_strike_price  ,      
							price_adder  ,  
							adder_currency_id ,  
							price_multiplier  ,  
							multiplier ,  
							fixed_price_currency_id ,  
							price_adder2  ,  
							price_adder_currency2 ,  
							volume_multiplier2  ,  
							meter_id ,  
							pay_opposite ,  
							settlement_date  ,  
							block_description  ,
							price_uom_id   ,  
							category    ,
							profile_code  , 
							pv_party,
							lock_deal_detail,
							status,
							counter
							)  
		select  
		t.source_deal_detail_id,  
		t.term_start,  
		t.term_end,  
		t.leg, --   
		t.contract_expiration_date,  
		t.fixed_float_leg, --  
		t.buy_sell_flag,  

		case   
		when t.physical_financial_flag=''Physical'' then ''p''   
		when t.physical_financial_flag=''p'' then ''p''   
		else ''f'' end,  
		t.location_id,  

		CASE WHEN ISNUMERIC(t.curve_id)=1 THEN t.curve_id ELSE NULL END,  
		'+ CASE WHEN @call_from='s' THEN ' floor(t.deal_volume * conv.conversion_factor) ' ELSE ' t.deal_volume ' END +',  
		--deal_volume=floor(z.deal_volume * '+ CASE WHEN @call_from='s' THEN ' conv.conversion_factor ' ELSE '1' END +'),  
		t.deal_volume_frequency,  
		'+ CASE WHEN @call_from='s' THEN CAST(@convert_uom_id AS VARCHAR) ELSE 't.deal_volume_uom_id' END +',  
		--deal_volume_uom_id=z.deal_volume_uom_id,  
		cast(t.capacity as numeric(38,20)),  
		CAST(t.fixed_price AS NUMERIC(38,20)),  
		CAST(t.fixed_cost AS NUMERIC(38,20)),  
		CASE WHEN ISNUMERIC(t.fixed_cost_currency_id)=1 THEN t.fixed_cost_currency_id ELSE NULL END,  
		CASE WHEN ISNUMERIC(t.formula_id)=0 THEN NULL ELSE t.formula_id END,  
		CASE WHEN ISNUMERIC(t.formula_currency_id)=1 THEN t.formula_currency_id ELSE NULL END,  
		CAST(t.option_strike_price AS NUMERIC(38,20)),  
		t.price_adder,  
		CASE WHEN ISNUMERIC(t.adder_currency_id)=1 THEN t.adder_currency_id ELSE NULL END,  
		case when isnull(t.price_multiplier,-1)=-1 then NULL else t.price_multiplier end,  
		case when isnull(t.multiplier,-1)=-1 then NULL else t.multiplier end,  
		CASE WHEN ISNUMERIC(t.fixed_price_currency_id)=1 THEN t.fixed_price_currency_id ELSE NULL END,  
		t.price_adder2,  
		CASE WHEN ISNUMERIC(t.price_adder_currency2)=1 THEN t.price_adder_currency2 ELSE NULL END,  
		case when isnull(t.volume_multiplier2,-1)=-1 then NULL else t.volume_multiplier2 end,  
		t.meter_id,  
		t.pay_opposite,  
		t.settlement_date,  
		t.block_description ,
		t.price_uom_id ,  
		t.category   ,
		t.profile_code  , 
		t.pv_party,  
		t.lock_deal_detail,
		t.status,
		z.counter
	FROM  #ztbl_final z   
		join source_deal_detail t on t.source_deal_detail_id = cast(z.source_deal_detail_id as int)  
		left join rec_volume_unit_conversion Conv ON Conv.from_source_uom_id = cast(z.deal_volume_uom_id as int)             
			AND Conv.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL') + '              
			And Conv.state_value_id IS NULL  
			AND Conv.assignment_type_value_id is null  
			AND Conv.curve_id is null   
		left join rec_volume_unit_conversion Conv1 ON Conv1.from_source_uom_id = cast(z.deal_volume_uom_id as int)             
			AND Conv1.to_source_uom_id = ' + ISNULL(CAST(@convert_settlement_uom_id AS VARCHAR),'NULL') + '              
			And Conv1.state_value_id IS NULL  
			AND Conv1.assignment_type_value_id is null  
			AND Conv1.curve_id is null    
	WHERE 1=1 '  
   
EXEC spa_print @sql  
EXEC(@sql)  
  
SELECT @count_new = COUNT('x') FROM #ztbl_final  
   
SELECT   
	@count_unchanged = COUNT('x')   
FROM #ztbl_final NEW  
	INNER JOIN #tbl_olddata OLD  
		ON old.source_deal_detail_id = CAST(new.source_deal_detail_id AS INT)  
		AND ISNULL(old.deal_volume,-1) = ISNULL(CAST(new.deal_volume AS NUMERIC(38,20)),-1)  
		AND old.deal_volume_uom_id = CAST(new.deal_volume_uom_id AS INT)  
		AND ISNULL(old.capacity,-1) = ISNULL(CAST(new.capacity AS NUMERIC(38,20)),-1)  
		AND ISNULL(old.fixed_cost,-1) = ISNULL(CAST(new.fixed_cost AS NUMERIC(38,20)),-1)  
		AND ISNULL(old.fixed_price,-1) = ISNULL(CAST(new.fixed_price AS NUMERIC(38,20)),-1)  
		AND ISNULL(old.option_strike_price,-1) = ISNULL(CAST(new.option_strike_price AS NUMERIC(38,20)),-1)  
		AND ISNULL(old.price_adder,-1) = ISNULL(CAST(new.price_adder AS NUMERIC(38,20)),-1)  
		AND ISNULL(old.price_multiplier,-1) = ISNULL(CAST(new.price_multiplier AS NUMERIC(38,20)),-1)  
		AND ISNULL(old.curve_id,-1) = ISNULL(CAST(new.curve_id AS INT),-1)  
		AND ISNULL(old.buy_sell_flag,-1) = ISNULL(new.buy_sell_flag,-1)  
		AND ISNULL(old.fixed_cost_currency_id,-1) = ISNULL(CAST(new.fixed_cost_currency_id AS INT),-1)  
		AND ISNULL(old.formula_currency_id,-1) = ISNULL(CAST(new.formula_currency_id AS INT),-1)  
		AND ISNULL(old.adder_currency_id,-1) = ISNULL(CAST(new.adder_currency_id AS INT),-1)  
		AND ISNULL(old.multiplier,-1) = ISNULL(CAST(new.multiplier AS NUMERIC(38,20)),-1)  
		--    
		AND ISNULL(old.price_adder2,-1) = ISNULL(CAST(new.price_adder2 AS NUMERIC(38,20)),-1)  
		AND ISNULL(old.price_adder_currency2,-1) = ISNULL(CAST(new.price_adder_currency2 AS NUMERIC(38,20)),-1)  
		AND ISNULL(old.volume_multiplier2,-1) = ISNULL(CAST(new.volume_multiplier2 AS NUMERIC(38,20)),-1)  
		AND ISNULL(old.pay_opposite,-1) = ISNULL(new.pay_opposite,-1)  
		AND ISNULL(old.block_description,-1) = ISNULL(new.block_description,-1)  

		AND ISNULL(old.price_uom_id,-1) = ISNULL(CAST(new.price_uom_id AS INT),-1)  
		AND ISNULL(old.category,-1) = ISNULL(new.category,-1)  
		AND ISNULL(old.profile_code,-1) = ISNULL(new.profile_code,-1)  
		AND ISNULL(old.pv_party,-1) = ISNULL(new.pv_party,-1)  
  
    
IF @count_new <> @count_unchanged  
BEGIN   
	SET @not_confirmed = 'y'  
END  
    
IF @not_confirmed = 'y'  
BEGIN  
	DECLARE @tempdate DATETIME  
	SET @tempdate = GETDATE()  

	DECLARE @deal_status INT 
	SELECT @deal_status = deal_status FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id 
	/*   
	CREATE TABLE #scs_error_handler(  
	error_code VARCHAR(20) COLLATE DATABASE_DEFAULT ,  
	MODULE VARCHAR(100) COLLATE DATABASE_DEFAULT ,  
	area VARCHAR(100) COLLATE DATABASE_DEFAULT ,  
	status VARCHAR(20) COLLATE DATABASE_DEFAULT ,  
	msg VARCHAR(100) COLLATE DATABASE_DEFAULT ,  
	recommendation VARCHAR(100) COLLATE DATABASE_DEFAULT   
	)  

	INSERT INTO #scs_error_handler (  
	error_code,  
	MODULE,  
	area,  
	status,  
	msg,  
	recommendation  
	)   

	-- 'deal' -> call_from flag  
	EXEC spa_confirm_status 'i',NULL,@source_deal_header_id,17200,@tempdate,'n',NULL,NULL,'d',@deal_status  

	IF EXISTS (SELECT 'x' FROM #scs_error_handler WHERE error_code LIKE 'Error')  
	BEGIN  
	RAISERROR('CatchError',16,1)  
	END  
	*/
END   
--BEGIN TRY  
	BEGIN TRAN  
	  
	-- if @deal_date is not null  
	--  update source_deal_header set deal_date = @deal_date where source_deal_header_id = @source_deal_header_id  
	  
	DECLARE @source_deal_detail_id		VARCHAR(50)
	DECLARE @term_start					VARCHAR(50)
	DECLARE @term_end					VARCHAR(50)
	DECLARE @leg						VARCHAR(50)
	DECLARE @expiration_date			VARCHAR(50)
	DECLARE @fixed_float_flag			VARCHAR(50)
	DECLARE @buy_sell_flag				VARCHAR(50)
	DECLARE @curve_type					VARCHAR(50)
	DECLARE @commodity					VARCHAR(50)
	DECLARE @physical_financial_flag	VARCHAR(50)
	DECLARE @location					VARCHAR(50)
	DECLARE @index						VARCHAR(50)
	DECLARE @volume						VARCHAR(50)
	DECLARE @volume_frequency			VARCHAR(50)
	DECLARE @UOM						VARCHAR(50)
	DECLARE @capacity					VARCHAR(50)
	DECLARE @price						VARCHAR(50)
	DECLARE @fixed_cost					VARCHAR(50)
	DECLARE @fixed_cost_currency_id		VARCHAR(50)
	DECLARE @formula_price				VARCHAR(50)
	DECLARE @currency					VARCHAR(50)
	DECLARE @option_strike_price		VARCHAR(50)
	DECLARE @price_adder				VARCHAR(50)
	DECLARE @adder_currency				VARCHAR(50)
	DECLARE @price_multiplier			VARCHAR(50)
	DECLARE @multiplier					VARCHAR(50)
	DECLARE @fixed_price_currency		VARCHAR(50)
	DECLARE @adder2						VARCHAR(50)
	DECLARE @currency2					VARCHAR(50)
	DECLARE @multiplier2				VARCHAR(50)
	DECLARE @meter						VARCHAR(50)
	DECLARE @pay_opposite				VARCHAR(50)
	DECLARE @settlement_date			VARCHAR(50)
	DECLARE @block_description			VARCHAR(50)
	DECLARE @detail_description			VARCHAR(50)
	DECLARE @formula					VARCHAR(50)
	DECLARE @day_count					VARCHAR(50)
	DECLARE @settlement_volume			VARCHAR(50)
	DECLARE @location_name				VARCHAR(50)
	DECLARE @curve_name					VARCHAR(50)
	DECLARE @settlement_currency		VARCHAR(50)
	DECLARE @syv						VARCHAR(50)
	DECLARE @price_uom					VARCHAR(50)
	DECLARE @category					VARCHAR(50)
	DECLARE @profile					VARCHAR(50)
	DECLARE @pv_party					VARCHAR(50) 
	DECLARE @formula_curve_id			VARCHAR(50)
	DECLARE @lock_deal_detail			VARCHAR(50)
	DECLARE @status						VARCHAR(50)

	SET @source_deal_detail_id  = 'source_deal_detail_id'
	SET @term_start = 'term_start'
	SET @term_end = 'term_end'
	SET @leg = 'leg'
	SET @expiration_date = 'contract_expiration_date'
	SET @fixed_float_flag = 'fixed_float_leg'
	SET @buy_sell_flag = 'buy_sell_flag'
	SET @curve_type = ''
	SET @commodity = ''
	SET @physical_financial_flag = 'physical_financial_flag'
	SET @location = 'location_id'
	SET @index = 'curve_id'
	SET @volume = 'deal_volume'
	SET @volume_frequency = 'deal_volume_frequency'
	SET @UOM = 'deal_volume_uom_id'
	SET @capacity = 'capacity'
	SET @price = 'fixed_price'
	SET @fixed_cost = 'fixed_cost'
	SET @fixed_cost_currency_id = 'fixed_cost_currency_id'
	SET @formula_price = ''
	SET @currency = 'formula_currency_id'
	SET @option_strike_price = 'option_strike_price'
	SET @price_adder = 'price_adder'
	SET @adder_currency = 'adder_currency_id'
	SET @price_multiplier = 'price_multiplier'
	SET @multiplier = 'multiplier'
	SET @fixed_price_currency = 'fixed_price_currency_id'
	SET @adder2 = 'price_adder2'
	SET @currency2 = 'price_adder_currency2'
	SET @multiplier2 = 'volume_multiplier2'
	SET @meter = 'meter_id'
	SET @pay_opposite = 'pay_opposite'
	SET @settlement_date = 'settlement_date'
	SET @block_description = 'block_description'
	SET @detail_description = 'deal_detail_description'
	SET @formula = 'formula_id'
	SET @day_count = 'day_count_id'
	SET @settlement_volume = 'settlement_volume'
	SET @location_name = ''
	SET @curve_name = ''
	SET @settlement_currency = 'settlement_currency'
	SET @syv = 'standard_yearly_volume'
	SET @price_uom = 'price_uom_id'
	SET @category = 'category'
	SET @profile = 'profile_code'
	SET @pv_party = 'pv_party'
	SET @formula_curve_id = 'formula_curve_id'   
	SET @lock_deal_detail = 'lock_deal_detail'
	SET @status = 'status'
		
	IF @process_id IS NOT NULL AND @process_id <> 'undefined'  
	BEGIN  
	  SET @user_login_id = dbo.FNADBUser()  
	  SET @source_deal_detail_tmp = dbo.FNAProcessTableName('paging_sourcedealtemp', @user_login_id, @process_id)  
	  --SET @expiration_date = '[Expire Date]'  
	  --SET @fixed_float_flag = '[Fixed/Float]'  
	  --SET @location = '[Location ID]'  
	  --SET @index = '[Curve ID]'  
	  --SET @volume = '[Deal Volume]'  
	  --SET @volume_frequency = '[Volume Frequency]'  
	  --SET @UOM = '[Volume UOM]'  
	  --SET @price = '[Fixed Price]'  
	  --SET @formula = '[Formula ID]'  
	  --SET @option_strike_price = '[Option Strike Price]'  
	  --SET @multiplier = '[Price Multiplier]'  
	  --SET @currency = '[Price Currency]'  
	  --SET @meter = '[meter]' 
	  
	--SET @source_deal_detail_id  = '[ID]'
	--SET @term_start = '[Term Start]'
	--SET @term_end = '[Term End]'
	--SET @leg = '[Leg]'
	--SET @expiration_date = '[Expire Date]'
	--SET @fixed_float_flag = '[Fixed/Float]'
	--SET @buy_sell_flag = '[Buy/Sell]'
	--SET @curve_type = '[Curve Type]'
	--SET @commodity = '[Commodity]'
	--SET @physical_financial_flag = '[Physical/Financial]'
	--SET @location = '[Location]'
	--SET @index = '[Curve ID]'
	--SET @volume = '[Deal Volume]'
	--SET @volume_frequency = '[Volume Frequency]'
	--SET @UOM = '[Volume UOM]'
	--SET @capacity = '[Capacity]'
	--SET @price = '[Fixed Price]'
	--SET @fixed_cost = '[Fixed Cost]'
	--SET @fixed_cost_currency_id = '[Fixed Cost Currency]'
	--SET @formula_price = '[Formula Price]'
	--SET @currency = '[Formula Currency]'
	--SET @option_strike_price = '[Option Strike Price]'
	--SET @price_adder = '[Price Adder]'
	--SET @adder_currency = '[Adder Currency]'
	--SET @price_multiplier = '[Price Multiplier]'
	--SET @multiplier = '[Multiplier]'
	--SET @fixed_price_currency = '[Fixed Price Currency]'
	--SET @adder2 = '[Price Adder2]'
	--SET @currency2 = '[Price Adder Currency2]'
	--SET @multiplier2 = '[Volume Multiplier2]'
	--SET @meter = '[Meter]'
	--SET @pay_opposite = '[Pay Opposite]'
	--SET @settlement_date = '[Settlement Date]'
	--SET @block_description = '[Block Description]'
	--SET @detail_description = '[Detail Description]'
	--SET @formula = '[Formula ID]'
	--SET @day_count = '[Day Count]'
	--SET @settlement_volume = '[Settlement Volume]'
	--SET @location_name = '[Location Name]'
	--SET @curve_name = '[Curve Name]'	
	--SET @settlement_currency = '[Settlement Currency]'
	--SET @syv = '[Standard Yearly Volume]'
	--SET @price_uom = '[Price UOM]'
	--SET @category = '[Category]' 
	--SET @profile = '[Profile Code]' 
	--SET @pv_party = '[Pv Party]'
	--SET @formula_curve_id = '[formula Curve ID]' 
	   
	 END  
	 ELSE  
	 BEGIN  
	  SET @source_deal_detail_tmp = 'source_deal_detail'  
	  --SET @expiration_date = 'contract_expiration_date'  
	  --SET @fixed_float_flag = 'fixed_float_leg'  
	  --SET @location = 'location_id'  
	  --SET @index = 'curve_id'  
	  --SET @volume = 'deal_volume'  
	  --SET @volume_frequency = 'deal_volume_frequency'  
	  --SET @UOM = 'deal_volume_uom_id'  
	  --SET @price = 'fixed_price'  
	  --SET @formula = 'formula_id'  
	  --SET @option_strike_price = 'option_strike_price'  
	  --SET @multiplier = 'price_multiplier'  
	  --SET @currency = 'fixed_price_currency_id'  
	  --SET @meter = 'meter_id'  

	 END  
	  
	   
	 IF @process_id IS NOT NULL AND @process_id <> 'undefined'      
	 BEGIN
		 SET @sql = 'UPDATE ' + @source_deal_detail_tmp + ' 
					SET ' + @fixed_float_flag + ' = CASE ' + @fixed_float_flag + '   
														WHEN ''Float'' THEN ''t''   
														WHEN ''Fixed'' THEN ''f''  
														ELSE ' + @fixed_float_flag + ' 
													END'  
		 EXEC spa_print @sql  
		 EXEC (@sql)  
	 END
	   
	 DECLARE @call_breakdown BIT  

	   
	 IF EXISTS (  
			SELECT 1
			FROM   source_deal_detail sdd
				LEFT JOIN #ztbl_final z  
					ON  dbo.FNAStdDate(z.term_start) = sdd.term_start   
					AND dbo.FNAStdDate(z.term_end) = sdd.term_end   
					AND CAST(z.leg AS INT) = sdd.leg   
							  AND isnull(sdd.formula_id, -1) = CAST(z.formula_id AS INT)
							  AND sdd.pay_opposite = z.pay_opposite
					AND sdd.buy_sell_flag = z.buy_sell_flag  
					AND ISNULL(sdd.multiplier, 1) = ISNULL(CAST(z.multiplier AS NUMERIC(38,20)),1)  
					AND ISNULL(sdd.volume_multiplier2, 1) = ISNULL(CAST(z.volume_multiplier2 AS NUMERIC(38,20)),1)  
			WHERE  sdd.source_deal_header_id = @source_deal_header_id
				 AND z.term_start IS NULL      
	 )  
	 BEGIN  
	  SET @call_breakdown = 1  
	  EXEC spa_print 'test'      
	 END   


	 ----update staging table @source_deal_detail_tmp ('paging_sourcedealtemp'+user_id+process_id) 
	 ----with value of xml
	IF (@save = 'n')
	BEGIN
		 SET @sql =' INSERT INTO ' + @source_deal_detail_tmp +
				  '(
					source_deal_detail_id,
					term_start,
					term_end,
					Leg,
					contract_expiration_date,
					fixed_float_leg,
					buy_sell_flag,
					curve_type,			
					physical_financial_flag,
					location_id,
					curve_id,
					deal_volume,
					deal_volume_frequency,
					deal_volume_uom_id,
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
					location_name,
					curve_name,
					settlement_currency,
					standard_yearly_volume,
					price_uom_id,
					category ,
					profile_code ,
					pv_party,
					sequence,
					insert_or_delete, 
					lock_deal_detail,
					status,
					counter
				  )	
			SELECT  tti.source_deal_detail_id,
					tti.term_start,
					tti.term_end,
					tti.Leg,
					tti.contract_expiration_date,
					tti.fixed_float_leg,
					tti.buy_sell_flag,
					tti.curve_id,
					tti.physical_financial_flag,
					tti.location_id,
					tti.curve_id,
					tti.deal_volume,
					tti.deal_volume_frequency,
					tti.deal_volume_uom_id,
					tti.capacity,
					tti.fixed_price,
					tti.fixed_cost,
					tti.fixed_cost_currency_id,
					tti.Formula_id,
					tti.formula_currency_id,
					tti.option_strike_price,
					tti.price_adder,
					tti.adder_currency_id,
					tti.price_multiplier,
					tti.multiplier,
					tti.fixed_price_currency_id,
					tti.price_adder2,
					tti.price_adder_currency2,
					tti.volume_multiplier2,
					tti.meter_id,
					tti.pay_opposite,
					tti.settlement_date,
					tti.block_description,
					tti.deal_detail_description,
					tti.formula_id,
					tti.day_count_id,
					tti.location_id,
					tti.curve_id,
					tti.settlement_currency,
					tti.standard_yearly_volume,
					tti.price_uom_id,
					tti.category ,
					tti.profile_code ,
					tti.pv_party,
					tti.sequence,
					tti.insert_or_delete,
					tti.lock_deal_detail,
					tti.status,
					tti.counter
		FROM #temp_to_insert tti 
			LEFT JOIN ' + @source_deal_detail_tmp + ' sddt
				ON tti.source_deal_detail_id = sddt.source_deal_detail_id
		WHERE sddt.source_deal_detail_id IS NULL'
		
	END

	EXEC(@sql)


	CREATE TABLE #temp_seq(SEQUENCE INT)

	SET @sql = 'INSERT INTO  #temp_seq(sequence) SELECT sequence  FROM ' + @source_deal_detail_tmp + ' WHERE insert_or_delete = ''added_row'''

	EXEC(@sql)

	EXEC ('UPDATE sddt
		   SET    sddt.sequence = sddt.sequence + 1               
		   FROM   ' + @source_deal_detail_tmp + ' sddt
				  INNER JOIN #temp_seq ts
					   ON  sddt.sequence > ts.sequence 
					   OR (
							   sddt.sequence = ts.sequence
							   AND sddt.insert_or_delete = ''added_row''
						   )
		  ') 


	EXEC ('UPDATE sddt SET  sddt.insert_or_delete = ttd.insert_or_delete
		   FROM   ' + @source_deal_detail_tmp + ' sddt
				 INNER JOIN #temp_to_delete ttd
					   ON sddt.source_deal_detail_id = ttd.source_deal_detail_id

		  ') 


	 SET @sql = '  
				 UPDATE t  
				 SET   
					   ' + @term_start + ' = dbo.FNAStdDate(z.term_start),  
					   ' + @term_end + ' = dbo.FNAStdDate(z.term_end),  
					   ' + @leg + ' = cast(z.leg as int), --   
					   ' + @expiration_date + ' = dbo.FNAStdDate(z.contract_expiration_date),  
					   ' + @fixed_float_flag + ' = z.fixed_float_leg,  
					   ' + @buy_sell_flag + '  = z.buy_sell_flag,  
					   ' + @physical_financial_flag + '  =
															CASE 
																 WHEN z.physical_financial_flag = ''Physical'' THEN ''p''
																 WHEN z.physical_financial_flag = ''p'' THEN ''p''
																 ELSE ''f''
															END,  
					   ' + @location + ' = cast(z.location_id as int),  
					   ' + @index + ' = 
										CASE 
											 WHEN ISNUMERIC(z.curve_id) = 1 THEN z.curve_id
											 ELSE NULL
										END,  
					   ' + @volume + ' = NULLIF(z.deal_volume, '''') ,  
					   ' + @volume_frequency + ' = z.deal_volume_frequency,  
					   ' + @UOM + ' = z.deal_volume_uom_id,  
					   ' + @capacity + '  = CAST(z.capacity AS NUMERIC(38, 20)),  
					   ' + @price + ' = NULLIF(z.fixed_price, ''''),  
					   ' + @fixed_cost + '  = NULLIF(z.fixed_cost, ''''),  
					   ' + @formula + ' = 
										CASE 
											 WHEN ISNUMERIC(cast(z.formula_id as int)) = 0 THEN NULL
											 ELSE cast(z.formula_id as int)
										END,  
					   ' + @option_strike_price + ' = NULLIF(z.option_strike_price, ''''),  
					   ' + @price_adder + '  = NULLIF(z.price_adder, ''''),  
					   ' + @price_multiplier + ' = case when isnull(cast(z.price_multiplier as numeric(38,20)),-1) = -1 then NULL else cast(z.price_multiplier as numeric(38,20)) end,  
					   ' + @fixed_price_currency + ' = CASE WHEN ISNUMERIC(z.fixed_price_currency_id) = 1 THEN z.fixed_price_currency_id ELSE NULL END,  
					   ' + @adder2 + '  = z.price_adder2,  
					   ' + @multiplier2 + '  = case when isnull(cast(z.volume_multiplier2 as numeric(38,20)),-1) = -1 then NULL else cast(z.volume_multiplier2 as numeric(38,20)) end,  
					   ' + @meter + ' = z.meter_id,  
					   ' + @pay_opposite + '  = z.pay_opposite,  
					   ' + @settlement_date + '  = z.settlement_date,  
					   ' + @fixed_cost_currency_id + '  = z.fixed_cost_currency_id,  
					   ' + @currency + ' = z.formula_currency_id,  
					   ' + @adder_currency + ' = z.adder_currency_id,  
					   ' + @currency2 + ' = z.price_adder_currency2,  
					   ' + @multiplier + ' = z.multiplier,      
					   ' + @detail_description + '=z.deal_detail_description,     
					   ' + @settlement_volume + ' = z.deal_volume*conv1.conversion_factor  ,
					   ' + @block_description + '=z.block_description  ,
					   ' + @settlement_currency + '=z.settlement_currency,
					   ' + @syv + '=z.standard_yearly_volume,
					   ' + @price_uom + '=z.price_uom_id,
					   ' + @category + '=z.category,
					   ' + @profile + '=z.profile_code,
					   ' + @pv_party + '=z.pv_party,
					   ' + @formula_curve_id + ' = z.formula_curve_id,
					   ' + @lock_deal_detail + ' = z.lock_deal_detail,
					   ' + @status + ' = z.status
				  FROM #ztbl_final z   
						JOIN '+ @source_deal_detail_tmp +' t ON t.' + @source_deal_detail_id + ' = cast(z.source_deal_detail_id as int)  
						LEFT JOIN rec_volume_unit_conversion Conv ON Conv.from_source_uom_id = CAST(z.deal_volume_uom_id as int)             
							AND Conv.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL') + '              
							And Conv.state_value_id IS NULL  
							AND Conv.assignment_type_value_id is null  
							AND Conv.curve_id is null   
						LEFT JOIN rec_volume_unit_conversion Conv1 ON Conv1.from_source_uom_id = cast(z.deal_volume_uom_id as int)             
							AND Conv1.to_source_uom_id = ' + ISNULL(CAST(@convert_settlement_uom_id AS VARCHAR),'NULL') + '              
							And Conv1.state_value_id IS NULL  
							AND Conv1.assignment_type_value_id is null  
							AND Conv1.curve_id is null    
				'  
	   
	 EXEC spa_print @sql  
	 EXEC(@sql)  
	 
	-------- Start of Update curve_id when F10 configuration is set to take curve from location ------------------
	IF EXISTS (	SELECT 1
				FROM   adiha_default_codes_values
				WHERE  default_code_id = 56
					   AND var_value = 1)				
	BEGIN
		SET @sql = 'UPDATE sdd
					SET sdd.curve_id = sml.term_pricing_index
					       
					FROM  ' +  @source_deal_detail_tmp + ' sdd
						   INNER JOIN source_minor_location sml
								ON  sdd.location_id = sml.source_minor_location_id
		            WHERE sdd.fixed_float_leg = ''t'' AND sdd.physical_financial_flag = ''p''
					'
		EXEC(@sql)
	-------- End of Update curve_id when F10 configuration is set to take curve from location ------------------

	END
	ELSE 
	BEGIN
		-------- Start of Update curve_id when curve_id is hidden ------------------
		IF EXISTS( SELECT 1
				   FROM   source_deal_header_template sdht
						  INNER JOIN maintain_field_template_detail mftd
							   ON  mftd.field_template_id = sdht.field_template_id
						  INNER JOIN maintain_field_deal mfd
							   ON  mfd.field_id = mftd.field_id
				   WHERE  mfd.farrms_field_id = 'curve_id'
						  AND mftd.insert_required = 'n'
						  AND sdht.template_id = @template_id)
		BEGIN
		
			IF EXISTS(SELECT 1
					  FROM   maintain_field_template_detail mftd
							 INNER JOIN maintain_field_deal mfd
								  ON  mftd.field_id = mfd.field_id
								  AND mftd.udf_or_system = 's'
					  WHERE  mftd.field_template_id = @field_template_id
							 AND mfd.farrms_field_id = 'generator_id'
			) 
			BEGIN 	
			
				SET @sql = 'UPDATE sdd SET curve_id = COALESCE(
						   CAST(
							   ISNULL(rg.source_curve_def_id, rg2.source_curve_def_id) AS 
							   VARCHAR
						   ),
						   CAST(
							   ISNULL(sml.term_pricing_index, sml2.term_pricing_index) AS 
							   VARCHAR
						   ),
						   CAST(ISNULL(sdd.curve_id, sddt.curve_id) AS VARCHAR)
					   )
				   FROM ' + @source_deal_detail_tmp + ' sdd
					   INNER JOIN source_deal_detail sdd2 
							ON sdd2.source_deal_detail_id =  sdd.source_deal_detail_id
					   INNER JOIN source_deal_header sdh 
							ON sdd2.source_deal_header_id = sdd2.source_deal_header_id
					   LEFT JOIN rec_generator rg
							ON  rg.generator_id = sdh.generator_id
					   LEFT JOIN source_minor_location sml
							ON  sml.source_minor_location_id = sdd.location_id
					   LEFT JOIN source_deal_header_template sdht
							ON  sdht.template_id = ' + CAST(@template_id AS VARCHAR(10)) + '
					   INNER JOIN source_deal_detail_template sddt
							ON  sdht.template_id = sddt.template_id
							AND sddt.leg = sdd.leg
					   LEFT JOIN rec_generator rg2
							ON  rg2.generator_id = sdht.generator_id
					   LEFT JOIN source_minor_location sml2
							ON  sml2.source_minor_location_id = sddt.location_id
					WHERE sdh.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(10))		
							
			END 
			ELSE
			BEGIN	
				SET @sql = 'UPDATE sdd SET curve_id = COALESCE(
								   CAST(rg2.source_curve_def_id AS VARCHAR),
								   CAST(
									   ISNULL(sml.term_pricing_index, sml2.term_pricing_index) AS 
									   VARCHAR
								   ),
								   CAST(ISNULL(sdd.curve_id, sddt.curve_id) AS VARCHAR)
							   )
						FROM   ' + @source_deal_detail_tmp + ' sdd
							   LEFT JOIN source_minor_location sml
									ON  sml.source_minor_location_id = sdd.location_id
							   LEFT JOIN source_deal_header_template sdht
									ON  sdht.template_id = ' + CAST(@template_id AS VARCHAR(10)) + '
							   INNER JOIN source_deal_detail_template sddt
									ON  sdht.template_id = sddt.template_id
									AND sddt.leg = sdd.leg
							   LEFT JOIN rec_generator rg2
									ON  rg2.generator_id = sdht.generator_id
							   LEFT JOIN source_minor_location sml2
									ON  sml2.source_minor_location_id = sddt.location_id'		
				
			END
			exec spa_print @sql
			EXEC(@sql)		
			-------- End of Update curve_id when curve_id is hidden ------------------
		END
	END 
	
	
	SET @sql = 'UPDATE sddt
				 SET    ' + @udf_update + '
				 FROM   ' + @source_deal_detail_tmp + ' sddt
						INNER JOIN ' + @udf_table + ' ut ON  sddt.source_deal_detail_id = ut.source_deal_detail_id'

	EXEC(@sql)
	 ----END OF update staging table @source_deal_detail_tmp ('paging_sourcedealtemp'+user_id+process_id) 
	 ----with value of xml

	/* 
	--######################### Changes Made for (IBT) transferred Deals  
	-- if the deal is transferred and offset deal is updated, then update the volume of New transferred deal also or vice versa  
	UPDATE  sdd1  
	SET		sdd1.deal_volume = CAST(z.deal_volume AS NUMERIC(38, 20)),
			sdd1.fixed_price = CAST(z.fixed_price AS NUMERIC(38,20)),  
			sdd1.fixed_cost = CAST(z.fixed_cost AS NUMERIC(38,20)),  
			sdd1.curve_id = CAST(z.curve_id AS INT),  
			sdd1.fixed_price_currency_id = CAST(z.fixed_price_currency_id AS INT),  
			sdd1.option_strike_price = CAST(z.option_strike_price AS NUMERIC(38,20)),  
			sdd1.deal_volume_frequency = z.deal_volume_frequency,  
			sdd1.deal_volume_uom_id= CAST(z.deal_volume_uom_id AS INT),  
			sdd1.price_adder = CAST(z.price_adder AS NUMERIC(38,20)),  
			sdd1.price_multiplier = CAST(z.price_multiplier AS NUMERIC(38,20)),  
			sdd1.multiplier = CAST(z.multiplier AS NUMERIC(38,20))  
	FROM    #ztbl_final z
			INNER JOIN source_deal_detail sdd
				 ON  sdd.source_deal_detail_id = CAST(z.source_deal_detail_id AS INT)
			INNER JOIN source_deal_header sdh
				 ON  sdh.source_deal_header_id = sdd.source_deal_header_id
			LEFT JOIN source_deal_header sdh1
				 ON  sdh1.close_reference_id = sdh.source_deal_header_id
				AND sdh1.deal_reference_type_id=12503  
			LEFT JOIN source_deal_detail sdd1
				 ON  sdd1.source_deal_header_id = sdh1.source_deal_header_id
				 AND sdd1.term_start = sdd.term_start
				 AND sdd1.leg = sdd1.leg  

	---- vice versa  

	UPDATE  sdd1  
	SET     sdd1.deal_volume = CAST(z.deal_volume AS NUMERIC(38, 20)),
			sdd1.fixed_price = CAST(z.fixed_price AS NUMERIC(38,20)),  
			sdd1.fixed_cost = CAST(z.fixed_cost AS NUMERIC(38,20)),  
			sdd1.curve_id = CAST(z.curve_id AS INT),  
			sdd1.fixed_price_currency_id = CAST(z.fixed_price_currency_id AS INT),  
			sdd1.option_strike_price = CAST(z.option_strike_price AS NUMERIC(38,20)),  
			sdd1.deal_volume_frequency = z.deal_volume_frequency,  
			sdd1.deal_volume_uom_id = CAST(z.deal_volume_uom_id AS INT),   
			sdd1.price_adder = CAST(z.price_adder AS NUMERIC(38,20)),  
			sdd1.price_multiplier = CAST(z.price_multiplier AS NUMERIC(38,20)),  
			sdd1.multiplier = CAST(z.multiplier AS NUMERIC(38,20))  
	FROM   #ztbl_final z
			INNER JOIN source_deal_detail sdd
				 ON  sdd.source_deal_detail_id = CAST(z.source_deal_detail_id AS INT)
			INNER JOIN source_deal_header sdh
				 ON  sdh.source_deal_header_id = sdd.source_deal_header_id
			LEFT JOIN source_deal_header sdh1
				 ON  sdh1.source_deal_header_id = sdh.close_reference_id
				 AND sdh.deal_reference_type_id = 12503
			LEFT JOIN source_deal_detail sdd1
				 ON  sdd1.source_deal_header_id = sdh1.source_deal_header_id
				 AND sdd1.term_start = sdd.term_start
				 AND sdd1.leg = sdd1.leg   

	--######################### END of Changes Made for (IBT) transferred Deals  
*/
	  
	IF @save = 'y'  
	BEGIN  
		DECLARE @last_confirm_status_type INT
		DECLARE @current_confirm_status_type INT
	        
        SELECT TOP 1 @last_confirm_status_type = type FROM confirm_status cs 
		WHERE source_deal_header_id IN (@source_deal_header_id) 
		ORDER BY update_ts DESC
        
        SELECT @current_confirm_status_type = confirm_status_type  
		FROM source_deal_header  WHERE source_deal_header_id = 18
        
        IF ISNULL(@last_confirm_status_type, -1) <> @current_confirm_status_type
        BEGIN
        	CREATE TABLE #scs_error_handler
			(
				error_code      VARCHAR(20) COLLATE DATABASE_DEFAULT ,
				MODULE          VARCHAR(100) COLLATE DATABASE_DEFAULT ,
				area            VARCHAR(100) COLLATE DATABASE_DEFAULT ,
				STATUS          VARCHAR(20) COLLATE DATABASE_DEFAULT ,
				msg             VARCHAR(100) COLLATE DATABASE_DEFAULT ,
				recommendation  VARCHAR(100) COLLATE DATABASE_DEFAULT 
			)  
		  
			INSERT INTO #scs_error_handler
			  (
				error_code,
				MODULE,
				area,
				STATUS,
				msg,
				recommendation
			  )
			-- 'deal' -> call_from flag  
			EXEC spa_confirm_status 'i',
				 NULL,
				 @source_deal_header_id,
				 17200,
				 @tempdate,
				 'n',
				 NULL,
				 NULL,
				 'd',
				 @deal_status  

			IF EXISTS (
				   SELECT 'x'
				   FROM   #scs_error_handler
				   WHERE  error_code LIKE 'Error'
			   )
			BEGIN
				RAISERROR('CatchError', 16, 1)
			END
        END		
	  
		IF @process_id IS NOT NULL AND @process_id <> 'undefined'  
		BEGIN 
		---------------------------UPDATES SOURCE_DEAL_DEAL TABLE------------------------------------------------------
			-------------------START OF LOSS FACTOR CALCULATIONS-------------------------------------------------------
			
			IF EXISTS(	
				SELECT 1 
				FROM  (
					SELECT TOP(1) uddf.udf_value
				FROM   user_defined_deal_fields uddf
					INNER JOIN user_defined_deal_fields_template uddft
						ON  uddft.udf_template_id = uddf.udf_template_id AND uddft.Field_label='Scheduled ID'
					 and uddf.source_deal_header_id =@source_deal_header_id 
					  AND ISNUMERIC(uddf.udf_value)=1
				) sch_id
				INNER JOIN user_defined_deal_fields uddf_d ON ISNUMERIC(uddf_d.udf_value)=1 AND uddf_d.udf_value=sch_id.udf_value
				outer apply(
					select cast(f.udf_value as float) factor from  user_defined_deal_fields f
					inner join  user_defined_deal_fields_template uddft on f.udf_template_id=uddft.udf_template_id  and uddft.field_name=-5614
						and f.source_deal_header_id=uddf_d.source_deal_header_id  and Isnumeric(f.udf_value)=1
				) fac
				--outer apply(
				--	select cast(f.udf_value as float) grp_path_id from  user_defined_deal_fields f
				--	inner join  user_defined_deal_fields_template uddft on f.udf_template_id=uddft.udf_template_id  and uddft.field_name=-5606
				--		and f.source_deal_header_id=uddf_d.source_deal_header_id  and Isnumeric(f.udf_value)=1
				--) grp_path
				where uddf_d.source_deal_header_id=@source_deal_header_id 
				--AND grp_path.grp_path_id IS NOT null
			)	
			BEGIN 	
				exec dbo.spa_update_pipeline_cut @process_id,@source_deal_header_id
				
			END
			ELSE
			BEGIN
				
				
				/*
				
				IF EXISTS(
				SELECT 1
				FROM   user_defined_fields_template udft
					   INNER JOIN user_defined_deal_fields_template uddft
							ON  udft.field_name = uddft.field_name
							AND uddft.template_id = @template_id
							AND udft.Field_label = 'Delivery Path' 	
				)
				BEGIN					
					CREATE TABLE #loss_factor_deal (
						source_deal_detail_id INT,
						term_start DATETIME,
						term_end DATETIME,
						leg INT,
						deal_volume NUMERIC(38, 20)
					)
					CREATE TABLE #loss_factor_deal_unique (
						source_deal_detail_id INT,
						term_start DATETIME,
						term_end DATETIME,
						leg INT,
						deal_volume NUMERIC(38, 20)
					)
					
					DECLARE @loss_factor NUMERIC(38, 20)				
					
					SELECT @loss_factor = ISNULL(dp.loss_factor, 0) + ISNULL(dp.fuel_factor, 0)
					FROM   user_defined_deal_fields uddf
						   INNER JOIN user_defined_deal_fields_template uddft
								ON  uddft.udf_template_id = uddf.udf_template_id
						   INNER JOIN user_defined_fields_template udft
								ON  udft.field_name = uddft.field_name
						   INNER JOIN delivery_path dp
								ON  dp.path_id = uddf.udf_value
					WHERE  uddf.source_deal_header_id = @source_deal_header_id
						   AND udft.Field_label = 'Delivery Path'
					
					SET @sql = ' 
							INSERT INTO #loss_factor_deal(source_deal_detail_id, term_start, term_end, leg, deal_volume)
							SELECT  sdd.source_deal_detail_id, sdd.term_start, sdd.term_end, sdd.leg, sddt.deal_volume 
							 FROM ' + @source_deal_detail_tmp + ' sddt
							 INNER JOIN source_deal_detail sdd
								 ON sddt.source_deal_detail_id = sdd.source_deal_detail_id
							WHERE	
								sddt.deal_volume <> sdd.deal_volume
							' 
					EXEC(@sql)
						
					
					INSERT INTO #loss_factor_deal_unique(source_deal_detail_id, term_start, term_end, leg, deal_volume )
					SELECT lfd.source_deal_detail_id, lfd.term_start, lfd.term_end, lfd.leg, lfd.deal_volume
						FROM #loss_factor_deal lfd
							   INNER JOIN (
										SELECT lfd.term_start,
											   lfd.term_end,
											   MIN(leg) leg
										FROM   #loss_factor_deal lfd
										GROUP BY
											   lfd.term_start,
											   lfd.term_end
									) SUB
									ON  sub.term_start = lfd.term_start
									AND sub.term_end = lfd.term_end
									AND sub.leg = lfd.leg

					SET @sql = ' UPDATE lfdu
								SET lfdu.source_deal_detail_id = sddt.source_deal_detail_id								
								FROM  ' + @source_deal_detail_tmp + ' sddt
									   INNER JOIN #loss_factor_deal_unique lfdu
											ON  sddt.term_start = lfdu.term_start
											AND sddt.term_end = lfdu.term_end
											AND sddt.leg <> lfdu.leg
					' 
		
					EXEC(@sql)
			
					SET @sql = 'UPDATE sddt
								SET sddt.deal_volume = CASE WHEN lfdu.leg = 1 THEN 
															lfdu.deal_volume - lfdu.deal_volume * ' + CAST(@loss_factor AS VARCHAR(50)) + '														
														ELSE 
															lfdu.deal_volume /(1 - ' + CAST(@loss_factor AS VARCHAR(50)) + ')
													   END
								FROM ' + @source_deal_detail_tmp + ' sddt
								INNER JOIN #loss_factor_deal_unique lfdu
								on lfdu.source_deal_detail_id = sddt.source_deal_detail_id
					'
					EXEC(@sql)
					--select @loss_factor
					--exec('select * from ' + @source_deal_detail_tmp)	
				
				END 
				-------------------END OF LOSS FACTOR CALCULATIONS------------------------------------------------------- 
				--	*/

				
				-------------------------START OF "FROM DEAL" AND "TO DEAL" UPDATE------------------------------
				
				IF EXISTS(
					SELECT 1
					FROM source_deal_header sdh
					INNER JOIN user_defined_deal_fields_template uddft
						ON sdh.template_id = uddft.template_id
					INNER JOIN user_defined_fields_template udft
						ON uddft.field_name = udft.field_name
						AND udft.field_label in ('from deal', 'to deal')
					INNER JOIN user_defined_deal_fields uddf 
						ON uddf.source_deal_header_id = sdh.source_deal_header_id
						AND uddft.udf_template_id = uddf.udf_template_id
					WHERE sdh.source_deal_header_id = @source_deal_header_id			
				)
				BEGIN	
					
					DECLARE @from_deal INT, @to_deal INT, @from_to_deal VARCHAR(100)
					
					SELECT @from_deal = uddf.udf_value
					FROM source_deal_header sdh
					INNER JOIN user_defined_deal_fields_template uddft
						ON sdh.template_id = uddft.template_id
					INNER JOIN user_defined_fields_template udft
						ON uddft.field_name = udft.field_name
						AND udft.field_label in ('from deal')
					INNER JOIN user_defined_deal_fields uddf 
						ON uddf.source_deal_header_id = sdh.source_deal_header_id
						AND uddft.udf_template_id = uddf.udf_template_id
					WHERE sdh.source_deal_header_id = @source_deal_header_id

					SELECT @to_deal = uddf.udf_value
					FROM source_deal_header sdh
					INNER JOIN user_defined_deal_fields_template uddft
						ON sdh.template_id = uddft.template_id
					INNER JOIN user_defined_fields_template udft
						ON uddft.field_name = udft.field_name
						AND udft.field_label in ('to deal')
					INNER JOIN user_defined_deal_fields uddf 
						ON uddf.source_deal_header_id = sdh.source_deal_header_id
						AND uddft.udf_template_id = uddf.udf_template_id
					WHERE sdh.source_deal_header_id = @source_deal_header_id
					
					
					CREATE TABLE #from_to_deal_update (
						term_start DATETIME,
						term_end DATETIME,
						leg INT,
						deal_volume_changed NUMERIC(38, 20)
					)
					
					SET @sql = ' 
								INSERT INTO #from_to_deal_update(term_start, term_end, leg, deal_volume_changed)
								SELECT sdd.term_start, sdd.term_end, sdd.leg, sdd.deal_volume - sddt.deal_volume 
								 FROM ' + @source_deal_detail_tmp + ' sddt
								 INNER JOIN source_deal_detail sdd
									 ON sddt.source_deal_detail_id = sdd.source_deal_detail_id
								WHERE	
									sddt.deal_volume <> sdd.deal_volume
									AND sdd.leg = 1
									
								' 
					EXEC(@sql)
					
					UPDATE sdd
						SET sdd.deal_volume = sdd.deal_volume - ftdu.deal_volume_changed				
					FROM source_deal_detail sdd
					INNER JOIN #from_to_deal_update ftdu
						ON sdd.term_start = ftdu.term_start
						AND sdd.term_end = ftdu.term_end
					WHERE sdd.source_deal_header_id in (@from_deal, @to_deal)			
					
					
					SELECT @from_to_deal = ISNULL(CAST(@from_deal AS VARCHAR(10)), '') 
							+ ISNULL(',' + CAST(@to_deal AS VARCHAR(10)), '')

					
					--------------------START OF CALCULATE TOTAL VOLUME OF FROM AND TO DEAL-----------------------------------------------------
					IF NULLIF(@from_to_deal, '') IS NOT NULL 
					BEGIN
						DECLARE @source_deal_header_tmp VARCHAR(200), @process_id_pos VARCHAR(200)
						SET @process_id_pos = dbo.FNAGetNewID()
						SELECT @source_deal_header_tmp = dbo.FNAProcessTableName('report_position', dbo.FNADBUser() , @process_id_pos)
						
						SET @sql = ' CREATE TABLE ' +  @source_deal_header_tmp + ' 
						(
							source_deal_header_id  INT,
							[action]               VARCHAR(1)
						)
						'		
						EXEC(@sql)						   
						                       
						SET @sql = ' INSERT INTO ' + @source_deal_header_tmp + 
									' (
										source_deal_header_id,
										ACTION
									  )	
									  SELECT item, ''i'' FROM dbo.SplitCommaSeperatedValues(''' + @from_to_deal + ''')
									  '
					
						EXEC (@sql)	
						
						EXEC dbo.spa_update_deal_total_volume NULL,
						 @process_id_pos,
						 0					
						
					END
					--------------------END OF CALCULATE TOTAL VOLUME OF FROM AND TO DEAL-----------------------------------------------------
				END
		
			END
			-------------------------END OF "FROM DEAL" AND "TO DEAL" UPDATE------------------------------
						
			SET @sql = '  
						UPDATE t  
						SET   
							term_start = dbo.FNACovertToSTDDate(z.' + @term_start + '),  
							term_end = dbo.FNACovertToSTDDate(z.' + @term_end + '),  
							leg = CAST(z.leg AS INT),   
							contract_expiration_date = dbo.FNACovertToSTDDate(z.' + @expiration_date + '),  
							fixed_float_leg = CAST(z.' + @fixed_float_flag + ' AS CHAR(1)),  
							buy_sell_flag = CAST(z.' + @buy_sell_flag + ' AS CHAR(1)),  
							physical_financial_flag = CAST(z.' + @physical_financial_flag + ' AS CHAR(1)),  
							location_id = CAST(z.' + @location + ' AS INT),  
							curve_id = CAST(z.' + @index + ' AS INT),  
							--curve_id = spcd.source_curve_def_id,  
							deal_volume = CAST(z.' + @volume + ' AS NUMERIC(38,20)),  
							deal_volume_frequency = CAST(z.' + @volume_frequency + ' AS CHAR(1)),  
							deal_volume_uom_id = CAST(z.' + @UOM + ' AS INT),  
							capacity = cast(z.' + @capacity + ' as numeric(38,20)),  
							fixed_price = CAST(z.' + @price + ' AS NUMERIC(38,20)),  
							fixed_cost = CAST(z.' + @fixed_cost + ' AS NUMERIC(38,20)),  
							formula_id = CAST(z.' + @formula + ' AS INT),  
							option_strike_price = CAST(z.' + @option_strike_price + ' AS NUMERIC(38,20)),  
							price_adder = CAST(z.' + @price_adder + ' AS NUMERIC(38,20)),  
							price_multiplier = CAST(z.' + @price_multiplier + ' AS NUMERIC(38,20)),  
							fixed_price_currency_id = CAST(z.' + @fixed_price_currency + ' AS INT),  
							price_adder2 = CAST(z.' + @adder2 + ' AS NUMERIC(38,20)),  
							volume_multiplier2 = CAST(z.' + @multiplier2 + ' AS NUMERIC(38,20)),  
							meter_id = CAST(z.' + @meter + ' AS INT),  
							pay_opposite = z.' + @pay_opposite + ',  
							settlement_date = dbo.FNACovertToSTDDate(z.' + @settlement_date + '),  
							settlement_volume = CAST(z.' + @settlement_volume + ' AS FLOAT),  
							fixed_cost_currency_id = CAST(z.' + @fixed_cost_currency_id + ' AS INT),  
							formula_currency_id = CAST(z.' + @currency + ' AS INT),  
							adder_currency_id = CAST(z.' + @adder_currency + ' AS INT),  
							price_adder_currency2 = CAST(z.' + @currency2 + ' AS INT),  
							multiplier = CAST(z.' + @multiplier + ' AS NUMERIC(38,20))  ,
							settlement_currency = z.' + @settlement_currency + ',
							standard_yearly_volume = z.' + @syv + ',
							price_uom_id = z.' + @price_uom + ',
							category = z.' + @category + ',
							profile_code = z.' + @profile + ',
							pv_party = z.' + @pv_party + ',
							block_description = CAST(z.' + @block_description + ' as varchar)  ,
							deal_detail_description = z.' + @detail_description + ',
							formula_curve_id = z.' + @formula_curve_id + ',
							lock_deal_detail = z.' + @lock_deal_detail + ',
							status = z.' + @status + '
						FROM  ' + @source_deal_detail_tmp + ' z 
							JOIN source_deal_detail t ON t.source_deal_detail_id = z.source_deal_detail_id 
						'  
			EXEC spa_print @sql  
			EXEC(@sql)  
			
			/* update lock deal detail*/ 
			--update deal lock accroding to month
			--EXEC spa_UpdateFromXml '<Root><PSRecordset  term_start= "01/01/2014" term_end= "01/01/2014" contract_expiration_date= "01/01/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "n" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821482" Leg= "1" sequence= "1" insert_or_delete= "normal" counter= "1"></PSRecordset><PSRecordset  term_start= "01/02/2014" term_end= "01/02/2014" contract_expiration_date= "01/02/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "n" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821483" Leg= "1" sequence= "2" insert_or_delete= "normal" counter= "2"></PSRecordset><PSRecordset  term_start= "01/03/2014" term_end= "01/03/2014" contract_expiration_date= "01/03/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "y" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821484" Leg= "1" sequence= "3" insert_or_delete= "normal" counter= "3"></PSRecordset><PSRecordset  term_start= "01/04/2014" term_end= "01/04/2014" contract_expiration_date= "01/04/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "n" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821485" Leg= "1" sequence= "4" insert_or_delete= "normal" counter= "4"></PSRecordset><PSRecordset  term_start= "01/05/2014" term_end= "01/05/2014" contract_expiration_date= "01/05/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "n" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821486" Leg= "1" sequence= "5" insert_or_delete= "normal" counter= "5"></PSRecordset><PSRecordset  term_start= "01/06/2014" term_end= "01/06/2014" contract_expiration_date= "01/06/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "y" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821487" Leg= "1" sequence= "6" insert_or_delete= "normal" counter= "6"></PSRecordset><PSRecordset  term_start= "01/07/2014" term_end= "01/07/2014" contract_expiration_date= "01/07/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821488" Leg= "1" sequence= "7" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/08/2014" term_end= "01/08/2014" contract_expiration_date= "01/08/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821489" Leg= "1" sequence= "8" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/09/2014" term_end= "01/09/2014" contract_expiration_date= "01/09/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821490" Leg= "1" sequence= "9" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/10/2014" term_end= "01/10/2014" contract_expiration_date= "01/10/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821491" Leg= "1" sequence= "10" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/11/2014" term_end= "01/11/2014" contract_expiration_date= "01/11/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821492" Leg= "1" sequence= "11" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/12/2014" term_end= "01/12/2014" contract_expiration_date= "01/12/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821493" Leg= "1" sequence= "12" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/13/2014" term_end= "01/13/2014" contract_expiration_date= "01/13/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821494" Leg= "1" sequence= "13" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/14/2014" term_end= "01/14/2014" contract_expiration_date= "01/14/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821495" Leg= "1" sequence= "14" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/15/2014" term_end= "01/15/2014" contract_expiration_date= "01/15/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821496" Leg= "1" sequence= "15" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/16/2014" term_end= "01/16/2014" contract_expiration_date= "01/16/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821497" Leg= "1" sequence= "16" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/17/2014" term_end= "01/17/2014" contract_expiration_date= "01/17/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821498" Leg= "1" sequence= "17" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/18/2014" term_end= "01/18/2014" contract_expiration_date= "01/18/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821499" Leg= "1" sequence= "18" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/19/2014" term_end= "01/19/2014" contract_expiration_date= "01/19/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821500" Leg= "1" sequence= "19" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/20/2014" term_end= "01/20/2014" contract_expiration_date= "01/20/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821501" Leg= "1" sequence= "20" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/21/2014" term_end= "01/21/2014" contract_expiration_date= "01/21/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821502" Leg= "1" sequence= "21" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/22/2014" term_end= "01/22/2014" contract_expiration_date= "01/22/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821503" Leg= "1" sequence= "22" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/23/2014" term_end= "01/23/2014" contract_expiration_date= "01/23/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821504" Leg= "1" sequence= "23" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/24/2014" term_end= "01/24/2014" contract_expiration_date= "01/24/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821505" Leg= "1" sequence= "24" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/25/2014" term_end= "01/25/2014" contract_expiration_date= "01/25/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821506" Leg= "1" sequence= "25" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/26/2014" term_end= "01/26/2014" contract_expiration_date= "01/26/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821507" Leg= "1" sequence= "26" insert_or_delete= "normal" counter= "0"></PSRecordset><PSRecordset  term_start= "01/27/2014" term_end= "01/27/2014" contract_expiration_date= "01/27/2014" buy_sell_flag= "b" curve_id= "2" fixed_price= "1" fixed_price_currency_id= "1" deal_volume= "1" deal_volume_frequency= "y" deal_volume_uom_id= "80" physical_financial_flag= "f" lock_deal_detail= "n" status= "" create_ts= "" create_user= "" fixed_cost= "1" total_volume= "48" update_ts= "" update_user= "" fixed_float_leg= "t" location_id= "" multiplier= "1" source_deal_detail_id= "1821508" Leg= "1" sequence= "27" insert_or_delete= "normal" counter= "9"></PSRecordset></Root>', '06657180_D558_462E_8848_F93EA8023915', NULL, 37018, 'y', '', 'y', NULL, 0, NULL, b
			SELECT DATEPART(YYYY, term_start) term_start_yr, DATEPART(mm,term_start) term_start_mth, 
					MAX([counter]) [counter], MAX(lock_deal_detail) lock_deal_detail,
					MAX(source_deal_detail_id) source_deal_detail_id
				INTO #update_deal_lock 
			FROM #ztbl_final
			GROUP BY DATEPART(YYYY, term_start), DATEPART(mm, term_start)


			DECLARE @updated_deal_id INT
			
			--get source deal header id of updated source_deal_header_id
			SELECT TOP 1 @updated_deal_id = sdd.source_deal_header_id 
			FROM #update_deal_lock udl
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = udl.source_deal_detail_id

			--update lock deal detail 
			--SELECT udl.*, zf.lock_deal_detail, sdd.source_deal_detail_id
			UPDATE sdd
			SET sdd.lock_deal_detail = zf.lock_deal_detail 
			FROM #update_deal_lock udl
			INNER JOIN #ztbl_final zf ON 1 = 1
				AND DATEPART(YYYY, zf.term_start) = udl.term_start_yr
				AND DATEPART(mm, zf.term_end) = udl.term_start_mth
				AND zf.[counter] = udl.[counter]
			INNER JOIN source_deal_detail sdd ON 1 = 1
				AND DATEPART(YYYY, zf.term_start) = DATEPART(YYYY, sdd.term_start)
				AND DATEPART(mm, zf.term_start) = DATEPART(mm, sdd.term_start)
			WHERE sdd.source_deal_header_id = @updated_deal_id		
			
			
			/*update buy sell start*/
			SELECT zf.leg, MAX(zf.buy_sell_flag) buy_sell_flag, MAX(@updated_deal_id)  source_deal_header_id
				INTO #buy_sell_update
			FROM #ztbl_final zf
			LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = @updated_deal_id
			GROUP BY zf.Leg

			--SELECT  bsu.leg, bsu.buy_sell_flag, sdd.Leg, sdd.buy_sell_flag
			UPDATE sdd
			SET sdd.buy_sell_flag = bsu.buy_sell_flag
			FROM source_deal_detail sdd
			INNER JOIN #buy_sell_update bsu ON bsu.source_deal_header_id = sdd.source_deal_header_id 	
				AND bsu.leg = sdd.leg
			WHERE sdd.source_deal_header_id = @updated_deal_id

			/*update buy sell end*/	  
			
			--DECLARE @deal_reference_type_id INT   
			--SELECT @deal_reference_type_id = deal_reference_type_id FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id  
			--PRINT @deal_reference_type_id  




			----------------------- Start of update transfer and offset deal---------------------------------------
			CREATE TABLE #transfer_offset_deal (source_deal_header_id INT, ref_source_deal_header_id INT, ref_type TINYINT )
			
			INSERT INTO #transfer_offset_deal
			SELECT --transfer deal without offset
				   @source_deal_header_id,
				   sdh.source_deal_header_id, 1
			FROM   source_deal_header sdh
			WHERE sdh.close_reference_id = @source_deal_header_id      
			AND sdh.deal_reference_type_id = 12503			       
			UNION --offset deal 
			SELECT @source_deal_header_id,
				   sdh.source_deal_header_id, 2
			FROM   source_deal_header sdh
			WHERE sdh.close_reference_id = @source_deal_header_id  
					  AND sdh.deal_reference_type_id = 12500
			UNION --transfer deal with offset
			SELECT @source_deal_header_id,
				   t.source_deal_header_id, 3
			FROM   source_deal_header sdh
				   INNER JOIN source_deal_header o
						ON  sdh.source_deal_header_id = o.close_reference_id
				   INNER JOIN source_deal_header t
						ON  t.close_reference_id = o.source_deal_header_id
			WHERE sdh.source_deal_header_id = @source_deal_header_id  
			
			SET @sql = 'UPDATE sdd2  
						SET  
						    sdd2.fixed_float_leg = CAST(z.' + @fixed_float_flag + ' AS CHAR(1)), 
							sdd2.buy_sell_flag = CASE WHEN tod.ref_type = 3 THEN 
													z.' + @buy_sell_flag + ' 
												ELSE CASE WHEN  z.' + @buy_sell_flag + ' =''b'' THEN ''s'' ELSE ''b'' END 
							                    END,
							sdd2.curve_id = CAST(z.' + @index + ' AS INT), 
							sdd2.fixed_price = CAST(z.' + @price + ' AS NUMERIC(38,20)), 
							sdd2.fixed_price_currency_id = CAST(z.' + @fixed_price_currency + ' AS INT), 
							sdd2.option_strike_price = CAST(z.' + @option_strike_price + ' AS NUMERIC(38,20)),  
							sdd2.deal_volume = CAST(z.' + @volume + ' AS NUMERIC(38,20)),  
							sdd2.deal_volume_frequency = CAST(z.' + @volume_frequency + ' AS CHAR(1)), 
							sdd2.deal_volume_uom_id = CAST(z.' + @UOM + ' AS INT),   
							sdd2.formula_id = CAST(z.' + @formula + ' AS INT),  
							sdd2.price_adder = CAST(z.' + @price_adder + ' AS NUMERIC(38,20)),  
							sdd2.price_multiplier = CAST(z.' + @price_multiplier + ' AS NUMERIC(38,20)),  
							sdd2.location_id = CAST(z.' + @location + ' AS INT),
							sdd2.meter_id = CAST(z.' + @meter + ' AS INT),  
							sdd2.physical_financial_flag = CAST(z.' + @physical_financial_flag + ' AS CHAR(1)),							
							sdd2.fixed_cost = CAST(z.' + @fixed_cost + ' AS NUMERIC(38,20)),  
							sdd2.multiplier =  CAST(z.' + @multiplier + ' AS NUMERIC(38,20)), 
							sdd2.adder_currency_id = CAST(z.' + @adder_currency + ' AS INT),  
							sdd2.fixed_cost_currency_id = CAST(z.' + @fixed_cost_currency_id + ' AS INT),
							sdd2.formula_currency_id = CAST(z.' + @currency + ' AS INT),  
							sdd2.price_adder2 = CAST(z.' + @adder2 + ' AS NUMERIC(38,20)),  
							sdd2.price_adder_currency2 = CAST(z.' + @currency2 + ' AS INT),
							sdd2.pay_opposite = z.' + @pay_opposite + ',
							sdd2.capacity = cast(z.' + @capacity + ' as numeric(38,20)),
							sdd2.settlement_currency=z.' + @settlement_currency + ',
							sdd2.standard_yearly_volume=z.' + @syv + ',
							sdd2.price_uom_id=z.' + @price_uom + ',
							sdd2.category=z.' + @category + ',
							sdd2.profile_code=z.' + @profile + ',
							sdd2.pv_party=z.' + @pv_party + ',
							sdd2.formula_curve_id = z.' + @formula_curve_id + ' 
							
						FROM ' + @source_deal_detail_tmp + ' z  
							INNER JOIN source_deal_detail sdd1 ON sdd1.source_deal_detail_id = z.' + @source_deal_detail_id + '   
							INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id = sdd1.source_deal_header_id  
							INNER JOIN #transfer_offset_deal tod ON tod.source_deal_header_id = sdh1.source_deal_header_id  							 
							INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = tod.ref_source_deal_header_id
								AND sdd2.leg = sdd1.leg
								AND sdd2.term_start = sdd1.term_start '
			    
			EXEC spa_print @sql
			EXEC(@sql)  
		    ----------------------- End of update transfer and offset deal--------------------------------------- 
		 END   		 
		 
		UPDATE sdd1 set sdd1.deal_volume = sdd.deal_volume * rga.auto_assignment_per 
		FROM  
		#ztbl_final z   
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = CAST(z.source_deal_detail_id AS INT)  
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id  
		INNER JOIN  source_deal_header sdh1 ON sdh1.close_reference_id=sdh.source_deal_header_id 
		INNER JOIN source_deal_detail sdd1 ON sdd1.source_deal_header_id = sdh1.source_deal_header_id
                INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh1.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
                AND rga.counterparty_id = sc.source_counterparty_id

		UPDATE sdd2 set sdd2.deal_volume = sdd.deal_volume * rga.auto_assignment_per
		FROM  
		#ztbl_final z   
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = CAST(z.source_deal_detail_id AS INT)  
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id  
		INNER JOIN  source_deal_header sdh1 ON sdh1.close_reference_id=sdh.source_deal_header_id 
		INNER JOIN source_deal_header sdh2 ON sdh2.close_reference_id = sdh1.source_deal_header_id
		INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
                INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh1.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
                AND rga.counterparty_id = sc.source_counterparty_id

		 
		-------------------------------------UDF DETAIL OPERATION SARTS HERE-------------------------------------------------------------
		 EXEC spa_print 'UDF Start'
		 CREATE TABLE #udf_table(
			sno INT IDENTITY(1,1)
		 )

		 CREATE TABLE #udf_transpose_table(
			 source_deal_detail_id	INT,
			 udf_template_id		VARCHAR(50) COLLATE DATABASE_DEFAULT ,
			 udf_value				VARCHAR(150) COLLATE DATABASE_DEFAULT 
		 )
		 
			--EXEC('select * from ' + @udf_table)

		SET @sql = 'UPDATE sddt SET ' + @udf_update + 
					' FROM ' + @source_deal_detail_tmp + ' sddt 
							INNER JOIN ' + @udf_table + ' ut ON sddt.source_deal_detail_id = ut.source_deal_detail_id'

		EXEC spa_print @sql
		EXEC (@sql)

		EXEC spa_print @udf_add_field;
		EXEC spa_print @udf_add_field_label

		 IF @udf_add_field IS NOT NULL
		 BEGIN
			 EXEC ('ALTER TABLE #udf_table ADD ' + @udf_add_field)
			 EXEC (
						'
						INSERT #udf_table
						  (
							' + @udf_field + '
						  )
						SELECT ' + @udf_add_field_label + '
						FROM   ' + @source_deal_detail_tmp + '
						UNION ALL ---(this is for inserting added rows from front end)
						SELECT ' + @udf_from_ut_table + '
						FROM   ' + @udf_table + ' ut
							   LEFT JOIN ' + @source_deal_detail_tmp + ' sddt
									ON  sddt.source_deal_detail_id = ut.source_deal_detail_id
						WHERE  sddt.source_deal_detail_id IS NULL 
						'
				  )
			 
			 DECLARE @udf_unpivot_clm VARCHAR(MAX)
			 SET @udf_unpivot_clm = REPLACE(@udf_field, ',source_deal_detail_id', '')
			 SET @sql = ' INSERT #udf_transpose_table(
							source_deal_detail_id,
							udf_template_id,
							udf_value
						  )
						SELECT source_deal_detail_id,
							   col,
							   colval
						FROM   (
								   SELECT ' + @udf_field + '
								   FROM   #udf_table
							   ) p
							   UNPIVOT(ColVal FOR Col IN (' + @udf_unpivot_clm + ')) AS unpvt'
			 exec spa_print @sql	 
			 EXEC (@sql)
		 END
	 
		UPDATE #udf_transpose_table
		SET    udf_template_id = REPLACE(udf_template_id, 'UDF___', '')

	------------------------UPDATES USER_DEFINED_DEAL_DETAIL_FIELDS(DETAIL UDF)--------------------------------------
		UPDATE user_defined_deal_detail_fields
		SET    udf_value = CASE 
				  WHEN uddft.Field_type = 'a' THEN dbo.[FNACovertToSTDDate](u.udf_value)
				  ELSE u.udf_value
		     END
		FROM   user_defined_deal_detail_fields udf
				 LEFT JOIN user_defined_deal_fields_template uddft
					ON  uddft.udf_template_id = udf.udf_template_id 
			   JOIN #udf_transpose_table u
					ON  u.udf_template_id = uddft.udf_user_field_id
					AND u.source_deal_detail_id = udf.source_deal_detail_id

       
        EXEC spa_print 'UDF End'
	-----------------------------END OF UDF DETAIL OPERATION -------------------------------------------------------------

	-----------------DELETE SOURCE_DEAL_DETAIL_ID WHICH ARE DELETED FROM FRONT END--------------------------------------------------------

		DELETE udddf
		FROM   user_defined_deal_detail_fields udddf
			   INNER JOIN #temp_to_delete ttd
					ON  udddf.source_deal_detail_id = ttd.source_deal_detail_id
		
		
		DELETE sdd
		FROM   source_deal_detail sdd
			   INNER JOIN #temp_to_delete ttd
					ON  sdd.source_deal_detail_id = ttd.source_deal_detail_id


	------------------END OF DELETE SOURCE_DEAL_DETAIL_ID WHICH ARE DELETED FROM FRONT END-------------------------------------------------

	------------------INSERT SOURCE_DEAL_DETAIL_ID WHICH ARE INSERTED FROM FRONT END--------------------------------------------------

		CREATE TABLE #temp_old_new_deal_detail_id (
			old_source_deal_detail_id  INT,
			new_source_deal_detail_id  INT
		)

		INSERT INTO source_deal_detail
		  (
			source_deal_header_id,
			term_start,
			term_end,
			Leg,
			contract_expiration_date,
			fixed_float_leg,
			buy_sell_flag,
			curve_id,
			fixed_price,
			fixed_price_currency_id,
			option_strike_price,
			deal_volume,
			deal_volume_frequency,
			deal_volume_uom_id,
			block_description,
			deal_detail_description,
			formula_id,
			volume_left,
			settlement_volume,
			settlement_uom,
			create_user,
			create_ts,
			update_user,
			update_ts,
			price_adder,
			price_multiplier,
			settlement_date,
			day_count_id,
			location_id,
			meter_id,
			physical_financial_flag,
			Booked,
			process_deal_status,
			fixed_cost,
			multiplier,
			adder_currency_id,
			fixed_cost_currency_id,
			formula_currency_id,
			price_adder2,
			price_adder_currency2,
			volume_multiplier2,
			pay_opposite,
			capacity,
			settlement_currency,
			standard_yearly_volume,
			formula_curve_id,
			price_uom_id,
			category,
			profile_code,
			pv_party
		  )
		OUTPUT INSERTED.pv_party, INSERTED.source_deal_detail_id INTO #temp_old_new_deal_detail_id 
		SELECT	source_deal_header_id,
				term_start,
				term_end,
				Leg,
				contract_expiration_date,
				fixed_float_leg,
				buy_sell_flag,
				curve_id,
				fixed_price,
				fixed_price_currency_id,
				option_strike_price,
				deal_volume,
				deal_volume_frequency,
				deal_volume_uom_id,
				block_description,
				deal_detail_description,
				formula_id,
				volume_left,
				settlement_volume,
				settlement_uom,
				create_user,
				create_ts,
				update_user,
				update_ts,
				price_adder,
				price_multiplier,
				settlement_date,
				day_count_id,
				location_id,
				meter_id,
				physical_financial_flag,
				Booked,
				process_deal_status,
				fixed_cost,
				multiplier,
				adder_currency_id,
				fixed_cost_currency_id,
				formula_currency_id,
				price_adder2,
				price_adder_currency2,
				volume_multiplier2,
				pay_opposite,
				capacity,
				settlement_currency,
				standard_yearly_volume,
				formula_curve_id,
				price_uom_id,
				category,
				profile_code,
				source_deal_detail_id    
		FROM #temp_to_insert 

		----SELECT * FROM #temp_old_new_deal_detail_id
		----SELECT * FROM #temp_to_insert tti
		--SELECT * FROM source_deal_detail sdd INNER JOIN 
		--#temp_old_new_deal_detail_id t ON sdd.source_deal_detail_id = t.new_source_deal_detail_id

		UPDATE sdd
		SET	   sdd.pv_party = tti.pv_party
		FROM   source_deal_detail sdd
			   INNER JOIN #temp_to_insert tti ON sdd.pv_party = tti.source_deal_detail_id
		WHERE sdd.source_deal_header_id = @source_deal_header_id

		----SELECT * FROM source_deal_detail sdd INNER JOIN 
		----#temp_old_new_deal_detail_id t ON sdd.source_deal_detail_id = t.new_source_deal_detail_id
		--SELECT * FROM  #udf_table
		--SELECT * FROM #temp_to_insert
		--SELECT * FROM #udf_transpose_table
		--SELECT * FROM #temp_old_new_deal_detail_id

		INSERT INTO user_defined_deal_detail_fields (	
			source_deal_detail_id,
			udf_template_id,
			udf_value
		)
		SELECT tonddi.new_source_deal_detail_id,
			   uddft.udf_template_id,
			   utt.udf_value
		FROM   #udf_transpose_table utt
			   LEFT JOIN user_defined_deal_detail_fields udddf
					ON  utt.source_deal_detail_id = udddf.source_deal_detail_id
			   INNER JOIN #temp_old_new_deal_detail_id tonddi
					ON  tonddi.old_source_deal_detail_id = utt.source_deal_detail_id
			   INNER JOIN user_defined_fields_template udft
					ON  udft.udf_template_id = utt.udf_template_id
			   INNER JOIN user_defined_deal_fields_template uddft
					ON  udft.field_name = uddft.field_name
		WHERE  udddf.source_deal_detail_id IS NULL
			   AND uddft.template_id = @template_id

		------------------END OF INSERT SOURCE_DEAL_DETAIL_ID WHICH ARE INSERTED FROM FRONT END--------------------------------------------------

		DECLARE @source_deal_detail_id_value INT  
		SELECT @source_deal_detail_id_value = source_deal_detail_id
		FROM   source_deal_detail
		WHERE  source_deal_header_id = @source_deal_header_id

		--EXEC spa_update_gis_certificate_no_monthly @source_deal_detail_id_value 
	  
	--- Calulate MTM based on configuration  

	END   
	
	UPDATE  delivery_status 
	SET delivered_volume = ABS((CASE WHEN sdd.buy_sell_flag = 's' THEN -1 ELSE 1 END * sdd.deal_volume))		 
	FROM source_deal_header sdh 
		INNER JOIN  source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
			AND sdh.source_deal_type_id = 57
			AND  sdh.source_deal_header_id = @source_deal_header_id
		INNER JOIN source_deal_header sdh1 ON CAST(sdh1.source_deal_header_id AS VARCHAR(10)) = REPLACE(sdh.deal_id, 'SCHD_','')
		INNER JOIN source_deal_detail sdd1 ON sdd1.source_deal_header_id = sdh1.source_deal_header_id
		CROSS APPLY (
			SELECT MAX(status_timestamp) as_of_date FROM delivery_status  WHERE source_deal_detail_id = sdd1.source_deal_detail_id
		) dt
		INNER JOIN delivery_status ds  ON ds.source_deal_detail_id = sdd1.source_deal_detail_id 
			AND ds.status_timestamp = dt.as_of_date
			AND sdd.Leg = sdd1.Leg
    
	SET @process_id = REPLACE(NEWID(),'-','_')  
	
	EXEC spa_print 'AAAAAAAAAAAAAAAAAAAAAA'
	EXEC spa_print @call_breakdown

	IF ISNULL(@call_breakdown,0)=1  
	BEGIN  
		EXEC spa_print 'EXEC spa_deal_position_breakdown ''u'',', @source_deal_header_id

		INSERT INTO #handle_sp_return_update 
		EXEC spa_deal_position_breakdown 'u', @source_deal_header_id   

		IF EXISTS(SELECT 1 FROM #handle_sp_return_update WHERE [ErrorCode]='Error')  
		BEGIN  
			DECLARE @msg_err VARCHAR(1000),@recom_err VARCHAR(1000)  
			SELECT @msg_err = [MESSAGE],
				   @recom_err = [Recommendation]
			FROM   #handle_sp_return_update
			WHERE  [ErrorCode] = 'Error'  

			EXEC spa_ErrorHandler -1,  
				 @call_update,  
				 'spa_UpdateFromXml',  
				 'DB Error',  
				 @msg_err,  
				 @recom_err   

			ROLLBACK TRAN  

			RETURN  
		END   
	  
	END  
	--rollback  
	COMMIT  TRAN  
	   
	IF @calculate_MTM_from_deal=1  
	BEGIN  
		DECLARE @as_of_date DATETIME  
		SELECT @as_of_date= as_of_date FROM module_asofdate WHERE module_type=15500  

		SET @job_name = 'mtm_' + @process_id  
		  
		SET @spa = 'spa_calc_mtm NULL, NULL, NULL, NULL, '   
			+ CASE 
				   WHEN @source_deal_header_id IS NULL THEN 'NULL'
				   ELSE CAST(@source_deal_header_id AS VARCHAR)
			  END + ',' 
			+ CASE 
				   WHEN @as_of_date IS NULL THEN 'NULL'
				   ELSE '''' + CAST(@as_of_date AS VARCHAR) + ''''
			  END 
		 + ',4500,4500,NULL,'  
			+ CASE 
				   WHEN @user_login_id IS NULL THEN 'NULL'
				   ELSE '''' + CAST(@user_login_id AS VARCHAR) + ''''
			  END 
		 + ',77,NULL'  

		EXEC spa_run_sp_as_job @job_name, @spa,'MTM' ,@user_login_id  
	  
	-- EXEC spa_calc_mtm NULL, NULL, NULL, NULL, @source_deal_header_id, @as_of_date, 4500, 4500, NULL, @user_login_id, 77, NULL  
	END  
	  
	EXEC spa_ErrorHandler 0,  
		 @call_update,  
		 'spa_getXml',  
		 'Success',  
		 'Deal is saved successfully.',  
		 @report_position_process_id  
--END TRY  
--BEGIN CATCH  
-- BEGIN  
--  ROLLBACK TRAN  
  
--  DECLARE @final_error_msg VARCHAR(1000)
--  SET @final_error_msg =  'Failed Updating record.' + ISNULL('Error: ' + @final_error_msg, '')
  
--  EXEC spa_ErrorHandler @@ERROR,  
--       'Source Deal Detail Temp Table',  
--       'spa_getXml',  
--       'DB Error',  
--       @final_error_msg,  
--       'Failed Updating Record'  
-- END  
--END CATCH  
--DROP TABLE #ztbl_final  
--DROP TABLE #tbl_olddata  

--GO

