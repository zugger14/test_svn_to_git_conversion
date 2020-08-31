
/****** Object:  StoredProcedure [dbo].[spa_REC_Target_Report]    Script Date: 10/06/2009 12:38:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_REC_Target_Report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_REC_Target_Report]
/****** Object:  StoredProcedure [dbo].[spa_REC_Target_Report]    Script Date: 10/06/2009 12:38:49 ******/
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
CREATE  PROC [dbo].[spa_REC_Target_Report]
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
	@batch_report_param varchar(500)=NULL, 
	@enable_paging int=0,  --'1'=enable, '0'=disable
	@page_size int =NULL,
	@page_no int=NULL
 AS
 
--SET NOCOUNT ON
-- CALL ACTIVITY REPORT
DECLARE @listCol VARCHAR(1000),@sql_select VARCHAR(5000),@listCol_tot VARCHAR(5000),@listCol_sel VARCHAR(5000)



--////////////////////////////Paging_Batch///////////////////////////////////////////
EXEC spa_print	'@batch_process_id:', @batch_process_id 
EXEC spa_print	'@batch_report_param:', @batch_report_param

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

			select @sql_stmt=@sql_stmt+',['+[name]+']' from adiha_process.sys.columns where [object_id]=object_id(@temptablename) and [name]<>'ROWID' ORDER BY column_id
			SET @sql_stmt=SUBSTRING(@sql_stmt,2,LEN(@sql_stmt))
			
			set @sql_stmt='select '+@sql_stmt +'
				  from '+ @temptablename   +' 
				  where rowid between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) 
				 
			exec spa_print @sql_stmt		
			exec(@sql_stmt)
			return
		END --else @page_size IS not NULL
	END --enable_paging = 1
		
end

--////////////////////////////End_Batch///////////////////////////////////////////




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


