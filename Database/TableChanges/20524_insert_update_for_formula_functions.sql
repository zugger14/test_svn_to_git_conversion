 
DECLARE  @type_id_category  INT  = 27400 --Category type ID
	  , @category_volume INT
	  , @category_Deal INT
	  , @category_Logical INT
	  , @category_Operators INT
	  , @category_PNL INT
	  , @category_Others INT
	  , @category_Price INT
	  , @category_Ref INT
	  , @category_date INT 
	  , @type_id_formula_func INT = 800 --Formula function type ID
	  , @AnnualVolCOD_func INT
	  , @CorresMnthValue_func INT
	  , @GeneratorMxHour_func INT  
	  , @MnthlyRollingAveg_func INT

SELECT  @category_volume  = value_id  FROM  static_data_value WHERE code = 'Volume' AND type_id =  @type_id_category
--SELECT  @category_Deal    = value_id  FROM  static_data_value WHERE code = 'Deal' AND type_id =  @type_id_category
--SELECT  @category_Logical = value_id  FROM  static_data_value WHERE code = 'Logical' AND type_id =  @type_id_category
--SELECT  @category_PNL     = value_id  FROM  static_data_value WHERE code = 'PNL' AND type_id =  @type_id_category
--SELECT  @category_Others  = value_id  FROM  static_data_value WHERE code = 'Others' AND type_id =  @type_id_category
--SELECT  @category_Price   = value_id  FROM  static_data_value WHERE code = 'Price' AND type_id =  @type_id_category
--SELECT  @category_Ref     = value_id  FROM  static_data_value WHERE code = 'Reference' AND type_id =  @type_id_category
SELECT  @category_date    = value_id  FROM  static_data_value WHERE code = 'Date Time' AND type_id =  @type_id_category

SELECT @AnnualVolCOD_func      = value_id  FROM  static_data_value WHERE code = 'AnnualVolCOD' AND type_id = @type_id_formula_func
SELECT @CorresMnthValue_func 	 = value_id  FROM  static_data_value WHERE code = 'CorresMnthValue' AND type_id = @type_id_formula_func
SELECT @GeneratorMxHour_func   = value_id  FROM  static_data_value WHERE code = 'GeneratorMxHour' AND type_id = @type_id_formula_func
SELECT @MnthlyRollingAveg_func = value_id  FROM  static_data_value WHERE code = 'MnthlyRollingAveg' AND type_id = @type_id_formula_func

/***************************Category Mapping For Formula*************************************************/
--AnnualVolCOD
IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = @AnnualVolCOD_func AND category_id = @category_volume)
BEGIN
	INSERT INTO map_function_category(category_id, function_id, is_active)
	VALUES (@category_volume, @AnnualVolCOD_func, 1)
	PRINT 'Function Mapped to volume Categrory'
END
 --CorresMnthValue
IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = @CorresMnthValue_func AND category_id = @category_date)
BEGIN
	INSERT INTO map_function_category(category_id, function_id, is_active)
	VALUES (@category_date, @CorresMnthValue_func, 1)
	PRINT 'Function Mapped to Date time Categrory'
END
   --GeneratorMxHour
IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = @GeneratorMxHour_func AND category_id = @category_date)
BEGIN
	INSERT INTO map_function_category(category_id, function_id, is_active)
	VALUES (@category_date, @GeneratorMxHour_func, 1)
	PRINT 'Function Mapped to Date time  Categrory'
END
 --MnthlyRollingAveg
IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = @MnthlyRollingAveg_func AND category_id = @category_date)
BEGIN
	INSERT INTO map_function_category(category_id, function_id, is_active)
	VALUES (@category_date, @MnthlyRollingAveg_func, 1)
	PRINT 'Function Mapped to Date time  Categrory'
END

--Update is_active value for formula functions
UPDATE mfc
  SET
      mfc.is_active = 1
FROM map_function_category mfc
     INNER JOIN static_data_value sdv ON mfc.function_id = sdv.value_id
WHERE sdv.code IN ('IsPeak', 'OffpeakVolume', 'OnPeakvolume');


/***************************END*******************************************************************/

/***************************Formula functions parameters***************************************************/
--AnnualVolCOD
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = @AnnualVolCOD_func AND field_label = 'Row')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (@AnnualVolCOD_func, 'Row', 't', '',  'Row','','','0','0','','1','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = @AnnualVolCOD_func AND field_label = 'Offset')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (@AnnualVolCOD_func, 'Offset', 't', '',  'Offset','','','0','0','','1','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = @AnnualVolCOD_func AND field_label = 'Aggregation')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (@AnnualVolCOD_func, 'Aggregation', 't', '',  'Aggregation','','SELECT 0 [ID], ''Sum'' [Name] UNION ALL SELECT 1, ''Average'' ','0','0','','1','farrms_admin', GETDATE())
END

--CorresMnthValue 
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = @CorresMnthValue_func AND field_label = 'Number of Row')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (@CorresMnthValue_func, 'Number of Row', 't', '',  'Number of Row','','','1','0','','1','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = @CorresMnthValue_func AND field_label = 'Number of Month')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (@CorresMnthValue_func, 'Number of Month', 't', '',  'Number of Month','','','1','0','','2','farrms_admin', GETDATE())
END

--GeneratorMxHour
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = @GeneratorMxHour_func AND field_label = 'Row')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (@GeneratorMxHour_func, 'Row', 't', '',  'Row','','','1','0','','1','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = @GeneratorMxHour_func AND field_label = 'Offset')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (@GeneratorMxHour_func, 'Offset', 't', '',  'Offset','','','0','0','','1','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = @GeneratorMxHour_func AND field_label = 'Aggregation')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (@GeneratorMxHour_func, 'Aggregation', 't', '',  'Aggregation','','SELECT 0 [ID], ''Sum'' [Name] UNION ALL SELECT 1, ''Average'' ','0','0','','1','farrms_admin', GETDATE())
END


--MnthlyRollingAveg
IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = @MnthlyRollingAveg_func AND field_label = 'Number of Row')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (@MnthlyRollingAveg_func, 'Number of Row', 't', '',  'Number of Row','','','1','0','','1','farrms_admin', GETDATE())
END

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE formula_id = @MnthlyRollingAveg_func AND field_label = 'Number of Month')
BEGIN
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (@MnthlyRollingAveg_func, 'Number of Month', 't', '',  'Number of Month','','','1','0','','2','farrms_admin', GETDATE())
END
/*********************************************END*************************************************************/






