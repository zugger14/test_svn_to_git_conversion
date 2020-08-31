
if object_id('spa_update_pipeline_cut') is not null
drop proc dbo.spa_update_pipeline_cut
go

create proc dbo.spa_update_pipeline_cut ( @process_id VARCHAR(250),@source_deal_header_id int)
as
/*

DECLARE @process_id VARCHAR(250)='351BBFCE_FCCD_49DF_A421_014701A7E020',@source_deal_header_id int=2646


drop TABLE #effective_deals
drop TABLE #leg_volume
drop TABLE #next_deal_leg_volume_final
drop TABLE #next_deal_leg_volume
--update source_deal_detail set deal_volume=deal_volume-10 where source_deal_header_id=@source_deal_header_id and leg=1


--*/



declare @user_login_id VARCHAR(30),@sql VARCHAR(MAX),@source_deal_detail_tmp  VARCHAR(250),@org_process_id VARCHAR(250)
SET @org_process_id=@process_id
SET @user_login_id = dbo.FNADBUser()  

SET @source_deal_detail_tmp = dbo.FNAProcessTableName('paging_sourcedealtemp', @user_login_id, @process_id)  

if @process_id is null
begin
	set @process_id=dbo.FNAGetNewID()
	SET @source_deal_detail_tmp = dbo.FNAProcessTableName('paging_sourcedealtemp', @user_login_id, @process_id)  
	set @sql='select * into '+@source_deal_detail_tmp+' from source_deal_detail where source_deal_header_id='+cast(@source_deal_header_id as varchar)
	exec spa_print @sql
	exec(@sql)
	update source_deal_detail set deal_volume=deal_volume+10 where source_deal_header_id=@source_deal_header_id and leg=1
	
	--SELECT deal_volume,* FROM source_deal_detail WHERE source_deal_header_id in (2646,2647)
end

DECLARE @loss_factor NUMERIC(38, 20),@sch_deal_id INT,@from_schedule_deal_update VARCHAR(1)				
		,@source_deal_header_tmp VARCHAR(200), @process_id_pos VARCHAR(200), @from_deal INT, @to_deal INT
		, @from_to_deal VARCHAR(100),@template_id INT ,@grp_path_id INT 
	

CREATE TABLE #effective_deals (
	source_deal_header_id INT
)

CREATE TABLE #leg_volume (
	leg INT,
	term_start DATETIME,
	term_end DATETIME,
	deal_volume NUMERIC(38, 20),
	deal_volume_changed NUMERIC(38, 20)
)

CREATE TABLE #next_deal_leg_volume_final (
	leg INT,
	term_start DATETIME,
	term_end DATETIME,
	deal_volume NUMERIC(38, 20),
	deal_volume_changed NUMERIC(38, 20)
)

CREATE TABLE #next_deal_leg_volume (
	leg INT,
	term_start DATETIME,
	term_end DATETIME,
	deal_volume NUMERIC(38, 20),
	deal_volume_changed NUMERIC(38, 20)
)



DECLARE @chenaged_leg_vol INT ,@leg INT,@min_schedule_deal_id int,@max_schedule_deal_id int

SELECT @min_schedule_deal_id =MIN(source_deal_header_id),@max_schedule_deal_id=max(source_deal_header_id)
FROM (
	SELECT distinct uddf_d.source_deal_header_id FROM  (
			SELECT TOP(1) uddf.udf_value
			FROM   user_defined_deal_fields uddf
			INNER JOIN user_defined_deal_fields_template uddft
				ON  uddft.udf_template_id = uddf.udf_template_id AND uddft.Field_label='Scheduled ID'
			 and uddf.source_deal_header_id =@source_deal_header_id  
			  AND ISNUMERIC(uddf.udf_value)=1
		) sch_id
		INNER JOIN user_defined_deal_fields uddf_d ON ISNUMERIC(uddf_d.udf_value)=1 AND uddf_d.udf_value=sch_id.udf_value
)	sch


