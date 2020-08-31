

/****** Object:  StoredProcedure [dbo].[spa_update_deal_total_volume]    Script Date: 01/30/2012 02:20:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_update_deal_total_volume]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_update_deal_total_volume]
GO

/****** Object:  StoredProcedure [dbo].[spa_update_deal_total_volume]    Script Date: 01/30/2012 02:20:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**

	Populate hourly position of the deals in portfolio.

	Parameters 
	@source_deal_header_ids : Source Deal Header Ids to process
	@process_id : Process Id for input process table of deal list to process
	@insert_type : Insert Type
				- 0 - Incremental FROM frontend
				- 5 - Re calculate all existing deals
	@partition_no : Partition No
	@user_login_id : User Login Id of runner
	@insert_process_table : Insert Process Table of deals
	@call_from : Call From
				- 0 - Call from application and adding deals in process table 
				- 1 - Call from job to process position breakdown of process table deal (without inserting process table) and job will not be created
	@call_from_2 : Call From 'alert' or other than 'alert'

*/


CREATE PROC [dbo].[spa_update_deal_total_volume]
	@source_deal_header_ids VARCHAR(MAX), 
	@process_id VARCHAR(128) = NULL,
	@insert_type INT = 0, -- 0=incremental FROM front	; 1= partial import; 2=bulk import ; 12= import FROM load forecast file
	@partition_no INT = NULL,
	@user_login_id VARCHAR(50) = NULL,
	@insert_process_table VARCHAR(1) = 'n',
	@call_from TINYINT = 0, --0=call from application and adding deals in process table ; 1=call from job to process position breakdown of process table deal (without inserting process table) and job will not be created
	@call_from_2 VARCHAR(20) = NULL 
AS 
SET nocount on
/*





-- CALCULATE POSITION DIRECTLY WITHOUT JOB
--exec [dbo].[spa_update_deal_total_volume] @source_deal_header_ids=????????????
--	,@process_id = NULL,@insert_type = 0, 
--	@partition_no = NULL,@user_login_id  = 'farrms_admin'
--	,@insert_process_table = 'n',@call_from = 1,@call_from_2 = NULL



--SELECT * FROM report_hourly_position_fixed WHERE source_deal_header_id=39859
--SELECT * FROM source_deal_detail WHERE source_deal_header_id=39859

--DELETE  report_hourly_position_fixed WHERE source_deal_header_id=39859





declare @source_deal_header_ids VARCHAR(MAX), 
	@process_id VARCHAR(128),
	@insert_type int, 
	@partition_no int
	,@user_login_id VARCHAR(50),@insert_process_table VARCHAR(1)
	,@call_from BIT=1,@call_from_2 VARCHAR(20) = NULL 
	

/*
select * from report_hourly_position_deal where source_deal_header_id=17912
select * from report_hourly_position_profile where source_deal_header_id=17912

select * from source_deal_breakdown where source_deal_header_id=17912

select * from source_deal_detail_position where source_deal_header_id=17912
select total_volume,* from source_deal_detail where source_deal_header_id=17912

select * from report_hourly_position_fixed where source_deal_header_id=17912
select * from report_hourly_position_financial where source_deal_header_id=17912

select * from source_deal_header where source_deal_header_id=17912

*/



SET nocount off	
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo

-- select * from process_deal_position_breakdown
-- delete process_deal_position_breakdown

select @source_deal_header_ids=267234, 
	@process_id = null, --'52C2B537_BDBA_41DB_BE8D_B657F070A041',
	@insert_type =1,
	@partition_no =1,
	@user_login_id='farrms_admin'
--select * from source_deal_detail_hour	
DROP TABLE #sdh11
--DROP TABLE #tmp_total_loc_volume
--DROP TABLE  #proxy_term
--DROP TABLE #proxy_term_summary
--DROP TABLE  #tmp_header_deal_id_1
--SELECT * FROM source_deal_header WHERE source_deal_header_id=398

 --SELECT * FROM #tmp_total_loc_volume
 -- SELECT * FROM #tmp_total_volume
--EXEC('truncate TABLE adiha_process.dbo.report_position_farrms_admin_'+@process_id)
--EXEC('insert into adiha_process.dbo.report_position_farrms_admin_'+@process_id +' SELECT 11111, ''i''')

--*/
--return

DECLARE @source_deal_header VARCHAR(200),
		@source_deal_detail VARCHAR(200),
		@sql VARCHAR(MAX),@sql1 VARCHAR(MAX),@sql2 VARCHAR(MAX),@sql3 VARCHAR(MAX),@sql4 VARCHAR(MAX),@sql5 VARCHAR(MAX),@sql6 VARCHAR(MAX),
		@max_id INT,
		@source_deal_header_id INT,
		@volume_frequency CHAR(1),
		@profile_id INT,
		@effected_deals VARCHAR(200),@spa VARCHAR(1000),@deal_detail_hour VARCHAR(100),@deadlock_var NCHAR(3),@orginal_insert_type int
		,@run_job_name VARCHAR(150),@source varchar(50),@err_status varchar(1),@remarks varchar(500)
		,@url VARCHAR(MAX),@desc VARCHAR(MAX)

DECLARE @baseload_block_type VARCHAR(10),
		@baseload_block_define_id VARCHAR(10),@job_name VARCHAR(100),@exit bit,@tmp_location_profile varchar(250)
		,@total_yr_fraction  varchar(250)
		,@ref_location  varchar(250)
declare @mw_uoms varchar(100) 
select @mw_uoms=ISNULL(@mw_uoms+',','')+cast(source_uom_id as varchar) from source_uom where uom_id in ('MW','KW')
set @mw_uoms=isnull(nullif(@mw_uoms,''),'-1')

begin_update:

IF object_id('tempdb..#sdh') IS NOT null		
	DROP TABLE #sdh
	
IF object_id('tempdb..#tmp_total_loc_volume') IS NOT null	
	DROP TABLE #tmp_total_loc_volume
	
IF object_id('tempdb..#proxy_term') IS NOT null
	DROP TABLE  #proxy_term

IF object_id('tempdb..#proxy_term_summary') IS NOT null
	DROP TABLE #proxy_term_summary
	
IF object_id('tempdb..#tmp_header_deal_id_1') IS NOT null
	DROP TABLE  #tmp_header_deal_id_1
	
IF object_id('tempdb..#profile_info') IS NOT null
	DROP TABLE  #profile_info

SET @deadlock_var = N'LOW'; 
SET DEADLOCK_PRIORITY @deadlock_var; 

DECLARE @default_dst_group VARCHAR(50)

SELECT  @default_dst_group = tz.dst_group_value_id
FROM
	(
		SELECT var_value default_timezone_id FROM dbo.adiha_default_codes_values  
		WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
	) df  
inner join dbo.time_zones tz  ON tz.timezone_id = df.default_timezone_id


SET @orginal_insert_type=@insert_type

SET @user_login_id=ISNULL(@user_login_id,dbo.FNADBUser())

set @exit=0

SELECT TOP (1) @run_job_name=v.[name] FROM dbo.farrms_sysjobactivity a INNER JOIN msdb.dbo.sysjobs_view v ON a.job_id=v.job_id 
		WHERE v.[name] LIKE 'update_total_volume%'+@process_id
	
set @source =replace(replace(replace(@run_job_name,'_'+@process_id,''),'_'+@user_login_id,''),'update_total_volume'+'_','')

	
SET @baseload_block_type = '12000'	-- Internal Static Data
SELECT @baseload_block_define_id = CAST(value_id as VARCHAR(10)) FROM static_data_value WHERE [type_id] = 10018 AND code LIKE 'Base Load' -- External Static Data
IF @baseload_block_define_id IS NULL 
	SET @baseload_block_define_id = 'NULL'

--for debugging by deal id 
if @process_id is null 
begin
	set @process_id=dbo.FNAGetNewID()
	IF ISNULL(@source_deal_header_ids,'')<>''
	BEGIN
		SET @source_deal_header_ids = REPLACE(@source_deal_header_ids, '#', '')
		
		CREATE TABLE #sdh11 (id INT) 
		INSERT INTO #sdh11 SELECT CAST(Item AS INT) FROM dbo.SplitCommaSeperatedValues(@source_deal_header_ids)
		
		INSERT INTO dbo.process_deal_position_breakdown (source_deal_header_id ,create_user,create_ts,process_status,insert_type ,deal_type 
			,commodity_id,fixation ,internal_deal_type_value_id,source_deal_detail_id)
		SELECT max(sdh.source_deal_header_id),@user_login_id,getdate(),0,@orginal_insert_type,max(isnull(sdh.internal_desk_id,17300)) deal_type ,
			max(isnull(spcd.commodity_id,-1)) commodity_id,max(isnull(sdh.product_id,4101)) fixation,max(isnull(sdh.internal_deal_type_value_id,-999999)),sdd.source_deal_detail_id  
		
		FROM #sdh11 h inner join source_deal_header sdh on h.id=sdh.source_deal_header_id
		inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
		left join source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id and sdd.curve_id is not null
		group by sdd.source_deal_detail_id 
		
		set @insert_type=0
		set @call_from=1
		--select * from process_deal_position_breakdown
	END
end

SET @effected_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)
SET @tmp_location_profile = dbo.FNAProcessTableName('tmp_location_profile', @user_login_id, @process_id)
SET @total_yr_fraction = dbo.FNAProcessTableName('total_yr_fraction', @user_login_id, @process_id)
SET @ref_location = dbo.FNAProcessTableName('ref_location', @user_login_id, @process_id)

SET @deal_detail_hour='deal_detail_hour'
SET @source_deal_header = 'source_deal_header'
SET @source_deal_detail = 'source_deal_detail'

