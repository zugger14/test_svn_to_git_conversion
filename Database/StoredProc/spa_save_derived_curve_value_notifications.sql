IF OBJECT_ID(N'[dbo].[spa_save_derived_curve_value_notifications]', N'P') IS NOT NULL

/****** Object:  StoredProcedure [dbo].[spa_save_derived_curve_value_notifications]    Script Date: 10/20/2014 9:28:44 AM ******/
DROP PROCEDURE [dbo].[spa_save_derived_curve_value_notifications]
GO

/****** Object:  StoredProcedure [dbo].[spa_save_derived_curve_value_notifications]    Script Date: 10/20/2014 9:28:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[spa_save_derived_curve_value_notifications]
@flag CHAR(1) = NULL,
@as_of_date_from VARCHAR(30) = NULL,
@as_of_date_to VARCHAR(30) = NULL

AS

DECLARE @from_date DATE = DATEADD(DAY, -1, GETDATE())
DECLARE @to_date DATE = @from_date
DECLARE @current_day int = DATEPART(d, @from_date)
DECLARE @tenor_from DATE = DATEADD(YEAR, -10, @from_date)
SET @tenor_from = DATEADD(day, -@current_day + 1, @tenor_from)
DECLARE @tenor_to DATE = DATEADD(YEAR, 20, @from_date)
SET @tenor_to = DATEADD(day, -@current_day + 1, @tenor_to)

DECLARE @curve_ids VARCHAR(500) = '10, 12, 14, 16, 17, 22, 24, 26, 28, 30, 18, 19, 32, 34, 36, 38, 40, 42, 45, 44, 51'
DECLARE @process_id VARCHAR(100) = dbo.FNAGetNewID (), @user_login_id VARCHAR(50) = dbo.fnadbuser()

IF @flag = 'c' 
BEGIN 
	SET @from_date = CONVERT(VARCHAR(10), @as_of_date_from, 121)
	SET @to_date = CONVERT(VARCHAR(10), ISNULL(@as_of_date_to, @from_date), 121)
	SET @tenor_from = CONVERT(VARCHAR(8), @from_date, 121) + '01'
	SET @tenor_to = DATEADD(YEAR, 7, @tenor_from)
	DECLARE @to_derive_curve VARCHAR(100) = NULL
	
	SELECT DISTINCT @to_derive_curve = STUFF((SELECT ',' + CAST(s.source_curve_def_id AS VARCHAR(10)) FROM source_price_curve_def s WHERE s.source_curve_def_id = source_curve_def_id AND  s.curve_id IN ( 'NOB Offpeak',  'NOB Onpeak') ORDER BY s.source_curve_def_id FOR XML PATH('')),1,1,'')
	FROM source_price_curve_def GROUP BY source_curve_def_id	
	
	--IF EXISTS( SELECT 1 FROM source_price_curve_def spcd INNER JOIN source_price_curve spc ON spc.source_curve_def_id = spcd.source_curve_def_id 
	--           WHERE spcd.market_value_id = 'Treasury Yield' AND spcd.formula_id IS NULL AND spc.curve_source_value_id = 4500 AND spc.as_of_date = @from_date)
	--BEGIN
		
		IF @to_derive_curve IS NOT NULL
			EXEC spa_save_derived_curve_value 'c', @to_derive_curve, 77, @from_date , @to_date, '4500', @tenor_from, @tenor_to, @process_id

	--END
	--ELSE
	--BEGIN
	--	EXEC  spa_message_board 'u', @user_login_id,
	--		NULL, 'Import Data',
	--		'No Forward Price imported for today. Derive curve Calculation has not been started.', '', '', 's', null, NULL, @process_id, NULL, 'n', '', 'y'
	--END	
		
END
ELSE
BEGIN	

EXEC spa_save_derived_curve_value 'c', @curve_ids, 77, @from_date, @to_date, 4500, @tenor_from, @tenor_to, @process_id

IF EXISTS (
	SELECT ids.item [Source Curve ID]
	FROM dbo.FNASplit(@curve_ids, ',') ids
	LEFT JOIN  source_price_curve spc 
	ON spc.source_curve_def_id = ids.item AND spc.as_of_date BETWEEN @from_date AND @to_date
	WHERE spc.as_of_date IS NULL
)
BEGIN
	DECLARE @email_ids VARCHAR(4000)
	DECLARE @mail_body VARCHAR(4000)
	
	SELECT @email_ids = var_value
	FROM adiha_default_codes_values_possible
	WHERE default_code_id = 55
	
	SET @mail_body = 'Price derivation completed for as of date ' + CAST(@from_date AS VARCHAR(10)) + ' (ERROR Found). <br/><br/>Price is not derived for following price curves.<br/><br/>
					<table border="1"><tr><th style="padding:5px;">Price Curve</th><th style="padding:5px;">As of Date</th><th style="padding:5px;">Tenor From</th><th style="padding:5px;">Tenor To</th></tr>'
	
	SELECT @mail_body = @mail_body + '<tr><td style="padding:5px;">' + spcd.curve_name + '</td><td style="padding:5px;">' + CAST(@from_date AS VARCHAR(10)) + '</td>
						<td style="padding:5px;">' + CAST(@tenor_from AS VARCHAR(10)) + '</td><td style="padding:5px;">' + CAST(@tenor_to AS VARCHAR(10)) + '</td></tr>'
	FROM dbo.FNASplit(@curve_ids, ',') ids
	LEFT JOIN  source_price_curve spc 
	ON spc.source_curve_def_id = ids.item AND spc.as_of_date BETWEEN @from_date AND @to_date
	INNER JOIN source_price_curve_def spcd 
	ON spcd.source_curve_def_id = ids.item
	WHERE spc.as_of_date IS NULL 
	
	SET @mail_body = @mail_body + '</table>'
	
	INSERT INTO [email_notes]
	(
		[internal_type_value_id],
		[category_value_id],
		[notes_object_id],
		[send_status],
		[active_flag],
		[notes_subject],
		[notes_text],
		[send_from],
		[send_to]
	)
	SELECT
		3,
		4,
		1,
		'n',
		'y',
		'CRITICAL: Price derivation completed for as of date ' + CAST(@from_date AS VARCHAR(10)) + ' (ERROR Found)',
		@mail_body,
		'noreply@pioneersolutionsglobal.com',
		item
	FROM dbo.FNASplit(@email_ids, ',')
END
END