SELECT @grp_path_id= grp_path.grp_path_id
					FROM  (
						SELECT TOP(1) uddf.udf_value
					FROM   user_defined_deal_fields uddf
						INNER JOIN user_defined_deal_fields_template uddft
							ON  uddft.udf_template_id = uddf.udf_template_id AND uddft.Field_label='Scheduled ID'
						 and uddf.source_deal_header_id =@source_deal_header_id 
						  AND ISNUMERIC(uddf.udf_value)=1
					) sch_id
					INNER JOIN user_defined_deal_fields uddf_d ON ISNUMERIC(uddf_d.udf_value)=1 AND uddf_d.udf_value=sch_id.udf_value
					outer apply(
						select cast(f.udf_value as float) factor from  user_defined_deal_fields f
						inner join  user_defined_deal_fields_template uddft on f.udf_template_id=uddft.udf_template_id  and uddft.field_name=-5614
							and f.source_deal_header_id=uddf_d.source_deal_header_id  and Isnumeric(f.udf_value)=1
					) fac
					outer apply(
						select cast(f.udf_value as float) grp_path_id from  user_defined_deal_fields f
						inner join  user_defined_deal_fields_template uddft on f.udf_template_id=uddft.udf_template_id  and uddft.field_name=-5606
							and f.source_deal_header_id=uddf_d.source_deal_header_id  and Isnumeric(f.udf_value)=1
					) grp_path
					where uddf_d.source_deal_header_id=@source_deal_header_id 


DECLARE leg_schedule_deals CURSOR FOR 
	SELECT distinct leg from source_deal_detail where source_deal_header_id=@source_deal_header_id order by 1

