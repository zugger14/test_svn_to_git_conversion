
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
	@call_from_2 VARCHAR(20) = NULL,
	@trigger_workflow NCHAR(1) = 'y'
AS 
SET nocount on
/*

-- CALCULATE POSITION DIRECTLY WITHOUT JOB
--exec [dbo].[spa_update_deal_total_volume] @source_deal_header_ids=????????????
--	,@process_id = NULL,@insert_type = 0, 
--	@partition_no = NULL,@user_login_id  = 'farrms_admin'
--	,@insert_process_table = 'n',@call_from = 1,@call_from_2 = NULL



--SELECT * FROM report_hourly_position_deal WHERE source_deal_header_id=39859
--SELECT * FROM source_deal_detail WHERE source_deal_header_id=39859

--DELETE  report_hourly_position_fixed WHERE source_deal_header_id=39859


declare @source_deal_header_ids VARCHAR(MAX), 
	@process_id VARCHAR(128),
	@insert_type int, 
	@partition_no int
	,@user_login_id VARCHAR(50),@insert_process_table VARCHAR(1)
	,@call_from BIT=1,@call_from_2 VARCHAR(20) = NULL 
	

/*
select * from report_hourly_position_deal where source_deal_header_id=100856
select * from report_hourly_position_profile where source_deal_header_id=100856

select * from source_deal_breakdown where source_deal_header_id=17912

select * from source_deal_detail_position where source_deal_detail_id=4194
select total_volume,* from source_deal_detail where source_deal_header_id=17912
select * from source_deal_detail where source_deal_detail_id=4194

select * from report_hourly_position_fixed where source_deal_header_id=17912
select * from report_hourly_position_financial where source_deal_header_id=17912

select * from source_deal_header where source_deal_header_id=17912

*/



SET nocount off	
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo

-- select * from  process_deal_position_breakdown set process_status=0
-- delete process_deal_position_breakdown

select @source_deal_header_ids=88563 , 
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

SET @baseload_block_type = '12000'	-- Internal Static Data
SELECT @baseload_block_define_id = CAST(value_id as VARCHAR(10)) FROM static_data_value WHERE [type_id] = 10018 AND code LIKE 'Base Load' -- External Static Data
IF @baseload_block_define_id IS NULL 
	SET @baseload_block_define_id = 'NULL'

SET @deal_detail_hour='deal_detail_hour'
SET @source_deal_header = 'source_deal_header'
SET @source_deal_detail = 'source_deal_detail'

IF isnull(@insert_process_table,'n')='y' 
BEGIN
	SET @source_deal_header = dbo.FNAProcessTableName('deal_header', @user_login_id, @process_id)
	SET @source_deal_detail = dbo.FNAProcessTableName('deal_detail', @user_login_id, @process_id)
END

IF object_id('tempdb..#total_process_deals') IS NOT null
	DROP TABLE  #total_process_deals

create table #total_process_deals(source_deal_header_id int)

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

