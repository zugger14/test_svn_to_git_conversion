BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = '552B5BB4_33EA_488C_A137_46322030F5B1'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Prisma Capacity Deal'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				-- Added to preserve rule detail like folder location, File endpoint details.
				IF OBJECT_ID('tempdb..#pre_ixp_import_data_source') IS NOT NULL
					DROP TABLE #pre_ixp_import_data_source

				SELECT rules_id
					, folder_location
					, file_transfer_endpoint_id
					, remote_directory 
				INTO #pre_ixp_import_data_source
				FROM ixp_import_data_source 
				WHERE rules_id = @old_ixp_rule_id

				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Prisma Capacity Deal' ,
					'N' ,
					NULL ,
					'/*[final_process_table]
udf_value1 = tso entry
udf_value3 = bundled
udf_value5 = undiscounted
udf_value6 = networkPoint_id_exit
udf_value7 = networkPoint_name_entry
udf_value8 = networkPoint_id_entry
udf_value4 = networkPoint_name_exit
*/

CREATE TABLE #source_system_data_import_status_detail (
	temp_id INT
	, process_id NVARCHAR(250) COLLATE DATABASE_DEFAULT
	, [source] NVARCHAR(50) COLLATE DATABASE_DEFAULT
	, [type] NVARCHAR(20) COLLATE DATABASE_DEFAULT
	, [description] NVARCHAR(500) COLLATE DATABASE_DEFAULT
	, type_error NVARCHAR(10) COLLATE DATABASE_DEFAULT
)

DECLARE @set_process_id VARCHAR(100)
	, @mapping_table_id INT, @count INT, @sql NVARCHAR(4000)
SELECT @set_process_id = ''@process_id''
SELECT @mapping_table_id = mapping_table_id 
FROM generic_mapping_header 
WHERE mapping_name = ''Prisma Others Mapping''

SELECT @count = COUNT(1) FROM [final_process_table]

INSERT INTO #source_system_data_import_status_detail(
	temp_id
	, process_id
	, [source]
	, [type]
	, [description]
	, type_error
)
SELECT ixp_source_unique_id, @set_process_id
	, ''ixp_source_deal_template''
	, ''Missing Value''
	, ''Generic mapping not found for Network Point Name (EXIT) : '' + temp.udf_value4 + '' and Network Point ID (EXIT) : '' + temp.udf_value6
	, ''Error''
FROM [final_process_table] temp
LEFT JOIN generic_mapping_values gmexit ON gmexit.mapping_table_id = @mapping_table_id 
AND gmexit.clm2_value = temp.udf_value4 AND gmexit.clm3_value = temp.udf_value6
WHERE gmexit.generic_mapping_values_id IS NULL 
AND temp.udf_value4 IS NOT NULL AND temp.udf_value6 IS NOT NULL

INSERT INTO #source_system_data_import_status_detail(
	temp_id
	, process_id
	, [source]
	, [type]
	, [description]
	, type_error
)
SELECT ixp_source_unique_id, @set_process_id
	, ''ixp_source_deal_template''
	, ''Missing Value''
	, ''Generic mapping not found for Network Point Name (ENTRY) : '' + temp.udf_value7 + '' and Network Point ID (ENTRY) : '' + temp.udf_value8
	, ''Error''
FROM [final_process_table] temp
LEFT JOIN generic_mapping_values gmentry ON gmentry.mapping_table_id = @mapping_table_id 
AND gmentry.clm5_value = temp.udf_value8 AND gmentry.clm4_value = temp.udf_value7
WHERE gmentry.generic_mapping_values_id IS NULL 
AND temp.udf_value8 IS NOT NULL AND temp.udf_value7 IS NOT NULL

INSERT INTO source_system_data_import_status_detail(
	 process_id
	, [source]
	, [type]
	, [description]
	, type_error
)
SELECT  
DISTINCT process_id
	, [source]
	, [type]
	, [description]
	, type_error 
FROM  #source_system_data_import_status_detail

DELETE t
FROM [final_process_table] t
INNER JOIN  #source_system_data_import_status_detail d ON d.temp_id = t.ixp_source_unique_id

IF @count <> 0 AND NOT EXISTS (SELECT 1 FROM [final_process_table])
BEGIN
    INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation, rules_name) 
 	SELECT @set_process_id,
 	       ''Error'', 
 	       ''Import Data'',
 	       ''Deal'',
 	       ''Error'',
 	       ''0 Data Imported out of '' + CAST(@count AS NVARCHAR(20)) + '' rows'',
 	       ''Please check your data.'',
 	       ''Prisma Capacity Deal''
END

DECLARE @default_code_value INT
/**36 = Define System Time Zone(adiha_default_codes) */
SELECT @default_code_value = [dbo].[FNAGetDefaultCodeValue](36, 1)

UPDATE a
SET [leg] = b.rn
FROM
[final_process_table] a
INNER JOIN 
(
SELECT 
ROW_NUMBER() OVER (
PARTITION BY deal_id
ORDER BY deal_id
) rn, ixp_source_unique_id FROM [final_process_table]
) b ON a.ixp_source_unique_id =b.ixp_source_unique_id


UPDATE [final_process_table]
SET 
  deal_date = CAST([dbo].[FNAGetLOCALTime](deal_date, @default_code_value) AS DATE)
, term_start = DATEADD(HOUR, -6, [dbo].[FNAGetLOCALTime](term_start, @default_code_value)) 
, term_end = DATEADD(MINUTE, -361, [dbo].[FNAGetLOCALTime](term_end, @default_code_value))  


Delete from [final_process_table] where CAST(deal_date As Date) < ''2021-11-01''


UPDATE t
    SET t.[trader_id] = st.trader_id
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[trader_id] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_traders st
	ON st.source_trader_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Prisma Trader Mapping''

UPDATE t
    SET t.[counterparty_id] = sc.counterparty_id
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[counterparty_id] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_counterparty sc
	ON sc.source_counterparty_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Prisma Counterparty Mapping''

UPDATE t
    SET t.[udf_value1] = sc.counterparty_id
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[udf_value1] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_counterparty sc
	ON sc.source_counterparty_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Prisma Counterparty Mapping''

UPDATE t
SET template_id = sdht.template_name,
sub_book = ssbm.logical_name,
curve_id = spcd.curve_name,
location_id = sml.Location_Name,
contract_id = cg.[contract_name]
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON  CASE WHEN t.[udf_value5] IS NOT NULL
		THEN IIF(t.[udf_value5]= ''False'' , ''f'', ''t'')
		ELSE ''-1''
		END = ISNULL(gmv.clm6_value, ''-1'')
	AND ISNULL(t.[udf_value6], -1) = IIF(t.[udf_value6] IS NOT NULL, gmv.clm3_value , ISNULL(t.[udf_value6], -1) ) 
	AND ISNULL(t.[udf_value7], -1) = IIF(t.[udf_value7] IS NOT NULL, gmv.clm4_value , ISNULL(t.[udf_value7], -1) ) 
	AND ISNULL(t.[udf_value8], -1) = IIF(t.[udf_value8] IS NOT NULL, gmv.clm5_value , ISNULL(t.[udf_value8], -1) ) 
	AND ISNULL(t.[udf_value4], -1) = IIF(t.[udf_value4] IS NOT NULL, gmv.clm2_value , ISNULL(t.[udf_value4], -1) ) 
	AND t.leg = 1
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id AND gmh.mapping_name = ''Prisma others Mapping''
INNER JOIN source_deal_header_template sdht ON sdht.template_id = gmv.clm8_value
INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = gmv.clm13_value
INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = gmv.clm10_value-- index leg1
INNER JOIN source_minor_location sml ON sml.source_minor_location_id = gmv.clm9_value -- location leg 1
INNER JOIN contract_group cg ON cg.contract_id = gmv.clm7_value 