IF isnull(@insert_process_table,'n')='y' 
BEGIN
	SET @source_deal_header = dbo.FNAProcessTableName('deal_header', @user_login_id, @process_id)
	SET @source_deal_detail = dbo.FNAProcessTableName('deal_detail', @user_login_id, @process_id)
END
	
IF ISNULL(@insert_type,0)=5 --re calculating of all existing deals
BEGIN
	IF OBJECT_ID(@effected_deals) IS NOT NULL
		exec('DROP TABLE '+@effected_deals)

	truncate table process_deal_position_breakdown

	exec('create TABLE '+@effected_deals +'	(source_deal_header_id int,create_user varchar(50),source_deal_detail_id int)'	)
			
	EXEC spa_print 'insert into  ',@effected_deals,' SELECT source_deal_header_id,isnull(update_user,create_user),source_deal_detail_id   FROM source_deal_detail'
	
	EXEC('insert into  '+@effected_deals +' SELECT source_deal_header_id,isnull(update_user,create_user),source_deal_detail_id FROM source_deal_detail')
	SET @insert_type=0
	SET @call_from=1
	
	set @sql='INSERT INTO dbo.process_deal_position_breakdown (source_deal_header_id ,create_user,create_ts ,process_status,insert_type ,deal_type ,commodity_id,fixation,internal_deal_type_value_id,source_deal_detail_id)
		SELECT  max(sdh.source_deal_header_id),max(sdh.create_user),getdate(),0 ,0,
			max(isnull(sdh.internal_desk_id,17300)) deal_type ,	max(isnull(spcd.commodity_id,-1)) commodity_id,max(isnull(sdh.product_id,4101)) fixation,max(isnull(sdh.internal_deal_type_value_id,-999999)),sdd.source_deal_detail_id
			FROM '+ @effected_deals +' h inner join source_deal_header sdh on h.source_deal_header_id=sdh.source_deal_header_id
				inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
				left join source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id and sdd.curve_id is not null
			group by sdd.source_deal_detail_id'

	EXEC spa_print @sql
	EXEC (@sql)
	
	delete report_hourly_position_deal_main
	delete report_hourly_position_breakdown_main
	delete report_hourly_position_profile_main
	delete report_hourly_position_financial_main
end

----the table #is_total_volume_only_update is CREATEd for skipping update timestamp statement in the  trigger [TRGUPD_SOURCE_DEAL_DETAIL] of source_deal_detail
IF  OBJECT_ID('tempdb..#is_total_volume_only_update') is  NULL
CREATE table #is_total_volume_only_update(yn bit) 

if OBJECT_ID('tempdb..#tmp_header_deal_id_1') is null
CREATE TABLE #tmp_header_deal_id_1 (source_deal_header_id INT ,create_user varchar(50) COLLATE DATABASE_DEFAULT,source_deal_detail_id int,rowid int,dst_group_value_id int )

if object_id('tempdb..#run_status_break') is null
create table #run_status_break(
	ErrorCode varchar(30) COLLATE DATABASE_DEFAULT ,	Module varchar(50) COLLATE DATABASE_DEFAULT ,	Area varchar(50) COLLATE DATABASE_DEFAULT ,	[Status] varchar(30) COLLATE DATABASE_DEFAULT ,	[Message] varchar(300) COLLATE DATABASE_DEFAULT ,	Recommendation varchar(300) COLLATE DATABASE_DEFAULT 
)
		
if object_id('tempdb..#deal_detail_dst_group') is not null
drop table #deal_detail_dst_group

create table #deal_detail_dst_group(
	deal_detail_id int, dst_group_value_id int
)
		

