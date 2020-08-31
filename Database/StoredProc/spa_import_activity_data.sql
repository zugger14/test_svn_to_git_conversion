
/****** Object:  StoredProcedure [dbo].[spa_import_activity_data]    Script Date: 07/04/2009 19:23:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_import_activity_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_activity_data]
/****** Object:  StoredProcedure [dbo].[spa_import_activity_data]    Script Date: 07/04/2009 19:23:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Created By: Anal Shrestha
Created On:Sept 02 2008
Comments: This SP is used to import activity data. This will insert data in the table ems_gen_input
exec [spa_import_activity_data] 'adiha_process.dbo.Activity_Data_farrms_admin_07A43872_C045_4831_B9A7_ADBE52836E35','as','asd','asdasdad','farrms_admin'

*/

CREATE proc [dbo].[spa_import_activity_data]
	@temp_table_name varchar(100),  
	@table_id varchar(100),  
	@job_name varchar(100),  
	@process_id varchar(100),  
	@user_login_id varchar(50)  
  
AS
BEGIN  
---**************************************************************************
--declare @temp_table_name varchar(100),  
--	@table_id varchar(100),  
--	@job_name varchar(100),  
--	@process_id varchar(100),  
--	@user_login_id varchar(50)  
--	select 
--	@temp_table_name='adiha_process.dbo.Activity_Data_farrms_admin_07A43872_C045_4831_B9A7_ADBE52836E35',  
--	@table_id='ooo',  
--	@job_name='aa',  
--	@process_id='aaa',  
--	@user_login_id='farrms_admin'  
	
--******************************************************************************************
	DECLARE @sql varchar(8000)
	DECLARE @errorCount int
	DECLARE @all_row_count int

