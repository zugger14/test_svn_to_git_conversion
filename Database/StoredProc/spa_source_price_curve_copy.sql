IF OBJECT_ID(N'spa_source_price_curve_copy', N'P') IS NOT NULL
	DROP PROCEDURE dbo.spa_source_price_curve_copy
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.spa_source_price_curve_copy 
	@flag CHAR(1) = 'c',
	@from_source VARCHAR(20) = NULL,
	@price_curve_from VARCHAR(20) = NULL,
	@as_of_date_from DATETIME = NULL,
	@as_of_date_to DATETIME = NULL,
	@tenor_from DATETIME = NULL,
	@tenor_to DATETIME = NULL,
	@forward_only VARCHAR(20) = NULL,
	@to_source VARCHAR(20) = NULL,
	@price_curve_to VARCHAR(20) = NULL,
	@dest_as_of_date_from DATETIME = NULL,
	@dest_as_of_date_to DATETIME = NULL,
	@shift_price_by VARCHAR(20) = NULL,
	@shift_value VARCHAR(20) = NULL,
	@shift_tenor_by VARCHAR(20) = NULL
AS


/*---------------Debug Area---------------------
DECLARE	@flag CHAR(1) = 'c',
		@from_source VARCHAR(20) = NULL,
		@price_curve_from VARCHAR(20) = NULL,
		@as_of_date_from DATETIME = NULL,
		@as_of_date_to DATETIME = NULL,
		@tenor_from DATETIME = NULL,
		@tenor_to DATETIME = NULL,
		@forward_only VARCHAR(20) = NULL,
		@to_source VARCHAR(20) = NULL,
		@price_curve_to VARCHAR(20) = NULL,
		@dest_as_of_date_from DATETIME = NULL,
		@dest_as_of_date_to DATETIME = NULL,
		@shift_price_by VARCHAR(20) = NULL,
		@shift_value FLOAT = NULL,
		@shift_tenor_by INT = NULL

SELECT @from_source='4500',@price_curve_from='7065',@as_of_date_from='2017-12-01',@as_of_date_to='2017-12-31',@tenor_from='2018-01-01',@tenor_to='2018-01-31',@forward_only='',@to_source='4500',@price_curve_to='7203',@dest_as_of_date_from='2018-06-04',@dest_as_of_date_to='2018-06-04',@shift_price_by='p',@shift_value='10',@shift_tenor_by='',@flag='c'
-----------------------------------------------*/
SET NOCOUNT ON;

