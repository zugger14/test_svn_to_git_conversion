
IF OBJECT_ID(N'[dbo].[spa_import_epa_allowance_data]', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_import_epa_allowance_data]
 GO 

CREATE proc [dbo].[spa_import_epa_allowance_data]
	@temp_table_name varchar(max), 
	@facility_ids VARCHAR(max), 
	@purge_data bit=0,
	@user_login_id varchar(50)='farrms_admin',
	@process_id varchar(100)=null,  
	@job_name varchar(100)

AS

/*
declare	  @temp_table_name VARCHAR(max)
		,@facility_ids VARCHAR(max)
	,@purge_data bit,
	@process_id varchar(100),  
	@user_login_id varchar(50),
	@job_name varchar(100)

/*	
* adiha_process.dbo.epa_allowance_data_farrms_admin_23500CBC_D20F_4E50_9338_27631A2E5A9C 
DTE Coal Services CAIR
drop table adiha_process.dbo.arp
select *  from adiha_process.dbo.epa_allowance_data_farrms_admin_23500CBC_D20F_4E50_9338_27631A2E5A9C
*/

select	@temp_table_name='adiha_process.dbo.epa_allowance_data_farrms_admin_32A25B7E_88EA_4D71_AB2D_2A6BE3FC61D1'
		, @facility_ids= '006137FACLTY'
		,@user_login_id='farrms_admin'
		,@job_name='ssss'
		,@purge_data =1
	
--*/






--select * from static_data_value where type_id=3100













DECLARE @tablename varchar(100),@facility_id VARCHAR(50) , @generator_id INT
DECLARE @error_msg VARCHAR(2000)
DECLARE @continue_to_next_file BIT

	DECLARE @sql VARCHAR(MAX),@total_no_rec INT,@total_upd_rec INT,@total_ins_rec INT
	Declare @url varchar(1000)
	declare @desc varchar(1000)
	set  @url=''
	set @desc=''
	set @process_id=ISNULL(@process_id,REPLACE(newid(),'-','_'))
	if object_id('tempdb.dbo.#tmp_no_rec') is not null
		drop table #tmp_no_rec
	if object_id('tempdb.dbo.#import_status') is not null
		drop table #import_status
	if object_id('tempdb.dbo.#tmp_source') is not null
		drop table #tmp_source
	if object_id('tempdb.dbo.#tmp_transfer_id') is not null
		drop table #tmp_transfer_id
	if object_id('tempdb.dbo.#tmp_existing_deal') is not null
		drop table #tmp_existing_deal
	if object_id('tempdb.dbo.#deal_for_transfer') is not null
		drop table #deal_for_transfer	
	if object_id('tempdb.dbo.#template_id') is not null
		drop table #template_id	
	if object_id('tempdb.dbo.#tmp_tbl') is not null
		drop table #tmp_tbl	
	if object_id('tempdb.dbo.#tmp_ids') is not null
		drop table #tmp_ids	


	---create temporary tables-----------------------------------------------

	CREATE TABLE #tmp_transfer_id (
			source_temp_id INT, transfer_temp_id INT,[cert_from] int ,[cert_to] INT
			,transaction_date DATETIME,VINTAGE_YEAR int,TOTAL_BLOCK FLOAT,deal_header_id int,deal_header_id_from int)

	
	create table #template_id(template_id int)
     CREATE TABLE #deal_for_transfer ( deal_header_id INT 
		,deal_detail_id INT
		,start_no INT
		, end_no INT
		,[gis_cert_date] DATETIME
		,yr INT
		,buy_sell_flag VARCHAR(1) COLLATE DATABASE_DEFAULT
		,deal_volume   float
		,buy_acc_no varchar(100) COLLATE DATABASE_DEFAULT
		,sell_acc_no varchar(100) COLLATE DATABASE_DEFAULT
	 )		
	CREATE TABLE #tmp_source (temp_id int,type_err int,PRG_Code VARCHAR(50) COLLATE DATABASE_DEFAULT,VINTAGE_YEAR INT ,Start_Block_a INT
								,end_Block_a INT ,Start_Block_b INT,end_Block_b INT
							)
	CREATE TABLE #tmp_existing_deal (
		temp_id INT,generator_id INT,deal_header_id INT ,deal_detail_id INT, start_block INT,end_block INT,
		 buy_sell_flag VARCHAR(1) COLLATE DATABASE_DEFAULT,Yr INT,deal_volume float,total_block INT,TRANSACTION_DATE datetime
	 )

	create  table #tmp_no_rec (facility_id varchar(50) COLLATE DATABASE_DEFAULT,total_no_rec int)

	create TABLE #import_status 
	(
		temp_id int ,
		ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,
		Module varchar(100) COLLATE DATABASE_DEFAULT,
		Source varchar(100) COLLATE DATABASE_DEFAULT,
		[type] varchar(100) COLLATE DATABASE_DEFAULT,
		[description] varchar(250) COLLATE DATABASE_DEFAULT,
		[nextstep] varchar(250) COLLATE DATABASE_DEFAULT
	)
-----------------------end create temporary tables--------------------------------------------------------------------------------------

/*
To find overlapping dates in MS SQL
CODE

 
      @datFromDate @datToDate
             |         |               
1   FR---TO  |         |               
             |         |               
2         FR-|-TO      |               
             |         |               
3            | FR---TO |               
             |         |               
4         FR-|---------|-TO       
             |         |               
5            |      FR-|-TO
             |         |               
6            |         |  FR---TO
 
where F_ToDate >= @datFromDate eliminates case 1
 and F_FromDate <= @datToDate eliminates case 6
*/


------------Valiadation	 Start-------------------------------------------------------------------------------------------------------

						
declare @prg_code	varchar(100)
SELECT *,ROWID=IDENTITY(int,1,1) INTO #tmp_tbl FROM dbo.SplitCommaSeperatedValues(@temp_table_name)
SELECT *,ROWID=IDENTITY(int,1,1) INTO #tmp_ids FROM dbo.SplitCommaSeperatedValues(@facility_ids)

begin try	
DECLARE b_cursor CURSOR FOR
SELECT ids.item,tbl.item,rg.generator_id  from	 #tmp_tbl tbl INNER JOIN #tmp_ids ids ON tbl.rowid=ids.rowid 
				INNER JOIN dbo.rec_generator rg ON ids.item=rg.id
OPEN b_cursor
FETCH NEXT FROM b_cursor INTO @facility_id,@tablename, @generator_id