IF (@show_cross_tabformat='n' OR @summary_option='d') AND(@plot='n')
BEGIN
	IF @summary_option='x' OR @summary_option='d' or @summary_option='g'
	BEGIN

		IF @summary_option='g' -- called from exposure report
			SET @summary_option='g'
			
			
			IF @summary_option='s'
			begin
				create table #temp_final_p ( 
					[sub] [varchar] (100) COLLATE DATABASE_DEFAULT  ,
					[Assigned/Default Jurisdiction] [varchar] (250) COLLATE DATABASE_DEFAULT  ,
					[Compliance/Expiration Year] [varchar] (100) COLLATE DATABASE_DEFAULT ,
					[Assignment] [varchar] (100) COLLATE DATABASE_DEFAULT ,
					[EnvProduct] [varchar] (50) COLLATE DATABASE_DEFAULT ,
					[Type] [varchar] (50) COLLATE DATABASE_DEFAULT ,
					[volume] [float] NULL ,
					[Bonus] [float] NULL ,
					[TotalVolume(+Long,-Short)] [float] NULL ,
					[Unit] [varchar] (50) COLLATE DATABASE_DEFAULT
					)
					
				INSERT INTO #temp_final_p	
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
					@technology, 
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
					@Plot,
					@include_banked,
					@program_scope,
					@program_type,
					@round_value,
					@udf_group1,
					@udf_group2,
					@udf_group3,
					@tier_type,
					@include_expired					
						
					SELECT @sql_select='SELECT * '+ @str_get_row_number+' '+ @str_batch_table +' FROM #temp_final_p'
					EXEC(@sql_select)	
			end
			ELSE IF @summary_option='d'
				BEGIN
				CREATE TABLE #tmp(
					[Sub] [varchar](100) COLLATE DATABASE_DEFAULT NOT NULL,
					[Strategy] [varchar](100) COLLATE DATABASE_DEFAULT NOT NULL,
					[Book] [varchar](100) COLLATE DATABASE_DEFAULT NOT NULL,
					[Env Product] [varchar](100) COLLATE DATABASE_DEFAULT NOT NULL,
					[Tier Type] [varchar](500) COLLATE DATABASE_DEFAULT NOT NULL,
					[Technology] [varchar](500) COLLATE DATABASE_DEFAULT NOT NULL,
					[Assignment] [varchar](500) COLLATE DATABASE_DEFAULT NOT NULL,
					[Type] [varchar](9) COLLATE DATABASE_DEFAULT NOT NULL,
					[Assigned/Default Jurisdiction] [varchar](500) COLLATE DATABASE_DEFAULT NULL,
					[Gen State] [varchar](500) COLLATE DATABASE_DEFAULT NULL,
					[Compliance/Expiration Year] [int] NULL,
					[Vintage] [varchar](50) COLLATE DATABASE_DEFAULT NULL,
					[Certification ID From] [varchar](1006) COLLATE DATABASE_DEFAULT NULL,
					[Certification ID T0] [varchar](1006) COLLATE DATABASE_DEFAULT NULL,
					[Original Reference ID] [varchar](500) COLLATE DATABASE_DEFAULT NULL,
					[Volume] [float] NULL,
					[Bonus] [float] NOT NULL,
					[Total Volume (+Long, -Short)] [float] NULL,
					[UOM] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
					[Conversion Factor] [float] NULL
				) 

				INSERT INTO #tmp
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
					@technology, 
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
					@Plot,
					@include_banked,
					@program_scope,
					@program_type,
					@round_value,
					@udf_group1,
					@udf_group2,
					@udf_group3,
					@tier_type,
					@include_expired

					SELECT @sql_select='SELECT * '+ @str_get_row_number+' '+ @str_batch_table +' FROM #tmp'
					EXEC(@sql_select)	
								
				END
			else BEGIN

				DECLARE @call_from_drilldrown VARCHAR(1)
				
				SET @call_from_drilldrown='y'
				IF OBJECT_ID('tempdb..#temp_drill') IS NULL
				begin
					create table #temp_drill ( 
						--sno int  identity(1,1),
						[sub] [varchar] (100) COLLATE DATABASE_DEFAULT  ,
						[Strategy] [varchar] (100) COLLATE DATABASE_DEFAULT,
						[Book] [varchar] (100) COLLATE DATABASE_DEFAULT,
						[EnvProduct] [varchar] (100) COLLATE DATABASE_DEFAULT,
						[TierType] [varchar] (100) COLLATE DATABASE_DEFAULT,
						[Technology] [varchar] (100) COLLATE DATABASE_DEFAULT,
						[Assignment] [varchar] (200) COLLATE DATABASE_DEFAULT,
						[Type] [varchar] (100) COLLATE DATABASE_DEFAULT,			
						[Assigned/Default Jurisdiction] [varchar] (250) COLLATE DATABASE_DEFAULT  ,
						[GenState] [varchar] (250) COLLATE DATABASE_DEFAULT  ,
						[Compliance/Expiration Year] [varchar] (200) COLLATE DATABASE_DEFAULT ,
						[Vintage] [varchar] (200) COLLATE DATABASE_DEFAULT ,			
						[CertIDFrom] [varchar](100) COLLATE DATABASE_DEFAULT,
						[CertIDTo] [varchar](100) COLLATE DATABASE_DEFAULT,
						[Original RefID] [varchar](250) COLLATE DATABASE_DEFAULT,
						[volume] [float] NULL ,
						[Bonus] [float] NULL ,
						[TotalVolume(+Long,-Short)] [float] NULL ,
						[Unit] [varchar] (50) COLLATE DATABASE_DEFAULT,conversion_fact float
						)
					SET @call_from_drilldrown='n'
					SELECT @sql_select='SELECT * '+ @str_get_row_number+' '+ @str_batch_table +' FROM #temp_drill'	
				end

				INSERT INTO #temp_drill	
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
					@technology, 
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
					@Plot,
					@include_banked,
					@program_scope,
					@program_type,
					@round_value,
					@udf_group1,
					@udf_group2,
					@udf_group3,
					@tier_type,
					@include_expired		
				if @call_from_drilldrown='n'
					EXEC(@sql_select)	
			END
			
	END --@summary_option='x' OR @summary_option='d' or @summary_option='g'
	ELSE
	BEGIN

		INSERT INTO #temp_final
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
			@Plot,
			@include_banked,
			@program_scope,
			@program_type,
			@round_value,
			@udf_group1,
			@udf_group2,
			@udf_group3,
			@tier_type,
			@include_expired	