OPEN leg_schedule_deals
FETCH NEXT FROM leg_schedule_deals INTO @leg
WHILE @@FETCH_STATUS = 0
BEGIN		

	truncate table #leg_volume
	truncate table #next_deal_leg_volume

	SET @sql = ' 
		INSERT INTO #leg_volume( term_start, term_end, leg, deal_volume,deal_volume_changed)
		SELECT   sdd.term_start, sdd.term_end, sdd.leg, sddt.deal_volume,sddt.deal_volume - sdd.deal_volume 
		FROM ' + @source_deal_detail_tmp + ' sddt
			INNER JOIN source_deal_detail sdd ON sddt.source_deal_detail_id = sdd.source_deal_detail_id
		where round(sddt.deal_volume - sdd.deal_volume ,2)<>0 and sdd.leg='+CASE WHEN @leg=1 THEN 'sdd.leg' ELSE cast(@leg as varchar) END 

	exec spa_print @sql
	EXEC(@sql)
		
		
	--always first loop is for deal @source_deal_header_id and then other

	set @sql='DECLARE schedule_deals CURSOR FOR 
		SELECT distinct uddf_d.source_deal_header_id,fac.factor,sdh.template_id FROM  (
			SELECT TOP(1) uddf.udf_value
		FROM   user_defined_deal_fields uddf
			INNER JOIN user_defined_deal_fields_template uddft
				ON  uddft.udf_template_id = uddf.udf_template_id AND uddft.Field_label=''Scheduled ID''
			 and uddf.source_deal_header_id ='+cast(@source_deal_header_id as varchar)+'  --41145 
			  AND ISNUMERIC(uddf.udf_value)=1
		) sch_id
		INNER JOIN user_defined_deal_fields uddf_d ON ISNUMERIC(uddf_d.udf_value)=1 AND uddf_d.udf_value=sch_id.udf_value
		INNER JOIN source_deal_header sdh on  uddf_d.source_deal_header_id=sdh.source_deal_header_id
		outer apply(
			select cast(f.udf_value as float) factor from  user_defined_deal_fields f
			inner join  user_defined_deal_fields_template uddft on f.udf_template_id=uddft.udf_template_id  and uddft.field_name=-5614
				and f.source_deal_header_id=sdh.source_deal_header_id  and Isnumeric(f.udf_value)=1
		) fac
		where uddf_d.source_deal_header_id'+case when @leg=1 then '<='+cast(@source_deal_header_id as varchar)+' ORDER BY 1 desc '
			 else '>'+cast(@source_deal_header_id as varchar)+' ORDER BY 1 '	end 	

	EXEC spa_print @sql
	exec(@sql)
	OPEN schedule_deals
	FETCH NEXT FROM schedule_deals INTO @sch_deal_id,@loss_factor,@template_id
	WHILE @@FETCH_STATUS = 0
	BEGIN			
		IF EXISTS(
			SELECT 1 FROM   user_defined_fields_template udft
				   INNER JOIN user_defined_deal_fields_template uddft ON  udft.field_name = uddft.field_name AND uddft.template_id = @template_id AND udft.Field_label = 'Delivery Path' 	
		)
		BEGIN
			insert into #effective_deals select @sch_deal_id
			
			EXEC spa_print '************************************************************'
			EXEC spa_print 'Scheduled deal ID:', @sch_deal_id
			EXEC spa_print '************************************************************'
			--select @sch_deal_id,@source_deal_header_id,@loss_factor
			
			IF @sch_deal_id<>@source_deal_header_id 
			BEGIN 
				IF  exists(SELECT 1 from #next_deal_leg_volume_final) --first loop of each leg is alway does not exist data in #next_deal_leg_volume_final
				BEGIN 
					truncate table #leg_volume
					EXEC spa_print 'ooooooooooooooooooo'
					UPDATE sddt
						SET sddt.deal_volume =  lfdu.deal_volume 
							output inserted.term_start, inserted.term_end, inserted.leg, inserted.deal_volume
							,lfdu.deal_volume_changed  into #leg_volume( term_start, term_end, leg, deal_volume,deal_volume_changed)
						FROM source_deal_detail sddt
						INNER JOIN #next_deal_leg_volume_final lfdu on  lfdu.term_start=sddt.term_start and lfdu.term_end=sddt.term_end 
						and  sddt.leg<> @leg AND lfdu.leg=@leg
							and round(lfdu.deal_volume_changed,2)<>0 AND sddt.source_deal_header_id=@sch_deal_id
			
				--	SELECT * FROM #leg_volume
			
				END 
			END



		--note: need to check for if both legs volumes are changed then leg 1 delta vol (this is meaningful for @source_deal_header_id).
						
			SELECT @chenaged_leg_vol=leg FROM (
				SELECT TOP(1) leg FROM (
					SELECT DISTINCT leg FROM  #leg_volume 
				) a ORDER BY 1
			) b		
			
			truncate table #next_deal_leg_volume
			
			SET @sql = 'UPDATE sddt
						SET sddt.deal_volume = CASE WHEN lfdu.leg = 1 THEN 
													lfdu.deal_volume - lfdu.deal_volume * ' + CAST(@loss_factor AS VARCHAR(50)) + '														
												ELSE 
													lfdu.deal_volume /(1 - ' + CAST(@loss_factor AS VARCHAR(50)) + ')
											   END
							output inserted.term_start, inserted.term_end, inserted.leg, inserted.deal_volume
							,inserted.deal_volume-deleted.deal_volume  into #next_deal_leg_volume( term_start, term_end, leg, deal_volume,deal_volume_changed)
						FROM ' + case WHEN @sch_deal_id=@source_deal_header_id AND @org_process_id IS NOT null THEN  @source_deal_detail_tmp ELSE 'source_deal_detail' END + ' sddt
						inner join source_deal_detail sdd on sdd.source_deal_detail_id=sddt.source_deal_detail_id
						INNER JOIN #leg_volume  lfdu on  lfdu.term_start=sddt.term_start and lfdu.term_end=sddt.term_end and  sddt.leg<> lfdu.leg
							and round(lfdu.deal_volume_changed,2)<>0 and lfdu.leg='+cast(@chenaged_leg_vol AS VARCHAR)+'
							AND sdd.source_deal_header_id='+CAST(@sch_deal_id AS VARCHAR)
			
			
			exec spa_print @sql
			EXEC(@sql)

			truncate table #next_deal_leg_volume_final
			
			insert into #next_deal_leg_volume_final (leg,term_start,term_end,deal_volume,deal_volume_changed)
			SELECT  leg,term_start, term_end,  deal_volume,deal_volume_changed from #next_deal_leg_volume
			
			insert into #next_deal_leg_volume_final (leg,term_start,term_end,deal_volume,deal_volume_changed)
			SELECT  l.leg,l.term_start, l.term_end,  l.deal_volume,l.deal_volume_changed from #leg_volume l
			left join #next_deal_leg_volume_final n_leg on n_leg.leg=l.leg and n_leg.term_start=l.term_start and n_leg.term_end=l.term_end
			where n_leg.leg is null
							 
		-------------------------START OF "FROM DEAL" AND "TO DEAL" UPDATE------------------------------

			IF EXISTS(
				SELECT 1 FROM source_deal_header sdh
				INNER JOIN user_defined_deal_fields_template uddft
					ON sdh.template_id = uddft.template_id
				INNER JOIN user_defined_fields_template udft
					ON uddft.field_name = udft.field_name AND udft.field_label in ('from deal', 'to deal')
				INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh.source_deal_header_id
					AND uddft.udf_template_id = uddf.udf_template_id
				WHERE sdh.source_deal_header_id = @sch_deal_id			
			)
			BEGIN	
				
					IF (@grp_path_id IS NOT NULL AND @sch_deal_id=@min_schedule_deal_id) OR @grp_path_id IS  NULL 
					BEGIN 
						EXEC spa_print '************************************************************'
						EXEC spa_print 'From deal ID:', @sch_deal_id
						EXEC spa_print '************************************************************'
						
						SELECT @from_deal = uddf.udf_value FROM source_deal_header sdh
						INNER JOIN user_defined_deal_fields_template uddft ON sdh.template_id = uddft.template_id
						INNER JOIN user_defined_fields_template udft ON uddft.field_name = udft.field_name
							AND udft.field_label in ('from deal')
						INNER JOIN user_defined_deal_fields uddf 
							ON uddf.source_deal_header_id = sdh.source_deal_header_id AND uddft.udf_template_id = uddf.udf_template_id
						WHERE sdh.source_deal_header_id =@sch_deal_id 
							
						UPDATE sdd
							SET sdd.deal_volume = sdd.deal_volume + del.deal_volume_changed				
						FROM source_deal_detail sdd
						INNER JOIN 
						 ( select *  from #next_deal_leg_volume_final where leg=1 and round(deal_volume_changed,2)<>0 ) del
							ON sdd.term_start = del.term_start
							AND sdd.term_end = del.term_end and  sdd.source_deal_header_id=@from_deal	
							
						insert into #effective_deals select @from_deal
						 
					END 
					IF (@grp_path_id IS NOT NULL AND @sch_deal_id=@max_schedule_deal_id) OR @grp_path_id IS  NULL 
					BEGIN 
						EXEC spa_print '************************************************************'
						EXEC spa_print 'To deal ID:', @sch_deal_id
						EXEC spa_print '************************************************************'
						
						SELECT @to_deal = uddf.udf_value
						FROM source_deal_header sdh
						INNER JOIN user_defined_deal_fields_template uddft
							ON sdh.template_id = uddft.template_id
						INNER JOIN user_defined_fields_template udft
							ON uddft.field_name = udft.field_name
							AND udft.field_label in ('to deal')
						INNER JOIN user_defined_deal_fields uddf 
							ON uddf.source_deal_header_id = sdh.source_deal_header_id
							AND uddft.udf_template_id = uddf.udf_template_id
						WHERE sdh.source_deal_header_id =@sch_deal_id
						
						UPDATE sdd
							SET sdd.deal_volume = sdd.deal_volume + del.deal_volume_changed				
						FROM source_deal_detail sdd
						INNER JOIN 
						 ( select *  from #next_deal_leg_volume_final where leg=2 and round(deal_volume_changed,2)<>0 ) del
							ON sdd.term_start = del.term_start
							AND sdd.term_end = del.term_end AND sdd.source_deal_header_id =@to_deal			
						
						insert into #effective_deals select @to_deal

						
					-------------------------END OF "FROM DEAL" AND "TO DEAL" UPDATE------------------------------
						
					END 
				END			
			END 
		-------------------END OF LOSS FACTOR CALCULATIONS------------------------------------------------------- 



--select *  FROM adiha_process.dbo.paging_sourcedealtemp_farrms_admin_E1C64152_19AC_48CE_8B2B_1A13B5C9F5A4
--select * from #leg_volume
--select * from #next_deal_leg_volume
--select * from #next_deal_leg_volume_final




		FETCH NEXT FROM schedule_deals INTO @sch_deal_id,@loss_factor,@template_id
	END
	CLOSE schedule_deals
	DEALLOCATE schedule_deals				
	FETCH NEXT FROM leg_schedule_deals INTO @leg
END
CLOSE leg_schedule_deals
DEALLOCATE leg_schedule_deals				


----------------------START OF CALCULATE TOTAL VOLUME OF FROM AND TO DEAL-----------------------------------------------------
IF exists(select 1 from #effective_deals) 
BEGIN
	SET @process_id_pos = dbo.FNAGetNewID()
	SELECT @source_deal_header_tmp = dbo.FNAProcessTableName('report_position', dbo.FNADBUser() , @process_id_pos)
	
	SET @sql = ' CREATE TABLE ' +  @source_deal_header_tmp + ' 
	(
		source_deal_header_id  INT,
		[action]               VARCHAR(1)
	)
	'		
	EXEC(@sql)						   
	                       
	SET @sql = ' INSERT INTO ' + @source_deal_header_tmp + 
		' (
			source_deal_header_id,
			ACTION
		  )	
		  SELECT distinct source_deal_header_id, ''i'' FROM #effective_deals
		  '

	EXEC (@sql)	
	
	EXEC dbo.spa_update_deal_total_volume NULL,@process_id_pos,0	
	
	set @sql=null
	select @sql=ISNULL(@sql+',','')+CAST(source_deal_header_id as varchar) from 
	(select distinct source_deal_header_id from #effective_deals) b
	EXEC spa_insert_update_audit 'u',@sql				
	
END
----------------------END OF CALCULATE TOTAL VOLUME OF FROM AND TO DEAL-----------------------------------------------------