BEGIN TRY
	SET @errorCount = 0
	SET @process_id = REPLACE(newid(),'-','_')

	 CREATE TABLE #temp_activity
		(
			[id] int identity(1,1),
			Sub [varchar] (255) COLLATE DATABASE_DEFAULT,
			Stra [varchar] (255) COLLATE DATABASE_DEFAULT,
			Book [varchar] (255) COLLATE DATABASE_DEFAULT,
			FacilityID [varchar] (255) COLLATE DATABASE_DEFAULT,
			Unit [varchar] (255) COLLATE DATABASE_DEFAULT,
			ems_input [varchar](255) COLLATE DATABASE_DEFAULT,
			term_start[varchar](255) COLLATE DATABASE_DEFAULT,
			term_end [varchar](255) COLLATE DATABASE_DEFAULT,
			frequency [varchar](255) COLLATE DATABASE_DEFAULT,
			char1[varchar](255) COLLATE DATABASE_DEFAULT,
			char2[varchar](255) COLLATE DATABASE_DEFAULT,
			char3[varchar](255) COLLATE DATABASE_DEFAULT,
			char4[varchar](255) COLLATE DATABASE_DEFAULT,
			char5[varchar](255) COLLATE DATABASE_DEFAULT,
			char6[varchar](255) COLLATE DATABASE_DEFAULT,
			char7[varchar](255) COLLATE DATABASE_DEFAULT,
			char8[varchar](255) COLLATE DATABASE_DEFAULT,
			char9[varchar](255) COLLATE DATABASE_DEFAULT,
			char10[varchar](255) COLLATE DATABASE_DEFAULT,
			input_value [varchar](255) COLLATE DATABASE_DEFAULT,
			UOM [varchar](255) COLLATE DATABASE_DEFAULT
		)


	EXEC (
			'INSERT INTO
					 #temp_activity 
			 SELECT 
					NULLIF(ltrim(rtrim(sub)),''NULL''),
					NULLIF(ltrim(rtrim(Stra)),''NULL''),
					NULLIF(ltrim(rtrim(Book)),''NULL''),
					NULLIF(ltrim(rtrim(FacilityID)),''NULL''),
					NULLIF(ltrim(rtrim(Unit)),''NULL''),
					NULLIF(ltrim(rtrim(ems_input)),''NULL''),
					NULLIF(term_start,''NULL''),
					NULLIF(term_end,''NULL''),
					NULLIF(frequency,''NULL''),
					NULLIF(char1,''NULL''),
					NULLIF(char2,''NULL''),
					NULLIF(char3,''NULL''),
					NULLIF(char4,''NULL''),
					NULLIF(char5,''NULL''),
					NULLIF(char6,''NULL''),
					NULLIF(char7,''NULL''),
					NULLIF(char8,''NULL''),
					NULLIF(char9,''NULL''),
					NULLIF(char10,''NULL''),
					NULLIF(input_value,''NULL''),
					NULLIF(UOM,''NULL'')
			 from
				' + @temp_table_name
			)

	-------########### delete the data whose facilityid is null
	DELETE FROM #temp_activity where FacilityID IS NULL
	--#################
	CREATE TABLE #import_status_detail
	(
		temp_id int identity(1,1),
		process_id varchar(100) COLLATE DATABASE_DEFAULT,
		ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,
		Module varchar(100) COLLATE DATABASE_DEFAULT,
		Source varchar(100) COLLATE DATABASE_DEFAULT,
		type varchar(100) COLLATE DATABASE_DEFAULT,
		[description] varchar(250) COLLATE DATABASE_DEFAULT,
		[nextstep] varchar(250) COLLATE DATABASE_DEFAULT,
		[id] int
	)

	CREATE TABLE #import_status
	(
		temp_id int identity(1,1),
		process_id varchar(100) COLLATE DATABASE_DEFAULT,
		ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,
		Module varchar(100) COLLATE DATABASE_DEFAULT,
		Source varchar(100) COLLATE DATABASE_DEFAULT,
		type varchar(100) COLLATE DATABASE_DEFAULT,
		[description] varchar(250) COLLATE DATABASE_DEFAULT,
		[nextstep] varchar(250) COLLATE DATABASE_DEFAULT
	)



	--** Log the errors fo the data that does not exists in the system
	--** check for Sources/Sinks
	INSERT INTO #import_status_detail(process_id,ErrorCode,Module,Source,[type],description,nextstep,[id])
	SELECT 
		@process_id,'Error','Import Data','Activity Data','Data Error',
		'Source/Sinks : '+ (ta.facilityID)+ ' '+ ISNULL((ta.Unit),'') +' not found in the System.','Please Check Source/Sink to verify' ,
		ta.[id]
	FROM #temp_activity ta LEFT JOIN rec_generator rg ON 
		ltrim(rtrim(ta.facilityID))=ltrim(rtrim(rg.id)) 
		AND ISNULL(ltrim(rtrim(ta.Unit)),-1)=ISNULL(rg.id2,-1)
	WHERE
		rg.generator_id is null


	--** check for Input/Outputs
	INSERT INTO #import_status_detail(process_id,ErrorCode,Module,Source,[type],description,nextstep,[id])
	SELECT 
		@process_id,'Error','Import Data','Activity Data','Data Error',
		'Input/Output : '+ (ta.ems_input)+' not found in the System.','Please Check Input/Outputs to verify' ,
		ta.[id]
	FROM #temp_activity ta LEFT JOIN ems_source_input esi ON 
		ltrim(rtrim(ta.ems_input))=esi.input_name
	WHERE
		esi.ems_source_input_id is null	