UPDATE t
SET template_id = sdht.template_name,
sub_book = ssbm.logical_name,
curve_id = spcd.curve_name,
location_id = sml.Location_Name,
contract_id = cg.[contract_name]
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON  CASE WHEN t.[udf_value5] IS NOT NULL
		THEN IIF(t.[udf_value5]= ''False'' , ''f'', ''t'')
		ELSE ''-1''
		END = ISNULL(gmv.clm6_value, ''-1'')
	AND ISNULL(t.[udf_value6], -1) = IIF(t.[udf_value6] IS NOT NULL, gmv.clm3_value , ISNULL(t.[udf_value6], -1) ) 
	AND ISNULL(t.[udf_value7], -1) = IIF(t.[udf_value7] IS NOT NULL, gmv.clm4_value , ISNULL(t.[udf_value7], -1) ) 
	AND ISNULL(t.[udf_value8], -1) = IIF(t.[udf_value8] IS NOT NULL, gmv.clm5_value , ISNULL(t.[udf_value8], -1) ) 
	AND ISNULL(t.[udf_value4], -1) = IIF(t.[udf_value4] IS NOT NULL, gmv.clm2_value , ISNULL(t.[udf_value4], -1) ) 
	AND t.leg =2
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id AND gmh.mapping_name = ''Prisma others Mapping''
INNER JOIN source_deal_header_template sdht ON sdht.template_id = gmv.clm8_value
INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = gmv.clm13_value
INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = gmv.clm12_value-- index leg2
INNER JOIN source_minor_location sml ON sml.source_minor_location_id = gmv.clm11_value-- location leg2
INNER JOIN contract_group cg ON cg.contract_id = gmv.clm7_value 


UPDATE t
SET buy_sell_flag = sddt.buy_sell_flag
FROM [final_process_table] t 
INNER JOIN source_deal_header_template sdht ON sdht.template_name = t.template_id
INNER JOIN source_deal_detail_template sddt ON sddt.template_id = sdht.template_id AND sddt.leg = t.leg

DECLARE @process_table NVARCHAR(120), @user_name NVARCHAR(100)
SELECT @user_name  = dbo.FNADBUser()
SELECT @process_table = dbo.FNAProcessTableName(''deal_final_backup'', @user_name, ''@process_id'')

EXEC (''SELECT * INTO '' + @process_table + '' FROM [final_process_table]'')
EXEC (''ALTER TABLE '' + @process_table + '' ADD total_count INT'')
SET @sql = ''UPDATE '' + @process_table + '' SET total_count = '' + CAST(@count AS NVARCHAR(20)) 
EXEC(@sql )


UPDATE [final_process_table]
SET 
 term_start = CAST(term_start AS DATE)
, term_end = CAST(term_end AS DATE)
',
					'DECLARE @final_process_table NVARCHAR(250), @user_name NVARCHAR(100)
, @new_process_id NVARCHAR(80), @position_deals NVARCHAR(250), @sql NVARCHAR(MAX)
SELECT @user_name  = dbo.FNADBUser(), @new_process_id = dbo.FNAGetNewID()
SELECT @final_process_table = dbo.FNAProcessTableName(''deal_final_backup'', @user_name, ''@process_id'')
SET @position_deals = dbo.FNAProcessTableName(''report_position'', @user_name, @new_process_id)

CREATE TABLE #row_count(imported_deal INT, total_deal INT)

EXEC(''INSERT INTO #row_count SELECT COUNT(1), MAX(total_count) FROM '' + @final_process_table)

DECLARE @imported_deal INT, @total_deal INT

SELECT @imported_deal = imported_deal, @total_deal = total_deal FROM #row_count

IF EXISTS(SELECT 1 FROM source_system_data_import_status
	  WHERE process_id = ''@process_id''
	  AND description like ''%Data imported Successfully out of%''
	  )
BEGIN
	UPDATE source_system_data_import_status
		SET description = CAST(@imported_deal AS NVARCHAR(10)) + '' Data imported Successfully out of '' + CAST(@total_deal AS NVARCHAR(10)) + '' rows.''
	WHERE process_id = ''@process_id''
	AND description like ''%Data imported Successfully out of%''
END
ELSE 
BEGIN
	INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation, rules_name) 
	SELECT DISTINCT ''@process_id'',
		''Error'',
		''Import Data'',
		''ixp_source_deal_template'',
		''Error'',
		CAST(@imported_deal AS NVARCHAR(10)) + '' Data imported Successfully out of '' + CAST(@total_deal AS NVARCHAR(10)) + '' rows.'',
		''Please verify data.'',
		''Prisma Capacity Deal''
END


EXEC (''CREATE TABLE '' + @position_deals + ''( source_deal_header_id INT, action NCHAR(1) COLLATE DATABASE_DEFAULT)'')
SET @sql = ''INSERT INTO '' + @position_deals + ''(source_deal_header_id,action) 
 	SELECT  DISTINCT sdh.source_deal_header_id,
 			''''u''''
 	FROM '' + @final_process_table + '' t
	INNER JOIN source_deal_header sdh ON sdh.deal_id = t.deal_id''
EXEC(@sql)

-- udf_value9 = Shipper user allocation price
EXEC (''UPDATE '' + @final_process_table + '' SET udf_value9 = ISNULL(udf_value9, 0) '') 
EXEC( ''ALTER TABLE '' + @final_process_table + '' ADD hours_diff INT'')
EXEC( ''ALTER TABLE '' + @final_process_table + '' ADD capacity_fee_leg1 NUMERIC(38,6)'')
EXEC( ''ALTER TABLE '' + @final_process_table + '' ADD capacity_fee_leg2 NUMERIC(38,6)'')

