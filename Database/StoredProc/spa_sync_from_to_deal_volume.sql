
if object_id('spa_sync_from_to_deal_volume') is not null
drop proc	dbo.spa_sync_from_to_deal_volume

go
create proc dbo.spa_sync_from_to_deal_volume   @source_deal_detail_tmp varchar(250)	
As
/*
declare @source_deal_detail_tmp varchar(250) ='adiha_process.dbo.detail_process_table_farrms_admin_90667192_F54A_4712_AE8E_A69956F21377'
--*/

 if object_id('tempdb..#deal_to_update') is not	 null
	 drop table #deal_to_update

 if object_id('tempdb..#deal_detail') is not	 null
	 drop table #deal_detail

 if object_id('tempdb..#checking_volume_change') is not	 null
	 drop table #checking_volume_change


 if object_id(@source_deal_detail_tmp+'_out') is not	 null
	 exec('drop table '+@source_deal_detail_tmp+'_out')

DECLARE   @sdv_from_deal	INT,@sdv_to_deal int,@sql varchar(max)	

SELECT @sdv_from_deal = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'From Deal'

SELECT @sdv_to_deal = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'To Deal'

create table #deal_to_update(deal_header_id int ,term_start datetime, deal_volume float,leg int,leg_volume float,source_deal_detail_id int)

create table #deal_detail(deal_header_id int ,term_start datetime, deal_volume float,leg int,source_deal_detail_id int)


 SET @sql = '
	insert into #deal_detail(deal_header_id ,term_start ,leg, deal_volume ,source_deal_detail_id ) 
	SELECT  sdd.source_deal_header_id,sdd.term_start,sdd.leg ,isnull(sdh.deal_volume,sdd.deal_volume) deal_volume,sdd.source_deal_detail_id
	FROM 
	(	select b.source_deal_header_id,b.source_deal_detail_id,a.deal_volume, a.term_start from ' + @source_deal_detail_tmp + ' a
			
			inner JOIN source_deal_detail b ON b.source_deal_detail_id = a.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = b.source_deal_header_id
			INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
				  and  sdt.deal_type_id=''Transportation''
			WHERE	b.leg in (1,2)
	)	sdh
	left JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id AND sdh.term_start = sdd.term_start
	WHERE	sdd.leg in (1,2)
		
	' 
--print(@sql)
EXEC(@sql) 	

SELECT  sdd.source_deal_header_id,sddt.term_start,sddt.leg ,sddt.deal_volume 
into #checking_volume_change
FROM #deal_detail sddt
INNER JOIN source_deal_detail sdd
		ON sddt.source_deal_detail_id = sdd.source_deal_detail_id
WHERE	
	sddt.deal_volume <> sdd.deal_volume	and  sdd.leg in (1,2)
order by sdd.leg 
		
if @@rowcount >0 --Check volume change
BEGIN	

	INSERT INTO #deal_to_update(deal_header_id ,term_start, leg,deal_volume)
	SELECT  sdd.source_deal_header_id,sddt.term_start,sddt.leg ,sddt.deal_volume 
	FROM #deal_detail sddt
	inner join  source_deal_header sdh on sdh.source_deal_header_id	 =sddt.deal_header_id
	INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
				  and  sdt.deal_type_id='Transportation'
	INNER JOIN source_deal_detail sdd
			ON sddt.source_deal_detail_id = sdd.source_deal_detail_id
	inner join (
				select min(a.leg) leg from #deal_detail a
				INNER JOIN source_deal_detail b
						ON a.source_deal_detail_id = b.source_deal_detail_id
					WHERE  b.leg in (1,2)	  and a.deal_volume <> b.deal_volume	
				) l	  on l.leg=sdd.leg
	WHERE	
		sddt.deal_volume <> sdd.deal_volume	
	order by sdd.leg 

								
	update sddt set deal_volume=round(case when sdd.leg=1 then sdd.deal_volume*(1.00-isnull(cast(lf.lost_factor as float)	,0.000000)) else sdd.deal_volume/(1.00-isnull(cast(lf.lost_factor as float)	,0.000000)) end,0) 
	FROM #deal_detail sddt
	INNER JOIN #deal_to_update sdd ON   sddt.term_start=sdd.term_start
			and sdd.leg in (1,2) and sdd.leg <> sddt.leg
	outer apply (
		select isnull(cast(uddf.udf_value as float)	,0.000000) lost_factor from  user_defined_deal_fields uddf
		inner join [user_defined_deal_fields_template] uddft ON  uddf.source_deal_header_id =sdd.deal_header_id
			and uddf.udf_template_id = uddft.udf_template_id AND uddft.field_name =-5614 --loss factor
	) lf

	truncate table #deal_to_update
	
	--print 'case 1:Deriving child deals for updating where parent deal are in child''s ''from deal'' udf 	 (change in parent)'