-- check if constant input have multiple activity data then give error
	INSERT INTO #import_status_detail(process_id,ErrorCode,Module,Source,[type],description,nextstep,[id])
	SELECT 
		@process_id,'Error','Import Data','Activity Data','Data Error',
		'Input/Output : '+ (ta.ems_input)+' is a constant input and can have only one value.','Please check the data and re-import' ,
		ta.[id]
	FROM #temp_activity ta 
	WHERE  ta.ems_input IN
	(SELECT ta.ems_input FROM #temp_activity ta LEFT JOIN ems_source_input esi ON 
		ltrim(rtrim(ta.ems_input))=esi.input_name
	WHERE
		ISNULL(esi.constant_value,'n')='y' 
	GROUP BY ta.ems_input,char1,char2,char3,char4,char5,char6,char7,char8,char9,char10 HAVING COUNT(*)>1)



	--** check for Input/Outputs
	INSERT INTO 
			#import_status_detail(process_id,ErrorCode,Module,Source,[type],description,nextstep,[id])
	SELECT DISTINCT
		@process_id,'Error','Import Data','Activity Data','Data Error',
		CASE WHEN COALESCE(esdv1.code,esdv2.code,esdv3.code,esdv4.code,esdv5.code,esdv6.code,esdv7.code,esdv8.code,esdv9.code,esdv10.code) is null 
		then ' Characteristics for Activity Data "'+ (ta.ems_input)+'" not defined.'
		else
		'Input/Output : '+ (COALESCE(esdv1.code,esdv2.code,esdv3.code,esdv4.code,esdv5.code,esdv6.code,esdv7.code,esdv8.code,esdv9.code,esdv10.code))+' not found in the System.' end ,'Please Check Input/Outputs to verify' ,
		ta.[id]
	FROM 
		#temp_activity ta LEFT JOIN ems_source_input esi ON 
		ltrim(rtrim(ta.ems_input))=esi.input_name
		JOIN ems_input_characteristics eic ON eic.ems_source_input_id=esi.ems_source_input_id
		LEFT JOIN ems_static_data_value esdv1 ON esdv1.type_id=eic.type_id
		and (ltrim(rtrim(ta.char1))=esdv1.code)
		LEFT JOIN ems_static_data_value esdv2 ON esdv2.type_id=eic.type_id
		and (ltrim(rtrim(ta.char2))=esdv2.code)
		LEFT JOIN ems_static_data_value esdv3 ON esdv3.type_id=eic.type_id
		and (ltrim(rtrim(ta.char3))=esdv3.code)
		LEFT JOIN ems_static_data_value esdv4 ON esdv4.type_id=eic.type_id
		and (ltrim(rtrim(ta.char4))=esdv4.code)
		LEFT JOIN ems_static_data_value esdv5 ON esdv5.type_id=eic.type_id
		and (ltrim(rtrim(ta.char5))=esdv5.code)
		LEFT JOIN ems_static_data_value esdv6 ON esdv6.type_id=eic.type_id
		and (ltrim(rtrim(ta.char6))=esdv6.code)
		LEFT JOIN ems_static_data_value esdv7 ON esdv7.type_id=eic.type_id
		and (ltrim(rtrim(ta.char7))=esdv7.code)
		LEFT JOIN ems_static_data_value esdv8 ON esdv8.type_id=eic.type_id
		and (ltrim(rtrim(ta.char8))=esdv8.code)
		LEFT JOIN ems_static_data_value esdv9 ON esdv9.type_id=eic.type_id
		and (ltrim(rtrim(ta.char9))=esdv9.code)
		LEFT JOIN ems_static_data_value esdv10 ON esdv10.type_id=eic.type_id
		and (ltrim(rtrim(ta.char10))=esdv10.code)
	WHERE
		COALESCE(esdv1.value_id,esdv2.value_id,esdv3.value_id,esdv4.value_id,esdv5.value_id,esdv6.value_id,esdv7.value_id,esdv8.value_id,esdv9.value_id,esdv10.value_id) is null	

	--** Now insert the data in the temporary table to insert in the ems_gen_input
