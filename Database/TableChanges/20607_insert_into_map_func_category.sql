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
	  , @OnPeakPeriodhour_func INT
	  , @OffPeakPeriodhour_func INT
	  , @TotalPeriodhour_func INT 

SELECT  @category_date = value_id  FROM static_data_value WHERE code = 'Date Time' AND type_id =  @type_id_category

SELECT @OnPeakPeriodhour_func  = value_id  FROM  static_data_value WHERE code = 'OnPeakPeriodHour' AND type_id = @type_id_formula_func
SELECT @OffPeakPeriodhour_func = value_id  FROM  static_data_value WHERE code = 'OffPeakPeriodHour' AND type_id = @type_id_formula_func
SELECT @TotalPeriodhour_func   = value_id  FROM  static_data_value WHERE code = 'TotalPeriodHour' AND type_id = @type_id_formula_func


/***************************Category Mapping For Formula*************************************************/
--OnPeakPeriodHour
IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = @OnPeakPeriodhour_func AND category_id = @category_date)
BEGIN
	INSERT INTO map_function_category(category_id, function_id, is_active)
	VALUES (@category_date, @OnPeakPeriodhour_func, 1)
	PRINT 'Function Mapped to Date time  Categrory'
END

--OffPeakPeriodHour
IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = @OffPeakPeriodhour_func AND category_id = @category_date)
BEGIN
	INSERT INTO map_function_category(category_id, function_id, is_active)
	VALUES (@category_date, @OffPeakPeriodhour_func, 1)
	PRINT 'Function Mapped to Date time  Categrory'
END

--OffPeakPeriodHour
IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = @TotalPeriodhour_func AND category_id = @category_date)
BEGIN
	INSERT INTO map_function_category(category_id, function_id, is_active)
	VALUES (@category_date, @TotalPeriodhour_func, 1)
	PRINT 'Function Mapped to Date time  Categrory'
END

/*********************************************END*************************************************************/


