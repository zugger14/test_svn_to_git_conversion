IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external([type_id] INT , [code] VARCHAR(500), [value_id] INT)
/*************** Insert Static Data Start *******************/
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'MIC Country')
BEGIN
	INSERT INTO static_data_value (type_id, code, description)
	OUTPUT INSERTED.type_id, INSERTED.code, INSERTED.value_id
		INTO #insert_output_sdv_external
	VALUES ('5500', 'MIC Country', 'MIC Country')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'MIC Country Code')
BEGIN
	INSERT INTO static_data_value (type_id, code, description)
	OUTPUT INSERTED.type_id, INSERTED.code, INSERTED.value_id
		INTO #insert_output_sdv_external
	VALUES ('5500', 'MIC Country Code', 'MIC Country Code')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'MIC')
BEGIN
	INSERT INTO static_data_value (type_id, code, description)
	OUTPUT INSERTED.type_id, INSERTED.code, INSERTED.value_id
		INTO #insert_output_sdv_external
	VALUES ('5500', 'MIC', 'MIC')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Operating MIC')
BEGIN
	INSERT INTO static_data_value (type_id, code, description)
	OUTPUT INSERTED.type_id, INSERTED.code, INSERTED.value_id
		INTO #insert_output_sdv_external
	VALUES ('5500', 'Operating MIC', 'Operating MIC')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'O/S')
BEGIN
	INSERT INTO static_data_value (type_id, code, description)
	OUTPUT INSERTED.type_id, INSERTED.code, INSERTED.value_id
		INTO #insert_output_sdv_external
	VALUES ('5500', 'O/S', 'O/S')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Name-Institution Desc')
BEGIN
	INSERT INTO static_data_value (type_id, code, description)
	OUTPUT INSERTED.type_id, INSERTED.code, INSERTED.value_id
		INTO #insert_output_sdv_external
	VALUES ('5500', 'Name-Institution Desc', 'Name-Institution Desc')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Acronym')
BEGIN
	INSERT INTO static_data_value (type_id, code, description)
	OUTPUT INSERTED.type_id, INSERTED.code, INSERTED.value_id
		INTO #insert_output_sdv_external
	VALUES ('5500', 'Acronym', 'Acronym')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'City')
BEGIN
	INSERT INTO static_data_value (type_id, code, description)
	OUTPUT INSERTED.type_id, INSERTED.code, INSERTED.value_id
		INTO #insert_output_sdv_external
	VALUES ('5500', 'City', 'City')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Website')
BEGIN
	INSERT INTO static_data_value (type_id, code, description)
	OUTPUT INSERTED.type_id, INSERTED.code, INSERTED.value_id
		INTO #insert_output_sdv_external
	VALUES ('5500', 'Website', 'Website')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Status Date')
BEGIN
	INSERT INTO static_data_value (type_id, code, description)
	OUTPUT INSERTED.type_id, INSERTED.code, INSERTED.value_id
		INTO #insert_output_sdv_external
	VALUES ('5500', 'Status Date', 'Status Date')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Status')
BEGIN
	INSERT INTO static_data_value (type_id, code, description)
	OUTPUT INSERTED.type_id, INSERTED.code, INSERTED.value_id
		INTO #insert_output_sdv_external
	VALUES ('5500', 'Status', 'Status')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Creation Date')
BEGIN
	INSERT INTO static_data_value (type_id, code, description)
	OUTPUT INSERTED.type_id, INSERTED.code, INSERTED.value_id
		INTO #insert_output_sdv_external
	VALUES ('5500', 'Creation Date', 'Creation Date')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Comments')
BEGIN
	INSERT INTO static_data_value (type_id, code, description)
	OUTPUT INSERTED.type_id, INSERTED.code, INSERTED.value_id
		INTO #insert_output_sdv_external
	VALUES ('5500', 'Comments', 'Comments')
END
/*************** Insert Static Data End *******************/

