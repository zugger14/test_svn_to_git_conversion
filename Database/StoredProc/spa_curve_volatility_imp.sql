IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_curve_volatility_imp]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_curve_volatility_imp]

go
CREATE PROC [dbo].[spa_curve_volatility_imp]
			@xml VARCHAR(MAX),
			@risk_free_rate INT,
			@as_of_date DATETIME,
			@no_days FLOAT,
			@curve_source_value_id INT,
			@round_by INT = 4,
			@batch_process_id VARCHAR(50) = NULL,	
			@batch_report_param VARCHAR(1000) = NULL
as

--SELECT p.* FROM dbo.source_price_curve p INNER JOIN source_price_curve_def d 
--ON p.source_curve_def_id=d.source_curve_def_id
--	AND d.source_curve_type_value_id=575 AND as_of_date='2009-04-05'
--	
--SELECT p.* FROM dbo.source_price_curve p INNER JOIN source_price_curve_def d 
--ON p.source_curve_def_id=d.source_curve_def_id
--	AND d.source_curve_type_value_id=577 AND as_of_date='2009-04-05'
--
--SELECT * FROM dbo.source_price_curve_def
--SELECT * FROM dbo.source_price_curve
-------------------test---------------------------------------------
/*
DECLARE @xml varchar(MAX),@risk_free_rate INT,@as_of_date DATETIME,@no_days INT,@curve_source_value_id INT,@round_by int, @batch_process_id VARCHAR(50)

SET @xml='
<Root><PSRecordset  options="c" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="2.8" premium="0.2605" seed="0.3" ></PSRecordset> <PSRecordset  options="c" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="2.85" premium="0.2289" seed="0.3" ></PSRecordset> <PSRecordset  options="c" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="2.9" premium="0.1998" seed="0.3" ></PSRecordset> <PSRecordset  options="c" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="2.95" premium="0.1733" seed="0.3" ></PSRecordset> <PSRecordset  options="c" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="3" premium="0.1493" seed="0.3" ></PSRecordset> <PSRecordset  options="c" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="3.05" premium="0.1278" seed="0.3" ></PSRecordset> <PSRecordset  options="c" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="3.1" premium="0.1087" seed="0.3" ></PSRecordset> <PSRecordset  options="c" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="3.15" premium="0.0918" seed="0.3" ></PSRecordset> <PSRecordset  options="c" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="3.2" premium="0.0771" seed="0.3" ></PSRecordset> <PSRecordset  options="c" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="3.25" premium="0.0644" seed="0.3" ></PSRecordset> <PSRecordset  options="p" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="2.8" premium="0.0797" seed="0.3" ></PSRecordset> <PSRecordset  options="p" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="2.85" premium="0.0981" seed="0.3" ></PSRecordset> <PSRecordset  options="p" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="2.9" premium="0.1189" seed="0.3" ></PSRecordset> <PSRecordset  options="p" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="2.95" premium="0.1423" seed="0.3" ></PSRecordset> <PSRecordset  options="p" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="3" premium="0.1683" seed="0.3" ></PSRecordset> <PSRecordset  options="p" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="3.05" premium="0.1967" seed="0.3" ></PSRecordset> <PSRecordset  options="p" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="3.1" premium="0.2275" seed="0.3" ></PSRecordset> <PSRecordset  options="p" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="3.15" premium="0.2606" seed="0.3" ></PSRecordset> <PSRecordset  options="p" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="3.2" premium="0.2958" seed="0.3" ></PSRecordset> <PSRecordset  options="p" exercise_type="e" commodity="50" index="4409" term="2017-04-01" expiration="2017-04-01" strike="3.25" premium="0.3331" seed="0.3" ></PSRecordset> </Root>'

SET @risk_free_rate=4856
SET @as_of_date='2017-03-09'
SET @no_days=''
SET @curve_source_value_id=4500
SET @round_by=2

DROP TABLE #tmp
--*/
----------------------end Test----------------------------------------
DECLARE @user_name VARCHAR(50)
SET @user_name = dbo.fnadbuser()
DECLARE @url VARCHAR(500)
DECLARE @desc VARCHAR(500)
DECLARE @errorMsg VARCHAR(200)
DECLARE @errorcode VARCHAR(1)
DECLARE @url_desc VARCHAR(500)