--				,
--				@batch_process_id,
--				@batch_report_param
		IF @summary_option='s'
			SELECT @sql_select='SELECT [Sub],env_product [Env Product],[Assignment],[Type],jurisdiction [Assigned/Default Jurisdiction],[Vintage],[Volume],[Bonus],TotalVolume [Total Volume (+Long, -Short)],UOM'+ @str_get_row_number+' '+ @str_batch_table +' FROM #temp_final'
		ELSE IF @summary_option='e'
			SELECT @sql_select='SELECT [Sub] [Env Product],env_product [Sub],[Assignment],[Type],jurisdiction [Assigned/Default Jurisdiction],[Vintage],[Volume],[Bonus],TotalVolume [Total Volume (+Long, -Short)],UOM '+ @str_get_row_number+' '+ @str_batch_table +'FROM #temp_final'
		ELSE IF @summary_option='t'
			SELECT @sql_select='SELECT [Sub] AS [Tier Type],
			                           env_product [Sub],
			                           [Assignment],
			                           [Type],
			                           jurisdiction 
			                           [Assigned/Default Jurisdiction],
			                           [Vintage],
			                           SUM([Volume]) [Volume],
			                           SUM([Bonus]) [Bonus],
			                           SUM(TotalVolume) [Total Volume (+Long, -Short)],
			                           UOM'+ @str_get_row_number+' 
			                           '+ @str_batch_table +'
			                    FROM   #temp_final
			                    GROUP BY Sub, env_product, Assignment, Type, jurisdiction, Vintage, UOM'
		ELSE IF @summary_option='l'
			SELECT @sql_select='SELECT [Sub] AS [Technology],
			                           env_product [Sub],
			                           [Assignment],
			                           [Type],
			                           jurisdiction [Assigned/Default Jurisdiction],
			                           [Vintage],
			                           SUM([Volume]) [Volume],
			                           SUM([Bonus]) [Bonus],
			                           SUM(TotalVolume) [Total Volume (+Long, -Short)],
			                           UOM'+ @str_get_row_number+' 
			                           '+ @str_batch_table +'
			                    FROM   #temp_final
			                    GROUP BY Sub, env_product, Assignment, Type, jurisdiction, Vintage, UOM
			                    '
		
		exec spa_print @sql_select
		exec(@sql_select)
	END --ELSE @summary_option='x' OR @summary_option='d' or @summary_option='g'