--SELECT * FROM dbo.static_data_value WHERE type_id=700
--700	700	Daily
--701	700	Weekly
--703	700	Monthly
--704	700	Quarterly
--705	700	Semi-annually
--706	700	Annually
	SELECT 
		rg.generator_id,
		esi.ems_source_input_id ,
		'r' as estimate_type,
		dbo.fnagetcontractmonth(cast(ta.term_start as datetime)) as term_start,
		CASE ta.frequency
		WHEN 703 then
			dateadd(month,1,dbo.fnagetcontractmonth(cast(ta.term_start as datetime)))-1 
		WHEN 704 then
			dateadd(quarter,1,dbo.fnagetcontractmonth(cast(ta.term_start as datetime)))-1 
		WHEN 705 then
			dateadd(month,6,dbo.fnagetcontractmonth(cast(ta.term_start as datetime)))-1 
		WHEN 706 then
			dateadd(year,1,dbo.fnagetcontractmonth(cast(ta.term_start as datetime)))-1 
		WHEN 700 then
			cast(ta.term_start as datetime) 
		WHEN 701 then
			dateadd(week,1,cast(ta.term_start as datetime))-1 
		ELSE
			ta.term_end		
		END	as term_end,
		ta.frequency as frequency,
		CASE WHEN esdt1.static_data_type IS NOT NULL THEN NULL ELSE (esdv1.value_id) END as char1,
		CASE WHEN esdt2.static_data_type IS NOT NULL THEN NULL ELSE (esdv2.value_id) END as char2,
		CASE WHEN esdt3.static_data_type IS NOT NULL THEN NULL ELSE (esdv3.value_id) END as char3,
		CASE WHEN esdt4.static_data_type IS NOT NULL THEN NULL ELSE (esdv4.value_id) END as char4,
		CASE WHEN esdt5.static_data_type IS NOT NULL THEN NULL ELSE (esdv5.value_id) END as char5,
		CASE WHEN esdt6.static_data_type IS NOT NULL THEN NULL ELSE (esdv6.value_id) END as char6,
		CASE WHEN esdt7.static_data_type IS NOT NULL THEN NULL ELSE (esdv7.value_id) END as char7,
		CASE WHEN esdt8.static_data_type IS NOT NULL THEN NULL ELSE (esdv8.value_id) END as char8,
		CASE WHEN esdt9.static_data_type IS NOT NULL THEN NULL ELSE (esdv9.value_id) END as char9,
		CASE WHEN esdt10.static_data_type IS NOT NULL THEN NULL ELSE (esdv10.value_id) END as char10,
		(cast(ta.input_value as float)) as input_value,
		su.source_uom_id as uom_id,
		NULL as Forecast_type,
		ph.entity_id as sub_id,
		ph1.entity_id as strategy_id,
		ph2.entity_id as book_id,
		ISNULL(esi.constant_value,'n') AS constant_value,
		ta.[id],
		rg.[name] generator_name
	INTO
		 #temp_generator
	FROM 
		#temp_activity ta
		JOIN portfolio_hierarchy ph ON ph.entity_name=ta.sub AND ph.hierarchy_level=2
		JOIN portfolio_hierarchy ph1 ON ph1.entity_name=ta.stra AND ph1.hierarchy_level=1
		and ph1.parent_entity_id=ph.entity_id
		JOIN portfolio_hierarchy ph2 ON ph2.entity_name=ta.book AND ph2.hierarchy_level=0
		and ph2.parent_entity_id=ph1.entity_id
		JOIN rec_generator rg ON ltrim(rtrim(rg.[id]))=ta.facilityid
			 AND ISNULL(rg.[id2],-1)=ISNULL(ta.Unit,-1) AND rg.legal_entity_value_id=ph.entity_id
		JOIN (SELECT max(isnull(effective_date,'1900-01-01')) effective_date,generator_id,max(ems_source_model_id)ems_source_model_id FROM 
						ems_source_model_effective  GROUP BY generator_id) esme
				on esme.generator_id=rg.generator_id 
		JOIN ems_source_model esm ON esm.ems_source_model_id=esme.ems_source_model_id
		JOIN ems_source_input esi ON esi.input_name=ta.ems_input 
		JOIN ems_input_map eim ON esm.ems_source_model_id=eim.source_model_id and esi.ems_source_input_id=eim.input_id
		LEFT JOIN ems_input_characteristics eic1 ON eic1.ems_source_input_id=esi.ems_source_input_id and eic1.sequence_id=1 
		LEFT JOIN ems_input_characteristics eic2 ON eic2.ems_source_input_id=esi.ems_source_input_id and eic2.sequence_id=2 
		LEFT JOIN ems_input_characteristics eic3 ON eic3.ems_source_input_id=esi.ems_source_input_id and eic3.sequence_id=3 
		LEFT JOIN ems_input_characteristics eic4 ON eic4.ems_source_input_id=esi.ems_source_input_id and eic4.sequence_id=4 
		LEFT JOIN ems_input_characteristics eic5 ON eic5.ems_source_input_id=esi.ems_source_input_id and eic5.sequence_id=5 
		LEFT JOIN ems_input_characteristics eic6 ON eic6.ems_source_input_id=esi.ems_source_input_id and eic6.sequence_id=6 
		LEFT JOIN ems_input_characteristics eic7 ON eic7.ems_source_input_id=esi.ems_source_input_id and eic7.sequence_id=7 
		LEFT JOIN ems_input_characteristics eic8 ON eic8.ems_source_input_id=esi.ems_source_input_id and eic8.sequence_id=8 
		LEFT JOIN ems_input_characteristics eic9 ON eic9.ems_source_input_id=esi.ems_source_input_id and eic9.sequence_id=9 
		LEFT JOIN ems_input_characteristics eic10 ON eic10.ems_source_input_id=esi.ems_source_input_id and eic10.sequence_id=10 

		LEFT JOIN ems_static_data_value esdv1 ON esdv1.type_id=eic1.type_id and (ltrim(rtrim(ta.char1))=esdv1.code)
		LEFT JOIN ems_static_data_value esdv2 ON esdv2.type_id=eic2.type_id and (ltrim(rtrim(ta.char2))=esdv2.code)
		LEFT JOIN ems_static_data_value esdv3 ON esdv3.type_id=eic3.type_id and (ltrim(rtrim(ta.char3))=esdv3.code)
		LEFT JOIN ems_static_data_value esdv4 ON esdv4.type_id=eic4.type_id and (ltrim(rtrim(ta.char4))=esdv4.code)
		LEFT JOIN ems_static_data_value esdv5 ON esdv5.type_id=eic5.type_id and (ltrim(rtrim(ta.char5))=esdv5.code)
		LEFT JOIN ems_static_data_value esdv6 ON esdv6.type_id=eic6.type_id and (ltrim(rtrim(ta.char6))=esdv6.code)
		LEFT JOIN ems_static_data_value esdv7 ON esdv7.type_id=eic7.type_id and (ltrim(rtrim(ta.char7))=esdv7.code)
		LEFT JOIN ems_static_data_value esdv8 ON esdv8.type_id=eic8.type_id and (ltrim(rtrim(ta.char8))=esdv8.code)
		LEFT JOIN ems_static_data_value esdv9 ON esdv9.type_id=eic9.type_id  and (ltrim(rtrim(ta.char9))=esdv9.code)
		LEFT JOIN ems_static_data_value esdv10 ON esdv10.type_id=eic10.type_id and (ltrim(rtrim(ta.char10))=esdv10.code)
		
		LEFT JOIN ems_static_data_type esdt1 ON esdt1.type_id=esdv1.type_id
		LEFT JOIN ems_static_data_type esdt2 ON esdt2.type_id=esdv2.type_id
		LEFT JOIN ems_static_data_type esdt3 ON esdt3.type_id=esdv3.type_id
		LEFT JOIN ems_static_data_type esdt4 ON esdt4.type_id=esdv4.type_id
		LEFT JOIN ems_static_data_type esdt5 ON esdt5.type_id=esdv5.type_id
		LEFT JOIN ems_static_data_type esdt6 ON esdt6.type_id=esdv6.type_id
		LEFT JOIN ems_static_data_type esdt7 ON esdt7.type_id=esdv7.type_id
		LEFT JOIN ems_static_data_type esdt8 ON esdt8.type_id=esdv8.type_id
		LEFT JOIN ems_static_data_type esdt9 ON esdt9.type_id=esdv9.type_id
		LEFT JOIN ems_static_data_type esdt10 ON esdt10.type_id=esdv10.type_id

		LEFT JOIN source_uom su ON ltrim(rtrim(ta.UOM))=su.uom_id