IF @flag = 'c'
BEGIN
	DECLARE @granularity INT,
			@exp_calendar_id INT,
			@sql_string VARCHAR(MAX),
			@error_message VARCHAR(2500),
			@uname VARCHAR(100) = dbo.FNADBUser(),
			@lock_dates VARCHAR(MAX),
			@granularity_dest INT

	IF EXISTS (SELECT 1 FROM lock_as_of_date WHERE close_date >= CONVERT(VARCHAR(20), @dest_as_of_date_from, 120) AND close_date <= CONVERT(VARCHAR(20), (@dest_as_of_date_to + 1), 120))
	BEGIN
		SELECT @lock_dates = ISNULL(@lock_dates + ',', '') + CONVERT(VARCHAR(10), dbo.FNAUserDateFormat(close_date, @uname), 120)
		FROM lock_as_of_date
		WHERE close_date >= CONVERT(VARCHAR(20), @dest_as_of_date_from, 120) 
			AND close_date <= CONVERT(VARCHAR(20), (@dest_as_of_date_to + 1), 120)

		SELECT @error_message = 'As of Date <b>(' + @lock_dates + ')</b> has been locked. Please unlock first to proceed.'
		FROM lock_as_of_date
		WHERE close_date >= CONVERT(VARCHAR(20), @dest_as_of_date_from, 120) 
			AND close_date <= CONVERT(VARCHAR(20), (@dest_as_of_date_to + 1), 120)

		EXEC spa_ErrorHandler -1, 'spa_source_price_curve_copy' , 'Copy Price Curve', 'Error', @error_message, ''
		RETURN
	END
	
	IF OBJECT_ID ('tempdb..#source_price_curve') IS NOT NULL
		DROP TABLE #source_price_curve

	SELECT source_curve_def_id,
		   as_of_date,
		   Assessment_curve_type_value_id,
		   curve_source_value_id,
		   maturity_date,
		   curve_value,
		   bid_value,
		   ask_value,
		   is_dst
	INTO #source_price_curve
	FROM source_price_curve
	WHERE 1 = 2

	SELECT @granularity = granularity,
		   @exp_calendar_id = exp_calendar_id 
	FROM source_price_curve_def spcd
	WHERE spcd.source_curve_def_id = @price_curve_from
	
	SELECT @granularity_dest = granularity,
		   @exp_calendar_id = exp_calendar_id 
	FROM source_price_curve_def spcd
	WHERE spcd.source_curve_def_id = @price_curve_to

	IF (@granularity <> @granularity_dest)
	BEGIN
		EXEC spa_ErrorHandler -1, 'spa_source_price_curve_copy' , 'Copy Price Curve', 'Error', 'Please select the price curves of same granularity.', ''
		RETURN
	END

	SET @sql_string = '
		INSERT INTO #source_price_curve
		SELECT ' + @price_curve_to + ',
				''' + CONVERT(VARCHAR(10), @dest_as_of_date_from, 120) + ''',
				assessment_curve_type_value_id,
				' + @to_source + ',
				' + IIF(NULLIF(@shift_tenor_by, '') IS NOT NULL, '[dbo].[FNAShiftDateByGranularity](' + CAST(@granularity AS VARCHAR(10)) + ', ' + CAST(@shift_tenor_by AS VARCHAR(10)) + ', [maturity_date])', '[maturity_date]') + ' maturity_date,
				' + IIF(NULLIF(@shift_value, '') IS NOT NULL, '
				IIF(''' + @shift_price_by + ''' = ''p'', spc.curve_value * (1.0 + ' + CAST(@shift_value AS VARCHAR(10)) + '/100.0), spc.curve_value + ' + CAST(@shift_value AS VARCHAR(10)) + ') curve_value,
				IIF(''' + @shift_price_by + ''' = ''p'', spc.bid_value * (1.0 + ' + CAST(@shift_value AS VARCHAR(10)) + '/100.0), spc.bid_value + ' + CAST(@shift_value AS VARCHAR(10)) + ') bid_value,
				IIF(''' + @shift_price_by + ''' = ''p'', spc.ask_value * (1.0 + ' + CAST(@shift_value AS VARCHAR(10)) + '/100.0), spc.ask_value + ' + CAST(@shift_value AS VARCHAR(10)) + ') ask_value,
				', 'spc.curve_value,
				spc.bid_value,
				spc.ask_value,
				') + '				
				is_dst 
		FROM source_price_curve spc			
	'
	IF @forward_only = 'y' AND @exp_calendar_id IS NOT NULL--If expiration calendar is mapped and Copy Only Forward Price.
	BEGIN
		SET @sql_string += '
			INNER JOIN source_price_curve_def spcd
				ON spcd.source_curve_def_id = spc.source_curve_def_id
			LEFT JOIN holiday_group hg
				ON hg.hol_group_value_id = spcd.exp_calendar_id			
					AND spc.as_of_date = hg.exp_date
					AND spc.maturity_date = hg.hol_date
		'
	END		

	SET @sql_string += '
		WHERE spc.source_curve_def_id = ' + @price_curve_from + '
			AND (spc.as_of_date >= ''' + CONVERT(VARCHAR(20), @as_of_date_from, 120) + ''' AND spc.as_of_date < ''' + CONVERT(VARCHAR(20), (@as_of_date_to + 1), 120) + ''')
			AND (spc.maturity_date >= ''' + CONVERT(VARCHAR(20), @tenor_from, 120) + ''' AND spc.maturity_date < ''' + CONVERT(VARCHAR(20), (@tenor_to + 1), 120) + ''')
			AND spc.curve_source_value_id = ' + @from_source + '
	'

	IF @forward_only = 'y'--Copy Only Forward Price.
	BEGIN
		SET @sql_string += '
			AND spc.as_of_date > spc.maturity_date
		'
	END
	
	EXEC(@sql_string)	

	IF NOT EXISTS (SELECT 1 FROM #source_price_curve)
	BEGIN
		EXEC spa_ErrorHandler -1, 'spa_source_price_curve_copy' , 'Copy Price Curve', 'Error', 'No Prices found to copy.', ''
		RETURN
	END

	BEGIN TRY
		BEGIN TRANSACTION

		DELETE spc 
		FROM source_price_curve spc
		INNER JOIN #source_price_curve t 
			ON spc.source_curve_def_id = t.source_curve_def_id
		WHERE spc.as_of_date = t.as_of_date
			AND spc.maturity_date = t.maturity_date
		
		INSERT INTO source_price_curve (
			source_curve_def_id,
			as_of_date,
			assessment_curve_type_value_id,
			curve_source_value_id,
			maturity_date,
			curve_value,
			bid_value,
			ask_value,
			is_dst
		)
		SELECT source_curve_def_id,
			   as_of_date,
			   Assessment_curve_type_value_id,
			   curve_source_value_id,
			   maturity_date,
			   curve_value,
			   bid_value,
			   ask_value,
			   is_dst
		FROM #source_price_curve
		COMMIT
		
		EXEC spa_ErrorHandler 0, 'spa_source_price_curve_copy' , 'Copy Price Curve', 'Success', 'Price(s) copied successfully.', ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

		SET @error_message = 'Error on Copying Price Curve. Details:' + ERROR_MESSAGE()

		EXEC spa_ErrorHandler -1, 'spa_source_price_curve_copy' , 'Copy Price Curve', 'DB Error', @error_message, ''
	END CATCH
END