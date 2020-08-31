
if object_id('spa_calc_generation_unit_cost_wrapper') is not null
	drop proc dbo.spa_calc_generation_unit_cost_wrapper

GO

CREATE PROCEDURE [dbo].[spa_calc_generation_unit_cost_wrapper] 
	@flag varchar(1)='l'  -- l=long term; s=short term, b=both
	,@as_of_date datetime 
	,@term_start datetime =null
	,@term_end datetime 
	,@hourly_no_days int=7
	,@tou_id int=null
	,@location_ids varchar(1000) = null ,
	@call_from_eod INT = 0,
	@purge char(1)=null,
	@enable_paging INT = 0, --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL,
	@batch_process_id VARCHAR(100) = NULL,
	@batch_report_param VARCHAR(1000) = NULL
AS

SET NOCOUNT ON
/*

	declare	@flag varchar(1)='b'  -- l=long term; s=short term, b=both
		,@as_of_date datetime='2017-03-25'
		,@term_start datetime ='2017-03-25'
		,@term_end datetime =null
		,@hourly_no_days int=null
		,@tou_id int=null
		,@location_ids varchar(1000) = null
		,@call_from_eod INT = 1
		,@purge char(1)=null
		,@enable_paging INT = 0, --'1' = enable, '0' = disable
		@page_size INT = NULL,
		@page_no INT = NULL,
		@batch_process_id VARCHAR(100) = NULL,
		@batch_report_param VARCHAR(1000) = NULL
		
	--	select @flag='s', @as_of_date='', @term_start='2017-03-25', @term_end='', @hourly_no_days='6', @location_ids='1587'
	
	
	--EXEC spa_calc_generation_unit_cost_wrapper  @flag='b',@as_of_date='2016-09-30',@term_start='2016-10-01',@term_end='2016-10-04',@hourly_no_days='3',@location_ids='1570'
	--*/
	
	set @as_of_date =nullif(@as_of_date,'')
	set @term_start =nullif(@term_start,'')
	set @term_end =nullif(@term_end,'')
	
	if @call_from_eod=1
		set @term_start=@as_of_date+1

		
	DECLARE  @term_start1 DATETIME,@term_end1 DATETIME ,@as_of_date1 DATETIME
	DECLARE @entire_term_end DATETIME = @term_end
	
	DECLARE @user_name        VARCHAR(30),
	        @desc             VARCHAR(MAX)='',
	        @group_tou_id     INT,
	        @st               VARCHAR(MAX)
	
	SET @batch_process_id = ISNULL(@batch_process_id, REPLACE(NEWID(), '-', '_'))
	SET @user_name = dbo.FNADBUser()
	
	
	IF OBJECT_ID(N'tempdb..#tmp_stutus') IS NOT NULL DROP TABLE #tmp_stutus
	
	CREATE TABLE #tmp_stutus
	(
		ErrorCode          VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[module]           VARCHAR(500) COLLATE DATABASE_DEFAULT,
		area               VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[status]           VARCHAR(50) COLLATE DATABASE_DEFAULT,
		err_msg            VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		recommendation     VARCHAR(MAX) COLLATE DATABASE_DEFAULT
	)
	


	BEGIN TRY

		if isnull(nullif(@purge,'NULL'),'n')='y'
		begin
			IF ISNULL(@flag, 'b') IN ('b', 's')
			BEGIN

				SET @term_start1 = isnull(@term_start,@as_of_date + 1)   
				SET @hourly_no_days = ISNULL(@hourly_no_days, 7)
				SET @term_end1 =  DATEADD(DAY, @hourly_no_days, @term_start1)

			END

			IF ISNULL(@flag, 'b') IN ('b', 'l')
			BEGIN
		
				if ISNULL(@flag, 'b')='b'
					SET @term_start1 =isnull(@term_start, @as_of_date + 1)
				else
					SET @term_start1 = @as_of_date + 1

				SET @term_end1 = ISNULL(@entire_term_end, DATEADD(YEAR, 6, @term_start1))
			end
		
			set @st='
					delete process_generation_unit_cost where term_hr between '''+convert(varchar(30),@term_start1,120)+''' and +'''+convert(varchar(30),dateadd(hour,-1, @term_end1+1),120)+''''
					+case when isnull(@location_ids,'')='' then '' else ' and location_id in ('+@location_ids+' )  ' end

			print(@st)
			exec(@st)

		end

		IF ISNULL(@flag, 'b') IN ('b', 's')
		BEGIN

		    SET @term_start1 = isnull(@term_start,@as_of_date + 1)
		   
		    SET @hourly_no_days = ISNULL(@hourly_no_days, 7)

			SET @term_end1 =  DATEADD(DAY, @hourly_no_days, @term_start1)
			
			set @as_of_date1=isnull(@as_of_date,@term_start1-1)
			
			-- select @term_start1 '@term_start1',@term_end1 '@term_end1'

			--select @as_of_date1,
		 --       @term_start1,
		 --       @term_end1,
		 --      @location_ids,
		 --        @call_from_eod
			--return

		    --insert into #tmp_stutus 
		    EXEC [dbo].[spa_calc_generation_unit_cost] 
		         @flag = 's', -- l=long term; s=short term
		         @as_of_date = @as_of_date1,
		         @term_start = @term_start1,
		         @term_end = @term_end1,
		         @hourly_no_days = null, --@hourly_no_days -- --Term derive logic is handle here in wrapper, so there will not be null in term_start and term_end in both short and long and no use of @hourly_no_days after derive the term

		         @group_tou_id = NULL,
		         @location_ids = @location_ids,
		         @call_from_eod = @call_from_eod

		END
		
		--if exists(select 1 from #tmp_stutus where ErrorCode='Error')
		--begin
		--    -- RAISERROR with severity 11-19 will cause execution to
		--    -- jump to the CATCH block.
		--    RAISERROR ('Error raised in TRY block.', -- Message text.
		--               16, -- Severity.
		--               1 -- State.
		--               );
		--end
		
		--truncate table #tmp_stutus
		
		IF ISNULL(@flag, 'b') IN ('b', 'l')
		BEGIN
			declare @c_term_start datetime,@c_term_end datetime


			if ISNULL(@flag, 'b')='b'
		    SET @term_start1 =isnull(@term_start, @as_of_date + 1)
			else
				SET @term_start1 = @as_of_date + 1
		    SET @term_end1 = ISNULL(@entire_term_end, DATEADD(YEAR, 6, @term_start1)) -- ISNULL(@entire_term_end, DATEADD(month, 3, @term_start1))  -- ISNULL(@entire_term_end, DATEADD(YEAR, 6, @term_start1))
		    SET @hourly_no_days = ISNULL(@hourly_no_days, 7)
			set @as_of_date1=isnull(@as_of_date,@term_start1-1)

		--	select @term_start1 '@term_start1',@term_end1 '@term_end1'

			DECLARE term CURSOR FOR 
			SELECT term_start,term_end FROM [FNATermBreakdown] ('m',@term_start1,@term_end1)  --where  term_start='2014-01-01'
			OPEN term
			FETCH NEXT FROM term INTO @c_term_start ,@c_term_end
			WHILE @@FETCH_STATUS = 0
			BEGIN


			--select	@as_of_date '@as_of_date',@c_term_start ,@c_term_end '@c_term_end',@location_ids '@location_ids',@call_from_eod '@call_from_eod'

		--	print '*************************************************************8'
		--	print 'Print Time:'+ convert(varchar(16),getdate(),120)
		--	print '@term_start:'+ convert(varchar(10),@c_term_start,120)
		--	print '@term_end:'+ convert(varchar(10),@c_term_end,120) 
		--	print '*************************************************************8'

				    --insert into #tmp_stutus 
				EXEC [dbo].[spa_calc_generation_unit_cost] 
					 @flag = 'l', -- l=long term; s=short term
					 @as_of_date = @as_of_date1,
					 @term_start =@c_term_start,
					 @term_end = @c_term_end,
					 @hourly_no_days = null,  --@hourly_no_days -- --Term derive logic is handle here in wrapper, so there will not be null in term_start and term_end in both short and long and no use of @hourly_no_days after derive the term
					 @group_tou_id = NULL,
					 @location_ids = @location_ids,
					 @call_from_eod = @call_from_eod
			
				FETCH NEXT FROM term INTO @c_term_start ,@c_term_end
			END
			CLOSE term
			DEALLOCATE term

		
		END
		
	--	return
		
		
		--if exists(select 1 from #tmp_stutus where ErrorCode='Error')
		--begin
		--	-- RAISERROR with severity 11-19 will cause execution to
		--	-- jump to the CATCH block.
		--	RAISERROR ('Error raised in TRY block.', -- Message text.
		--			   16, -- Severity.
		--			   1 -- State.
		--			   );
		--end
		
		
		/*-----------------------------------------Total Deal vloume update for the changed volume ----------------------------------------------------------------------------*/	
		DECLARE @spa VARCHAR(1000)
		DECLARE @job_name                  VARCHAR(500),
		        @report_position_deals     VARCHAR(500)
		
		SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_name, @batch_process_id)
		EXEC spa_print @report_position_deals
		EXEC (
		         'CREATE TABLE ' + @report_position_deals +
		         '( source_deal_header_id INT, action CHAR(1))'
		     )
		
		SET @st = 'INSERT INTO ' + @report_position_deals +
		    '(source_deal_header_id,action)
			SELECT DISTINCT sdd.source_deal_header_id ,''u'' 
			FROM  source_deal_detail sdd 
	inner join dbo.source_minor_location sml on sdd.location_id=sml.source_minor_location_id
	inner join dbo.source_major_location smjl on smjl.source_major_location_ID=sml.source_major_location_ID
		 and smjl.location_name=''Generator''		
		' + CASE 
		         WHEN ISNULL(@location_ids, '') = '' THEN ''
		         ELSE ' and sml.source_minor_location_id in (' + @location_ids + 
		              ' )  '
		    END
		
		EXEC (@st)
		
		IF @@rowcount > 0
		BEGIN
		    SET @spa = 'spa_update_deal_total_volume NULL,''' + @batch_process_id + ''''
		    
		    EXEC (@spa)
		         
		         --EXEC spa_print @spa
		         --SET @job_name = 'spa_update_deal_total_volume_' + @batch_process_id
		         --EXEC spa_run_sp_as_job @job_name,
		         --	 @spa,
		         --	 'spa_update_deal_total_volume',
		         --	 @user_name
		END
		
		SET @desc = 
		    'Generator power cost calculation process completed for as of date:' 
		    + dbo.FNADateFormat(@as_of_date1) + '.'
		
		
		EXEC spa_ErrorHandler 0,
		     'Generation Calculation',
		     'spa_calc_generation_unit_cost_wrapper',
		     'Success',
		     @desc,
		     ''
		IF @call_from_eod <> 1     
		     EXEC spa_message_board 'i',
		     		@user_name,
		     		NULL,
		     		'Generator power cost calculation',
		     		@desc ,null,null,'s'
	END TRY
	BEGIN CATCH
		SELECT @desc = 
		       'Generator power cost calculation process completed for as of date:' 
		       + dbo.FNADateFormat(@as_of_date) + ' (ERRORS found).'
		       + ISNULL('[' + err_msg + ']', '')
		FROM   #tmp_stutus
		WHERE  ErrorCode = 'Error'
		
		SET @desc = ISNULL(@desc, ERROR_MESSAGE())		
		
		
		EXEC spa_ErrorHandler -1,
		     'Generation Calculation',
		     'spa_calc_generation_unit_cost_wrapper',
		     'Error',
		     @desc,
		     ''
		IF @call_from_eod <> 1        
		     EXEC spa_message_board 'i',
		     	@user_name,
		     	NULL,
		     	'Generator power cost calculation',
		     	@desc ,null,null,'e'
	END CATCH