--SELECT * FROM #temp_generator
----########## check for the input validations



		INSERT INTO #import_status_detail(process_id,ErrorCode,Module,Source,[type],description,nextstep,[id])
			SELECT 
				@process_id,'Error','Import Data','Activity Data','Data Error',
				'Inavalid Input value found for the source '+rg.[name]+'. Input value for '+dbo.FNAEmissionHyperlink(2,12101300,esi.input_name,esi.ems_source_input_id,NULL)+' should be between '+CAST(ISNULL(min_value,'') AS VARCHAR)+' and '+CAST(ISNULL(max_value,'') AS VARCHAR)+'.','Please check the data and re-import' ,
				ta.[id]
		FROM #temp_generator ta 
			 INNER JOIN ems_input_valid_values eiv on ta.ems_source_input_id=eiv.ems_source_input_id
			 INNER JOIN rec_generator rg on rg.generator_id=ta.generator_id
			 INNER JOIN ems_source_input esi on ta.ems_source_input_id=esi.ems_source_input_id
		WHERE 
			(ISNULL(ta.input_value,0)<isnull(min_value,-999999999) OR ISNULL(ta.input_value,0)>isnull(max_value,999999999))



---######### Check if the data is already published
		select 
			distinct rg.generator_id,rg.name [name],max(epr.as_of_date) published_date 
		into 
			#generator_published
		from 
			#temp_generator ta
			INNER JOIN rec_generator rg ON rg.generator_id=ta.generator_id
			INNER JOIN ems_publish_report epr on epr.sub_id=ta.sub_id 
				and isnull(epr.strategy_entity_id,ta.strategy_id)=ta.strategy_id 
				and isnull(epr.book_entity_id,ta.book_id)=ta.book_id
		group by rg.generator_id,rg.name


	
		INSERT INTO #import_status_detail(process_id,ErrorCode,Module,Source,[type],description,nextstep,[id])
			SELECT 
				@process_id,'Error','Import Data','Activity Data','Data Error',
				'Report is already published for the source '+gp.[name]+' for the term '+dbo.fnadateformat(ta.term_start)+'.','Please check the data and re-import' ,
				ta.[id]
			FROM #temp_generator ta 
				 INNER JOIN #generator_published gp ON gp.generator_id=ta.generator_id
				 AND ta.term_start<=gp.published_date

