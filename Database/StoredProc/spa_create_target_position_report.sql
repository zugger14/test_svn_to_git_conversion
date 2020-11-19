
/****** Object:  StoredProcedure [dbo].[spa_create_target_position_report]    Script Date: 10/16/2009 12:36:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_target_position_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_target_position_report]
/****** Object:  StoredProcedure [dbo].[spa_create_target_position_report]    Script Date: 10/16/2009 12:36:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--% Assigned for  each  generator = (total assigned for RPS compliance)/((total assigned for RPS compliance) + banked)

--exec spa_REC_Target_Report '2006-06-05','94',NULL,NULL,'5149','s',NULL,5098,'y',NULL,null,'n',NULL,NULL,NULL,NULL,NULL,NULL,NULL

-- exec spa_REC_Target_Report '2006-03-15','94',NULL,NULL,NULL,'s',NULL,NULL,'y',98, null
-- exec spa_REC_Target_Report '2006-04-05','94',NULL,NULL,NULL,'s',NULL,NULL,'y',98, null, 'y'
-- exec spa_REC_Target_Report '2006-04-05','94',NULL,NULL,NULL,'s',NULL,NULL,'y',97, null, 'y'

-- exec spa_REC_Target_Report '2006-04-06','94',NULL,NULL,NULL,'s',NULL,NULL,'y',97,null,'y'
-- exec spa_REC_Target_Report '2006-04-06','96',NULL,NULL,NULL,'s',NULL,NULL,'y',96,null,'n', null, null, 5148, null, null, null, null
-- exec spa_REC_Target_Report '2006-04-06','96',NULL,NULL,NULL,'d',NULL,NULL,'y',96,null,'n', null, null, 5148, null, null, null, null
-- exec spa_REC_Target_Report '2006-04-06','96',NULL,NULL,NULL,'i',NULL,NULL,'y',96,null,'n', null, null, 5148, null, null, null, null

--exec spa_REC_Target_Report '2006-06-05','94',NULL,NULL,'5146','s',2006,5098,'y',NULL,null,'n',NULL,NULL,NULL,NULL,NULL,NULL,NULL
-- 
-- --exec spa_REC_Target_Report '2005-12-31', '94', NULL, NULL, NULL, 's', 2005, null, 'n', null
-- --exec spa_REC_Target_Report '2005-12-31', '96', NULL, NULL, 5146, 's', 2005, 5118, 'y', 96
-- --exec spa_REC_Target_Report '2005-12-31', '96', NULL, NULL, 5146, 's', 2005, 5118, 'y'
-- --exec spa_REC_Target_Report '2005-12-31', null, NULL, '117,120', 5146, 's', 2005, null, 'y'
-- 
CREATE  PROC [dbo].[spa_create_target_position_report]
	@as_of_date varchar(50), 
	@sub_entity_id varchar(100), 
	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL, 
	@assignment_type int = null,  --assignment_type  
	@summary_option char(1),  --'s' summary, 'd' detail that shows generator, 'i' shows indvidual deals -- 'x' -> called from Exposure report
	@compliance_year int,
	@assigned_state int = null,
	@include_banked varchar(1) = 'n',
	@curve_id int = NULL,
	@curve_name varchar(100)= NULL,
	@plot varchar(1) = 'n',
	@generator_id int = null,
	@convert_uom_id int = null,
	@convert_assignment_type_id int = null,
	@deal_id_from int = null,
	@deal_id_to int = null,
	@gis_cert_number varchar(250)= null,
	@gis_cert_number_to varchar(250)= null,
	@generation_state int=null,
	@program_scope varchar(50)=null,
	@program_type char(1)='b', --- 'a' -> Compliance, 'b' -> cap&trade ,
	@round_value CHAR(1)='0', 
	@show_cross_tabformat CHAR(1)='n',
	@gen_date_from varchar(20) = null,            
	@gen_date_to varchar(20) = null,  
	@include_expired CHAR(1)='n',
	@carry_forward CHAR(1)='n',
	@udf_group1 INT=NULL,
	@udf_group2 INT=NULL,
	@udf_group3 INT=NULL,	
	@tier_type INT=NULL,
	@technology INT=NULL,
	@allocate_banked CHAR(1)=NULL,
	@report_type CHAR(1)=NULL, -- 't' target report, 'p' trader position report
	@curve_source_value_id INT=NULL,
	@drill_State VARCHAR(100)=NULL,
	@batch_process_id varchar(50)=NULL,
	@batch_report_param varchar(500)=NULL  ,
	@enable_paging int=0,  --'1'=enable, '0'=disable
	@page_size int =NULL,
	@page_no int=NULL
  
 AS
 SET NOCOUNT ON 
 


--////////////////////////////Paging_Batch///////////////////////////////////////////
EXEC spa_print	'@batch_process_id:', @batch_process_id 
EXEC spa_print	'@batch_report_param:',	@batch_report_param

declare @str_batch_table varchar(max),@str_get_row_number VARCHAR(100)
declare @temptablename varchar(128),@user_login_id varchar(50),@flag CHAR(1)
DECLARE @is_batch bit
declare @maturity_date varchar(50)
set @maturity_date = cast(@compliance_year as varchar) + '-12-01'
set @str_batch_table=''
SET @str_get_row_number=''

declare @sql_stmt varchar(5000)

IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
	SET @is_batch = 1
ELSE
	SET @is_batch = 0
	
IF (@is_batch = 1 OR @enable_paging = 1)
begin
	IF (@batch_process_id IS NULL)
		SET @batch_process_id = REPLACE(NEWID(), '-', '_')
		
	SET @user_login_id = dbo.FNADBUser()	
	SET @temptablename = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
	exec spa_print '@temptablename', @temptablename
	SET @str_batch_table=' INTO ' + @temptablename
	SET @str_get_row_number=', ROWID=IDENTITY(int,1,1)'
	IF @enable_paging = 1
	BEGIN
		
		IF @page_size IS not NULL
		begin
			declare @row_to int,@row_from int
			set @row_to=@page_no * @page_size
			if @page_no > 1 
				set @row_from =((@page_no-1) * @page_size)+1
			else
				set @row_from =@page_no
			set @sql_stmt=''
			--	select @temptablename
			--select * from adiha_process.sys.columns where [object_id]=object_id(@temptablename) and [name]<>'ROWID' ORDER BY column_id

			select @sql_stmt=@sql_stmt+',['+[name]+']' from adiha_process.sys.columns WITH(NOLOCK) where [object_id]=object_id(@temptablename) and [name]<>'ROWID' ORDER BY column_id
			SET @sql_stmt=SUBSTRING(@sql_stmt,2,LEN(@sql_stmt))
			
			set @sql_stmt='select '+@sql_stmt +'
				  from '+ @temptablename   +' 
				  where rowid between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) 
				 
			--print(@sql_stmt)		
			exec(@sql_stmt)
			return
		END --else @page_size IS not NULL
	END --enable_paging = 1
		
end

--////////////////////////////End_Batch///////////////////////////////////////////














-- CALL ACTIVITY REPORT
DECLARE @listCol VARCHAR(max),@sql_select VARCHAR(max),@listCol_tot VARCHAR(max),@listCol_sel VARCHAR(max)

IF @program_type IS NULL
	SET @program_type='b'



CREATE TABLE #temp_final(
		sub VARCHAR(500) COLLATE DATABASE_DEFAULT,
		env_product VARCHAR(500) COLLATE DATABASE_DEFAULT,
		technology VARCHAR(500) COLLATE DATABASE_DEFAULT,
		assignment VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[type] VARCHAR(500) COLLATE DATABASE_DEFAULT,		
		jurisdiction varchar(1000) COLLATE DATABASE_DEFAULT,
		vintage VARCHAR(500) COLLATE DATABASE_DEFAULT,
		volume FLOAT,
		bonus FLOAT,
		TotalVolume FLOAT,
		UOM VARCHAR(500) COLLATE DATABASE_DEFAULT,
		expiration DATETIME,
		[isJurisdiction] CHAR(1) COLLATE DATABASE_DEFAULT,
		curve_id INT,
		fixed_price FLOAT
	)



	INSERT INTO #temp_final (sub,
		env_product,
		technology,
		assignment,
		type,		
		jurisdiction,
		vintage ,
		volume,
		bonus,
		TotalVolume,
		UOM,
		expiration,
		[isJurisdiction],
		curve_id,
		fixed_price
	) 
	EXEC spa_get_rec_activity_report 
			@as_of_date,
			@sub_entity_id, 
			@strategy_entity_id, 
			@book_entity_id, 
			@assignment_type,  
			@summary_option,
			@compliance_year,
			@assigned_state,
			@curve_id,
			@generator_id,
			@convert_uom_id,
			@convert_assignment_type_id,
			@deal_id_from,
			@deal_id_to,
			@gis_cert_number,
			@gis_cert_number_to,
			@gen_date_from,
			@gen_date_to,
			NULL, 
			NULL, 
			NULL, 
			NULL, 
			NULL, 
			NULL, 
			NULL,
			NULL,
			NULL,
			NULL, 
			@generation_state,
			'n',
			NULL, 
			NULL, 
			NULL, 
			NULL, 
			@drill_State,
			NULL,	
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			'y',
			'n',
			@include_banked,
			@program_scope,
			@program_type,
			@round_value,
			@udf_group1,
			@udf_group2,
			@udf_group3,
			@tier_type
--			,
--			@batch_process_id,
--			@batch_report_param
			select * into #temp_final_1 FROM #temp_final WHERE 1=2
			ALTER TABLE #temp_final_1 ADD volume_left FLOAT

			IF @allocate_banked='y'
			BEGIN	
	
				DECLARE @sub VARCHAR(100),@env_product VARCHAR(100),@tech VARCHAR(100),@volume FLOAT,@vintage INT,@jurisdiction VARCHAR(500),@expire_year INT,@vintage_actual INT
				DECLARE @pre_sub VARCHAR(100),@pre_env_product VARCHAR(100),@next_volumne FLOAT,@volume_left FLOAT,@new_volume FLOAT,@prev_vinatage INT,@total_volume FLOAT
				DECLARE @max_vintage INT,@actual_volume FLOAT,@next_volume FLOAT	 
					SET @volume_left=0
					set @actual_volume=0
					set @next_volume=0



				INSERT INTO #temp_final(sub,env_product,technology,jurisdiction,assignment,[type],vintage,expiration,totalvolume,volume,curve_id)
				SELECT sub,env_product,technology,jurisdiction,MAX(assignment),'d',vintage,MAX(expiration),0,0,curve_id from #temp_final group by  sub,env_product,technology,jurisdiction,YEAR(expiration),vintage,curve_id


				DECLARE cur1 CURSOR FOR SELECT sub,[env_product],vintage,MAX(YEAR(expiration)),sum(totalvolume),curve_id
				 FROM #temp_final where 1=1 --and vintage =(2007)
					 GROUP BY sub,[env_product],vintage,curve_id order by [sub],[env_product],vintage,curve_id 
				OPEN cur1
				FETCH NEXT FROM cur1 INTO  @sub,@env_product,@vintage_actual,@expire_year,@actual_volume,@curve_id
				WHILE @@FETCH_STATUS=0
				BEGIN

						SELECT @max_vintage=MAX(vintage) FROM #temp_final WHERE sub=@sub AND env_product=@env_product
						SELECT @expire_year= CASE WHEN @expire_year>@max_vintage THEN @max_vintage ELSE @expire_year END
						SET @volume_left=@actual_volume

						DECLARE  cur2 cursor for 
									SELECT a.sub,a.[env_product],MAX(a.technology),MAX(a.jurisdiction), a.vintage,sum(a.totalvolume+ISNULL(b.totalvolume,0)) Volume,a.curve_id
									from (select sub,[env_product],MAX(technology)technology,MAX(jurisdiction)jurisdiction,vintage,sum(totalvolume)totalvolume,curve_id 
											FROM #temp_final GROUP BY sub,[env_product],vintage,curve_id)a--where [env_product]='REC-Solar'
										 LEFT JOIN #temp_final_1 b ON a.sub=b.sub and a.env_product=b.env_product and a.vintage=b.vintage 
									WHERE a.sub=@sub AND a.[env_product]=@env_product and a.vintage>=@vintage_actual
										
									GROUP BY a.sub,a.[env_product],a.vintage,a.curve_id order by a.[sub],a.[env_product],a.vintage,a.curve_id

						open cur2
						fetch next from cur2 into @sub,@env_product,@tech,@jurisdiction,@vintage,@Volume,@curve_id
						WHILE @@FETCH_STATUS=0
						BEGIN
							 IF  @Volume>0 AND @vintage<@max_vintage
								BEGIN
									--SET @volume=CASE WHEN @expire_year=@vintage THEN @volume_left WHEN @volume_left<0 THEN abs(@volume_left)WHEN abs(@volume)>@volume_left THEN @volume_left ELSE abs(@volume) END	
									--SET @volume_left=CASE WHEN @volume_left<0 THEN @volume ELSE @volume_left END	
									INSERT INTO #temp_final_1(sub,env_product,technology,jurisdiction,assignment,[type],vintage,totalvolume,volume_left,curve_id)
									SELECT 	@sub,@env_product,@tech,@jurisdiction,'Banked'+CASE WHEN @report_type='p' THEN '' ELSE '-'+CAST(@vintage_actual AS VARCHAR)END,'',@vintage+1,@Volume,@volume_left,@curve_id
									SET @Volume=0
								END
							break
						fetch next from cur2 into @sub,@env_product,@tech,@jurisdiction,@vintage,@Volume,@curve_id
						END
					CLOSE cur2
					DEALLOCATE cur2
				FETCH NEXT FROM cur1 INTO  @sub,@env_product,@vintage_actual,@expire_year,@actual_volume,@curve_id
				END
				CLOSE cur1
				DEALLOCATE cur1

		END
		delete from #temp_final where [type]='d'
		delete from #temp_final_1 where volume_left=0


		INSERT INTO #temp_final(sub,env_product,technology,jurisdiction,assignment,[type],vintage,totalvolume,curve_id)
		SELECT sub,env_product,technology,jurisdiction,assignment,[type],vintage,totalvolume,curve_id FROM #temp_final_1


--		INSERT INTO #temp_final(sub,env_product,technology,jurisdiction,assignment,[type],vintage,totalvolume,curve_id)
--		SELECT	DISTINCT
--			a.sub,a.env_product,a.technology,a.jurisdiction,'Banked-'+CAST(a.vintage AS VARCHAR),'',a.vintage,-1 * b.totalvolume,a.curve_id		
--		FROM
--			#temp_final a
--			INNER JOIN #temp_final_1 b ON a.sub=b.sub AND a.env_product=b.env_product AND a.vintage=SUBSTRING(b.assignment,CHARINDEX('-',b.assignment)+1,LEN(b.assignment))
--	
			SELECT  @listCol = STUFF(( SELECT DISTINCT '],[' + (((CASE WHEN @carry_forward='y' THEN CASE WHEN vintage<YEAR(@as_of_date) THEN ' Carry Forward' ELSE vintage END ELSE vintage END)))
				 FROM    #temp_final WHERE vintage>0
					   ORDER BY '],[' + (((CASE WHEN @carry_forward='y' THEN CASE WHEN vintage<YEAR(@as_of_date) THEN ' Carry Forward' ELSE vintage END ELSE vintage END))) FOR XML PATH('')), 1, 2, '') + ']'
			IF @listCol IS NULL
				SET @listCol='[0]'
			
			SELECT  @listCol_tot = STUFF(( SELECT DISTINCT '],0)+ISNULL([' + (((CASE WHEN @carry_forward='y' THEN CASE WHEN vintage<YEAR(@as_of_date) THEN ' Carry Forward' ELSE vintage END ELSE vintage END)))
				 FROM    #temp_final WHERE vintage>0
					   ORDER BY '],0)+ISNULL([' + (((CASE WHEN @carry_forward='y' THEN CASE WHEN vintage<YEAR(@as_of_date) THEN ' Carry Forward' ELSE vintage END ELSE vintage END))) FOR XML PATH('')), 1, 4, '') + '],0)'
			IF @listCol_tot IS NULL
				SET @listCol_tot='[0]'
				
		
			IF @udf_group1 is not null
			SET @sql_select=@sql_select +' and udf_group1='''+cast(@udf_group1 as varchar) +''''	

			
			IF @udf_group2 is not null
			SET @sql_select=@sql_select +' and udf_group2='''+cast(@udf_group2 as varchar) +''''	
			
			IF @udf_group3 is not null
			SET @sql_select=@sql_select +' and udf_group3='''+cast(@udf_group3 as varchar) +''''	


			CREATE TABLE #inventory_wght_avg_cost(

				curve_id INT,
				vintage INT,
				wght_avg_cost FLOAT
			)

			INSERT INTO #inventory_wght_avg_cost(curve_id,vintage,wght_avg_cost)
			SELECT 558,2007,7.12
			UNION
			SELECT 560,2007,47.93
			UNION
			SELECT 559,2007,0


		SELECT DISTINCT
			spc.curve_source_value_id,
			spc.source_curve_def_id,
			spc.maturity_date,
			spc.as_of_date,
			spc.curve_value
		INTO #source_price_curve
		FROM #temp_final
		JOIN (select max(as_of_date) as_of_date,curve_source_value_id,YEAR(maturity_date) maturity_date,source_curve_def_id FROM source_price_curve group by source_curve_def_id,curve_source_value_id,YEAR(maturity_date))spc1
						ON spc1.curve_source_value_id=@curve_source_value_id
						  AND spc1.source_curve_def_id=curve_id	
						  AND spc1.maturity_date=vintage	
		 JOIN source_price_curve spc 
					  ON spc.curve_source_value_id=spc1.curve_source_value_id
					   AND spc.source_curve_def_id=spc1.source_curve_def_id
					   AND YEAR(spc.maturity_date)=(spc1.maturity_date)
					   AND spc.as_of_date=spc1.as_of_date


	DECLARE cur3 CURSOR FOR
		SELECT sub,curve_id,jurisdiction,vintage FROM #temp_final where vintage>2007 GROUP BY sub,curve_id,jurisdiction,vintage
	OPEN cur3
	FETCH next from cur3 INTO @sub,@curve_id,@jurisdiction,@vintage
	WHILE @@FETCH_STATUS=0
	BEGIN

		INSERT INTO #inventory_wght_avg_cost(curve_id,vintage,wght_avg_cost)
		SELECT 
			curve_id,vintage,SUM(cost)/SUM(TotalVolume)
			FROM(
			select 
					a.curve_id,a.vintage,SUM(TotalVolume)TotalVolume,SUM(TotalVolume*ISNULL(b.wght_avg_cost,a.fixed_price)) as COST
			
				from 
					#temp_final a
					left JOIN #inventory_wght_avg_cost b ON a.curve_id=b.curve_id
					AND CAST(b.vintage AS VARCHAR)=SUBSTRING(a.assignment,CHARINDEX('-',a.assignment)+1,LEN(a.assignment))
				where (a.totalvolume>0 OR assignment='Sale')
					AND sub=@sub and a.curve_id=@curve_id and @jurisdiction=jurisdiction and a.vintage=@vintage
				group by a.curve_id,a.vintage
			UNION
				select a.curve_id,a.vintage,abs(SUM(TotalVolume)),abs(SUM(TotalVolume))*MAX(spc.curve_value) AS COST
				from #temp_final a  
				 LEFT JOIN #source_price_curve spc ON 
											   spc.curve_source_value_id=@curve_source_value_id
											   AND spc.source_curve_def_id=curve_id
											   AND YEAR(spc.maturity_date)=vintage
				where  sub=@sub and a.curve_id=@curve_id and @jurisdiction=jurisdiction and a.vintage=@vintage	
				group by a.curve_id,a.vintage having SUM(TotalVOlume)<0
			)a	GROUP BY curve_id,vintage
		FETCH next from cur3 INTO @sub,@curve_id,@jurisdiction,@vintage
	END
	CLOSE cur3
	DEALLOCATE cur3

	IF @report_type='t'
			SELECT @sql_select=
				'SELECT Sub AS '+CASE WHEN @summary_option='s' THEN '[Sub]' WHEN @summary_option='e' THEN '[Env Product]' WHEN @summary_option='l' THEN  '[Technology]' ELSE '[Tier Type]' END +',
					env_product AS '+CASE WHEN @summary_option='s' THEN '[Env Product]'   WHEN @summary_option='t' THEN '[Sub]' ELSE '[Sub]' END +',
					Assignment,[type] [Type],Jurisdiction,'+@listCol+','+@listCol_tot+' AS Total '+ @str_batch_table +'
				FROM
				(SELECT 
					sub,jurisdiction,CASE WHEN '''+@carry_forward+'''=''y'' THEN CASE WHEN vintage<YEAR('''+CAST(@as_of_date AS VARCHAR)+''') THEN '' Carry Forward'' ELSE vintage END ELSE vintage END AS vintage,assignment,env_product,[type],TotalVolume
				FROM #temp_final) p
				PIVOT
				(
					SUM(TotalVolume) FOR vintage IN('+@listCol+')) AS pvt
				ORDER BY '+CASE WHEN @summary_option='s' THEN '[Sub]' WHEN @summary_option='e' THEN '[Env Product]' WHEN @summary_option='l' THEN '[Technology]' ELSE '[Tier Type]' END +
				CASE WHEN @summary_option='s' THEN ',[Env Product]'   WHEN @summary_option='t' THEN ',[Sub]' ELSE ',[Sub]' END+',jurisdiction,assignment'

		ELSE IF @report_type='p'
		BEGIN
			SELECT @sql_select=
				'SELECT Sub AS '+CASE WHEN @summary_option='s' THEN '[Sub]' WHEN @summary_option='e' THEN '[Env Product]' WHEN @summary_option='l' THEN  '[Technology]' ELSE '[Tier Type]' END +',
					env_product AS '+CASE WHEN @summary_option='s' THEN '[Env Product]'   WHEN @summary_option='t' THEN '[Sub]' ELSE '[Sub]' END +',
					[type] [Type],Assignment,Jurisdiction,'+@listCol+','+@listCol_tot+' AS Total '+ @str_batch_table +'
				FROM
				(SELECT 
					sub,jurisdiction,CASE WHEN '''+@carry_forward+'''=''y'' THEN CASE WHEN vintage<YEAR('''+CAST(@as_of_date AS VARCHAR)+''') THEN '' Carry Forward'' ELSE vintage END ELSE vintage END AS vintage,
						CASE WHEN ISNULL(isJurisdiction,''n'')=''y'' AND assignment IN(''Banked'') THEN ''Allocated Allowance'' 
							 WHEN assignment IN(''Banked'',''Sale'') AND [Type] IN(''Actual'',''Forward'') THEN ''Purchases, Trades, Swaps'' 
							 WHEN assignment IN(''Banked'') AND [type] IN(''Projected'') THEN ''Projected Emissions'' 
							 WHEN assignment IN(''Emissions'') THEN ''Projected Emissions'' 
							 ELSE assignment END as assignment, 
						env_product,''Position'' as [type],TotalVolume
					FROM #temp_final
				) p
				PIVOT
				(
					SUM(TotalVolume) FOR vintage IN('+@listCol+')) AS pvt'
				+' UNION '+
				'SELECT Sub AS '+CASE WHEN @summary_option='s' THEN '[Sub]' WHEN @summary_option='e' THEN '[Env Product]' WHEN @summary_option='l' THEN  '[Technology]' ELSE '[Tier Type]' END +',
					env_product AS '+CASE WHEN @summary_option='s' THEN '[Env Product]'   WHEN @summary_option='t' THEN '[Sub]' ELSE '[Sub]' END +',
					[type] [Type],Assignment,Jurisdiction,'+@listCol+','+@listCol_tot+' AS Total
				FROM
				(SELECT 
					sub,jurisdiction,CASE WHEN '''+@carry_forward+'''=''y'' THEN CASE WHEN vintage<YEAR('''+CAST(@as_of_date AS VARCHAR)+''') THEN '' Carry Forward'' ELSE vintage END ELSE vintage END AS vintage,
						''Projected Purchase Cost (K$)'' as assignment, 
						env_product,''Cost'' as [type],ROUND((-1*SUM(TotalVolume)*MAX(spc.curve_value))/1000,'+@round_value+') TotalCost
					FROM #temp_final tf
						 LEFT JOIN #source_price_curve spc ON spc.curve_source_value_id='+CAST(@curve_source_value_id AS VARCHAR)+'	
								   AND spc.source_curve_def_id=curve_id
								   AND YEAR(spc.maturity_date)=vintage
					GROUP BY sub,jurisdiction,Vintage,env_product	
					HAVING SUM(TotalVolume)<0
				) p
				PIVOT
				(
					SUM(TotalCost) FOR vintage IN('+@listCol+')) AS pvt
				ORDER BY '+CASE WHEN @summary_option='s' THEN '[Sub]' WHEN @summary_option='e' THEN '[Env Product]' WHEN @summary_option='l' THEN '[Technology]' ELSE '[Tier Type]' END +
				CASE WHEN @summary_option='s' THEN ',[Env Product]'   WHEN @summary_option='t' THEN ',[Sub]' ELSE ',[Sub]' END+',[type] desc,jurisdiction,assignment'
			
			
		END
		ELSE IF @report_type='c'
			SELECT @sql_select=
				'SELECT Sub AS '+CASE WHEN @summary_option='s' THEN '[Sub]' WHEN @summary_option='e' THEN '[Env Product]' WHEN @summary_option='l' THEN  '[Technology]' ELSE '[Tier Type]' END +',
					env_product AS '+CASE WHEN @summary_option='s' THEN '[Env Product]'   WHEN @summary_option='t' THEN '[Sub]' ELSE '[Sub]' END +',
					[type] [Type],Assignment,Jurisdiction,'+@listCol+','+@listCol_tot+' AS Total '+ @str_batch_table +'
				FROM
				(SELECT 
					sub,#temp_final.jurisdiction,CASE WHEN '''+@carry_forward+'''=''y'' THEN CASE WHEN #temp_final.vintage<YEAR('''+CAST(@as_of_date AS VARCHAR)+''') THEN '' Carry Forward'' ELSE #temp_final.vintage END ELSE #temp_final.vintage END AS vintage,
						CASE WHEN ISNULL(isJurisdiction,''n'')=''y'' AND assignment IN(''Banked'') THEN ''Allocated Allowance'' 
							 WHEN assignment IN(''Banked'',''Sale'') AND [Type] IN(''Actual'',''Forward'') THEN ''Purchases, Trades, Swaps'' 
							 WHEN assignment IN(''Banked'') AND [type] IN(''Projected'') THEN ''Projected Emissions'' 
							 WHEN assignment IN(''Emissions'') THEN ''Projected Emissions'' 
							 ELSE SUBSTRING(assignment,1,CASE WHEN (CHARINDEX(''-'',assignment)-1)>0 THEN (CHARINDEX(''-'',assignment)-1) ELSE LEN(assignment) END) END as assignment, 
						env_product,''Position'' as [type],TotalVolume*ISNULL(wacog.wght_avg_cost,fixed_price) As Cost
					FROM #temp_final
						 LEFT JOIN #inventory_wght_avg_cost wacog
							  ON CAST(wacog.vintage AS VARCHAR)=SUBSTRING(assignment,CHARINDEX(''-'',assignment)+1,LEN(assignment))
							   AND wacog.curve_id=#temp_final.curve_id
				) p
				PIVOT
				(
					SUM(Cost) FOR vintage IN('+@listCol+')) AS pvt'
				+' UNION '+
				'SELECT Sub AS '+CASE WHEN @summary_option='s' THEN '[Sub]' WHEN @summary_option='e' THEN '[Env Product]' WHEN @summary_option='l' THEN  '[Technology]' ELSE '[Tier Type]' END +',
					env_product AS '+CASE WHEN @summary_option='s' THEN '[Env Product]'   WHEN @summary_option='t' THEN '[Sub]' ELSE '[Sub]' END +',
					[type] [Type],Assignment,Jurisdiction,'+@listCol+','+@listCol_tot+' AS Total
				FROM
				(SELECT 
					sub,jurisdiction,CASE WHEN '''+@carry_forward+'''=''y'' THEN CASE WHEN vintage<YEAR('''+CAST(@as_of_date AS VARCHAR)+''') THEN '' Carry Forward'' ELSE vintage END ELSE vintage END AS vintage,
						''Cost of Additional Purchases Needed'' as assignment, 
						env_product,''Cost'' as [type],(-1*SUM(TotalVolume)*MAX(spc.curve_value)) TotalCost
					FROM #temp_final tf
						 LEFT JOIN #source_price_curve spc ON spc.curve_source_value_id='+CAST(@curve_source_value_id AS VARCHAR)+'	
								   AND spc.source_curve_def_id=curve_id
								   AND YEAR(spc.maturity_date)=vintage
					GROUP BY sub,jurisdiction,Vintage,env_product	
					HAVING SUM(TotalVolume)<0
				) p
				PIVOT
				(
					SUM(TotalCost) FOR vintage IN('+@listCol+')) AS pvt'
				+' UNION '+
				' SELECT Sub AS '+CASE WHEN @summary_option='s' THEN '[Sub]' WHEN @summary_option='e' THEN '[Env Product]' WHEN @summary_option='l' THEN  '[Technology]' ELSE '[Tier Type]' END +',
					env_product AS '+CASE WHEN @summary_option='s' THEN '[Env Product]'   WHEN @summary_option='t' THEN '[Sub]' ELSE '[Sub]' END +',
					[type] [Type],Assignment,Jurisdiction,'+@listCol+','+@listCol_tot+' AS Total
				FROM
				(SELECT 
					sub,jurisdiction,CASE WHEN '''+@carry_forward+'''=''y'' THEN CASE WHEN tf.vintage<YEAR('''+CAST(@as_of_date AS VARCHAR)+''') THEN '' Carry Forward'' ELSE tf.vintage END ELSE tf.vintage END AS vintage,
						''Cost of Allowances Used'' as assignment, 
						env_product,''Cost'' as [type],SUM(abs(TotalVolume)*wacog.wght_avg_cost) TotalCost
					FROM #temp_final tf
						 LEFT JOIN #inventory_wght_avg_cost wacog ON tf.curve_id=wacog.curve_id
								   AND tf.vintage=wacog.vintage	
											WHERE assignment IN(''Emissions'') OR assignment IN(''Cap and Trade'') OR(assignment IN(''Banked'') AND [type] in(''Projected''))
					GROUP BY sub,jurisdiction,tf.Vintage,env_product	
					
				) p
				PIVOT
				(
					SUM(TotalCost) FOR vintage IN('+@listCol+')) AS pvt
				ORDER BY '+CASE WHEN @summary_option='s' THEN '[Sub]' WHEN @summary_option='e' THEN '[Env Product]' WHEN @summary_option='l' THEN '[Technology]' ELSE '[Tier Type]' END +
				CASE WHEN @summary_option='s' THEN ',[Env Product]'   WHEN @summary_option='t' THEN ',[Sub]' ELSE ',[Sub]' END+',[type] desc,jurisdiction,assignment'


		ELSE IF @report_type='u'
		BEGIN

			SELECT @sql_select=
				'SELECT Sub AS '+CASE WHEN @summary_option='s' THEN '[Sub]' WHEN @summary_option='e' THEN '[Env Product]' WHEN @summary_option='l' THEN  '[Technology]' ELSE '[Tier Type]' END +',
					env_product AS '+CASE WHEN @summary_option='s' THEN '[Env Product]'   WHEN @summary_option='t' THEN '[Sub]' ELSE '[Sub]' END +',
					[type] [Type],Assignment,Jurisdiction,'+@listCol+','+@listCol_tot+' AS Total '+ @str_batch_table +'
				FROM
				(SELECT 
					sub,#temp_final.jurisdiction,CASE WHEN '''+@carry_forward+'''=''y'' THEN CASE WHEN #temp_final.vintage<YEAR('''+CAST(@as_of_date AS VARCHAR)+''') THEN '' Carry Forward'' ELSE #temp_final.vintage END ELSE #temp_final.vintage END AS vintage,
						CASE WHEN ISNULL(isJurisdiction,''n'')=''y'' AND assignment IN(''Banked'') THEN ''Banked'' 
							 WHEN assignment IN(''Banked'',''Sale'') AND [Type] IN(''Actual'',''Forward'') THEN ''Purchases, Trades, Swaps'' 
							 WHEN assignment IN(''Banked'') AND [type] IN(''Projected'') THEN ''Projected Emissions'' 
							 WHEN assignment IN(''Emissions'') THEN ''Projected Emissions'' 
							 ELSE SUBSTRING(assignment,1,CASE WHEN (CHARINDEX(''-'',assignment)-1)>0 THEN (CHARINDEX(''-'',assignment)-1) ELSE LEN(assignment) END) END as assignment, 
						env_product,''Position'' as [type],ISNULL(MAX(wacog.wght_avg_cost),SUM(TotalVOlume*ISNULL(wacog.wght_avg_cost,fixed_price))/ISNULL(NULLIF(SUM(TotalVolume),0),1)) As UnitCost
					FROM #temp_final
						 LEFT JOIN #inventory_wght_avg_cost wacog
							  ON CAST(wacog.vintage+1 AS VARCHAR)=#temp_final.vintage
							   AND wacog.curve_id=#temp_final.curve_id
							   AND (CHARINDEX(''-'',assignment)-1)<=0		
							   AND ISNULL(isJurisdiction,''n'')=''y'' AND assignment IN(''Banked'')	
						GROUP BY sub,#temp_final.jurisdiction,#temp_final.vintage,env_product,isJurisdiction,
							 CASE WHEN ISNULL(isJurisdiction,''n'')=''y'' AND assignment IN(''Banked'') THEN ''Banked'' 
							 WHEN assignment IN(''Banked'',''Sale'') AND [Type] IN(''Actual'',''Forward'') THEN ''Purchases, Trades, Swaps'' 
							 WHEN assignment IN(''Banked'') AND [type] IN(''Projected'') THEN ''Projected Emissions'' 
							 WHEN assignment IN(''Emissions'') THEN ''Projected Emissions'' 
							 ELSE SUBSTRING(assignment,1,CASE WHEN (CHARINDEX(''-'',assignment)-1)>0 THEN (CHARINDEX(''-'',assignment)-1) ELSE LEN(assignment) END) END 
							
				) p
				PIVOT
				(
					SUM(UnitCost) FOR vintage IN('+@listCol+')) AS pvt'
				+' UNION '+
				'SELECT Sub AS '+CASE WHEN @summary_option='s' THEN '[Sub]' WHEN @summary_option='e' THEN '[Env Product]' WHEN @summary_option='l' THEN  '[Technology]' ELSE '[Tier Type]' END +',
					env_product AS '+CASE WHEN @summary_option='s' THEN '[Env Product]'   WHEN @summary_option='t' THEN '[Sub]' ELSE '[Sub]' END +',
					[type] [Type],Assignment,Jurisdiction,'+@listCol+','+@listCol_tot+' AS Total
				FROM
				(SELECT 
					sub,jurisdiction,CASE WHEN '''+@carry_forward+'''=''y'' THEN CASE WHEN vintage<YEAR('''+CAST(@as_of_date AS VARCHAR)+''') THEN '' Carry Forward'' ELSE vintage END ELSE vintage END AS vintage,
						''Cost of Additional Purchases Needed'' as assignment, 
						env_product,''Cost'' as [type],MAX(spc.curve_value) UnitCost
					FROM #temp_final tf
						 LEFT JOIN #source_price_curve spc ON spc.curve_source_value_id='+CAST(@curve_source_value_id AS VARCHAR)+'	
								   AND spc.source_curve_def_id=curve_id
								   AND YEAR(spc.maturity_date)=vintage
					GROUP BY sub,jurisdiction,Vintage,env_product	
					HAVING SUM(TotalVolume)<0
				) p
				PIVOT
				(
					SUM(UnitCost) FOR vintage IN('+@listCol+')) AS pvt'
				+' UNION '+
				' SELECT Sub AS '+CASE WHEN @summary_option='s' THEN '[Sub]' WHEN @summary_option='e' THEN '[Env Product]' WHEN @summary_option='l' THEN  '[Technology]' ELSE '[Tier Type]' END +',
					env_product AS '+CASE WHEN @summary_option='s' THEN '[Env Product]'   WHEN @summary_option='t' THEN '[Sub]' ELSE '[Sub]' END +',
					[type] [Type],Assignment,Jurisdiction,'+@listCol+','+@listCol_tot+' AS Total
				FROM
				(SELECT 
					sub,jurisdiction,CASE WHEN '''+@carry_forward+'''=''y'' THEN CASE WHEN tf.vintage<YEAR('''+CAST(@as_of_date AS VARCHAR)+''') THEN '' Carry Forward'' ELSE tf.vintage END ELSE tf.vintage END AS vintage,
						''Total Allowance/Ton'' as assignment, 
						env_product,''Cost'' as [type],MAX(wacog.wght_avg_cost) UnitCost
					FROM #temp_final tf
						 LEFT JOIN #inventory_wght_avg_cost wacog ON tf.curve_id=wacog.curve_id
								   AND tf.vintage=wacog.vintage	
											WHERE assignment IN(''Emissions'') OR assignment IN(''Cap and Trade'') OR(assignment IN(''Banked'') AND [type] in(''Projected''))
					GROUP BY sub,jurisdiction,tf.Vintage,env_product	
					
				) p
				PIVOT
				(
					SUM(UnitCost) FOR vintage IN('+@listCol+')) AS pvt
				ORDER BY '+CASE WHEN @summary_option='s' THEN '[Sub]' WHEN @summary_option='e' THEN '[Env Product]' WHEN @summary_option='l' THEN '[Technology]' ELSE '[Tier Type]' END +
				CASE WHEN @summary_option='s' THEN ',[Env Product]'   WHEN @summary_option='t' THEN ',[Sub]' ELSE ',[Sub]' END+',[type] desc,jurisdiction,assignment'


		END
		exec spa_print @sql_select
		EXEC(@sql_select)
		if isnull(@str_batch_table	,'')<>'' -- for paging
		begin	
			set @sql_select='alter TABLE ' + replace(@str_batch_table,'INTO','')+' ADD ROWID INT IDENTITY(1,1)' --coz ROWID=IDENTITY(int,1,1) is not support in Union
			exec spa_print @sql_select
			EXEC(@sql_select)		
		end
	
if @is_batch = 1
begin
	exec spa_print '@str_batch_table'  
	 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)   
		   exec spa_print @str_batch_table
	 EXEC(@str_batch_table)                   
	        
	 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_REC_Exposure_Report','Run REC Exposure Report')         
	 EXEC spa_print @str_batch_table
	 EXEC(@str_batch_table)        
	EXEC spa_print 'finsh spa_REC_Exposure_Report'
	return
END

IF @enable_paging = 1
BEGIN
		IF @page_size IS NULL
		BEGIN
			set @sql_stmt='select count(*) TotalRow,'''+@batch_process_id +''' process_id  from '+ @temptablename
			EXEC spa_print @sql_stmt
			exec(@sql_stmt)
		end
END 