END	--(@show_cross_tabformat='n' OR @summary_option='d') AND(@plot='n')
ELSE 
BEGIN 
		EXEC spa_print '/***********************************/'
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
				@tier_type,
				@include_expired
	--			,
	--			@batch_process_id,
	--			@batch_report_param


		IF @plot='n'
		BEGIN

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
				SELECT sub,env_product,technology,jurisdiction,MAX(assignment),'d',YEAR(expiration),MAX(expiration),0,0,curve_id from #temp_final group by  sub,env_product,technology,jurisdiction,YEAR(expiration),vintage,curve_id


				DECLARE cur1 CURSOR FOR SELECT sub,[env_product],vintage,MAX(YEAR(expiration)),sum(totalvolume),curve_id
				 FROM #temp_final where 1=1 --and vintage =(2008)
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
						if @expire_year<=@vintage_actual -- Do nothing
							Set @volume_left=@volume_left
						ELSE IF @volume>=0  AND @expire_year=@vintage AND @volume_left>0
							BEGIN

								INSERT INTO #temp_final_1(sub,env_product,technology,jurisdiction,assignment,[type],vintage,totalvolume,volume_left,curve_id)
								SELECT 	@sub,@env_product,@tech,@jurisdiction,'Banked-'+CAST(@vintage_actual AS VARCHAR),'',@vintage,@volume_left,@volume_left,@curve_id
								SET @volume_left=0
	
							END
						ELSE IF @volume<0 AND @volume_left>0
							BEGIN
								
								SET @volume=CASE WHEN @expire_year=@vintage THEN @volume_left WHEN @volume_left<0 THEN abs(@volume_left)WHEN abs(@volume)>@volume_left THEN @volume_left ELSE abs(@volume) END	
								
								--SET @volume_left=CASE WHEN @volume_left<0 THEN @volume ELSE @volume_left END	
								INSERT INTO #temp_final_1(sub,env_product,technology,jurisdiction,assignment,[type],vintage,totalvolume,volume_left,curve_id)
								SELECT 	@sub,@env_product,@tech,@jurisdiction,'Banked-'+CAST(@vintage_actual AS VARCHAR),'',@vintage,@volume,@volume_left,@curve_id
								SET @volume_left=@volume_left-@volume
	
							END
						fetch next from cur2 into @sub,@env_product,@tech,@jurisdiction,@vintage,@Volume,@curve_id
					END
					CLOSE cur2
					DEALLOCATE cur2
					FETCH NEXT FROM cur1 INTO  @sub,@env_product,@vintage_actual,@expire_year,@actual_volume,@curve_id
				END
				CLOSE cur1
				DEALLOCATE cur1
			END --  @allocate_banked='y'
			
			
			delete from #temp_final where [type]='d'

			INSERT INTO #temp_final(sub,env_product,technology,jurisdiction,assignment,[type],vintage,totalvolume,curve_id)
			SELECT sub,env_product,technology,jurisdiction,assignment,[type],vintage,totalvolume,curve_id FROM #temp_final_1

			INSERT INTO #temp_final(sub,env_product,technology,jurisdiction,assignment,[type],vintage,totalvolume,curve_id)
			SELECT	DISTINCT
				a.sub,a.env_product,a.technology,a.jurisdiction,'Banked-'+CAST(a.vintage AS VARCHAR),'',a.vintage,-1 * b.totalvolume,a.curve_id		
			FROM
				#temp_final a
				INNER JOIN #temp_final_1 b ON a.sub=b.sub AND a.env_product=b.env_product AND a.vintage=SUBSTRING(b.assignment,CHARINDEX('-',b.assignment)+1,LEN(b.assignment))
	
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

			IF @report_type='t'
				SELECT @sql_select=
					'SELECT Sub AS '+CASE WHEN @summary_option='s' THEN '[Sub]' WHEN @summary_option='e' THEN '[Env Product]' WHEN @summary_option='l' THEN  '[Technology]' ELSE '[Tier Type]' END +',
						env_product AS '+CASE WHEN @summary_option='s' THEN '[Env Product]'   WHEN @summary_option='t' THEN '[Sub]' ELSE '[Sub]' END +',
						Assignment,[type] [Type],Jurisdiction,'+@listCol+','+@listCol_tot+' AS Total'+ @str_get_row_number+' '+ @str_batch_table +'
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
						[type] [Type],Assignment,Jurisdiction,'+@listCol+','+@listCol_tot+' AS Total'+ @str_get_row_number+' '+ @str_batch_table +'
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
							env_product,''Cost'' as [type],(-1*SUM(TotalVolume)*MAX(spc.curve_value))/1000 TotalCost
						FROM #temp_final tf
							 LEFT JOIN source_price_curve spc ON spc.curve_source_value_id='+CAST(@curve_source_value_id AS VARCHAR)+'	
									   AND spc.source_curve_def_id=curve_id
									   AND YEAR(spc.maturity_date)=vintage
						GROUP BY sub,jurisdiction,Vintage,env_product	
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
						[type] [Type],Assignment,Jurisdiction,'+@listCol+','+@listCol_tot+' AS Total'+ @str_get_row_number+' '+ @str_batch_table +'
					FROM
					(SELECT 
						sub,#temp_final.jurisdiction,CASE WHEN '''+@carry_forward+'''=''y'' THEN CASE WHEN #temp_final.vintage<YEAR('''+CAST(@as_of_date AS VARCHAR)+''') THEN '' Carry Forward'' ELSE #temp_final.vintage END ELSE #temp_final.vintage END AS vintage,
							CASE WHEN ISNULL(isJurisdiction,''n'')=''y'' AND assignment IN(''Banked'') THEN ''Allocated Allowance'' 
								 WHEN assignment IN(''Banked'',''Sale'') AND [Type] IN(''Actual'',''Forward'') THEN ''Purchases, Trades, Swaps'' 
								 WHEN assignment IN(''Banked'') AND [type] IN(''Projected'') THEN ''Projected Emissions'' 
								 WHEN assignment IN(''Emissions'') THEN ''Projected Emissions'' 
								 ELSE assignment END as assignment, 
							env_product,''Position'' as [type],TotalVolume*ISNULL(wacog.wght_avg_cost,fixed_price) As Cost
						FROM #temp_final
							 LEFT JOIN inventory_account_type iat ON iat.group_id=1
								  AND CAST(iat.vintage AS VARCHAR)=SUBSTRING(assignment,CHARINDEX(''-'',assignment)+1,LEN(assignment))
								  AND iat.curve_id=#temp_final.curve_id
							 LEFT JOIN calcprocess_inventory_wght_avg_cost wacog ON wacog.group_id=iat.group_id
								  AND wacog.gl_account_id=iat.gl_account_id
								
								
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
							 LEFT JOIN source_price_curve spc ON spc.curve_source_value_id='+CAST(@curve_source_value_id AS VARCHAR)+'	
									   AND spc.source_curve_def_id=curve_id
									   AND YEAR(spc.maturity_date)=vintage
						GROUP BY sub,jurisdiction,Vintage,env_product	
					) p
					PIVOT
					(
						SUM(TotalCost) FOR vintage IN('+@listCol+')) AS pvt
					ORDER BY '+CASE WHEN @summary_option='s' THEN '[Sub]' WHEN @summary_option='e' THEN '[Env Product]' WHEN @summary_option='l' THEN '[Technology]' ELSE '[Tier Type]' END +
					CASE WHEN @summary_option='s' THEN ',[Env Product]'   WHEN @summary_option='t' THEN ',[Sub]' ELSE ',[Sub]' END+',[type] desc,jurisdiction,assignment'


			ELSE IF @report_type='u'
			BEGIN

				SELECT  @listCol_sel = STUFF(( SELECT DISTINCT '],0),1) AS [' + (((CASE WHEN @carry_forward='y' THEN CASE WHEN vintage<YEAR(@as_of_date) THEN ' Carry Forward' ELSE vintage END ELSE vintage END)))+'],a.[' + (((CASE WHEN @carry_forward='y' THEN CASE WHEN vintage<YEAR(@as_of_date) THEN ' Carry Forward' ELSE vintage END ELSE vintage END)))+']/ISNULL(NULLIF(b.[' + (((CASE WHEN @carry_forward='y' THEN CASE WHEN vintage<YEAR(@as_of_date) THEN ' Carry Forward' ELSE vintage END ELSE vintage END)))
					 FROM    #temp_final WHERE vintage>0
						   ORDER BY '],0),1) AS [' + (((CASE WHEN @carry_forward='y' THEN CASE WHEN vintage<YEAR(@as_of_date) THEN ' Carry Forward' ELSE vintage END ELSE vintage END)))+'],a.[' + (((CASE WHEN @carry_forward='y' THEN CASE WHEN vintage<YEAR(@as_of_date) THEN ' Carry Forward' ELSE vintage END ELSE vintage END)))+']/ISNULL(NULLIF(b.[' + (((CASE WHEN @carry_forward='y' THEN CASE WHEN vintage<YEAR(@as_of_date) THEN ' Carry Forward' ELSE vintage END ELSE vintage END))) FOR XML PATH('')), 1, 18, '') + '],0),1)'
				IF @listCol_sel IS NULL
					SET @listCol='[0]'


					SELECT @sql_select=
						'
					SELECT a.Sub AS '+CASE WHEN @summary_option='s' THEN '[Sub]' WHEN @summary_option='e' THEN '[Env Product]' WHEN @summary_option='l' THEN  '[Technology]' ELSE '[Tier Type]' END +',
							a.env_product AS '+CASE WHEN @summary_option='s' THEN '[Env Product]'   WHEN @summary_option='t' THEN '[Sub]' ELSE '[Sub]' END +',
							a.[type] [Type],a.Assignment,a.Jurisdiction,'+@listCol_sel+', a.Total'+ @str_get_row_number+' '+ @str_batch_table +'
					FROM
					(SELECT Sub,env_product,
							[type],Assignment,Jurisdiction,'+@listCol+','+@listCol_tot+' AS Total
						FROM
						(SELECT 
							sub,jurisdiction,CASE WHEN '''+@carry_forward+'''=''y'' THEN CASE WHEN vintage<YEAR('''+CAST(@as_of_date AS VARCHAR)+''') THEN '' Carry Forward'' ELSE vintage END ELSE vintage END AS vintage,
								CASE WHEN ISNULL(isJurisdiction,''n'')=''y'' AND assignment IN(''Banked'') THEN ''Allocated Allowance'' 
									 WHEN assignment IN(''Banked'',''Sale'') AND [Type] IN(''Actual'',''Forward'') THEN ''Purchases, Trades, Swaps'' 
									 WHEN assignment IN(''Banked'') AND [type] IN(''Projected'') THEN ''Projected Emissions'' 
									 WHEN assignment IN(''Emissions'') THEN ''Projected Emissions'' 
									 ELSE assignment END as assignment, 
								env_product,''Position'' as [type],TotalVolume*fixed_price As Cost
							FROM #temp_final
								
						) p
						PIVOT
						(
							SUM(Cost) FOR vintage IN('+@listCol+')) AS pvt)a'
					+' LEFT JOIN 
					(SELECT Sub,env_product,[type] ,Assignment,Jurisdiction,'+@listCol+','+@listCol_tot+' AS Total
						FROM
						(SELECT 
							sub,jurisdiction,CASE WHEN '''+@carry_forward+'''=''y'' THEN CASE WHEN vintage<YEAR('''+CAST(@as_of_date AS VARCHAR)+''') THEN '' Carry Forward'' ELSE vintage END ELSE vintage END AS vintage,
								CASE WHEN ISNULL(isJurisdiction,''n'')=''y'' AND assignment IN(''Banked'') THEN ''Allocated Allowance'' 
									 WHEN assignment IN(''Banked'',''Sale'') AND [Type] IN(''Actual'',''Forward'') THEN ''Purchases, Trades, Swaps'' 
									 WHEN assignment IN(''Banked'') AND [type] IN(''Projected'') THEN ''Projected Emissions'' 
									 WHEN assignment IN(''Emissions'') THEN ''Projected Emissions'' 
									 ELSE assignment END as assignment, 
								env_product,''Position'' as [type],(TotalVolume) As TotalVolume
							FROM #temp_final
								
						) p
						PIVOT
						(
							SUM(TotalVolume) FOR vintage IN('+@listCol+')) AS pvt) b

						ON a.sub=b.sub AND a.jurisdiction=b.jurisdiction 
						AND a.env_product=b.env_product AND a.assignment=b.assignment and a.type=b.type'
				
			END
			EXEC(@sql_select)		
	END	--@plot='n'
	ELSE
		BEGIN

			SELECT  @listCol = STUFF(( SELECT DISTINCT '],[' + ltrim(assignment+' '+ [type])
				 FROM    #temp_final WHERE vintage>0
					   ORDER BY '],[' + ltrim(assignment+' '+ [type]) FOR XML PATH('')), 1, 2, '') + ']'
				

   	
			SELECT @sql_select=	
				CASE WHEN @listCol IS NOT NULL	THEN		
					'SELECT vintage,'+ @listCol + @str_get_row_number+' '+ @str_batch_table +' FROM
					(SELECT 
						vintage,assignment+'' ''+ [type] AS [assignment],ABS(TotalVolume)Volume
					FROM #temp_final WHERE vintage>0) p
					PIVOT
					(
						SUM(Volume) FOR assignment IN('+@listCol+')) AS pvt
					ORDER BY vintage'
				ELSE
					'SELECT * FROM #temp_final WHERE 1=2'
				END	

				
			EXEC(@sql_select)	
		END ---else @plot='n'
		

END ---else --(@show_cross_tabformat='n' OR @summary_option='d') AND(@plot='n')

EXEC spa_print 'finsh spa_REC_Target_Report'



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