IF  ISNULL(@insert_type,0) NOT IN (1,2)
BEGIN 		
	IF isnull(@call_from,0)IN (0,2)
	BEGIN
			
		SET @sql='IF COL_LENGTH('''+@effected_deals+''', ''source_deal_detail_id'') IS NULL
					ALTER TABLE '+@effected_deals+' ADD source_deal_detail_id INT
				'
		EXEC(@sql)		

		set @sql='insert into '+ @effected_deals+ '(source_deal_header_id,source_deal_detail_id) 
			SELECT distinct fix.source_deal_header_id,sdd.source_deal_detail_id 
			FROM ' + @effected_deals + ' p inner join source_deal_header fix  on p.source_deal_header_id=fix.close_reference_id 
					and ISNULL(fix.internal_desk_id,17300)=17301 and isnull(fix.product_id,4101)=4100 
				inner join source_deal_detail sdd on fix.source_deal_header_id=sdd.source_deal_header_id
				LEFT JOIN '+@effected_deals+' m ON sdd.source_deal_header_id=m.source_deal_header_id 
					and sdd.source_deal_detail_id=isnull(m.source_deal_detail_id,sdd.source_deal_detail_id)
			WHERE  m.source_deal_detail_id IS null	
		'
				
		--	SELECT  * FROM static_data_value sdv WHERE sdv.value_id=17301	
		EXEC spa_print @sql 
		exec(@sql)	
					
			-- insert nomination/schedule/actul deals
				
		set @sql='insert into '+ @effected_deals+ '(source_deal_header_id,source_deal_detail_id) 
			SELECT distinct sdh.source_deal_header_id,sdd.source_deal_detail_id
			FROM  ' + @effected_deals + ' p inner join source_deal_header sdh  on p.source_deal_header_id=sdh.close_reference_id 
				and sdh.internal_deal_type_value_id IN(19,20)
				inner join source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
			UNION
			SELECT distinct sdh1.source_deal_header_id,sdd.source_deal_detail_id
			FROM  ' + @effected_deals + ' p inner join source_deal_header sdh  on p.source_deal_header_id=sdh.source_deal_header_id 
				and sdh.internal_deal_type_value_id IN(20,21)
			inner join source_deal_header sdh1  on sdh1.source_deal_header_id=sdh.close_reference_id
			inner join source_deal_detail sdd on sdd.source_deal_header_id=sdh1.source_deal_header_id

			'
		EXEC spa_print @sql
		EXEC(@sql)			
			
		set @sql='
		INSERT INTO dbo.process_deal_position_breakdown (source_deal_detail_id,source_deal_header_id ,create_user,create_ts,process_status
			,insert_type ,deal_type ,commodity_id,fixation ,internal_deal_type_value_id)
		SELECT sdd.source_deal_detail_id,max(sdh.source_deal_header_id),'''+@user_login_id+''',getdate(),0,'+cast(@orginal_insert_type as varchar)+',
			max(isnull(sdh.internal_desk_id,17300)) deal_type ,	max(isnull(spcd.commodity_id,-1)) commodity_id
			,max(isnull(sdh.product_id,4101)) fixation,max(isnull(sdh.internal_deal_type_value_id,-999999))
		FROM '+ @effected_deals +' h inner join source_deal_header sdh on h.source_deal_header_id=sdh.source_deal_header_id
			inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id 
				and sdd.source_deal_detail_id=isnull(h.source_deal_detail_id,sdd.source_deal_detail_id)
			left join source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id and sdd.curve_id is not null
		group by sdd.source_deal_detail_id'
	
		EXEC spa_print @sql
		EXEC (@sql)
		
		declare @process_id_deal varchar(50),@process_id_uom varchar(50)
		
		select @process_id_deal=@process_id,@process_id_uom=@process_id

		--EXEC spa_print '```````````````````````````````````````````````````````````````````````````````````````````````````````'
		--EXEC spa_print 'EXEC [dbo].[spa_calc_deal_uom_conversion] null,null,null,null, ''', @user_login_id, ''',''', @process_id, ''''
		--EXEC spa_print '```````````````````````````````````````````````````````````````````````````````````````````````````````'

		--EXEC [dbo].[spa_calc_deal_uom_conversion] null,null,null,null, @user_login_id, @process_id_uom

		IF ISNULL(@source_deal_header_ids,'')<>''
		BEGIN
			SET @source_deal_header_ids = REPLACE(@source_deal_header_ids, '#', '')

			CREATE TABLE #sdh (id INT) 

			INSERT INTO #sdh SELECT CAST(Item AS INT) FROM dbo.SplitCommaSeperatedValues(@source_deal_header_ids)

			INSERT INTO dbo.process_deal_position_breakdown (source_deal_detail_id,source_deal_header_id ,create_user,create_ts,process_status,insert_type 
				,deal_type ,commodity_id,fixation,internal_deal_type_value_id )
			SELECT sdd.source_deal_detail_id,max(sdh.source_deal_header_id),@user_login_id,getdate(),0,@orginal_insert_type
				,max(isnull(sdh.internal_desk_id,17300)) deal_type ,
				max(isnull(spcd.commodity_id,-1)) commodity_id,max(isnull(sdh.product_id,4101)) fixation 
				,max(isnull(sdh.internal_deal_type_value_id,-999999)) 
			FROM #sdh h inner join source_deal_header sdh on h.id=sdh.source_deal_header_id
				inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
				left join source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id and sdd.curve_id is not null
			group by sdd.source_deal_detail_id
			
		END
		
	-- changed for EOD	
		IF ISNULL(@call_from,0)=0 --not call from eod  
		BEGIN  
			--capture details on jobs
			--INSERT INTO @currently_running_jobs
			--EXECUTE master.dbo.xp_sqlagent_enum_jobs 1,''

			IF  not EXISTS (SELECT a.job_id FROM dbo.farrms_sysjobactivity a INNER JOIN  msdb.dbo.sysjobs_view b ON a.job_id=b.job_id WHERE b.name like db_name()+'- Calc Position Breakdown%' AND a.stop_execution_date IS NULL  
				AND a.start_execution_date IS NOT NULL -- AND a.run_requested_date IS NOT NULL
				)
				--IF  not EXISTS (SELECT 1 FROM  @currently_running_jobs rJOB  INNER JOIN [msdb].[dbo].[sysjobs_view] AS [sJOB] ON rJOB.[job_id] = [sJOB].[job_id] 
				--					WHERE [sJOB].name like db_name()+'- Calc Position Breakdown%' AND running=1 and next_run_date=0)
				BEGIN   
					SET @spa = 'spa_update_deal_total_volume null,null,0,1,''' + @user_login_id + ''',''n'',1, ' + ISNULL('''' + @call_from_2 + '''', 'NULL') + '' 
					select @job_name= db_name()+'- Calc Position Breakdown'+@process_id
					EXEC spa_run_sp_as_job @job_name,  @spa, 'FARRMS - Calc Position Breakdown', @user_login_id
			
				--EXEC dbo.spa_run_existing_job N'FARRMS - Calc Position Breakdown'
				END   
			RETURN
		END
		ELSE  --call from eod  
		BEGIN  
			SET @call_from=1  
			GOTO begin_update  
		END   
	END--isnull(@call_from,0)IN (0,2)
	ELSE 
	BEGIN
		--return
		set @exit=0

		IF OBJECT_ID(@effected_deals) IS NOT NULL
			exec('DROP TABLE '+@effected_deals)
			
		set @sql='create TABLE '+@effected_deals +'	(source_deal_detail_id int,source_deal_header_id int,create_user varchar(50),insert_type int,deal_type int,commodity_id int,fixation int)'
		
		exec(@sql)
			
		set @sql='
		UPDATE top(10000) process_deal_position_breakdown with (ROWLOCK) SET process_status=1 
		output 
			inserted.source_deal_detail_id,inserted.source_deal_header_id,INSERTED.create_user,q.insert_type,q.deal_type,q.commodity_id ,q.fixation
			into '+@effected_deals +' 
		from process_deal_position_breakdown p inner join 
		(
			select top 1 insert_type ,deal_type ,commodity_id ,fixation from process_deal_position_breakdown 
			where ISNULL(process_status,0)=0 and internal_deal_type_value_id NOT IN(19,20,21)
			group by insert_type ,deal_type ,commodity_id ,fixation
			order by insert_type ,deal_type ,commodity_id ,fixation desc 
		) q on p.insert_type =q.insert_type and p.deal_type=q.deal_type  and p.commodity_id =q.commodity_id and p.fixation=q.fixation
		where ISNULL(p.process_status,0)=0 AND p.internal_deal_type_value_id NOT IN(19,20,21)'
			
		EXEC spa_print @sql
		exec(@sql)


		IF @@ROWCOUNT<1
			set @exit=1
			
		set @sql='
			UPDATE process_deal_position_breakdown with (ROWLOCK) SET process_status=1 
			output inserted.source_deal_detail_id,inserted.source_deal_header_id,INSERTED.create_user,inserted.insert_type,inserted.deal_type,inserted.commodity_id ,inserted.fixation into '+@effected_deals +' 
		--	from process_deal_position_breakdown p
			where ISNULL(process_status,0)=0 AND internal_deal_type_value_id IN (19,20,21)'
			
		EXEC spa_print @sql
		exec(@sql)

		IF @@ROWCOUNT<1 and @exit=1
			RETURN
			
	END --else isnull(@call_from,0)IN (0,2)
	
	set @sql='INSERT INTO #tmp_header_deal_id_1 (source_deal_detail_id,source_deal_header_id,create_user) 
		select  source_deal_detail_id,max(source_deal_header_id),max(create_user) from '+@effected_deals +'
		GROUP BY source_deal_detail_id'
		
	EXEC spa_print @sql
	EXEC(@sql)		

	EXEC('CREATE INDEX indx_tmp_header_deal_id_1_qqq ON #tmp_header_deal_id_1(source_deal_detail_id,source_deal_header_id)')
END	

-------End collecting deal to process-----------------------------------------------------------------------------------------------
------------------
if object_id('tempdb..#density_multiplier_1') is not null 
	drop table #density_multiplier_1

CREATE TABLE #density_multiplier_1 (
	source_deal_detail_id INT,physical_density_mult NUMERIC(38,16),financial_density_mult NUMERIC(38, 16)
)



insert into #density_multiplier_1 (source_deal_detail_id,physical_density_mult,financial_density_mult)
select distinct sdd.source_deal_detail_id,isnull(cf_p1.factor,cf_p.factor),cf_f.factor
from #tmp_header_deal_id_1 sdh inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
	left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id --and spcd.conversion_value_id
	left join source_minor_location sml on sml.source_minor_location_id=sdd.location_id and sml.conversion_value_id is not null
	left join forecast_profile fp on fp.profile_id=COALESCE(sdd.profile_id,sml.profile_id,sml.proxy_profile_id)
	left join [dbo].[conversion_factor] h_p on h_p.conversion_value_id=sml.conversion_value_id	
		and h_p.from_uom=sdd.deal_volume_uom_id and h_p.to_uom=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id)
	left join [dbo].[conversion_factor] h_p1 on h_p1.conversion_value_id=sml.conversion_value_id	
		and h_p1.from_uom=fp.uom_id and h_p1.to_uom=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id)
	left join [dbo].[conversion_factor] h_f on h_f.conversion_value_id=spcd.conversion_value_id
		and h_f.from_uom=sdd.deal_volume_uom_id and h_f.to_uom=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id)
	outer apply
	(
		select max(d.effective_date) effective_date from  [conversion_factor_detail] d where d.conversion_factor_id=h_p.conversion_factor_id
			and d.effective_date<=sdd.term_start
	) cf_p_date
	outer apply
	(
		select max(d.effective_date) effective_date from [dbo].[conversion_factor_detail] d where d.conversion_factor_id=h_p1.conversion_factor_id
			and d.effective_date<=sdd.term_start
	) cf_p1_date
	outer apply
	(

		select max(d.effective_date) effective_date from [dbo].[conversion_factor_detail] d where d.conversion_factor_id=h_f.conversion_factor_id
			and d.effective_date<=sdd.term_start
	) cf_f_date
	left join [dbo].[conversion_factor_detail] cf_p on cf_p.conversion_factor_id=h_p.conversion_factor_id
		and cf_p.effective_date=cf_p_date.effective_date
	left join [dbo].[conversion_factor_detail] cf_p1 on cf_p1.conversion_factor_id=h_p1.conversion_factor_id
		and cf_p1.effective_date=cf_p1_date.effective_date
	left join dbo.[conversion_factor_detail] cf_f on cf_f.conversion_factor_id=h_f.conversion_factor_id
		and cf_f.effective_date=cf_f_date.effective_date

update ed set dst_group_value_id=isnull(tz.dst_group_value_id, @default_dst_group)
FROM source_deal_detail sdd
	INNER JOIN #tmp_header_deal_id_1 ed ON ed.source_deal_detail_id = sdd.source_deal_detail_id 
	left join dbo.vwDealTimezone tz  on  tz.source_deal_header_id=sdd.source_deal_header_id
		and tz.curve_id=isnull(sdd.curve_id,-1)  and tz.location_id=isnull(sdd.location_id,-1) 


/*
set @sql='
insert into	 #deal_detail_dst_group(deal_detail_id ,dst_group_value_id)
select sdd.source_deal_detail_id,	isnull(tz.dst_group_value_id, '+@default_dst_group+')
FROM '+ @source_deal_detail +' sdd  with (nolock)
INNER JOIN #tmp_header_deal_id_1 ed  with (nolock) ON ed.source_deal_header_id = sdd.source_deal_header_id 
left join dbo.vwDealTimezone tz on  sdd.source_deal_header_id=tz.source_deal_header_id
	and tz.curve_id=isnull(sdd.curve_id,-1)  and tz.location_id=isnull(sdd.location_id,-1) 
'

EXEC spa_print @sql
EXEC(@sql)
*/
BEGIN TRY
	--BEGIN TRAN
------------------------	
	
	--IF ISNULL(@insert_type,0)=0 --If clause is removed since the @insert_type passed is 12 instead of 0 to show delta value
	--BEGIN


	if object_id('tempdb..#position_report_group_map') is not null
		drop table #position_report_group_map

	select 
		sdd.source_deal_detail_id
		,isnull(sdd.curve_id,-1) curve_id
		,isnull(sdd.location_id,-1) location_id
		,coalesce(spcd.commodity_id,sdh.commodity_id,-1) commodity_id
		,isnull(sdh.counterparty_id,-1) counterparty_id
		,isnull(sdh.trader_id,-1) trader_id
		,isnull(sdh.contract_id,-1) contract_id
		,ssbm.book_deal_type_map_id subbook_id
		,coalesce(sdd.position_uom,spcd.display_uom_id,spcd.uom_id,-1) deal_volume_uom_id
		,isnull(sdh.deal_status,-1) deal_status_id
		,isnull(sdh.source_deal_type_id,-1) deal_type 
		,isnull(sdh.pricing_type,-1) pricing_type
		,isnull(sdh.internal_portfolio_id,-1) internal_portfolio_id
		,isnull(sdd.physical_financial_flag,'p') physical_financial_flag
	into #position_report_group_map
	FROM  source_deal_header sdh  
		INNER JOIN source_deal_detail sdd  ON sdh.source_deal_header_id=sdd.source_deal_header_id 
		INNER JOIN #tmp_header_deal_id_1 thdi on sdd.source_deal_detail_id=thdi.source_deal_detail_id
		INNER JOIN source_system_book_map ssbm  on sdh.source_system_book_id1=ssbm.source_system_book_id1
			and sdh.source_system_book_id2=ssbm.source_system_book_id2 and sdh.source_system_book_id3=ssbm.source_system_book_id3
			and sdh.source_system_book_id4=ssbm.source_system_book_id4
		LEFT JOIN source_price_curve_def spcd  ON spcd.source_curve_def_id=sdd.curve_id

	insert into dbo.position_report_group_map (
		curve_id
		,location_id
		,commodity_id
		,counterparty_id
		,trader_id
		,contract_id
		,subbook_id
		--,deal_volume_uom_id
		,deal_status_id
		,deal_type 
		,pricing_type
		,internal_portfolio_id
		,physical_financial_flag
	)
	select distinct 
		isnull(s.curve_id,-1)
		,isnull(s.location_id,-1)
		,isnull(s.commodity_id,-1)
		,isnull(s.counterparty_id,-1)
		,isnull(s.trader_id,-1)
		,isnull(s.contract_id,-1)
		,isnull(s.subbook_id,-1)
		--,s.deal_volume_uom_id
		,isnull(s.deal_status_id,-1)
		,isnull(s.deal_type,-1)
		,isnull(s.pricing_type,-1)
		,isnull(s.internal_portfolio_id,-1)
		,isnull(s.physical_financial_flag,'p')
	from #position_report_group_map s 
		left join position_report_group_map d on s.curve_id=d.curve_id
			and s.location_id=d.location_id
			and s.commodity_id=d.commodity_id
			and s.counterparty_id=d.counterparty_id
			and s.trader_id=d.trader_id
			and s.contract_id=d.contract_id
			and s.subbook_id=d.subbook_id
			--and s.deal_volume_uom_id=d.deal_volume_uom_id
			and s.deal_status_id=d.deal_status_id
			and s.deal_type =d.deal_type
			and s.pricing_type=d.pricing_type
			and s.internal_portfolio_id=d.internal_portfolio_id
			and s.physical_financial_flag=d.physical_financial_flag
	where d.rowid is null

	update thdi set rowid=d.rowid
	from #tmp_header_deal_id_1 thdi 
		inner join #position_report_group_map s on s.source_deal_detail_id=thdi.source_deal_detail_id
		inner join position_report_group_map d  on s.curve_id=d.curve_id
			and s.location_id=d.location_id
			and s.commodity_id=d.commodity_id
			and s.counterparty_id=d.counterparty_id
			and s.trader_id=d.trader_id
			and s.contract_id=d.contract_id
			and s.subbook_id=d.subbook_id
			--and s.deal_volume_uom_id=d.deal_volume_uom_id
			and s.deal_status_id=d.deal_status_id
			and s.deal_type =d.deal_type
			and s.pricing_type=d.pricing_type
			and s.internal_portfolio_id=d.internal_portfolio_id
			and s.physical_financial_flag=d.physical_financial_flag


	delete sddp
	from source_deal_detail_position sddp 
		inner join #tmp_header_deal_id_1 ed ON ed.source_deal_detail_id = sddp.source_deal_detail_id
		
	--update for fixed deal
	SET @sql='
	insert into source_deal_detail_position(source_deal_detail_id,total_volume,hourly_position,position_report_group_map_rowid)
	select	ed.source_deal_detail_id
		,round(cast(CAST(sdd.deal_volume AS NUMERIC(24,10))
		*cast(term_factor.factor AS NUMERIC(24,10)) AS NUMERIC(24,10)) ,isnull(rnd.position_calc_round,100))
		*cast(cast(CAST(ISNULL(sdd.multiplier,1) AS NUMERIC(24,16)) AS NUMERIC(24,16))*CAST(ISNULL(sdd.volume_multiplier2,1) AS NUMERIC(24,16)) AS NUMERIC(24,16)) * CAST(COALESCE(case when sdd.physical_financial_flag=''p'' then dm.physical_density_mult else dm.financial_density_mult end,conv.conversion_factor,1) AS NUMERIC(24,16)) total_volume
		,cast(CAST(sdd.deal_volume AS NUMERIC(24,10))/cast(nullif(term_factor.factor,0) AS NUMERIC(24,10)) AS NUMERIC(24,10)) 
		*cast(cast(CAST(ISNULL(sdd.multiplier,1) AS NUMERIC(24,16)) AS NUMERIC(24,16))*CAST(ISNULL(sdd.volume_multiplier2,1) AS NUMERIC(24,16)) AS NUMERIC(24,16)) * CAST(COALESCE(case when sdd.physical_financial_flag=''p'' then dm.physical_density_mult else dm.financial_density_mult end,conv.conversion_factor,1) AS NUMERIC(24,16)) hourly_position
		,ed.rowid position_report_group_map_rowid
	FROM '+ @source_deal_detail +' sdd
		INNER JOIN #tmp_header_deal_id_1 ed ON ed.source_deal_detail_id = sdd.source_deal_detail_id 
		INNER JOIN '+@source_deal_header +' sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id and ISNULL(sdh.internal_desk_id,17300)=17300 --and ISNULL(sdh.product_id,-1)<>9501
		LEFT JOIN source_price_curve_def spcd  ON spcd.source_curve_def_id = sdd.curve_id 
		outer apply ( SELECT sum( volume_mult) volume_mult FROM hour_block_term where
	 		dst_group_value_id=isnull(ed.dst_group_value_id,'+@default_dst_group+')
			AND block_define_id = COALESCE(spcd.block_define_id, sdh.block_define_id,'+@baseload_block_define_id+')
			and term_date BETWEEN sdd.term_start AND sdd.term_end 
		) vft
		LEFT JOIN rec_volume_unit_conversion conv  ON conv.from_source_uom_id=sdd.deal_volume_uom_id
			AND to_source_uom_id=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id)
		LEFT JOIN #density_multiplier_1 dm on dm.source_deal_detail_id =sdd.source_deal_detail_id 
		outer apply (
			select top(1) position_calc_round from deal_default_value where isnull(deal_type_id,-1)=COALESCE(sdh.source_deal_type_id,deal_type_id,-1)
			--and isnull(pricing_type,-1)=COALESCE(sdd.pricing_type,pricing_type,-1)
			 and commodity=COALESCE(sdd.detail_commodity_id,sdh.commodity_id,spcd.commodity_id) and buy_sell_flag=isnull(sdd.buy_sell_flag,buy_sell_flag)
		) rnd
		outer apply
		(
		select	CASE sdd.deal_volume_frequency when ''h'' then vft.volume_mult 		
			when ''x'' then vft.volume_mult*case when sdd.deal_volume_uom_id in ('+@mw_uoms+') then 1 else 4.00 end  --15 minute
			when ''y'' then vft.volume_mult*case when sdd.deal_volume_uom_id in ('+@mw_uoms+') then 0.5 else 2.00 end --30 minute
			when ''d'' then datediff(day,term_start,term_end)+1 
			when ''t'' then 1 
			when ''m'' then 
				case when  day(term_start)=1 and day(term_end+1)=1 then datediff(month,term_start,term_end+1)
				else cast(datediff(day,term_start,term_end)+1 as numeric(30,20))/datediff(day,cast(dbo.FNAGetContractMonth(term_start) as datetime),dateadd(month,1,cast(dbo.FNAGetContractMonth(term_start) as datetime)))
				end
			when ''a'' then 
				case when datediff(month,term_start,term_end+1)%12=0 then datediff(year,term_start,term_end+1)
				else cast(datediff(day,term_start,term_end)+1 as numeric(30,20))/datediff(day,cast(cast(year(term_start) as varchar)+''-01-01'' as datetime),cast(cast(year(term_start)+1 as varchar)+''-01-01'' as datetime))
				end
			when ''w'' then cast(datediff(day,term_start,term_end)+1 as numeric(30,20))/7
			when ''q'' then 
				case when datediff(month,term_start,term_end+1)%3=0 then datediff(qq,term_start,term_end+1)
				else cast(datediff(day,term_start,term_end)+1 as numeric(30,20))/datediff(day,convert(datetime,cast(year(term_start) as varchar) +''-''+cast((DATEPART(qq,term_start) *3)-2 AS VARCHAR)+''-01'',120),dateadd(month,1,convert(datetime,cast(year(term_start) as varchar) +''-''+cast((DATEPART(qq,term_start) *3) AS VARCHAR)+''-01'',120)))
			end 
		end factor
	) term_factor
	left join source_deal_detail_position ext on ext.source_deal_detail_id=sdd.source_deal_detail_id
	where sdd.position_formula_id is null and ext.source_deal_detail_id is null
	'
	
	EXEC dbo.spa_print @sql
	EXEC(@sql)	
	
		--update fixing deal total_volume by its deal_volume
	/*	SET @sql=' UPDATE sdd with (rowlock)
				SET total_volume =sdd.deal_volume
		FROM '+ @source_deal_detail +' sdd  with (rowlock)
		INNER JOIN '+@source_deal_header +' sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id 
			and ISNULL(sdh.internal_desk_id,17300)=17300	
			and ISNULL(sdh.product_id,-1)=9501
		INNER JOIN '+ @effected_deals + ' ed ON ed.source_deal_header_id = sdh.source_deal_header_id 
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id 
		'
		EXEC dbo.spa_print @sql
		EXEC(@sql)		
		
	*/

		--update for shaped deal
	SET @sql='	
	insert into source_deal_detail_position(source_deal_detail_id,total_volume,hourly_position,position_report_group_map_rowid)
	select	ed.source_deal_detail_id
		,round(CAST(COALESCE(case when sdd.physical_financial_flag=''p'' then dm.physical_density_mult else dm.financial_density_mult end,conv.conversion_factor,1) AS NUMERIC(24,16))*	CAST(isnull(sddh.vol_hr,0) AS NUMERIC(22,10))*cast(CAST(ISNULL(sdd.multiplier,1) AS NUMERIC(24,16)) *CAST(ISNULL(sdd.volume_multiplier2,1) AS NUMERIC(24,16))  AS NUMERIC(24,16))
		* case  when sdd.deal_volume_frequency =''x'' and sdd.deal_volume_uom_id in ('+@mw_uoms+') then 0.25 
				when sdd.deal_volume_frequency =''y'' and sdd.deal_volume_uom_id in ('+@mw_uoms+') then 0.5 
		else 1.00 end,isnull(rnd.position_calc_round,100)) total_volume
		,null hourly_position
		,ed.rowid position_report_group_map_rowid
	FROM '+ @source_deal_detail +' sdd
		INNER JOIN #tmp_header_deal_id_1 ed ON ed.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN '+@source_deal_header +' sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id and ISNULL(sdh.internal_desk_id,17300)=17302 
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id 
		OUTER APPLY 
			(SELECT sum(volume) vol_hr FROM source_deal_detail_hour
				WHERE source_deal_detail_id=sdd.source_deal_detail_id  and isnull(volume,0)<>0
			) sddh
		LEFT JOIN rec_volume_unit_conversion conv ON conv.from_source_uom_id=sdd.deal_volume_uom_id
			AND to_source_uom_id=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id)		
		LEFT JOIN #density_multiplier_1 dm on dm.source_deal_detail_id =sdd.source_deal_detail_id 
		outer apply (
			select top(1) position_calc_round from deal_default_value where isnull(deal_type_id,-1)=COALESCE(sdh.source_deal_type_id,deal_type_id,-1)
			--and isnull(pricing_type,-1)=COALESCE(sdd.pricing_type,pricing_type,-1)
			 and commodity=COALESCE(sdd.detail_commodity_id,sdh.commodity_id,spcd.commodity_id) and buy_sell_flag=isnull(sdd.buy_sell_flag,buy_sell_flag)
		) rnd
		left join source_deal_detail_position ext on ext.source_deal_detail_id=sdd.source_deal_detail_id
		where sdd.position_formula_id is null and  ext.source_deal_detail_id is null
		'
	EXEC dbo.spa_print @sql
	EXEC(@sql)	
			
	IF ISNULL(@orginal_insert_type,0)=12
	BEGIN
		SET @insert_type=0
	end

	-- performance _tuning
	SELECT DISTINCT sdd.source_deal_detail_id
		,spcd.commodity_id
		,ISNULL(sdd.profile_id,sml.profile_id) profile_id
		,fp1.profile_type profile_type1
		,fp.profile_type
		,isnull(ed.dst_group_value_id,@default_dst_group) dst_group_value_id ,sml.proxy_profile_id
		,isnull(spcd.block_define_id,@baseload_block_define_id) block_define_id
		,sdd.term_start
		,sdd.term_end
	into #profile_info -- select * from #profile_info
	FROM source_minor_location sml  
			inner join source_deal_detail sdd  on sdd.location_id=sml.source_minor_location_id and sdd.position_formula_id is null
			inner join #tmp_header_deal_id_1 ed  on sdd.source_deal_detail_id=ed.source_deal_detail_id
			left join [forecast_profile] fp  on fp.profile_id =ISNULL(sdd.profile_id,sml.profile_id)
			left join [forecast_profile] fp1  on fp1.profile_id =sml.proxy_profile_id  
			left join source_price_curve_def spcd  on spcd.source_curve_def_id=sdd.curve_id

	if object_id(@tmp_location_profile) is not null
	exec('drop table '+@tmp_location_profile)

	SET @sql='	
		SELECT 
			prof.source_deal_detail_id
			,case when ddh.vol is null or (prof.commodity_id=-1 and ddh.vol=0) then COALESCE(prof.proxy_profile_id,prof.profile_id) else prof.profile_id end  profile_id
			,case when ddh.vol is null or (prof.commodity_id=-1 and ddh.vol=0) then isnull(prof.profile_type1,prof.profile_type) else prof.profile_type end profile_type
			,prof.term_start ,prof.term_end ,prof.dst_group_value_id 
		into '+@tmp_location_profile+'
		FROM #profile_info prof
		outer apply
		(
			select max(isnull(d.Hr7,0)+isnull(d.Hr8,0)+isnull(d.Hr9,0)+isnull(d.Hr10,0)
				+isnull(d.Hr11,0)+isnull(d.Hr12,0)
				+isnull(d.Hr13,0)+isnull(d.Hr14,0)+isnull(d.Hr15,0)+isnull(d.Hr16,0)+isnull(d.Hr17,0)+isnull(d.Hr18,0)
				+isnull(d.Hr19,0)+isnull(d.Hr20,0)+isnull(d.Hr21,0)+isnull(d.Hr22,0)+isnull(d.Hr23,0)+isnull(d.Hr24,0)) vol  
			from  deal_detail_hour d where d.profile_id=prof.profile_id and d.term_date between  prof.term_start and prof.term_end
		) ddh
		WHERE case when ddh.vol is null or (prof.commodity_id=-1 and ddh.vol=0) then COALESCE(prof.proxy_profile_id,prof.profile_id) else prof.profile_id end  is not null 
			'
	EXEC dbo.spa_print @sql
	EXEC(@sql)	


	exec('CREATE index indx_tmp_location_profile_location_id on '+@tmp_location_profile+' ([source_deal_detail_id])')
	exec('CREATE index indx_tmp_location_profile_profile_id on '+ @tmp_location_profile+' ([profile_id])')

	IF  OBJECT_ID('tempdb..#deal_term') is not NULL
		DROP TABLE #deal_term




	IF  OBJECT_ID(@ref_location) is not NULL
		exec('DROP TABLE '+@ref_location)
		

	if object_id(@total_yr_fraction) is not null
	exec('drop table '+@total_yr_fraction)


--SELECT source_deal_header_id, product_id FROM source_deal_header WHERE product_id IS NOT null
	SET @sql = '
	SELECT sdd.[source_deal_detail_id],sdd.source_deal_header_id,sdd.leg ,sdd.term_start ,sdd.term_end
		, COALESCE(spcd.block_define_id,sdh.block_define_id,'+@baseload_block_define_id+') block_define_id
		,COALESCE(spcd.block_type,sdh.block_type,12000) block_type,tlp.profile_id,sdd.location_id,sdd.curve_id
		,tlp.profile_type,spcd.commodity_id,sdd.deal_volume_uom_id uom_id,isnull(ed.product_id,4101) fixation
		,ed.source_deal_header_id upd_deal_id,sdd.multiplier,sdd.volume_multiplier2
		,COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id) convert_to_uom_id,tlp.dst_group_value_id
		,rnd.position_calc_round [round],sddp.rowid
	, sdd.physical_financial_flag
	  into #deal_term --- select  * from #deal_term where [source_deal_detail_id]=2322197 
	FROM '+@source_deal_header +' sdh 
		cross apply (
				SELECT  source_deal_header_id, source_deal_header_id close_reference_id ,isnull(product_id,4101)  product_id 
				FROM  '+@source_deal_header +'  where source_deal_header_id=sdh.source_deal_header_id
						and isnull(product_id,4101)<> 4100 --fixation deal logic is handled below. 
				union 
				select  source_deal_header_id, close_reference_id,isnull(product_id,4101) product_id 
				FROM  '+@source_deal_header +' where source_deal_header_id=sdh.source_deal_header_id
					and (close_reference_id is not null or isnull(product_id,4101)= 4100) 
			) ed  
		inner join  #tmp_header_deal_id_1 sddp on sddp.source_deal_header_id=ed.close_reference_id
		inner join ' + @source_deal_detail +' sdd on sdd.source_deal_detail_id=sddp.source_deal_detail_id
		inner join '+@tmp_location_profile+' tlp on tlp.source_deal_detail_id=sdd.source_deal_detail_id 
		left JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id --and spcd.commodity_id=-2 --power
		outer apply (
			select top(1) position_calc_round from deal_default_value where isnull(deal_type_id,-1)=COALESCE(sdh.source_deal_type_id,deal_type_id,-1)
			--and isnull(pricing_type,-1)=COALESCE(sdd.pricing_type,pricing_type,-1) 
			and commodity=COALESCE(sdd.detail_commodity_id,sdh.commodity_id,spcd.commodity_id) and buy_sell_flag=isnull(sdd.buy_sell_flag,buy_sell_flag)
		) rnd
	where ISNULL(sdh.internal_desk_id,17300)=17301;

	CREATE index indx_deal_term1 on  #deal_term([term_start],[term_end]);	
	CREATE index indx_deal_term2 on  #deal_term(block_define_id,block_type)	;
	'	

--sum yearly fraction for the Power profile type=National profile
	SET @sql1 = '
		SELECT	yr.source_deal_header_id,yr.yr,yr.location_id,yr.curve_id,tot_yr.tot_fraction tot_yr_fraction
		into '+@total_yr_fraction+'
		FROM 
		( 
			SELECT distinct [source_deal_header_id],year(term_start) yr ,block_define_id,block_type
				,profile_id,location_id,curve_id,dst_group_value_id FROM #deal_term 
			WHERE commodity_id=-2 and profile_type=17502 and fixation=4101)  yr
			outer apply (
			SELECT  SUM(
				case when ISNULL(hb.hr1,0)=0 then 0 else ISNULL(ddh.Hr1,0) end +
				case when ISNULL(hb.hr2,0)=0 then 0 else ISNULL(ddh.Hr2,0) end +
				case when ISNULL(hb.hr3,0)=0 then 0 else ISNULL(ddh.Hr3,0) end +
				case when ISNULL(hb.hr4,0)=0 then 0 else ISNULL(ddh.Hr4,0) end +
				case when ISNULL(hb.hr5,0)=0 then 0 else ISNULL(ddh.Hr5,0) end +
				case when ISNULL(hb.hr6,0)=0 then 0 else ISNULL(ddh.Hr6,0) end +
				case when ISNULL(hb.hr7,0)=0 then 0 else ISNULL(ddh.Hr7,0) end +
				case when ISNULL(hb.hr8,0)=0 then 0 else ISNULL(ddh.Hr8,0) end +
				case when ISNULL(hb.hr9,0)=0 then 0 else ISNULL(ddh.Hr9,0) end +
				case when ISNULL(hb.hr10,0)=0 then 0 else ISNULL(ddh.Hr10,0) end +
				case when ISNULL(hb.hr11,0)=0 then 0 else ISNULL(ddh.Hr11,0) end +
				case when ISNULL(hb.hr12,0)=0 then 0 else ISNULL(ddh.Hr12,0) end +
				case when ISNULL(hb.hr13,0)=0 then 0 else ISNULL(ddh.Hr13,0) end +
				case when ISNULL(hb.hr14,0)=0 then 0 else ISNULL(ddh.Hr14,0) end +
				case when ISNULL(hb.hr15,0)=0 then 0 else ISNULL(ddh.Hr15,0) end +
				case when ISNULL(hb.hr16,0)=0 then 0 else ISNULL(ddh.Hr16,0) end +
				case when ISNULL(hb.hr17,0)=0 then 0 else ISNULL(ddh.Hr17,0) end +
				case when ISNULL(hb.hr18,0)=0 then 0 else ISNULL(ddh.Hr18,0) end +
				case when ISNULL(hb.hr19,0)=0 then 0 else ISNULL(ddh.Hr19,0) end +
				case when ISNULL(hb.hr20,0)=0 then 0 else ISNULL(ddh.Hr20,0) end +
				case when ISNULL(hb.hr21,0)=0 then 0 else ISNULL(ddh.Hr21,0) end +
				case when ISNULL(hb.hr22,0)=0 then 0 else ISNULL(ddh.Hr22,0) end +
				case when ISNULL(hb.hr23,0)=0 then 0 else ISNULL(ddh.Hr23,0) end +
				case when ISNULL(hb.hr24,0)=0 then 0 else ISNULL(ddh.Hr24,0) end 
			) tot_fraction FROM ' + @deal_detail_hour +'  ddh
			inner join hour_block_term hb ON hb.dst_group_value_id=yr.dst_group_value_id and hb.block_define_id=yr.block_define_id
			and ddh.term_date=hb.term_date and ddh.profile_id=yr.profile_id AND year(ddh.term_date)=yr.yr
				and hb.block_type=yr.block_type
		) tot_yr;'
		
	----term total for power (not GAS)
	SET @sql2 = ' 
		SELECT	sdd.source_deal_detail_id,sdd.source_deal_header_id,sdd.leg,sdd.term_start,tot_term.tot_fraction tot_term_fraction,sdd.profile_type,sdd.commodity_id
		, CAST(COALESCE(case when sdd.physical_financial_flag=''p'' then dm.physical_density_mult else dm.financial_density_mult end,conv.conversion_factor,1) AS NUMERIC(24,16)) conversion_factor,sdd.round,sdd.rowid
		INTO #total_term_fraction
		from (
			SELECT distinct [source_deal_detail_id],source_deal_header_id,leg ,term_start,term_end,block_define_id,block_type
				,profile_id,location_id,curve_id,profile_type,commodity_id,uom_id,fixation,multiplier,volume_multiplier2
				,convert_to_uom_id,dst_group_value_id,[round],rowid ,physical_financial_flag
			from #deal_term 
		) sdd
  		  OUTER APPLY (
				SELECT  sum(case when ISNULL(hb.hr1,0)=0 then 0 else cast(ISNULL(ddh.Hr1,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr2,0)=0 then 0 else cast(ISNULL(ddh.Hr2,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr3,0)=0 then 0 else cast(ISNULL(ddh.Hr3,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr4,0)=0 then 0 else cast(ISNULL(ddh.Hr4,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr5,0)=0 then 0 else cast(ISNULL(ddh.Hr5,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr6,0)=0 then 0 else cast(ISNULL(ddh.Hr6,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr7,0)=0 then 0 else cast(ISNULL(ddh.Hr7,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr8,0)=0 then 0 else cast(ISNULL(ddh.Hr8,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr9,0)=0 then 0 else cast(ISNULL(ddh.Hr9,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr10,0)=0 then 0 else cast(ISNULL(ddh.Hr10,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr11,0)=0 then 0 else cast(ISNULL(ddh.Hr11,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr12,0)=0 then 0 else cast(ISNULL(ddh.Hr12,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr13,0)=0 then 0 else cast(ISNULL(ddh.Hr13,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr14,0)=0 then 0 else cast(ISNULL(ddh.Hr14,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr15,0)=0 then 0 else cast(ISNULL(ddh.Hr15,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr16,0)=0 then 0 else cast(ISNULL(ddh.Hr16,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr17,0)=0 then 0 else cast(ISNULL(ddh.Hr17,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr18,0)=0 then 0 else cast(ISNULL(ddh.Hr18,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr19,0)=0 then 0 else cast(ISNULL(ddh.Hr19,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr20,0)=0 then 0 else cast(ISNULL(ddh.Hr20,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr21,0)=0 then 0 else cast(ISNULL(ddh.Hr21,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr22,0)=0 then 0 else cast(ISNULL(ddh.Hr22,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr23,0)=0 then 0 else cast(ISNULL(ddh.Hr23,0) AS NUMERIC(38,20)) end +
					case when ISNULL(hb.hr24,0)=0 then 0 else cast(ISNULL(ddh.Hr24,0) AS NUMERIC(38,20)) end ) tot_fraction
				FROM ' + @deal_detail_hour +'  ddh
					INNER JOIN hour_block_term hb ON hb.dst_group_value_id=sdd.dst_group_value_id 
						and hb.block_define_id=sdd.block_define_id
						and ddh.term_date=hb.term_date  and ddh.profile_id=sdd.profile_id AND ddh.term_date between sdd.term_start and term_end
			) tot_term 	
			left join forecast_profile fp on fp.profile_id=sdd.profile_id
				left join rec_volume_unit_conversion conv on conv.from_source_uom_id=isnull(fp.uom_id ,sdd.uom_id)
					and conv.to_source_uom_id=sdd.convert_to_uom_id and sdd.profile_type=17500 -- forecaste profile
			LEFT JOIN #density_multiplier_1 dm on dm.source_deal_detail_id =sdd.source_deal_detail_id 
		where  sdd.commodity_id<>-1 AND sdd.fixation=4101; --Original
 '
	----term total for GAS
	
	SET @sql3 = '
		SELECT	sdd.source_deal_detail_id,sdd.source_deal_header_id,sdd.leg,sdd.term_start,tot_term.tot_fraction tot_term_fraction,sdd.profile_type,sdd.commodity_id
			,COALESCE(case when sdd.physical_financial_flag=''p'' then dm.physical_density_mult else dm.financial_density_mult end,conv.conversion_factor,1) conversion_factor,sdd.[round],sdd.rowid
		into #total_term_fraction_gas
		from (
			SELECT distinct [source_deal_detail_id],source_deal_header_id,leg ,term_start,term_end,block_define_id,block_type
				,profile_id,location_id,curve_id,profile_type,commodity_id,uom_id,fixation,multiplier,volume_multiplier2
				,convert_to_uom_id,dst_group_value_id,[round],rowid,physical_financial_flag 
			from #deal_term 
		) sdd
  			OUTER APPLY (
  		  	SELECT sum(tot_fraction) tot_fraction FROM (
				SELECT 
						CASE WHEN hb.term_date=sdd.term_start THEN  0 ELSE
							case when ISNULL(hb.hr1,0)=0 then 0 else cast(ISNULL(ddh.Hr1,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr2,0)=0 then 0 else cast(ISNULL(ddh.Hr2,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr3,0)=0 then 0 else cast(ISNULL(ddh.Hr3,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr4,0)=0 then 0 else cast(ISNULL(ddh.Hr4,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr5,0)=0 then 0 else cast(ISNULL(ddh.Hr5,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr6,0)=0 then 0 else cast(ISNULL(ddh.Hr6,0) AS NUMERIC(38,20)) END 
						end	+
						CASE WHEN hb.term_date=sdd.term_end+1 THEN 0 ELSE 
							case when ISNULL(hb.hr7,0)=0 then 0 else cast(ISNULL(ddh.Hr7,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr8,0)=0 then 0 else cast(ISNULL(ddh.Hr8,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr9,0)=0 then 0 else cast(ISNULL(ddh.Hr9,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr10,0)=0 then 0 else cast(ISNULL(ddh.Hr10,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr11,0)=0 then 0 else cast(ISNULL(ddh.Hr11,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr12,0)=0 then 0 else cast(ISNULL(ddh.Hr12,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr13,0)=0 then 0 else cast(ISNULL(ddh.Hr13,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr14,0)=0 then 0 else cast(ISNULL(ddh.Hr14,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr15,0)=0 then 0 else cast(ISNULL(ddh.Hr15,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr16,0)=0 then 0 else cast(ISNULL(ddh.Hr16,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr17,0)=0 then 0 else cast(ISNULL(ddh.Hr17,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr18,0)=0 then 0 else cast(ISNULL(ddh.Hr18,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr19,0)=0 then 0 else cast(ISNULL(ddh.Hr19,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr20,0)=0 then 0 else cast(ISNULL(ddh.Hr20,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr21,0)=0 then 0 else cast(ISNULL(ddh.Hr21,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr22,0)=0 then 0 else cast(ISNULL(ddh.Hr22,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr23,0)=0 then 0 else cast(ISNULL(ddh.Hr23,0) AS NUMERIC(38,20)) end +
							case when ISNULL(hb.hr24,0)=0 then 0 else cast(ISNULL(ddh.Hr24,0) AS NUMERIC(38,20)) end 
						END tot_fraction
					FROM ' + @deal_detail_hour +'  ddh
						INNER JOIN hour_block_term hb ON  hb.dst_group_value_id=sdd.dst_group_value_id
							and hb.block_define_id=sdd.block_define_id 
							and ddh.term_date=hb.term_date and ddh.profile_id=sdd.profile_id 
							AND ddh.term_date between sdd.term_start and sdd.term_end+1
  		  		) a	
			) tot_term 	
		left join forecast_profile fp on fp.profile_id=sdd.profile_id
		left join rec_volume_unit_conversion conv on conv.from_source_uom_id=isnull(fp.uom_id ,sdd.uom_id)
			and conv.to_source_uom_id=sdd.convert_to_uom_id and sdd.profile_type=17500 -- forecaste profile
		LEFT JOIN #density_multiplier_1 dm on dm.source_deal_detail_id =sdd.source_deal_detail_id 
  and sdd.profile_type=17500
		where sdd.commodity_id=-1 and sdd.fixation=4101; --Original

	insert into #total_term_fraction select * from #total_term_fraction_gas;
	CREATE index indx_total_term_fraction01 on  #total_term_fraction([source_deal_detail_id])	;
	CREATE index indx_total_term_fraction on  #total_term_fraction([source_deal_header_id],leg,term_start)	;
	CREATE index indx_total_yr_fraction on '+@total_yr_fraction+'([source_deal_header_id],location_id,curve_id);

	'
		-- SELECT * FROM static_data_value sdv WHERE TYPE_ID=17500

	SET @sql4 = '
	insert into source_deal_detail_position(source_deal_detail_id,total_volume,hourly_position,position_report_group_map_rowid)
	select term.source_deal_detail_id
		,round(
			CAST(case when term.profile_type=17500 then term.tot_term_fraction * isnull(term.conversion_factor,1)
			else 
				CAST(sdd.standard_yearly_volume AS NUMERIC(24,14)) *
				case when term.commodity_id=-2 and term.profile_type=17502 then ---Power profile type=National profile
					cast(cast(term.tot_term_fraction AS NUMERIC(22,14))/cast(nullif(yr.tot_yr_fraction,0) AS NUMERIC(22,14)) AS NUMERIC(18,8))
				else cast(case when term.tot_term_fraction>100 then 100 else term.tot_term_fraction end  AS NUMERIC(14,10)) end
			END  AS NUMERIC(22,10))* CAST(COALESCE(case when sdd.physical_financial_flag=''p'' then dm.physical_density_mult else dm.financial_density_mult end,conv.conversion_factor,1) AS NUMERIC(24,16))
			* cast(CAST(ISNULL(sdd.multiplier,1)  AS NUMERIC(24,16))*CAST(ISNULL(sdd.volume_multiplier2,1) AS NUMERIC(24,16))  AS NUMERIC(24,16))
			* case when sdd.deal_volume_frequency = ''x'' and sdd.deal_volume_uom_id in ('+@mw_uoms+') then 0.25
				when sdd.deal_volume_frequency =''y'' and sdd.deal_volume_uom_id in ('+@mw_uoms+') then 0.5
				else 1.00
			end,isnull(term.round,100))
		,null hourly_position,term.rowid position_report_group_map_rowid
	FROM '+ @source_deal_detail +'  sdd
		INNER JOIN #total_term_fraction term on sdd.source_deal_detail_id=term.source_deal_detail_id
		LEFT JOIN  '+@total_yr_fraction+' yr on term.[source_deal_header_id]=yr.source_deal_header_id and yr.yr=year(term.term_start) 
			and sdd.location_id=yr.location_id and sdd.curve_id =yr.curve_id and term.profile_type<>17500
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id	
		LEFT JOIN rec_volume_unit_conversion conv on conv.from_source_uom_id=sdd.deal_volume_uom_id 
			and conv.to_source_uom_id=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id)
		LEFT JOIN #density_multiplier_1 dm on dm.source_deal_detail_id =sdd.source_deal_detail_id 
		left join source_deal_detail_position ext on ext.source_deal_detail_id=sdd.source_deal_detail_id
	where sdd.position_formula_id is null and ext.source_deal_detail_id is null;
	' 
			
--	return	

---------------------------------------------------------------------------------------
------ UPdate the total volume for forecasted deals with deal volume whose forecast does not exists
---------------------------------------------------------------------------------------
	SET @sql5=' 
	insert into source_deal_detail_position(source_deal_detail_id,total_volume,hourly_position,position_report_group_map_rowid)
	select ed.source_deal_detail_id
		,round(cast(CAST(sdd.deal_volume AS NUMERIC(24,10)) * 
		cast(term_factor.factor AS NUMERIC(24,10)) AS NUMERIC(24,10)) *cast(CAST(ISNULL(sdd.multiplier,1) AS NUMERIC(24,16))
		*CAST(ISNULL(sdd.volume_multiplier2,1) AS NUMERIC(24,16)) AS NUMERIC(24,16))
		* CAST(COALESCE(case when sdd.physical_financial_flag=''p'' then dm.physical_density_mult else dm.financial_density_mult end,conv.conversion_factor,1) AS NUMERIC(24,16)),isnull(rnd.position_calc_round,100))
		,cast(CAST(sdd.deal_volume AS NUMERIC(24,10))/cast(nullif(term_factor.factor,0) AS NUMERIC(24,10)) AS NUMERIC(24,10)) 
		*cast(CAST(ISNULL(sdd.multiplier,1) AS NUMERIC(24,16))*CAST(ISNULL(sdd.volume_multiplier2,1) AS NUMERIC(24,16)) AS NUMERIC(24,16))
		* CAST(COALESCE(case when sdd.physical_financial_flag=''p'' then dm.physical_density_mult else dm.financial_density_mult end,conv.conversion_factor,1) AS NUMERIC(24,16))
		,ed.rowid position_report_group_map_rowid
	FROM '+ @source_deal_detail +' sdd
		INNER JOIN #tmp_header_deal_id_1 ed  ON ed.source_deal_detail_id = sdd.source_deal_detail_id 
		INNER JOIN '+@source_deal_header +' sdh  ON sdh.source_deal_header_id = sdd.source_deal_header_id 
			and ISNULL(sdh.internal_desk_id,17300)=17301
		LEFT JOIN source_price_curve_def spcd  ON spcd.source_curve_def_id = sdd.curve_id 
		outer apply ( SELECT sum(volume_mult) volume_mult FROM hour_block_term where
			 dst_group_value_id=isnull(ed.dst_group_value_id,'+@default_dst_group+') AND block_define_id = COALESCE(spcd.block_define_id, sdh.block_define_id,'+@baseload_block_define_id+') and term_date BETWEEN sdd.term_start AND sdd.term_end
		) vft
		LEFT JOIN rec_volume_unit_conversion conv  ON conv.from_source_uom_id=sdd.deal_volume_uom_id
			AND to_source_uom_id=COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id)
		LEFT JOIN #density_multiplier_1 dm on dm.source_deal_detail_id =sdd.source_deal_detail_id 
		LEFT JOIN (SELECT source_deal_detail_id FROM #total_term_fraction GROUP BY source_deal_detail_id) tt
			ON tt.source_deal_detail_id = sdd.source_deal_detail_id
		outer apply (
			select top(1) position_calc_round from deal_default_value where isnull(deal_type_id,-1)=COALESCE(sdh.source_deal_type_id,deal_type_id,-1)
			--and isnull(pricing_type,-1)=COALESCE(sdd.pricing_type,pricing_type,-1) 
			and commodity=COALESCE(sdd.detail_commodity_id,sdh.commodity_id,spcd.commodity_id) and buy_sell_flag=isnull(sdd.buy_sell_flag,buy_sell_flag)
		) rnd
		outer apply (
		select	CASE sdd.deal_volume_frequency when ''h'' then vft.volume_mult 
			when ''d'' then datediff(day,term_start,term_end)+1 
			when ''x'' then vft.volume_mult*case when sdd.deal_volume_uom_id in ('+@mw_uoms+') then 4.00 else 0.25 end  --15 minute
			when ''y'' then vft.volume_mult*case when sdd.deal_volume_uom_id in ('+@mw_uoms+') then 2.00 else 0.5 end --30 minute
			when ''t'' then 1 
			when ''m'' then 
				case when  day(term_start)=1 and day(term_end+1)=1 then datediff(month,term_start,term_end+1)
				else cast(datediff(day,term_start,term_end)+1 as numeric(30,20))/datediff(day,cast(dbo.FNAGetContractMonth(term_start) as datetime),dateadd(month,1,cast(dbo.FNAGetContractMonth(term_start) as datetime)))
				end
			when ''a'' then 
				case when datediff(month,term_start,term_end+1)%12=0 then datediff(year,term_start,term_end+1)
				else cast(datediff(day,term_start,term_end)+1 as numeric(30,20))/datediff(day,cast(cast(year(term_start) as varchar)+''-01-01'' as datetime),cast(cast(year(term_start)+1 as varchar)+''-01-01'' as datetime))
				end
			when ''w'' then cast(datediff(day,term_start,term_end)+1 as numeric(30,20))/7
			when ''q'' then 
				case when datediff(month,term_start,term_end+1)%3=0 then datediff(qq,term_start,term_end+1)
				else cast(datediff(day,term_start,term_end)+1 as numeric(30,20))/datediff(day,convert(datetime,cast(year(term_start) as varchar) +''-''+cast((DATEPART(qq,term_start) *3)-2 AS VARCHAR)+''-01'',120),dateadd(month,1,convert(datetime,cast(year(term_start) as varchar) +''-''+cast((DATEPART(qq,term_start) *3) AS VARCHAR)+''-01'',120)))
				end
		end factor
	) term_factor
	left join source_deal_detail_position ext on ext.source_deal_detail_id=sdd.source_deal_detail_id
	WHERE tt.source_deal_detail_id IS NULL and sdd.position_formula_id is null and ext.source_deal_detail_id is null;
	'

--SELECT * FROM static_data_value sdv WHERE TYPE_ID=17500


--Fixation logic start--------------------------------------------------
----------------------------------------------------------------------------

	SET @sql6='
		-- need to discuss in order to add this code ???????????

		--select d.source_deal_detail_id,a.audit_id,sddp.total_volume
		--into #tmp_deal_detail_audit
		--FROM #tmp_header_deal_id_1 d 
		--	INNER JOIN source_deal_detail_position sddp ON sddp.source_deal_detail_id = d.source_deal_detail_id	
		--	cross apply (
		--		select max(audit_id) audit_id from source_deal_detail_audit where  source_deal_detail_id=d.source_deal_detail_id
		--	 ) a 

		--create index indx_tmp_deal_detail_audit_001 on #tmp_deal_detail_audit (source_deal_detail_id,audit_id) include (total_volume);

		--UPDATE sdda
		--	SET sdda.total_volume = a.total_volume
		--		--,sdda.position_uom = a.position_uom
		--FROM source_deal_detail_audit sdda
		--	inner join #tmp_deal_detail_audit a
		--	 on sdda.source_deal_detail_id=a.source_deal_detail_id and sdda.audit_id= a.audit_id;

		SELECT	
		distinct sdd.source_deal_header_id,sdd.location_id,sdd.profile_id,sdd.upd_deal_id fixation_deal_id,sdd.multiplier,sdd.volume_multiplier2,sdd.curve_id
		into '+ @ref_location+'
		FROM #deal_term sdd where  sdd.fixation=4100 --fixed deal only

	'

	EXEC dbo.spa_print @sql
	EXEC dbo.spa_print @sql1
	EXEC dbo.spa_print @sql2
	EXEC dbo.spa_print @sql3
	EXEC dbo.spa_print @sql4
	EXEC dbo.spa_print @sql5
	EXEC dbo.spa_print @sql6
	
	EXEC(@sql+@sql1+@sql2+@sql3+@sql4+@sql5+@sql6)
	--return


	run_job_breakdown:
	--Populate report tables
	IF ISNULL(@insert_type,0)=0 AND isnull(@insert_process_table,'n')='n'
	BEGIN		
	
	--	EXEC [dbo].[spa_deal_position_breakdown] 'u', null, @user_login_id, @process_id
		SET @spa='EXEC spa_maintain_transaction_job ''' +@process_id +''','+cast(@orginal_insert_type AS VARCHAR)+',null,'''+@user_login_id+''''
		--EXEC spa_run_sp_as_job @process_id,@spa , 'generating_report_table',@user_login_id
		

		print '#########################################################################################'
			print @spa
		print '#########################################################################################'

		EXEC(@spa)
		 
	END

--IF @@TRANCOUNT>0
--	COMMIT TRAN

IF isnull(@call_from,0)=1
BEGIN
	delete dbo.process_deal_position_breakdown WHERE process_status=1
	IF EXISTS(SELECT 1 FROM dbo.process_deal_position_breakdown WHERE process_status=0)
	BEGIN 
		
		GOTO begin_update
		--SET @spa = 'dbo.spa_run_existing_job ''FARRMS - Calc Position Breakdown'''
		--EXEC spa_run_sp_as_job 'Run_FARRMS - Calc Position Breakdown',  @spa, 'Run_FARRMS - Calc Position Breakdown', 'farrms_admin'
		--exec(@spa)
	END 