---case 1:Deriving child deals for updating where parent deal are in child's 'from deal' udf 	 (change in parent)

	INSERT INTO #deal_to_update(deal_header_id ,term_start, deal_volume)
	SELECT child_sdd.source_deal_header_id,child_sdd.term_start, (child_sdd.deal_volume/ sdd.deal_volume)*sddt.deal_volume deal_volume 
	FROM #deal_detail sddt
	INNER JOIN source_deal_detail sdd
			ON sddt.source_deal_detail_id = sdd.source_deal_detail_id
	inner join  user_defined_deal_fields uddf on  uddf.udf_value = CAST(sdd.source_deal_header_id AS VARCHAR) and isnumeric(uddf.udf_value)=1 
	inner join [user_defined_deal_fields_template] uddft ON uddf.udf_template_id = uddft.udf_template_id AND uddft.field_name =@sdv_from_deal --293418 
	inner join  source_deal_detail child_sdd  on 	child_sdd.source_deal_header_id= uddf.source_deal_header_id
		and child_sdd.location_id=sdd.location_id and child_sdd.term_start=sdd.term_start and  child_sdd.leg=1
					
					
	if @@ROWCOUNT<1
	begin	

		--print 'case 1:Deriving child deals for updating that from parent''s ''to deal'' udf 	  (change in parent)'
		---case 1:Deriving child deals for updating that from parent's 'to deal' udf 	  (change in parent)

		INSERT INTO #deal_to_update(deal_header_id ,term_start, deal_volume)
		SELECT child_sdd.source_deal_header_id,child_sdd.term_start, sddt.deal_volume deal_volume 
		FROM #deal_detail sddt
		INNER JOIN source_deal_detail sdd
				ON sddt.source_deal_detail_id = sdd.source_deal_detail_id
		inner join  user_defined_deal_fields uddf on  uddf.source_deal_header_id =sdd.source_deal_header_id
		inner join [user_defined_deal_fields_template] uddft ON uddf.udf_template_id = uddft.udf_template_id AND uddft.field_name =@sdv_to_deal  --293418 
		inner join  source_deal_detail child_sdd  on 	cast(child_sdd.source_deal_header_id as varchar)= uddf.udf_value   and isnumeric(uddf.udf_value)=1
			and child_sdd.location_id=sdd.location_id and child_sdd.term_start=sdd.term_start and  child_sdd.leg=1

	end 

	if exists(select  1 from #deal_to_update)
	begin
	--	update child deal
		UPDATE sdd
			SET sdd.deal_volume = round(ftdu.deal_volume,0)				
		FROM source_deal_detail sdd
		INNER JOIN #deal_to_update ftdu
			ON sdd.term_start = ftdu.term_start
			AND sdd.leg = 1
		and sdd.source_deal_header_id=ftdu.deal_header_id	 
		where sdd.deal_volume <> ftdu.deal_volume
						
		if @@rowcount>0	
			UPDATE sdd
				SET sdd.deal_volume =
				round(   ftdu.deal_volume	* (1.0000-isnull(lf.loss_factor	,1.0000)),0)		
				FROM source_deal_detail sdd
			INNER JOIN #deal_to_update ftdu
				ON sdd.term_start = ftdu.term_start
				AND sdd.leg = 2
			and sdd.source_deal_header_id=ftdu.deal_header_id	
				outer apply (
				select  isnull(uddf.udf_value	,1) loss_factor from user_defined_deal_fields uddf  
				inner join [user_defined_deal_fields_template] uddft ON uddf.udf_template_id = uddft.udf_template_id 
				and  uddf.source_deal_header_id =ftdu.deal_header_id AND uddft.field_name =-5614 --loss factor 
			) lf
	end	
				  ----------------------------------------------------------------------------------------
	if not exists(select  1 from #deal_to_update)
	begin
		--print 'case 3:deriving parent deals that from child from deal udf 	   (change in child)'
		---case 3:deriving parent deals that from child's 'from deal' udf 	   (change in child)
		INSERT INTO #deal_to_update(deal_header_id ,term_start, deal_volume,leg)
		SELECT parent_sdd.source_deal_header_id,parent_sdd.term_start,parent_sdd.deal_volume+(sddt.deal_volume-sdd.deal_volume)  ,parent_sdd.leg
		FROM #deal_detail sddt
		INNER JOIN source_deal_detail sdd
				ON sddt.source_deal_detail_id = sdd.source_deal_detail_id
		inner join  user_defined_deal_fields uddf on  uddf.source_deal_header_id = CAST(sdd.source_deal_header_id AS VARCHAR) 
		inner join [user_defined_deal_fields_template] uddft ON uddf.udf_template_id = uddft.udf_template_id AND uddft.field_name =cast(@sdv_from_deal as varchar)  --293418 
		inner join  source_deal_detail parent_sdd  on 	cast(parent_sdd.source_deal_header_id as varchar)= uddf.udf_value   and isnumeric(uddf.udf_value)=1
			and parent_sdd.location_id=sdd.location_id and parent_sdd.term_start=sdd.term_start and  sdd.leg=1
		
		if @@ROWCOUNT<1
		begin	
				--print 'case 4:deriving parent deals that from parent''s ''to deal'' udf  (change in child)'
				---case 4:deriving parent deals that from parent's 'to deal' udf  (change in child)
							
				INSERT INTO #deal_to_update(deal_header_id ,term_start, deal_volume,leg)
				SELECT parent_sdd.source_deal_header_id,parent_sdd.term_start, parent_sdd.deal_volume+(sddt.deal_volume-sdd.deal_volume) deal_volume ,parent_sdd.leg 
				FROM #deal_detail sddt
				INNER JOIN source_deal_detail sdd
						ON sddt.source_deal_detail_id = sdd.source_deal_detail_id
				inner join  user_defined_deal_fields uddf on  uddf.udf_value = CAST(sdd.source_deal_header_id AS VARCHAR) and isnumeric(uddf.udf_value)=1 
				inner join [user_defined_deal_fields_template] uddft ON uddf.udf_template_id = uddft.udf_template_id AND uddft.field_name =cast(@sdv_to_deal as varchar)  --293418 
				inner join  source_deal_detail parent_sdd  on 	parent_sdd.source_deal_header_id= uddf.source_deal_header_id
					and parent_sdd.location_id=sdd.location_id and parent_sdd.term_start=sdd.term_start and  sdd.leg=1
							
		end	
					
		UPDATE sdd
			SET sdd.deal_volume =  round(ftdu.deal_volume,0)		
		FROM source_deal_detail sdd
		INNER JOIN #deal_to_update ftdu
			ON sdd.term_start = ftdu.term_start
			AND sdd.leg = ftdu.leg
		and sdd.source_deal_header_id=ftdu.deal_header_id	
		where sdd.deal_volume <> ftdu.deal_volume

		if @@rowcount>0
				UPDATE sdd
				SET sdd.deal_volume = 
				round( case when  ftdu.leg=1  then  ftdu.deal_volume* (1- isnull(cast(lf.loss_factor as float),0.0000))	else 	 ftdu.deal_volume/ (1-  isnull(cast(lf.loss_factor as float),0.0000))	 end,0)
			FROM source_deal_detail sdd
			INNER JOIN #deal_to_update ftdu
				ON sdd.term_start = ftdu.term_start
				AND sdd.leg <> ftdu.leg
			and sdd.source_deal_header_id=ftdu.deal_header_id
			outer apply (	
				select  isnull(cast(uddf.udf_value as float),0.00) loss_factor from user_defined_deal_fields uddf 
				inner join [user_defined_deal_fields_template] uddft ON uddf.udf_template_id = uddft.udf_template_id AND uddft.field_name =-5614 --loss factor 
				and   uddf.source_deal_header_id =ftdu.deal_header_id 
			) lf
					
	end
	exec('select * into '+@source_deal_detail_tmp+'_out'+' from	#deal_detail')		
					

	--------------------START OF CALCULATE TOTAL VOLUME OF FROM AND TO DEAL-----------------------------------------------------
	IF exists( select * from #deal_to_update)
	BEGIN
		DECLARE @source_deal_header_tmp VARCHAR(200), @process_id_pos VARCHAR(200)
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
						SELECT distinct deal_header_id, ''i'' FROM #deal_to_update
						'
					
		EXEC (@sql)	
						
		EXEC dbo.spa_update_deal_total_volume NULL,@process_id_pos,0					
						
	END
	--------------------END OF CALCULATE TOTAL VOLUME OF FROM AND TO DEAL-----------------------------------------------------
End --checking volume change