/*************** Insert UDF Start *******************/
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'MIC Country')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id, 'MIC Country', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, 400, iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE iose.[code] = 'MIC Country'
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'MIC Country Code')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id, 'MIC Country Code', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, 400, iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE iose.[code] = 'MIC Country Code'
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'MIC')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id, 'MIC', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, 400, iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE iose.[code] = 'MIC'
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'Operating MIC')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id, 'Operating MIC', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, 400, iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE iose.[code] = 'Operating MIC'
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'O/S')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id, 'O/S', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, 400, iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE iose.[code] = 'O/S'
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'Name-Institution Desc')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id, 'Name-Institution Desc', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, 400, iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE iose.[code] = 'Name-Institution Desc'
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'Acronym')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id, 'Acronym', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, 400, iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE iose.[code] = 'Acronym'
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'City')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id, 'City', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, 400, iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE iose.[code] = 'City'
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'Website')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id, 'Website', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, 400, iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE iose.[code] = 'Website'
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'Status Date')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id, 'Status Date', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, 400, iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE iose.[code] = 'Status Date'
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'Status')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id, 'Status', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, 400, iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE iose.[code] = 'Status'
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'Creation Date')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id, 'Creation Date', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, 400, iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE iose.[code] = 'Creation Date'
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'Comments')
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id, 'Comments', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, 400, iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE iose.[code] = 'Comments'
END
/*************** Insert UDF End *******************/
DECLARE @Country INT = (SELECT udf_template_id FROM user_defined_fields_template WHERE Field_label = 'MIC Country') 
DECLARE @Country_Code INT = (SELECT udf_template_id FROM user_defined_fields_template WHERE Field_label = 'MIC Country Code')
DECLARE @MIC INT = (SELECT udf_template_id FROM user_defined_fields_template WHERE Field_label = 'MIC') 
DECLARE @Operating_MIC INT = (SELECT udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Operating MIC') 
DECLARE @o_s INT = (SELECT udf_template_id FROM user_defined_fields_template WHERE Field_label = 'O/S')
DECLARE @Name_Institution_Desc INT = (SELECT udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Name-Institution Desc')
DECLARE @Acronym INT = (SELECT udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Acronym')
DECLARE @City INT = (SELECT udf_template_id FROM user_defined_fields_template WHERE Field_label = 'City')
DECLARE @Website INT = (SELECT udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Website')
DECLARE @Status_Date INT = (SELECT udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Status Date')
DECLARE @Status INT = (SELECT udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Status')
DECLARE @Creation_Date INT = (SELECT udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Creation Date')
DECLARE @Comments INT = (SELECT udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Comments')

/******************** Generic Mapping Header Start *****************************/
IF NOT EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'MIC List')
BEGIN
	INSERT INTO generic_mapping_header (mapping_name, total_columns_used)
	VALUES ('MIC List', 13)
END
/******************** Generic Mapping Header End *****************************/

/******************** Generic Mapping Definition Start *****************************/
IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id WHERE gmh.mapping_name = 'MIC List')
BEGIN
	INSERT INTO generic_mapping_definition (mapping_table_id, clm1_label, clm1_udf_id, clm2_label, clm2_udf_id, clm3_label, clm3_udf_id, clm4_label, clm4_udf_id, clm5_label, clm5_udf_id, clm6_label, clm6_udf_id, clm7_label, clm7_udf_id, clm8_label, clm8_udf_id, clm9_label, clm9_udf_id, clm10_label, clm10_udf_id, clm11_label, clm11_udf_id, clm12_label, clm12_udf_id, clm13_label, clm13_udf_id)
	SELECT mapping_table_id, 'Country', @Country, 'Country Code', @Country_Code, 'MIC', @MIC, 'Operating MIC', @Operating_MIC, 'O/S', @o_s, 'Name-Institution Desc', @Name_Institution_Desc, 'Acronym', @Acronym, 'City', @City, 'Website', @Website, 'Status Date', @Status_Date, 'Status', @Status, 'Creation Date', @Creation_Date, 'Comments', @Comments FROM generic_mapping_header WHERE mapping_name = 'MIC List'
END
/******************** Generic Mapping Definition End *****************************/
GO

DECLARE @mapping_table_id INT

SELECT @mapping_table_id = mapping_table_id 
FROM generic_mapping_header 
WHERE mapping_name = 'MIC List'

DELETE FROM generic_mapping_values WHERE mapping_table_id = @mapping_table_id

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ALBANIA','AL','XTIR','XTIR','O','TIRANA STOCK EXCHANGE','','TIRANA','','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ARMENIA','AM','XARM','XARM','O','NASDAQ OMX ARMENIA','ARMEX','YEREVAN','WWW.NASDAQOMX.COM','FEBRUARY 2011','ACTIVE','FEBRUARY 2011','NASDAQ OMX ARMENIA IS THE NEW NAME OF THE ARMENIAN STOCK EXCHANGE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'AUSTRIA','AT','EGSI','EGSI','O','ERSTE GROUP BANK AG','','VIENNA','WWW.ERSTEGROUP.COM','JANUARY 2017','ACTIVE','JANUARY 2017','SYSTEMATIC INTERNALISER.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'AUSTRIA','AT','XWBO','XWBO','O','WIENER BOERSE AG','','VIENNA','WWW.WIENERBOERSE.AT','NOVEMBER 2008','ACTIVE','NOVEMBER 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'AUSTRIA','AT','EXAA','XWBO','S','WIENER BOERSE AG, AUSTRIAN ENERGY EXCHANGE','EXAA','VIENNA','WWW.EXAA.AT','MAY 2016','ACTIVE','MAY 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'AUSTRIA','AT','WBAH','XWBO','S','WIENER BOERSE AG AMTLICHER HANDEL (OFFICIAL MARKET)','','VIENNA','WWW.WIENERBOERSE.AT','JULY 2007','ACTIVE','JULY 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'AUSTRIA','AT','WBDM','XWBO','S','WIENER BOERSE AG DRITTER MARKT (THIRD MARKET)','','VIENNA','WWW.WIENERBOERSE.AT','JULY 2007','ACTIVE','JULY 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'AUSTRIA','AT','WBGF','XWBO','S','WIENER BOERSE AG GEREGELTER FREIVERKEHR (SECOND REGULATED MARKET)','','VIENNA','WWW.WIENERBOERSE.AT','FEBRUARY 2015','ACTIVE','JULY 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'AUSTRIA','AT','XVIE','XWBO','S','WIENER BOERSE AG, WERTPAPIERBOERSE (SECURITIES EXCHANGE)','','VIENNA','WWW.WIENERBORSE.AT','APRIL 2011','ACTIVE','APRIL 2011','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BELARUS','BY','BCSE','BCSE','O','BELARUS CURRENCY AND STOCK EXCHANGE','BCSE','MINSK','WWW.BCSE.BY','AUGUST 2006','ACTIVE','AUGUST 2006','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BELGIUM','BE','BEAM','BEAM','O','MTS ASSOCIATED MARKETS','','BRUSSELS','WWW.MTSBELGIUM.COM','MAY 2017','ACTIVE','MAY 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BELGIUM','BE','BMTS','BEAM','S','MTS BELGIUM','','BRUSSELS','WWW.MTSBELGIUM.COM','MAY 2017','MODIFIED','NOVEMBER 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BELGIUM','BE','BLPX','BLPX','O','BELGIAN POWER EXCHANGE','BLPX','BRUSSELS','WWW.BELPEX.BE','NOVEMBER 2007','ACTIVE','NOVEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BELGIUM','BE','MTSD','BMTS','S','MTS DENMARK','','BRUSSELS','WWW.MTSDENMARK.COM','NOVEMBER 2005','ACTIVE','NOVEMBER 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BELGIUM','BE','MTSF','BMTS','S','MTS FINLAND','','BRUSSELS','WWW.MTSFINLAND.COM','NOVEMBER 2005','ACTIVE','NOVEMBER 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BELGIUM','BE','XBRU','XBRU','O','EURONEXT - EURONEXT BRUSSELS','','BRUSSELS','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BELGIUM','BE','ALXB','XBRU','S','EURONEXT - ALTERNEXT BRUSSELS','','BRUSSELS','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BELGIUM','BE','ENXB','XBRU','S','EURONEXT - EASY NEXT','','BRUSSELS','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','JUNE 2008','MULTILATERAL TRADING FACILITY FOR WARRANTS AND CERTIFICATES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BELGIUM','BE','MLXB','XBRU','S','EURONEXT - MARCHE LIBRE BRUSSELS','','BRUSSELS','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BELGIUM','BE','TNLB','XBRU','S','EURONEXT - TRADING FACILITY BRUSSELS','','BRUSSELS','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BELGIUM','BE','VPXB','XBRU','S','EURONEXT - VENTES PUBLIQUES BRUSSELS','','BRUSSELS','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BELGIUM','BE','XBRD','XBRU','S','EURONEXT - EURONEXT BRUSSELS - DERIVATIVES','','BRUSSELS','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','NOVEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BOSNIA AND HERZEGOVINA','BA','XBLB','XBLB','O','BANJA LUKA STOCK EXCHANGE','','BANJA LUKA','WWW.BLBERZA.COM','OCTOBER 2005','ACTIVE','OCTOBER 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BOSNIA AND HERZEGOVINA','BA','BLBF','XBLB','S','BANJA LUKA STOCK EXCHANGE - FREE MARKET','BLSE','BANJA LUKA','WWW.BLBERZA.COM','MARCH 2013','ACTIVE','MARCH 2013','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BOSNIA AND HERZEGOVINA','BA','XSSE','XSSE','O','SARAJEVO STOCK EXCHANGE','SASE','SARAJEVO','WWW.SASE.BA','JUNE 2007','ACTIVE','JUNE 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BULGARIA','BG','IBEX','IBEX','O','INDEPENDENT BULGARIAN ENERGY EXCHANGE','IBEX','SOFIA','WWW.IBEX.BG','DECEMBER 2015','ACTIVE','DECEMBER 2015','IBEX WAS ESTABLISHED JANUARY 2014, AS A FULLY-OWNED SUBSIDIARY OF THE BULGARIAN ENERGY HOLDING EAD. IBEX HOLDS A 10-YEAR LICENSE BY THE STATE ENERGY AND WATER REGULATORY COMMISSION TO ORGANIZING A POWER EXCHANGE FOR ELECTRICITY IN BULGARIA.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BULGARIA','BG','MBUL','MBUL','O','MTF SOFIA','','SOFIA','WWW.CAPMAN.BG','NOVEMBER 2016','ACTIVE','NOVEMBER 2016','MULTILATERAL TRADING FACILITY FOR EQUITIES, BONDS, DERIVATIVES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BULGARIA','BG','XBUL','XBUL','O','BULGARIAN STOCK EXCHANGE','BSE','SOFIA','WWW.BSE-SOFIA.BG','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BULGARIA','BG','ABUL','XBUL','S','BULGARIAN STOCK EXCHANGE - ALTERNATIVE MARKET','BSE','SOFIA','WWW.BSE-SOFIA.BG','AUGUST 2016','ACTIVE','AUGUST 2016','ALTERNATIVE REGULATED MARKET.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'BULGARIA','BG','IBUL','XBUL','S','BULGARIAN STOCK EXCHANGE - INTERNATIONAL INSTRUMENTS','BSE','SOFIA','WWW.BSE-SOFIA.BG','MAY 2017','ACTIVE','MAY 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'CROATIA','HR','XCRO','XCRO','O','CROATIAN POWER EXCHANGE','CROPEX','ZAGREB','WWW.CROPEX.HR','OCTOBER 2015','ACTIVE','OCTOBER 2015','ORGANISED MARKET PLACE FOR ELECTRICITY TRADING.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'CROATIA','HR','XTRZ','XTRZ','O','ZAGREB MONEY AND SHORT TERM SECURITIES MARKET INC','','ZAGREB','WWW.TRZISTENOVCA.HR','APRIL 2007','ACTIVE','APRIL 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'CROATIA','HR','XZAG','XZAG','O','ZAGREB STOCK EXCHANGE','','ZAGREB','WWW.ZSE.HR','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'CROATIA','HR','XZAM','XZAG','S','THE ZAGREB STOCK EXCHANGE MTF','','ZAGREB','WWW.ZSE.HR','SEPTEMBER 2009','ACTIVE','SEPTEMBER 2009','MULTILATERAL TRADING FACILITY OF THE ZAGREB STOCK EXCHANGE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'CYPRUS','CY','XCYS','XCYS','O','CYPRUS STOCK EXCHANGE','CSE','NICOSIA (LEFKOSIA)','WWW.CSE.COM.CY','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'CYPRUS','CY','XCYO','XCYS','S','CYPRUS STOCK EXCHANGE - OTC','','NICOSIA (LEFKOSIA)','WWW.CSE.COM.CY','OCTOBER 2009','ACTIVE','OCTOBER 2009','ELECTRONIC TRADING PLATFORM FOR OTC.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'CYPRUS','CY','XECM','XCYS','S','MTF - CYPRUS EXCHANGE','','NICOSIA','WWW.CSE.COM.CY/EN/DEFAULT.ASP','MAY 2009','ACTIVE','MAY 2009','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'CZECH REPUBLIC','CZ','FTFS','FTFS','O','42 FINANCIAL SERVICES','42FS','PRAGUE','WWW.42FS.COM','JULY 2016','ACTIVE','JULY 2016','42 FS ENERGY.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'CZECH REPUBLIC','CZ','XPRA','XPRA','O','PRAGUE STOCK EXCHANGE','PSE','PRAGUE','WWW.PSE.CZ','MAY 2010','ACTIVE','MAY 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'CZECH REPUBLIC','CZ','XPRM','XPRA','S','PRAGUE STOCK EXCHANGE - MTF','PSE','PRAGUE','WWW.PSE.CZ','JANUARY 2016','ACTIVE','JANUARY 2016','MTF MARKET OF THE PRAGUE STOCK EXCHANGE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'CZECH REPUBLIC','CZ','XPXE','XPXE','O','POWER EXCHANGE CENTRAL EUROPE','PXE','PRAGUE','WWW.PXE.CZ','MAY 2010','ACTIVE','MAY 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'CZECH REPUBLIC','CZ','XRMZ','XRMZ','O','RM-SYSTEM CZECH STOCK EXCHANGE','RMS CZ','PRAGUE','WWW.RMSYSTEM.CZ','MAY 2010','ACTIVE','MAY 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'CZECH REPUBLIC','CZ','XRMO','XRMZ','S','RM-SYSTEM CZECH STOCK EXCHANGE (MTF)','RMS CZ','PRAGUE','WWW.RMSYSTEM.CZ','MAY 2010','ACTIVE','MAY 2010','ELECTRONIC TRADING PLATFORM FOR EQUITIES AND BONDS LEGALLY DEFINED AS A MULTI-SIDED TRADING SYSTEM (MOS) WITH MORE OPEN CONDITIONS FOR ACCEPTING SECURITIES.')


INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'DENMARK','DK','DASI','DASI','O','DANSKE BANK A/S - SYSTEMATIC INTERNALISER','','COPENHAGEN','WWW.DANSKEBANK.DK','MARCH 2017','ACTIVE','MARCH 2017','SYSTEMATIC INTERNALISER.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'DENMARK','DK','DKTC','DKTC','O','DANSK OTC','','HORSENS','WWW.DANSKOTC.DK','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'DENMARK','DK','GXGR','GXGR','O','GXG MARKETS A/S','DANSK AMP','HORSENS','WWW.GXGMARKETS.COM','MAY 2012','ACTIVE','MAY 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'DENMARK','DK','GXGF','GXGR','S','GXG MTF FIRST QUOTE','','HORSENS','WWW.GXGMARKETS.COM','APRIL 2012','ACTIVE','APRIL 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'DENMARK','DK','GXGM','GXGR','S','GXG MTF','','HORSENS','WWW.GXGMARKETS.COM','OCTOBER 2011','ACTIVE','OCTOBER 2011','MULTILATERAL TRADING FACILITY FOR EQUITIES AND BONDS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'DENMARK','DK','NPGA','NPGA','O','GASPOINT NORDIC A/S','GPN','COPENHAGEN','WWW.GASPOINTNORDIC.COM','MARCH 2015','ACTIVE','JUNE 2011','GASPOINT NORDIC IS OPERATING A PLATFORM FOR CONTINUOUS ELECTRONIC TRADING OF GAS, DELIVERABLE TO THE ETF VIRTUAL TRADING POINT.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'DENMARK','DK','SNSI','SNSI','O','SPAR NORD BANK - SYSTEMATIC INTERNALISER','','AALBORG','WWW.SPARNORD.DK','MAY 2017','ACTIVE','MAY 2017','SYSTEMATIC INTERNALISER.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'DENMARK','DK','XCSE','XCSE','O','NASDAQ COPENHAGEN A/S','','COPENHAGEN','WWW.NASDAQOMXNORDIC.COM','DECEMBER 2015','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'DENMARK','DK','DCSE','XCSE','S','NASDAQ COPENHAGEN A/S - NORDIC@MID','','COPENHAGEN','WWW.NASDAQOMXNORDIC.COM','DECEMBER 2015','ACTIVE','NOVEMBER 2015','NORDIC@MID DARK POOL FOR XCSE')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'DENMARK','DK','FNDK','XCSE','S','FIRST NORTH DENMARK','','COPENHAGEN','WWW.NASDAQOMXNORDIC.COM','NOVEMBER 2015','ACTIVE','NOVEMBER 2015','FIRST NORTH IS OPERATED BY NASDAQ. FIRST NORTH IS A NORDIC ALTERNATIVE MTF MARKETPLACE FOR TRADING SHARES AND OTHER TYPES OF FINANCIAL INSTRUMENTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'DENMARK','DK','DNDK','XCSE','S','FIRST NORTH DENMARK - NORDIC@MID','','COPENHAGEN','WWW.NASDAQOMXNORDIC.COM','NOVEMBER 2015','ACTIVE','NOVEMBER 2015','NORDIC@MID DARK POOL FOR FIRST NORTH DENMARK')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'DENMARK','DK','MCSE','XCSE','S','NASDAQ COPENHAGEN A/S – AUCTION ON DEMAND','','COPENHAGEN','WWW.NASDAQOMXNORDIC.COM','JUNE 2016','ACTIVE','JUNE 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'DENMARK','DK','MNDK','XCSE','S','FIRST NORTH DENMARK – AUCTION ON DEMAND','','COPENHAGEN','WWW.NASDAQOMXNORDIC.COM','JUNE 2016','ACTIVE','JUNE 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ESTONIA','EE','XTAL','XTAL','O','NASDAQ TALLINN AS','','TALLINN','WWW.NASDAQBALTIC.COM','DECEMBER 2015','ACTIVE','DECEMBER 2009','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ESTONIA','EE','FNEE','XTAL','S','FIRST NORTH ESTONIA','','TALLINN','WWW.NASDAQBALTIC.COM','NOVEMBER 2015','ACTIVE','NOVEMBER 2009','FIRST NORTH IS OPERATED BY NASDAQ. FIRST NORTH IS A NORDIC ALTERNATIVE MTF MARKETPLACE FOR TRADING SHARES AND OTHER TYPES OF FINANCIAL INSTRUMENTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FAROE ISLANDS','FO','VMFX','VMFX','O','THE FAROESE SECURITIES MARKET','','TORSHAVN','WWW.VMF.FO','AUGUST 2011','ACTIVE','AUGUST 2011','THE FAROESE SECURITIES MARKET (VMF) IS THE STOCK EXCHANGE OF THE FAROE ISLANDS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FINLAND','FI','FGEX','FGEX','O','KAASUPORSSI - FINNISH GAS EXCHANGE','','ESPOO','WWW.KAASUPORSSI.COM','SEPTEMBER 2015','ACTIVE','SEPTEMBER 2015','THE FINNISH GAS EXCHANGE')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FINLAND','FI','XHEL','XHEL','O','NASDAQ HELSINKI LTD','','HELSINKI','WWW.NASDAQOMXNORDIC.COM','DECEMBER 2015','ACTIVE','JANUARY 2011','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FINLAND','FI','FNFI','XHEL','S','FIRST NORTH FINLAND','','HELSINKI','WWW.NASDAQOMXNORDIC.COM','NOVEMBER 2015','ACTIVE','MARCH 2008','FIRST NORTH IS OPERATED BY NASDAQ. FIRST NORTH IS A NORDIC ALTERNATIVE MTF MARKETPLACE FOR TRADING SHARES AND OTHER TYPES OF FINANCIAL INSTRUMENTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FINLAND','FI','DHEL','XHEL','S','NASDAQ HELSINKI LTD - NORDIC@MID','','HELSINKI','WWW.NASDAQOMXNORDIC.COM','DECEMBER 2015','ACTIVE','NOVEMBER 2015','NORDIC@MID DARK POOL FOR XHEL')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FINLAND','FI','DNFI','XHEL','S','FIRST NORTH FINLAND - NORDIC@MID','','HELSINKI','WWW.NASDAQOMXNORDIC.COM','NOVEMBER 2015','ACTIVE','NOVEMBER 2015','NORDIC@MID DARK POOL FOR FIRST NORTH FINLAND')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FINLAND','FI','MHEL','XHEL','S','NASDAQ HELSINKI LTD –  AUCTION ON DEMAND','','HELSINKI','WWW.NASDAQOMXNORDIC.COM','JUNE 2016','ACTIVE','JUNE 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FINLAND','FI','MNFI','XHEL','S','FIRST NORTH FINLAND – AUCTION ON DEMAND','','HELSINKI','WWW.NASDAQOMXNORDIC.COM','JUNE 2016','ACTIVE','JUNE 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','COAL','COAL','O','LA COTE ALPHA','','PARIS','WWW.COTE-ALPHA.FR','SEPTEMBER 2011','ACTIVE','SEPTEMBER 2011','SOURCE OF PRICES FOR INVESTMENT FUNDS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','EPEX','EPEX','O','EPEX SPOT SE','','PARIS','WWW.EPEXSPOT.COM','SEPTEMBER 2009','ACTIVE','SEPTEMBER 2009','EUROPEAN POWER EXCHANGE (DAY AHEAD AND INTRADAY MARKETS FOR ELECTRICITY IN CENTRAL EUROPE).')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','FMTS','FMTS','O','MTS FRANCE SAS','','PARIS','WWW.MTSFRANCE.COM','NOVEMBER 2005','ACTIVE','NOVEMBER 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','GMTF','GMTF','O','GALAXY','','PARIS','WWW.TRADINGSCREEN.COM','APRIL 2011','ACTIVE','APRIL 2011','MULTILATERAL TRADING FACILITY FOR EURO DENOMINATED GOVERNMENT AND CORPORATE BONDS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','LCHC','LCHC','O','LCH.CLEARNET','','PARIS','WWW.LCHCLEARNET.COM','DECEMBER 2013','ACTIVE','DECEMBER 2013','CLEARING HOUSE')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','XAFR','XAFR','O','ALTERNATIVA FRANCE','','PARIS','WWW.ALTERNATIVA.FR','JUNE 2008','ACTIVE','JUNE 2008','MULTILATERAL TRADING FACILITY FOR UNQUOTED STOCKS AND FUNDS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','XBLN','XBLN','O','BLUENEXT','','PARIS','WWW.BLUENEXT.EU','APRIL 2011','ACTIVE','APRIL 2011','BLUENEXT MTF HAS BECOME A REGULATED MARKET.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','XPAR','XPAR','O','EURONEXT - EURONEXT PARIS','','PARIS','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','ALXP','XPAR','S','EURONEXT - ALTERNEXT PARIS','','PARIS','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','MTCH','XPAR','S','BONDMATCH','','PARIS','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','NOVEMBER 2010','FINANCIAL, CORPORATE AND COVERED BONDS TRADING PLATFORM FOR PROFESSIONAL INVESTORS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','XMAT','XPAR','S','EURONEXT PARIS MATIF','','PARIS','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','XMLI','XPAR','S','EURONEXT - MARCHE LIBRE PARIS','','PARIS','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','JUNE 2006','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','XMON','XPAR','S','EURONEXT PARIS MONEP','','PARIS','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','XSPM','XPAR','S','EURONEXT STRUCTURED PRODUCTS MTF','','PARIS','WWW.EURONEXT.COM','SEPTEMBER 2016','ACTIVE','SEPTEMBER 2016','MULTILATERAL TRADING FACILITY FOR THE TRADING OF STRUCTURED PRODUCTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','XPOW','XPOW','O','POWERNEXT','','PARIS','WWW.POWERNEXT.FR','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','XPSF','XPOW','S','POWERNEXT - GAS SPOT AND FUTURES','','PARIS','WWW.POWERNEXT.COM','SEPTEMBER 2015','ACTIVE','SEPTEMBER 2015','PEGAS SPOT AND PEGAS FUTURES (SPOT AND FUTURES GAS MARKETS OF POWERNEXT)')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'FRANCE','FR','XPOT','XPOW','S','POWERNEXT - OTF','','PARIS','WWW.POWERNEXT.COM','MARCH 2016','ACTIVE','MARCH 2016','OTF SEGMENT OF THE PEGAS MARKETS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GEORGIA','GE','XGSE','XGSE','O','GEORGIA STOCK EXCHANGE','GSE','TBILISI','WWW.GSE.GE','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','360T','360T','O','360T','','FRANKFURT','WWW.360T.COM','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','CATS','CATS','O','CATS','CATS','FRANKFURT','WWW.BS-CATS.COM','FEBRUARY 2015','ACTIVE','NOVEMBER 2010','ELECTRONIC TRADING PLATFORM FOR STRUCTURED PRODUCTS. THE OWNER OF CATS HAS CHANGED FROM CITIGROUP TO BOERSE STUTTGART.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','DBOX','DBOX','O','DEUTSCHE BANK OFF EXCHANGE TRADING','','FRANKFURT','WWW.DEUTSCHE-BANK.DE','FEBRUARY 2010','ACTIVE','FEBRUARY 2010','DEUTSCHE BANK AG ELECTRONIC OFF EXCHANGE TRADING PLATFORM.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','AUTO','DBOX','S','AUTOBAHN FX','','FRANKFURT','WWW.AUTOBAHNFX.DB.COM','OCTOBER 2012','ACTIVE','OCTOBER 2012','DEUTSCHE BANK''S ELECTRONIC PLATFORM FOR TRADING FOREIGN EXCHANGE AND PRECIOUS METALS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','ECAG','ECAG','O','EUREX CLEARING AG','','FRANKFURT','WWW.EUREXCLEARING.COM','NOVEMBER 2016','ACTIVE','NOVEMBER 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','FICX','FICX','O','FINANCIAL INFORMATION CONTRIBUTORS EXCHANGE','FICONEX','RODGAU','WWW.FICONEX.COM','AUGUST 2016','ACTIVE','AUGUST 2016','GLOBAL, CLOUD BASED PLATFORM FOR CONTRIBUTORS INFORMATION EXCHANGE IN REAL-TIME.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','TGAT','TGAT','O','TRADEGATE EXCHANGE','','BERLIN','WWW.TRADEGATE.DE','AUGUST 2012','ACTIVE','AUGUST 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XGAT','TGAT','S','TRADEGATE EXCHANGE - FREIVERKEHR','','BERLIN','WWW.TRADEGATE.DE','MAY 2010','ACTIVE','MAY 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XGRM','TGAT','S','TRADEGATE EXCHANGE - REGULIERTER MARKT','','BERLIN','WWW.TRADEGATE.DE','MAY 2010','ACTIVE','MAY 2010','TRADEGATE EXCHANGE IS AN OFFICIAL REGULATED STOCK EXCHANGE IN BERLIN/GERMANY FOR SHARES, BONDS, ETFS AND FONDS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XBER','XBER','O','BOERSE BERLIN','','BERLIN','WWW.BOERSE-BERLIN.DE','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','BERA','XBER','S','BOERSE BERLIN - REGULIERTER MARKT','','BERLIN','WWW.BERLIN-BOERSE.DE','FEBRUARY 2008','ACTIVE','FEBRUARY 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','BERB','XBER','S','BOERSE BERLIN - FREIVERKEHR','','BERLIN','WWW.BERLIN-BOERSE.DE','FEBRUARY 2008','ACTIVE','FEBRUARY 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','BERC','XBER','S','BOERSE BERLIN - BERLIN SECOND REGULATED MARKET','','BERLIN','WWW.BERLIN-BOERSE.DE','AUGUST 2010','ACTIVE','AUGUST 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','EQTA','XBER','S','BOERSE BERLIN EQUIDUCT TRADING - REGULIERTER MARKT','','BERLIN','WWW.EQUIDUCT-TRADING.DE','MAY 2008','ACTIVE','MAY 2008','ELECTRONIC TRADING SYSTEM.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','EQTB','XBER','S','BOERSE BERLIN EQUIDUCT TRADING - BERLIN SECOND REGULATED MARKET','','BERLIN','WWW.EQUIDUCT-TRADING.DE','MARCH 2010','ACTIVE','MARCH 2010','ELECTRONIC TRADING SYSTEM.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','EQTC','XBER','S','BOERSE BERLIN EQUIDUCT TRADING - FREIVERKEHR','','BERLIN','WWW.EQUIDUCT-TRADING.DE','AUGUST 2010','ACTIVE','AUGUST 2010','ELECTRONIC TRADING SYSTEM.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','EQTD','XBER','S','BOERSE BERLIN EQUIDUCT TRADING - OTC','','BERLIN','WWW.EQUIDUCT-TRADING.DE','JANUARY 2011','ACTIVE','JANUARY 2011','ELECTRONIC TRADING SYSTEM.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XEQT','XBER','S','BOERSE BERLIN EQUIDUCT TRADING','','BERLIN','WWW.EQUIDUCT-TRADING.DE','MAY 2008','ACTIVE','MAY 2008','ELECTRONIC TRADING SYSTEM.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','ZOBX','XBER','S','ZOBEX','ZOBEX','BERLIN','WWW.BOERSE-BERLIN.DE','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XDUS','XDUS','O','BOERSE DUESSELDORF','','DUESSELDORF','WWW.BOERSE-DUESSELDORF.DE','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','DUSA','XDUS','S','BOERSE DUESSELDORF - REGULIERTER MARKT','','DUESSELDORF','','FEBRUARY 2008','ACTIVE','FEBRUARY 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','DUSB','XDUS','S','BOERSE DUESSELDORF - FREIVERKEHR','','DUESSELDORF','','FEBRUARY 2008','ACTIVE','FEBRUARY 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','DUSC','XDUS','S','BOERSE DUESSELDORF - QUOTRIX - REGULIERTER MARKT','','DUESSELDORF','','AUGUST 2008','ACTIVE','AUGUST 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','DUSD','XDUS','S','BOERSE DUESSELDORF - QUOTRIX MTF','','DUESSELDORF','','AUGUST 2008','ACTIVE','AUGUST 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XQTX','XDUS','S','BOERSE DUESSELDORF - QUOTRIX','','DUESSELDORF','WWW.BOERSE-DUESSELDORF.DE','SEPTEMBER 2013','ACTIVE','SEPTEMBER 2013','ELECTRONIC TRADING SYSTEM FOR SHARES, BONDS, ETFs, INVESTMENT FUNDS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XECB','XECB','O','ECB EXCHANGE RATES','','FRANKFURT','WWW.ECB.EUROPA.EU','NOVEMBER 2012','ACTIVE','NOVEMBER 2012','EURO FOREIGN EXCHANGE REFERENCE RATES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XECC','XECC','O','EUROPEAN COMMODITY CLEARING AG','ECC','LEIPZIG','WWW.ECC.DE','MAY 2012','ACTIVE','MAY 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XEEE','XEEE','O','EUROPEAN ENERGY EXCHANGE','EEX','LEIPZIG','WWW.EEX.COM','SEPTEMBER 2015','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XEEO','XEEE','S','EUROPEAN ENERGY EXCHANGE - NON-MTF MARKET','EEX','LEIPZIG','WWW.EEX.COM','NOVEMBER 2015','ACTIVE','SEPTEMBER 2015','NON-MTF MARKET')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XEER','XEEE','S','EUROPEAN ENERGY EXCHANGE - REGULATED MARKET','EEX','LEIPZIG','WWW.EEX.COM','NOVEMBER 2015','ACTIVE','SEPTEMBER 2015','REGULATED MARKET')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XETR','XETR','O','XETRA','XETRA','FRANKFURT','WWW.DEUTSCHE-BOERSE.COM','NOVEMBER 2016','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XEUB','XETR','S','EUREX BONDS','','FRANKFURT','WWW.EUREX-BONDS.COM','NOVEMBER 2016','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XETA','XETR','S','XETRA - REGULIERTER MARKT','XETRA','FRANKFURT','WWW.DEUTSCHE-BOERSE.COM','NOVEMBER 2016','ACTIVE','MARCH 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XETB','XETR','S','XETRA - FREIVERKEHR','XETRA','FRANKFURT','WWW.DEUTSCHE-BOERSE.COM','NOVEMBER 2016','ACTIVE','MARCH 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XEUP','XEUP','O','EUREX REPO GMBH','','FRANKFURT','WWW.EUREXREPO.COM','NOVEMBER 2016','ACTIVE','NOVEMBER 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XEUM','XEUP','S','EUREX REPO SECLEND MARKET','','FRANKFURT','WWW.EUREXREPO.COM','NOVEMBER 2016','ACTIVE','JANUARY 2012','ET IS NOW OPERATED FROM FRANKFURT (GERMANY)')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XERE','XEUP','S','EUREX REPO - FUNDING AND FINANCING PRODUCTS','','FRANKFURT','WWW.EUREXREPO.COM','NOVEMBER 2016','ACTIVE','APRIL 2014','EUREX REPO ELECTRONIC TRADING PLATFORM FOR FUNDING AND FINANCING PRODUCTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XERT','XEUP','S','EUREX REPO - TRIPARTY','','FRANKFURT','WWW.EUREXREPO.COM','NOVEMBER 2016','ACTIVE','DECEMBER 2015','EUREX REPO ELECTRONIC TRADING SEGMENT FOR TRIPARTY REPO.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XEUR','XEUR','O','EUREX DEUTSCHLAND','','FRANKFURT','WWW.EUREXCHANGE.COM','NOVEMBER 2016','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XFRA','XFRA','O','DEUTSCHE BOERSE AG','','FRANKFURT','WWW.DEUTSCHE-BOERSE.COM','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','FRAA','XFRA','S','BOERSE FRANKFURT - REGULIERTER MARKT','','FRANKFURT','WWW.DEUTSCHE-BOERSE.COM','MARCH 2008','ACTIVE','MARCH 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','FRAB','XFRA','S','BOERSE FRANKFURT - FREIVERKEHR','','FRANKFURT','WWW.DEUTSCHE-BOERSE.COM','MARCH 2008','ACTIVE','MARCH 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XDBC','XFRA','S','DEUTSCHE BOERSE AG - CUSTOMIZED INDICES','','FRANKFURT','WWW.DEUTSCHE-BOERSE.COM','MARCH 2011','ACTIVE','MARCH 2011','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XDBV','XFRA','S','DEUTSCHE BOERSE AG - VOLATILITY INDICES','','FRANKFURT','WWW.DEUTSCHE-BOERSE.COM','MARCH 2011','ACTIVE','MARCH 2011','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XDBX','XFRA','S','DEUTSCHE BOERSE AG - INDICES','','FRANKFURT','WWW.DEUTSCHE-BOERSE.COM','MARCH 2011','ACTIVE','MARCH 2011','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XHAM','XHAM','O','HANSEATISCHE WERTPAPIERBOERSE HAMBURG','','HAMBURG','WWW.BOERSENAG.DE','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','HAMA','XHAM','S','BOERSE HAMBURG - REGULIERTER MARKT','','HAMBURG','','FEBRUARY 2008','ACTIVE','FEBRUARY 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','HAMB','XHAM','S','BOERSE HAMBURG - FREIVERKEHR','','HAMBURG','','FEBRUARY 2008','ACTIVE','FEBRUARY 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','HAML','XHAM','S','BOERSE HAMBURG - LANG AND SCHWARZ EXCHANGE','','HAMBURG','WWW.BOERSENAG.DE','SEPTEMBER 2016','ACTIVE','APRIL 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','HAMM','XHAM','S','BOERSE HAMBURG - LANG AND SCHWARZ EXCHANGE - REGULIERTER MARKT','','HAMBURG','WWW.BOERSENAG.DE','SEPTEMBER 2016','ACTIVE','APRIL 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','HAMN','XHAM','S','BOERSE HAMBURG - LANG AND SCHWARZ EXCHANGE - FREIVERKEHR','','HAMBURG','WWW.BOERSENAG.DE','SEPTEMBER 2016','ACTIVE','APRIL 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XHAN','XHAN','O','NIEDERSAECHSISCHE BOERSE ZU HANNOVER','','HANNOVER','WWW.BOERSENAG.DE','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','HANA','XHAN','S','BOERSE HANNOVER - REGULIERTER MARKT','','HANNOVER','','FEBRUARY 2008','ACTIVE','FEBRUARY 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','HANB','XHAN','S','BOERSE HANNOVER - FREIVERKEHR','','HANNOVER','','FEBRUARY 2008','ACTIVE','FEBRUARY 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XINV','XINV','O','INVESTRO','','FRANKFURT','WWW.INVESTRO.DE','OCTOBER 2008','ACTIVE','OCTOBER 2008','SETTLEMENT PLATFORM FOR CSD AND NON CSD FUNDS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XMUN','XMUN','O','BOERSE MUENCHEN','','MUENCHEN','WWW.BOERSE-MUENCHEN.DE','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','MUNA','XMUN','S','BOERSE MUENCHEN - REGULIERTER MARKT','','MUENCHEN','WWW.BOERSE-MUENCHEN.DE','FEBRUARY 2008','ACTIVE','FEBRUARY 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','MUNB','XMUN','S','BOERSE MUENCHEN - FREIVERKEHR','','MUENCHEN','WWW.BOERSE-MUENCHEN.DE','FEBRUARY 2008','ACTIVE','FEBRUARY 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','MUNC','XMUN','S','BOERSE MUENCHEN - MARKET MAKER MUNICH - REGULIERTER MARKT','','MUENCHEN','WWW.BOERSE-MUENCHEN.DE','MAY 2014','ACTIVE','MAY 2014','MARKET LAUNCH DATE: 4 JULY 2014')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','MUND','XMUN','S','BOERSE MUENCHEN - MARKET MAKER MUNICH - FREIVERKEHR MARKT','','MUENCHEN','WWW.BOERSE-MUENCHEN.DE','MAY 2014','ACTIVE','MAY 2014','MARKET LAUNCH DATE: 4 JULY 2014')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XSCO','XSCO','O','BOERSE FRANKFURT WARRANTS TECHNICAL','','FRANKFURT','WWW.ZERTIFIKATEBOERSE.DE','DECEMBER 2013','ACTIVE','AUGUST 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XSC1','XSCO','S','BOERSE FRANKFURT WARRANTS TECHNICAL 1','','FRANKFURT','WWW.ZERTIFIKATEBOERSE.DE','DECEMBER 2013','ACTIVE','MAY 2010','MARKET FOR STRUCTURED PRODUCTS - COUNTRY SEGMENT 1.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XSC2','XSCO','S','BOERSE FRANKFURT WARRANTS TECHNICAL 2','','FRANKFURT','WWW.ZERTIFIKATEBOERSE.DE','DECEMBER 2013','ACTIVE','MAY 2010','MARKET FOR STRUCTURED PRODUCTS - COUNTRY SEGMENT 2.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XSC3','XSCO','S','BOERSE FRANKFURT WARRANTS TECHNICAL 3','','FRANKFURT','WWW.ZERTIFIKATEBOERSE.DE','DECEMBER 2013','ACTIVE','MAY 2010','MARKET FOR STRUKTURED PRODUCTS - COUNTRY SEGMENT 3.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XSTU','XSTU','O','BOERSE STUTTGART','','STUTTGART','WWW.BOERSE-STUTTGART.DE','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','EUWX','XSTU','S','EUWAX','EUWAX','STUTTGART','WWW.EUWAX.DE','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','STUA','XSTU','S','BOERSE STUTTGART - REGULIERTER MARKT','','STUTTGART','WWW.BOERSE-STUTTGART.DE','FEBRUARY 2008','ACTIVE','FEBRUARY 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','STUB','XSTU','S','BOERSE STUTTGART - FREIVERKEHR','','STUTTGART','WWW.BOERSE-STUTTGART.DE','FEBRUARY 2008','ACTIVE','FEBRUARY 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XSTF','XSTU','S','BOERSE STUTTGART - TECHNICAL PLATFORM 2','','STUTTGART','WWW.BOERSE-STUTTGART.DE','FEBRUARY 2017','ACTIVE','FEBRUARY 2017','FOR REPORTING PURPOSE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','STUC','XSTU','S','BOERSE STUTTGART - REGULIERTER MARKT - TECHNICAL PLATFORM 2','','STUTTGART','WWW.BOERSE-STUTTGART.DE','FEBRUARY 2017','ACTIVE','FEBRUARY 2017','FOR REPORTING PURPOSE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','STUD','XSTU','S','BOERSE STUTTGART - FREIVERKEHR - TECHNICAL PLATFORM 2','','STUTTGART','WWW.BOERSE-STUTTGART.DE','FEBRUARY 2017','ACTIVE','FEBRUARY 2017','FOR REPORTING PURPOSE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GERMANY','DE','XXSC','XXSC','O','FRANKFURT CEF SC','','FRANKFURT','WWW.DEUTSCHE-BOERSE.COM','OCTOBER 2011','ACTIVE','OCTOBER 2011','XXSC WILL COMPRISE THE INFORMATION FOR "FRAA" AND "FRAB". QUOTE AND TRADE INFORMATION IS DISTRIBUTED VIA CEF (CONSOLIDATED EXCHANGE FEED), THEREFORE THE SHORT NAME "FRANKFURT CEF SC" REFERS TO CEF AND SC TO SCOACH.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GIBRALTAR','GI','GSXL','GSXL','O','THE GIBRALTAR STOCK EXCHANGE','GSX','GIBRALTAR','WWW.GSX.GI','JULY 2015','ACTIVE','JULY 2015','EU REGULATED MARKET FOR TECHNICAL LISTINGS IN COLLECTIVE INVESTMENT SCHEMES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GREECE','GR','ASEX','ASEX','O','ATHENS STOCK EXCHANGE','ASE','ATHENS','WWW.ASE.GR','JULY 2012','ACTIVE','JULY 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GREECE','GR','ENAX','ASEX','S','ATHENS EXCHANGE ALTERNATIVE MARKET','ENAX','ATHENS','WWW.ATHEXGROUP.GR','NOVEMBER 2016','ACTIVE','NOVEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GREECE','GR','HOTC','ASEX','S','HELLENIC EXCHANGE OTC MARKET','','ATHENS','WWW.ATHEXGROUP.GR','NOVEMBER 2016','ACTIVE','AUGUST 2008','THE HELLENIC EXCHANGE OTC MARKET IS THE OVER-THE-COUNTER ELECTRONIC TRADING MARKET FOR ATHENS EXCHANGE')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GREECE','GR','XADE','ASEX','S','ATHENS EXCHANGE S.A. DERIVATIVES MARKET','ATHEXD','ATHENS','WWW.ATHEXGROUP.GR','NOVEMBER 2016','ACTIVE','NOVEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GREECE','GR','XATH','ASEX','S','ATHENS EXCHANGE S.A. CASH MARKET','ATHEXC','ATHENS','WWW.ATHEXGROUP.GR','NOVEMBER 2016','ACTIVE','NOVEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GREECE','GR','XIPO','ASEX','S','HELEX ELECTRONIC BOOK BUILDING','EBB','ATHENS','WWW.ASE.GR','JUNE 2014','ACTIVE','JUNE 2014','EBB IS A PRIMARY MARKET (IPO MARKET)')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GREECE','GR','HDAT','HDAT','O','ELECTRONIC SECONDARY SECURITIES MARKET (HDAT)','HDAT','ATHENS','WWW.BANKOFGREECE.GR','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'GREECE','GR','HEMO','HEMO','O','LAGIE - OPERATOR OF THE ENERGY MARKET S.A.','LAGIE S.A.','PIREAUS','WWW.LAGIE.GR','APRIL 2015','ACTIVE','APRIL 2015','LAGIE IS RESPONSIBLE FOR MANAGING THE MARKET OF ELECTRIC ENERGY TRADING IN GREECE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'HUNGARY','HU','BETA','BETA','O','BETA MARKET','','BUDAPEST','WWW.BSE.HU','DECEMBER 2011','ACTIVE','DECEMBER 2011','LAUNCHED IN NOVEMBER 2011,  MULTILATERAL TRADING FACILITY.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'HUNGARY','HU','HUPX','HUPX','O','HUNGARIAN POWER EXCHANGE','HUPX','BUDAPEST','WWW.HUPX.HU','APRIL 2009','ACTIVE','APRIL 2009','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'HUNGARY','HU','KCCP','KCCP','O','KELER CCP','','BUDAPEST','WWW.KELERKSZF.HU','SEPTEMBER 2013','ACTIVE','SEPTEMBER 2013','CENTRAL COUNTERPARTY OF THE BUDAPEST STOCK EXCHANGE, MTS HUNGARY PLATFORM, CENTRAL EASTERN EUROPEAN GAS EXCHANGE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'HUNGARY','HU','XBUD','XBUD','O','BUDAPEST STOCK EXCHANGE','','BUDAPEST','WWW.BET.HU','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'HUNGARY','HU','XGAS','XGAS','O','CENTRAL EASTERN EUROPEAN GAS EXCHANGE LTD','','BUDAPEST','WWW.CEEGEX.COM','MAY 2013','ACTIVE','MAY 2013','CEEGEX IS A ORGANISED NATURAL GAS MARKET PROVIDING SERVICES FOR THE GAS MARKET PLAYERS WITHIN THE EUROPEAN ECONOMIC AREA (EEA).')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ICELAND','IS','XICE','XICE','O','NASDAQ ICELAND HF.','ICEX','REYKJAVIK','WWW.NASDAQOMXNORDIC.COM','DECEMBER 2015','ACTIVE','MAY 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ICELAND','IS','DICE','XICE','S','NASDAQ ICELAND HF. - NORDIC@MID','ICEX','REYKJAVIK','WWW.NASDAQOMXNORDIC.COM','DECEMBER 2015','ACTIVE','NOVEMBER 2015','NORDIC@MID DARK POOL FOR XICE')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ICELAND','IS','FNIS','XICE','S','FIRST NORTH ICELAND','','REYKJAVIK','WWW.NASDAQOMXNORDIC.COM','NOVEMBER 2015','ACTIVE','NOVEMBER 2015','FIRST NORTH IS OPERATED BY NASDAQ. FIRST NORTH IS A NORDIC ALTERNATIVE MTF MARKETPLACE FOR TRADING SHARES AND OTHER TYPES OF FINANCIAL INSTRUMENTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ICELAND','IS','DNIS','XICE','S','FIRST NORTH ICELAND - NORDIC@MID','','REYKJAVIK','WWW.NASDAQOMXNORDIC.COM','NOVEMBER 2015','ACTIVE','NOVEMBER 2015','NORDIC@MID DARK POOL FOR FIRST NORTH ICELAND')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ICELAND','IS','MICE','XICE','S','NASDAQ ICELAND HF. – AUCTION ON DEMAND','','REYKJAVIK','WWW.NASDAQOMXNORDIC.COM','JUNE 2016','ACTIVE','JUNE 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ICELAND','IS','MNIS','XICE','S','FIRST NORTH ICELAND – AUCTION ON DEMAND','','REYKJAVIK','WWW.NASDAQOMXNORDIC.COM','JUNE 2016','ACTIVE','JUNE 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'IRELAND','IE','AREX','AREX','O','AREX - AUTOMATED RECEIVABLES EXCHANGE','AREX','DUBLIN','HTTP://AREX.IO','MAY 2016','ACTIVE','MAY 2016','MARKET FOR ETR (EXCHANGE TRADED RECEIVABLES) ORDER EXECUTION.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'IRELAND','IE','XPOS','ITGI','S','POSIT','POSIT','DUBLIN','WWW.ITG.COM','JULY 2007','ACTIVE','JULY 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'IRELAND','IE','XCDE','XCDE','O','BAXTER FINANCIAL SERVICES','','DUBLIN','WWW.BAXTER-FX.COM','MAY 2008','ACTIVE','MAY 2008','ELECTRONIC TRADING PLATFORM FOR CURRENCY FUTURES EFP''S AND OTC CURRENCY TRADING')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'IRELAND','IE','XDUB','XDUB','O','IRISH STOCK EXCHANGE - ALL MARKET','ISE','DUBLIN','WWW.ISE.IE','NOVEMBER 2007','ACTIVE','NOVEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'IRELAND','IE','XEYE','XDUB','S','IRISH STOCK EXCHANGE - GEM - XETRA','ISE XETRA','DUBLIN','WWW.ISE.IE','SEPTEMBER 2016','ACTIVE','MARCH 2012','NOT OPERATIONAL YET - DUBLIN - IRISH STOCK EXCHANGE - GLOBAL EXCHANGE MARKET (GEM)- ISE XETRA.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'IRELAND','IE','XESM','XDUB','S','DUBLIN - IRISH STOCK EXCHANGE - ENTREPRISE SECURITIES MARKET (ESM)- ISE XETRA','ISE','DUBLIN','WWW.ISE.IE','SEPTEMBER 2016','ACTIVE','JANUARY 2013','NOT OPERATIONAL YET.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'IRELAND','IE','XMSM','XDUB','S','DUBLIN - IRISH STOCK EXCHANGE - MAIN SECURITIES MARKET (MSM)- ISE XETRA','ISE','DUBLIN','WWW.ISE.IE','SEPTEMBER 2016','ACTIVE','JANUARY 2013','NOT OPERATIONAL YET.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'IRELAND','IE','XATL','XDUB','S','ATLANTIC SECURITIES MARKET','ISE','DUBLIN','WWW.ISE.IE','SEPTEMBER 2016','ACTIVE','JANUARY 2015','NOT OPERATIONAL YET - ATLANTIC SECURITIES MARKET (ASM). THE ASM IS AUTHORISED BY THE CENTRAL BANK OF IRELAND AS A MTF (AS DEFINED IN THE DIRECTIVE ON MARKETS IN FINANCIAL INSTRUMENTS 2004/39/EC) AND IS REGULATED BY THE IRISH STOCK EXCHANGE PLC.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'IRELAND','IE','XEBI','XEBI','O','ENERGY BROKING IRELAND GAS TRADING PLATFORM','EBI','DUBLIN','WWW.EBI.IE','OCTOBER 2015','ACTIVE','OCTOBER 2015','ELECTRONIC TRADING AND BROKING PLATFORM FOR OTC NATURAL GAS PHYSICAL SPOT TRANSACTIONS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','CGIT','CGIT','O','CASSA DI COMPENSAZIONE E GARANZIA SPA','CC&amp;G','ROMA','WWW.CCG.IT','JUNE 2013','ACTIVE','JUNE 2013','CENTRAL COUNTERPARTY ACROSS MULTIPLE TRADING VENUES COVERING A WIDE RANGE OF ASSET CLASSES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','CGQT','CGIT','S','CASSA DI COMPENSAZIONE E GARANZIA SPA - EQUITY CCP SERVICE','CCGEQUITY','ROMA','WWW.CCG.IT','JUNE 2013','ACTIVE','JUNE 2013','CCP SERVICE FOR EQUITIES AND COMPARABLE PRODUCTS SUCH WARRANTS, CONVERTIBLE BONDS, CLOSED-END FUNDS, INVESTMENT COMPANIES, REAL ESTATE INVESTMENT COMPANIES, ETF AND ETC')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','CGDB','CGIT','S','CASSA DI COMPENSAZIONE E GARANZIA SPA - BONDS CCP SERVICE','CCGBONDS','ROMA','WWW.CCG.IT','JUNE 2013','ACTIVE','JUNE 2013','CCP SERVICE FOR GOVERNMENT BONDS, CORPORATE BONDS AND REPOS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','CGEB','CGIT','S','CASSA DI COMPENSAZIONE E GARANZIA SPA - EURO BONDS CCP SERVICE','CCGEUROBONDS','ROMA','WWW.CCG.IT','JUNE 2013','ACTIVE','JUNE 2013','CCP SERVICE FOR EURO GOVERNMENT BONDS, EURO CORPORATE BONDS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','CGTR','CGIT','S','CASSA DI COMPENSAZIONE E GARANZIA SPA - TRIPARTY REPO CCP SERVICE','CCGTRIPARTY','ROMA','WWW.CCG.IT','JUNE 2013','ACTIVE','JUNE 2013','CCP SERVICE FOR TRIPARTY REPOS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','CGQD','CGIT','S','CASSA DI COMPENSAZIONE E GARANZIA SPA - CCP EQUITY DERIVATIVES','CCGEQUITYDER','ROMA','WWW.CCG.IT','JUNE 2013','ACTIVE','JUNE 2013','CCP SERVICE ON EQUITY DERIVATIVES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','CGND','CGIT','S','CASSA DI COMPENSAZIONE E GARANZIA SPA - CCP ENERGY DERIVATIVES','CCGENERGYDER','ROMA','WWW.CCG.IT','JUNE 2013','ACTIVE','JUNE 2013','CCP SERVICE ON ENERGY DERIVATIVES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','CGGD','CGIT','S','CASSA DI COMPENSAZIONE E GARANZIA SPA - CCP AGRICULTURAL COMMODITY DERIVATIVES','CCGAGRIDER','ROMA','WWW.CCG.IT','JUNE 2013','ACTIVE','JUNE 2013','CCP SERVICE ON AGRICULTURAL COMMODITIES DERIVATIVES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','CGCM','CGIT','S','CASSA DI COMPENSAZIONE E GARANZIA SPA - COLLATERALIZED MONEY MARKET GUARANTEE SERVICE','NEWMIC','ROMA','WWW.CCG.IT','JUNE 2013','ACTIVE','JUNE 2013','COLLATERALIZED MONEY MARKET GUARANTEE SERVICE')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','EMID','EMID','O','E-MID','','MILANO','WWW.E-MID.IT','MAY 2010','ACTIVE','MAY 2010','MARKET FOR INTERBANK DEPOSITS IN EUROPE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','EMDR','EMID','S','E-MID - E-MIDER MARKET','','MILANO','WWW.E-MID.IT','JUNE 2008','ACTIVE','JUNE 2008','MARKET FOR THE TRADING OF MULTI-CURRENCY DERIVATIVE FINANCIAL INSTRUMENTS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','EMIR','EMID','S','E-MID REPO','','MILANO','WWW.E-MID.IT','NOVEMBER 2011','ACTIVE','NOVEMBER 2011','ELECTRONIC TRADING PLATFORM FOR REPO TRADES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','EMIB','EMID','S','E-MID - BANCA D''ITALIA SHARES TRADING MARKET','','MILANO','WWW.E-MID.IT','OCTOBER 2016','ACTIVE','OCTOBER 2016','MARKET FOR THE NATIONAL CENTRAL BANK (BANCA D''ITALIA) SHARES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','ETLX','ETLX','O','EUROTLX','','MILANO','WWW.EUROTLX.COM','AUGUST 2007','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','HMTF','HMTF','O','HI-MTF','','MILANO','WWW.HIMTF.COM','NOVEMBER 2007','ACTIVE','NOVEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','HMOD','HMTF','S','HI-MTF ORDER DRIVEN','','MILANO','WWW.HIMTF.COM','JULY 2008','ACTIVE','JULY 2008','MULTILATERAL TRADING FACILITY ORDER DRIVEN FOR EQUITIES AND BONDS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','HRFQ','HMTF','S','HI-MTF RFQ','','MILANO','WWW.HIMTF.COM','JULY 2016','ACTIVE','JULY 2016','MTF FOR BONDS BASED ON RFQ NEGOTIATION MODEL')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','MTSO','MTSO','O','MTS S.P.A.','','ROMA','WWW.MTSMARKETS.COM','APRIL 2017','ACTIVE','APRIL 2017','LEGAL ENTITY OPERATING ALL RELATED MARKET SEGMENT MICS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','BOND','MTSO','S','BONDVISION ITALIA','','ROMA','WWW.MTSMARKETS.COM','APRIL 2017','ACTIVE','NOVEMBER 2005','REGULATED MARKET FOR GOVERNMENT DEBT SECURITIES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','MTSC','MTSO','S','MTS ITALIA','MTS ITALY','ROMA','WWW.MTSMARKETS.COM','APRIL 2017','ACTIVE','NOVEMBER 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','MTSM','MTSO','S','MTS CORPORATE MARKET','MTS ITALY','ROMA','WWW.MTSMARKETS.COM','APRIL 2017','ACTIVE','JANUARY 2008','NON-GOVERNMENT BONDS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','SSOB','MTSO','S','BONDVISION ITALIA MTF','','ROMA','WWW.MTSMARKETS.COM','APRIL 2017','ACTIVE','MAY 2010','CORPORATE BONDS, COVERED BONDS, ETFS, SUPRANATIONAL, SOVEREIGN AND AGENCY (SSA).')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','XGME','XGME','O','GESTORE MERCATO ELETTRICO - ITALIAN POWER EXCHANGE','IPEX/GME','ROMA','WWW.MERCATOELETTRICO.ORG','APRIL 2009','ACTIVE','APRIL 2009','ITALIAN POWER EXCHANGE')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','XMIL','XMIL','O','BORSA ITALIANA S.P.A.','','MILANO','WWW.BORSAITALIANA.IT','SEPTEMBER 2012','ACTIVE','DECEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','MTAH','XMIL','S','BORSA ITALIANA EQUITY MTF','BITEQMTF','MILAN','WWW.BORSAITALIANA.IT','JULY 2016','ACTIVE','JULY 2016','SINCE 11.7.16, BIEM OFFERS TRADING IN REGULAR MARKET HOURS FOR INTERNATIONAL SHARES ("BIT GEM" SEGMENT, FROM 8AM TO 5:42PM MILAN TIME) AND "AFTER HOUR" TRADING FOR ITALIAN AND INTL. SHARES ("TAH" SEGMENT, FROM 6PM TO 8:30PM MILAN TIME).')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','ETFP','XMIL','S','ELECTRONIC OPEN-END FUNDS AND ETC MARKET','ETFPLUS','MILANO','WWW.BORSAITALIANA.IT','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','MIVX','XMIL','S','MARKET FOR INVESTMENT VEHICLES','MIV','MILAN','WWW.BORSAITALIANA.IT','MAY 2017','MODIFIED','JUNE 2009','THE MIV, DEDICATED TO INVESTMENT VEHICLES, IS DIVIDED INTO THREE SEGMENTS: UNITS OF CLOSED-END FUNDS SEGMENT, INVESTMENT COMPANIES SEGMENT, REAL ESTATE INVESTMENT COMPANIES SEGMENT (REICS FROM THE EXPANDI MARKET).')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','MOTX','XMIL','S','ELECTRONIC BOND MARKET','MOT','MILANO','WWW.BORSAITALIANA.IT','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','MTAA','XMIL','S','ELECTRONIC SHARE MARKET','MTA','MILAN','WWW.BORSAITALIANA.IT','MAY 2017','MODIFIED','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','SEDX','XMIL','S','SECURITISED DERIVATIVES MARKET','SEDEX','MILANO','WWW.BORSAITALIANA.IT','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','XAIM','XMIL','S','AIM ITALIA - MERCATO ALTERNATIVO DEL CAPITALE','','MILAN','WWW.BORSAITALIANA.IT','MAY 2017','MODIFIED','APRIL 2012','MULTILATERAL TRADING FACILITY - MERGE OF AIM ITALIA AND MAC, MAC WILL BE OPENED TILL END 2012.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','XDMI','XMIL','S','ITALIAN DERIVATIVES MARKET','IDEM','MILAN','WWW.BORSAITALIANA.IT','MAY 2017','MODIFIED','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ITALY','IT','XMOT','XMIL','S','EXTRAMOT','','MILANO','WWW.BORSAITALIANA.IT','JULY 2009','ACTIVE','JULY 2009','MTF OF BONDS MANAGED AND ORGANISED BY BORSA ITALIANA.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'LATVIA','LV','XRIS','XRIS','O','NASDAQ RIGA AS','','RIGA','WWW.NASDAQBALTIC.COM','DECEMBER 2015','ACTIVE','OCTOBER 2009','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'LATVIA','LV','FNLV','XRIS','S','FIRST NORTH LATVIA','','RIGA','WWW.NASDAQBALTIC.COM','NOVEMBER 2015','ACTIVE','MARCH 2008','FIRST NORTH IS OPERATED BY NASDAQ. FIRST NORTH IS A NORDIC ALTERNATIVE MTF MARKETPLACE FOR TRADING SHARES AND OTHER TYPES OF FINANCIAL INSTRUMENTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'LITHUANIA','LT','BAPX','BAPX','O','BALTPOOL','','VILNIUS','WWW.BALTPOOL.LT','MARCH 2010','ACTIVE','MARCH 2010','BALTPOOL UAB IS THE ELECTRICITY MARKET OPERATOR OF LITHUANIA.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'LITHUANIA','LT','GETB','GETB','O','LITHUANIAN NATURAL GAS EXCHANGE','GET BALTIC','VILNIUS','WWW.GETBALTIC.LT','NOVEMBER 2014','ACTIVE','NOVEMBER 2014','LITHUANIAN NATURAL GAS EXCHANGE FOR PHYSICAL DELIVERY PRODUCTS TRADING.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'LITHUANIA','LT','XLIT','XLIT','O','AB NASDAQ VILNIUS','','VILNIUS','WWW.NASDAQBALTIC.COM','DECEMBER 2015','ACTIVE','OCTOBER 2009','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'LITHUANIA','LT','FNLT','XLIT','S','FIRST NORTH LITHUANIA','','VILNIUS','WWW.NASDAQBALTIC.COM','NOVEMBER 2015','ACTIVE','OCTOBER 2009','FIRST NORTH IS OPERATED BY NASDAQ. FIRST NORTH IS A NORDIC ALTERNATIVE MTF MARKETPLACE FOR TRADING SHARES AND OTHER TYPES OF FINANCIAL INSTRUMENTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'LUXEMBOURG','LU','CCLX','CCLX','O','FINESTI S.A.','CCLUX','LUXEMBOURG','WWW.CCLUX.LU','APRIL 2009','ACTIVE','APRIL 2009','CENTRALE DE COMMUNICATIONS LUXEMBOURG S.A. (CCLUX) CHANGED ITS NAME TO FINESTI S.A.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'LUXEMBOURG','LU','XLUX','XLUX','O','LUXEMBOURG STOCK EXCHANGE','','LUXEMBOURG','WWW.BOURSE.LU','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'LUXEMBOURG','LU','EMTF','XLUX','S','EURO MTF','','LUXEMBOURG','WWW.BOURSE.LU','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'LUXEMBOURG','LU','XVES','XVES','O','VESTIMA','','LUXEMBOURG','WWW.CLEARSTREAM.COM','DECEMBER 2014','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'MACEDONIA','MK','XMAE','XMAE','O','MACEDONIAN STOCK EXCHANGE','','SKOPJE','WWW.MSE.ORG.MK','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'MALTA','MT','EWSM','EWSM','O','EUROPEAN WHOLESALE SECURITIES MARKET','EWSM','VALLETTA','WWW.EWSM.EU','MAY 2016','ACTIVE','APRIL 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'MALTA','MT','XMAL','XMAL','O','MALTA STOCK EXCHANGE','MSE','VALLETTA','WWW.BORZAMALTA.COM.MT','MAY 2016','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'MALTA','MT','PROS','XMAL','S','PROSPECTS','','VALLETTA','WWW.SMEPROSPECTS.COM','NOVEMBER 2016','ACTIVE','NOVEMBER 2016','MTF')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','FISH','FISH','O','FISH POOL ASA','','BERGEN','WWW.FISHPOOL.EU','JUNE 2007','ACTIVE','JUNE 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','FSHX','FSHX','O','FISHEX','','TROMSO','WWW.FISHEX.NO','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','ICAS','ICAS','O','ICAP ENERGY AS','','BERGEN','WWW.ICAPENERGY.COM/EU','JULY 2008','ACTIVE','JULY 2008','MTF - ELECTRONIC TRADING PLATFORM FOR OTC DERIVATIVES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','NEXO','NEXO','O','NOREXECO ASA','NOREXECO','KONGSVINGER','WWW.NOREXECO.COM','NOVEMBER 2016','ACTIVE','JANUARY 2014','FINANCIAL DERIVATIVES, CASH SETTLED FUTURES CONTRACTS. ELECTRONIC TRADING QND CLEARING')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','NOPS','NOPS','O','NORD POOL SPOT AS','','TRONDHEIM','WWW.NORDPOOLSPOT.COM','JUNE 2011','ACTIVE','JUNE 2011','NORD POOL SPOT AS ENERGY EXCHANGE FOR NORDIC PHYSICAL MARKETS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','NORX','NORX','O','NASDAQ OMX COMMODITIES','','OSLO','WWW.NASDAQOMXCOMMODITIES.COM','MAY 2011','ACTIVE','MAY 2011','NASDAQ OMX COMMODITIES IS RESPONSIBLE FOR THE INTERNATIONAL DERIVATIVE AND CARBON PRODUCTS OFFERING, AND ALSO OPERATES THE CLEARING BUSINESS AND OFFERS CONSULTING SERVICES TO COMMODITIES MARKETS GLOBALLY.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','ELEU','NORX','S','NASDAQ COMMODITIES - EUR POWER/ENERGY','','OSLO','WWW.NASDAQOMX.COM/COMMODITIES/','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','ELSE','NORX','S','NASDAQ COMMODITIES - SEK POWER/ENERGY','','OSLO','WWW.NASDAQOMX.COM/COMMODITIES/','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','ELNO','NORX','S','NASDAQ COMMODITIES - NOK POWER/ENERGY','','OSLO','WWW.NASDAQOMX.COM/COMMODITIES/','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','ELUK','NORX','S','NASDAQ COMMODITIES - GBP POWER/ENERGY','','OSLO','WWW.NASDAQOMX.COM/COMMODITIES/','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','FREI','NORX','S','NASDAQ COMMODITIES - FREIGHT COMMODITY','','OSLO','WWW.NASDAQOMX.COM/COMMODITIES/','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','BULK','NORX','S','NASDAQ COMMODITIES - BULK COMMODITY','','OSLO','WWW.NASDAQOMX.COM/COMMODITIES/','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','STEE','NORX','S','NASDAQ COMMODITIES - STEEL COMMODITY','','OSLO','WWW.NASDAQOMX.COM/COMMODITIES/','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','NOSC','NOSC','O','NOS CLEARING ASA','NOS','OSLO','WWW.NOSCLEARING.COM','DECEMBER 2013','ACTIVE','DECEMBER 2013','CENTRAL COUNTER PARTY CLEARING HOUSE (CCP) FOR COMMODITY DERIVATIVES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','NOTC','NOTC','O','NORWEGIAN OVER THE COUNTER MARKET','NOTC','OSLO','WWW.NFMF.NO','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','OSLC','OSLC','O','SIX X-CLEAR AG','','OSLO','WWW.SIX-SECURITIES-SERVICES.COM','JUNE 2015','ACTIVE','NOVEMBER 2013','SECURITIES LENDING, TRADE REGISTRATIONS AND FINANCIAL SETTLEMENT FOR DERIVATIVES. AS OF 1 MAY 2015 OSLO CLEARING ASA IS LEGALLY INTEGRATED INTO SIX X-CLEAR LTD.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','XIMA','XIMA','O','INTERNATIONAL MARTIME EXCHANGE','IMAREX','OSLO','WWW.IMAREX.COM','JUNE 2006','ACTIVE','JUNE 2006','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','XOSL','XOSL','O','OSLO BORS ASA','','OSLO','WWW.OSLOBORS.NO','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','XOAM','XOSL','S','NORDIC ALTERNATIVE BOND MARKET','ABM','OSLO','WWW.OSLOBORS.NO','DECEMBER 2014','ACTIVE','NOVEMBER 2007','NORDIC MARKETPLACE FOR LISTING OF BONDS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','XOAS','XOSL','S','OSLO AXESS','','OSLO','WWW.OSLOBORS.NO','JUNE 2013','ACTIVE','FEBRUARY 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','XOSC','XOSL','S','OSLO CONNECT','','OSLO','WWW.OSLOBORS.NO','MAY 2013','ACTIVE','MAY 2013','MULTILATERAL TRADING FACILITY FOR FINANCIAL INSTRUMENTS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','NIBR','XOSL','S','NORWEGIAN INTER BANK OFFERED RATE','NIBOR','OSLO','WWW.OSLOBORS.NO','JULY 2013','ACTIVE','JULY 2013','OFFICIAL PLATFORM FOR SUBMISSION OF NIBOR BASIS RATES AND DISTRIBUTION OF NIBOR FIXING RATES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','XOAD','XOSL','S','OSLO AXESS NORTH SEA - DARK POOL','','OSLO','WWW.OSLOBORS.NO','APRIL 2015','ACTIVE','APRIL 2015','DARK POOL.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','XOSD','XOSL','S','OSLO BORS NORTH SEA - DARK POOL','','OSLO','WWW.OSLOBORS.NO','APRIL 2015','ACTIVE','APRIL 2015','DARK POOL.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','MERD','XOSL','S','MERKUR MARKET - DARK POOL','','OSLO','WWW.OSLOBORS.NO','AUGUST 2015','ACTIVE','AUGUST 2015','MULTILATERAL TRADING FACILITY FOR FINANCIAL INSTRUMENTS - DARK POOL')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'NORWAY','NO','MERK','XOSL','S','MERKUR MARKET','','OSLO','WWW.OSLOBORS.NO','AUGUST 2015','ACTIVE','AUGUST 2015','MULTILATERAL TRADING FACILITY FOR FINANCIAL INSTRUMENTS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'PORTUGAL','PT','OMIC','OMIC','O','THE IBERIAN ENERGY CLEARING HOUSE','OMICLEAR','LISBOA','WWW.OMICLEAR.PT','JUNE 2013','ACTIVE','JUNE 2013','REGISTERED CLEARING HOUSE ACTING AS CENTRAL COUNTERPARTY FOR EXCHANGE AND OTC DERIVATIVES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'PORTUGAL','PT','OPEX','OPEX','O','PEX-PRIVATE EXCHANGE','OPEX','LISBOA','WWW.OPEX.PT','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'PORTUGAL','PT','XLIS','XLIS','O','EURONEXT - EURONEXT LISBON','','LISBOA','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'PORTUGAL','PT','ALXL','XLIS','S','EURONEXT - ALTERNEXT LISBON','','LISBON','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','MAY 2011','ALTERNEXT IS THE NAME OF A MARKET (MTF) ORGANISED IN PORTUGAL BY EURONEXT LISBON, SOCIEDADE GESTORA DE MERCADOS REGULAMENTADOS, S.A.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'PORTUGAL','PT','ENXL','XLIS','S','EURONEXT - EASYNEXT LISBON','','LISBOA','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'PORTUGAL','PT','MFOX','XLIS','S','EURONEXT - MERCADO DE FUTUROS E OPÇÕES','','LISBOA','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','NOVEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'PORTUGAL','PT','OMIP','XLIS','S','OPERADOR DE MERCADO IBERICO DE ENERGIA - PORTUGAL','OMIP','LISBOA','WWW.OMIP.PT','MAY 2007','ACTIVE','MAY 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'PORTUGAL','PT','WQXL','XLIS','S','EURONEXT - MARKET WITHOUT QUOTATIONS LISBON','','LISBOA','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ROMANIA','RO','BMFX','BMFX','O','SIBIU MONETARY- FINANCIAL AND COMMODITIES EXCHANGE','','SIBIU','WWW.SIBEX.RO','JULY 2010','ACTIVE','JULY 2010','THE SIBIU MONETARY FINANCIAL AND COMMODITIES EXCHANGE (BURSA MONETAR FINANCIARÃ ŞI DE MÃRFURI SIBIU OR BMFMS IN ROMANIAN) IS ROMANIA''S SECOND LARGEST FINANCIAL MARKET.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ROMANIA','RO','BMFA','BMFX','S','BMFMS-ATS','','SIBIU','WWW.SIBEX.RO','OCTOBER 2010','ACTIVE','OCTOBER 2010','ALTERNATIVE TRADING SYSTEM FOR EQUITIES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ROMANIA','RO','BMFM','BMFX','S','DERIVATIVES REGULATED MARKET - BMFMS','BMFMS','SIBIU','WWW.SIBEX.RO','MAY 2010','ACTIVE','MAY 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ROMANIA','RO','SBMF','BMFX','S','SPOT REGULATED MARKET - BMFMS','','SIBIU','WWW.SIBEX.RO','FEBRUARY 2010','ACTIVE','FEBRUARY 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ROMANIA','RO','XBRM','XBRM','O','ROMANIAN  COMMODITIES EXCHANGE','BRM','BUCHAREST','WWW.BRM.RO','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ROMANIA','RO','XBSE','XBSE','O','SPOT REGULATED MARKET - BVB','REGS','BUCHAREST','WWW.BVB.RO','JANUARY 2008','ACTIVE','JANUARY 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ROMANIA','RO','XBSD','XBSE','S','DERIVATIVES REGULATED MARKET - BVB','REGF','BUCHAREST','WWW.BVB.RO','JANUARY 2008','ACTIVE','JANUARY 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ROMANIA','RO','XCAN','XBSE','S','CAN-ATS','','BUCHAREST','WWW.BVB.RO','OCTOBER 2010','ACTIVE','OCTOBER 2010','THE ALTERNATIVE TRADING SYSTEM - "CAN-ATS" ( NEW COMPANIES &amp; EQUITIES) OFFER ACCESS TO TRADING FOR NEWLY SET-UP BUSINESSES AS WELL AS FOR OTHER COMPANIES THAT CANNOT BE TRADED ON THE REGULATED MARKET OF BUCHAREST STOCK EXCHANGE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ROMANIA','RO','XRAS','XBSE','S','RASDAQ','RASDAQ','BUCHAREST','WWW.BVB.RO','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'ROMANIA','RO','XRPM','XRPM','O','ROMANIAN POWER MARKET','','BUCHAREST','WWW.OPCOM.RO','APRIL 2009','ACTIVE','APRIL 2009','ROMANIAN POWER MARKET OPERATOR (OPCOM).')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'RUSSIA','RU','MISX','MISX','O','MOSCOW EXCHANGE','MOEX','MOSCOW','WWW.MICEX.COM','JULY 2013','ACTIVE','JANUARY 2012','FORMED EXCHANGE AFTER THE MERGER OF RTS AND MICEX EXCHANGES. CURRENCY MARKET OF MICEX AND STOCK MARKET OF MICEX SE')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'RUSSIA','RU','RTSX','MISX','S','MOSCOW EXCHANGE-DERIVATIVES AND CLASSICA MARKET','MOEX','MOSCOW','WWW.MOEX.COM','OCTOBER 2015','ACTIVE','MARCH 2012','DERIVATIVES AND CLASSICA MARKET OF FORMER RTS EXCHANGE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'RUSSIA','RU','NAMX','NAMX','O','NATIONAL MERCANTILE EXCHANGE','NAMEX','MOSCOW','WWW.NAMEX.ORG','MARCH 2011','ACTIVE','MARCH 2011','ORGANIZING AND CONDUCTING TRADING OF THE FUTURES CONTRACTS ON THE COMMODITY SESSION.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'RUSSIA','RU','RPDX','RPDX','O','MOSCOW ENERGY EXCHANGE','MOSENEX','MOSCOW','WWW.MOSENEX.RU','MARCH 2013','ACTIVE','MAY 2010','RUSSIAN POWER DERIVATIVES EXCHANGE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'RUSSIA','RU','RUSX','RUSX','O','NON-PROFIT PARTNERSHIP FOR THE DEVELOPMENT OF FINANCIAL MARKET RTS','NP RTS','MOSCOW','WWW.NPRTS.RU','JANUARY 2015','ACTIVE','DECEMBER 2014','MARKET OPERATOR FOR RUSSIAN OTC MARKET.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'RUSSIA','RU','SPIM','SPIM','O','ST. PETERSBURG INTERNATIONAL MERCANTILE EXCHANGE','SPIMEX','SAINT-PETERSBURG','WWW.S-PIMEX.RU','MARCH 2011','ACTIVE','MARCH 2011','REGISTERD COMMODITIES MARKET - OIL.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'RUSSIA','RU','XMOS','XMOS','O','MOSCOW STOCK EXCHANGE','MSE','MOSCOW','WWW.MSE.RU','NOVEMBER 2007','ACTIVE','NOVEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'RUSSIA','RU','XPET','XPET','O','SAINT PETERSBURG EXCHANGE','SPEX','SAINT-PETERSBURG','WWW.SPBEX.RU','MAY 2010','ACTIVE','MAY 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'RUSSIA','RU','XPIC','XPIC','O','SAINT-PETERSBURG CURRENCY EXCHANGE','SPCEX','SAINT-PETERSBURG','WWW.SPCEX.RU','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'RUSSIA','RU','XRUS','XRUS','O','INTERNET DIRECT-ACCESS EXCHANGE','INDX','MOSCOW','WWW.INDX.RU','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'RUSSIA','RU','XSAM','XSAM','O','SAMARA CURRENCY INTERBANK EXCHANGE','SCIEX','SAMARA','WWW.SCIEX.RU','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'RUSSIA','RU','XSIB','XSIB','O','SIBERIAN EXCHANGE','SIMEX','NOVOSIBIRSK','WWW.SIBEX.RU','MAY 2010','ACTIVE','MAY 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SLOVAKIA','SK','SPXE','SPXE','O','SPX','SPX','ZILINA','WWW.SPX.SK','JUNE 2015','ACTIVE','JUNE 2015','ELECTRONIC TRADING PLATFORM FOR OTC DERIVATIVES - SLOVAK AND CZECH POWER AND GAS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SLOVAKIA','SK','XBRA','XBRA','O','BRATISLAVA STOCK EXCHANGE','BSSE','BRATISLAVA','WWW.BSSE.SK','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SLOVAKIA','SK','EBRA','XBRA','S','BRATISLAVA STOCK EXCHANGE-MTF','','BRATISLAVA','WWW.BSSE.SK','DECEMBER 2016','ACTIVE','DECEMBER 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SLOVENIA','SI','XLJU','XLJU','O','LJUBLJANA STOCK EXCHANGE (OFFICIAL MARKET)','','LJUBLJANA','WWW.LJSE.SI','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SLOVENIA','SI','XLJM','XLJU','S','SI ENTER','','LJUBLJANA','WWW.LJSE.SI','DECEMBER 2016','ACTIVE','DECEMBER 2016','MULTILATERAL TRADING FACILITY OF THE LJUBLJANA STOCK EXCHANGE. NOT LIVE YET.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SLOVENIA','SI','XSOP','XSOP','O','BSP REGIONAL ENERGY EXCHANGE - SOUTH POOL','','LJUBLJANA','WWW.BSP-SOUTHPOOL.COM','APRIL 2009','ACTIVE','APRIL 2009','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','BMEX','BMEX','O','BME - BOLSAS Y MERCADOS ESPANOLES','BME','MADRID','WWW.BOLSASYMERCADOS.ES','AUGUST 2012','ACTIVE','AUGUST 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','MABX','BMEX','S','MERCADO ALTERNATIVO BURSATIL','MAB','MADRID','WWW.BOLSASYMERCADOS.ES','JULY 2007','ACTIVE','JULY 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','SEND','BMEX','S','SEND - SISTEMA ELECTRONICO DE NEGOCIACION DE DEUDA','SEND','MADRID','WWW.AIAF.ES','OCTOBER 2013','ACTIVE','JUNE 2010','SEND IS AN ELECTRONIC TRADING PLATFORM, DEVELOPED BY AIAF MERCADO DE RENTA FIJA, DESIGNED FOR THE TRADING OF RETAIL DISTRIBUTED FIXED INCOME SECURITIES LISTED IN THIS MARKET.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','XBAR','BMEX','S','BOLSA DE BARCELONA','','BARCELONA','WWW.BORSABCN.ES','JUNE 2011','ACTIVE','JUNE 2011','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','XBIL','BMEX','S','BOLSA DE VALORES DE BILBAO','','BILBAO','WWW.BOLSABILBAO.ES','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','XDRF','BMEX','S','AIAF - MERCADO DE RENTA FIJA','','MADRID','WWW.AIAF.ES','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','XLAT','BMEX','S','LATIBEX','','MADRID','WWW.LATIBEX.COM','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','XMAD','BMEX','S','BOLSA DE MADRID','','MADRID','WWW.BOLSAMADRID.ES','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','XMCE','BMEX','S','MERCADO CONTINUO ESPANOL - CONTINUOUS MARKET','SIBE','MADRID','WWW.BOLSASYMERCADOS.ES','NOVEMBER 2007','ACTIVE','NOVEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','XMRV','BMEX','S','MEFF FINANCIAL DERIVATIVES','MEFF','MADRID','WWW.MEFF.COM','JUNE 2014','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','XVAL','BMEX','S','BOLSA DE VALENCIA','','VALENCIA','WWW.BOLSAVALENCIA.ES','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','MERF','BMEX','S','MERCADO ELECTRONICO DE RENTA FIJA','MERF','MADRID','WWW.BMERF.ES','OCTOBER 2013','ACTIVE','AUGUST 2012','REGISTERED MARKET FOR BONDS ELECTRONIC TRADING PLATFORM.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','MARF','BMEX','S','MERCADO ALTERNATIVO DE RENTA FIJA','MARF','MADRID','WWW.AIAF.ES','JULY 2013','ACTIVE','JULY 2013','ALTERNATIVE FIXED INCOME MARKET FOR SMALL AND MEDIUM ENTERPRISES ISSUES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','BMCL','BMEX','S','BME CLEARING S.A.','','MADRID','WWW.AIAF.ES','OCTOBER 2013','ACTIVE','OCTOBER 2013','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','XMPW','BMEX','S','MEFF POWER DERIVATIVES','MEPD','MADRID','WWW.MEFF.COM','JUNE 2014','ACTIVE','JUNE 2014','MEFF SEGMENT FOR THE TRADING OF POWER DERIVATIVES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','SBAR','BMEX','S','BOLSA DE BARCELONA RENTA FIJA','','BARCELONA','WWW.BOLSASYMERCADOS.ES','FEBRUARY 2017','ACTIVE','FEBRUARY 2017','ELECTRONIC TRADING PLATFORM FIXED INCOME BOLSA DE BARCELONA')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','SBIL','BMEX','S','BOLSA DE BILBAO RENTA FIJA','','BILBAO','WWW.BOLSASYMERCADOS.ES','FEBRUARY 2017','ACTIVE','FEBRUARY 2017','ELECTRONIC TRADING PLATFORM FIXED INCOME BOLSA DE BILBAO.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','IBGH','IBGH','O','IBERIAN GAS HUB','IBGH','BILBAO','WWW.IBERIANGASHUB.COM','APRIL 2015','ACTIVE','APRIL 2015','TRADING PLATFORM FOR THE IBERIAN GAS MARKET.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','MIBG','MIBG','O','MERCADO ORGANIZADO DEL GAS','MIBGAS','MADRID','WWW.MERCADOSGAS.OMIE.ES','JULY 2015','ACTIVE','JULY 2015','REGULATED MARKET OPERATOR FOR THE ORGANISED GAS MARKET IN SPAIN.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','OMEL','OMEL','O','OMI POLO ESPANOL S.A. (OMIE)','OMIE','MADRID','WWW.OMIE.ES','NOVEMBER 2014','ACTIVE','MAY 2007','OMIE IS LEGAL SUCCESSOR OF OMEL AS MARKET OPERATOR BY WAY OF UNIVERSAL LEGAL SUCCESSION')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','PAVE','PAVE','O','ALTERNATIVE PLATFORM FOR SPANISH SECURITIES','PAVE','BARCELONA','WWW.PAVEPLATFORM.COM','MARCH 2012','ACTIVE','MARCH 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','XDPA','XDPA','O','CADE - MERCADO DE DEUDA PUBLICA ANOTADA','','MADRID','','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SPAIN','ES','XNAF','XNAF','O','SISTEMA ESPANOL DE NEGOCIACION DE ACTIVOS FINANCIEROS','SENAF','MADRID','WWW.SENAF.NET','JUNE 2007','ACTIVE','JUNE 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','CRYD','CRYD','O','CRYEX - FX AND DIGITAL CURRENCIES','','STOCKHOLM','WWW.CRYEX.COM','JUNE 2015','ACTIVE','JUNE 2015','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','CRYX','CRYX','O','CRYEX','','STOCKHOLM','WWW.CRYEX.COM','JUNE 2015','ACTIVE','JUNE 2015','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','SEBX','SEBX','O','SEB - LIQUIDITY POOL','SEB','STOCKHOLM','WWW.SEB.SE','NOVEMBER 2012','ACTIVE','NOVEMBER 2012','SKANDINAVISKA ENSKILDA BANKEN AB LIQUIDITY POOL.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','ENSX','SEBX','S','SEB ENSKILDA','','STOCKHOLM','WWW.SEB.SE','NOVEMBER 2012','ACTIVE','NOVEMBER 2012','SEB ENSKILADA LIQUIDITY POOL.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','XNGM','XNGM','O','NORDIC GROWTH MARKET','NGM','STOCKHOLM','WWW.NGM.SE','APRIL 2012','ACTIVE','APRIL 2012','REINSTATED. CONFIRMED BY EXCHANGE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','NMTF','XNGM','S','NORDIC MTF','','STOCKHOLM','WWW.NORDICMTF.SE','NOVEMBER 2007','ACTIVE','NOVEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','XNDX','XNGM','S','NORDIC DERIVATIVES EXCHANGE','NDX','STOCKHOLM','WWW.NDX.SE','MARCH 2008','ACTIVE','MARCH 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','XNMR','XNGM','S','NORDIC MTF REPORTING','','STOCKHOLM','WWW.NORDICMTF.SE','APRIL 2008','ACTIVE','APRIL 2008','OFF EXCHANGE TRADE REPORTING')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','XSAT','XSAT','O','AKTIETORGET','','STOCKHOLM','WWW.AKTIETORGET.SE','JUNE 2007','ACTIVE','JUNE 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','XSTO','XSTO','O','NASDAQ STOCKHOLM AB','','STOCKHOLM','WWW.NASDAQOMXNORDIC.COM','DECEMBER 2015','ACTIVE','JULY 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','FNSE','XSTO','S','FIRST NORTH SWEDEN','','STOCKHOLM','NASDAQOMXNORDIC.COM/FIRSTNORTH','NOVEMBER 2015','ACTIVE','JANUARY 2008','FIRST NORTH IS OPERATED BY NASDAQ. FIRST NORTH IS A NORDIC ALTERNATIVE MTF MARKETPLACE FOR TRADING SHARES AND OTHER TYPES OF FINANCIAL INSTRUMENTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','XOPV','XSTO','S','OTC PUBLICATION VENUE','','STOCKHOLM','WWW.NASDAQOMXNORDIC.COM','DECEMBER 2014','ACTIVE','NOVEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','CSTO','XSTO','S','NASDAQ CLEARING AB','','STOCKHOLM','WWW.NASDAQOMX.COM/EUROPEANCLEARING','DECEMBER 2015','ACTIVE','NOVEMBER 2014','CLEARING HOUSE FOR EQUITY, FIXED INCOME AND COMMODITIES DERIVATIVES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','DSTO','XSTO','S','NASDAQ STOCKHOLM AB - NORDIC@MID','','STOCKHOLM','WWW.NASDAQOMXNORDIC.COM','DECEMBER 2015','ACTIVE','NOVEMBER 2015','NORDIC@MID DARK POOL FOR XSTO')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','DNSE','XSTO','S','FIRST NORTH SWEDEN - NORDIC@MID','','STOCKHOLM','NASDAQOMXNORDIC.COM/FIRSTNORTH','NOVEMBER 2015','ACTIVE','NOVEMBER 2015','NORDIC@MID DARK POOL FOR FIRST NORTH SWEDEN')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','MSTO','XSTO','S','NASDAQ STOCKHOLM AB – AUCTION ON DEMAND','','STOCKHOLM','WWW.NASDAQOMXNORDIC.COM','JUNE 2016','ACTIVE','JUNE 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','MNSE','XSTO','S','FIRST NORTH SWEDEN – AUCTION ON DEMAND','','STOCKHOLM','WWW.NASDAQOMXNORDIC.COM','JUNE 2016','ACTIVE','JUNE 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','DKED','XSTO','S','NASDAQ STOCKHOLM AB - DANISH EQ DERIVATIVES','','STOCKHOLM','WWW.NASDAQOMXNORDIC.COM','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','FIED','XSTO','S','NASDAQ STOCKHOLM AB - FINNISH EQ DERIVATIVES','','STOCKHOLM','WWW.NASDAQOMXNORDIC.COM','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','NOED','XSTO','S','NASDAQ STOCKHOLM AB - NORWEGIAN EQ DERIVATIVES','','STOCKHOLM','WWW.NASDAQOMXNORDIC.COM','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','SEED','XSTO','S','NASDAQ STOCKHOLM AB - SWEDISH EQ DERIVATIVES','','STOCKHOLM','WWW.NASDAQOMXNORDIC.COM','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','PNED','XSTO','S','NASDAQ STOCKHOLM AB - PAN-NORDIC EQ DERIVATIVES','','STOCKHOLM','WWW.NASDAQOMXNORDIC.COM','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','EUWB','XSTO','S','NASDAQ STOCKHOLM AB - EUR WB EQ DERIVATIVES','','STOCKHOLM','WWW.NASDAQOMXNORDIC.COM','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','USWB','XSTO','S','NASDAQ STOCKHOLM AB - USD WB EQ DERIVATIVES','','STOCKHOLM','WWW.NASDAQOMXNORDIC.COM','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','DKFI','XSTO','S','NASDAQ STOCKHOLM AB - DANISH FI DERIVATIVES','','STOCKHOLM','WWW.NASDAQOMXNORDIC.COM','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','EBON','XSTO','S','NASDAQ STOCKHOLM AB - EUR FI DERIVATIVES','','STOCKHOLM','WWW.NASDAQOMXNORDIC.COM','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWEDEN','SE','NOFI','XSTO','S','NASDAQ STOCKHOLM AB - NORWEGIAN FI DERIVATIVES','','STOCKHOLM','WWW.NASDAQOMXNORDIC.COM','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','AIXE','AIXE','O','AIXECUTE','','BERNE','WWW.BEKB.CH','OCTOBER 2013','ACTIVE','JULY 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','DOTS','DOTS','O','SWISS DOTS BY CATS','DOTS','ZURICH','WWW.BS-CATS.COM','FEBRUARY 2015','ACTIVE','OCTOBER 2013','OTC DERIVATIVES AVAILABLE TO THE SWISS MARKET USING THE CATS PLATFORM IN ASSOCIATION WITH SWISSQUOTE BANK. THE OWNER OF CATS HAS CHANGED FROM CITIGROUP TO BOERSE STUTTGART.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','EUCH','EUCH','O','EUREX ZURICH','','ZURICH','WWW.EUREXREPO.COM','JULY 2012','ACTIVE','JULY 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','EUSP','EUCH','S','EUREX OTC SPOT MARKET','','ZURICH','WWW.EUREXREPO.COM','JULY 2012','ACTIVE','JULY 2012','EUREX SWISS OTC/SPOT MARKET.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','EURM','EUCH','S','EUREX REPO MARKET','','ZURICH','WWW.EUREXREPO.COM','JULY 2012','ACTIVE','JULY 2012','EUREX SWISS REPO MARKET.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','EUSC','EUCH','S','EUREX CH SECLEND MARKET','','ZURICH','WWW.EUREXREPO.COM','JULY 2012','ACTIVE','JULY 2012','EUREX SWISS SECURITIES LENDING MARKET.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','S3FM','S3FM','O','SOCIETY3 FUNDERSMART','S3FM','LUZERN','HTTP://SOCIETY3.COM','JANUARY 2017','ACTIVE','JANUARY 2017','NON REGULATED, US SEC AND SWISS FINMA COMPLIANT AND BANKING LICENSE EXEMPT EQUITY FUNDRAISING AND TRADING PLATFORM.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','STOX','STOX','O','STOXX LIMITED','','ZURICH','WWW.STOXX.COM','MARCH 2013','ACTIVE','AUGUST 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','XSCU','STOX','S','STOXX LIMITED - CUSTOMIZED INDICES','','ZURICH','WWW.STOXX.COM','MARCH 2011','ACTIVE','MARCH 2011','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','XSTV','STOX','S','STOXX LIMITED - VOLATILITY INDICES','','ZURICH','WWW.STOXX.COM','MARCH 2011','ACTIVE','MARCH 2011','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','XSTX','STOX','S','STOXX LIMITED - INDICES','','ZURICH','WWW.STOXX.COM','MARCH 2011','ACTIVE','MARCH 2011','')


INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','UBSG','UBSG','O','UBS TRADING','','ZURICH','WWW.UBS.COM','AUGUST 2013','ACTIVE','AUGUST 2013','UBS TRADING PLATFORMS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','UBSF','UBSG','S','UBS FX','','ZURICH','WWW.UBS.COM','SEPTEMBER 2013','ACTIVE','JULY 2013','UBS E-FX EXECUTION VENUE')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','UBSC','UBSG','S','UBS PIN-FX','','ZURICH','WWW.UBS.COM','SEPTEMBER 2013','ACTIVE','JULY 2013','UBS FX PRICE IMPROVEMENT NETWORK')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','VLEX','VLEX','O','VONTOBEL LIQUIDITY EXTENDER','VLEX','ZURICH','WWW.VONTOBEL.COM','MARCH 2016','ACTIVE','MARCH 2016','SYSTEMATIC INTERNALISER')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','XBRN','XBRN','O','BX SWISS AG','','BERN','WWW.BXSWISS.COM; WWW.BERNE-X.COM','AUGUST 2014','ACTIVE','JUNE 2005','BX WORLDCAPS, BX LOCAL SHARES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','XSWX','XSWX','O','SIX SWISS EXCHANGE','SIX','ZURICH','WWW.SIX-SWISS-EXCHANGE.COM','APRIL 2015','ACTIVE','JUNE 2005','MID/SMALL CAP EQUITY, FUNDS, ETFS, BOND SEGMENT.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','XQMH','XSWX','S','SIX SWISS EXCHANGE – STRUCTURED PRODUCTS','SIX','ZURICH','WWW.SIX-STRUCTURED-PRODUCTS.COM','APRIL 2017','ACTIVE','OCTOBER 2007','WARRANTS AND STRUCTURED PRODUCTS SEGMENT.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','XVTX','XSWX','S','SIX SWISS EXCHANGE - BLUE CHIPS SEGMENT','SIX','ZURICH','WWW.SIX-SWISS-EXCHANGE.COM','APRIL 2015','ACTIVE','MARCH 2010','BLUE CHIPS EQUITY SEGMENT.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','XBTR','XSWX','S','SIX SWISS BILATERAL TRADING PLATFORM FOR STRUCTURED OTC PRODUCTS','SIX','ZURICH','WWW.SIX-SWISS-EXCHANGE.COM','APRIL 2015','ACTIVE','MARCH 2013','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','XICB','XSWX','S','SIX CORPORATE BONDS AG','SIX','ZURICH','WWW.SIX-SWISS-EXCHANGE.COM','AUGUST 2015','ACTIVE','MARCH 2015','REGULATED PLATFORM FOR CORPORATE BONDS TRADING.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','XSWM','XSWX','S','SIX SWISS EXCHANGE - SIX SWISS EXCHANGE AT MIDPOINT','SIX','ZURICH','WWW.SIX-SWISS-EXCHANGE.COM','SEPTEMBER 2016','ACTIVE','SEPTEMBER 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','XSLS','XSWX','S','SIX SWISS EXCHANGE - SLS','SIX','ZURICH','WWW.SIX-SWISS-EXCHANGE.COM','SEPTEMBER 2016','ACTIVE','SEPTEMBER 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','ZKBX','ZKBX','O','ZURCHER KANTONALBANK SECURITIES EXCHANGE','','ZURICH','WWW.ZKB.CH','FEBRUARY 2017','ACTIVE','JUNE 2011','REGISTERED MARKET FOR EQUITIES AND BONDS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'SWITZERLAND','CH','KMUX','ZKBX','S','ZURCHER KANTONALBANK - EKMU-X','','ZURICH','WWW.ZKB.CH/EKMUX','FEBRUARY 2017','ACTIVE','FEBRUARY 2017','ELECTRONIC TRADING PLATFORM FOR SWISS EQUITIES (OTC).')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','CLMX','CLMX','O','CLIMEX','','UTRECHT','WWW.CLIMEX.COM','JULY 2009','ACTIVE','JULY 2009','MARKET FOR TRADING AND AUCTIONING ENVIRONMENTAL COMMODITIES AND ENERGY CONTRACTS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','HCHC','HCHC','O','ICE CLEAR NETHERLANDS B.V.','','AMSTERDAM','WWW.THEICE.COM','SEPTEMBER 2015','ACTIVE','JANUARY 2014','CENTRAL COUNTER PARTY FOR EXCHANGE TRADED DERIVATIVES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','NDEX','NDEX','O','ICE ENDEX DERIVATIVES B.V.','ICE ENDEX','AMSTERDAM','WWW.ICEENDEX.COM','AUGUST 2015','ACTIVE','MAY 2007','ENERGY DERIVATIVES MARKET')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','IMCO','NDEX','S','ICE ENDEX PHYSICAL FORWARDS','','AMSTERDAM','WWW.THEICE.COM','MAY 2017','MODIFIED','JUNE 2011','ELECTRONIC PLATFORM TO TRADE PHYSICAL FORWARDS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','IMEQ','NDEX','S','ICE MARKETS EQUITY','ICE ENDEX','AMSTERDAM','WWW.THEICE.COM/ENDEX','MARCH 2017','ACTIVE','JUNE 2011','ELECTRONIC PLATFORM TO TRADE EQUITY PRODUCTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','NDXS','NDEX','S','ICE ENDEX GAS B.V.','ICE ENDEX','AMSTERDAM','WWW.ICEENDEX.COM','AUGUST 2015','ACTIVE','FEBRUARY 2014','SPOT MARKET')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','NLPX','NLPX','O','APX POWER NL','','AMSTERDAM','WWW.APXGROUP.COM','JUNE 2006','ACTIVE','JUNE 2006','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','TOMX','TOMX','O','TOM MTF CASH MARKETS','','AMSTERDAM','WWW.TOMMTF.EU','JUNE 2011','ACTIVE','JUNE 2011','MTF FOR EQUITIES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','TOMD','TOMX','S','TOM MTF DERIVATIVES MARKET','','AMSTERDAM','WWW.TOMMTF.EU','JUNE 2011','ACTIVE','JUNE 2011','MTF FOR DERIVATIVES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','XAMS','XAMS','O','EURONEXT - EURONEXT AMSTERDAM','','AMSTERDAM','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','ALXA','XAMS','S','EURONEXT - ALTERNEXT AMSTERDAM','','AMSTERDAM','WWW.EURONEXT.COM','MAY 2015','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','TNLA','XAMS','S','EURONEXT - TRADED BUT NOT LISTED AMSTERDAM','','AMSTERDAM','WWW.EURONEXT.COM','APRIL 2015','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','XEUC','XAMS','S','EURONEXT COM, COMMODITIES FUTURES AND OPTIONS','','AMSTERDAM','WWW.EURONEXT.COM','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','XEUE','XAMS','S','EURONEXT EQF, EQUITIES AND INDICES DERIVATIVES','','AMSTERDAM','WWW.EURONEXT.COM','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','XEUI','XAMS','S','EURONEXT IRF, INTEREST RATE FUTURE AND OPTIONS','','AMSTERDAM','WWW.EURONEXT.COM','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','XEMS','XEMS','O','EMS EXCHANGE','','S-HERTOGENBOSCH','WWW.VANLANSCHOT.NL','SEPTEMBER 2012','ACTIVE','SEPTEMBER 2012','REGISTERED MARKET FOR SECURITIES, ELECTRONIC TRADING PLATFORM.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'THE NETHERLANDS','NL','XNXC','XNXC','O','NXCHANGE','','AMSTERDAM','WWW.NXCHANGE.COM','MAY 2016','ACTIVE','MAY 2016','REGULATED MARKET, TRADING PLATFORM NXCHANGE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'TURKEY','TR','EXTR','EXTR','O','ENERGY EXCHANGE ISTANBUL','EXIST','ISTANBUL','HTTPS://WWW.EPIAS.COM.TR','MAY 2016','ACTIVE','MAY 2016','LICENSED ENERGY MARKET OPERATOR FOR DAY AHEAD/INTRADAY ELECTRICITY MARKETS AND ESTABLISHMENT OF NATURAL GAS MARKET.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'TURKEY','TR','XEID','EXTR','S','ELECTRICITY INTRA-DAY MARKET','EXIST','ISTANBUL','HTTPS://WWW.EPIAS.COM.TR','MAY 2016','ACTIVE','MAY 2016','ELECTRICITY INTRA-DAY MARKET')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'TURKEY','TR','XEDA','EXTR','S','ELECTRICITY DAY-AHEAD MARKET','EXIST','ISTANBUL','HTTPS://WWW.EPIAS.COM.TR','MAY 2016','ACTIVE','MAY 2016','ELECTRICITY DAY-AHEAD MARKET')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'TURKEY','TR','XIST','XIST','O','BORSA ISTANBUL','','ISTANBUL','WWW.BORSAISTANBUL.COM','MAY 2013','ACTIVE','JUNE 2005','CHANGE OF MARKET NAME AND MARKET WEBSITE')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'TURKEY','TR','XFNO','XIST','S','BORSA ISTANBUL - FUTURES AND OPTIONS MARKET','','ISTANBUL','WWW.BORSAISTANBUL.COM','JANUARY 2014','ACTIVE','JANUARY 2014','FUTURES AND OPTIONS MARKET')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'TURKEY','TR','XEQY','XIST','S','BORSA ISTANBUL - EQUITY MARKET','','ISTANBUL','WWW.BORSAISTANBUL.COM','JANUARY 2014','ACTIVE','JANUARY 2014','EQUITY MARKET')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'TURKEY','TR','XDSM','XIST','S','BORSA ISTANBUL - DEBT SECURITIES MARKET','','ISTANBUL','WWW.BORSAISTANBUL.COM','JANUARY 2014','ACTIVE','JANUARY 2014','DEBT SECURITIES MARKET')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'TURKEY','TR','XPMS','XIST','S','BORSA ISTANBUL - PRECIOUS METALS AND DIAMONDS MARKETS','','ISTANBUL','WWW.BORSAISTANBUL.COM','JANUARY 2014','ACTIVE','JANUARY 2014','PRECIOUS METALS AND DIAMONDS MARKETS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UKRAINE','UA','EESE','EESE','O','EAST EUROPEAN STOCK EXCHANGE','','KIEV','WWW.EESE.COM.UA','MAY 2010','ACTIVE','MAY 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UKRAINE','UA','PFTS','PFTS','O','PFTS STOCK EXCHANGE','PFTS','KIEV','WWW.PFTS.COM','MAY 2010','ACTIVE','MAY 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UKRAINE','UA','PFTQ','PFTS','S','PFTS QUOTE DRIVEN','','KIEV','WWW.PFTS.COM','OCTOBER 2010','ACTIVE','OCTOBER 2010','QUOTE DRIVEN MARKET IS A TRADING SEGMENT UNDER PFTS STOCK EXCHANGE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UKRAINE','UA','SEPE','SEPE','O','STOCK EXCHANGE PERSPECTIVA','','DNIPROPETROVSK','FBP.COM.UA','MAY 2010','ACTIVE','MAY 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UKRAINE','UA','UKEX','UKEX','O','UKRAINIAN EXCHANGE','','KIEV','WWW.UX.UA','DECEMBER 2011','ACTIVE','DECEMBER 2011','REGISTERED MARKET FOR EQUITIES AND BONDS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UKRAINE','UA','XDFB','XDFB','O','JOINT-STOCK COMPANY “STOCK EXCHANGE INNEX”','','KIEV','','MAY 2010','ACTIVE','MAY 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UKRAINE','UA','XKHR','XKHR','O','KHARKOV COMMODITY EXCHANGE','','KHARKOV','WWW.XTB.COM.UA','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UKRAINE','UA','XKIE','XKIE','O','KIEV UNIVERSAL EXCHANGE','','KIEV','WWW.KUE.KIEV.UA','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UKRAINE','UA','XKIS','XKIS','O','KIEV INTERNATIONAL STOCK EXCHANGE','KISE','KIEV','WWW.KISE-UA.COM','JUNE 2006','ACTIVE','JUNE 2006','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UKRAINE','UA','XODE','XODE','O','ODESSA COMMODITY EXCHANGE','','ODESSA','WWW.OTB.ODESSA.UA','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UKRAINE','UA','XPRI','XPRI','O','PRIDNEPROVSK COMMODITY EXCHANGE','','DNIPROPETROVSK','','MAY 2010','ACTIVE','MAY 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UKRAINE','UA','XUAX','XUAX','O','UKRAINIAN STOCK EXCHANGE','UKRSE','KIEV','WWW.UKRSE.KIEV.UA','FEBRUARY 2006','ACTIVE','FEBRUARY 2006','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UKRAINE','UA','XUKR','XUKR','O','UKRAINIAN UNIVERSAL COMMODITY EXCHANGE','','KIEV','WWW.UUTB.COM.UA','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','AFDL','AFDL','O','ABIDE FINANCIAL DRSP LIMITED APA','AFDLAPA','LONDON','WWW.ABIDE-FINANCIAL.COM','MARCH 2017','ACTIVE','MARCH 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','AQXE','AQXE','O','AQUIS EXCHANGE','AQX','LONDON','WWW.AQUIS.EU','JULY 2013','ACTIVE','JULY 2013','PAN-EUROPEAN EQUITIES TRADING EXCHANGE (MTF)')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','ARAX','ARAX','O','ARAX COMMODITIES LTD','','LONDON','WWW.ARAXCOMMODITIES.COM','MARCH 2016','ACTIVE','MARCH 2016','PLATFORM FOR OTC ENERGY DERIVATIVES, SPECIFICALLY EUROPEAN POWER')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','ATLB','ATLB','O','ATLANTIC BROKERS LTD','','LONDON','WWW.ATLANTICBROKERS.CO.UK','MAY 2016','ACTIVE','MAY 2016','INTRODUCING BROKER FOR FINANCIAL COAL FUTURES, OPTIONS AND PHYSICAL COAL.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','AUTX','AUTX','O','AUTILLA','','LONDON','WWW.AUTILLA.COM','MARCH 2017','ACTIVE','FEBRUARY 2017','ELECTRONIC PLATFORM FOR COMMODITIES AND FX.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','AUTP','AUTX','S','AUTILLA - PRECIOUS METALS','','LONDON','WWW.AUTILLA.COM','MARCH 2017','ACTIVE','MARCH 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','AUTB','AUTX','S','AUTILLA - BASE METALS','','LONDON','WWW.AUTILLA.COM','MARCH 2017','ACTIVE','MARCH 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BALT','BALT','O','THE BALTIC EXCHANGE','','LONDON','WWW.BALTICEXCHANGE.COM','NOVEMBER 2008','ACTIVE','NOVEMBER 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BLTX','BALT','S','BALTEX - FREIGHT DERIVATIVES MARKET','','LONDON','WWW.BALTICEXCHANGE.COM','JULY 2013','ACTIVE','JULY 2013','MTF FOR ELECTRONIC TRADING OF FREIGHT DERIVATIVES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BCRM','BCRM','O','BATS EUROPE REGULATED MARKETS','BATS  EUROPE','LONDON','WWW.BATSTRADING.CO.UK','MAY 2017','ACTIVE','MAY 2017','BATS REGULATED MARKETS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BARO','BCRM','S','BATS EUROPE - REGULATED MARKET OFF BOOK','BATS  REGM OFF BOOK','LONDON','WWW.BATSTRADING.CO.UK','MAY 2017','MODIFIED','JUNE 2016','BATS EUROPE - REGULATED MARKET SECURITIES MIC CODE FOR OFF-BOOK TRADES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BARK','BCRM','S','BATS EUROPE - REGULATED MARKET DARK BOOK','BATS  REGM DARK','LONDON','WWW.BATSTRADING.CO.UK','MAY 2017','MODIFIED','JUNE 2016','BATS EUROPE - REGULATED MARKET SECURITIES MIC CODE FOR DARK ORDER BOOK TRADES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BART','BCRM','S','BATS EUROPE - REGULATED MARKET INTEGRATED BOOK','BATS  REGM LIT','LONDON','WWW.BATSTRADING.CO.UK','MAY 2017','MODIFIED','JUNE 2016','BATS EUROPE - REGULATED MARKET SECURITIES MIC CODE FOR INTEGRATED BOOK TRADES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BCXE','BCXE','O','BATS  EUROPE','BATS  EUROPE','LONDON','WWW.BATSTRADING.CO.UK','APRIL 2016','ACTIVE','APRIL 2013','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BATE','BCXE','S','BATS EUROPE -BXE ORDER BOOKS','BATS EUROPE','LONDON','WWW.BATSTRADING.CO.UK','SEPTEMBER 2016','ACTIVE','NOVEMBER 2008','MULTILATERAL TRADING FACILITY FOR CASH EQUITIES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','CHIX','BCXE','S','BATS EUROPE - CXE ORDER BOOKS','BATS EUROPE','LONDON','WWW.BATSTRADING.CO.UK','APRIL 2016','ACTIVE','OCTOBER 2007','MULTILATERAL TRADING FACILITY FOR CASH EQUITIES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BATD','BCXE','S','BATS EUROPE -BXE DARK ORDER BOOK','BATS DARK','LONDON','WWW.BATSTRADING.CO.UK','APRIL 2016','ACTIVE','JANUARY 2013','TO BE USED FOR REPORTING DARK BOOK EXECUTIONS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','CHID','BCXE','S','BATS EUROPE - CXE DARK ORDER BOOK','CXE DARK','LONDON','WWW.BATSTRADING.CO.UK','APRIL 2016','ACTIVE','JANUARY 2013','TO BE USED FOR REPORTING DARK BOOK EXECUTIONS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BATF','BCXE','S','BATS EUROPE – BATS OFF-BOOK','BATS OFF-BOOK','LONDON','WWW.BATSTRADING.CO.UK','APRIL 2016','ACTIVE','APRIL 2013','BATS EUROPE (BXE) OFF-BOOK TRADE REPORTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','CHIO','BCXE','S','BATS EUROPE - CXE - OFF-BOOK','CXE OFF-BOOK','LONDON','WWW.BATSTRADING.CO.UK','SEPTEMBER 2016','ACTIVE','APRIL 2013','BATS EUROPE - CXE - OFF-BOOK TRADE REPORTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BOTC','BCXE','S','OFF EXCHANGE IDENTIFIER FOR OTC TRADES REPORTED TO BATS EUROPE','BATS OFF EXCHANGE','LONDON','WWW.BATSTRADING.CO.UK','SEPTEMBER 2016','ACTIVE','AUGUST 2013','OFF EXCHANGE IDENTIFIER FOR OTC TRADES REPORTED TO BATS EUROPE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BATP','BCXE','S','BATS EUROPE - BXE PERIODIC','','LONDON','WWW.BATSTRADING.CO.UK','APRIL 2016','ACTIVE','JULY 2015','TO BE USED FOR EXECUTIONS RESULTING FROM BATS BXE AUCTIONS BOOK.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','LISX','BCXE','S','BATS  EUROPE - LIS SERVICE','BATS  LIS','LONDON','WWW.BATSTRADING.CO.UK','SEPTEMBER 2016','ACTIVE','SEPTEMBER 2016','TO BE USED FOR EXECUTIONS RESULTING FROM BATS EUROPE LIS SERVICE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BGCI','BGCI','O','BGC BROKERS LP','','LONDON','WWW.BGCPARTNERS.COM','OCTOBER 2007','ACTIVE','OCTOBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BGCB','BGCI','S','BGC BROKERS LP - TRAYPORT','','LONDON','WWW.BGCPARTNERS.COM','FEBRUARY 2014','ACTIVE','FEBRUARY 2014','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BLOX','BLOX','O','BLOCKMATCH','','LONDON','WWW.INSTINET.COM','NOVEMBER 2007','ACTIVE','NOVEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BMTF','BMTF','O','BLOOMBERG TRADING FACILITY LIMITED','','LONDON','WWW.BLOOMBERG.COM','JUNE 2015','ACTIVE','JUNE 2015','BLOOMBERG''S MULTI-LATERAL TRADING FACILITY')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BOAT','BOAT','O','CINNOBER BOAT','','LONDON','WWW.CINNOBER.COM/BOAT-TRADE-REPORTING','SEPTEMBER 2014','ACTIVE','JUNE 2008','OTC EQUITIES TRADE REPORTING PLATFORM')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BOSC','BOSC','O','BONDSCAPE','','LONDON','WWW.BONDSCAPE.NET','NOVEMBER 2007','ACTIVE','NOVEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BRNX','BRNX','O','BERNSTEIN CROSS (BERN-X)','BERN-X','LONDON','WWW.ALLIANCEBERNSTEIN.COM','MAY 2014','ACTIVE','MAY 2014','INTERNAL CROSSING FOR BERNSTEIN')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BTEE','BTEE','O','BROKERTEC EU MTF','BEM','LONDON','WWW.BROKERTEC.COM/','MARCH 2017','ACTIVE','OCTOBER 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','EBSX','BTEE','S','EBS MTF','EBS','LONDON','WWW.EBS.COM','MARCH 2017','ACTIVE','DECEMBER 2015','MULTILATERAL TRADING FACILITY FOR FX DERIVATIVES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','CCO2','CCO2','O','CANTORCO2E.COM LIMITED','','LONDON','WWW.CANTORCO2E.COM','JULY 2007','ACTIVE','JULY 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','CGME','CGME','O','CITI MATCH','','LONDON','WWW.CITIGROUP.COM','APRIL 2012','ACTIVE','APRIL 2012','CITI MATCH EMEA')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','CHEV','CHEV','O','CA CHEUVREUX','','LONDON','WWW.CHEUVREUX.COM','JUNE 2012','ACTIVE','JUNE 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BLNK','CHEV','S','BLINK MTF','','LONDON','WWW.CHEUVREUX.COM','SEPTEMBER 2009','ACTIVE','SEPTEMBER 2009','EQUITIES CROSSING, EQUITIES DARK POOL, PAN-EUROPEAN EQUITIES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','CMEE','CMEE','O','CME  EUROPE','CME','LONDON','WWW.CMEGROUP.COM','JANUARY 2013','ACTIVE','JANUARY 2013','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','CMEC','CMEE','S','CME CLEARING EUROPE','CME','LONDON','WWW.CMECLEARINGEUROPE.COM','FEBRUARY 2014','ACTIVE','DECEMBER 2011','EUROPEAN CLEARING HOUSE')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','CMED','CMEE','S','CME EUROPE - DERIVATIVES','CME','LONDON','WWW.CMEEUROPE.COM','FEBRUARY 2014','ACTIVE','JANUARY 2013','CME EUROPE TRADING PLATFORM')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','CMMT','CMMT','O','CLEAR MARKETS EUROPE LIMITED','CM MTF','LONDON','WWW.CLEAR-MARKETS.COM','DECEMBER 2014','ACTIVE','DECEMBER 2014','MTF REGISTERED SWAP EXECUTION FACILITY')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','CRYP','CRYP','O','CRYPTO FACILITIES','CF','LONDON','WWW.CRYPTOFACILITIES.CO.UK','JUNE 2016','ACTIVE','JUNE 2016','DIGITAL ASSETS TRADING PLATFORM.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','CSEU','CSEU','O','CREDIT SUISSE (EUROPE)','','LONDON','WWW.CREDIT-SUISSE.COM','SEPTEMBER 2012','ACTIVE','SEPTEMBER 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','CSCF','CSEU','S','CREDIT SUISSE AES CROSSFINDER EUROPE','','LONDON','WWW.CREDIT-SUISSE.COM','AUGUST 2012','ACTIVE','AUGUST 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','CSBX','CSEU','S','CREDIT SUISSE AES EUROPE BENCHMARK CROSS','','LONDON','WWW.CREDIT-SUISSE.COM','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','DBIX','DBIX','O','DEUTSCHE BANK INTERNALISATION','DB INTERNALISATION','LONDON','HTTPS://AUTOBAHN.DB.COM/MICROSITE/HTML/EQUITY.HTML','OCTOBER 2014','ACTIVE','OCTOBER 2014','DEUTSCHE BANK AG OPERATING MARKET CODES AS PER MMT2 STANDARD DEFINITION PROPOSED BY FIXPROTOCOL.ORG AND SUPPORTED BY EUROPEAN TDM''S(HTTP://WWW.BATSTRADING.CO.UK/BXTR/)')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','DBDC','DBIX','S','DEUTSCHE BANK - DIRECT CAPITAL ACCESS','DCA','LONDON','HTTPS://AUTOBAHN.DB.COM/MICROSITE/HTML/EQUITY.HTML','OCTOBER 2014','ACTIVE','OCTOBER 2014','DEUTSCHE BANK AG MARKET SEGMENT MARKET CODE FOR DCA AS PER MMT2 STANDARD DEFINITION PROPOSED BY FIXPROTOCOL.ORG AND SUPPORTED BY EUROPEAN TDM''S(HTTP://WWW.BATSTRADING.CO.UK/BXTR/)')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','DBCX','DBIX','S','DEUTSCHE BANK - CLOSE CROSS','CLX','LONDON','HTTPS://AUTOBAHN.DB.COM/MICROSITE/HTML/EQUITY.HTML','OCTOBER 2014','ACTIVE','OCTOBER 2014','DEUTSCHE BANK AG MARKET SEGMENT MARKET CODE FOR CLOSE CROSS AS PER MMT2 STANDARD DEFINITION PROPOSED BY FIXPROTOCOL.ORG AND SUPPORTED BY EUROPEAN TDM''S(HTTP://WWW.BATSTRADING.CO.UK/BXTR/)')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','DBCR','DBIX','S','DEUTSCHE BANK - CENTRAL RISK BOOK','CENTRAL RISK BOOK','LONDON','HTTPS://AUTOBAHN.DB.COM/MICROSITE/HTML/EQUITY.HTML','OCTOBER 2014','ACTIVE','OCTOBER 2014','DEUTSCHE BANK AG MARKET SEGMENT MARKET CODE FOR THE CENTRAL RISK BOOK AS PER MMT2 STANDARD DEFINITION PROPOSED BY FIXPROTOCOL.ORG AND SUPPORTED BY EUROPEAN TDM''S(HTTP://WWW.BATSTRADING.CO.UK/BXTR/)')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','DBMO','DBIX','S','DEUTSCHE BANK - MANUAL OTC','MANUAL OTC','LONDON','HTTPS://AUTOBAHN.DB.COM/MICROSITE/HTML/EQUITY.HTML','OCTOBER 2014','ACTIVE','OCTOBER 2014','DEUTSCHE BANK AG MARKET SEGMENT MARKET CODE FOR MANUAL OTC FILLS AS PER MMT2 STANDARD DEFINITION PROPOSED BY FIXPROTOCOL.ORG AND SUPPORTED BY EUROPEAN TDM''S(HTTP://WWW.BATSTRADING.CO.UK/BXTR/)')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','DBSE','DBIX','S','DEUTSCHE BANK - SUPERX EU','SUPERX EU','LONDON','HTTPS://AUTOBAHN.DB.COM/MICROSITE/HTML/EQUITY.HTML','OCTOBER 2014','ACTIVE','OCTOBER 2014','DEUTSCHE BANK AG MARKET SEGMENT MARKET CODE FOR SUPERX EU AS PER MMT2 STANDARD DEFINITION PROPOSED BY FIXPROTOCOL.ORG AND SUPPORTED BY EUROPEAN TDM''S(HTTP://WWW.BATSTRADING.CO.UK/BXTR/)')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','EMBX','EMBX','O','EMERGING MARKETS BOND EXCHANGE LIMITED','EMBX','LONDON','WWW.EMBONDS.COM','OCTOBER 2016','ACTIVE','OCTOBER 2016','ELECTRONIC TRADING PLATFORM FOR EMERGING MARKET FIXED INCOME BOND.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','ENCL','ENCL','O','ENCLEAR','ENC','LONDON','WWW.LCHCLEARNET.COM','OCTOBER 2013','ACTIVE','OCTOBER 2013','LCH.CLEARNET ENCLEAR PROVIDES AN OTC CLEARING SERVICE FOR VARIOUS COMMODITY PRODUCTS INCLUDING FREIGHT, CONTAINERS, EMISSIONS, IRON ORE, FERTILISER &amp; COAL.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','EQLD','EQLD','O','EQUILEND EUROPE LIMITED','','LONDON','WWW.EQUILEND.COM','AUGUST 2013','ACTIVE','AUGUST 2013','MULTILATERAL TRADING FACILITY')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','EXEU','EXEU','O','EXANE BNP PARIBAS','EXEU','LONDON','WWW.EXANE.COM','JULY 2015','ACTIVE','JULY 2015','OPERATING MIC COVERING THE CROSSING MECHANISMS OPERATED BY EXANE BNP PARIBAS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','EXMP','EXEU','S','EXANE BNP PARIBAS - MID POINT','EXANE BNP PARIBAS','LONDON','WWW.EXANE.COM','JULY 2015','ACTIVE','JULY 2015','EUROPEAN MID-POINT CROSSING NETWORK OPERATED BY EXANE BNP PARIBAS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','EXOR','EXEU','S','EXANE BNP PARIBAS - CHILD ORDER CROSSING','','LONDON','WWW.EXANE.COM','AUGUST 2015','ACTIVE','JULY 2015','SMART ORDER ROUTING CROSSING MECHANISM OPERATED BY EXANE BNP PARIBAS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','EXVP','EXEU','S','EXANE BNP PARIBAS - VOLUME PROFILE CROSSING','','LONDON','WWW.EXANE.COM','JULY 2015','ACTIVE','JULY 2015','CROSSING MECHANISM OPERATED BY EXANE BNP PARIBAS WHERE A BUY AND A SELL ORDER HAVE OPPOSITE VOLUME PROFILES FOR AN INTERVAL OF TIME.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','EXBO','EXEU','S','EXANE BNP PARIBAS - BID-OFFER CROSSING','','LONDON','WWW.EXANE.COM','JULY 2015','ACTIVE','JULY 2015','BID-OFFER CROSSING NETWORK TO BE OPERATED BY EXANE BNP PARIBAS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','EXSI','EXEU','S','EXANE BNP PARIBAS - SYSTEMATIC INTERNALISER','','LONDON','WWW.EXANE.COM','JULY 2015','ACTIVE','JULY 2015','EXSI IS THE IDENTIFIER TO BE USED FOR CLIENT EXECUTIONS EXECUTED UNDER THE SYSTEMATIC INTERNALISER REGIME BY EXANE BNP PARIBAS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','EXCP','EXEU','S','EXANE BNP PARIBAS - CLOSING PRICE','','LONDON','WWW.EXANE.COM','JULY 2015','ACTIVE','JULY 2015','EXCP IS THE IDENTIFIER TO BE USED FOR CLIENT EXECUTIONS EXECUTED UNDER EXANE''S CLOSING PRICE MECHANISM.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','EXLP','EXEU','S','EXANE BNP PARIBAS - LIQUIDITY PROVISION','EXLP','LONDON','WWW.EXANE.COM','SEPTEMBER 2016','ACTIVE','SEPTEMBER 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','EXDC','EXEU','S','EXANE BNP PARIBAS - DIRECT CAPITAL ACCESS','EXDC','LONDON','WWW.EXANE.COM','SEPTEMBER 2016','ACTIVE','SEPTEMBER 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','FAIR','FAIR','O','CANTOR SPREADFAIR','','LONDON','WWW.SPREADFAIR.COM','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','GEMX','GEMX','O','GEMMA (GILT EDGED MARKET MAKERS’ASSOCIATION)','GEMMA','LONDON','','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','GFIC','GFIC','O','GFI CREDITMATCH','','LONDON','WWW.GFIGROUP.COM','APRIL 2014','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','GFIF','GFIC','S','GFI FOREXMATCH','','LONDON','WWW.GFIGROUP.COM','APRIL 2014','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','GFIN','GFIC','S','GFI ENERGYMATCH','','LONDON','WWW.GFIGROUP.COM','APRIL 2014','ACTIVE','APRIL 2009','ADDITIONAL PRODUCTS: DRY FREIGHT DERIVATIVES AND UK GAS TRADING')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','GFIR','GFIC','S','GFI RATESMATCH','','LONDON','WWW.GFIGROUP.COM','APRIL 2014','ACTIVE','SEPTEMBER 2010','ELECTRONIC PLATFORM FOR TRADING INTEREST RATE DERVIATIVES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','GMEG','GMEG','O','GMEX EXCHANGE','GMEX','LONDON','WWW.GMEX-GROUP.COM','MAY 2016','ACTIVE','JUNE 2013','MTF FOR DERIVATIVES AND SECURITIES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XLDX','GMEG','S','LONDON DERIVATIVES EXCHANGE','LDX','LONDON','WWW.GMEX-GROUP.COM','JUNE 2013','ACTIVE','JUNE 2013','MTF FOR DERIVATIVES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XGDX','GMEG','S','GLOBAL DERIVATIVES EXCHANGE','GDX','LONDON','WWW.GMEX-GROUP.COM','JUNE 2013','ACTIVE','JUNE 2013','EXCHANGE FOR DERIVATIVES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XGSX','GMEG','S','GLOBAL SECURITIES EXCHANGE','GSX','LONDON','WWW.GMEX-GROUP.COM','JUNE 2013','ACTIVE','JUNE 2013','EXCHANGE FOR SECURITIES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XGCX','GMEG','S','GLOBAL COMMODITIES EXCHANGE','GCX','LONDON','WWW.GMEX-GROUP.COM','JUNE 2013','ACTIVE','JUNE 2013','EXCHANGE FOR CASH SETTLED COMMODITIES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','GRIF','GRIF','O','GRIFFIN MARKETS LIMITED','','LONDON','WWW.GRIFFINMARKETS.COM','OCTOBER 2012','ACTIVE','OCTOBER 2012','TRADING VENUE FOR EUROPEAN ENERGY MARKETS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','GRIO','GRIF','S','GRIFFIN MARKETS LIMITED - OTF','','LONDON','WWW.GRIFFINMARKETS.COM','FEBRUARY 2017','ACTIVE','FEBRUARY 2017','GRIFFIN ORGANISED TRADING FACILITY.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','GRSE','GRSE','O','THE GREEN STOCK EXCHANGE - ACB IMPACT MARKETS','GSE','LONDON','WWW.ACBIMPACTMARKETS.COM','JULY 2014','ACTIVE','JULY 2014','MARKETPLACE FOR SUSTAINABLE SECURITIES (SECURITIES, BONDS, COMMODITIES)')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','GSIL','GSIL','O','GOLDMAN SACHS INTERNATIONAL','GSI','LONDON','WWW.GOLDMANSACHS.COM/GSET','OCTOBER 2016','ACTIVE','OCTOBER 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','GSSI','GSIL','S','GOLDMAN SACHS INTERNATIONAL - SYSTEMATIC INTERNALISER','','LONDON','WWW.GOLDMANSACHS.COM/GSET','OCTOBER 2016','ACTIVE','OCTOBER 2016','GSI SYSTEMATIC INTERNALISER')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','GSBX','GSIL','S','GOLDMAN SACHS INTERNATIONAL - SIGMA BCN','','LONDON','WWW.GOLDMANSACHS.COM/GSET','OCTOBER 2016','ACTIVE','OCTOBER 2016','GSI BROKER CROSSING NETWORK')


INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','HPCS','HPCS','O','HPC SA','','LONDON','WWW.OTCEXGROUP.COM','APRIL 2017','ACTIVE','APRIL 2017','TRADE NAME: TRAYPORT')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','HSXE','HSXE','O','HSBC-X UNITED KINGDOM','','LONDON','WWW.HSBC.COM','AUGUST 2012','ACTIVE','AUGUST 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','IBAL','IBAL','O','ICE BENCHMARK ADMINISTRATION','IBA','LONDON','WWW.THEICE.COM/IBA','JULY 2015','ACTIVE','JULY 2015','INDEPENDENT SUBSIDIARY OF THE ICE, RESPONSIBLE FOR THE END-TO-END ADMINISTRATION OF BENCHMARKS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','ICAP','ICAP','O','ICAP EUROPE','','LONDON','WWW.I-SWAP.COM','JUNE 2007','ACTIVE','JUNE 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','ICAH','ICAP','S','TRAYPORT','','LONDON','WWW.ICAP.COM','DECEMBER 2013','ACTIVE','JUNE 2007','ICAP ELECTRONIC BROKING LIMITED')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','ICEN','ICAP','S','ICAP ENERGY','','LONDON','WWW.ICAPENERGY.COM','JUNE 2007','ACTIVE','JUNE 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','ICSE','ICAP','S','ICAP SECURITIES','','LONDON','WWW.ICAP.COM','JUNE 2007','ACTIVE','JUNE 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','ICTQ','ICAP','S','ICAP TRUEQUOTE','','LONDON','WWW.ICAPENERGY.COM/EU','MARCH 2010','ACTIVE','MARCH 2010','ELECTONIC TRADING PLATFORM FOR OTC OIL SWAPS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','WCLK','ICAP','S','ICAP WCLK','','LONDON','WWW.ICAP.COM','JUNE 2007','ACTIVE','JUNE 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','ISDX','ICAP','S','ICAP SECURITIES &amp; DERIVATIVES EXCHANGE LIMITED','','LONDON','WWW.ISDX.COM','NOVEMBER 2012','ACTIVE','NOVEMBER 2012','THE MARKET OPERATOR PLUS STOCK EXCHANGE PLC CHANGED ITS NAME TO ICAP SECURITIES &amp; DERIVATIVES EXCHANGE LIMITED, ISDX WITH EFFECT FROM 31 OCTOBER 2012.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','IGDL','ICAP','S','ICAP GLOBAL DERIVATIVES LIMITED','IGDL','LONDON','WWW.ICAP.COM/WHAT-WE-DO/GLOBAL-BROKING/SEF.ASPX','NOVEMBER 2016','ACTIVE','NOVEMBER 2016','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','IFEU','IFEU','O','ICE FUTURES EUROPE','','LONDON','WWW.THEICE.COM','DECEMBER 2013','ACTIVE','OCTOBER 2011','ELECTRONIC PLATFORM TO TRADE FUTURES AND OPTIONS PRODUCTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','CXRT','IFEU','S','CREDITEX BROKERAGE LLP - MTF','','LONDON','WWW.CREDITEX.COM','MARCH 2017','ACTIVE','SEPTEMBER 2007','ELECTRONIC MARKET FOR CREDIT PRODUCTS. CXRT HAS BEEN DEACTIVATED FROM MAY 2014 TO 26 JANUARY 2015(IMPLEMENTATION DATE).')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','IFLO','IFEU','S','ICE FUTURES EUROPE - EQUITY PRODUCTS DIVISION','','LONDON','WWW.THEICE.COM','DECEMBER 2013','ACTIVE','DECEMBER 2013','ELECTRONIC PLATFORM TO TRADE FUTURES AND OPTIONS PRODUCTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','IFLL','IFEU','S','ICE FUTURES EUROPE - FINANCIAL PRODUCTS DIVISION','','LONDON','WWW.THEICE.COM','DECEMBER 2013','ACTIVE','DECEMBER 2013','ELECTRONIC PLATFORM TO TRADE FUTURES AND OPTIONS PRODUCTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','IFUT','IFEU','S','ICE FUTURES EUROPE - EUROPEAN UTILITIES DIVISION','','LONDON','WWW.THEICE.COM','DECEMBER 2013','ACTIVE','DECEMBER 2013','ELECTRONIC PLATFORM TO TRADE FUTURES AND OPTIONS PRODUCTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','IFLX','IFEU','S','ICE FUTURES EUROPE - AGRICULTURAL PRODUCTS DIVISION','','LONDON','WWW.THEICE.COM','DECEMBER 2013','ACTIVE','DECEMBER 2013','ELECTRONIC PLATFORM TO TRADE FUTURES AND OPTIONS PRODUCTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','IFEN','IFEU','S','ICE FUTURES EUROPE - OIL AND REFINED PRODUCTS DIVISION','','LONDON','WWW.THEICE.COM','DECEMBER 2013','ACTIVE','DECEMBER 2013','ELECTRONIC PLATFORM TO TRADE FUTURES AND OPTIONS PRODUCTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','CXOT','IFEU','S','CREDITEX BROKERAGE LLP - OTF','','LONDON','WWW.THEICE.COM/SERVICE/CREDITEX','APRIL 2017','ACTIVE','MARCH 2017','ELECTRONIC MARKET FOR FIXED INCOME PRODUCTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','ISWA','ISWA','O','I-SWAP','','LONDON','WWW.I-SWAP.COM','JANUARY 2012','ACTIVE','JANUARY 2012','AUTHORISED MTF FOR OF EURO INTEREST RATE SWAPS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','JPSI','JPSI','O','J.P. MORGAN SECURITIES PLC','','LONDON','WWW.JPMORGAN.COM','JANUARY 2017','ACTIVE','JANUARY 2017','SYSTEMATIC INTERNALISER.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','KLEU','KLEU','O','KNIGHT LINK EUROPE','','LONDON','WWW.KNIGHT.COM','APRIL 2009','ACTIVE','APRIL 2009','SYSTEMATIC INTERNALISER')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','LCUR','LCUR','O','CURRENEX LDFX','CX LDFX','LONDON','WWW.CURRENEX.COM','MAY 2016','ACTIVE','MAY 2016','FOREIGN EXCHANGE TRADING PLATFORM/SYSTEM THAT INCLUDES MATCHING ENGINES OPERATING DIFFERENT MARKETS: LDFX IS ITS LONDON MATCHING ENGINE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','LIQU','LIQU','O','LIQUIDNET SYSTEMS','','LONDON','WWW.LIQUIDNET.COM','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','LIQH','LIQU','S','LIQUIDNET H20','LQNT H20','LONDON','WWW.LIQUIDNET.COM','MAY 2011','ACTIVE','MAY 2011','DARK POOL.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','LIQF','LIQU','S','LIQUIDNET EUROPE LIMITED','LIQU','LONDON','WWW.LIQUIDNET.COM','JUNE 2014','ACTIVE','JUNE 2014','MIC FOR FIXED INCOME BOND TRADING REPORTING')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','LMAX','LMAX','O','LMAX','','LONDON','WWW.MTF.LMAX.COM/','DECEMBER 2010','ACTIVE','DECEMBER 2010','FSA REGULATED MTF FOR RETAIL CLIENTS TO TRADE CFDS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','LMAD','LMAX','S','LMAX - DERIVATIVES','','LONDON','WWW.LMAX.COM','AUGUST 2011','ACTIVE','AUGUST 2011','LMAX ALLOWS THE BENEFIT OF DIRECT ACCESS TO FINANCIAL MARKETS AND ALSO FACILITATES MTF WHERE TRADES ARE ENTERED DIRECTLY INTO THE MARKET AS ORDERS AND ALSO ACCESS FIVE LEVELS OF MARKET DEPTH WHERE THE BOOK IS WEIGHTED BETWEEN BUYERS AND SELLERS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','LMAE','LMAX','S','LMAX - EQUITIES','','LONDON','WWW.LMAX.COM','JANUARY 2010','ACTIVE','JANUARY 2010','FSA REGULATED MTF FOR RETAIL CLIENTS TO TRADE CFDS UNDERLYINGS IN MULTIPLE ASSETS CLASSES INCLUDING EQUITIES.
.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','LMAF','LMAX','S','LMAX - FX','','LONDON','WWW.LMAX.COM','JANUARY 2010','ACTIVE','JANUARY 2010','FSA REGULATED MTF FOR RETAIL CLIENTS TO TRADE CFDS UNDERLYINGS IN MULTIPLE ASSETS CLASSES INCLUDING FX.
.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','LMAO','LMAX','S','LMAX - INDICES/RATES/COMMODITIES','','LONDON','WWW.LMAX.COM','JANUARY 2010','ACTIVE','JANUARY 2010','FSA REGULATED MTF FOR RETAIL CLIENTS TO TRADE CFDS UNDERLYINGS IN MULTIPLE ASSETS CLASSES INCLUDING INDICES/RATES/COMMODITIES.
.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','LMEC','LMEC','O','LME CLEAR','LMEC','LONDON','WWW.LME.COM','FEBRUARY 2014','ACTIVE','FEBRUARY 2014','LONDON METAL EXCHANGE CLEARING PLATFORM')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','LOTC','LOTC','O','OTC MARKET','','LONDON','WWW.LOTCE.COM','AUGUST 2013','ACTIVE','AUGUST 2013','SERVICE COMPANY PROVIDING TRADEABLE OTC DERIVATIVE PRODUCTS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','PLDX','LOTC','S','PLUS DERIVATIVES EXCHANGE','PLUS-DX','LONDON','WWW.PLUS-DX.COM','AUGUST 2013','ACTIVE','MARCH 2012','SERVICE COMPANY PROVIDING EXECUTION SERVICES FOR OTC DERIVATIVES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','LPPM','LPPM','O','LONDON PLATINUM AND PALLADIUM MARKET','LPPM','LONDON','WWW.LPPM.ORG.UK','APRIL 2007','ACTIVE','APRIL 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MAEL','MAEL','O','MARKETAXESS EUROPE LIMITED','','LONDON','WWW.MARKETAXESS.COM','JULY 2007','ACTIVE','JULY 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MCUR','MCUR','O','CURRENEX MTF','','LONDON','WWW.CURRENEX.COM','MAY 2017','ACTIVE','MAY 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MCXS','MCUR','S','CURRENEX MTF - STREAMING','','LONDON','WWW.CURRENEX.COM','MAY 2017','ACTIVE','MAY 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MCXR','MCUR','S','CURRENEX MTF - RFQ','','LONDON','WWW.CURRENEX.COM','MAY 2017','ACTIVE','MAY 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MFGL','MFGL','O','MF GLOBAL ENERGY MTF','','LONDON','WWW.MFGLOBAL.COM','NOVEMBER 2007','ACTIVE','NOVEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MFXC','MFXC','O','FX CONNECT - MTF','','LONDON','WWW.FXCONNECT.COM','MAY 2017','ACTIVE','MAY 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MFXA','MFXC','S','FX CONNECT - MTF - ALLOCATIONS','','LONDON','WWW.FXCONNECT.COM','MAY 2017','ACTIVE','MAY 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MFXR','MFXC','S','FX CONNECT - MTF - RFQ','','LONDON','WWW.FXCONNECT.COM','MAY 2017','ACTIVE','MAY 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MLXN','MLXN','O','BANK OF AMERICA - MERRILL LYNCH INSTINCT X - EUROPE','','LONDON','HTTP://CORP.BANKOFAMERICA.COM/BUSINESS/CI/TRADER-INSTINCT','MAY 2015','ACTIVE','MAY 2015','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MLAX','MLXN','S','BANK OF AMERICA - MERRILL LYNCH AUCTION CROSS','','LONDON','HTTP://CORP.BANKOFAMERICA.COM/BUSINESS/CI/TRADER-INSTINCT','MAY 2015','ACTIVE','MAY 2015','INSTINCT-X AUCTION CROSS FACILITY')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MLEU','MLXN','S','BANK OF AMERICA - MERRILL LYNCH OTC - EUROPE','','LONDON','HTTP://CORP.BANKOFAMERICA.COM/BUSINESS/CI/TRADER-INSTINCT','MAY 2015','ACTIVE','MAY 2015','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MLVE','MLXN','S','BANK OF AMERICA - MERRILL LYNCH VWAP CROSS - EUROPE','','LONDON','HTTP://CORP.BANKOFAMERICA.COM/BUSINESS/CI/TRADER-INSTINCT','JULY 2015','ACTIVE','MAY 2015','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MSIP','MSIP','O','MORGAN STANLEY AND CO. INTERNATIONAL PLC','','LONDON','WWW.MORGANSTANLEY.COM','MAY 2015','ACTIVE','MAY 2015','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MSSI','MSIP','S','MORGAN STANLEY AND CO. INTERNATIONAL PLC - SYSTEMATIC INTERNALISER','','LONDON','WWW.MORGANSTANLEY.COM','MAY 2017','ACTIVE','MAY 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MYTR','MYTR','O','MYTREASURY','','LONDON','WWW.MYTREASURY.COM','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','N2EX','N2EX','O','N2EX','','LONDON','WWW.N2EX.COM','NOVEMBER 2009','ACTIVE','NOVEMBER 2009','N2EX, THE UK MARKET OPERATED BY NASDAQ OMX COMMODITIES AND NORD POOL SPOT, IS A MARKETPLACE FOR PHYSICAL UK POWER CONTRACTS AND LAUNCH A PLATFORM FOR FINANCIAL FUTURES CONTRACTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','NDCM','NDCM','O','ICE ENDEX GAS SPOT LTD','OCM','LONDON','WWW.THEICE.COM/ENDEX','AUGUST 2015','ACTIVE','DECEMBER 2014','ELECTRONIC PLATFORM FOR DERIVATIVES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','NEXS','NEXS','O','NEX SEF','NSL','LONDON','WWW.NEX.COM','MARCH 2017','ACTIVE','NOVEMBER 2016','SWAP EXECUTION FACILITY')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','NOFF','NOFF','O','NOMURA OTC TRADES','','LONDON','WWW.NOMURA.COM','APRIL 2012','ACTIVE','APRIL 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','NOSI','NOSI','O','NOMURA SYSTEMATIC INTERNALISER','','LONDON','WWW.NOMURA.COM','APRIL 2017','ACTIVE','APRIL 2017','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','NURO','NURO','O','NASDAQ OMX EUROPE','','LONDON','WWW.NASDAQOMXEUROPE.COM','SEPTEMBER 2008','ACTIVE','SEPTEMBER 2008','MULTILATERAL TRADING FACILITY - NASDAQOMX  EUROPE - NEW MIC')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XNLX','NURO','S','NASDAQ OMX NLX','NLX','LONDON','WWW.NLX.CO.UK','NOVEMBER 2012','ACTIVE','NOVEMBER 2012','MULTILATERAL TRADING FACILITY FOR LISTED DERIVATIVES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','NURD','NURO','S','NASDAQ EUROPE (NURO) DARK','NURODARK','LONDON','WWW.NASDAQOMXEUROPE.COM','MAY 2011','ACTIVE','MAY 2011','DARK POOL.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','NXEU','NXEU','O','NX','','LONDON','WWW.NOMURA.COM','JUNE 2009','ACTIVE','JUNE 2009','NX IS THE INTERNAL EQUITIES ONLY CROSSING PLATFORM FOR NOMURA.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','OTCE','OTCE','O','OTCEX','','LONDON','WWW.OTCEXGROUP.COM','APRIL 2016','ACTIVE','APRIL 2016','TRADE NAME: TRAYPORT.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','PEEL','PEEL','O','PEEL HUNT LLP UK','','LONDON','WWW.PEELHUNT.COM','FEBRUARY 2014','ACTIVE','FEBRUARY 2014','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XRSP','PEEL','S','PEEL HUNT RETAIL','','LONDON','WWW.PEELHUNT.COM','FEBRUARY 2014','ACTIVE','FEBRUARY 2014','ELECTRONIC TRADING PLATFORM FOR EQUITIES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XPHX','PEEL','S','PEEL HUNT CROSSING','','LONDON','WWW.PEELHUNT.COM','FEBRUARY 2014','ACTIVE','FEBRUARY 2014','ELECTRONIC CROSSING PLATFORM FOR EQUITIES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','PIEU','PIEU','O','ARITAS FINANCIAL LTD','','LONDON','WWW.PIPELINETRADING.COM','FEBRUARY 2012','ACTIVE','FEBRUARY 2012','MTF FOR LARGE BLOCK PAN-EUROPEAN EQUITIES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','PIRM','PIRM','O','PIRUM','','LONDON','WWW.PIRUM.COM','JULY 2011','ACTIVE','JULY 2011','SECURITIES LENDING CCP FLOW PROVIDER.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','QWIX','QWIX','O','Q-WIXX PLATFORM','','LONDON','WWW.QWIXX.COM','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','RBCE','RBCE','O','RBC EUROPE LIMITED','','LONDON','WWW.RBC.COM','JUNE 2013','ACTIVE','JUNE 2013','EQUITIES BROKER FILL')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','RBSX','RBSX','O','RBS CROSS','','LONDON','WWW.RBS.COM','MAY 2011','ACTIVE','MAY 2011','RBS CROSS IS THE BROKER CROSSING SYSTEM (BCS) OPERATED BY RBS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','RTSL','RTSL','O','REUTERS TRANSACTION SERVICES LIMITED','RTSL','LONDON','WWW.REUTERS.COM','AUGUST 2007','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TRFW','RTSL','S','REUTERS TRANSACTION SERVICES LIMITED - FORWARDS MATCHING','','LONDON','WWW.REUTERS.COM','APRIL 2017','ACTIVE','APRIL 2017','REGISTERED MARKET FOR OTC FX DERIVATIVES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TRAL','RTSL','S','REUTERS TRANSACTION SERVICES LIMITED - FXALL RFQ','','LONDON','WWW.REUTERS.COM','APRIL 2017','ACTIVE','APRIL 2017','TRADING REQUEST FOR QUOTE PLATFORM FOR FX OTC DERIVATIVES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','SECF','SECF','O','SECFINEX','','LONDON','WWW.SECFINEX.COM','JANUARY 2009','ACTIVE','JANUARY 2009','MULTILATERAL TRADING FACILITY - ELECTRONIC EXCHANGE FOR STOCK BORROWING AND LENDING TRANSACTIONS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','SGMX','SGMX','O','SIGMA X MTF','','LONDON','HTTP://GSET.GS.COM/SIGMAXMTF/','FEBRUARY 2010','ACTIVE','FEBRUARY 2010','ELECTRONIC TRADING PLATFORM FOR EUROPEAN EQUITIES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','SHAR','SHAR','O','ASSET MATCH','','AYLESBURY','WWW.SHAREMARK.COM','DECEMBER 2012','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','SPEC','SPEC','O','MAREX SPECTRON INTERNATIONAL LIMITED OTF','MSIL OTF','LONDON','WWW.MAREXSPECTRON.COM','MAY 2017','MODIFIED','SEPTEMBER 2007','ORGANISED TRADE FACILITY FOR OTC DERIVATIVES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','SPRZ','SPRZ','O','SPREADZERO','','LONDON','WWW.SPREADZERO.COM','SEPTEMBER 2009','ACTIVE','SEPTEMBER 2009','ELECTRONIC CROSSING PLATFORM')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','SSEX','SSEX','O','SOCIAL STOCK EXCHANGE','SSE','LONDON','WWW.SOCIALSTOCKEXCHANGE.COM','JULY 2013','ACTIVE','JULY 2013','THE SSE GIVES INVESTORS ACCESS TO INFORMATION ON PUBLICLY LISTED BUSINESSES WITH STRONG SOCIAL AND ENVIRONMENTAL PURPOSE.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','SWAP','SWAP','O','SWAPSTREAM','','LONDON','WWW.SWAPSTREAM.COM','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TFSV','TFSV','O','VOLBROKER','','LONDON','WWW.TFSICAP.COM','AUGUST 2007','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','FXOP','TFSV','S','TRADITION-NEX OTF','','LONDON','WWW.TRADITION.COM','APRIL 2017','ACTIVE','APRIL 2017','FX OPTIONS TRADING FACILITY.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TPIE','TPIE','O','THE PROPERTY INVESTMENT EXCHANGE','PROPEX','LONDON','WWW.PROPEX.CO.UK','MARCH 2013','ACTIVE','OCTOBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TRAX','TRAX','O','TRAX APA','','LONDON','WWW.TRAXMARKETS.COM','MAY 2017','ACTIVE','MAY 2017','APPROVED PUBLICATION ARRANGEMENT.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TRDE','TRDE','O','TRADITION ELECTRONIC TRADING PLATFORM','','LONDON','WWW.TRADITION.COM','FEBRUARY 2017','ACTIVE','OCTOBER 2010','ELECTRONIC TRADING PLATFORM FOR SECURITIES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','NAVE','TRDE','S','NAVESIS-MTF','','LONDON','WWW.TRADITION.COM','APRIL 2017','ACTIVE','MARCH 2012','TRADE NAME: NAVESIS ETF.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TCDS','TRDE','S','TRADITION CDS','','LONDON','WWW.TRADITION.CO.UK','AUGUST 2007','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TRDX','TRDE','S','TRAD-X','TRAD-X','LONDON','WWW.TRADITION.COM','MARCH 2012','ACTIVE','MARCH 2012','TRADITION''S HYBRID TRADING PLATFORM FOR OTC DERIVATIVES AND OTHER FINANCIAL INSTRUMENTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','VOLA','TRDE','S','TRADITION - VOLATIS','','LONDON','WWW.TRADITION.COM','JUNE 2012','ACTIVE','JUNE 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TFSG','TRDE','S','TRADITION ENERGY','','LONDON','WWW.TFSGREEN.COM','JANUARY 2014','ACTIVE','MARCH 2012','TRADE NAME: TRAYPORT')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','PARX','TRDE','S','PARFX','','LONDON','WWW.PARFX.COM','SEPTEMBER 2013','ACTIVE','SEPTEMBER 2013','ELECTRONIC TRADING PLATFORM FOR SPOT FX')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','ELIX','TRDE','S','ELIXIUM','','LONDON','WWW.TRADITION.COM','APRIL 2016','ACTIVE','APRIL 2016','PLATFORM FOR SECURITIES FINANCING TRANSACTIONS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','EMCH','TRDE','S','FINACOR EMATCH','','LONDON','WWW.TRADITION.COM','NOVEMBER 2016','ACTIVE','NOVEMBER 2016','PLATFORM FOR EMERGING MARKETS SECURITIES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TREU','TREU','O','TRADEWEB EUROPE LIMITED','','LONDON','WWW.TRADEWEB.COM','NOVEMBER 2014','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TREA','TREU','S','TRADEWEB EUROPE LIMITED - APA','','LONDON','WWW.TRADEWEB.COM','APRIL 2017','ACTIVE','APRIL 2017','APPROVED PUBLICATION ARRANGEMENT SEGMENT')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TREO','TREU','S','TRADEWEB EUROPE LIMITED - OTF','','LONDON','WWW.TRADEWEB.COM','APRIL 2017','ACTIVE','APRIL 2017','ORGANISED TRADING FACILITY')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TRQX','TRQX','O','TURQUOISE','','LONDON','WWW.TRADETURQUOISE.COM','SEPTEMBER 2007','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TRQM','TRQX','S','TURQUOISE DARK','TQDARK','LONDON','WWW.TRADETURQUOISE.COM','MAY 2011','ACTIVE','MAY 2011','DARK POOL.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','UBSL','UBSL','O','UBS EMEA EQUITIES TRADING','','LONDON','WWW.UBS.COM','DECEMBER 2015','ACTIVE','DECEMBER 2015','UBS TRADING PLATFORMS (EQUITIES EMEA).')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','UBSE','UBSL','S','UBS PIN (EMEA)','','LONDON','WWW.UBS.COM','DECEMBER 2015','ACTIVE','DECEMBER 2015','UBS PRICE IMPROVEMENT NETWORK IN EMEA (EQUITIES).')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','UKPX','UKPX','O','APX POWER UK','','LONDON','WWW.APXGROUP.COM','JUNE 2006','ACTIVE','JUNE 2006','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','VEGA','VEGA','O','VEGA-CHI','','LONDON','WWW.VEGA-CHI.COM','SEPTEMBER 2009','ACTIVE','SEPTEMBER 2009','ELECTRONIC TRADING PLATFORM FOR OTC SECURITIES. FSA APPROVAL RECEIVED ON JANUARY 2010.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','WINS','WINS','O','WINTERFLOOD SECURITIES LIMITED','WINS','LONDON','WWW.WINTERFLOOD.COM','OCTOBER 2014','ACTIVE','OCTOBER 2014','REGISTERED MARKET MAKER')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XALT','XALT','O','ALTEX-ATS','','LONDON','WWW.ALTEX-ATS.CO.UK','JUNE 2007','ACTIVE','JUNE 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XCOR','XCOR','O','ICMA','','LONDON','WWW.ICMA-GROUP.ORG','SEPTEMBER 2006','ACTIVE','SEPTEMBER 2006','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XGCL','XGCL','O','GLOBAL COAL LIMITED','GLOBALCOAL','LONDON','WWW.GLOBALCOAL.COM','AUGUST 2013','ACTIVE','AUGUST 2013','MTF PLATFORM FOR OTC DERIVATIVES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XLBM','XLBM','O','LONDON BULLION MARKET','','LONDON','WWW.LBMA.ORG.UK','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XLCH','XLCH','O','LCH.CLEARNET LTD','','LONDON','WWW.LCHCLEARNET.COM','DECEMBER 2013','ACTIVE','DECEMBER 2013','LCH.CLEARNET GROUP IS A LEADING MULTI-ASSET CLASS AND MULTI-NATIONAL CLEARING HOUSE, SERVING MAJOR EXCHANGES AND PLATFORMS AS WELL AS A RANGE OF OTC MARKETS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XLDN','XLDN','O','EURONEXT - EURONEXT LONDON','','LONDON','WWW.EURONEXT.COM','MAY 2015','ACTIVE','MARCH 2010','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XLME','XLME','O','LONDON METAL EXCHANGE','LME','LONDON','WWW.LME.CO.UK','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XLON','XLON','O','LONDON STOCK EXCHANGE','LSE','LONDON','WWW.LONDONSTOCKEXCHANGE.COM','NOVEMBER 2015','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XLOD','XLON','S','LONDON STOCK EXCHANGE - DERIVATIVES MARKET','LSE','LONDON','WWW.LONDONSTOCKEXCHANGE.COM','NOVEMBER 2015','ACTIVE','JULY 2013','LONDON STOCK EXCHANGE DERIVATIVES MARKET (PART OF LONDON STOCK EXCHANGE REGULATED MARKET)')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XMTS','XMTS','O','EUROMTS LTD','','LONDON','WWW.MTSMARKETS.COM','APRIL 2017','ACTIVE','MARCH 2013','LEGAL ENTITY OPERATING ALL RELATED MARKET SEGMENT MICS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','HUNG','XMTS','S','MTS HUNGARY','','LONDON','','DECEMBER 2014','ACTIVE','SEPTEMBER 2011','MTS HUNGARY IS A DIVISION OF EUROMTS AND TRADES GOVIES BONDS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','UKGD','XMTS','S','UK GILTS MARKET','','LONDON','','APRIL 2017','ACTIVE','JULY 2011','THE MTS UK GOVERNMENT BOND MARKET OPERATES AS AN MTF AND WILL BE OPEN EXCLUSIVELY TO THE COMMUNITY OF GEMMS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','AMTS','XMTS','S','MTS NETHERLANDS','','LONDON','WWW.MTSMARKETS.COM','FEBRUARY 2011','ACTIVE','FEBRUARY 2011','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','EMTS','XMTS','S','EUROMTS','EMTS','LONDON','WWW.EUROMTS-LTD.COM','JUNE 2005','ACTIVE','JUNE 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','GMTS','XMTS','S','MTS GERMANY','','LONDON','WWW.MTSGERMANY.COM','FEBRUARY 2011','ACTIVE','FEBRUARY 2011','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','IMTS','XMTS','S','MTS IRELAND','','LONDON','WWW.MTSIRELAND.COM','NOVEMBER 2005','ACTIVE','NOVEMBER 2005','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MCZK','XMTS','S','MTS CZECH REPUBLIC','','LONDON','','MAY 2011','ACTIVE','MAY 2011','MTS CZECH REPUBLIC IS A DOMESTIC MARKET WHERE IT WILL BE POSSIBLE TO TRADE GOVIES BONDS IN LOCAL CURRENCY.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MTSA','XMTS','S','MTS AUSTRIA','','LONDON','WWW.MTSAUSTRIA.COM','FEBRUARY 2011','ACTIVE','FEBRUARY 2011','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MTSG','XMTS','S','MTS GREECE','','LONDON','WWW.MTSGREECE.COM','FEBRUARY 2011','ACTIVE','FEBRUARY 2011','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MTSS','XMTS','S','MTS INTERDEALER SWAPS MARKET','','LONDON','','APRIL 2015','ACTIVE','OCTOBER 2007','B2B SEGMENT')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','RMTS','XMTS','S','MTS ISRAEL','','LONDON','WWW.MTSISRAEL.COM','AUGUST 2007','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','SMTS','XMTS','S','MTS SPAIN','','LONDON','WWW.MTSSPAIN.COM','FEBRUARY 2011','ACTIVE','FEBRUARY 2011','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','VMTS','XMTS','S','MTS SLOVENIA','','LONDON','WWW.MTSSLOVENIA.COM','AUGUST 2007','ACTIVE','AUGUST 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','BVUK','XMTS','S','BONDVISION UK','','LONDON','WWW.MTSMARKETS.COM','JULY 2014','ACTIVE','JULY 2014','ELECTRONIC TRADING PLATFORM FOR GOVIES AND NON GOVIES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','PORT','XMTS','S','MTS PORTUGAL','PTE','LONDON','WWW.MTSMARKETS.COM','JULY 2014','ACTIVE','JULY 2014','MTSD PORTUGAL IS OPERATING AS A DIVISION OF EUROMTS SINCE 30 JUNE 2014')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','MTSW','XMTS','S','MTS SWAP MARKET','STF','LONDON','WWW.MTSMARKETS.COM','JULY 2014','ACTIVE','JULY 2014','B2C SEGMENT OF EUROMTS LTD')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XSGA','XSGA','O','ALPHA Y','','LONDON','WWW.EXECUTION.SOCGEN.COM','SEPTEMBER 2012','ACTIVE','SEPTEMBER 2012','EUROPEAN ELECTRONIC CROSSING PLATFORM FOR CASH EQUITIES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XSMP','XSMP','O','SMARTPOOL','','LONDON','WWW.EURONEXT.COM/SMARTPOOL','MAY 2015','ACTIVE','SEPTEMBER 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XSWB','XSWB','O','SWX SWISS BLOCK','','LONDON','WWW.SWXEUROPE.COM','SEPTEMBER 2008','ACTIVE','SEPTEMBER 2008','TRADING VENUE FOR SWISS BLUE-CHIP EQUITIES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XTUP','XTUP','O','TULLETT PREBON PLC','','LONDON','WWW.TULLETTPREBON.COM','AUGUST 2012','ACTIVE','AUGUST 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TPEQ','XTUP','S','TULLETT PREBON PLC - TP EQUITYTRADE','','LONDON','WWW.TULLETTPREBON.COM','NOVEMBER 2012','ACTIVE','NOVEMBER 2012','MULTILATERAL TRADING PLATFORM FOR EQUITY DERIVATIVES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TBEN','XTUP','S','TULLETT PREBON PLC - TP ENERGY','','LONDON','WWW.TULLETTPREBON.COM','MARCH 2016','ACTIVE','SEPTEMBER 2007','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TBLA','XTUP','S','TULLETT PREBON PLC - TP TRADEBLADE','','LONDON','WWW.TULLETTPREBON.COM','JUNE 2008','ACTIVE','JUNE 2008','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TPCD','XTUP','S','TULLETT PREBON PLC - TP CREDITDEAL','','LONDON','WWW.TULLETTPREBON.COM','JUNE 2008','ACTIVE','JUNE 2008','ELECTRONIC TRADING PLATFORM FOR CREDIT PRODUCTS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TPFD','XTUP','S','TULLETT PREBON PLC - TP FORWARDDEAL','','LONDON','WWW.TULLETTPREBON.COM','APRIL 2012','ACTIVE','APRIL 2012','')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TPRE','XTUP','S','TULLETT PREBON PLC - TP REPO','','LONDON','WWW.TULLETTPREBON.COM','JUNE 2008','ACTIVE','JUNE 2008','ELECTRONIC TRADING PLATFORM FOR REPURCHASE AGREEMENTS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TPSD','XTUP','S','TULLETT PREBON PLC - TP SWAPDEAL','','LONDON','WWW.TULLETTPREBON.COM','APRIL 2011','ACTIVE','APRIL 2011','OTC ELECTRONIC TRADING PLATFORM FOR INTEREST RATE DERIVATIVES.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XTPE','XTUP','S','TULLETT PREBON PLC - TP ENERGYTRADE','','LONDON','WWW.TULLETTPREBON.COM','APRIL 2012','ACTIVE','APRIL 2012','OTC ELECTRONIC TRADING PLATFORM FOR ENERGY PRODUCTS.')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TPEL','XTUP','S','TULLETT PREBON PLC – TULLETT PREBON (EUROPE) LIMITED','','LONDON','WWW.TULLETTPREBON.COM','MARCH 2016','ACTIVE','MARCH 2016','MTF FOR THE BROKING OF FOREIGN EXCHANGE, ENERGY, COMMODITY AND INTEREST RATE DERIVATIVES')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','TPSL','XTUP','S','TULLETT PREBON PLC – TULLETT PREBON (SECURITIES) LIMITED','','LONDON','WWW.TULLETTPREBON.COM','MARCH 2016','ACTIVE','MARCH 2016','MTF FOR THE BROKING OF SECURITIES, DERIVATIVES AND REPURCHASE AGREEMENTS')

INSERT INTO generic_mapping_values (mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, clm11_value, clm12_value, clm13_value)
VALUES (@mapping_table_id, 'UNITED KINGDOM','GB','XUBS','XUBS','O','UBS MTF','','LONDON','WWW.UBS.COM/MTF','DECEMBER 2014','ACTIVE','JULY 2010','')