--loop
----------------------------------------------------------------------------------------------------
WHILE @@FETCH_STATUS = 0   
BEGIN 
BEGIN TRY
	begin TRAN
	SET @continue_to_next_file = 0
	--truncate table #tmp_no_rec
	--truncate table  #import_status
	truncate table  #tmp_source
	truncate table #tmp_existing_deal
	truncate table #deal_for_transfer
	truncate table #template_id
	truncate table #tmp_transfer_id

	exec('insert into  #tmp_no_rec  (facility_id,total_no_rec)  select '''+@facility_id+''', count(*) from ' + @tablename)
	--select * from #tmp_no_rec
	select @total_no_rec=total_no_rec from #tmp_no_rec where facility_id=@facility_id

	EXEC spa_print 'Faciliy: ', @facility_id

	SET @sql='UPDATE ' + @tablename +'
			SET [PRG_CODE] = REPLACE(PRG_CODE,''"'','''')
		  ,[TRANSACTION_ID] = REPLACE(TRANSACTION_ID,''"'','''')
		  ,[TRANSACTION_TOTAL] = REPLACE(TRANSACTION_TOTAL,''"'','''')
		  ,[TRANSACTION_TYPE] = REPLACE(TRANSACTION_TYPE,''"'','''')
		  ,[SELL_ACCT_NUMBER] = REPLACE(SELL_ACCT_NUMBER,''"'','''')
		  ,[SELL_ACCT_NAME] = REPLACE(SELL_ACCT_NAME,''"'','''')
		  ,[SELL_STATE] = REPLACE(SELL_STATE,''"'','''')
		  ,[SELL_DISPLAY_NAME] = REPLACE(SELL_DISPLAY_NAME,''"'','''')
		  ,[BUY_ACCT_NUMBER] = REPLACE(BUY_ACCT_NUMBER,''"'','''')
		  ,[BUY_ACCT_NAME] = REPLACE(BUY_ACCT_NAME,''"'','''')
		  ,[BUY_STATE] = REPLACE(BUY_STATE,''"'','''')
		  ,[BUY_DISPLAY_NAME] = REPLACE(BUY_DISPLAY_NAME,''"'','''')
		  ,[TRANSACTION_DATE] = REPLACE(TRANSACTION_DATE,''"'','''')
		  ,[VINTAGE_YEAR] = REPLACE(VINTAGE_YEAR,''"'','''')
		  ,[START_BLOCK] = REPLACE(START_BLOCK,''"'','''')
		  ,[END_BLOCK] = REPLACE(END_BLOCK,''"'','''')
		  ,[TOTAL_BLOCK] = REPLACE(TOTAL_BLOCK,''"'','''')
		  '
	exec( @sql)   
	exec('
		if not exists(select 1 from adiha_process.sys.columns WITH(NOLOCK) where [name]=''temp_id'' and [object_id]=object_id('''+@tablename+'''))
		alter table '+ @tablename+' add temp_id int identity'
	)


	if isnull(@purge_data,0)=1
	begin
		set @sql='delete unassignment_audit from  unassignment_audit ua inner join source_deal_detail sdd on ua.source_deal_header_id =sdd.source_deal_detail_id
				inner join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id
				and sdh.generator_id='+ CAST(@generator_id AS VARCHAR) +'
				inner join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
				inner join static_data_value sdv on sdv.value_id=spcd.program_scope_value_id 
				inner join  ' + @tablename +' s  ON sdv.code=s.PRG_Code AND sdv.TYPE_ID=3100'
		exec spa_print @sql

		EXEC(@sql)

		set @sql='delete unassignment_audit from  unassignment_audit ua inner join source_deal_detail sdd on ua.source_deal_header_id_from =sdd.source_deal_detail_id
				inner join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id
				and sdh.generator_id='+ CAST(@generator_id AS VARCHAR) +'
				inner join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
				inner join static_data_value sdv on sdv.value_id=spcd.program_scope_value_id 
				inner join  ' + @tablename +' s  ON sdv.code=s.PRG_Code AND sdv.TYPE_ID=3100'

		exec spa_print @sql
		EXEC(@sql)

		set @sql='delete assignment_audit from  assignment_audit aa inner join source_deal_detail sdd on aa.source_deal_header_id =sdd.source_deal_detail_id
				inner join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id
				and sdh.generator_id='+ CAST(@generator_id AS VARCHAR) +'
				inner join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
				inner join static_data_value sdv on sdv.value_id=spcd.program_scope_value_id 
				inner join  ' + @tablename +' s  ON sdv.code=s.PRG_Code AND sdv.TYPE_ID=3100'
		exec spa_print @sql

		EXEC(@sql)

		set @sql='delete assignment_audit from  assignment_audit aa inner join source_deal_detail sdd on aa.source_deal_header_id_from =sdd.source_deal_detail_id
				inner join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id
				and sdh.generator_id='+ CAST(@generator_id AS VARCHAR) +'
				inner join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
				inner join static_data_value sdv on sdv.value_id=spcd.program_scope_value_id 
				inner join  ' + @tablename +' s  ON sdv.code=s.PRG_Code AND sdv.TYPE_ID=3100'
		exec spa_print @sql

		EXEC(@sql)

		set @sql='delete [Gis_Certificate] from  [Gis_Certificate] gc inner join source_deal_detail sdd on gc.source_deal_header_id =sdd.source_deal_detail_id
				inner join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id
				and sdh.generator_id='+ CAST(@generator_id AS VARCHAR) +'
				inner join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
				inner join static_data_value sdv on sdv.value_id=spcd.program_scope_value_id 
				inner join  ' + @tablename +' s  ON sdv.code=s.PRG_Code AND sdv.TYPE_ID=3100'
		exec spa_print @sql

		EXEC(@sql)

--		set @sql='delete user_defined_deal_fields from user_defined_deal_fields udf  
--				inner join source_deal_header sdh on udf.source_deal_header_id=sdh.source_deal_header_id
--				inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
--				and sdh.generator_id='+ CAST(@generator_id AS VARCHAR) +'
--				inner join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
--				inner join static_data_value sdv on sdv.value_id=spcd.program_scope_value_id 
--				inner join  ' + @tablename +' s  ON sdv.code=s.PRG_Code AND sdv.TYPE_ID=3100'
--		exec spa_print @sql
--
--		EXEC(@sql)

		set @sql='delete source_deal_detail from source_deal_detail sdd 
				inner join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id
				and sdh.generator_id='+ CAST(@generator_id AS VARCHAR) +'
				inner join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
				inner join static_data_value sdv on sdv.value_id=spcd.program_scope_value_id 
				inner join  ' + @tablename +' s  ON sdv.code=s.PRG_Code AND sdv.TYPE_ID=3100'
		exec spa_print @sql

		EXEC(@sql)
		set @sql='delete  source_deal_header from source_deal_header sdh 
				left join source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id 
					where sdd.source_deal_header_id is null'
		exec spa_print @sql

		EXEC(@sql)
		EXEC spa_print 'llllllllllll'

	end

	
	IF ISNULL(@total_no_rec,0) = 0
	BEGIN
		SET @continue_to_next_file = 1
		
		INSERT INTO #import_status (ErrorCode, Module, Source, [type], [description], nextstep)
		VALUES ('Error', 'epa_allowance_data_adaptor', @facility_id ,'no_data_found' ,'No data found to import for facility_ID:' + @facility_id + '.', 'Please verify the data source.')
	END
	ELSE IF NOT EXISTS(SELECT * FROM source_book WHERE source_system_book_id=@facility_id)
	BEGIN
		SET @continue_to_next_file = 1
		
		INSERT INTO #import_status (ErrorCode, Module, Source, [type], [description], nextstep)
		VALUES ( 'Error', 'epa_allowance_data_adaptor', @facility_id,'source_book','Book is not found  for facility_ID:' + @facility_id + '.', 'Please check source data.')
	END
	IF @continue_to_next_file = 1
	BEGIN
		--uncommittable state
		IF (XACT_STATE()) = -1
			ROLLBACK TRANSACTION
	    --active and valid transaction
		ELSE 
			IF (XACT_STATE()) = 1
			COMMIT TRANSACTION 

		EXEC spa_print 'B4 Fetch'
		FETCH NEXT FROM b_cursor INTO @facility_id,@tablename, @generator_id
		--continue with next file
		CONTINUE
	END
	
	--overlapping validation in source
	set @sql='
		INSERT INTO #tmp_source (temp_id,type_err,PRG_Code,VINTAGE_YEAR,Start_Block_a,end_Block_a ,Start_Block_b,end_Block_b)
		select DISTINCT a.temp_id,1,a.PRG_Code,A.VINTAGE_YEAR,a.Start_Block Start_Block_a,a.end_Block end_Block_b,b.Start_Block Start_Block_b,b.end_Block end_Block_b
		FROM ' + @tablename +' a 
		INNER JOIN ' + @tablename +' b ON cast(a.start_block as int)<=cast(b.end_block as int) AND cast(a.end_block as int)>=cast(b.start_block as int) AND a.VINTAGE_YEAR=b.VINTAGE_YEAR
		and not (cast(a.start_block as int)<=cast(b.start_block as int) AND cast(a.end_block as int)>=cast(b.end_block as int))
		AND (CASE when a.SELL_ACCT_NUMBER='''+@facility_id+''' THEN ''s''
			WHEN a.buy_ACCT_NUMBER='''+@facility_id+''' THEN ''b''
		END )=(CASE when b.SELL_ACCT_NUMBER='''+@facility_id+''' THEN ''s''
			WHEN b.buy_ACCT_NUMBER='''+@facility_id+''' THEN ''b'' 
		END )
		AND a.temp_id<>b.temp_id
		--AND a.temp_id>b.temp_id --removing duplicate record
		ORDER BY a.VINTAGE_YEAR,a.start_block,a.end_block'
	exec spa_print @sql
	EXEC(@sql)
	set @sql='DELETE  ' + @tablename +'
		  OUTPUT deleted.temp_id,''Error'', ''epa_allowance_data_adaptor'', ''' + @facility_id + ''',''DATA_OVERLAP1''
		  , ''Data error FOR PRG_Code:''+ a.PRG_Code +''; Facility_ID:'+@facility_id+'; START_BLOCK:'' + cast(a.Start_Block_a as varchar)+ ''; END_BLOCK:'' + cast(a.end_Block_a as varchar)+ ''; VINTAGE_YEAR:''+ CAST(A.VINTAGE_YEAR AS VARCHAR) + '' ( Overlap within import file data found for START_BLOCK:'' + cast(a.Start_Block_b as varchar)+ '' AND 
		    END_BLOCK:'' + cast(a.end_Block_b as varchar)+ '')'', ''Please check source data.'' INTO #import_status (temp_id,ErrorCode,Module,Source,[type],[description], nextstep)
		from ' + @tablename +' s inner join #tmp_source a  on
		a.temp_id=s.temp_id'
		
	exec spa_print  @sql
	EXEC( @sql)
	
		--overlapping validation in Gis_Certificate

	set @sql='
		INSERT INTO #tmp_source (temp_id,type_err,PRG_Code,VINTAGE_YEAR,Start_Block_a,end_Block_a ,Start_Block_b	,end_Block_b)
		select DISTINCT a.temp_id,2,a.PRG_Code,A.VINTAGE_YEAR,a.Start_Block,a.end_Block,b.certificate_number_from_int,b.certificate_number_to_int
		FROM ' + @tablename +' a 
		INNER JOIN Gis_Certificate b ON a.start_block<=b.certificate_number_to_int AND a.end_block>=b.certificate_number_from_int 
		and not (a.start_block<=b.certificate_number_to_int AND a.end_block>=b.certificate_number_from_int)
		AND a.VINTAGE_YEAR=year(b.gis_cert_date)
		inner join source_deal_detail sdd on sdd.source_deal_detail_id=b.source_deal_header_id
		where 	
		 (CASE when a.SELL_ACCT_NUMBER='''+@facility_id+''' THEN ''s''
			WHEN a.buy_ACCT_NUMBER='''+@facility_id+''' THEN ''b''
		END )=sdd.buy_sell_flag
		ORDER BY a.VINTAGE_YEAR,a.start_block,a.end_block'
	exec spa_print  @sql
	EXEC( @sql)
/*	
INSERT INTO #tmp_source (temp_id,type_err,PRG_Code,VINTAGE_YEAR,Start_Block_a,end_Block_a ,Start_Block_b,end_Block_b)
		select DISTINCT a.temp_id,1,a.PRG_Code,A.VINTAGE_YEAR,a.Start_Block Start_Block_a,a.end_Block end_Block_a,b.Start_Block Start_Block_b,b.end_Block end_Block_b
		FROM adiha_process.dbo.epa_allowance_data_farrms_admin_D1EF26FD_5B53_4878_B97C_755BBC3127D6 a 
		INNER JOIN adiha_process.dbo.epa_allowance_data_farrms_admin_D1EF26FD_5B53_4878_B97C_755BBC3127D6 b 
ON cast(a.start_block as int)<=cast(b.end_block as int) AND cast(a.end_block as int)>=cast(b.start_block as int) 
AND a.VINTAGE_YEAR=b.VINTAGE_YEAR
		and not (cast(a.start_block as int)<=cast(b.start_block as int) AND cast(a.end_block as int)>=cast(b.end_block as int))
		AND (CASE when a.SELL_ACCT_NUMBER='006137FACLTY' THEN 's'
			WHEN a.buy_ACCT_NUMBER='006137FACLTY' THEN 'b'
		END )=(CASE when b.SELL_ACCT_NUMBER='006137FACLTY' THEN 'b'
			WHEN b.buy_ACCT_NUMBER='006137FACLTY' THEN 's' 
		END )
		AND a.temp_id<>b.temp_id
		--AND a.temp_id>b.temp_id --removing duplicate record
		ORDER BY a.VINTAGE_YEAR,a.start_block,a.end_block

select VINTAGE_YEAR,Start_Block,end_block,CASE when SELL_ACCT_NUMBER='006137FACLTY' THEN 's'
			WHEN buy_ACCT_NUMBER='006137FACLTY' THEN 'b'
		END b_s,count(*) no_rec
 FROM adiha_process.dbo.epa_allowance_data_farrms_admin_D1EF26FD_5B53_4878_B97C_755BBC3127D6  group by 
VINTAGE_YEAR,Start_Block,end_block,CASE when SELL_ACCT_NUMBER='006137FACLTY' THEN 's'
			WHEN buy_ACCT_NUMBER='006137FACLTY' THEN 'b'
		END
having count(*)>1
*/
	set @sql='DELETE  ' + @tablename +'
		  OUTPUT deleted.temp_id,''Error'', ''epa_allowance_data_adaptor'',''' + @facility_id + ''',''DATA_OVERLAP1''
		  , ''Data error FOR PRG_Code:''+ a.PRG_Code +''; Facility_ID:'+@facility_id+'; START_BLOCK:'' + cast(a.Start_Block_a as varchar)+ ''; END_BLOCK:'' + cast(a.end_Block_a as varchar)+ ''; VINTAGE_YEAR:''+ CAST(A.VINTAGE_YEAR AS VARCHAR) + ''(Overlap within import file data found for START_BLOCK:'' + cast(a.Start_Block_b as varchar)+ '' AND 
		    END_BLOCK:'' + cast(a.end_Block_b as varchar)+ '')'', ''Please check source data.'' INTO #import_status (temp_id,ErrorCode,Module,Source,[type],[description], nextstep)
		from ' + @tablename +' s inner join #tmp_source a  on
		a.temp_id=s.temp_id and a.type_err=2'
	
	exec spa_print  @sql
	EXEC(@sql)

				-- existing deal list
	
	 set @sql='
		INSERT INTO #tmp_existing_deal (temp_id,generator_id,deal_header_id,deal_detail_id, start_block,end_block, buy_sell_flag,Yr,deal_volume,total_block,TRANSACTION_DATE)
		select s.temp_id,ex.generator_id,deal_header_id,deal_detail_id, ex.start_block,ex.end_block, ex.buy_sell_flag,ex.Yr,deal_volume,s.total_block,s.TRANSACTION_DATE
		from ' + @tablename +'  s inner join 
		 (
			SELECT  distinct sdh.generator_id,sdd.source_deal_header_id deal_header_id,sdd.source_deal_detail_id deal_detail_id, gc.[certificate_number_from_int] start_block
			,gc.[certificate_number_to_int] end_block, sdd.buy_sell_flag,year(sdd.term_start) Yr,sdd.deal_volume
			from [Gis_Certificate] gc INNER JOIN dbo.source_deal_detail sdd  ON sdd.source_deal_detail_id=gc.source_deal_header_id
			INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id=sdh.source_deal_header_id
		) ex on ex.[START_BLOCK]=s.START_BLOCK
				   and ex.[end_BLOCK] =s.end_BLOCK  and s.[VINTAGE_YEAR]=ex.yr 
				   and ex.buy_sell_flag =CASE when s.SELL_ACCT_NUMBER='''+@facility_id +''' THEN ''s''
						WHEN s.buy_ACCT_NUMBER='''+@facility_id +''' THEN ''b'' END
						AND ex.generator_id='+ CAST(@generator_id AS VARCHAR)
					
		exec spa_print @sql
		EXEC(@sql)
	
		---source deal (source_deal_header_id_from)
		
		set @sql='DELETE  ' + @tablename +' 
				 OUTPUT deleted.temp_id,''Error'', ''epa_allowance_data_adaptor'',''' + @facility_id + ''',''Assignment_exist_from''
				  , ''Data error for PRG_Code:''+ deleted.PRG_Code +''; Facility_ID:'+@facility_id+'; START_BLOCK:'' + cast(deleted.Start_Block as varchar)+ ''; END_BLOCK:'' + cast(deleted.end_Block as varchar)+ ''; VINTAGE_YEAR:''+ CAST(deleted.VINTAGE_YEAR AS VARCHAR) + '' (The deal is already assigned with deal_id: ''+ CAST(ex.deal_header_id AS VARCHAR)+'')''
				  , ''Please check source data.''
				INTO #import_status (temp_id,ErrorCode,Module,Source,[type],[description], nextstep)
				FROM ' + @tablename +' a INNER JOIN #tmp_existing_deal	ex ON ex.temp_id=a.temp_id						
						INNER JOIN dbo.assignment_audit aa ON ex.deal_detail_id=aa.source_deal_header_id_from	'
				
				
		exec spa_print @sql
		EXEC(@sql)
		
		
			---assigned deal (source_deal_header_id)
		set @sql='DELETE  ' + @tablename +' 
				 OUTPUT deleted.temp_id,''Error'', ''epa_allowance_data_adaptor'',''' + @facility_id + ''',''Assignment_exist_to''
				  , ''Data error for PRG_Code:''+ deleted.PRG_Code +''; Facility_ID:'+@facility_id+'; START_BLOCK:'' + cast(deleted.Start_Block as varchar)+ ''; END_BLOCK:'' + cast(deleted.end_Block as varchar)+ ''; VINTAGE_YEAR:''+ CAST(deleted.VINTAGE_YEAR AS VARCHAR) + '' ( The deal is already assigned with deal_id: ''+ CAST(ex.deal_header_id AS VARCHAR)+'')''
				  , ''Please check source data.''				  
				INTO #import_status (temp_id,ErrorCode,Module,Source,[type],[description], nextstep)
				FROM ' + @tablename +' a INNER JOIN #tmp_existing_deal	ex ON ex.temp_id=a.temp_id							
						INNER JOIN dbo.assignment_audit aa ON ex.deal_detail_id=aa.source_deal_header_id	'
				
				
		exec spa_print @sql
		EXEC(@sql)
			

		---source_traders
		set @sql='INSERT INTO [dbo].[source_traders]
           ([source_system_id]
           ,[trader_id]
           ,[trader_name]
           ,[trader_desc]
			)
		select distinct
           2,
           CASE when a.SELL_ACCT_NUMBER='''+@facility_id+ ''' THEN a.SELL_DISPLAY_NAME
						WHEN a.buy_ACCT_NUMBER='''+@facility_id+ ''' THEN a.BUY_DISPLAY_NAME
					END,
           CASE when a.SELL_ACCT_NUMBER='''+@facility_id+ ''' THEN a.SELL_DISPLAY_NAME
						WHEN a.buy_ACCT_NUMBER='''+@facility_id+ ''' THEN a.BUY_DISPLAY_NAME
					END,
           CASE when a.SELL_ACCT_NUMBER='''+@facility_id+ ''' THEN a.SELL_DISPLAY_NAME
						WHEN a.buy_ACCT_NUMBER='''+@facility_id+ ''' THEN a.BUY_DISPLAY_NAME
					END
			FROM ' + @tablename +' a left JOIN source_traders b on b.trader_id=CASE when a.SELL_ACCT_NUMBER='''+@facility_id+ ''' THEN a.SELL_DISPLAY_NAME
						WHEN a.buy_ACCT_NUMBER='''+@facility_id+ ''' THEN a.BUY_DISPLAY_NAME
					END
				 where b.trader_id is null
				and (CASE when a.SELL_ACCT_NUMBER='''+@facility_id+ ''' THEN a.SELL_DISPLAY_NAME
						WHEN a.buy_ACCT_NUMBER='''+@facility_id+ ''' THEN a.BUY_DISPLAY_NAME
					END) is not null	'



		exec spa_print @sql
		EXEC(@sql)

			--counterparty

		set @sql='INSERT INTO [dbo].[source_counterparty]
			   ([source_system_id]
			   ,[counterparty_id]
			   ,[counterparty_name]
			   ,[counterparty_desc]
			   ,[int_ext_flag])
			select distinct 2,
					CASE WHEN a.TRANSACTION_TYPE IN (''Emissions Deduction'' ,''Initial Allocation'',''Transfer from Legacy SYSTEM'')  THEN ''EPA''
								ELSE 
										CASE WHEN a.SELL_ACCT_NUMBER='''+@facility_ID+''' THEN a.BUY_ACCT_Name 
											WHEN a.Buy_acCT_NUMBER='''+@facility_ID+''' THEN a.sell_ACCT_Name 
										END
								END,
					CASE WHEN a.TRANSACTION_TYPE IN (''Emissions Deduction'' ,''Initial Allocation'',''Transfer from Legacy SYSTEM'')  THEN ''EPA''
								ELSE 
										CASE WHEN a.SELL_ACCT_NUMBER='''+@facility_ID+''' THEN a.BUY_ACCT_Name 
											WHEN a.Buy_acCT_NUMBER='''+@facility_ID+''' THEN a.sell_ACCT_Name 
										END
								END,
					CASE WHEN a.TRANSACTION_TYPE IN (''Emissions Deduction'' ,''Initial Allocation'',''Transfer from Legacy SYSTEM'')  THEN ''EPA''
								ELSE 
										CASE WHEN a.SELL_ACCT_NUMBER='''+@facility_ID+''' THEN a.BUY_ACCT_Name 
											WHEN a.Buy_acCT_NUMBER='''+@facility_ID+''' THEN a.sell_ACCT_Name 
										END
								END,
				''e''
				FROM ' + @tablename +' a 
				left JOIN [counterparty_epa_account] b on b.external_value=CASE WHEN a.TRANSACTION_TYPE IN (''Emissions Deduction'' ,''Initial Allocation'',''Transfer from Legacy SYSTEM'')  THEN ''EPA''
								ELSE 
										CASE WHEN a.SELL_ACCT_NUMBER='''+@facility_ID+''' THEN a.BUY_ACCT_NUMBER 
											WHEN a.Buy_acCT_NUMBER='''+@facility_ID+''' THEN a.sell_ACCT_NUMBER 
										END
								END
				left join [dbo].[source_counterparty] c on c.counterparty_id=CASE WHEN a.TRANSACTION_TYPE IN (''Emissions Deduction'' ,''Initial Allocation'',''Transfer from Legacy SYSTEM'')  THEN ''EPA''
								ELSE 
										CASE WHEN a.SELL_ACCT_NUMBER='''+@facility_ID+''' THEN a.BUY_ACCT_name 
											WHEN a.Buy_acCT_NUMBER='''+@facility_ID+''' THEN a.sell_ACCT_name 
										END
								END
				 where b.counterparty_id is null
				and (CASE WHEN a.TRANSACTION_TYPE IN (''Emissions Deduction'' ,''Initial Allocation'',''Transfer from Legacy SYSTEM'')  THEN ''EPA''
								ELSE 
										CASE WHEN a.SELL_ACCT_NUMBER='''+@facility_ID+''' THEN a.SELL_ACCT_NUMBER 
											WHEN a.Buy_acCT_NUMBER='''+@facility_ID+''' THEN a.Buy_acCT_NUMBER 
										END
								END) is not null and c.counterparty_id is null	'
		exec spa_print @sql
		EXEC(@sql)

		set @sql='INSERT INTO [dbo].[counterparty_epa_account]
			   ([counterparty_id]
			   ,[external_type_id]
			   ,[external_value])

			select distinct c.source_counterparty_id,
					case right(CASE WHEN a.TRANSACTION_TYPE IN (''Emissions Deduction'' ,''Initial Allocation'',''Transfer from Legacy SYSTEM'')  THEN ''EPA''
									ELSE 
											CASE WHEN a.SELL_ACCT_NUMBER='''+@facility_ID+''' THEN a.BUY_ACCT_NUMBER 
												WHEN a.Buy_acCT_NUMBER='''+@facility_ID+''' THEN a.sell_ACCT_NUMBER 
											END
									END
								,6)
					when ''FACLTY''  then 2201 
					when ''EPA'' then 2201
					else 2203 end,
					CASE WHEN a.TRANSACTION_TYPE IN (''Emissions Deduction'' ,''Initial Allocation'',''Transfer from Legacy SYSTEM'')  THEN ''EPA''
								ELSE 
										CASE WHEN a.SELL_ACCT_NUMBER='''+@facility_ID+''' THEN a.BUY_ACCT_NUMBER  
											WHEN a.Buy_acCT_NUMBER='''+@facility_ID+''' THEN a.sell_ACCT_NUMBER 
										END
								END
				FROM ' + @tablename +' a 
					inner join  source_counterparty c on c.counterparty_id=CASE WHEN a.TRANSACTION_TYPE IN (''Emissions Deduction'' ,''Initial Allocation'',''Transfer from Legacy SYSTEM'')  THEN ''EPA''
								ELSE 
										CASE WHEN a.SELL_ACCT_NUMBER='''+@facility_ID+''' THEN a.BUY_ACCT_Name 
											WHEN a.Buy_acCT_NUMBER='''+@facility_ID+''' THEN a.sell_ACCT_Name 
										END
								END 
					left JOIN [counterparty_epa_account] b on b.external_value=CASE WHEN a.TRANSACTION_TYPE IN (''Emissions Deduction'' ,''Initial Allocation'',''Transfer from Legacy SYSTEM'')  THEN ''EPA''
								ELSE 
										CASE WHEN a.SELL_ACCT_NUMBER='''+@facility_ID+''' THEN a.BUY_ACCT_NUMBER 
											WHEN a.Buy_acCT_NUMBER='''+@facility_ID+''' THEN a.sell_ACCT_NUMBER 
										END
								END
				 where b.counterparty_id is null
				and (CASE WHEN a.TRANSACTION_TYPE IN (''Emissions Deduction'' ,''Initial Allocation'',''Transfer from Legacy SYSTEM'')  THEN ''EPA''
								ELSE 
										CASE WHEN a.SELL_ACCT_NUMBER='''+@facility_ID+''' THEN a.SELL_ACCT_NUMBER 
											WHEN a.Buy_acCT_NUMBER='''+@facility_ID+''' THEN a.Buy_acCT_NUMBER 
										END
								END) is not null	'
		exec spa_print @sql
		EXEC(@sql)



-----------------end Validation----------------------------------------------------------------------------		
		
		
		declare @map1 int
        select  @map1= source_book_id from dbo.source_book  where source_system_book_id=@facility_id
        
--------update existing data-----------------------------------------------------------------------		
        
		--delete invalid data from existing deal
		delete #tmp_existing_deal from #tmp_existing_deal ex inner join #import_status err on ex.temp_id=err.temp_id
		
		set @sql='           
		   update [dbo].[source_deal_header] 
		   set
				deal_date=s.TRANSACTION_DATE ,
				physical_financial_flag=sdht.physical_financial_flag,
				structured_deal_id =s.TRANSACTION_ID ,
				counterparty_id =sc.source_counterparty_id  ,
				source_deal_type_id =sdht.source_deal_type_id,
				deal_sub_type_type_id=sdht.deal_sub_type_type_id,
				source_system_book_id1='+CAST(@map1 AS VARCHAR)+',
				source_system_book_id2=-2 ,
				source_system_book_id3=-3 ,
				source_system_book_id4=-4 ,
				description1=s.TRANSACTION_TYPE ,
				deal_category_value_id=475 ,
				trader_id=st.source_trader_id ,
				template_id=sdht.template_id,
				generator_id='+CAST(@generator_id AS VARCHAR)+',
				header_buy_sell_flag=
					CASE when s.SELL_ACCT_NUMBER='''+@facility_id+ ''' THEN ''s''
						WHEN s.buy_ACCT_NUMBER='''+@facility_id+ ''' THEN ''b''
					END,
				term_frequency =''a''
			  FROM source_deal_header sdh INNER JOIN #tmp_existing_deal ex ON sdh.source_deal_header_id= ex.deal_header_id
					inner join '+@tablename +' s ON s.temp_id=ex.temp_id
					INNER JOIN dbo.static_data_value sdv ON sdv.code=s.PRG_Code AND sdv.TYPE_ID=3100
					INNER JOIN dbo.source_price_curve_def spcd ON  sdv.value_id=spcd.program_scope_value_id
					INNER JOIN dbo.source_deal_detail_template sddt  ON spcd.source_curve_def_id=sddt.curve_id
					INNER JOIN dbo.source_deal_header_template sdht ON sdht.template_id=sddt.template_id
					INNER JOIN source_traders st ON st.trader_id=CASE when s.SELL_ACCT_NUMBER='''+@facility_id+ ''' THEN s.SELL_DISPLAY_NAME
						WHEN s.buy_ACCT_NUMBER='''+@facility_id+ ''' THEN s.BUY_DISPLAY_NAME
					END
					
					INNER JOIN dbo.source_counterparty	SC	
						  ON sc.counterparty_id=CASE WHEN s.TRANSACTION_TYPE IN (''Emissions Deduction'' ,''Initial Allocation'',''Transfer from Legacy SYSTEM'')  THEN ''EPA''
								ELSE 
										CASE WHEN s.SELL_ACCT_NUMBER='''+@facility_ID+''' THEN s.buy_ACCT_NAME 
											WHEN s.Buy_acCT_NUMBER='''+@facility_ID+''' THEN s.Sell_ACCT_NAME 
										END
								END
			   '
    exec spa_print @sql 
    EXEC(@sql)
	set @total_upd_rec=@@ROWCOUNT
	IF ISNULL(@total_upd_rec,0)<>0
		INSERT INTO #import_status(ErrorCode, module, source, [type],[description],nextstep) 
		VALUES('Success', 'epa_allowance_data_adaptor', @facility_ID, 'Success_updated',
		CAST(@total_upd_rec AS varchar) +' records successfully updated out of ' + CAST(@total_no_rec AS VARCHAR) 
		+ '.',
		'Please verify imported data.' )
			
	set @sql='
		update [dbo].[source_deal_detail]
           set
				fixed_float_leg =sddt.fixed_float_leg
				,buy_sell_flag =sdh.header_buy_sell_flag
				,curve_id=sddt.curve_id
				,deal_volume_frequency =sddt.deal_volume_frequency
				,deal_volume_uom_id =sddt.deal_volume_uom_id
          FROM source_deal_detail sdd INNER JOIN #tmp_existing_deal ex ON sdd.source_deal_detail_id= ex.deal_detail_id
				inner join '+@tablename +' s ON s.temp_id=ex.temp_id
		  INNER JOIN    dbo.source_deal_header sdh ON sdh.source_deal_header_id=ex.deal_header_id 
		  INNER JOIN dbo.source_deal_header_template sdht ON sdht.template_id=sdh.template_id
		  INNER join dbo.source_deal_detail_template sddt  ON sdht.template_id=sddt.template_id'
   exec spa_print @sql
   EXEC(@sql)
     
          
   update [dbo].[Gis_Certificate]
		set
			gis_cert_date=ex.TRANSACTION_DATE 
      FROM Gis_Certificate gc INNER JOIN #tmp_existing_deal ex ON gc.source_deal_header_id= ex.deal_detail_id

	set @sql='DELETE  ' + @tablename +' 
				FROM ' + @tablename +' s INNER JOIN #tmp_existing_deal	ex ON ex.temp_id=s.temp_id'

	exec(@sql)
	truncate table #tmp_existing_deal
	
	--------end update existing data-----------------------------------------------------------------------		

--------------------------------------------------------------------------------------------------------------------
-------------Start Data inserting-----------------------------------------------------------------------------------
  
	set @sql='           
       INSERT INTO [dbo].[source_deal_header]
           ([source_system_id]
           ,[deal_id]
           ,[deal_date]
           ,[ext_deal_id]
           ,[physical_financial_flag]
           ,[structured_deal_id]
           ,[counterparty_id]
           ,[entire_term_start]
           ,[entire_term_end]
           ,[source_deal_type_id]
           ,[deal_sub_type_type_id]
           ,[source_system_book_id1]
           ,[source_system_book_id2]
           ,[source_system_book_id3]
           ,[source_system_book_id4]
           ,[description1]
           ,[deal_category_value_id]
           ,[trader_id]
           ,[template_id]
           ,[header_buy_sell_flag]
           ,[generator_id]
           ,[term_frequency]
           ,option_flag
           
		)
     SELECT 2
           ,'''+@process_id + '_' +cast(@generator_ID as varchar)+'_'+'''+CAST(s.temp_id AS VARCHAR)
           ,TRANSACTION_DATE deal_date
           ,null
           ,sdht.physical_financial_flag
           ,TRANSACTION_ID structured_deal_id
           ,sc.source_counterparty_id  counterparty_id
           ,CAST(CAST(VINTAGE_YEAR AS VARCHAR)+''-01-01'' as DATETIME) entire_term_start
           ,CAST(CAST(VINTAGE_YEAR+1 AS VARCHAR)+''-01-01'' as DATETIME)-1 entire_term_end
           ,sdht.source_deal_type_id
           ,sdht.deal_sub_type_type_id
           ,'+cast(@map1 as varchar) +'
           ,-2 source_system_book_id2
           ,-3 source_system_book_id3
           ,-4 source_system_book_id4
           ,s.TRANSACTION_TYPE description1
           ,475 deal_category_value_id
           ,st.source_trader_id trader_id
           ,sdht.template_id
           ,CASE when s.SELL_ACCT_NUMBER='''+@facility_id+ ''' THEN ''s''
				WHEN s.buy_ACCT_NUMBER='''+@facility_id+ ''' THEN ''b''
			END header_buy_sell_flag
           ,'+ CAST(@generator_id AS VARCHAR) +' generator_id
           ,''a'',''n''
          FROM '+@tablename +' s 
		INNER JOIN dbo.static_data_value sdv ON sdv.code=s.PRG_Code AND sdv.TYPE_ID=3100
		INNER JOIN dbo.source_price_curve_def spcd ON  sdv.value_id=spcd.program_scope_value_id
		INNER JOIN dbo.source_deal_detail_template sddt  ON spcd.source_curve_def_id=sddt.curve_id
		INNER JOIN dbo.source_deal_header_template sdht ON sdht.template_id=sddt.template_id
		INNER JOIN source_traders st ON st.trader_id=CASE when s.SELL_ACCT_NUMBER='''+@facility_id+ ''' THEN s.SELL_DISPLAY_NAME
			WHEN s.buy_ACCT_NUMBER='''+@facility_id+ ''' THEN s.BUY_DISPLAY_NAME
		END
		INNER JOIN dbo.source_counterparty	SC	
          ON sc.counterparty_id=CASE WHEN s.TRANSACTION_TYPE IN (''Emissions Deduction'' ,''Initial Allocation'',''Transfer from Legacy SYSTEM'')  THEN ''EPA''
				ELSE 
						CASE WHEN s.SELL_ACCT_NUMBER='''+@facility_ID+''' THEN s.buy_ACCT_NAME 
							WHEN s.Buy_acCT_NUMBER='''+@facility_ID+''' THEN s.Sell_ACCT_NAME 
						END
				END
           '
    exec spa_print @sql 
    EXEC(@sql)
	set @total_upd_rec=@@ROWCOUNT
	IF ISNULL(@total_upd_rec,0)<>0
		INSERT INTO #import_status(ErrorCode, Module, Source, [type], [description], nextstep) 
		VALUES('Success', 'epa_allowance_data_adaptor', @facility_ID, 'Success_insert',
		CAST(@total_upd_rec AS varchar) +' records successfully inserted out of ' + CAST(@total_no_rec AS VARCHAR) + '.',
		'Please verify imported data.')

	set @sql='
		INSERT INTO [dbo].[source_deal_detail]
           ([source_deal_header_id]
           ,[term_start]
           ,[term_end]
           ,[Leg]
           ,[contract_expiration_date]
           ,[fixed_float_leg]
           ,[buy_sell_flag]
           ,[curve_id]
           ,[deal_volume]
           ,[deal_volume_frequency]
           ,[deal_volume_uom_id]
           ,[volume_left]
,settlement_date
			)
		SELECT sdh.source_deal_header_id
			   ,sdh.entire_term_start term_start
			   ,sdh.entire_term_end term_end
			   ,1
			   ,sdh.deal_date --sdh.entire_term_end contract_expiration_date --??????????????????????
			   ,sddt.fixed_float_leg
			   ,sdh.header_buy_sell_flag buy_sell_flag
			   ,sddt.curve_id
			   ,s.TOTAL_BLOCK deal_volume
			   ,sddt.deal_volume_frequency
			   ,sddt.deal_volume_uom_id
			   ,s.TOTAL_BLOCK volume_left
		,sdh.deal_date
		FROM '+@tablename +' s       
		  INNER JOIN    dbo.source_deal_header sdh ON sdh.deal_id='''+@process_id + '_' +cast(@generator_ID as varchar)+'_'+'''+CAST(s.temp_id AS VARCHAR) 
		  INNER JOIN dbo.source_deal_header_template sdht ON sdht.template_id=sdh.template_id
		  INNER join dbo.source_deal_detail_template sddt  ON sdht.template_id=sddt.template_id'
   exec spa_print @sql
   EXEC(@sql)


   set @sql='       
           INSERT INTO [dbo].[Gis_Certificate]
           ([source_deal_header_id]
           ,[gis_certificate_number_from]
           ,[gis_certificate_number_to]
           ,[certificate_number_from_int]
           ,[certificate_number_to_int]
           ,[gis_cert_date]
		)
    select 
           sdd.source_deal_detail_id source_deal_header_id
           ,s.START_BLOCK gis_certificate_number_from
           ,s.END_BLOCK gis_certificate_number_to
           ,s.START_BLOCK certificate_number_from_int
           ,s.END_BLOCK certificate_number_to_int
           ,sdh.deal_date gis_cert_date
      FROM '+@tablename +' s       
      INNER JOIN    dbo.source_deal_header sdh ON sdh.deal_id='''+@process_id + '_' +cast(@generator_ID as varchar)+'_'+'''+CAST(s.temp_id AS VARCHAR)
      INNER JOIN dbo.source_deal_detail sdd  ON sdh.source_deal_header_id=sdd.source_deal_header_id'
   
   exec spa_print @sql
   EXEC(@sql)
   
   
	-------------Start Assigment data insrting-----------------------------------------------------------------------------------

   set @sql=' insert into #template_id(template_id) select distinct sdht.template_id  FROM '+@tablename +' s 
		INNER JOIN dbo.static_data_value sdv ON sdv.code=s.PRG_Code AND sdv.TYPE_ID=3100
           INNER JOIN dbo.source_price_curve_def spcd ON  sdv.value_id=spcd.program_scope_value_id
            INNER JOIN dbo.source_deal_detail_template sddt  ON spcd.source_curve_def_id=sddt.curve_id
          INNER JOIN dbo.source_deal_header_template sdht ON sdht.template_id=sddt.template_id
          '
    exec spa_print @sql
    EXEC(@sql)      

	set @sql='insert into #deal_for_transfer ( deal_header_id ,deal_detail_id ,start_no , end_no ,[gis_cert_date],yr,buy_sell_flag, deal_volume,buy_acc_no ,sell_acc_no  )
			  select	sdd.[source_deal_header_id] deal_header_id
						,sdd.source_deal_detail_id deal_detail_id
					   ,[certificate_number_from_int] start_no
					   ,[certificate_number_to_int] end_no
					   ,[gis_cert_date]
					   ,year(sdd.term_start) yr
					   ,sdd.buy_sell_flag
					   ,deal_volume,s.buy_ACCT_NUMBER ,s.SELL_ACCT_NUMBER
				from [dbo].[Gis_Certificate] gc inner join dbo.source_deal_detail sdd on gc.source_deal_header_id=sdd.source_deal_detail_id
					and sdd.volume_left>0 
					inner join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id 
					and sdh.generator_id='+cast(@generator_id as varchar)+'
					AND sdh.source_system_book_id1= '+cast(@map1 as varchar) +'
					AND sdh.source_system_book_id2 =-2 
					AND sdh.source_system_book_id3 =-3 
					AND sdh.source_system_book_id4 =-4 
				inner join #template_id tmp ON tmp.template_id=sdh.template_id
				  INNER JOIN  '+@tablename +' s ON sdh.deal_id='''+@process_id + '_' +cast(@generator_ID as varchar)+'_'+'''+CAST(s.temp_id AS VARCHAR)
				left join [dbo].[assignment_audit] aa on aa.source_deal_header_id=sdd.source_deal_detail_id
					where aa.source_deal_header_id is null '
		exec spa_print @sql
		EXEC(@sql)
       /*
		set @sql='	  select	sdd.[source_deal_header_id] deal_header_id
						,sdd.source_deal_detail_id deal_detail_id
					   ,[certificate_number_from_int] start_no
					   ,[certificate_number_to_int] end_no
					   ,[gis_cert_date]
					   ,year(sdd.term_start) yr
					   ,sdd.buy_sell_flag
					   ,deal_volume,s.buy_ACCT_NUMBER ,s.SELL_ACCT_NUMBER
				from [dbo].[Gis_Certificate] gc inner join dbo.source_deal_detail sdd on gc.source_deal_header_id=sdd.source_deal_detail_id
					and sdd.volume_left>0 
					inner join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id 
					and sdh.generator_id='+cast(@generator_id as varchar)+'
					AND sdh.source_system_book_id1= '+cast(@map1 as varchar) +'
					AND sdh.source_system_book_id2 =-2 
					AND sdh.source_system_book_id3 =-3 
					AND sdh.source_system_book_id4 =-4 
				inner join #template_id tmp ON tmp.template_id=sdh.template_id
				  INNER JOIN  '+@tablename +' s ON sdh.deal_id='''+@process_id + '_' +cast(@generator_ID as varchar)+'_'+'''+CAST(s.temp_id AS VARCHAR)
				left join [dbo].[assignment_audit] aa on aa.source_deal_header_id=sdd.source_deal_detail_id
					where aa.source_deal_header_id is null and [certificate_number_from_int] in (2138474,2142474) and year(sdd.term_start)=1998'
		exec spa_print @sql
		EXEC(@sql)

*/


	INSERT INTO #tmp_transfer_id (source_temp_id , transfer_temp_id,[cert_from],[cert_to],transaction_date,VINTAGE_YEAR,TOTAL_BLOCK,deal_header_id,deal_header_id_from)  
			SELECT  a.deal_detail_id , b.deal_detail_id ,b.start_no,b.end_no,b.gis_cert_date,b.yr,b.deal_volume,b.deal_header_id,a.deal_header_id
			FROM #deal_for_transfer a 
			INNER JOIN #deal_for_transfer b ON a.start_no=b.start_no AND a.end_no=b.end_no 
			AND a.yr=b.yr 
			and a.buy_sell_flag='b' and b.buy_sell_flag='s'	
			AND b.buy_sell_flag<>a.buy_sell_flag
			AND a.deal_detail_id<>b.deal_detail_id
			and a.sell_acc_no=b.buy_acc_no
--select * from #tmp_transfer_id
	INSERT INTO #tmp_transfer_id (source_temp_id , transfer_temp_id,[cert_from],[cert_to],transaction_date,VINTAGE_YEAR,TOTAL_BLOCK,deal_header_id,deal_header_id_from)  
			SELECT  a.deal_detail_id , b.deal_detail_id ,b.start_no,b.end_no,b.gis_cert_date,b.yr,b.deal_volume,b.deal_header_id,a.deal_header_id
			FROM #deal_for_transfer a 
			INNER JOIN #deal_for_transfer b ON a.start_no<=b.start_no AND a.end_no>=b.end_no 
			AND a.yr=b.yr 
			and a.buy_sell_flag='b' and b.buy_sell_flag='s'	
			AND b.buy_sell_flag<>a.buy_sell_flag
			AND a.deal_detail_id<>b.deal_detail_id
			--and a.sell_acc_no<>b.buy_acc_no
			left join #tmp_transfer_id tt on 
				tt.source_temp_id=a.deal_detail_id or 
			tt.transfer_temp_id=b.deal_detail_id 
			where tt.source_temp_id is null
--select * from #deal_for_transfer where start_no='2138474' and yr=1998

--select * from #tmp_transfer_id where source_temp_id=30949
--30949
--30982
--30984

--select * from [assignment_audit] where source_deal_header_id=25996
    INSERT INTO [dbo].[assignment_audit]
           ([assignment_type]
           ,[assignment_date]
           ,[assigned_volume]
           ,[source_deal_header_id]
           ,[source_deal_header_id_from]
           ,[compliance_year]
           ,[state_value_id]
           ,[assigned_date]
           ,[assigned_by]
           ,[cert_from]
           ,[cert_to]
			)
     select 
           case when sdh.description1='Private Transfer' then 5173 else 5180 end assignment_type
           ,tmp.transaction_date assignment_date
           ,tmp.TOTAL_BLOCK assigned_volume
           ,tmp.transfer_temp_id source_deal_header_id
           ,tmp.source_temp_id   source_deal_header_id_from
           ,tmp.VINTAGE_YEAR compliance_year
           ,rg.state_value_id
           ,tmp.transaction_date assigned_date
           ,dbo.fnadbuser() assigned_by
           ,tmp.cert_from
           ,tmp.cert_to
FROM #tmp_transfer_id tmp INNER JOIN dbo.source_deal_header sdh ON sdh.source_deal_header_id=tmp.deal_header_id
		INNER JOIN rec_generator rg ON rg.generator_id=sdh.generator_id
--select a.source_deal_detail_id,a.deal_volume,a.volume_left,t.TOTAL_BLOCK v2
--		FROM source_deal_detail a INNER JOIN 
--		(
--		SELECT source_temp_id,SUM(TOTAL_BLOCK) TOTAL_BLOCK 		
--			FROM #tmp_transfer_id GROUP BY source_temp_id
--		) t ON t.source_temp_id=a.source_deal_detail_id


--		UPDATE	source_deal_detail SET volume_left=a.volume_left-t.TOTAL_BLOCK
--		FROM source_deal_detail a INNER JOIN 
--		(
--		SELECT source_temp_id,SUM(TOTAL_BLOCK) TOTAL_BLOCK 		
--			FROM #tmp_transfer_id GROUP BY source_temp_id
--		) t ON t.source_temp_id=a.source_deal_detail_id

 --  select header_buy_sell_flag,assignment_type_value_id, * from source_deal_header where assignment_type_value_id =5180

		UPDATE dbo.source_deal_header SET 
           assignment_type_value_id=case when sdh.description1='Private Transfer' then 5173 else 5180 end ,
			compliance_year=tmp.VINTAGE_YEAR,
			state_value_id=rg.state_value_id,
			assigned_date=tmp.transaction_date,
			assigned_by=dbo.fnadbuser(),
			ext_deal_id=tmp.deal_header_id_from
		FROM #tmp_transfer_id tmp INNER JOIN dbo.source_deal_header sdh ON sdh.source_deal_header_id=tmp.deal_header_id
		INNER JOIN rec_generator rg ON rg.generator_id=sdh.generator_id
--select * from #tmp_transfer_id order by source_temp_id
UPDATE dbo.source_deal_header SET deal_id=source_deal_header_id WHERE deal_id LIKE @process_id + '%'

	COMMIT TRAN
	
	END TRY
	BEGIN CATCH
	
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
	
		SET @error_msg = ERROR_MESSAGE() 
		
		EXEC spa_print 'Error while importing facility ', @facility_id, ': ', @error_msg
			
		INSERT INTO #import_status (ErrorCode,Module,Source,[type],[description], nextstep)
		VALUES ('Error', 'epa_allowance_data_adaptor', @facility_id,'import_data_error' ,'Error: ' + @error_msg + ' for facility_ID:' + @facility_id + '.', 'Please check source data.')
	END CATCH
	FETCH NEXT FROM b_cursor INTO @facility_id,@tablename, @generator_id
END --end of while loop
CLOSE b_cursor
DEALLOCATE  b_cursor
EXEC spa_print 'end cursor'	
	
UPDATE dbo.source_deal_header SET deal_id=source_deal_header_id WHERE deal_id LIKE @process_id + '%'
		
		
		-------------end Assigment data insrting-----------------------------------------------------------------------------------

-------------end  Data inserting-----------------------------------------------------------------------------------

----messaging-----
	DECLARE @errorcode VARCHAR(1)
	IF EXISTS(SELECT * FROM #import_status WHERE ErrorCode <> 'Success')
	BEGIN
	--import_data_files_audit
		set @errorcode='e'
		insert into source_system_data_import_status_detail(process_id,source,type,[description],type_error)
		select @process_id,source,type,[description],[TYPE] from #import_status WHERE ErrorCode <> 'Success'
	END
	ELSE
	BEGIN
		SET @errorcode='s'
	END	

	INSERT INTO source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
		SELECT @process_id,MAX(errorcode),MAX(module),MAX(source),[TYPE],
		CASE [TYPE] 
		WHEN 'DATA_OVERLAP1' THEN 'Overlap found within the import file'
		WHEN 'DATA_OVERLAP2' THEN 'Overlap found in existing deals'
		WHEN 'Assignment_exist_to' THEN 'Import failed for assigned deals'
		WHEN 'Assignment_exist_from' THEN 'Import failed for deals already assigned'
		WHEN 'not_exist_counterparty' THEN 'Counterparty not found'
		WHEN 'not_exist_trader' THEN 'Trader not found'
		WHEN 'no_data_found' THEN 'No data found'
		WHEN 'source_book' THEN 'Book not found'
		ELSE [TYPE] 
		END +' ( Total records ' +CAST(count(*) AS VARCHAR) + ' out of '+ CAST(max(isnull(total_no_rec,0)) AS VARCHAR)+' failed in import process.)' [description],
		MAX(nextstep) + '(Please drill down for details).' AS recommendation
	FROM  #import_status s left join #tmp_no_rec r on s.source=r.facility_id  where ErrorCode <> 'Success' GROUP BY source, [TYPE]
	INSERT INTO source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
		SELECT @process_id,errorcode,module,source,[TYPE],[description],nextstep
	FROM  #import_status  where ErrorCode = 'Success'
/*
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

	select @desc = '<a target="_blank" href="' + @url + '">' + 
				'EPA Allowance import process Completed for as of date:' + dbo.FNAUserDateFormat(getdate(), @user_login_id) + 
			case when (@errorcode = 'e') then ' (ERRORS found)' else '' end +
			'.</a>'

	EXEC  spa_message_board 'i', @user_login_id,
				NULL, 'Import.Allowance',
				@desc, '', '', @errorcode, @job_name,null,@process_id	
	
	*/
	EXEC spa_compliance_workflow 114,'i',@process_id,NULL,@errorcode
--		SELECT * FROM #import_status
--		SELECT * FROM message_board WHERE process_id=@process_id
--		SELECT * FROM source_system_data_import_status WHERE process_id=@process_id
--		SELECT * FROM source_system_data_import_status_detail WHERE process_id=@process_id
end try
begin catch
	IF @@TRANCOUNT > 0
		rollback tran

	set @desc='SQL Error found in SP' + OBJECT_NAME(@@PROCID) +':  (' + ERROR_MESSAGE() + ')'
	exec spa_print 'Error: ', @desc

	insert into source_system_data_import_status(process_id,code,module,source,type,
	[description],recommendation) 
	select @process_id,'Error','epa_allowance_data',@tablename,
	'Data Error',
	@desc,'Please check your data format.'
	
	EXEC  spa_message_board 'i', @user_login_id, NULL, 'epa_allowance_data',  @desc, '', '', 'e', @job_name,
		null,@process_id	
end CATCH