EXEC (''UPDATE a
SET hours_diff = DATEDIFF(hh, a.term_start, a.term_end)+ 1 + (CASE WHEN insert_delete = ''''i'''' THEN 1 WHEN insert_delete = ''''d'''' THEN -1 ELSE 0 END),
capacity_fee_leg1 = (udf_value9 + CAST(fixed_price AS float)) * 10
						/
						(DATEDIFF(hh, a.term_start, a.term_end)+1 + (CASE WHEN insert_delete = ''''i'''' THEN 1 WHEN insert_delete = ''''d'''' THEN -1 ELSE 0 END)),
capacity_fee_leg2 = ((udf_value9 * 0.5 ) + CAST(fixed_price AS float)) * 10
						/
						(DATEDIFF(hh, a.term_start, a.term_end)+1 + (CASE WHEN insert_delete = ''''i'''' THEN 1 WHEN insert_delete = ''''d'''' THEN -1 ELSE 0 END))
FROM '' + @final_process_table + '' a
LEFT JOIN mv90_dst md ON md.year = YEAR(term_start) 
AND CAST(md.[date] -1 AS date) BETWEEN CAST(term_start AS DATE) AND CAST(term_end AS DATE)
AND md.dst_group_value_id = 102201 
'') 

EXEC(''
DECLARE @uom_id INT, @currency_id INT
SELECT @uom_id = source_uom_id FROM source_uom WHERE uom_name = ''''Mwh''''
SELECT @currency_id = source_currency_id FROM source_currency WHERE currency_name = ''''Eur''''

-- FOR 2 leg deals
INSERT INTO user_defined_deal_fields (source_deal_header_id, udf_template_id,currency_id,
	uom_id, receive_pay, udf_value, counterparty_id)
SELECT cp_entry.source_deal_header_id, 
	cp_entry.udf_template_id, @currency_id, @uom_id, ''''p'''' ,
	a.capacity_fee_leg2,
	 sc.source_counterparty_id
FROM '' + @final_process_table + ''  a
INNER JOIN source_counterparty sc ON sc.counterparty_id = a.udf_value1
CROSS APPLY (SELECT uddft.udf_template_id, sdh.source_deal_header_id FROM user_defined_fields_template  udft
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_Name  = udft.field_Name
	INNER JOIN source_deal_header sdh on sdh.template_id = uddft.template_id AND sdh.deal_id = a.deal_id
	where udft.field_label = ''''capacity fees-entry''''
) cp_entry
LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cp_entry.source_deal_header_id 
	AND uddf.udf_template_id = cp_entry.udf_template_id
WHERE uddf.udf_deal_id IS NULL AND a.udf_value3 = ''''true'''' AND a.udf_value6 IS NULL  -- udf_value6 =networkPoint_id_exit
UNION
SELECT cp_exit.source_deal_header_id, 
	cp_exit.udf_template_id, @currency_id, @uom_id, ''''p'''' ,
	a.capacity_fee_leg2,
	sc.source_counterparty_id
FROM '' + @final_process_table + ''  a
INNER JOIN source_counterparty sc ON sc.counterparty_id = a.counterparty_id
CROSS APPLY (SELECT uddft.udf_template_id, sdh.source_deal_header_id FROM user_defined_fields_template  udft
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_Name  = udft.field_Name
	INNER JOIN source_deal_header sdh on sdh.template_id = uddft.template_id AND sdh.deal_id = a.deal_id
	where udft.field_label = ''''capacity fees-exit''''
) cp_exit
LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cp_exit.source_deal_header_id 
	AND uddf.udf_template_id = cp_exit.udf_template_id
WHERE uddf.udf_deal_id IS NULL AND a.udf_value3 = ''''true'''' AND a.udf_value6 IS NOT NULL  -- udf_value6 =networkPoint_id_exit

UPDATE uddf
SET udf_value= a.capacity_fee_leg2
, counterparty_id = sc.source_counterparty_id
FROM '' + @final_process_table + ''  a
INNER JOIN source_counterparty sc ON sc.counterparty_id = a.udf_value1
CROSS APPLY (SELECT uddft.udf_template_id, sdh.source_deal_header_id FROM user_defined_fields_template  udft
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_Name  = udft.field_Name
	INNER JOIN source_deal_header sdh on sdh.template_id = uddft.template_id AND sdh.deal_id = a.deal_id
	where udft.field_label = ''''capacity fees-entry''''
) cp_entry
INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cp_entry.source_deal_header_id 
	AND uddf.udf_template_id = cp_entry.udf_template_id
WHERE a.udf_value3 = ''''true'''' AND a.udf_value6 IS NULL  -- udf_value6 =networkPoint_id_exit

UPDATE uddf
SET udf_value= a.capacity_fee_leg2
, counterparty_id = sc.source_counterparty_id
FROM '' + @final_process_table + ''  a
INNER JOIN source_counterparty sc ON sc.counterparty_id = a.counterparty_id
CROSS APPLY (SELECT uddft.udf_template_id, sdh.source_deal_header_id FROM user_defined_fields_template  udft
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_Name  = udft.field_Name
	INNER JOIN source_deal_header sdh on sdh.template_id = uddft.template_id AND sdh.deal_id = a.deal_id
	where udft.field_label = ''''capacity fees-exit''''
) cp_entry
INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cp_entry.source_deal_header_id 
	AND uddf.udf_template_id = cp_entry.udf_template_id
WHERE a.udf_value3 = ''''true'''' AND a.udf_value6 IS NOT NULL  -- udf_value6 =networkPoint_id_exit

-- END FOR 2 leg deals

-- FOR 1 leg Deal
INSERT INTO user_defined_deal_fields (source_deal_header_id, udf_template_id,currency_id,
	uom_id, receive_pay, udf_value, counterparty_id)
SELECT cp_entry.source_deal_header_id, 
	cp_entry.udf_template_id, @currency_id, @uom_id, ''''p'''' ,
	a.capacity_fee_leg1,
	sc.source_counterparty_id
FROM '' + @final_process_table + ''  a
INNER JOIN source_counterparty sc ON sc.counterparty_id = a.counterparty_id
CROSS APPLY (SELECT uddft.udf_template_id, sdh.source_deal_header_id FROM user_defined_fields_template  udft
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_Name  = udft.field_Name
	INNER JOIN source_deal_header sdh on sdh.template_id = uddft.template_id AND sdh.deal_id = a.deal_id
	where udft.field_label = ''''capacity fees-entry''''
) cp_entry
LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cp_entry.source_deal_header_id 
	AND uddf.udf_template_id = cp_entry.udf_template_id
WHERE 1=1 AND uddf.udf_deal_id IS NULL
AND a.udf_value3 = ''''false'''' AND a.udf_value6 IS NULL  -- udf_value6 =networkPoint_id_exit
UNION
SELECT cp_exit.source_deal_header_id, 
	cp_exit.udf_template_id, @currency_id, @uom_id, ''''p'''' ,
	a.capacity_fee_leg1,
	sc.source_counterparty_id
FROM '' + @final_process_table + ''  a
INNER JOIN source_counterparty sc ON sc.counterparty_id = a.counterparty_id
CROSS APPLY (SELECT uddft.udf_template_id, sdh.source_deal_header_id FROM user_defined_fields_template  udft
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_Name  = udft.field_Name
	INNER JOIN source_deal_header sdh on sdh.template_id = uddft.template_id AND sdh.deal_id = a.deal_id
	where udft.field_label = ''''capacity fees-exit''''
) cp_exit
LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cp_exit.source_deal_header_id 
	AND uddf.udf_template_id = cp_exit.udf_template_id
WHERE uddf.udf_deal_id IS NULL AND a.udf_value3 = ''''false'''' AND a.udf_value6 IS NOT NULL  -- udf_value6 =networkPoint_id_exit

UPDATE uddf
SET udf_value = a.capacity_fee_leg1
, counterparty_id = sc.source_counterparty_id
FROM '' + @final_process_table + ''  a
INNER JOIN source_counterparty sc ON sc.counterparty_id = a.counterparty_id
CROSS APPLY (SELECT uddft.udf_template_id, sdh.source_deal_header_id FROM user_defined_fields_template  udft
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_Name  = udft.field_Name
	INNER JOIN source_deal_header sdh on sdh.template_id = uddft.template_id AND sdh.deal_id = a.deal_id
	where udft.field_label = ''''capacity fees-entry''''
) cp_entry
INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cp_entry.source_deal_header_id 
	AND uddf.udf_template_id = cp_entry.udf_template_id
WHERE a.udf_value3 = ''''false'''' AND a.udf_value6 IS NULL  -- udf_value6 =networkPoint_id_exit

UPDATE uddf
SET udf_value= a.capacity_fee_leg1
, counterparty_id = sc.source_counterparty_id
FROM '' + @final_process_table + ''  a
INNER JOIN source_counterparty sc ON sc.counterparty_id = a.counterparty_id
CROSS APPLY (SELECT uddft.udf_template_id, sdh.source_deal_header_id FROM user_defined_fields_template  udft
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_Name  = udft.field_Name
	INNER JOIN source_deal_header sdh on sdh.template_id = uddft.template_id AND sdh.deal_id = a.deal_id
	where udft.field_label = ''''capacity fees-exit''''
) cp_entry
INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cp_entry.source_deal_header_id 
	AND uddf.udf_template_id = cp_entry.udf_template_id
WHERE a.udf_value3 = ''''false'''' AND a.udf_value6 IS NOT NULL  -- udf_value6 =networkPoint_id_exit

-- END FOR 1 leg Deal 

SELECT sdd.source_deal_Detail_id, CAST(a.term_start AS DATE) term_date, 
IIF(LEN(DATEPART(hour,a.term_start) +1 ) = 1, ''''0'''' + CAST(DATEPART(hour,a.term_start) +1 AS NVARCHAR(4)) , CAST(DATEPART(hour,a.term_start) +1 AS NVARCHAR(4))) + '''':00'''' hrs , 
CAST(temp.deal_volume AS NUMERIC(38,5)) deal_volume, 982 granularity, 0 is_dst
INTO #temp_detail_hour
FROM '' + @final_process_table + '' temp
CROSS APPLY (SELECT * FROM dbo.FNATermBreakdown(''''h'''',term_start,term_end)) a
INNER JOIN source_deal_header sdh ON sdh.deal_id = temp.deal_id
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
AND YEAR(sdd.term_start) = YEAR(a.term_start) AND MONTH(sdd.term_start) =  MONTH(a.term_start) 
AND sdd.leg = temp.leg 

SELECT DISTINCT YEAR(term_date) yr INTO #years FROM #temp_detail_hour

/**For DST: mv.[date] -1 done because Gas hour starts from 7 current day to 6 next day*/
INSERT INTO #temp_detail_hour (source_deal_detail_id, term_date, hrs, deal_volume, granularity, is_dst )
SELECT source_deal_detail_id, term_date, 
IIF(LEN(hr) = 1, ''''0'''' + hr + '''':00'''', hr + '''':00''''  ), deal_volume ,granularity, is_dst 
FROM (
    SELECT DISTINCT source_deal_detail_id, term_date,
        CAST(24-mv.[hour] AS NVARCHAR(2)) hr, 
        deal_volume, granularity, 1 is_dst 
    FROM #temp_detail_hour tdh
    INNER JOIN mv90_dst mv ON mv.[date] -1 = tdh.term_date 
        AND [year] IN (SELECT yr FROM #years)  
    	AND insert_delete = ''''i'''' AND dst_group_value_id = 102201
) a 

UPDATE #temp_detail_hour
SET deal_volume = NULL
FROM #temp_detail_hour tdh
INNER JOIN (
	SELECT DISTINCT source_deal_detail_id,tdh.term_date, 
		IIF(LEN(24-mv.[hour]) = 1,''''0'''' + CAST(24-mv.[hour] AS NVARCHAR(2)) + '''':00'''', CAST(24-mv.[hour] AS NVARCHAR(2)) + '''':00'''') hr
	FROM #temp_detail_hour tdh
	INNER JOIN mv90_dst mv ON mv.[date]-1 = tdh.term_date 
		AND [year] IN (SELECT yr FROM #years) 
		AND insert_delete = ''''d''''	AND dst_group_value_id = 102201
) a ON a.source_deal_detail_id = tdh.source_deal_detail_id AND a.term_date = tdh.term_date AND tdh.hrs = a.hr

DELETE sddh FROM #temp_detail_hour dh
INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = dh.source_deal_detail_id
AND sddh.term_date = dh.term_date AND sddh.hr = dh.hrs AND sddh.is_dst = dh.is_dst

INSERT INTO source_deal_detail_hour (source_deal_detail_id, term_date, hr, is_dst, volume, granularity)
SELECT source_deal_detail_id, term_date, hrs, is_dst, deal_volume, granularity
FROM #temp_detail_hour

UPDATE sdd
SET fixed_price = NULL
FROM '' + @final_process_table + '' temp
INNER JOIN source_deal_header sdh ON sdh.deal_id = temp.deal_id
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
'')

EXEC spa_calc_deal_position_breakdown NULL,@new_process_id',
					'i' ,
					'y' ,
					@admin_user ,
					23502,
					1,
					'552B5BB4_33EA_488C_A137_46322030F5B1'
					 )

				SET @ixp_rules_id_new = SCOPE_IDENTITY()
				EXEC spa_print 	@ixp_rules_id_new

				UPDATE ixp
				SET import_export_id = @ixp_rules_id_new
				FROM ipx_privileges ixp
				WHERE ixp.import_export_id = @old_ixp_rule_id
		END
				
				

		ELSE 
		BEGIN
			SET @ixp_rules_id_new = @old_ixp_rule_id
			EXEC spa_print 	@ixp_rules_id_new
			
			UPDATE
			ixp_rules
			SET ixp_rules_name = 'Prisma Capacity Deal'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = '/*[final_process_table]
udf_value1 = tso entry
udf_value3 = bundled
udf_value5 = undiscounted
udf_value6 = networkPoint_id_exit
udf_value7 = networkPoint_name_entry
udf_value8 = networkPoint_id_entry
udf_value4 = networkPoint_name_exit
*/

CREATE TABLE #source_system_data_import_status_detail (
	temp_id INT
	, process_id NVARCHAR(250) COLLATE DATABASE_DEFAULT
	, [source] NVARCHAR(50) COLLATE DATABASE_DEFAULT
	, [type] NVARCHAR(20) COLLATE DATABASE_DEFAULT
	, [description] NVARCHAR(500) COLLATE DATABASE_DEFAULT
	, type_error NVARCHAR(10) COLLATE DATABASE_DEFAULT
)

DECLARE @set_process_id VARCHAR(100)
	, @mapping_table_id INT, @count INT, @sql NVARCHAR(4000)
SELECT @set_process_id = ''@process_id''
SELECT @mapping_table_id = mapping_table_id 
FROM generic_mapping_header 
WHERE mapping_name = ''Prisma Others Mapping''

SELECT @count = COUNT(1) FROM [final_process_table]

INSERT INTO #source_system_data_import_status_detail(
	temp_id
	, process_id
	, [source]
	, [type]
	, [description]
	, type_error
)
SELECT ixp_source_unique_id, @set_process_id
	, ''ixp_source_deal_template''
	, ''Missing Value''
	, ''Generic mapping not found for Network Point Name (EXIT) : '' + temp.udf_value4 + '' and Network Point ID (EXIT) : '' + temp.udf_value6
	, ''Error''
FROM [final_process_table] temp
LEFT JOIN generic_mapping_values gmexit ON gmexit.mapping_table_id = @mapping_table_id 
AND gmexit.clm2_value = temp.udf_value4 AND gmexit.clm3_value = temp.udf_value6
WHERE gmexit.generic_mapping_values_id IS NULL 
AND temp.udf_value4 IS NOT NULL AND temp.udf_value6 IS NOT NULL

INSERT INTO #source_system_data_import_status_detail(
	temp_id
	, process_id
	, [source]
	, [type]
	, [description]
	, type_error
)
SELECT ixp_source_unique_id, @set_process_id
	, ''ixp_source_deal_template''
	, ''Missing Value''
	, ''Generic mapping not found for Network Point Name (ENTRY) : '' + temp.udf_value7 + '' and Network Point ID (ENTRY) : '' + temp.udf_value8
	, ''Error''
FROM [final_process_table] temp
LEFT JOIN generic_mapping_values gmentry ON gmentry.mapping_table_id = @mapping_table_id 
AND gmentry.clm5_value = temp.udf_value8 AND gmentry.clm4_value = temp.udf_value7
WHERE gmentry.generic_mapping_values_id IS NULL 
AND temp.udf_value8 IS NOT NULL AND temp.udf_value7 IS NOT NULL

INSERT INTO source_system_data_import_status_detail(
	 process_id
	, [source]
	, [type]
	, [description]
	, type_error
)
SELECT  
DISTINCT process_id
	, [source]
	, [type]
	, [description]
	, type_error 
FROM  #source_system_data_import_status_detail

DELETE t
FROM [final_process_table] t
INNER JOIN  #source_system_data_import_status_detail d ON d.temp_id = t.ixp_source_unique_id

IF @count <> 0 AND NOT EXISTS (SELECT 1 FROM [final_process_table])
BEGIN
    INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation, rules_name) 
 	SELECT @set_process_id,
 	       ''Error'', 
 	       ''Import Data'',
 	       ''Deal'',
 	       ''Error'',
 	       ''0 Data Imported out of '' + CAST(@count AS NVARCHAR(20)) + '' rows'',
 	       ''Please check your data.'',
 	       ''Prisma Capacity Deal''
END

DECLARE @default_code_value INT
/**36 = Define System Time Zone(adiha_default_codes) */
SELECT @default_code_value = [dbo].[FNAGetDefaultCodeValue](36, 1)

UPDATE a
SET [leg] = b.rn
FROM
[final_process_table] a
INNER JOIN 
(
SELECT 
ROW_NUMBER() OVER (
PARTITION BY deal_id
ORDER BY deal_id
) rn, ixp_source_unique_id FROM [final_process_table]
) b ON a.ixp_source_unique_id =b.ixp_source_unique_id


UPDATE [final_process_table]
SET 
  deal_date = CAST([dbo].[FNAGetLOCALTime](deal_date, @default_code_value) AS DATE)
, term_start = DATEADD(HOUR, -6, [dbo].[FNAGetLOCALTime](term_start, @default_code_value)) 
, term_end = DATEADD(MINUTE, -361, [dbo].[FNAGetLOCALTime](term_end, @default_code_value))  


Delete from [final_process_table] where CAST(deal_date As Date) < ''2021-11-01''


UPDATE t
    SET t.[trader_id] = st.trader_id
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[trader_id] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_traders st
	ON st.source_trader_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Prisma Trader Mapping''

UPDATE t
    SET t.[counterparty_id] = sc.counterparty_id
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[counterparty_id] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_counterparty sc
	ON sc.source_counterparty_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Prisma Counterparty Mapping''

UPDATE t
    SET t.[udf_value1] = sc.counterparty_id
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[udf_value1] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_counterparty sc
	ON sc.source_counterparty_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Prisma Counterparty Mapping''

UPDATE t
SET template_id = sdht.template_name,
sub_book = ssbm.logical_name,
curve_id = spcd.curve_name,
location_id = sml.Location_Name,
contract_id = cg.[contract_name]
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON  CASE WHEN t.[udf_value5] IS NOT NULL
		THEN IIF(t.[udf_value5]= ''False'' , ''f'', ''t'')
		ELSE ''-1''
		END = ISNULL(gmv.clm6_value, ''-1'')
	AND ISNULL(t.[udf_value6], -1) = IIF(t.[udf_value6] IS NOT NULL, gmv.clm3_value , ISNULL(t.[udf_value6], -1) ) 
	AND ISNULL(t.[udf_value7], -1) = IIF(t.[udf_value7] IS NOT NULL, gmv.clm4_value , ISNULL(t.[udf_value7], -1) ) 
	AND ISNULL(t.[udf_value8], -1) = IIF(t.[udf_value8] IS NOT NULL, gmv.clm5_value , ISNULL(t.[udf_value8], -1) ) 
	AND ISNULL(t.[udf_value4], -1) = IIF(t.[udf_value4] IS NOT NULL, gmv.clm2_value , ISNULL(t.[udf_value4], -1) ) 
	AND t.leg = 1
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id AND gmh.mapping_name = ''Prisma others Mapping''
INNER JOIN source_deal_header_template sdht ON sdht.template_id = gmv.clm8_value
INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = gmv.clm13_value
INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = gmv.clm10_value-- index leg1
INNER JOIN source_minor_location sml ON sml.source_minor_location_id = gmv.clm9_value -- location leg 1
INNER JOIN contract_group cg ON cg.contract_id = gmv.clm7_value 

UPDATE t
SET template_id = sdht.template_name,
sub_book = ssbm.logical_name,
curve_id = spcd.curve_name,
location_id = sml.Location_Name,
contract_id = cg.[contract_name]
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON  CASE WHEN t.[udf_value5] IS NOT NULL
		THEN IIF(t.[udf_value5]= ''False'' , ''f'', ''t'')
		ELSE ''-1''
		END = ISNULL(gmv.clm6_value, ''-1'')
	AND ISNULL(t.[udf_value6], -1) = IIF(t.[udf_value6] IS NOT NULL, gmv.clm3_value , ISNULL(t.[udf_value6], -1) ) 
	AND ISNULL(t.[udf_value7], -1) = IIF(t.[udf_value7] IS NOT NULL, gmv.clm4_value , ISNULL(t.[udf_value7], -1) ) 
	AND ISNULL(t.[udf_value8], -1) = IIF(t.[udf_value8] IS NOT NULL, gmv.clm5_value , ISNULL(t.[udf_value8], -1) ) 
	AND ISNULL(t.[udf_value4], -1) = IIF(t.[udf_value4] IS NOT NULL, gmv.clm2_value , ISNULL(t.[udf_value4], -1) ) 
	AND t.leg =2
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id AND gmh.mapping_name = ''Prisma others Mapping''
INNER JOIN source_deal_header_template sdht ON sdht.template_id = gmv.clm8_value
INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = gmv.clm13_value
INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = gmv.clm12_value-- index leg2
INNER JOIN source_minor_location sml ON sml.source_minor_location_id = gmv.clm11_value-- location leg2
INNER JOIN contract_group cg ON cg.contract_id = gmv.clm7_value 


UPDATE t
SET buy_sell_flag = sddt.buy_sell_flag
FROM [final_process_table] t 
INNER JOIN source_deal_header_template sdht ON sdht.template_name = t.template_id
INNER JOIN source_deal_detail_template sddt ON sddt.template_id = sdht.template_id AND sddt.leg = t.leg

DECLARE @process_table NVARCHAR(120), @user_name NVARCHAR(100)
SELECT @user_name  = dbo.FNADBUser()
SELECT @process_table = dbo.FNAProcessTableName(''deal_final_backup'', @user_name, ''@process_id'')

EXEC (''SELECT * INTO '' + @process_table + '' FROM [final_process_table]'')
EXEC (''ALTER TABLE '' + @process_table + '' ADD total_count INT'')
SET @sql = ''UPDATE '' + @process_table + '' SET total_count = '' + CAST(@count AS NVARCHAR(20)) 
EXEC(@sql )


UPDATE [final_process_table]
SET 
 term_start = CAST(term_start AS DATE)
, term_end = CAST(term_end AS DATE)
'
				, after_insert_trigger = 'DECLARE @final_process_table NVARCHAR(250), @user_name NVARCHAR(100)
, @new_process_id NVARCHAR(80), @position_deals NVARCHAR(250), @sql NVARCHAR(MAX)
SELECT @user_name  = dbo.FNADBUser(), @new_process_id = dbo.FNAGetNewID()
SELECT @final_process_table = dbo.FNAProcessTableName(''deal_final_backup'', @user_name, ''@process_id'')
SET @position_deals = dbo.FNAProcessTableName(''report_position'', @user_name, @new_process_id)

CREATE TABLE #row_count(imported_deal INT, total_deal INT)

EXEC(''INSERT INTO #row_count SELECT COUNT(1), MAX(total_count) FROM '' + @final_process_table)

DECLARE @imported_deal INT, @total_deal INT

SELECT @imported_deal = imported_deal, @total_deal = total_deal FROM #row_count

IF EXISTS(SELECT 1 FROM source_system_data_import_status
	  WHERE process_id = ''@process_id''
	  AND description like ''%Data imported Successfully out of%''
	  )
BEGIN
	UPDATE source_system_data_import_status
		SET description = CAST(@imported_deal AS NVARCHAR(10)) + '' Data imported Successfully out of '' + CAST(@total_deal AS NVARCHAR(10)) + '' rows.''
	WHERE process_id = ''@process_id''
	AND description like ''%Data imported Successfully out of%''
END
ELSE 
BEGIN
	INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation, rules_name) 
	SELECT DISTINCT ''@process_id'',
		''Error'',
		''Import Data'',
		''ixp_source_deal_template'',
		''Error'',
		CAST(@imported_deal AS NVARCHAR(10)) + '' Data imported Successfully out of '' + CAST(@total_deal AS NVARCHAR(10)) + '' rows.'',
		''Please verify data.'',
		''Prisma Capacity Deal''
END


EXEC (''CREATE TABLE '' + @position_deals + ''( source_deal_header_id INT, action NCHAR(1) COLLATE DATABASE_DEFAULT)'')
SET @sql = ''INSERT INTO '' + @position_deals + ''(source_deal_header_id,action) 
 	SELECT  DISTINCT sdh.source_deal_header_id,
 			''''u''''
 	FROM '' + @final_process_table + '' t
	INNER JOIN source_deal_header sdh ON sdh.deal_id = t.deal_id''
EXEC(@sql)

-- udf_value9 = Shipper user allocation price
EXEC (''UPDATE '' + @final_process_table + '' SET udf_value9 = ISNULL(udf_value9, 0) '') 
EXEC( ''ALTER TABLE '' + @final_process_table + '' ADD hours_diff INT'')
EXEC( ''ALTER TABLE '' + @final_process_table + '' ADD capacity_fee_leg1 NUMERIC(38,6)'')
EXEC( ''ALTER TABLE '' + @final_process_table + '' ADD capacity_fee_leg2 NUMERIC(38,6)'')

EXEC (''UPDATE a
SET hours_diff = DATEDIFF(hh, a.term_start, a.term_end)+ 1 + (CASE WHEN insert_delete = ''''i'''' THEN 1 WHEN insert_delete = ''''d'''' THEN -1 ELSE 0 END),
capacity_fee_leg1 = (udf_value9 + CAST(fixed_price AS float)) * 10
						/
						(DATEDIFF(hh, a.term_start, a.term_end)+1 + (CASE WHEN insert_delete = ''''i'''' THEN 1 WHEN insert_delete = ''''d'''' THEN -1 ELSE 0 END)),
capacity_fee_leg2 = ((udf_value9 * 0.5 ) + CAST(fixed_price AS float)) * 10
						/
						(DATEDIFF(hh, a.term_start, a.term_end)+1 + (CASE WHEN insert_delete = ''''i'''' THEN 1 WHEN insert_delete = ''''d'''' THEN -1 ELSE 0 END))
FROM '' + @final_process_table + '' a
LEFT JOIN mv90_dst md ON md.year = YEAR(term_start) 
AND CAST(md.[date] -1 AS date) BETWEEN CAST(term_start AS DATE) AND CAST(term_end AS DATE)
AND md.dst_group_value_id = 102201 
'') 

EXEC(''
DECLARE @uom_id INT, @currency_id INT
SELECT @uom_id = source_uom_id FROM source_uom WHERE uom_name = ''''Mwh''''
SELECT @currency_id = source_currency_id FROM source_currency WHERE currency_name = ''''Eur''''

-- FOR 2 leg deals
INSERT INTO user_defined_deal_fields (source_deal_header_id, udf_template_id,currency_id,
	uom_id, receive_pay, udf_value, counterparty_id)
SELECT cp_entry.source_deal_header_id, 
	cp_entry.udf_template_id, @currency_id, @uom_id, ''''p'''' ,
	a.capacity_fee_leg2,
	 sc.source_counterparty_id
FROM '' + @final_process_table + ''  a
INNER JOIN source_counterparty sc ON sc.counterparty_id = a.udf_value1
CROSS APPLY (SELECT uddft.udf_template_id, sdh.source_deal_header_id FROM user_defined_fields_template  udft
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_Name  = udft.field_Name
	INNER JOIN source_deal_header sdh on sdh.template_id = uddft.template_id AND sdh.deal_id = a.deal_id
	where udft.field_label = ''''capacity fees-entry''''
) cp_entry
LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cp_entry.source_deal_header_id 
	AND uddf.udf_template_id = cp_entry.udf_template_id
WHERE uddf.udf_deal_id IS NULL AND a.udf_value3 = ''''true'''' AND a.udf_value6 IS NULL  -- udf_value6 =networkPoint_id_exit
UNION
SELECT cp_exit.source_deal_header_id, 
	cp_exit.udf_template_id, @currency_id, @uom_id, ''''p'''' ,
	a.capacity_fee_leg2,
	sc.source_counterparty_id
FROM '' + @final_process_table + ''  a
INNER JOIN source_counterparty sc ON sc.counterparty_id = a.counterparty_id
CROSS APPLY (SELECT uddft.udf_template_id, sdh.source_deal_header_id FROM user_defined_fields_template  udft
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_Name  = udft.field_Name
	INNER JOIN source_deal_header sdh on sdh.template_id = uddft.template_id AND sdh.deal_id = a.deal_id
	where udft.field_label = ''''capacity fees-exit''''
) cp_exit
LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cp_exit.source_deal_header_id 
	AND uddf.udf_template_id = cp_exit.udf_template_id
WHERE uddf.udf_deal_id IS NULL AND a.udf_value3 = ''''true'''' AND a.udf_value6 IS NOT NULL  -- udf_value6 =networkPoint_id_exit

UPDATE uddf
SET udf_value= a.capacity_fee_leg2
, counterparty_id = sc.source_counterparty_id
FROM '' + @final_process_table + ''  a
INNER JOIN source_counterparty sc ON sc.counterparty_id = a.udf_value1
CROSS APPLY (SELECT uddft.udf_template_id, sdh.source_deal_header_id FROM user_defined_fields_template  udft
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_Name  = udft.field_Name
	INNER JOIN source_deal_header sdh on sdh.template_id = uddft.template_id AND sdh.deal_id = a.deal_id
	where udft.field_label = ''''capacity fees-entry''''
) cp_entry
INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cp_entry.source_deal_header_id 
	AND uddf.udf_template_id = cp_entry.udf_template_id
WHERE a.udf_value3 = ''''true'''' AND a.udf_value6 IS NULL  -- udf_value6 =networkPoint_id_exit

UPDATE uddf
SET udf_value= a.capacity_fee_leg2
, counterparty_id = sc.source_counterparty_id
FROM '' + @final_process_table + ''  a
INNER JOIN source_counterparty sc ON sc.counterparty_id = a.counterparty_id
CROSS APPLY (SELECT uddft.udf_template_id, sdh.source_deal_header_id FROM user_defined_fields_template  udft
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_Name  = udft.field_Name
	INNER JOIN source_deal_header sdh on sdh.template_id = uddft.template_id AND sdh.deal_id = a.deal_id
	where udft.field_label = ''''capacity fees-exit''''
) cp_entry
INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cp_entry.source_deal_header_id 
	AND uddf.udf_template_id = cp_entry.udf_template_id
WHERE a.udf_value3 = ''''true'''' AND a.udf_value6 IS NOT NULL  -- udf_value6 =networkPoint_id_exit

-- END FOR 2 leg deals

-- FOR 1 leg Deal
INSERT INTO user_defined_deal_fields (source_deal_header_id, udf_template_id,currency_id,
	uom_id, receive_pay, udf_value, counterparty_id)
SELECT cp_entry.source_deal_header_id, 
	cp_entry.udf_template_id, @currency_id, @uom_id, ''''p'''' ,
	a.capacity_fee_leg1,
	sc.source_counterparty_id
FROM '' + @final_process_table + ''  a
INNER JOIN source_counterparty sc ON sc.counterparty_id = a.counterparty_id
CROSS APPLY (SELECT uddft.udf_template_id, sdh.source_deal_header_id FROM user_defined_fields_template  udft
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_Name  = udft.field_Name
	INNER JOIN source_deal_header sdh on sdh.template_id = uddft.template_id AND sdh.deal_id = a.deal_id
	where udft.field_label = ''''capacity fees-entry''''
) cp_entry
LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cp_entry.source_deal_header_id 
	AND uddf.udf_template_id = cp_entry.udf_template_id
WHERE 1=1 AND uddf.udf_deal_id IS NULL
AND a.udf_value3 = ''''false'''' AND a.udf_value6 IS NULL  -- udf_value6 =networkPoint_id_exit
UNION
SELECT cp_exit.source_deal_header_id, 
	cp_exit.udf_template_id, @currency_id, @uom_id, ''''p'''' ,
	a.capacity_fee_leg1,
	sc.source_counterparty_id
FROM '' + @final_process_table + ''  a
INNER JOIN source_counterparty sc ON sc.counterparty_id = a.counterparty_id
CROSS APPLY (SELECT uddft.udf_template_id, sdh.source_deal_header_id FROM user_defined_fields_template  udft
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_Name  = udft.field_Name
	INNER JOIN source_deal_header sdh on sdh.template_id = uddft.template_id AND sdh.deal_id = a.deal_id
	where udft.field_label = ''''capacity fees-exit''''
) cp_exit
LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cp_exit.source_deal_header_id 
	AND uddf.udf_template_id = cp_exit.udf_template_id
WHERE uddf.udf_deal_id IS NULL AND a.udf_value3 = ''''false'''' AND a.udf_value6 IS NOT NULL  -- udf_value6 =networkPoint_id_exit

UPDATE uddf
SET udf_value = a.capacity_fee_leg1
, counterparty_id = sc.source_counterparty_id
FROM '' + @final_process_table + ''  a
INNER JOIN source_counterparty sc ON sc.counterparty_id = a.counterparty_id
CROSS APPLY (SELECT uddft.udf_template_id, sdh.source_deal_header_id FROM user_defined_fields_template  udft
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_Name  = udft.field_Name
	INNER JOIN source_deal_header sdh on sdh.template_id = uddft.template_id AND sdh.deal_id = a.deal_id
	where udft.field_label = ''''capacity fees-entry''''
) cp_entry
INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cp_entry.source_deal_header_id 
	AND uddf.udf_template_id = cp_entry.udf_template_id
WHERE a.udf_value3 = ''''false'''' AND a.udf_value6 IS NULL  -- udf_value6 =networkPoint_id_exit

UPDATE uddf
SET udf_value= a.capacity_fee_leg1
, counterparty_id = sc.source_counterparty_id
FROM '' + @final_process_table + ''  a
INNER JOIN source_counterparty sc ON sc.counterparty_id = a.counterparty_id
CROSS APPLY (SELECT uddft.udf_template_id, sdh.source_deal_header_id FROM user_defined_fields_template  udft
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_Name  = udft.field_Name
	INNER JOIN source_deal_header sdh on sdh.template_id = uddft.template_id AND sdh.deal_id = a.deal_id
	where udft.field_label = ''''capacity fees-exit''''
) cp_entry
INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cp_entry.source_deal_header_id 
	AND uddf.udf_template_id = cp_entry.udf_template_id
WHERE a.udf_value3 = ''''false'''' AND a.udf_value6 IS NOT NULL  -- udf_value6 =networkPoint_id_exit

-- END FOR 1 leg Deal 

SELECT sdd.source_deal_Detail_id, CAST(a.term_start AS DATE) term_date, 
IIF(LEN(DATEPART(hour,a.term_start) +1 ) = 1, ''''0'''' + CAST(DATEPART(hour,a.term_start) +1 AS NVARCHAR(4)) , CAST(DATEPART(hour,a.term_start) +1 AS NVARCHAR(4))) + '''':00'''' hrs , 
CAST(temp.deal_volume AS NUMERIC(38,5)) deal_volume, 982 granularity, 0 is_dst
INTO #temp_detail_hour
FROM '' + @final_process_table + '' temp
CROSS APPLY (SELECT * FROM dbo.FNATermBreakdown(''''h'''',term_start,term_end)) a
INNER JOIN source_deal_header sdh ON sdh.deal_id = temp.deal_id
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
AND YEAR(sdd.term_start) = YEAR(a.term_start) AND MONTH(sdd.term_start) =  MONTH(a.term_start) 
AND sdd.leg = temp.leg 

SELECT DISTINCT YEAR(term_date) yr INTO #years FROM #temp_detail_hour

/**For DST: mv.[date] -1 done because Gas hour starts from 7 current day to 6 next day*/
INSERT INTO #temp_detail_hour (source_deal_detail_id, term_date, hrs, deal_volume, granularity, is_dst )
SELECT source_deal_detail_id, term_date, 
IIF(LEN(hr) = 1, ''''0'''' + hr + '''':00'''', hr + '''':00''''  ), deal_volume ,granularity, is_dst 
FROM (
    SELECT DISTINCT source_deal_detail_id, term_date,
        CAST(24-mv.[hour] AS NVARCHAR(2)) hr, 
        deal_volume, granularity, 1 is_dst 
    FROM #temp_detail_hour tdh
    INNER JOIN mv90_dst mv ON mv.[date] -1 = tdh.term_date 
        AND [year] IN (SELECT yr FROM #years)  
    	AND insert_delete = ''''i'''' AND dst_group_value_id = 102201
) a 

UPDATE #temp_detail_hour
SET deal_volume = NULL
FROM #temp_detail_hour tdh
INNER JOIN (
	SELECT DISTINCT source_deal_detail_id,tdh.term_date, 
		IIF(LEN(24-mv.[hour]) = 1,''''0'''' + CAST(24-mv.[hour] AS NVARCHAR(2)) + '''':00'''', CAST(24-mv.[hour] AS NVARCHAR(2)) + '''':00'''') hr
	FROM #temp_detail_hour tdh
	INNER JOIN mv90_dst mv ON mv.[date]-1 = tdh.term_date 
		AND [year] IN (SELECT yr FROM #years) 
		AND insert_delete = ''''d''''	AND dst_group_value_id = 102201
) a ON a.source_deal_detail_id = tdh.source_deal_detail_id AND a.term_date = tdh.term_date AND tdh.hrs = a.hr

DELETE sddh FROM #temp_detail_hour dh
INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = dh.source_deal_detail_id
AND sddh.term_date = dh.term_date AND sddh.hr = dh.hrs AND sddh.is_dst = dh.is_dst

INSERT INTO source_deal_detail_hour (source_deal_detail_id, term_date, hr, is_dst, volume, granularity)
SELECT source_deal_detail_id, term_date, hrs, is_dst, deal_volume, granularity
FROM #temp_detail_hour

UPDATE sdd
SET fixed_price = NULL
FROM '' + @final_process_table + '' temp
INNER JOIN source_deal_header sdh ON sdh.deal_id = temp.deal_id
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
'')

EXEC spa_calc_deal_position_breakdown NULL,@new_process_id'
				, import_export_flag = 'i'
				, ixp_owner = @admin_user
				, ixp_category = 23502
				, is_system_import = 'y'
				, is_active = 1
			WHERE ixp_rules_id = @ixp_rules_id_new
				
		END

				
INSERT INTO ixp_export_tables (ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number)  
								   SELECT @ixp_rules_id_new,
										  it.ixp_tables_id,
										  dependent_table.ixp_tables_id,
										  0,
										  0,
										  0
									FROM ixp_tables it
									LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
									WHERE it.ixp_tables_name = 'ixp_source_deal_template'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter
					, excel_sheet, ssis_package, soap_function_id, clr_function_id, ws_function_name, enable_email_import
					, send_email_import_reply, file_transfer_endpoint_id, remote_directory)
					SELECT @ixp_rules_id_new,
						   NULL,
						   NULL,
						   '\\EU-U-SQL03\shared_docs_TRMTracker_Enercity_UAT\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'pa',
						   '1',
						   'SELECT 
 [counter], dealID, auctionId, balancingGroup_balancingGroupNumber, bookingDate, bundled
  ,  marketArea_name, networkPoint_direction, networkPoint_identifier, networkPoint_name, periodType
  , priceInformation_charges_regulatedCapacityTariff_price_unit_currency, priceInformation_charges_regulatedCapacityTariff_price_value
  , quantity_unit, quantity_value, runtime_end, runtime_start, shipper_user_email, tso_name, undiscounted, priceInformation_auctionSurcharge_price_value
INTO #test_data
FROM  
(
	SELECT  dealid, [label], [value], [counter]
	FROM [temp_process_table]
) AS SourceTable  
PIVOT  
(  
  min([value])  
  FOR label IN (auctionId, balancingGroup_balancingGroupNumber, bookingDate, bundled
  ,  marketArea_name, networkPoint_direction, networkPoint_identifier, networkPoint_name, periodType
  , priceInformation_charges_regulatedCapacityTariff_price_unit_currency, priceInformation_charges_regulatedCapacityTariff_price_value
  , quantity_unit, quantity_value, runtime_end, runtime_start, shipper_user_email, tso_name, undiscounted, priceInformation_auctionSurcharge_price_value)  
) AS PivotTable;  

SELECT 
[counter], dealID, auctionId, balancingGroup_balancingGroupNumber
, bookingDate, bundled
, marketArea_name location_id, networkPoint_direction
, IIF(networkPoint_direction = ''ENTRY'', networkPoint_identifier, NULL) networkPoint_id_entry
, IIF(networkPoint_direction = ''EXIT'', networkPoint_identifier, NULL) networkPoint_id_exit
, IIF(networkPoint_direction = ''ENTRY'', networkPoint_name, NULL) networkPoint_name_entry
, IIF(networkPoint_direction = ''EXIT'', networkPoint_name, NULL) networkPoint_name_exit
, networkPoint_identifier, networkPoint_name, periodType
, priceInformation_charges_regulatedCapacityTariff_price_unit_currency price_unit_currency
, priceInformation_charges_regulatedCapacityTariff_price_value price_value
, quantity_unit, quantity_value, runtime_end, runtime_start, shipper_user_email trader_id
, tso_name, CAST('''' AS NVARCHAR(50)) counterparty_id, undiscounted , CAST('''' AS NVARCHAR(50)) tso_entry
, priceInformation_auctionSurcharge_price_value shipper_user_alloc_price
INTO #final_data
FROM #test_data

--drop table #final_data
UPDATE fd
SET fd.tso_entry = a.tso_name
FROM #final_data fd
INNER JOIN 
( SELECT tso_name,dealid FROM #final_data 
WHERE bundled = ''true'' AND networkPoint_direction = ''ENTRY''
) a ON a.dealID = fd.dealID

UPDATE fd
SET fd.counterparty_id = a.tso_name
FROM #final_data fd
INNER JOIN 
( SELECT tso_name,dealid FROM #final_data 
WHERE bundled = ''true'' AND networkPoint_direction = ''EXIT''
) a ON a.dealID = fd.dealID

UPDATE #final_data SET counterparty_id = tso_name WHERE bundled = ''false''
UPDATE #final_data SET tso_entry = NULL WHERE bundled = ''false''

SELECT * 
--[__custom_table__] 
FROM #final_data
',
						   'n',
						   0,
						   '',
						   '1',
						   'n',
						   '',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   icf.ixp_clr_functions_id,
						   '', 
						   '0',
						   '0',
						   NULL,
						   NULL
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = 'Prisma' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new
						IF OBJECT_ID('tempdb..#pre_ixp_import_data_source') IS NOT NULL
						BEGIN
							UPDATE iids
							SET folder_location = piids.folder_location
								, file_transfer_endpoint_id = piids.file_transfer_endpoint_id
								, remote_directory = piids.remote_directory
							FROM ixp_import_data_source iids
							INNER JOIN #pre_ixp_import_data_source piids 
							ON iids.rules_id = piids.rules_id
						END
					

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id)   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[dealID]', ic.ixp_columns_id, 'pa.[dealID] + ''_PRISMA''', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[bookingDate]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[auctionId]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'ext_deal_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Physical''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'physical_financial_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[counterparty_id]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'counterparty_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Capacity''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_deal_type_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Real''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_category_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[trader_id]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'trader_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, 'IIF(pa.[bundled] = ''true'', ''Linear Asset Model'', NULL)', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'internal_deal_type_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, 'IIF(pa.[bundled] = ''true'', ''Linear Model Option'', NULL)', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'internal_deal_subtype_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Buy''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'header_buy_sell_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Shaped''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'internal_desk_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Gas''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'commodity_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''New''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_status' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Not Confirmed''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'confirm_status_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[runtime_start]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term_start' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[runtime_end]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term_end' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[counter]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Leg' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''t''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_float_leg' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[price_value]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_price' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[price_unit_currency]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_price_currency_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[quantity_value]', ic.ixp_columns_id, 'CAST(pa.[quantity_value] AS NUMERIC(38,5))/1000', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[periodType]', ic.ixp_columns_id, '''Hourly''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume_frequency' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[quantity_unit]', ic.ixp_columns_id, '''MW''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume_uom_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[location_id]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'location_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Fixed Priced''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'pricing_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Hourly''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'profile_granularity' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[tso_entry]', ic.ixp_columns_id, NULL, NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'TSO Entry' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'TSO Entry'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[balancingGroup_balancingGroupNumber]', ic.ixp_columns_id, NULL, NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Balancing Group Number' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Balancing Group Number'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[bundled]', ic.ixp_columns_id, NULL, NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Bundled' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Bundled'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[networkPoint_name_exit]', ic.ixp_columns_id, NULL, NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Network Point Name (EXIT)' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Network Point Name (EXIT)'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[undiscounted]', ic.ixp_columns_id, NULL, NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Undiscount/Discount Flag' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value5' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Undiscount/Discount Flag'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[networkPoint_id_exit]', ic.ixp_columns_id, NULL, NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Network Point ID (EXIT)' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value6' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Network Point ID (EXIT)'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[networkPoint_name_entry]', ic.ixp_columns_id, NULL, NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Network Point Name (ENTRY)' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value7' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Network Point Name (ENTRY)'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[networkPoint_id_entry]', ic.ixp_columns_id, NULL, NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Network Point ID (ENTRY)' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value8' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Network Point ID (ENTRY)'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pa.[shipper_user_alloc_price]', ic.ixp_columns_id, NULL, NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Shipper User Allocation Price' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value9' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Shipper User Allocation Price'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template'

COMMIT 

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN;
				DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
				DECLARE @msg_severity INT = ERROR_SEVERITY();
				DECLARE @msg_state INT = ERROR_STATE();
					
				RAISERROR(@msg, @msg_severity, @msg_state)
			
				--EXEC spa_print 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
			END CATCH
END