set @exit=0


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
			max(isnull(spcd.commodity_id,-1)) commodity_id,max(isnull(sdh.product_id,4101)) fixation
			,max(isnull(sdh.internal_deal_type_value_id,-999999)),sdd.source_deal_detail_id
		FROM #sdh11 h inner join source_deal_header sdh on h.id=sdh.source_deal_header_id
			inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
			left join source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id and sdd.curve_id is not null
		group by sdd.source_deal_detail_id 

		-- Taking fixation deal of orginal deal.

		INSERT INTO dbo.process_deal_position_breakdown (source_deal_header_id ,create_user,create_ts,process_status,insert_type ,deal_type 
			,commodity_id,fixation ,internal_deal_type_value_id,source_deal_detail_id)
		SELECT distinct fix.source_deal_header_id
			,@user_login_id,getdate(),0,@orginal_insert_type
			,isnull(fix.internal_desk_id,17300) deal_type ,
			isnull(spcd.commodity_id,-1) commodity_id,isnull(fix.product_id,4101) fixation
			,isnull(fix.internal_deal_type_value_id,-999999)
			,sdd.source_deal_detail_id  
	
		FROM #sdh11 p inner join source_deal_header fix  on p.id=fix.close_reference_id 
				and ISNULL(fix.internal_desk_id,17300)=17301 
				and isnull(fix.product_id,4101)=4100 
			inner join source_deal_detail sdd on fix.source_deal_header_id=sdd.source_deal_header_id
			LEFT JOIN dbo.process_deal_position_breakdown m ON sdd.source_deal_header_id=m.source_deal_header_id 
				and sdd.source_deal_detail_id=isnull(m.source_deal_detail_id,sdd.source_deal_detail_id)
			left join source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id and sdd.curve_id is not null
		WHERE  m.source_deal_detail_id IS null	

		--Taking orginal deal of fixation deal

		INSERT INTO dbo.process_deal_position_breakdown (source_deal_header_id ,create_user,create_ts,process_status,insert_type ,deal_type 
			,commodity_id,fixation ,internal_deal_type_value_id,source_deal_detail_id)
		SELECT max(sdd.source_deal_header_id),@user_login_id,getdate(),0,@orginal_insert_type
		,max(isnull(fix.internal_desk_id,17300)) deal_type ,
			max(isnull(spcd.commodity_id,-1)) commodity_id,max(isnull(fix.product_id,4101)) fixation
			,max(isnull(fix.internal_deal_type_value_id,-999999)),sdd.source_deal_detail_id  
		FROM #sdh11 h inner join source_deal_header fix on h.id=fix.source_deal_header_id 
			and isnull(fix.product_id,4101)=4100
		inner join source_deal_detail sdd on fix.close_reference_id=sdd.source_deal_header_id
		left join source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id and sdd.curve_id is not null
		left join process_deal_position_breakdown ex on  ex.source_deal_header_id=sdd.source_deal_header_id
		where  ex.source_deal_header_id is null
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

	-- Taking fixation deal of orginal deal.

		set @sql='insert into '+ @effected_deals+ '(source_deal_header_id,source_deal_detail_id) 
			SELECT distinct fix.source_deal_header_id,sdd.source_deal_detail_id 
			FROM ' + @effected_deals + ' p inner join source_deal_header fix  on p.source_deal_header_id=fix.close_reference_id 
					and ISNULL(fix.internal_desk_id,17300)=17301 
					and isnull(fix.product_id,4101)=4100 
				inner join source_deal_detail sdd on fix.source_deal_header_id=sdd.source_deal_header_id
				LEFT JOIN '+@effected_deals+' m ON sdd.source_deal_header_id=m.source_deal_header_id 
					and sdd.source_deal_detail_id=isnull(m.source_deal_detail_id,sdd.source_deal_detail_id)
			WHERE  m.source_deal_detail_id IS null	
		'
				
		--	SELECT  * FROM static_data_value sdv WHERE sdv.value_id=17301	
		EXEC spa_print @sql 
		exec(@sql)	
					
		-- Taking orginal deal of fixation deal.
		set @sql='insert into '+ @effected_deals+ '(source_deal_header_id,source_deal_detail_id) 
			SELECT distinct sdd.source_deal_header_id,sdd.source_deal_detail_id 
			FROM ' + @effected_deals + ' p 
				inner join source_deal_header fix  on p.source_deal_header_id=fix.source_deal_header_id 
					and isnull(fix.product_id,4101)=4100 
				inner join source_deal_detail sdd on fix.close_reference_id=sdd.source_deal_header_id
				LEFT JOIN '+@effected_deals+' m ON sdd.source_deal_header_id=m.source_deal_header_id 
					and sdd.source_deal_detail_id=isnull(m.source_deal_detail_id,sdd.source_deal_detail_id)
			WHERE  m.source_deal_detail_id IS null	
			'

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

			IF  not EXISTS (SELECT a.job_id FROM dbo.farrms_sysjobactivity a INNER JOIN  msdb.dbo.sysjobs_view b ON a.job_id=b.job_id 
			WHERE b.name like '%'+db_name()+' - Calc Position Breakdown%' AND a.stop_execution_date IS NULL  
				AND a.start_execution_date IS NOT NULL -- AND a.run_requested_date IS NOT NULL
				)
				--IF  not EXISTS (SELECT 1 FROM  @currently_running_jobs rJOB  INNER JOIN [msdb].[dbo].[sysjobs_view] AS [sJOB] ON rJOB.[job_id] = [sJOB].[job_id] 
				--					WHERE [sJOB].name like db_name()+'- Calc Position Breakdown%' AND running=1 and next_run_date=0)
				BEGIN   
					SET @spa = 'spa_update_deal_total_volume null,null,0,1,''' + @user_login_id + ''',''n'',1, ' + ISNULL('''' + @call_from_2 + '''', 'NULL') + ',''' + @trigger_workflow + '''' 
					select @job_name= 'Calc Position Breakdown_'+@process_id
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
			
		set @sql='create TABLE '+@effected_deals +'	(source_deal_detail_id int,source_deal_header_id int,create_user varchar(50),insert_type int,deal_type int,commodity_id int,fixation int,rowid int)'
		
		exec(@sql)
			
		-- Note: Increasing batch size 100000 instead 20000 will help to increase performance for calculating position of whole portfolio
		set @sql='
		UPDATE top(20000) process_deal_position_breakdown with (ROWLOCK) SET process_status=1 
		output 
			inserted.source_deal_detail_id,inserted.source_deal_header_id,INSERTED.create_user,q.insert_type,q.deal_type,null commodity_id ,q.fixation
			into '+@effected_deals +' (source_deal_detail_id,source_deal_header_id,create_user,insert_type,deal_type,commodity_id,fixation)
		from process_deal_position_breakdown p inner join
		(
			select top 1 insert_type ,deal_type ,fixation--,commodity_id --
			 from process_deal_position_breakdown 
			where ISNULL(process_status,0)=0 and internal_deal_type_value_id NOT IN(19,20,21)
			group by insert_type ,deal_type,fixation --,commodity_id --
			order by insert_type ,deal_type,fixation desc --,commodity_id -- 
		) q on p.insert_type =q.insert_type and p.deal_type=q.deal_type  and p.fixation=q.fixation --and p.commodity_id =q.commodity_id --
		where ISNULL(p.process_status,0)=0 AND p.internal_deal_type_value_id NOT IN(19,20,21)'
			
		EXEC spa_print @sql
		exec(@sql)

		IF @@ROWCOUNT<1
			set @exit=1
			
		set @sql='
			UPDATE process_deal_position_breakdown with (ROWLOCK) SET process_status=1 
			output inserted.source_deal_detail_id,inserted.source_deal_header_id,INSERTED.create_user,inserted.insert_type,inserted.deal_type,inserted.commodity_id ,inserted.fixation into '+@effected_deals +' (source_deal_detail_id,source_deal_header_id,create_user,insert_type,deal_type,commodity_id,fixation) 
		--	from process_deal_position_breakdown p
			where ISNULL(process_status,0)=0 AND internal_deal_type_value_id IN (19,20,21)'
			
		EXEC spa_print @sql
		exec(@sql)

		IF @@ROWCOUNT<1 and @exit=1
			RETURN

		exec('insert into #total_process_deals (source_deal_header_id) select distinct source_deal_header_id from '+@effected_deals ) 
			
			
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

update ed set dst_group_value_id=isnull(tz.dst_group_value_id, @default_dst_group)
FROM source_deal_detail sdd
	INNER JOIN #tmp_header_deal_id_1 ed ON ed.source_deal_detail_id = sdd.source_deal_detail_id 
	left join dbo.vwDealTimezone tz  on  tz.source_deal_header_id=sdd.source_deal_header_id
		and tz.curve_id=isnull(sdd.curve_id,-1)  and tz.location_id=isnull(sdd.location_id,-1) 

BEGIN TRY
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

	set @sql='
		update e set rowid=h.rowid
		from '+@effected_deals +' e inner join #tmp_header_deal_id_1 h on h.source_deal_detail_id=e.source_deal_detail_id
		'
		
	EXEC spa_print @sql
	EXEC(@sql)		


	--update for fixed deal

	exec('select top(1) deal_type into #ttttt from '+ @effected_deals +' where deal_type=17300') 
	if @@rowcount>0
	begin

		if object_id('tempdb..#density_multiplier_1') is not null 
			drop table #density_multiplier_1

		CREATE TABLE #density_multiplier_1 (
			source_deal_detail_id INT,physical_density_mult NUMERIC(38,16),financial_density_mult NUMERIC(38, 16)
		)


		insert into #density_multiplier_1 (source_deal_detail_id,physical_density_mult,financial_density_mult)
		select distinct sdd.source_deal_detail_id,isnull(cf_p1.factor,cf_p.factor),cf_f.factor
		from #tmp_header_deal_id_1 sdh inner join source_deal_detail sdd on sdh.source_deal_detail_id=sdd.source_deal_detail_id
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


		SET @sql='
		select	ed.source_deal_detail_id
			,round(cast(CAST(sdd.deal_volume AS NUMERIC(24,10))
			*cast(term_factor.factor AS NUMERIC(24,10)) AS NUMERIC(24,10)) ,isnull(rnd.position_calc_round,100))
			*cast(cast(CAST(ISNULL(sdd.multiplier,1) AS NUMERIC(24,16)) AS NUMERIC(24,16))*CAST(ISNULL(sdd.volume_multiplier2,1) AS NUMERIC(24,16)) AS NUMERIC(24,16)) * CAST(COALESCE(case when sdd.physical_financial_flag=''p'' then dm.physical_density_mult else dm.financial_density_mult end,conv.conversion_factor,1) AS NUMERIC(24,16)) total_volume
			,cast(CAST(sdd.deal_volume AS NUMERIC(24,10))/cast(nullif(term_factor.factor,0) AS NUMERIC(24,10)) AS NUMERIC(24,10)) 
			*cast(cast(CAST(ISNULL(sdd.multiplier,1) AS NUMERIC(24,16)) AS NUMERIC(24,16))*CAST(ISNULL(sdd.volume_multiplier2,1) AS NUMERIC(24,16)) AS NUMERIC(24,16)) * CAST(COALESCE(case when sdd.physical_financial_flag=''p'' then dm.physical_density_mult else dm.financial_density_mult end,conv.conversion_factor,1) AS NUMERIC(24,16)) hourly_position
			,ed.rowid position_report_group_map_rowid
		into #source_deal_detail_position
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
		where sdd.position_formula_id is null; 

		delete sddp
		from source_deal_detail_position sddp 
			inner join #source_deal_detail_position ed ON ed.source_deal_detail_id = sddp.source_deal_detail_id;

		insert into source_deal_detail_position(source_deal_detail_id,total_volume,hourly_position,position_report_group_map_rowid)
		select sddp.source_deal_detail_id,sddp.total_volume,sddp.hourly_position,sddp.position_report_group_map_rowid 
		from #source_deal_detail_position sddp inner join source_deal_detail sdd on sddp.source_deal_detail_id=sdd.source_deal_detail_id

	'
	
		EXEC dbo.spa_print @sql
		EXEC(@sql)	
	end



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

if 	exists(select top(1) 1 from  #total_process_deals ) 
begin

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
	SELECT distinct sdh.source_deal_header_id,
		sdh.deal_date,
		sdh.entire_term_start,
		sdh.counterparty_id
	FROM   source_deal_header sdh 
		inner join #total_process_deals tpd on sdh.source_deal_header_id=tpd.source_deal_header_id
	'

	IF ISNULL(@call_from_2, '') <> 'alert' AND @trigger_workflow = 'y'
	BEGIN
		EXEC(@sql)
		EXEC spa_print @sql
		EXEC spa_register_event 20601, 20509, @alert_process_table, 1, @process_id
	END
end
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