END
-- alert call
DECLARE @alert_process_table VARCHAR(300)
SET @alert_process_table = 'adiha_process.dbo.alert_deal_' + @process_id + '_ad'

EXEC ('CREATE TABLE ' + @alert_process_table + ' (
       	source_deal_header_id  VARCHAR(500),
       	deal_date              DATETIME,
       	term_start             DATETIME,
       	counterparty_id        VARCHAR(100),
       	hyperlink1             VARCHAR(5000),
       	hyperlink2             VARCHAR(5000),
       	hyperlink3             VARCHAR(5000),
       	hyperlink4             VARCHAR(5000),
       	hyperlink5             VARCHAR(5000)
       )')
SET @sql = 'INSERT INTO ' + @alert_process_table + '
(
	source_deal_header_id,
	deal_date,
	term_start,
	counterparty_id
)
SELECT sdh.source_deal_header_id,
	sdh.deal_date,
	sdh.entire_term_start,
	sdh.counterparty_id
FROM   source_deal_header sdh WHERE sdh.source_deal_header_id IN (SELECT source_deal_header_id from ' + @effected_deals + ')'
IF ISNULL(@call_from_2, '') <> 'alert'
BEGIN
	EXEC(@sql)
	EXEC spa_print @sql
	EXEC spa_register_event 20601, 20509, @alert_process_table, 1, @process_id
