IF OBJECT_ID(N'[dbo].[spa_blotter_deal]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_blotter_deal]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 

/**  
	Handles all deal blotter process

	Parameters
	@flag : Flag
		's' - Returns JSON and other info to load deal blotter grid
		'd' - Returns configuration string, header menu list, combo list, filter list and validation rule from detail config process table
		'e' - Returns default field list
		'u' - TDL
		'x' - TDL
		'h' - TDL
		't' - Returns term start and term end according to term frequency

	@template_id : Deal Template Id
	@no_of_row : Number Of deal
	@term_start : Deal Term Start Date
	@term_end : Deal Term End Date
	@blotter_leg : Blotter Deal Leg
	@process_id : Process Id
	@xml : XML Containing Data of Deal Header and Detail
	@deal_date : Deal Date
	@term_frequency : Term Frequency of Deal
	@sub_book : Sub Book in which deal will be created
	@formula_process_id : Formula Process Id
	@term_rule : Deal Term Rule

*/


CREATE PROCEDURE [dbo].[spa_blotter_deal]
    @flag NCHAR(1),
	@template_id INT = NULL,
	@no_of_row INT = 1,
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@blotter_leg INT = NULL,
	@process_id NVARCHAR(200) = NULL,
	@xml XML = NULL,
	@deal_date DATETIME = NULL,
	@term_frequency NCHAR(1) = NULL,
	@sub_book INT = NULL,
	@formula_process_id NVARCHAR(200) = NULL,
	@term_rule INT = NULL
	
AS

SET NOCOUNT ON

DECLARE @field_template_id        INT,
        @process_table            NVARCHAR(150),
        @process_table_detail     NVARCHAR(150),
        @sql                      NVARCHAR(MAX),
        @detail_config_table      NVARCHAR(200),
        @term_level_process_table NVARCHAR(300)
        
DECLARE @update_process_table NVARCHAR(300)
DECLARE @update_process_id NVARCHAR(200) = dbo.FNAGETNewID()
DECLARE @update_clause NVARCHAR(MAX)
DECLARE @formula_present INT

IF @formula_process_id IS NULL
	SET @formula_process_id = dbo.FNAGetNewId()
	
DECLARE @formula_fields_detail NVARCHAR(1000)

DECLARE @detail_formula_process_table NVARCHAR(200), @user_name NVARCHAR(50) = dbo.FNADBUser()
SET @detail_formula_process_table = dbo.FNAProcessTableName('detail_formula_process_table', @user_name, @formula_process_id)

DECLARE @is_admin INT = dbo.FNAIsUserOnAdminGroup(@user_name, 0)

IF @flag = 's'
BEGIN	
	DECLARE @deal_date_rule     INT        

	SELECT @field_template_id = sdht.field_template_id,
		   @deal_date_rule = sdht.deal_date_rule,
		   @term_rule = sdht.term_rule,
		   @term_frequency = ISNULL(@term_frequency, sdht.term_frequency_type)
	FROM dbo.source_deal_header_template sdht
	WHERE sdht.template_id = @template_id 
	
	IF @deal_date IS NULL
		SET @deal_date = CONVERT(DATE, GETDATE())

	SET @deal_date = dbo.FNAResolveDate(@deal_date, @deal_date_rule)
	SET @term_start = dbo.FNAResolveDate(@deal_date, @term_rule)
	
	IF @deal_date = @term_start
	BEGIN
		IF @term_frequency = 'd'
			SET @term_start = DATEADD(day, 1, @term_start)
		IF @term_frequency = 'm'
			SET @term_start = DATEADD(m, DATEDIFF(m, -1, @term_start), 0) 
	END
	
	SET @term_end = dbo.FNAGetTermEndDate(@term_frequency, @term_start, 0)

	----TRANSPOSE COLUMNS TO ROWS
	IF OBJECT_ID('tempdb..#template_default_value') IS NOT NULL	
		DROP TABLE #template_default_value

	IF OBJECT_ID('tempdb..#template_header') IS NOT NULL	
		DROP TABLE #template_header

	IF OBJECT_ID('tempdb..#template_detail') IS NOT NULL	
		DROP TABLE #template_detail
	
	CREATE TABLE #template_default_value (
		sno            INT IDENTITY(1, 1),
		clm_name       NVARCHAR(50) COLLATE DATABASE_DEFAULT ,
		clm_value      NVARCHAR(150) COLLATE DATABASE_DEFAULT ,
		header_detail  NCHAR(1) COLLATE DATABASE_DEFAULT 
	)

	SELECT column_name,
			data_type 
	INTO #template_header
	FROM INFORMATION_SCHEMA.Columns
	WHERE TABLE_NAME = 'source_deal_header_template' 

	SELECT column_name,
			data_type 
	INTO #template_detail
	FROM   INFORMATION_SCHEMA.Columns
	WHERE  TABLE_NAME = 'source_deal_detail_template' 		

	DECLARE @select_list NVARCHAR(MAX)
	SELECT @select_list = COALESCE(@select_list + ' UNION ALL ', '') + ' SELECT ''' + column_name + ''',' +  CASE WHEN data_type = 'datetime' THEN ' LTRIM(RTRIM(dbo.FNAGetSQLStandardDate(NULLIF(' + column_name + ',''1900-01-01 00:00:00.000''))))'  ELSE 'CAST(LTRIM(RTRIM(' + column_name + ')) AS NVARCHAR(100))' END + ',''h'' FROM source_deal_header_template WHERE template_id = ' + CAST(@template_id AS NVARCHAR(10))
	FROM #template_header

	SELECT @select_list = COALESCE(@select_list + ' UNION ', '') + ' SELECT ''' + column_name + ''',' +  CASE WHEN data_type = 'datetime' THEN ' LTRIM(RTRIM(dbo.FNAGetSQLStandardDate(NULLIF(' + column_name + ',''1900-01-01 00:00:00.000''))))'  ELSE 'CAST(LTRIM(RTRIM(' + column_name + ')) AS NVARCHAR(100))' END + ',''d'' FROM source_deal_detail_template WHERE ISNULL(leg, 1) = 1 and template_id = ' + CAST(@template_id AS NVARCHAR(10))
	FROM #template_detail

	INSERT INTO #template_default_value(clm_name,clm_value,header_detail)
	EXEC(@select_list)

	UPDATE #template_default_value
	SET    clm_name = 'header_buy_sell_flag'
	WHERE  clm_name = 'buy_sell_flag'
	AND header_detail = 'h'

	IF @process_id IS NULL
		SET @process_id = REPLACE(NEWID(), '-', '_')   
	
	IF @process_table IS NULL
		SET @process_table = dbo.FNAProcessTableName('blotter_deal_insert', 'system', @process_id)      

	IF @process_table_detail IS NULL
		SET @process_table_detail = dbo.FNAProcessTableName('blotter_deal_insert_detail', 'system', @process_id)     

	IF OBJECT_ID('tempdb..#field_template_collection') IS NOT NULL
		DROP TABLE #field_template_collection

	CREATE TABLE #field_template_collection (
		farrms_field_id  NVARCHAR(100) COLLATE DATABASE_DEFAULT ,
		default_label    NVARCHAR(100) COLLATE DATABASE_DEFAULT ,
		field_group_seq  NVARCHAR(50) COLLATE DATABASE_DEFAULT ,
		seq_no           INT,
		header_detail    NCHAR(1) COLLATE DATABASE_DEFAULT ,
		field_id         NVARCHAR(50) COLLATE DATABASE_DEFAULT ,
		field_type       NVARCHAR(50) COLLATE DATABASE_DEFAULT ,
		default_value    NVARCHAR(150) COLLATE DATABASE_DEFAULT ,
		leg              INT,
		udf_or_system    NCHAR(1) COLLATE DATABASE_DEFAULT ,
		hide_control     NVARCHAR(50) COLLATE DATABASE_DEFAULT ,
		original_field_type NCHAR(1) COLLATE DATABASE_DEFAULT ,
		sql_string		 NVARCHAR(4000) COLLATE DATABASE_DEFAULT,
		json_data		 NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		is_required		 NVARCHAR(20) COLLATE DATABASE_DEFAULT 
	)
		
	INSERT into #field_template_collection(farrms_field_id,default_label,field_group_seq,seq_no,header_detail,field_id,field_type,default_value,leg,udf_or_system,hide_control, original_field_type, sql_string, is_required)
	SELECT *
	FROM   (
			SELECT LOWER(mfd.farrms_field_id) farrms_field_id,
					CASE WHEN mfd.farrms_field_id IN ('deal_volume','deal_volume_uom_id','fixed_price','fixed_cost','fixed_price_currency_id') THEN '<div style=\"width:100%; text-align:right;\">'+ ISNULL(mftd.field_caption, mfd.default_label) +'</div>'  ELSE '<div style=\"width:100%; text-align:left;\">'+ ISNULL(mftd.field_caption, mfd.default_label) +'</div>' END  
					default_label,
					ISNULL(mftg.seq_no, 1000) field_group_seq,
					ISNULL(mftd.seq_no, 1000) seq_no,
					mfd.header_detail,
					CAST(mfd.field_id AS NVARCHAR) field_id,
					CASE 
						WHEN mfd.data_type = 'price' THEN 'ed_p'
						WHEN mfd.data_type = 'number' THEN 'ed_no'
						ELSE  CASE field_type
								WHEN 'c' THEN 'combo'
								WHEN 'd' THEN 'combo'
								WHEN 't' THEN 'ed'
								WHEN 'a' THEN 'dhxCalendarA'
								WHEN 'w' THEN 'win_link_custom'
								ELSE 'ro'
							END
					END field_type,
					CAST(mftd.default_value AS NVARCHAR) default_value,
					NULL AS leg,
					's' udf_or_system,
					CASE WHEN ISNULL(mftd.hide_control,'n') = 'n' THEN 'false' ELSE 'true' END hide_control,
					mfd.field_type original_field_type,
					CASE WHEN LOWER(mfd.farrms_field_id) = 'status' 
								THEN 'SELECT sdv.value_id,sdv.code, ''enable'' state FROM deal_fields_mapping_detail_status dfs
										INNER JOIN  deal_fields_mapping dfm
											ON dfm.deal_fields_mapping_id = dfs.deal_fields_mapping_id
										LEFT JOIN static_data_value sdv 
											ON sdv.value_id = dfs.detail_status_id AND sdv.type_id = 25000
										WHERE dfm.template_id  = ' + CAST(@template_id as NVARCHAR)									  
							    ELSE mfd.sql_string 
						 END [sql_string],
					CASE WHEN ISNULL(mftd.value_required, 'n') = 'y' THEN 'true' ELSE 'false' END [value_required]
			FROM maintain_field_deal mfd
			JOIN maintain_field_template_detail mftd
				ON  mftd.field_id = mfd.field_id
				AND mftd.field_template_id = @field_template_id
				AND ISNULL(mftd.udf_or_system, 's') = 's'
			LEFT JOIN maintain_field_template_group mftg
				ON  mftg.field_group_id = mftd.field_group_id
				AND mftg.field_template_id = @field_template_id
			WHERE  mfd.farrms_field_id NOT IN ('source_deal_header_id', 
												'source_deal_detail_id', 
												'create_user', 'create_ts', 
												'update_user', 'update_ts', 
												'template_id', 
												'entire_term_start', 
												'entire_term_end', 
												'fixed_float_leg')
					AND ISNULL(mftd.hide_control, 'n') = 'n'
					AND ISNULL(mftd.insert_required, 'n') = 'y'
			UNION ALL 
			SELECT CASE WHEN udft.udf_type = 'h' THEN 'UDF___' + CAST(udft.udf_template_id AS NVARCHAR)
						ELSE 'UDF___' + CAST(udft.udf_template_id AS NVARCHAR)
					END udf_template_id,
					ISNULL(mftd.field_caption, udft.Field_label) 
					default_label,
					ISNULL(mftg.seq_no, 1000) field_group_seq,
					ISNULL(mftd.seq_no, 1000) seq_no,
					udft.udf_type header_detail,
					'u--' + CAST(udft.udf_template_id AS NVARCHAR) field_id,
					CASE 
						WHEN udft.data_type = 'price' THEN 'ed_p'
						WHEN udft.data_type = 'number' THEN 'ed_no'
						ELSE  CASE udft.field_type
								WHEN 'c' THEN 'combo'
								WHEN 'd' THEN 'combo'
								WHEN 't' THEN 'ed'
								WHEN 'a' THEN 'dhxCalendarA'
								WHEN 'w' THEN 'win_link_custom'
								WHEN 'e' THEn 'time' 
								ELSE 'ro'
							END
					END field_type,
					COALESCE(CAST(mftd.default_value AS NVARCHAR), CAST(uddft.default_value AS NVARCHAR(500)), CAST(udft.default_value AS NVARCHAR(500))) default_value,
					uddft.leg,
					'u' udf_or_system,
					CASE WHEN ISNULL(mftd.hide_control,'n') = 'n' THEN 'false' ELSE 'true' END hide_control,
					udft.field_type original_field_type,
					ISNULL(NULLIF(udft.sql_string, ''), uds.sql_string) sql_string,
					CASE WHEN ISNULL(mftd.value_required, 'n') = 'y' THEN 'true' ELSE 'false' END
			FROM maintain_field_template_detail mftd
			INNER JOIN user_defined_fields_template udft
				ON  mftd.field_id = udft.udf_template_id
				AND mftd.udf_or_system = 'u'
			INNER JOIN user_defined_deal_fields_template uddft
				ON  uddft.field_name = udft.field_name
			LEFT JOIN maintain_field_template_group mftg
				ON  mftg.field_group_id = mftd.field_group_id
				AND mftg.field_template_id = @field_template_id
			LEFT JOIN udf_data_source uds 
				ON uds.udf_data_source_id = udft.data_source_type_id
			WHERE  ISNULL(mftd.hide_control, 'n') = 'n'
					AND ISNULL(mftd.insert_required, 'n') = 'y'
					AND mftd.field_template_id = @field_template_id
					AND ISNULL(mftd.udf_or_system, 's') = 'u'
					AND uddft.template_id = @template_id
			UNION ALL
			SELECT LOWER(mfd.farrms_field_id) farrms_field_id,
					ISNULL(mftd.field_caption, mfd.default_label) 
					default_label,
					ISNULL(mftg.seq_no, 1000) field_group_seq,
					ISNULL(mftd.seq_no, 1000) seq_no,
					mfd.header_detail,
					CAST(mfd.field_id AS NVARCHAR) field_id,
					CASE 
						WHEN mfd.data_type = 'price' AND ISNULL(mftd.is_disable, 'n') = 'y' THEN 'ro_p'
						WHEN mfd.data_type = 'number' AND ISNULL(mftd.is_disable, 'n') = 'y' THEN 'ro_no'
						WHEN mfd.data_type = 'price' THEN 'ed_p'
						WHEN mfd.data_type = 'number' THEN 'ed_no'
						ELSE  CASE field_type
								WHEN 'c' THEN CASE WHEN ISNULL(mftd.is_disable, 'n') = 'y' THEN 'ro_combo' ELSE 'combo' END
								WHEN 'd' THEN CASE WHEN ISNULL(mftd.is_disable, 'n') = 'y' THEN 'ro_combo' ELSE 'combo' END
								WHEN 't' THEN CASE WHEN ISNULL(mftd.is_disable, 'n') = 'y' THEN 'ro' ELSE 'ed' END
								WHEN 'e' THEN CASE WHEN ISNULL(mftd.is_disable, 'n') = 'y' THEN 'time' ELSE 'time' END
								WHEN 'a' THEN CASE WHEN ISNULL(mftd.is_disable, 'n') = 'y' THEN 'ro_dhxCalendarA' ELSE 'dhxCalendarA' END
								WHEN 'w' THEN CASE WHEN ISNULL(mftd.is_disable, 'n') = 'y' THEN 'ro_win_link_custom' ELSE 'win_link_custom' END
								ELSE 'ro'
							END
					END field_type,
					CAST(mftd.default_value AS NVARCHAR) default_value,
					NULL AS leg,
					's' udf_or_system,
					CASE WHEN ISNULL(mftd.hide_control,'n') = 'n' THEN 'false' ELSE 'true' END hide_control,
					mfd.field_type original_field_type,
					mfd.sql_string,
					CASE WHEN ISNULL(mftd.value_required, 'n') = 'y' THEN 'true' ELSE 'false' END
			FROM   maintain_field_deal mfd
			JOIN maintain_field_template_detail mftd
				ON  mftd.field_id = mfd.field_id
				AND mftd.field_template_id = @field_template_id
				AND ISNULL(mftd.udf_or_system, 's') = 's'
			LEFT JOIN maintain_field_template_group mftg
				ON  mftg.field_group_id = mftd.field_group_id
				AND mftg.field_template_id = @field_template_id
			WHERE  mfd.farrms_field_id IN ('fixed_float_leg')	                  
	) l 
	ORDER BY header_detail DESC, field_group_seq, ISNULL(l.seq_no, 10000)

	
	SELECT @formula_fields_detail = COALESCE(@formula_fields_detail + ',', '') + farrms_field_id
 	FROM #field_template_collection
 	WHERE original_field_type = 'w' AND header_detail = 'd'
 	
 	IF @formula_fields_detail IS NOT NULL
 	BEGIN
 		 SET @sql = '
 				 CREATE TABLE ' + @detail_formula_process_table + ' (
 		 			[id]                        INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
 		 			[row_id]				    NVARCHAR(20) NULL,
 		 			[leg]						NVARCHAR(20) NULL,
 		 			[source_deal_detail_id]     NVARCHAR(100) NULL,
 		 			[source_deal_group_id]      NVARCHAR(100) NULL,
 		 			[udf_template_id]           INT NULL,
 		 			[udf_value]                 NVARCHAR(2000) NULL
 				 )'
 		  EXEC(@sql)
 	END

	IF EXISTS(SELECT 1 FROM #field_template_collection WHERE [farrms_field_id] = 'sub_book')
	BEGIN
		UPDATE temp
		SET [default_value] = ISNULL(@sub_book, [default_value])
		FROM #field_template_collection temp
		WHERE [farrms_field_id] = 'sub_book'
	END
	
	IF EXISTS(SELECT 1 FROM #field_template_collection WHERE [farrms_field_id] = 'internal_counterparty')
	BEGIN

		DECLARE @transfer_rules_cpty INT
		SELECT @transfer_rules_cpty = counterparty_id_to FROM deal_transfer_mapping 
			WHERE source_book_mapping_id_from = @sub_book

		DECLARE @internal_cpty_id INT
		
		SELECT @internal_cpty_id = coalesce(@transfer_rules_cpty, ssbm.primary_counterparty_id, fs.counterparty_id)
		FROM source_system_book_map ssbm
		INNER JOIN fas_books fb ON fb.fas_book_id = ssbm.fas_book_id
		INNER JOIN portfolio_hierarchy ph_book ON ph_book.[entity_id] = fb.fas_book_id
		INNER JOIN portfolio_hierarchy ph_st ON ph_st.[entity_id] = ph_book.parent_entity_id
		INNER JOIN portfolio_hierarchy ph_sub ON ph_sub.[entity_id] = ph_st.parent_entity_id
		INNER JOIN fas_subsidiaries fs ON ph_sub.[entity_id] = fs.fas_subsidiary_id
		WHERE ssbm.book_deal_type_map_id = @sub_book
				
		SELECT @internal_cpty_id = ISNULL(@internal_cpty_id, counterparty_id)
		FROM   fas_subsidiaries
		WHERE fas_subsidiary_id = -1		
		
		UPDATE temp
		SET [default_value] = @internal_cpty_id
		FROM #field_template_collection temp
		WHERE [farrms_field_id] = 'internal_counterparty'
	END


	DECLARE @check_fix_float NVARCHAR(10)
	SELECT @check_fix_float = [default_value] FROM #field_template_collection WHERE [farrms_field_id] IN ('fixed_float_leg')

	UPDATE #field_template_collection
	SET default_value = CASE 
								WHEN f.farrms_field_id = 'deal_date' AND f.default_value IS NULL THEN dbo.FNAGetSQLStandardDate(@deal_date)
								WHEN f.farrms_field_id = 'term_start' AND f.default_value IS NULL THEN dbo.FNAGetSQLStandardDate(@term_start)
								WHEN f.farrms_field_id = 'term_end' AND f.default_value IS NULL THEN dbo.FNAGetSQLStandardDate(@term_end)
								WHEN f.farrms_field_id = 'contract_expiration_date' AND t.clm_value IS NULL THEN dbo.FNAGetSQLStandardDate(@term_end)
								WHEN f.original_field_type = 'a' AND f.default_value IS NOT NULL THEN dbo.FNAGetSQLStandardDate (ISNULL(t.clm_value, f.default_value)) --convert date in formate yyyy-mm-dd
								ELSE ISNULL(t.clm_value, f.default_value) 
						END
	FROM #field_template_collection f
	LEFT OUTER JOIN #template_default_value t
		ON  f.farrms_field_id = t.clm_name
		AND f.header_detail = t.header_detail
	
	UPDATE ft
	SET ft.default_value = CASE 
								WHEN uddft.field_type = 'a' THEN dbo.FNAGetSQLStandardDate(ISNULL(uddft.default_value, ft.default_value))
								ELSE ISNULL(NULLIF(uddft.default_value, ''), ft.default_value)
							END
	FROM #field_template_collection ft
	INNER JOIN user_defined_deal_fields_template uddft
		ON  REPLACE(ft.farrms_field_id, 'UDF___', '') = uddft.udf_user_field_id
		AND ft.udf_or_system = 'u'
		AND ISNULL(ft.leg, 0) = ISNULL(uddft.leg, 0)
	WHERE  uddft.template_id = @template_id 	


	DECLARE @field_id NVARCHAR(500), @header_detail NCHAR(1), @sql_string NVARCHAR(MAX), @field_type NVARCHAR(10), @default_value NVARCHAR(10), @is_required NVARCHAR(20)
	DECLARE dropdown_cursor CURSOR FORWARD_ONLY READ_ONLY 
	FOR
		SELECT farrms_field_id,
			   header_detail,
			   sql_string,
			   field_type,
			   default_value,
			   is_required           
		FROM #field_template_collection
		WHERE original_field_type IN ('d', 'c') AND sql_string IS NOT NULL

	OPEN dropdown_cursor
	FETCH NEXT FROM dropdown_cursor INTO @field_id, @header_detail, @sql_string, @field_type, @default_value, @is_required                                    
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @json nvarchar(max)
		DECLARE @nsql NVARCHAR(MAX)
	
		IF OBJECT_ID('tempdb..#temp_combo') IS NOT NULL
			DROP TABLE #temp_combo
	
		CREATE TABLE #temp_combo ([value] NVARCHAR(10) COLLATE DATABASE_DEFAULT, [text] NVARCHAR(1000) COLLATE DATABASE_DEFAULT, [state] NVARCHAR(10) DEFAULT 'enable' COLLATE DATABASE_DEFAULT, selected NVARCHAR(10) COLLATE DATABASE_DEFAULT)
				
		IF @is_required = 'false'
		BEGIN
			INSERT INTO #temp_combo([value], [text])
			SELECT '', ''
		END
		--SELECT * FROM maintain_field_deal mfd WHERE mfd.farrms_field_id LIKE '%deal_type%'
		DECLARE @type NCHAR(1)
		SET @type = SUBSTRING(@sql_string, 1, 1)
		
		IF @type = '['
		BEGIN
			SET @sql_string = REPLACE(@sql_string, NCHAR(13), '')
			SET @sql_string = REPLACE(@sql_string, NCHAR(10), '')
			SET @sql_string = REPLACE(@sql_string, NCHAR(32), '')	
			SET @sql_string = [dbo].[FNAParseStringIntoTable](@sql_string)  
			EXEC('INSERT INTO #temp_combo([value], [text])
				  SELECT value_id, code from (' + @sql_string + ') a(value_id, code)');
		END 
		ELSE IF @field_id = 'source_deal_type_id' AND @is_admin = 0
		BEGIN
			INSERT INTO #temp_combo([value], [text])
			SELECT DISTINCT sdt.source_deal_type_id, sdt.source_deal_type_name
			FROM template_mapping tm 
			INNER JOIN source_deal_type sdt ON tm.deal_type_id = sdt.source_deal_type_id
			INNER JOIN template_mapping_privilege tmp 
				ON tmp.template_mapping_id = tm.template_mapping_id
				AND (tmp.[user_id] = @user_name OR tmp.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(@user_name) fur))
			WHERE tm.template_id = @template_id
			ORDER BY sdt.source_deal_type_name
		END
		ELSE IF @field_id = 'commodity_id' AND @is_admin = 0
		BEGIN
			INSERT INTO #temp_combo([value], [text])
			SELECT DISTINCT sc.source_commodity_id, sc.commodity_name
			FROM template_mapping tm 
			INNER JOIN source_commodity sc ON tm.commodity_id = sc.source_commodity_id
			INNER JOIN template_mapping_privilege tmp
				ON tmp.template_mapping_id = tm.template_mapping_id
				AND (tmp.[user_id] = @user_name OR tmp.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(@user_name) fur))
			WHERE tm.template_id = @template_id
			ORDER BY sc.commodity_name
		END
		ELSE
		BEGIN
			BEGIN TRY				
				INSERT INTO #temp_combo([value], [text], [state])
				EXEC(@sql_string)
			END TRY
			BEGIN CATCH				
				INSERT INTO #temp_combo([value], [text])
				EXEC(@sql_string)
			END CATCH
		END
		
		UPDATE #temp_combo
		SET selected = 'true'
		WHERE value = @default_value
		
		IF NOT EXISTS (SELECT 1 FROM #temp_combo WHERE value = @default_value)
		BEGIN
			UPDATE #field_template_collection
			SET default_value = NULL
			WHERE farrms_field_id = @field_id
		END		
	
		DECLARE @dropdown_xml XML
		DECLARE @param NVARCHAR(100)
		SET @param = N'@dropdown_xml XML OUTPUT';

		SET @nsql = ' SET @dropdown_xml = (SELECT [value], [text], [state], [selected]
						FROM #temp_combo 
						FOR XML RAW (''row''), ROOT (''root''), ELEMENTS)'
	
		EXECUTE sp_executesql @nsql, @param,  @dropdown_xml = @dropdown_xml OUTPUT;
		SET @dropdown_xml = REPLACE(CAST(@dropdown_xml AS NVARCHAR(MAX)), '"', '\"')
		SET @json = dbo.FNAFlattenedJSON(@dropdown_xml)
			
		IF CHARINDEX('[', @json, 0) <= 0
			SET @json = '{"options":[' + @json + ']}'
		ELSE
			SET @json = '{"options":' + @json + '}' 
	
		UPDATE #field_template_collection
		SET json_data = @json
		WHERE farrms_field_id = @field_id
		AND header_detail = @header_detail
		
		FETCH NEXT FROM dropdown_cursor INTO @field_id, @header_detail, @sql_string, @field_type, @default_value, @is_required    
	END
	CLOSE dropdown_cursor
	DEALLOCATE dropdown_cursor

	DECLARE @field                    NVARCHAR(Max),
			@field_temp_detail        NVARCHAR(MAX),
			@field_process_detail     NVARCHAR(MAX),
			@field_detail			  NVARCHAR(MAX),
			@header_grid_labels		  NVARCHAR(MAX),
			@detail_grid_labels		  NVARCHAR(MAX),
			@dummy_header_value		  NVARCHAR(MAX),
			@dummy_detail_value		  NVARCHAR(MAX),
			@header_combo_list		  NVARCHAR(MAX),
			@detail_combo_list		  NVARCHAR(MAX),
			@header_menu_enable_list  NVARCHAR(2000),
			@detail_menu_enable_list  NVARCHAR(2000),
			@detail_filter_list		  NVARCHAR(MAX),
			@header_validator		  NVARCHAR(MAX),
			@detail_validator		  NVARCHAR(MAX)

	SELECT 
	@field = CASE WHEN header_detail = 'h' THEN COALESCE(@field + ',', '') + 
												CAST(farrms_field_id AS NVARCHAR(150)) + ' NVARCHAR(MAX) ' +  
												CASE WHEN default_value IS NOT NULL  THEN ' default ''' +  CASE WHEN original_field_type = 'a' THEN  dbo.FNAGetSQLStandardDate(default_value) ELSE  default_value END + '''' 
													 ELSE '' 
												END
				  ELSE @field 
			 END,
	@field_detail = CASE WHEN header_detail = 'd' THEN COALESCE(@field_detail + ',', '') + 
												CAST(farrms_field_id AS NVARCHAR(150)) + ' NVARCHAR(MAX) ' +  
												CASE WHEN default_value IS NOT NULL  THEN ' default ''' +  CASE WHEN original_field_type = 'a' THEN  dbo.FNAGetSQLStandardDate(default_value) ELSE  default_value END + '''' 
													 ELSE '' 
												END
						ELSE @field_detail 
					END,
	@field_temp_detail = CASE WHEN header_detail = 'd' AND farrms_field_id NOT LIKE 'udf%' THEN COALESCE(@field_temp_detail + ',', '') + 
												CASE WHEN original_field_type = 'a' AND default_value IS NOT NULL AND udf_or_system = 's' THEN '''' + dbo.FNAGetSQLStandardDate(default_value) + ''''
													 WHEN farrms_field_id NOT IN ('') THEN  CAST(farrms_field_id AS NVARCHAR)
													 ELSE ''
												END
							  ELSE @field_temp_detail 
						END,
	@field_process_detail = CASE WHEN header_detail = 'd' AND farrms_field_id NOT LIKE 'udf%' THEN COALESCE(@field_process_detail + ',', '') + 
												CASE WHEN farrms_field_id NOT IN ('') THEN  CAST(farrms_field_id AS NVARCHAR)
													 ELSE ''
												END
								 ELSE @field_process_detail 
							END,
	@header_grid_labels = CASE WHEN header_detail = 'd' THEN @header_grid_labels
							   ELSE COALESCE(@header_grid_labels + ',', '') + '{"id":"' + farrms_field_id +  '", "hidden":' + hide_control + ', "align":"' + CASE WHEN farrms_field_id IN ('deal_volume','deal_volume_uom_id','fixed_price','fixed_cost','fixed_price_currency_id') THEN 'right' ELSE 'left' END  + '", "sort":"' + CASE WHEN field_type = 'dhxCalendarA' THEN 'date' ELSE 'str' END + '", "width":"150", "type":"' + field_type + '", "value":"' + default_label + '"}'
						  END,
	@detail_grid_labels = CASE WHEN header_detail = 'h' THEN @detail_grid_labels
							   ELSE COALESCE(@detail_grid_labels + ',', '') + '{"id":"' + farrms_field_id +  '", "hidden":' + hide_control + ', "align":"' + CASE WHEN farrms_field_id IN ('deal_volume','deal_volume_uom_id','fixed_price','fixed_cost','fixed_price_currency_id') THEN 'right' ELSE 'left' END  + '", "sort":"' + CASE WHEN field_type = 'dhxCalendarA' THEN 'date' ELSE 'str' END + '", "width":"150", "type":"' + field_type + '", "value":"' + default_label + '"}'
						  END,
	@dummy_header_value = CASE WHEN header_detail = 'd' THEN @dummy_header_value
							   ELSE COALESCE(@dummy_header_value + ',', '') + '""'
						  END,
	@dummy_detail_value = CASE WHEN header_detail = 'h' THEN @dummy_detail_value
							   ELSE COALESCE(@dummy_detail_value + ',', '') + '""'
						  END,
	@header_combo_list = CASE WHEN header_detail = 'h' AND original_field_type IN ('d', 'c') AND ft.json_data IS NOT NULL THEN COALESCE(@header_combo_list + '||||', '') + ft.farrms_field_id + '::::' + ft.json_data ELSE @header_combo_list END,
	@detail_combo_list = CASE WHEN header_detail = 'd' AND original_field_type IN ('d', 'c')  AND ft.json_data IS NOT NULL THEN COALESCE(@detail_combo_list + '||||', '') + ft.farrms_field_id + '::::' + ft.json_data ELSE @detail_combo_list END,
	@header_menu_enable_list = CASE WHEN ft.header_detail = 'h' THEN COALESCE(@header_menu_enable_list + ',', '') + CASE WHEN ft.hide_control = 'true' THEN 'false' ELSE 'true' END ELSE @header_menu_enable_list END,
	@detail_menu_enable_list = CASE WHEN ft.header_detail = 'd' THEN COALESCE(@detail_menu_enable_list + ',', '') + CASE WHEN ft.hide_control = 'true' THEN 'false' ELSE 'true' END ELSE @detail_menu_enable_list END,
	@detail_filter_list = CASE WHEN ft.header_detail = 'd' THEN COALESCE(@detail_filter_list + ',', '') + CASE ft.original_field_type WHEN 'a' THEN '#daterange_filter' WHEN 'c' THEN '#combo_filter' ELSE '#text_filter' END ELSE @detail_filter_list END,
	@header_validator = CASE WHEN header_detail = 'h' THEN COALESCE(@header_validator + ',', '') + CASE WHEN ft.is_required = 'true' AND ft.farrms_field_id <> 'deal_id' THEN 'NotEmpty' ELSE '' END ELSE @header_validator END,
	@detail_validator = CASE WHEN header_detail = 'd' THEN COALESCE(@detail_validator + ',', '') + CASE WHEN ft.is_required = 'true' THEN 'NotEmpty' ELSE '' END ELSE @detail_validator END
	FROM #field_template_collection ft
	WHERE  ISNULL(leg, 1) = 1
	ORDER BY header_detail DESC, ft.field_group_seq, ft.seq_no
	
	DECLARE @original_detail_labels NVARCHAR(MAX) = '{"head":[' + @detail_grid_labels + '],"rows":[{"id":1, "data":[' + @dummy_detail_value  + ']}]}'
	SET @header_grid_labels='{"head":[{"id": "row_id", "hidden": false, "width": 50, "type": "sub_row_grid", "value":""},' + @header_grid_labels + '],"rows":[{"id":1, "data":[' + @dummy_header_value + ']}]}'
	SET @detail_grid_labels='{"head":[{"id": "img_link", "hidden": false, "width":50, "type": "img", "value":""},{"id": "row_id", "hidden": true, "width": 30, "type": "ro", "value":""},{"id": "blotterleg", "align":"left", "offsetLeft":0, "hidden": true, "width": 50, "type": "ro", "value":""},' + @detail_grid_labels + '],"rows":[{"id":1, "data":[' + @dummy_detail_value  + ']}]}'

	SET @sql = ' CREATE TABLE ' + @process_table + '(
					Row_id int,
					blotterleg INT,
					' + @field + 
				')'	
	--exec spa_print @sql
	EXEC (@sql)

	SET @sql = ' CREATE TABLE ' + @process_table_detail + '(
					Row_id int,
					blotterleg INT,
					' + @field_detail   + 
				')'
	--exec spa_print @sql
	EXEC (@sql)

	IF OBJECT_ID('tempdb..#temp_no_of_deals_header') IS NOT NULL
		DROP TABLE #temp_no_of_deals_header
	CREATE TABLE #temp_no_of_deals_header (num INT)
	
	;WITH gen AS (
		SELECT 1 AS num
		UNION ALL
		SELECT num+1 FROM gen WHERE num+1<=@no_of_row
	)
	INSERT INTO #temp_no_of_deals_header (num)
	SELECT num FROM gen
	option (maxrecursion 0)

	SET @sql = ' INSERT INTO ' + @process_table_detail + ' (
					Row_id,
					blotterleg,
					' + @field_process_detail + '
					)
				SELECT a.num,
						leg,
						' + @field_temp_detail + '
				FROM   source_deal_detail_template sddt
				OUTER APPLY (SELECT num FROM #temp_no_of_deals_header) a
				WHERE  template_id = ' + CAST(@template_id AS NVARCHAR(20))	
	--exec spa_print @sql		
	EXEC(@sql)	



	SET @sql = '';
	SELECT  @sql += ' UPDATE ' + @process_table_detail + '
						SET ' + farrms_field_id + ' = ''' + ISNULL(default_value, '') + '''
					WHERE blotterleg = ' + CAST(leg AS NVARCHAR(10))	
	FROM #field_template_collection 
	WHERE udf_or_system = 'u' 
		AND header_detail = 'd' 
	
	EXEC(@sql)

	SET @sql = ' INSERT INTO ' + @process_table + ' (
					Row_id
					)
				SELECT DISTINCT Row_id
				FROM ' + @process_table_detail	
	EXEC(@sql)	

	DECLARE @sql_pre             NVARCHAR(MAX),
			@sql_pre_detail      NVARCHAR(MAX)

	SELECT @sql_pre = CASE WHEN ft.header_detail = 'h' THEN COALESCE(@sql_pre + ',', '') + CASE WHEN ft.field_type = 'ro' AND ft.original_field_type = 'a' THEN ' dbo.FNADateFormat(' + ft.farrms_field_id + ') AS ' + ft.farrms_field_id ELSE ft.farrms_field_id END ELSE @sql_pre END,
		   @sql_pre_detail = CASE WHEN ft.header_detail = 'd' THEN COALESCE(@sql_pre_detail + ',', '') + CASE WHEN ft.field_type = 'ro' AND ft.original_field_type = 'a' THEN ' dbo.FNADateFormat(' + ft.farrms_field_id + ') AS ' + ft.farrms_field_id ELSE ft.farrms_field_id END ELSE @sql_pre_detail END
	FROM   #field_template_collection ft
	WHERE  ISNULL(leg, 1) = 1
	ORDER BY ft.header_detail DESC, ft.field_group_seq, ft.seq_no

	-------------------------Start:Added to get default trader defined in Maintain Defination for particular user login----------------------------------
	DECLARE @trader_hide_check NCHAR(1)
	DECLARE @is_disable NCHAR(1)

	SELECT @trader_hide_check = mftd.hide_control,
		   @is_disable = mfd.is_disable
	FROM maintain_field_deal mfd
	JOIN maintain_field_template_detail mftd
		ON  mftd.field_id = mfd.field_id
		AND mftd.field_template_id = @field_template_id
		AND ISNULL(mftd.udf_or_system, 's') = 's'
		AND ISNULL(mftd.insert_required, 'n') = 'y'
	WHERE mfd.farrms_field_id  IN ('trader_id')

	DECLARE @trader_id   NVARCHAR(50)
	DECLARE @sql_trader  NVARCHAR(2000)

	IF @trader_hide_check = 'n'
	BEGIN
		SELECT @trader_id = CASE WHEN @is_disable = 'y' THEN MAX(st.trader_name) ELSE CAST(MAX(st.source_trader_id) AS NVARCHAR(10)) END
		FROM source_traders st
		WHERE st.user_login_id = dbo.FNADBUser()
	
		IF @trader_id IS NOT NULL
		BEGIN
			SET @sql_trader = 'UPDATE ' + @process_table + ' SET trader_id = ' + @trader_id	  
			EXEC(@sql_trader)
		END
	END

	-------------------------END-----------------------------------------------------------------------------------------------------------------------
	IF OBJECT_ID('tempdb..#grid_definition') IS NOT NULL
		DROP TABLE #grid_definition
		
	CREATE TABLE #grid_definition(
		header_detail              NVARCHAR(50) COLLATE DATABASE_DEFAULT ,
		config_json				   NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
		query					   NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
		combo_list				   NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		process_table			   NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
		process_id				   NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
		header_menu_list		   NVARCHAR(2000) COLLATE DATABASE_DEFAULT ,
		validation_rule			   NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
		term_frequency         NCHAR(1) COLLATE DATABASE_DEFAULT,
		formula_fields         NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		formula_process_id     NVARCHAR(200) COLLATE DATABASE_DEFAULT
	)
	--__IMAGE_PATH__edit
	DECLARE @first_col NVARCHAR(200)
	SET @first_col = '''edit.png^Edit Detail'''
	
	SET @formula_present = COL_LENGTH(@process_table_detail, 'formula_id')
	
	IF @formula_present IS NOT NULL
	BEGIN
		SET @sql = 'UPDATE temp
					SET formula_id = CAST(fe.formula_id AS NVARCHAR(200)) + ''^'' + dbo.FNAFormulaFormat(fe.formula, ''r'') 
					FROM ' + @process_table_detail + ' temp
					INNER JOIN formula_editor fe ON CAST(fe.formula_id AS NVARCHAR(2000)) = temp.formula_id'
		EXEC(@sql)
	END
	
	INSERT INTO #grid_definition (header_detail, config_json, query, combo_list, process_table, process_id, header_menu_list, validation_rule, term_frequency, formula_fields, formula_process_id)
	SELECT 'header', @header_grid_labels, 'SELECT  row_id, ' + @sql_pre + ' FROM ' + @process_table, @header_combo_list, @process_table, @process_id, 'false,' + @header_menu_enable_list, ',' + @header_validator, @term_frequency, NULL, NULL
	UNION ALL
	SELECT 'detail', @detail_grid_labels, 'SELECT  ' + @first_col + ', row_id, blotterleg, ' + @sql_pre_detail + ' FROM ' + @process_table_detail, @detail_combo_list, @process_table_detail, @process_id, 'false,false,false,' + @detail_menu_enable_list, ',,,' + @detail_validator, @term_frequency, @formula_fields_detail, CASE WHEN @formula_fields_detail IS NOT NULL THEN @formula_process_id ELSE NULL END

	SET @detail_config_table = dbo.FNAProcessTableName('detail_config_table', 'system', @process_id)
	
	SET @sql = 'CREATE TABLE ' + @detail_config_table + ' (config_string NVARCHAR(MAX), header_menu_list NVARCHAR(2000), combo_list NVARCHAR(MAX), field_list NVARCHAR(3000), filter_list NVARCHAR(MAX), validation_rule NVARCHAR(MAX)) 
			    INSERT INTO ' + @detail_config_table + ' (config_string, header_menu_list, combo_list, field_list, filter_list, validation_rule)
			    SELECT ''' + @original_detail_labels + ''', ''' + @detail_menu_enable_list + ''', ''' + REPLACE(@detail_combo_list, '''', '''''') + ''', ''' + @sql_pre_detail + ''', ''' + @detail_filter_list + ''', ''' + @detail_validator + '''
			   '
	--exec spa_print @sql
	EXEC(@sql)
	
	SELECT * FROM #grid_definition
	DROP TABLE #field_template_collection
	DROP TABLE #grid_definition
	RETURN
END
ELSE IF @flag = 'd'
BEGIN
	SET @detail_config_table = dbo.FNAProcessTableName('detail_config_table', 'system', @process_id)	
	EXEC('SELECT config_string, header_menu_list, combo_list, filter_list, validation_rule FROM ' + @detail_config_table)
END	
ELSE IF @flag = 'e'
BEGIN
	DECLARE @default_list NVARCHAR(2000)
	SET @process_table_detail = dbo.FNAProcessTableName('blotter_deal_insert_detail', 'system', @process_id)
	SET @detail_config_table = dbo.FNAProcessTableName('detail_config_table', 'system', @process_id)
	
	IF OBJECT_ID('tempdb..#detail_config_table') IS NOT NULL
		DROP TABLE #detail_config_table
	
	CREATE TABLE #detail_config_table (field_list NVARCHAR(2000) COLLATE DATABASE_DEFAULT )
	EXEC('INSERT INTO #detail_config_table(field_list) 
		  SELECT field_list FROM ' + @detail_config_table)
		  
	SELECT @default_list = COALESCE(@default_list + ',', '') + field_list
	FROM #detail_config_table
	
	IF OBJECT_ID('tempdb..#temp_terms') IS NOT NULL
		DROP TABLE #temp_terms 
	
	CREATE TABLE #temp_terms (term_start DATETIME, term_end DATETIME, unique_id NVARCHAR(200) COLLATE DATABASE_DEFAULT )		
	DECLARE @unique_id NVARCHAR(200) = dbo.FNAGetNewId()
	
	SELECT @term_frequency = ISNULL(@term_frequency, sdht.term_frequency_type) -- sdht.term_frequency_value, sdht.term_frequency_type, sdht.term_frequency
	FROM source_deal_header_template sdht
	WHERE sdht.template_id = @template_id
	--a	Annually
	--d	Daily
	--h	Hourly
	--m	Monthly
	--q	Quarterly
	--s	Semi-Annually
	
	IF @term_frequency <> 'h'
	BEGIN
		IF @term_frequency = 't'
		BEGIN
			INSERT INTO #temp_terms(term_start, term_end, unique_id)
			SELECT @term_start, @term_end, @unique_id
		END
		ELSE 
		BEGIN
			WITH cte AS (
				SELECT @term_start [term_start], dbo.FNAGetTermEndDate(@term_frequency, @term_start, 0) [term_end]
				UNION ALL
				SELECT dbo.FNAGetTermStartDate(@term_frequency, [term_start], 1), dbo.FNAGetTermEndDate(@term_frequency, dbo.FNAGetTermStartDate(@term_frequency, [term_start], 1), 0) 
				FROM cte WHERE dbo.FNAGetTermStartDate(@term_frequency, [term_start], 1) <= @term_end
			) 
			INSERT INTO #temp_terms(term_start, term_end, unique_id)
			SELECT term_start, term_end, @unique_id FROM cte
			option (maxrecursion 0)
		END
	END
	
	IF EXISTS (SELECT 1 FROM #temp_terms)
	BEGIN
		DECLARE @fields_list NVARCHAR(MAX),
				@insert_field_list NVARCHAR(MAX),
				@select_field_list NVARCHAR(MAX)
		
		SELECT @fields_list = COALESCE(@fields_list + ', ', '') + Column_name + ' ' + DATA_TYPE + CASE WHEN DATA_TYPE = 'NVARCHAR' THEN '(MAX)' ELSE '' END ,
			   @insert_field_list = COALESCE(@insert_field_list + ', ', '') + Column_name,
			   @select_field_list = COALESCE(@select_field_list + ', ', '') + 'temp.' + Column_name
		FROM adiha_process.INFORMATION_SCHEMA.Columns WITH(NOLOCK)
		WHERE TABLE_NAME = REPLACE(@process_table_detail, 'adiha_process.dbo.', '') 
		AND Column_name NOT IN ('term_start', 'term_end')
		
		SET @term_level_process_table = dbo.FNAProcessTableName('term_level_detail', 'system', @process_id) 
		SET @sql = '
					IF OBJECT_ID(''tempdb..#temp_detail_data'') IS NOT NULL
						DROP TABLE #temp_detail_data
						
					SELECT *, ''' + @unique_id + ''' AS temp_unique_id 
					INTO #temp_detail_data 
					FROM ' + @process_table_detail + ' 
					WHERE blotterleg = ' + CAST(@blotter_leg AS NVARCHAR(10)) + '
					AND row_id = ' + CAST(@no_of_row AS NVARCHAR(10)) + '
					
					IF OBJECT_ID(''' + @term_level_process_table + ''') IS NULL
					BEGIN
						CREATE TABLE ' + @term_level_process_table + ' (term_start DATETIME, term_end DATETIME, ' + @fields_list + ')
					END
										
					INSERT INTO ' + @term_level_process_table + ' (term_start, term_end, ' + @insert_field_list + ')
					SELECT tt.term_start, tt.term_end, ' + @select_field_list + '						
					FROM #temp_detail_data temp
					INNER JOIN #temp_terms tt ON temp.temp_unique_id = tt.unique_id
					LEFT JOIN ' + @term_level_process_table + ' npt ON tt.term_start = npt.term_start AND npt.term_end = tt.term_end AND temp.blotterleg = npt.blotterleg AND temp.row_id = npt.row_id
					WHERE npt.term_start IS NULL
					
					DELETE tlpt
					FROM ' + @term_level_process_table + ' tlpt
					LEFT JOIN (
						SELECT tt.term_start, tt.term_end, temp.blotterleg, temp.row_id
						 FROM #temp_detail_data temp 
						 INNER JOIN #temp_terms tt ON temp.temp_unique_id = tt.unique_id 
					) a ON a.term_start = tlpt.term_start AND tlpt.term_end = a.term_end AND a.blotterleg = tlpt.blotterleg AND tlpt.row_id = a.row_id
					WHERE a.term_start IS NULL AND tlpt.blotterleg = ' + CAST(@blotter_leg AS NVARCHAR(20)) + ' AND tlpt.row_id = ' + CAST(@no_of_row AS NVARCHAR(20)) + '
					
					
					SELECT ' + @default_list + '
					FROM ' + @term_level_process_table + ' temp 
					WHERE temp.blotterleg = ' + CAST(@blotter_leg AS NVARCHAR(10)) + '
					AND row_id = ' + CAST(@no_of_row AS NVARCHAR(10)) + '
					'  
		EXEC(@sql) 
	END
END
ELSE IF @flag IN ('u', 'x')
BEGIN
	SET @term_level_process_table = dbo.FNAProcessTableName('term_level_detail', 'system', @process_id)
	SET @process_table_detail = dbo.FNAProcessTableName('blotter_deal_insert_detail', 'system', @process_id)
	
	SET @update_process_table = dbo.FNAProcessTableName('detail_update_process_table', 'system', @update_process_id) 
	EXEC spa_parse_xml_file 'b', NULL, @xml, @update_process_table
	
	
	IF @flag = 'u'
	BEGIN
		SELECT @update_clause = COALESCE(@update_clause + ', ', '') + Column_name + ' = NULLIF(temp_update.' + Column_name + ','''')'
		FROM adiha_process.INFORMATION_SCHEMA.Columns WITH (NOLOCK)
		WHERE TABLE_NAME = REPLACE(@update_process_table, 'adiha_process.dbo.', '') 
		AND Column_name NOT IN ('term_start', 'term_end', 'leg', 'blotterleg')
	END
	ELSE 
	BEGIN
		SELECT @update_clause = COALESCE(@update_clause + ', ', '') + Column_name + ' = NULLIF(temp_update.' + Column_name + ','''')'
		FROM adiha_process.INFORMATION_SCHEMA.Columns WITH (NOLOCK)
		WHERE TABLE_NAME = REPLACE(@update_process_table, 'adiha_process.dbo.', '') 
		AND Column_name NOT IN ('leg', 'blotterleg')
	END
	
	IF OBJECT_ID(@term_level_process_table) IS NOT NULL
	BEGIN
		SET @sql = 'UPDATE temp_term
					SET ' + @update_clause + '
					FROM ' + @term_level_process_table + ' temp_term
					INNER JOIN ' + @update_process_table + ' temp_update
						ON temp_term.row_id = temp_update.row_id
						AND temp_term.blotterleg = temp_update.blotterleg '
	
		IF @flag = 'u'
		BEGIN
			SET @sql += '
						AND temp_term.term_start = temp_update.term_start
						AND temp_term.term_end = temp_update.term_end'
		END		
					
		EXEC(@sql)
	END
	
	IF @flag = 'x'
	BEGIN
		SET @sql = 'UPDATE temp_term
					SET ' + @update_clause + '
					FROM ' + @process_table_detail + ' temp_term
					INNER JOIN ' + @update_process_table + ' temp_update
						ON temp_term.row_id = temp_update.row_id
						AND temp_term.blotterleg = temp_update.blotterleg '
				
		EXEC(@sql)
	END
	
	SET @formula_present = COL_LENGTH(@update_process_table, 'formula_id')
	
	IF @formula_present IS NOT NULL
	BEGIN
		SET @sql = 'UPDATE temp
					SET formula_id = CAST(fe.formula_id AS NVARCHAR(200)) + ''^'' + dbo.FNAFormulaFormat(fe.formula, ''r'') 
					FROM ' + @process_table_detail + ' temp
					INNER JOIN formula_editor fe ON CAST(fe.formula_id AS NVARCHAR(2000)) = temp.formula_id'
		--exec spa_print @sql
		EXEC(@sql)
		
		IF OBJECT_ID(@term_level_process_table) IS NOT NULL
		BEGIN
			SET @sql = 'UPDATE temp
						SET formula_id = CAST(fe.formula_id AS NVARCHAR(200)) + ''^'' + dbo.FNAFormulaFormat(fe.formula, ''r'')
						FROM ' + @term_level_process_table + ' temp
						INNER JOIN formula_editor fe ON CAST(fe.formula_id AS NVARCHAR(2000)) = temp.formula_id'
				
			--exec spa_print @sql
			EXEC(@sql)
		END
	END
END
ELSE IF @flag = 'h'
BEGIN
	SET @term_level_process_table = dbo.FNAProcessTableName('term_level_detail', 'system', @process_id)
	
	SET @update_process_table = dbo.FNAProcessTableName('header_update_process_table', 'system', @update_process_id) 
	EXEC spa_parse_xml_file 'b', NULL, @xml, @update_process_table
	
	SELECT @update_clause = COALESCE(@update_clause + ', ', '') + Column_name + ' = NULLIF(temp_update.' + Column_name + ','''')'
	FROM adiha_process.INFORMATION_SCHEMA.Columns WITH (NOLOCK)
	WHERE TABLE_NAME = REPLACE(@update_process_table, 'adiha_process.dbo.', '') 
	AND Column_name NOT IN ('term_start', 'term_end', 'leg', 'blotterleg')
	
	SET @sql = 'UPDATE temp_term
				SET ' + @update_clause + '
	            FROM ' + @term_level_process_table + ' temp_term
	            INNER JOIN ' + @update_process_table + ' temp_update
					ON temp_term.row_id = temp_update.row_id
					AND temp_term.blotterleg = temp_update.blotterleg
					AND temp_term.term_start = temp_update.term_start
					AND temp_term.term_end = temp_update.term_end'
					
	EXEC(@sql)
END
ELSE IF @flag = 't'
BEGIN
	SELECT @term_rule = ISNULL(@term_rule, sdht.term_rule),
		   @term_frequency = ISNULL(@term_frequency, sdht.term_frequency_type)
	FROM  dbo.source_deal_header_template sdht
	WHERE sdht.template_id = @template_id 
	
	
	SELECT
			CASE WHEN sdv.value_id IN (19316, 19308) THEN DATEADD(DD, 1, @deal_date)
			WHEN sdv.value_id IN(19317) THEN CASE WHEN DATEADD(DD, 1, @deal_date) < DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @deal_date) + 1, 0)) THEN DATEADD(DD, 1, @deal_date) ELSE DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @deal_date) +1, 0)) END 
			WHEN sdv.value_id IN(19315) THEN CASE WHEN DATEADD(DD, 1, @deal_date) < DATEADD(day, DATEDIFF(DAY, 6, @deal_date-1) /7*7 + 6, 6) THEN DATEADD(DD, 1, @deal_date) ELSE DATEADD(day, DATEDIFF(DAY, 6, @deal_date-1) /7*7 + 6, 6) END --Balance of the Week
			WHEN sdv.value_id IN(19318) THEN CASE WHEN DATEADD(DD, 1, @deal_date) < DATEADD(dd, -1, DATEADD(yy, DATEDIFF(yy, 0, @deal_date) + 1, 0)) THEN DATEADD(DD, 1, @deal_date) ELSE DATEADD (dd, -1, DATEADD(yy, DATEDIFF(yy, 0, @deal_date) + 1, 0)) END --Balance of the Year
			WHEN sdv.value_id IN(19309) THEN dbo.FNAGetBusinessDay('n', @deal_date, NULL) -- working date to do
			WHEN sdv.value_id IN(19312) THEN DATEADD(dd, 1, EOMONTH(@deal_date)) -- Next Month
			WHEN sdv.value_id IN(19313) THEN DATEADD(qq, DATEDIFF(qq, 0, @deal_date) + 1, 0)  --Next Quarter
			WHEN sdv.value_id IN(19311) THEN DATEADD(DAY, 8 - DATEPART(WEEKDAY, @deal_date), CAST(@deal_date AS DATE))  --Next Week
			WHEN sdv.value_id IN(19314) THEN DATEADD(yy, DATEDIFF(yy, 0, @deal_date) + 1, 0)  --Next year
			WHEN sdv.value_id IN(19310) THEN DATEADD(DD, -1, @deal_date )  --Prior Day
			ELSE  @deal_date --Today
			END term_start
		, CASE WHEN sdv.value_id IN (19316) THEN  EOMONTH(DATEADD(DD, 1, @deal_date))
			WHEN sdv.value_id IN(19317) THEN DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @deal_date) +1, 0)) --quarter
			WHEN sdv.value_id IN(19315) THEN DATEADD(DAY, DATEDIFF(DAY, 6, @deal_date-1)/7*7 + 6, 6) -- Balance of the Week
			WHEN sdv.value_id IN(19318) THEN DATEADD(dd, -1, DATEADD(yy, DATEDIFF(yy, 0, @deal_date) + 1, 0)) --Balance of the Year
			WHEN sdv.value_id IN(19309) THEN dbo.FNAGetBusinessDay('n', @deal_date, NULL) -- working date  --to do
			WHEN sdv.value_id IN(19308) THEN DATEADD(DD, 1, @deal_date)
			WHEN sdv.value_id IN(19312) THEN EOMONTH(DATEADD(dd, 1, EOMONTH(@deal_date))) -- Next Month
			WHEN sdv.value_id IN(19313) THEN DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @deal_date) + 2, 0))  --Next Quarter
			WHEN sdv.value_id IN(19311) THEN DATEADD(DAY, 14 - DATEPART(WEEKDAY, @deal_date), CAST(@deal_date AS DATE))  --Next Week
			WHEN sdv.value_id IN(19314) THEN DATEADD (dd, -1, DATEADD(yy, DATEDIFF(yy, 0, @deal_date) +2, 0))  --Next year
			WHEN sdv.value_id IN(19310) THEN DATEADD(DD, -1, @deal_date )  --Prior Day
			ELSE 
				@deal_date --Today
			END term_end
	FROM  static_data_value sdv WHERE sdv.value_id = @term_rule
	/*
	SET @term_start = dbo.FNAResolveDate(@deal_date, @term_rule)

	IF @deal_date = @term_start AND (@term_rule IS NULL OR @term_rule <> 19307) --Exclude Today Logical Term (Make term start today date)
	BEGIN
		IF @term_frequency = 'd'
			SET @term_start = DATEADD(DAY, 1, @term_start)
		IF @term_frequency = 'm'
			SET @term_start = DATEADD(m, DATEDIFF(m, -1, @term_start), 0) 
	END
	
	IF @term_frequency = 't'
		SET @term_end = @term_start
	ELSE
	BEGIN
		IF NULLIF(@term_rule, '') IS NOT NULL
			SET @term_end = dbo.FNAGetLogicalTermEndDate(@term_rule, @term_start)
		ELSE
			SET @term_end = dbo.FNAGetTermEndDate(@term_frequency, @term_start, 0)
	END
	
	SELECT dbo.FNAGetSQLStandardDate(@term_start) term_start, dbo.FNAGetSQLStandardDate(@term_end) term_end
	*/ 
END
GO