---################################################3



	--** Now deleite the data tha has errors
	DELETE a FROM  
			#temp_generator a,
			#import_status_detail b WHERE  a.[id]=b.[id]

---#########################################


	DELETE	egi
	FROM 
		ems_gen_input egi inner JOIN 
		#temp_generator tg 	on egi.generator_id=tg.generator_id 
		and tg.ems_source_input_id = egi.ems_input_id and ((tg.term_start = egi.term_start AND tg.constant_value='n') OR tg.constant_value='y')
--
	INSERT INTO ems_gen_input 
			(generator_id, ems_input_id, estimate_type, term_start, term_end, 
				char1,char2,char3,char4,char5,char6,char7,char8,char9,char10,	
				frequency, input_value,uom_id)
		SELECT DISTINCT tg.generator_id,ems_source_input_id as ems_input_id,estimate_type,term_start, term_end,
				--max(char1),max(char2),max(char3),max(char4),max(char5),max(char6),max(char7),max(char8),max(char9),max(char10),
				char1,char2,char3,char4,char5,char6,char7,char8,char9,char10,
				max(frequency),
				max(CASE WHEN input_value<0 and esme.ems_source_model_id not in(134,135) then 0 else input_value end),max(uom_id)
					FROM #temp_generator tg
						INNER JOIN dbo.ems_source_model_effective esme ON esme.generator_id=tg.generator_id
						INNER JOIN (SELECT max(isnull(effective_date,'1900-01-01')) effective_date,generator_id FROM 
						dbo.ems_source_model_effective WHERE 1=1 GROUP BY generator_id) ab
						on esme.generator_id=ab.generator_id and isnull(esme.effective_date,'1900-01-01')=ab.effective_date
				
		group by 
			tg.generator_id,ems_source_input_id ,estimate_type,term_start, term_end,
			char1,char2,char3,char4,char5,char6,char7,char8,char9,char10
				--char2,char3,char4,char5,char6,char7,char8,char9,char10 

	-------------##############################################################################
	--- Now run the calc for 
	DECLARE @process_table varchar(128),@process_id1 varchar(100),@term_start datetime,@term_end datetime,@series_type_id int
	SET @process_id1 = REPLACE(newid(),'-','_')
	set @process_table=dbo.FNAProcessTableName('edr_process',@user_login_id,@process_id1)
	SELECT @term_start=min(term_start),@term_end=max(term_end),@series_type_id=max(forecast_type) FROM #temp_generator