END

END TRY
BEGIN CATCH
	EXEC spa_print 'ERROR found '
	--IF @@TRANCOUNT>0
	--	ROLLBACK TRAN

	SET @err_status='e'
	DECLARE @err_no INT,@err_msg VARCHAR(1000)
	SELECT  @err_no= ERROR_NUMBER() ,@err_msg=ERROR_MESSAGE()
	EXEC spa_print @err_msg
	select @remarks='Err#:'+cast(@err_no AS VARCHAR)+ ';  Error:'+REPLACE(@err_msg,'''','''''')
	SET @err_msg=REPLACE(@err_msg,'''','')

	IF ISNULL(@insert_type,0) NOT IN (1,2) -- not FOR import
	BEGIN
		--539:Schema changed after the target table was created. Rerun the Select Into query.
		--1205:Transaction was deadlocked on lock resources with another process and has been chosen as the deadlock victim
		 --IF @err_no=1205 OR @err_no=539		
		 --BEGIN
			--DECLARE @job_name varchar(500)
			--SET @job_name='rerun_job_for_deadlock_'+@process_id
			--SET @spa = 'spa_update_deal_total_volume NULL,'''+@process_id+''',0,1,''' + @user_login_id + ''''	

			--EXEC spa_run_sp_as_job @job_name,  @spa, 'rerun_job_for_deadlock', @user_login_id
			--return
		 --END

		UPDATE import_data_files_audit SET status='e' WHERE process_id=@process_id

		IF  NOT EXISTS(SELECT 'x' FROM message_board WHERE process_id=@process_id)
		BEGIN
			EXEC spa_print @effected_deals
			 SET @sql = 'insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation,create_user,create_ts) 
				   SELECT  distinct '''+@process_id +''',''ERROR'',''Update total deal volume'',''Update total deal volume'',''ERROR'',''Error #:' + cast(@err_no as varchar) +'; Message:'+ @err_msg+'[Deal ID:''+CAST(source_deal_header_id AS VARCHAR)+''].'' ,''Please check data.'',create_user usr,GETDATE() dt
				   FROM #tmp_header_deal_id_1'
			EXEC spa_print @sql
			EXEC(@sql)
				   
			SET @sql = 'insert into source_system_data_import_status_detail(process_id,source,type,[description],create_user,create_ts) 
				   select '''+@process_id+''',''Update total deal volume'',''Error'',''Error #:' + cast(@err_no as varchar) +'; Message:'+ @err_msg+'[Deal ID:''+CAST(source_deal_header_id AS VARCHAR)+'' Detail ID:'' +CAST(source_deal_detail_id AS VARCHAR) +''].'',create_user usr,GETDATE() dt
				   FROM #tmp_header_deal_id_1'
			EXEC spa_print @sql
			EXEC(@sql)

			
			DECLARE netting CURSOR FOR 
			SELECT DISTINCT create_user FROM #tmp_header_deal_id_1
			OPEN netting
			FETCH NEXT FROM netting INTO @user_login_id
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+ @user_login_id+''''
				SELECT @desc = '<a target="_blank" href="' + @url + '">Error found while updating total deal volume.</a>'   
				set @desc=ISNULL(@desc,'no message')
					
				EXEC  spa_message_board 'i', @user_login_id,NULL, 'Update total volume',@desc, '', '', @err_status, 'Update total volume',NULL,@process_id
				
				FETCH NEXT FROM netting INTO @user_login_id
			END
			CLOSE netting
			DEALLOCATE netting

		END
	END 
	ELSE
	BEGIN
		insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation,create_user,create_ts) 
		   select @process_id,'Error','Update total deal volume','Update total deal volume','Error','Error #:' + cast(@err_no as varchar) +'; Message:'+ @err_msg+'.','Please check data.',dbo.fnadbuser() usr,GETDATE() dt

		insert into source_system_data_import_status_detail(process_id,source,type,[description],create_user,create_ts) 
		   select @process_id,'Update total deal volume','Error','Error #:' + cast(@err_no as varchar) +'; Message:'+ @err_msg+'.',dbo.fnadbuser() usr,GETDATE() dt
	END
				
	IF isnull(@call_from,0)=1
	BEGIN
		update dbo.process_deal_position_breakdown SET process_status=2,error_description=@remarks WHERE process_status=1
		print '##########################################################'
		print '##########################################################'
		print '##########################################################'
		print @remarks

		--return 


		IF EXISTS(SELECT 1 FROM dbo.process_deal_position_breakdown WHERE process_status=0)
		BEGIN 
			
			GOTO begin_update

			--SET @spa = 'dbo.spa_run_existing_job ''FARRMS - Calc Position Breakdown'''
			--EXEC spa_run_sp_as_job 'Run_FARRMS - Calc Position Breakdown',  @spa, 'Run_FARRMS - Calc Position Breakdown', 'farrms_admin'
		END 
	END				
END CATCH