SET @url = ''
SET @desc = ''
SET @errorMsg = ''
SET @errorcode = 'e'
SET @url_desc = ''
SET @round_by = 4 --According to the new requirement ROUNDING is not required anymore for the calculation so it's set to NULL.

DECLARE @idoc INT, @process_id VARCHAR(50)
DECLARE @vol_value FLOAT, @return_PREMIUM FLOAT, @return_PREMIUM_old FLOAT, @incrementby FLOAT, @vol_value_old FLOAT
--if @process_id is null
--	SET @process_id = REPLACE(newid(),'-','_')
	
SET @process_id = ISNULL(@batch_process_id, dbo.FNAGetNewID())

BEGIN TRY
	BEGIN TRAN

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
	SELECT * into #tmp
	FROM OPENXML (@idoc, '/Root/PSRecordset', 2)
		WITH (
			options VARCHAR(50)		'@options',      
			ex_type VARCHAR(50)		'@exercise_type',      
			commodity INT			'@commodity',      
			curve_id INT			'@index',      
			term VARCHAR(50)		'@term',      
			expiration VARCHAR(50)	'@expiration',      
			strike VARCHAR(50)		'@strike',      
			premium VARCHAR(50)		'@premium',
			seed VARCHAR(50)		'@seed'    

	)
	
	EXEC sp_xml_removedocument @idoc
	
	DECLARE	@divison2 TINYINT, @cnt TINYINT
	SET @divison2 = 0
	DECLARE @S FLOAT, @r FLOAT, @T FLOAT
	DECLARE @options VARCHAR(50), @ex_type VARCHAR(50), @commodity INT, @curve_id INT, @term_start DATETIME,      
			@expiration DATETIME,  @strike FLOAT, @premium FLOAT, @seed FLOAT
			
	DECLARE tblCursor CURSOR FOR
	SELECT * FROM #tmp FOR  READ ONLY
	OPEN tblCursor
	FETCH NEXT FROM tblCursor INTO @options, @ex_type, @commodity, @curve_id, @term_start, @expiration, @strike, @premium, @seed
	WHILE @@FETCH_STATUS = 0
	BEGIN
	--	SELECT @options,@ex_type, @commodity,@curve_id,@term_start,@expiration,@strike,@premium,@seed
		IF ISNULL(@curve_id,'')=''
		begin
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
			select @process_id,'Error', 'Vol_I.Calculation', 'Volatility Imp. Calculation',
			'index','Index is not found for Term:' + case when @term_start is null then '' else dbo.FNADateFormat(@term_start) end  + '; Expiration:' +  case when @expiration is null then '' else dbo.FNADateFormat(@expiration) end  + '.' , 'Please check data.'
			 FROM dbo.source_price_curve_def WHERE source_curve_def_id=@curve_id
			GOTO ignor_record
		end
	
		SET @vol_value=NULL
		if ISNULL(@no_days,0)=0
		BEGIN
			IF (@term_start IS NULL) OR (@expiration IS NULL)
			begin
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
				select @process_id,'Error', 'Vol_I.Calculation', 'Volatility Imp. Calculation',
				'term','Term/Expiration is not found for Index:' + curve_id  + '.' , 'Please check data.'
				 FROM dbo.source_price_curve_def WHERE source_curve_def_id=@curve_id
				GOTO ignor_record
			end
			--SET @T=DATEDIFF(DAY,@term_start,@expiration)
			SET @T=DATEDIFF(DAY,@as_of_date,@expiration)

		end
		ELSE
			SET @T=ISNULL(@no_days,0)

		SET @T=@T/365
		SELECT @S =MAX(CASE WHEN source_curve_def_id=@curve_id THEN curve_value ELSE NULL END),
				@r =MAX(CASE WHEN source_curve_def_id=@risk_free_rate THEN curve_value ELSE NULL END) 
		FROM dbo.source_price_curve 
		WHERE as_of_date=@as_of_date AND maturity_date=@term_start AND curve_source_value_id=@curve_source_value_id

		IF @S IS NULL
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
			select @process_id,'Error', 'Vol_I.Calculation', 'Volatility Imp. Calculation',
			'Curve_Price','Curve Price is not found for Index:' + curve_id  + '; as_of_date:' + dbo.FNADateFormat(@as_of_date) +'; Term:'+ case when @term_start is null then '' else dbo.FNADateFormat(@term_start) end + '.' , 'Please check data.'
			 FROM dbo.source_price_curve_def WHERE source_curve_def_id=@curve_id
			GOTO ignor_record
		end
		IF @r IS NULL
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
			select @process_id,'Error', 'Vol_I.Calculation', 'Volatility Imp. Calculation',
			'Risk_free_rate','Risk free rate value is not found for Risk Free Rate:' + curve_id  + '; as_of_date:' + dbo.FNADateFormat(@as_of_date) +'; Term:'+ case when @term_start is null then '' else dbo.FNADateFormat(@term_start) end + '.' , 'Please check data.'
			 FROM dbo.source_price_curve_def WHERE source_curve_def_id=@risk_free_rate
			GOTO ignor_record
		end

		IF ISNULL(@options,'')='' OR @options NOT IN ('c','p')
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
			select @process_id,'Error', 'Vol_I.Calculation', 'Volatility Imp. Calculation',
			'options','Options value is not valiad for Index:' + curve_id  + '; as_of_date:' + dbo.FNADateFormat(@as_of_date) +'; Term:'+ case when @term_start is null then '' else dbo.FNADateFormat(@term_start) end  + ' (Options=' + ISNULL(@options,'') +').' , 'Please check data.'
			 FROM dbo.source_price_curve_def WHERE source_curve_def_id=@curve_id
			GOTO ignor_record
		END
		IF ISNULL(@strike,'')=''
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
			select @process_id,'Error', 'Vol_I.Calculation', 'Volatility Imp. Calculation',
			'strike','Strike Price is not found for index:' + curve_id  + '; Term:' + case when @term_start is null then '' else dbo.FNADateFormat(@term_start) end  +'; Expiration:'+ case when @expiration is null then '' else dbo.FNADateFormat(@expiration) end + '.' , 'Please check data.'
			 FROM dbo.source_price_curve_def WHERE source_curve_def_id=@curve_id
			GOTO ignor_record
		end

		IF ISNULL(@seed,'')=''
			SELECT @vol_value = [value] 
			FROM [dbo].[curve_volatility] v 
			INNER JOIN (
					SELECT MAX([as_of_date]) as_of_date 
					FROM [dbo].[curve_volatility] 
					WHERE [as_of_date] <= @as_of_date AND [curve_id] = @curve_id AND [curve_source_value_id] = @curve_source_value_id AND [term] = @term_start
					) m_recent 
				ON m_recent.as_of_date = v.as_of_date AND [curve_id] = @curve_id AND [curve_source_value_id] = @curve_source_value_id AND [term] = @term_start
		ELSE

		SET @vol_value = @seed
		SET @divison2 = 0
		SET @vol_value = ISNULL(@vol_value, .15)
		SET @incrementby = .1	
		SET @return_PREMIUM_old = NULL
		SET @cnt = 0
		WHILE 1 = 1
		BEGIN
				
			SET @vol_value_old=@vol_value
			EXEC spa_print 'Compare_Premium:', @premium
			EXEC spa_print 'Increament By:', @incrementby
			EXEC spa_print 'Temp_Volatilty:', @vol_value
			
			SELECT @return_PREMIUM = [PREMIUM] FROM [dbo].[FNABlackScholes] (@options, @S, @strike, @T, @r, @vol_value)
			IF 	@return_PREMIUM = @return_PREMIUM_old
				SET @cnt = @cnt+1
			ELSE
				SET @cnt = 0
				
			IF @return_PREMIUM IS NULL
				EXEC spa_print 'Return:Null'
			EXEC spa_print 'Return_Premium:', @return_PREMIUM 
			EXEC spa_print '----------------------------------------------------------------'
			IF  ROUND(@return_PREMIUM,@round_by)< round(@premium,@round_by)
			BEGIN
				IF @divison2 = 0 
					SET @vol_value = @vol_value+@incrementby
			END
			ELSE IF  ROUND(@return_PREMIUM, @round_by)> round(@premium, @round_by)
			BEGIN
				IF @divison2 = 0 
					SET @vol_value = @vol_value-@incrementby
			END
			ELSE
				BREAK

			IF @return_PREMIUM_old IS NOT NULL
			BEGIN 
				IF @premium BETWEEN @return_PREMIUM_old AND @return_PREMIUM
				BEGIN
					SET @divison2 = 1
					SET @vol_value = @vol_value_old
					SET @incrementby = @incrementby/2
					SET @return_PREMIUM = @return_PREMIUM_old
					SET @vol_value = @vol_value + (CASE WHEN @return_PREMIUM_old < @return_PREMIUM THEN 1 ELSE -1 END * @incrementby)
				END
				ELSE
				BEGIN
					IF @divison2 = 1
					BEGIN
						EXEC spa_print '@divison2=1'
						SET @incrementby = @incrementby/2
						SET @divison2 = 2
						SET @vol_value = @vol_value + (CASE WHEN @return_PREMIUM_old < @return_PREMIUM THEN 1 ELSE -1 END * @incrementby)

					END
					ELSE IF @divison2 = 2
					BEGIN
						EXEC spa_print '@divison2=2'
						--SET @incrementby=@incrementby/2
						--SET @divison2=2
						SET @vol_value = @vol_value + (CASE WHEN @return_PREMIUM_old < @return_PREMIUM THEN 1 ELSE -1 END * @incrementby)

					END

				END
				
			END 
			SET @return_PREMIUM_old = @return_PREMIUM
			IF  @cnt>9
			BEGIN
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
				select @process_id,'Warning', 'Vol_I.Calculation', 'Volatility Imp. Calculation',
				'primium','Primium can not be greater than ' +cast(@return_PREMIUM as varchar) +
				 ' for the Parameters:@CallPutFlag='+@options +', @S=' + cast(@S as varchar)+ ', @X='+cast(@strike as varchar) +
				 ', @T='+ cast(@T as varchar) +', @r='+cast(@r as varchar) +', @v='+ cast(@vol_value as varchar)+ 
				 '  for the index:' + curve_id  + '; Term:' + dbo.FNADateFormat(@term_start) +'; Expiration:'+ dbo.FNADateFormat(@expiration) + '.' , 'Please check data.'
				 FROM dbo.source_price_curve_def WHERE source_curve_def_id=@curve_id
				--GOTO ignor_record
				break
			end

		END
		EXEC spa_print 'Final_Volatilty:', @vol_value
		
		IF OBJECT_ID(N'tempdb..#del_ids') IS NOT NULL
			DROP TABLE #del_ids 
			
		CREATE TABLE #del_ids(id INT)
		
		DELETE cvi
		OUTPUT DELETED.id INTO #del_ids 
		FROM [dbo].[curve_volatility_imp] cvi
		WHERE cvi.[as_of_date] = @as_of_date 
			AND cvi.[curve_id] = @curve_id 
			AND cvi.[curve_source_value_id] = @curve_source_value_id
			AND cvi.[term] = @term_start
			AND cvi.strike = @strike
			AND cvi.exercise_type = @ex_type
			AND cvi.option_type = @options

		INSERT INTO [dbo].[curve_volatility_imp]
				   ([as_of_date]
				   ,[curve_id]
				   ,[curve_source_value_id]
				   ,[term]
				   ,[value]
				   ,[create_user]
				   ,[create_ts]
				   ,[update_user]
				   ,[update_ts]
				   ,[strike]
				   ,[option_type]
				   ,[exercise_type])
			 VALUES
				   (@as_of_date
				   ,@curve_id
				   ,@curve_source_value_id
				   ,@term_start
				   ,@vol_value
				   ,dbo.FNADBUser()
				   ,GETDATE()
				   ,dbo.FNADBUser()
				   ,GETDATE()
				   ,@strike
				   ,@options 
				   ,@ex_type)
		
		DECLARE @eid INT
		SET @eid = SCOPE_IDENTITY()

		DELETE civ FROM calc_implied_volatility civ
		INNER JOIN #del_ids di on di.id = civ.cvi_id
		
		INSERT INTO calc_implied_volatility(
			option_type,
			exercise_type,
			commodity_id,
			curve_id,
			term,
			expiration,
			strike,
			premium,
			seed,
			cvi_id)
		SELECT 
			@options, 
			@ex_type,
			@commodity,
			@curve_id,
			@term_start,
			@expiration,
			@strike,
			@premium,
			@seed,
			@eid				
				   
