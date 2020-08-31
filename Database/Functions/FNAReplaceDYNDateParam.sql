IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[dbo].[FNAReplaceDYNDateParam]')
			AND type IN (
				N'FN'
				,N'IF'
				,N'TF'
				,N'FS'
				,N'FT'
				)
		)
	DROP FUNCTION [dbo].FNAReplaceDYNDateParam

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	This Function is created for dynamic calender (Report Filter value specific).
	This Function is used to replace the Raw value of the dynamic calendar to the resolved value. 

	Parameters
	@report_parameter : Report Parameters

	Returns: Resolved date
	
*/

CREATE FUNCTION [dbo].FNAReplaceDYNDateParam (@report_parameter NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
/******
DECLARE @report_parameter VARCHAR(MAX) 

--SET @report_parameter = ''
--SET @report_parameter = NULL 
SET @report_parameter = 'curve_id = 7184,as_of_date=45600|1|106400|n, maturity_date = NULL, Granularity = NULL, to_as_of_date= 45600|2|106400|y, to_maturity_date=45600|3|106400|n, period_from = NULL, period_to = NULL'

--SELECT dbo.FNAReplaceDYNDateParam('sub_id=NULL,stra_id=NULL,book_id=NULL,sub_book_id=NULL,as_of_date_from=45600|1|106400|n,as_of_date_to=45600|-2|106400|y,term_start=45600|1|106400|y,term_end=45600|-1|106400|n,deal_date_from=45600|-2|106400|y,deal_date_to=45600|1|106400|n,physical_financial_flag=NULL,buy_sell_flag=NULL,source_deal_header_id=NULL,counterparty_id=NULL,contract_id=NULL,trader_id=NULL,commodity_id=NULL,location_id=NULL,curve_id=NULL,source_deal_type_id=NULL,current_included=1_-_7A61D521_0FD6_4EAD_8767_934297BCA847')
--**/
BEGIN
	DECLARE @new_report_parameter NVARCHAR(MAX)
	DECLARE @pattern_1 VARCHAR(100) = '%456[0-9][0-9]|[0-9]|1064[0-9][0-9]|[ny]%'
	DECLARE @pattern_2 VARCHAR(100) = '%456[0-9][0-9]|[0-9][0-9]|1064[0-9][0-9]|[ny]%'
	DECLARE @pattern_3 VARCHAR(100) = '%456[0-9][0-9]|[0-9][0-9][0-9]|1064[0-9][0-9]|[ny]%'
	DECLARE @pattern_4 VARCHAR(100) = '%456[0-9][0-9]|-[0-9]|1064[0-9][0-9]|[ny]%'
	DECLARE @pattern_5 VARCHAR(100) = '%456[0-9][0-9]|-[0-9][0-9]|1064[0-9][0-9]|[ny]%'
	DECLARE @pattern_6 VARCHAR(100) = '%456[0-9][0-9]|-[0-9][0-9][0-9]|1064[0-9][0-9]|[ny]%'
	DECLARE @end_pattern VARCHAR(100) = '%|[ny]%'
	DECLARE @start_index INT
	DECLARE @end_index INT
	DECLARE @dyn_calendar_value NVARCHAR(50)
	DECLARE @match_pattern NVARCHAR(50)
	DECLARE @counter INT
	DECLARE @filter_value_len INT
	DECLARE @new_report_parameter_len_till_start_index INT 


	-- 465[0-9][0-9] static data type (Override Type) of type id 45600 which value id range from 45600 to 45699
	-- first three character are fixed i.e 465 but last two character can range from 0 to 9 so [0-9][0-9] is used

	-- | is used as to match the dynamic date formate i.e (Override Type|Day Adjusment|Date Adjustment Type|Is businessday) eg. 45602|0|106400|y 

	-- [0-9] is used in @pattern_1, [0-9][0-9] is used in @pattern_2, [0-9][0-9][0-9] is used in @pattern_3 is adjusment day 
	--can be numbe number ranging from 0 - 999

	-- 1064[0-9][0-9] static data type (Date Adjustment Type) of type id 106400 which value id range from 106400 to 106499
	-- first four character are fixed i.e 1064 but last two character can range from 0 to 9 so [0-9][0-9] is used

	-- [ny] is used for the is_businessday

	-- Note: we assumed that there might be only max of 100 value id for this type id
	-- Adjusment day only supports only number of three disgits

	

	SET @counter = 0
	SET @new_report_parameter = @report_parameter

	-- Added @counter to handel max recursion if in case of errror ocurred

	--select PATINDEX(@pattern_4, @new_report_parameter), PATINDEX(@pattern_1, @new_report_parameter)

	WHILE (PATINDEX(@pattern_1, @new_report_parameter) > 0
		OR PATINDEX(@pattern_2, @new_report_parameter) > 0
		OR PATINDEX(@pattern_3, @new_report_parameter) > 0
		OR PATINDEX(@pattern_4, @new_report_parameter) > 0
		OR PATINDEX(@pattern_5, @new_report_parameter) > 0
		OR PATINDEX(@pattern_6, @new_report_parameter) > 0) AND @counter < 1000
	BEGIN
		SET @start_index = NULL
		SET @end_index = NULL
		SET @dyn_calendar_value = NULL
		SET @match_pattern = NULL
		SET @filter_value_len = NULL
		SET @new_report_parameter_len_till_start_index = NULL
		
		IF PATINDEX(@pattern_1, @new_report_parameter) > 0
			SET @match_pattern = @pattern_1
		ELSE IF PATINDEX(@pattern_2, @new_report_parameter) > 0
			SET @match_pattern = @pattern_2
		ELSE IF PATINDEX(@pattern_3, @new_report_parameter) > 0
			SET @match_pattern = @pattern_3
		ELSE IF PATINDEX(@pattern_4, @new_report_parameter) > 0
			SET @match_pattern = @pattern_4
		ELSE IF PATINDEX(@pattern_5, @new_report_parameter) > 0
			SET @match_pattern = @pattern_5
		ELSE IF PATINDEX(@pattern_6, @new_report_parameter) > 0
			SET @match_pattern = @pattern_6

		--SELECT @start_index = MIN(rs_matches.id)
		--FROM (VALUES 
		--		(PATINDEX(@pattern_1, @new_report_parameter))
		--		, (PATINDEX(@pattern_2, @new_report_parameter))
		--		, (PATINDEX(@pattern_3, @new_report_parameter))
		--		, (PATINDEX(@pattern_4, @new_report_parameter))
		--		, (PATINDEX(@pattern_5, @new_report_parameter))
		--		, (PATINDEX(@pattern_6, @new_report_parameter))
		--	) rs_matches (id)

	
		SET @filter_value_len = LEN(@new_report_parameter)

		SELECT @start_index = PATINDEX(@match_pattern, @new_report_parameter)

		/*
		Using LEN here is buggy when there is leading space such as 
		"curve_id = 7184, as_of_date = 45600|1|106400|n, maturity_date = NULL, Granularity = NULL"
		The substring will return "curve_id = 7184, as_of_date = " (with trailing space), which will be unaccounted when using LEN
		, thus giving less value, which will generate following malformed output
		
		curve_id = 7184, as_of_date = 2020-06-04arity = NULL
		So DATALENGHT()/2 is used to include trailing space for the character count.
		Other possible solutions are LEN(@string + 'x') - 1 or LEN(REPLACE(@string, ' ', '_'))
		*/
		SET @new_report_parameter_len_till_start_index = DATALENGTH(SUBSTRING(@new_report_parameter, 0, @start_index)) / 2

		/*
			As the filter parameter may contain multiple pattern and we have added if else condition to get match pattern it will cause issue while finding the end index of the pattern as PATINDEX return index of the first occurence of the match pattern.To deal with such issue @new_report_parameter_len_till_start_index
			is set length up to the @start_index and substring 
			operation is done to find the end index. 

			This string search logic doesn't guarentee finding first match as @match_pattern as it depends on setting @match_pattern to fix this issue SUBSTRING logic is added.

		*/
		
		/*
		SELECT @end_index = PATINDEX(@end_pattern, SUBSTRING(@new_report_parameter, @start_index, @filter_value_len )) + (2 + @new_report_parameter_len_till_start_index)
		WHERE (PATINDEX(@end_pattern, SUBSTRING (@new_report_parameter, @start_index, @filter_value_len )) + @new_report_parameter_len_till_start_index) > @start_index
		*/

		SELECT @end_index = @new_report_parameter_len_till_start_index + temp_end_index + 2 --2 is length of end index|[ny]
		FROM (VALUES (1)) dummy_set (id)
		OUTER APPLY (SELECT PATINDEX(@end_pattern, 
						SUBSTRING(@new_report_parameter, @start_index, LEN(@new_report_parameter))) temp_end_index
				) rs_index
		WHERE @new_report_parameter_len_till_start_index + rs_index.temp_end_index > @start_index
		
		SELECT @dyn_calendar_value = SUBSTRING(@new_report_parameter, @start_index, @end_index - @start_index)

		--select @start_index,@end_index
		SELECT @new_report_parameter = STUFF(@new_report_parameter, @start_index, @end_index - @start_index, 
			ISNULL(dbo.FNAGetSQLStandardDate(dbo.[FNAResolveDynamicDate](@dyn_calendar_value)), 'NULL'));

		SET @counter = @counter + 1
	END
	--select @new_report_parameter
	RETURN (@new_report_parameter)
END