exec(
	'SELECT 
		distinct generator_id,term_start,term_end
	into '+@process_table+' FROM #temp_generator')

	--exec spa_calc_emissions_inventory NULL,@term_start,@term_end,NULL,NULL,NULL,NULL,@series_type_id,@process_table

	--####################################################################################################


--################################ Now Complete the compliance activities for the selects inputs
DECLARE @generator_id INT,@ems_source_input_id INT,@generator_name VARCHAR(100)
--,@sub_id INT,@strategy_id INT,@book_id INT
DECLARE @message VARCHAR(1000)
	DECLARE cur1 cursor for
		SELECT 
--			DISTINCT generator_id,ems_source_input_id,MAX(term_start),strategy_id,sub_id,book_id FROM #temp_generator group by generator_id,ems_source_input_id,strategy_id,sub_id,book_id
			DISTINCT generator_id,ems_source_input_id,MAX(term_start),generator_name FROM #temp_generator group by generator_id,ems_source_input_id,generator_name
		OPEN cur1
		FETCH NEXT FROM cur1 INTO @generator_id,@ems_source_input_id,@term_start,@generator_name
		--,@strategy_id,@sub_id,@book_id
		WHILE @@FETCH_STATUS=0
			BEGIN
				SET @message='Import Activity Data Completed for '+dbo.FNAEmissionHyperlink(3,12101500,@generator_name,@generator_id,'''e''')
				--SELECT @message 
				--set @sql =' EXEC spa_complete_compliance_activities ''a'',1,'''+cast(@term_start as varchar)+''',''<'+cast(@sub_id as varchar)+'><'+cast(@strategy_id as varchar)+'><'+cast(@book_id as varchar)+'><'+cast(@generator_id as varchar)+'><'+cast(@ems_source_input_id as varchar)+'>'',NULL,NULL,NULL,'''+@message+''',''c'''
				--set @sql =' EXEC spa_complete_compliance_activities ''a'',1,'''+cast(@term_start as varchar)+''',''<'+cast(@generator_id as varchar)+'><'+cast(@ems_source_input_id as varchar)+'>'',NULL,NULL,NULL,'''+@message+''',''c'''
				EXEC spa_print @sql
				EXEC(@sql)
			FETCH NEXT FROM cur1 INTO @generator_id,@ems_source_input_id,@term_start,@generator_name
			--,@strategy_id,@sub_id,@book_id
			END
		CLOSE cur1
		DEALLOCATE cur1

		---################## Publish the compliance activity when there is a credit voilation for counterparty.
--	IF	(SELECT MAX(limit_to_us_violated) FROM #limit_check)=1 OR (SELECT MAX(tenor_limit_violated) FROM #limit_check)=1
--		BEGIN
--			SET @risk_control_id=21
--			SET @message='Credit limit violated for some Counterparties'
--			SET @message=@message+'<a target="_blank" href="dev/spa_html.php?spa=exec spa_get_counterparty_exposure_report ''''e'''',''''s'''',''''c'''','''''+@as_of_date+''''','''''+CAST(@sub_entity_id AS VARCHAR)+''''',NULL,NULL,NULL,NULL,NULL,NULL,e,NULL,NULL,NULL,NULL,NULL,''''n'''',''''y'''',''''n'''',''''n'''',''''s'''',1,''''n'''',4500,6,''''u'''',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL&__user_name__='+@user_login_id+'">' + 
--			' Click here...' +'</a>'
--			
--			SET @sqlSelect =' EXEC spa_complete_compliance_activities ''a'',NULL,'''+cast(getdate() AS VARCHAR)+''',''<>'','+CAST(@risk_control_id AS VARCHAR)+',NULL,NULL,'''+@message+''',''v'''
--			EXEC spa_print @sqlSelect
--			EXEC(@sqlSelect)
--
--		END

--############################################################################





	set @all_row_count=(SELECT count(*) FROM #temp_activity)
	--


	INSERT INTO #import_status(
		process_id,ErrorCode,Module,Source,	type,[description],[nextstep])
	SELECT 
		@process_id,'Success','Import Data','Activity Data','Activity Data',
		'Source: ' + rg.[name] + ' Imported.','' 

	from
		#temp_generator tg
		JOIN rec_generator rg ON rg.generator_id = tg.generator_id
	GROUP BY rg.[name]


	declare @detail_errorMsg varchar(1000),@msg_rec varchar(1000),@count int
	declare @url varchar(5000), @desc varchar(5000),@errorcode varchar(10)
	declare @count_temp int,@totalcount int
	declare @noGenerator int


	declare @sqlStmt varchar(5000), @tempTable varchar(200)
	--set @user_login_id=dbo.FNADBUser()


	INSERT INTO  #import_status(
		process_id,ErrorCode,Module,Source,	type,[description],[nextstep])
	SELECT distinct 
		process_id,ErrorCode,Module,Source,	type,
		'<a target="_blank" href="' + '../dev/spa_html.php?__user_name__=' + @user_login_id + 
			'&spa=exec spa_get_import_process_status_detail ''' + @process_id + '''">'+'Some errors found' ,'Please check the Data'
	from
		#import_status_detail

	-----###########################################
	INSERT INTO source_system_data_import_status(process_id,code,module,source,
			type,[description],recommendation) 
	SELECT 
		distinct process_id,ErrorCode,Module,Source,	type,[description],[nextstep]
	from
		#import_status


	-----###########################################
	INSERT INTO source_system_data_import_status_detail(process_id,source,type,[description]) 
	SELECT 
		distinct process_id,source,type,[description]
	from
		#import_status_detail



	set @totalcount=(SELECT count(*) FROM #temp_generator)
	if @totalcount<=0
		set @msg_rec='No Data Found to import.'
	else
		set @msg_rec= cast(@all_row_count as varchar) +' data imported.'



	if exists(SELECT ErrorCode FROM #import_status WHERE ErrorCode='Error')
	set @errorcode='e'
	else
	set @errorcode='s'

	CREATE table #temp_user(user_login_id varchar(100) COLLATE DATABASE_DEFAULT)

	if @noGenerator >0 
	INSERT INTO #temp_user
	SELECT DISTINCT ISNULL(af.login_id,ar.user_login_id)
		from
			application_functional_users af
			RIGHT JOIN application_role_user ar
			on ar.role_id=af.role_id or af.login_id is not null
			WHERE	af.function_id=2
	ELSE
	INSERT INTO #temp_user SELECT @user_login_id 


/*
		DECLARE curtemp CURSOR FOR
		SELECT 	user_login_id FROM #temp_user
		OPEN curtemp
		FETCH next FROM curtemp into @user_login_id
		WHILE @@FETCH_STATUS=0
		BEGIN	

		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
			'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''
		
		SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
					'Activity Data Import process Completed:' + @msg_rec + 
				CASE WHEN (@errorcode = 'e') then ' (ERRORS found)' else '' end +
				'.</a>'
		
		EXEC  spa_message_board 'i', @user_login_id,
					NULL, 'Import.Activity',
					@desc, '', '', @errorcode, 'Activity Data Import'
		
		FETCH next FROM curtemp into @user_login_id
		END
		CLOSE curtemp
		DEALLOCATE curtemp
		*/
		exec spa_compliance_workflow 113,'i',@process_id,NULL,@errorcode,@msg_rec

END TRY
BEGIN CATCH

	SELECT @msg_rec = ERROR_MESSAGE()

	SET @desc =  'Error Found in Catch: ' + @msg_rec

	EXEC spa_print @desc

	SET @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
			'&spa=exec spa_get_mtm_test_run_log ''' + @process_id + ''''
		
	SET @desc = '<a target="_blank" href="' + @url + '">' + 
				'Import Activity Data did not complete.'+
				' (ERRORS found: ' + @desc + ')'  +
				'</a>'

	INSERT INTO source_system_data_import_status_detail(process_id,source,type,[description]) 
	SELECT 
		distinct process_id,source,type,[description]
	from
		#import_status_detail


	--select @user_name
	insert into inventory_accounting_log(process_id,code,module,source,type,[description],nextsteps)  
	SELECT @process_id,'Error','Import Activity Data','Import Activity Data','SQL Error',
				'SQL Error found: (' + @msg_rec + ')' as status_description, 
				'Please contact technical support'

	
		EXEC spa_compliance_workflow 113,'e',@process_id,NULL,'e',@msg_rec
	--EXEC  spa_message_board 'i', @user_login_id, NULL, 'Import Activity Data',  @desc, '', '', 'e', @job_name

--select * from source_deal_pnl_Detail


END CATCH

END




