ignor_record:		
		FETCH NEXT FROM tblCursor INTO @options, @ex_type, @commodity, @curve_id, @term_start, @expiration, @strike, @premium, @seed
	END 
	CLOSE  tblCursor
	DEALLOCATE tblCursor
	
--SELECT * FROM [dbo].[curve_volatility_imp] where [as_of_date]=@as_of_date ORDER BY curve_id,term
	COMMIT TRAN


	EXEC spa_print 'finish Volatility Imp Calculation'
	SET @desc = 'Volatility Imp. Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, dbo.FNADBUser()) + '.'
	SET @errorcode = 's'
	SET @url = ''
	EXEC spa_print @errorcode
	EXEC spa_print @process_id
-------------------End error Trapping--------------------------------------------------------------------------
--/*
END TRY

BEGIN CATCH
	EXEC spa_print 'Catch Error'
	if @@TRANCOUNT>0
		rollback
	EXEC spa_print @process_id
	set @errorcode='e'
	--EXEC spa_print  ERROR_line()
	if ERROR_message() = 'CatchError'
	begin
		set @desc='Volatility Imp. Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) + ' (ERRORS found).'
		EXEC spa_print @desc
		--SELECT * FROM fas_eff_ass_test_run_log WHERE process_id=@process_id
	end
	else
	begin
		set @desc = 'Volatility Imp. Calculation critical error found ( Errr Description:'+  ERROR_MESSAGE() + '; Line no: ' + cast(error_line() as varchar) + ').'
		EXEC spa_print @desc
	end


end catch
-- #import_status (process_id,ErrorCode,Module,Source,type,[description],[nextstep],type_error)
DECLARE @tot_no INT, @err_no INT, @war_no INT

SELECT @err_no = COUNT(*) FROM fas_eff_ass_test_run_log WHERE process_id = @process_id
SELECT @tot_no = COUNT(*) FROM #tmp
SELECT @war_no = COUNT(*) FROM fas_eff_ass_test_run_log WHERE process_id = @process_id AND code='Warning'
IF @err_no > 0 
	SET @errorcode = 'e'

SET @url_desc = '' 

if @errorcode = 'e'
BEGIN
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + 
				'&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'''

	SELECT @desc = '<a target="_blank" href="' + @url  + '">' + @desc 
	+ 
	 CASE WHEN @err_no > 0 THEN '[Records:' +cast(@tot_no-@err_no+@war_no as varchar) +'/' +  cast(@tot_no as varchar) +']' 
	 ELSE '' END
	 + '.</a>'

	SET @url_desc='<a href="../../dev/spa_html.php?spa=spa_fas_eff_ass_test_run_log '''+@process_id+'''">Click here...</a>'
		SELECT CASE WHEN @err_no = @war_no THEN 'Success' ELSE 'Error' END ErrorCode, 'Calculate Volatility Imp.' Module, 
			'spa_calc_Vol_imp' Area, CASE WHEN @err_no = @war_no THEN 'DB Warning' ELSE 'DB Error' END  Status, 
		'Volatility Imp. Calculation completed with ' +CASE WHEN @err_no = @war_no THEN 'warning' ELSE 'error' END +', Please view this report. '+@url_desc Message, '' Recommendation
END
ELSE
BEGIN
	Exec spa_ErrorHandler 0, 'VolImp_Calculation', 
				'VolImp_Calculation', 'Success', 
				@desc, ''
end

DECLARE @temptablequery VARCHAR(500)
IF @errorcode = 'e'
	SET @temptablequery = 'exec '+DB_NAME()+'.dbo.spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'''
ELSE
	SET @temptablequery = NULL
		
EXEC  spa_message_board 'u', @user_name,
			NULL, 'VolImp_Calculation',
			@desc, '', '', @errorcode, @batch_process_id,null,@batch_process_id,NULL,'n',@temptablequery,'y'