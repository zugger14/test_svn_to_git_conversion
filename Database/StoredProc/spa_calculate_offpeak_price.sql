--author mmanandhar@pioneersolutionsglobal.com

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_calculate_offpeak_price]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_calculate_offpeak_price]
GO


CREATE PROC [dbo].[spa_calculate_offpeak_price]
@as_of_date VARCHAR(100) = NULL,
--@maturity_date VARCHAR(100) = NULL,
@baseload_curve_id INT = NULL,
@onpeak_curve_id INT = NULL,
@offpeak_curve_id INT = NULL
--@tbl_name VARCHAR(100) = NULL,
--@tbl_prefix VARCHAR(100) = NULL 
 
AS 

BEGIN TRY 

	DECLARE @sql VARCHAR(8000), @db_name VARCHAR(500), @fq_table_from VARCHAR(1000), @sql1 VARCHAR(8000), @sql2 VARCHAR(8000),@message VARCHAR(200)

	DECLARE @baseload_block_type INT , @baseload_block_define_id INT 
	SET @baseload_block_type = '12000' -- Internal Static Data
	SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10)) FROM static_data_value WHERE [TYPE_ID] = 10018 AND code LIKE 'Base Load' -- External Static Data
	IF @baseload_block_define_id IS NULL 
		SET @baseload_block_define_id = 'NULL'
	 
	DECLARE @onpeak_block_type INT , @onpeak_block_define_id INT 
	SET @onpeak_block_type = '12000' -- Internal Static Data
	SELECT @onpeak_block_define_id = CAST(value_id AS VARCHAR(10)) FROM static_data_value WHERE [TYPE_ID] = 18900 AND code LIKE 'Onpeak' -- External Static Data
	IF @onpeak_block_define_id IS NULL 
		SET @onpeak_block_define_id = '0'
	 
	 --- changed on 12th March  2012 as this script is for source_price_curve and there is no logic of archiving 
	 --- by SGUPTA 
	 SET @fq_table_from = 'source_price_curve'
	--SELECT @db_name = dbase_name
	--FROM process_table_archive_policy
	--	WHERE ISNULL([prefix_location_table], '') = @tbl_prefix AND [tbl_name] = @tbl_name
		
	--SELECT @db_name = ISNULL(adpd.archive_db + '.dbo.', '') , @fq_table_from = ISNULL(adpd.archive_db + '.dbo.', '')+ adpd.table_name 	
	--FROM archive_data_policy_detail adpd 
	--		INNER JOIN archive_data_policy adp ON  adpd.archive_data_policy_id = adp.archive_data_policy_id
	--			AND  adp.main_table_name  = @tbl_name AND right(adpd.table_name,6) = @tbl_prefix 

	--IF ISNULL(@db_name, '') = '' 
	--	SET @db_name = 'dbo'
	--ELSE IF @db_name <> 'dbo'
	--	SET @db_name = @db_name + '.dbo'
	--IF @tbl_prefix IS NULL
	--	SET @tbl_prefix = ''    
		 
	--SET @fq_table_from = @db_name + '.' + @tbl_name + @tbl_prefix
	--SET @fq_table_from = 'FarrmsData.adiha_process_archive_clean.dbo.source_price_curve_arch2'
	--SET @fq_table_from = 'dbo.source_price_curve_arch2'
	
	CREATE TABLE #baseload(curve_value float,source_curve_def_id INT , Assessment_curve_type_value_id int, curve_source_value_id INT, maturity_date datetime, block_define_id int, block_type INT, is_dst INT )
	
	SET @sql ='insert into #baseload(curve_value ,source_curve_def_id  , Assessment_curve_type_value_id , curve_source_value_id , maturity_date , block_define_id , block_type,is_dst)
	select spc.curve_value,spc.source_curve_def_id, spc.Assessment_curve_type_value_id, spc.curve_source_value_id, spc.maturity_date, 
	spcd1.block_define_id, spcd1.block_type , spc.is_dst
	from ' + @fq_table_from + ' spc inner join source_price_curve_def spcd1 on spcd1.source_curve_def_id = spc.source_curve_def_id
	and  spc.source_curve_def_id = ' + cast(@baseload_curve_id AS VARCHAR)+ ' AND	spc.as_of_date = ''' + @as_of_date + ''' 
		AND spc.curve_source_value_id = 4500'
	EXEC spa_print @sql	
	EXEC(@sql)
	
	CREATE TABLE #onpeak(curve_value float,source_curve_def_id INT , Assessment_curve_type_value_id int, curve_source_value_id INT, maturity_date datetime, block_define_id int, block_type INT,is_dst INT)
	
	SET @sql ='insert into #onpeak(curve_value ,source_curve_def_id  , Assessment_curve_type_value_id , curve_source_value_id , maturity_date , block_define_id , block_type,is_dst)
	select spc.curve_value,spc.source_curve_def_id, spc.Assessment_curve_type_value_id, spc.curve_source_value_id, spc.maturity_date,
	 spcd1.block_define_id, spcd1.block_type, spc.is_dst
	from ' + @fq_table_from + ' spc inner join source_price_curve_def spcd1 on spcd1.source_curve_def_id = spc.source_curve_def_id
	and  spc.source_curve_def_id = ' + cast(@onpeak_curve_id AS VARCHAR)+ ' AND	spc.as_of_date = ''' + @as_of_date + ''' 
		AND spc.curve_source_value_id = 4500'
	EXEC spa_print @sql
	EXEC(@sql)
	
	IF NOT EXISTS(SELECT 'x' FROM #baseload)
	BEGIN
		
		SET @message = 'There is no data for baseload in the table ' + @fq_table_from
		
		EXEC spa_ErrorHandler -1												--error no
							, 'EOD'											--module
							, 'spa_calculate_offpeak_price'					--area
							, 'Error'										--status
							, @message				--message
							, ''													--recommendation
		RETURN
	END
	
	IF NOT EXISTS(SELECT 'x' FROM #onpeak)
	BEGIN
		
		SET @message = 'There is no data for onpeak in the table ' + @fq_table_from
		
		EXEC spa_ErrorHandler -1												--error no
							, 'EOD'											--module
							, 'spa_calculate_offpeak_price'					--area
							, 'Error'										--status
							, @message				--message
							, ''													--recommendation
		RETURN
	END
	
	
	
	DECLARE @baseload_granularity INT, @onpeak_granularity INT ,@term_baseload CHAR(1),@term_onpeak CHAR(1)
	SELECT @baseload_granularity = granularity FROM source_price_curve_def WHERE source_curve_def_id = @baseload_curve_id
	SELECT @onpeak_granularity = granularity FROM source_price_curve_def WHERE source_curve_def_id = @onpeak_curve_id
	
	IF @baseload_granularity = 991
		set @term_baseload = 'q'
	ELSE IF @baseload_granularity = 993
		set @term_baseload = 'a'
	ELSE
		set @term_baseload = 'm'
	
	IF @onpeak_granularity = 991
		set @term_onpeak = 'q'
	ELSE IF @onpeak_granularity = 993
		set @term_onpeak = 'a'
	ELSE
		set @term_onpeak = 'm'
	
	SELECT * INTO #temp_price_curve FROM source_price_curve spc WHERE 1=2
	-- insert only match rows of baseload and onpeak 
		SET @sql = '
	insert into #temp_price_curve (source_curve_def_id, as_of_date, Assessment_curve_type_value_id,curve_source_value_id, maturity_date , curve_value, is_dst)
	SELECT  
	' + cast(@offpeak_curve_id AS VARCHAR)+ ', ''' + @as_of_date + ''',baseload.Assessment_curve_type_value_id, 4500,baseload.maturity_date,
	(((aaa.term_no_hrs * baseload.curve_value)-(bbb.term_no_hrs * onpeak.curve_value))/(aaa.term_no_hrs - bbb.term_no_hrs)),onpeak.is_dst
	 
	 FROM  
	#baseload  baseload  
	inner join #onpeak onpeak on onpeak.maturity_date = baseload.maturity_date and isnull(onpeak.is_dst,0) = isnull(baseload.is_dst,0)
	OUTER APPLY (
	  select sum(volume_mult) term_no_hrs from hour_block_term hbt WHERE term_date >=  dbo.FNAGetTermStartDate(''' + @term_baseload + ''',onpeak.maturity_date,0)  and term_date < dbo.[FNAGetTermStartDate](''' + @term_baseload + ''',onpeak.maturity_date,1)
	  AND  hbt.block_define_id = COALESCE(baseload.block_define_id,' + cast(@baseload_block_define_id AS VARCHAR) + ') and  hbt.block_type = COALESCE(baseload.block_type,' + cast(@baseload_block_type AS VARCHAR) + ')
	) aaa
	OUTER APPLY (
	  select sum(volume_mult) term_no_hrs 
	  from hour_block_term hbt WHERE term_date >= dbo.FNAGetTermStartDate(''' + @term_onpeak + ''',onpeak.maturity_date,0) and term_date < dbo.[FNAGetTermStartDate](''' + @term_onpeak + ''',onpeak.maturity_date,1)
	  AND  hbt.block_define_id = COALESCE(onpeak.block_define_id,' + cast(@onpeak_block_define_id AS VARCHAR) + ') and  hbt.block_type = COALESCE(onpeak.block_type,' + cast(@onpeak_block_type AS VARCHAR) + ')
	) bbb
	'
		

	EXEC spa_print @sql
	EXEC(@sql)
	
	-- insert only exist rows in baseload and not exists in onpeak
	SET @sql = '
	insert into #temp_price_curve (source_curve_def_id, as_of_date, Assessment_curve_type_value_id,curve_source_value_id, maturity_date , curve_value,is_dst)
	SELECT 
	' + cast(@offpeak_curve_id AS VARCHAR)+ ', ''' + @as_of_date + ''',baseload.Assessment_curve_type_value_id, 4500,baseload.maturity_date,
	(((aaa.term_no_hrs * baseload.curve_value)-(bbb.term_no_hrs * isnull(max_value.curve_value,onpeak.curve_value)))/(aaa.term_no_hrs - bbb.term_no_hrs)),baseload.is_dst
	 
	 FROM  
	
	#baseload  baseload  
	left join #onpeak onpeak on onpeak.maturity_date = baseload.maturity_date and isnull(onpeak.is_dst,0) = isnull(baseload.is_dst,0)
	CROSS APPLY (
		SELECT  MAX(o.maturity_date) maturity_date ,MAX(o.block_define_id) block_define_id, MAX(o.block_type) block_type
		FROM #onpeak o where o.maturity_date < baseload.maturity_date and onpeak.maturity_date is null
		)  max_date
		
	inner join #onpeak max_value on max_date.maturity_date = max_value.maturity_date
	
	OUTER APPLY (
	  select sum(volume_mult) term_no_hrs from hour_block_term hbt WHERE term_date >=  dbo.FNAGetTermStartDate(''' + @term_baseload + ''',baseload.maturity_date,0)  and term_date < dbo.[FNAGetTermStartDate](''' + @term_baseload + ''',baseload.maturity_date,1)
	  AND  hbt.block_define_id = COALESCE(baseload.block_define_id,' + cast(@baseload_block_define_id AS VARCHAR) + ') and  hbt.block_type = COALESCE(baseload.block_type,' + cast(@baseload_block_type AS VARCHAR) + ')
	) aaa
	OUTER APPLY (
	  select sum(volume_mult) term_no_hrs 
	  from hour_block_term hbt WHERE term_date >= dbo.FNAGetTermStartDate(''' + @term_onpeak + ''',baseload.maturity_date,0) and term_date < dbo.[FNAGetTermStartDate](''' + @term_onpeak + ''',baseload.maturity_date,1)
	  AND  hbt.block_define_id = COALESCE(max_date.block_define_id,' + cast(@onpeak_block_define_id AS VARCHAR) + ') and  hbt.block_type = COALESCE(max_date.block_type,' + cast(@onpeak_block_type AS VARCHAR) + ')
	) bbb
	'
		

	EXEC spa_print @sql
	EXEC(@sql)
	
	
	-- insert only exist rows in onpeak and not exists in baseload 
	SET @sql = '
	insert into #temp_price_curve (source_curve_def_id, as_of_date, Assessment_curve_type_value_id,curve_source_value_id, maturity_date , curve_value,is_dst)
	SELECT 
	' + cast(@offpeak_curve_id AS VARCHAR)+ ', ''' + @as_of_date + ''',onpeak.Assessment_curve_type_value_id, 4500,onpeak.maturity_date,
	(((aaa.term_no_hrs *  isnull(max_value.curve_value,baseload.curve_value))-(bbb.term_no_hrs *onpeak.curve_value))/(aaa.term_no_hrs - bbb.term_no_hrs)),onpeak.is_dst
	 
	 FROM  
	
	#onpeak  onpeak   
	left join #baseload baseload on onpeak.maturity_date = baseload.maturity_date and isnull(onpeak.is_dst,0) = isnull(baseload.is_dst,0)
	CROSS APPLY (
		SELECT  MAX(b.maturity_date) maturity_date ,MAX(b.block_define_id) block_define_id, MAX(b.block_type) block_type
		FROM #baseload b where b.maturity_date < onpeak.maturity_date and baseload.maturity_date is null
		)  max_date
		
	INNER join #baseload max_value on max_date.maturity_date = max_value.maturity_date
	
	OUTER APPLY (
	  select sum(volume_mult) term_no_hrs from hour_block_term hbt WHERE term_date >=  dbo.FNAGetTermStartDate(''' + @term_baseload + ''',onpeak.maturity_date,0)  and term_date < dbo.[FNAGetTermStartDate](''' + @term_baseload + ''',onpeak.maturity_date,1)
	  AND  hbt.block_define_id = COALESCE(max_date.block_define_id,' + cast(@baseload_block_define_id AS VARCHAR) + ') and  hbt.block_type = COALESCE(max_date.block_type,' + cast(@baseload_block_type AS VARCHAR) + ')
	) aaa
	OUTER APPLY (
	  select sum(volume_mult) term_no_hrs 
	  from hour_block_term hbt WHERE term_date >= dbo.FNAGetTermStartDate(''' + @term_onpeak + ''',onpeak.maturity_date,0) and term_date < dbo.[FNAGetTermStartDate](''' + @term_onpeak + ''',onpeak.maturity_date,1)
	  AND  hbt.block_define_id = COALESCE(onpeak.block_define_id,' + cast(@onpeak_block_define_id AS VARCHAR) + ') and  hbt.block_type = COALESCE(onpeak.block_type,' + cast(@onpeak_block_type AS VARCHAR) + ')
	) bbb
	'
		

	EXEC spa_print @sql
	EXEC(@sql)
	
	SET @sql ='delete opeak from ' + @fq_table_from + ' opeak inner join #temp_price_curve osource 
	on opeak.source_curve_def_id = osource.source_curve_def_id and opeak.maturity_date = osource.maturity_date and opeak.as_of_date = osource.as_of_date
	and opeak.is_dst = osource.is_dst and opeak.curve_source_value_id = 4500'
	
	EXEC spa_print @sql
	EXEC(@sql)
	
	SET @sql ='insert into ' + @fq_table_from + ' (source_curve_def_id, as_of_date, Assessment_curve_type_value_id,curve_source_value_id, maturity_date , curve_value,is_dst)  select source_curve_def_id, as_of_date, Assessment_curve_type_value_id,curve_source_value_id, maturity_date , curve_value,is_dst from #temp_price_curve'
	 
	EXEC spa_print @sql
	EXEC(@sql)
		
	
	EXEC spa_ErrorHandler 0													--error no
								, 'EOD'										--module
								, 'spa_calculate_offpeak_price'				--area
								, 'Success'									--status
								, 'Successfully inserted offpeak price'		--message
								, ''										--recommendation

END TRY
BEGIN CATCH
	DECLARE @err_no INT 
	SELECT @err_no = ERROR_NUMBER()
	IF @err_no = 2627
		set @message ='There already exists data in table ' + @fq_table_from + ' for the curve id'
	ELSE	
		SET @message = 'Failed inserting offpeak price'
		
	EXEC spa_ErrorHandler -1												--error no
							, 'EOD'											--module
							, 'spa_calculate_offpeak_price'					--area
							, 'Error'										--status
							, @message										--message
							, ''											--recommendation

END CATCH 