


if object_id('testing.spa_check_pre_post') is not null
drop proc testing.spa_check_pre_post
go

create proc testing.spa_check_pre_post @rowids VARCHAR(max)
	,@action VARCHAR(1)='i' --i=insert, c=compare
	,@mode VARCHAR(1) ='a' --a=adhoc(results in backend); q=query results are saved in process table while run from front-end
	,@re_calc  VARCHAR(1) ='y' --y=will calculate the process like mtm,settlemt,position process first and then compare, n=no re-calculate the process
	,@as_of_date VARCHAR(10)='2013-07-01'
	,@sub_ids VARCHAR(max)=NULL
	,@stra_ids VARCHAR(max)=NULL
	,@book_ids VARCHAR(max)=null
	,@deal_header_ids  VARCHAR(MAX)=null
	,@term_start VARCHAR(10)=null,@term_end VARCHAR(10)=null
	,@process_id varchar(50)=null,@batch_process_id VARCHAR(100) = NULL
	,@batch_report_param VARCHAR(1000) = NULL


as

/*

DROP TABLE  #compare_columns
DROP TABLE  #join_columns
DROP TABLE #pre_post_calc_status
DROP TABLE #process_table_name
DROP TABLE #rowid
DROP TABLE #pre_post_calc_status
DROP TABLE #display_columns

SET nocount off	
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo


DECLARE @rowids VARCHAR(max)='40',
	@action VARCHAR(1)='c' --i=insert, c=compare
	,@mode VARCHAR(1) ='a' --a=adhoc(results in backend); q=query results are saved in process table while run from front-end
	,@re_calc  VARCHAR(1) ='n' --y=will calculate the process like mtm,settlemt,position process first and then compare, n=no re-calculate the process
	,@as_of_date VARCHAR(10)='2014-06-25'
	,@sub_ids VARCHAR(MAX)=NULL
	,@stra_ids VARCHAR(200)=NULL
	,@book_ids VARCHAR(250)=null

	,@deal_header_ids  VARCHAR(MAX)=null
	,@term_start VARCHAR(10)=null,@term_end VARCHAR(10)=null
	,@process_id varchar(50)
					
CLOSE config
DEALLOCATE config

--*/


DECLARE @url varchar(500),@user_id varchar(30)
DECLARE @error_code varchar(1)
DECLARE @module_desc varchar(250)
DECLARE @desc varchar(8000)
DECLARE @st VARCHAR(MAX),@deal_filters varchar(250),@run_start_time DATETIME,@db_name VARCHAR(50)
declare @tbl1 varchar(500),@tbl2 varchar(500),@tbl3 varchar(500),@tbl4 varchar(500),@tbl5 varchar(500),@involk VARCHAR(1),@report_process_id varchar(150)

--SET @as_of_date=convert(varchar(10),GETDATE(),120)
SET @db_name='testing.' --for saving benchmark table into external database
SET @run_start_time=GETDATE()
SET @involk='n'
set @user_id=isnull(@user_id,dbo.fnadbuser())
SET @process_id=isnull(@process_id,REPLACE(newid(),'-','_'))

set @as_of_date=isnull(nullif(@as_of_date,''),convert(varchar(10),getdate(),120))

CREATE TABLE #pre_post_calc_status
(
	process_id varchar(100) COLLATE DATABASE_DEFAULT ,
	ErrorCode varchar(50) COLLATE DATABASE_DEFAULT ,
	Module varchar(100) COLLATE DATABASE_DEFAULT ,
	Source varchar(100) COLLATE DATABASE_DEFAULT ,
	type varchar(100) COLLATE DATABASE_DEFAULT ,
	[description] varchar(1000) COLLATE DATABASE_DEFAULT ,
	[nextstep] varchar(250) COLLATE DATABASE_DEFAULT 
)

CREATE TABLE #process_table_name (
	row_count INT,	tbl_name varchar(250) COLLATE DATABASE_DEFAULT 
)
-------------------------------------------------------------------------------------------
-----------------------------------------Start Data filtration------------------------------

SET @deal_filters = dbo.FNAProcessTableName('report_position', @user_id, @process_id)

IF OBJECT_ID(@deal_filters) IS null
BEGIN 

	if object_id('tempdb..#deal_filter_pre_post') is not null
	drop table #deal_filter_pre_post

	create table #deal_filter_pre_post(source_deal_header_id int)

	IF @deal_header_ids IS not null
		insert into #deal_filter_pre_post (source_deal_header_id)
		SELECT item FROM dbo.FNASplit(@deal_header_ids,',') f

	ELSE
	BEGIN
		
		SET @st='
			insert into #deal_filter_pre_post (source_deal_header_id)
			SELECT source_deal_header_id FROM source_deal_header	sdh		
			inner  join source_system_book_map sbm
			on sbm.source_system_book_id1=sdh.source_system_book_id1 and sbm.source_system_book_id2=sdh.source_system_book_id2
			and sbm.source_system_book_id3 =sdh.source_system_book_id3 and sbm.source_system_book_id4 =sdh.source_system_book_id4           
				INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=sbm.fas_book_id
				INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
			WHERE 1=1  ' +CASE WHEN  @sub_ids IS NULL THEN '' ELSE ' and stra.parent_entity_id in ('+@sub_ids+')' END
			+CASE WHEN  @stra_ids IS NULL THEN '' ELSE ' and stra.entity_id in ('+@stra_ids+')' END
			+CASE WHEN  @book_ids IS NULL THEN '' ELSE ' and stra.entity_id in ('+@book_ids+')' END

		EXEC spa_print @st
		EXEC(@st)
	END

	exec('select distinct *,''i'' [action] into '+@deal_filters+' from #deal_filter_pre_post')
END 

-----------------------------------------End Data filtration------------------------------
------------------------------------------------------------------------------------

DECLARE @module_id INT,@pre_module_id INT
	,@tbl_name VARCHAR(150)
	,@description VARCHAR(150)
	,@join_columns VARCHAR(500)
	,@compare_columns VARCHAR(500)
	,@exec_sp  VARCHAR(max)
	,@re_calc_sp  VARCHAR(max)
	,@as_of_date_filter_clm VARCHAR(50)
	,@deal_filter_clm VARCHAR(50),@display_columns VARCHAR(500)
	,@st_join_columns VARCHAR(max)
	,@st_compare_columns VARCHAR(max)
	,@st_display_columns VARCHAR(max)
	,@order_by_column_no VARCHAR(50)
	,@group_by_columns VARCHAR(max)
	,@having_columns VARCHAR(max)	
	,@select_columns VARCHAR(max)
	,@i INT
	,@from_stmt VARCHAR(max),@rowid varchar(5),@tbl_name_with_rowid VARCHAR(150)

	declare @list_src_column_name varchar(max),@list_dst_column_name varchar(max)

SET @i=0

SELECT item into #rowid FROM dbo.FNASplit(@rowids,',') f

DECLARE config CURSOR FOR 
	SELECT module_value_id , tbl_name, descrptn, unique_clms, compare_clms,  exec_sp, re_calc_sp, as_of_date_filter_clm, deal_filter_clm, display_clms,order_by_clm_index,right('0000000'+cast(s.row_id as varchar),4) rowid
	FROM dbo.pre_post_configuration s 
	INNER JOIN #rowid r ON s.row_id=r.item 
	ORDER BY module_value_id
OPEN config
FETCH NEXT FROM config INTO @module_id,@tbl_name,@description,@join_columns,@compare_columns,@exec_sp,@re_calc_sp
	,@as_of_date_filter_clm,@deal_filter_clm,@display_columns,@order_by_column_no,@rowid

WHILE @@FETCH_STATUS = 0
BEGIN
	set @tbl_name_with_rowid='t'+@rowid+'_'+@tbl_name
	set @tbl2=null
	SET @tbl1 = dbo.FNAProcessTableName(@tbl_name_with_rowid, @user_id, @process_id)
	set @i=@i+1
	TRUNCATE TABLE #pre_post_calc_status
	
	IF isnull(@pre_module_id,0)=@module_id
		set @involk='y'
	ELSE 
		set @involk='n'

	SET @pre_module_id=@module_id
	---------------calculation logic---------------------------------------------------
	----------------------------------------------------------------------------------
	IF @involk='n'
	BEGIN
		
		IF @re_calc_sp IS NOT NULL AND @re_calc='y'
		BEGIN
			IF @module_id=22502 --special logic handle for position recalculation..
			BEGIN
				set @st='insert into '+ @deal_filters+ '(source_deal_header_id,ACTION) SELECT fix.source_deal_header_id,''i'' 
								FROM  ' + @deal_filters + ' p inner join source_deal_header fix (nolock) on p.source_deal_header_id=fix.close_reference_id 
								and ISNULL(fix.internal_desk_id,17300)=17301 and isnull(fix.product_id,4101)=4100 
								LEFT JOIN '+@deal_filters+' m ON fix.source_deal_header_id=m.source_deal_header_id 
								WHERE  m.source_deal_header_id IS  null	
							'
				exec spa_print @st
				exec(@st)	
						
				-- insert nomination/schedule/actul deals
						
				set @st='insert into '+ @deal_filters+ '(source_deal_header_id,ACTION) 
					SELECT sdh.source_deal_header_id,''i'' 
					FROM  ' + @deal_filters + ' p inner join source_deal_header sdh (nolock) on p.source_deal_header_id=sdh.close_reference_id 
					and sdh.internal_deal_type_value_id IN(19,20)
					UNION
					SELECT sdh1.source_deal_header_id,''i''
					FROM  ' + @deal_filters + ' p inner join source_deal_header sdh (nolock) on p.source_deal_header_id=sdh.source_deal_header_id 
					and sdh.internal_deal_type_value_id IN(20,21)
					inner join source_deal_header sdh1 (nolock) on sdh1.source_deal_header_id=sdh.close_reference_id 
					'
				exec spa_print @st
				EXEC(@st)			
					
				set @st='INSERT INTO dbo.process_deal_position_breakdown (source_deal_header_id ,create_user,create_ts,process_status,insert_type ,deal_type ,commodity_id,fixation ,internal_deal_type_value_id)
					SELECT DISTINCT sdh.source_deal_header_id,'''+@user_id+''',getdate(),0,0,
					max(isnull(sdh.internal_desk_id,17300)) deal_type ,	max(isnull(spcd.commodity_id,-1)) commodity_id,max(isnull(sdh.product_id,4101)) fixation,max(isnull(sdh.internal_deal_type_value_id,-999999))
					FROM '+ @deal_filters +' h inner join source_deal_header sdh on h.source_deal_header_id=sdh.source_deal_header_id
						inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
						left join source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id and sdd.curve_id is not null
					group by sdh.source_deal_header_id'

				EXEC spa_print @st
				EXEC (@st)

				EXEC dbo.spa_update_deal_total_volume null,null,0,1,@user_id,'n',1			
						
			END
			SET @re_calc_sp=replace(replace(replace(REPLACE(@re_calc_sp,'$as_of_date$',ISNULL(''''+@as_of_date+'''','null')),'$sub_ids$',ISNULL(''''+@sub_ids+'''','null')),'$stra_ids$',ISNULL(''''+@stra_ids+'''','null')),'$book_ids$',ISNULL(''''+@book_ids+'''','null'))
			SET @re_calc_sp=replace(replace(replace(@re_calc_sp,'$term_start$',ISNULL(''''+@as_of_date+'''','null')),'$term_end$',ISNULL(''''+@as_of_date+'''','null')),'$deal_list_table$',ISNULL(''''+@deal_filters+'''','null'))
			SET @re_calc_sp=replace(@re_calc_sp,'$user_id$',ISNULL(''''+@user_id+'''','null'))
			exec spa_print @re_calc_sp
			EXEC(@re_calc_sp)

		END
		
		set @involk='y'
	END

	---------------end calculation logic---------------------------------------------------
	---------------------------------------------------------------------------------------

--SELECT @deal_filters,@exec_sp

	IF @exec_sp IS NOT NULL --for report only, not for table
	BEGIN
		set @report_process_id= @process_id+CAST(@i AS VARCHAR)
	
		if charindex('spa_rfx_run_sql_external',@exec_sp)=0 --old standard report
		begin
	
			SET @exec_sp='insert into #process_table_name '+@exec_sp
			if charindex('$process_id$',@exec_sp)=0
				set @exec_sp=@exec_sp+',$process_id$,null,1'
		
		end 
		else --report manager
		begin
			set @exec_sp=@exec_sp+',$process_id$'
		
		end
		SET @exec_sp=replace(replace(replace(REPLACE(@exec_sp,'$as_of_date$',''''+@as_of_date+''''),'$sub_ids$',case WHEN @sub_ids IS NULL THEN 'null' ELSE ''''+@sub_ids+'''' END)
			,'$stra_ids$',case WHEN @stra_ids IS NULL THEN 'null' ELSE ''''+@stra_ids+'''' END)
			,'$book_ids$',case WHEN @book_ids IS NULL THEN 'null' ELSE ''''+@book_ids+'''' END)

		--SELECT @process_id,@i
		SET @exec_sp=replace(replace(replace(replace(@exec_sp,'$term_start$',case WHEN @term_start IS NULL THEN 'null' ELSE ''''+@term_start+'''' END)
			,'$term_end$',case WHEN @term_end IS NULL THEN 'null' ELSE ''''+@term_end+'''' END)
			,'$deal_header_ids$',case WHEN @deal_header_ids IS NULL THEN 'null' ELSE ''''+@deal_header_ids+'''' END ),'$process_id$',''''
			+@report_process_id+'''')

		EXEC spa_print 'lllllllllllllllllllll'

		exec spa_print @exec_sp
		EXEC(@exec_sp)
		
		
		set @tbl2= dbo.FNAProcessTableName('batch_report', @user_id,@report_process_id)

		--delete identity column row_id
		IF COL_LENGTH(@tbl2, 'row_id') IS not NULL
		BEGIN
			exec('ALTER TABLE '+@tbl2+' drop column row_id')
		END

	END

	----------------------------------------------------------------------------------
	---------------Start Main Import/Compare logic---------------------------------------------------
	EXEC spa_print 'Start Main Import/Compare logic'

	EXEC spa_print @tbl_name_with_rowid
	EXEC spa_print @tbl_name --For physical Table (process result)
	EXEC spa_print @tbl2 --For adhoc report Table (sp output result) adiha_process table
	--SELECT  @tbl_name,@tbl2
	
	select @st_join_columns=null,@select_columns=null,@st_display_columns=null,@st_compare_columns=null,@group_by_columns=null,@having_columns=null	     ,@order_by_column_no=null
		

	if OBJECT_ID('tempdb..#join_columns') is not null drop table #join_columns
	if OBJECT_ID('tempdb..#compare_columns') is not null drop table #compare_columns
	if OBJECT_ID('tempdb..#display_columns') is not null drop table #display_columns



	SELECT item into #join_columns FROM dbo.FNASplit(@join_columns,',') f
	SELECT item into #compare_columns FROM dbo.FNASplit(@compare_columns,',') f
	SELECT item into #display_columns FROM dbo.FNASplit(@display_columns,',') f

	SELECT @select_columns=isnull(@select_columns,'')+',isnull(a.'+isnull(item,'')+',b.'+isnull(item,'')+') '+ isnull(item,'') FROM #join_columns
	SELECT @group_by_columns=isnull(@group_by_columns+',','')+'isnull(a.'+isnull(item,'')+',b.'+isnull(item,'')+')' FROM #join_columns

	SELECT @st_display_columns =ISNULL(@st_display_columns,'')+',max(isnull(a.'+isnull(item,'')+',b.'+isnull(item,'')+')) '+ isnull(item,'') FROM #display_columns
		
	SELECT @st_compare_columns =isnull(@st_compare_columns,'')+',max(b.'+isnull(item,'')+') '+isnull(item,'')+' ,max(a.'+isnull(item,'')+') ['+ isnull(replace(replace(item,'[',''),']',''),'')+'_new]' FROM #compare_columns
	--SELECT @having_columns =ISNULL(@having_columns+' or ','')+'round(isnull(max(a.'+isnull(item,'')+'),0),2)<>round(isnull(max(b.'+isnull(item,'')+'),0),2)' FROM #compare_columns
	SELECT @having_columns =ISNULL(@having_columns+' or ','')+'isnull(max(a.'+isnull(item,'')+'),0)<>isnull(max(b.'+isnull(item,'')+'),0)' FROM #compare_columns
	SELECT @st_join_columns= ISNULL(@st_join_columns + ' and ','')+'a.'+isnull(item,'')+'=isnull(b.'+isnull(item,'')+',a.'+isnull(item,'')+')' FROM #join_columns

	IF @action='i'
	BEGIN

		---handling identity column
		select @list_src_column_name=null,@list_dst_column_name=null
		if  object_id(@tbl2) IS NULL
		begin
			
			select @list_dst_column_name=isnull(@list_dst_column_name+',','') + sys.columns.name 
				,@list_src_column_name=isnull(@list_src_column_name+',','') + 'a.'+sys.columns.name
			from sys.columns where object_name(sys.columns.object_id)= @tbl_name and is_identity<>1

		end
		else  ---  report data output case (always without identity column)
		begin
			select @list_dst_column_name='',@list_src_column_name= 'a.*'
		
		end		

		if OBJECT_ID(@db_name+@tbl_name_with_rowid) IS NULL
		begin

			SET @st='SELECT '+@list_src_column_name  + case when OBJECT_ID(@db_name+@tbl_name_with_rowid) IS NULL then ' INTO '+@db_name+@tbl_name_with_rowid+' ' else '' end 
					+ '	FROM '+CASE WHEN object_id(@tbl2) IS NULL THEN @tbl_name ELSE  @tbl2 END +' a '
		end			
		else
		begin
			SET @st='DELETE b ' + '	FROM '+CASE WHEN object_id(@tbl2) IS NULL THEN @tbl_name ELSE @tbl2 END +' a '
				+CASE WHEN @deal_filter_clm IS NOT null THEN 
				' inner join #deal_filter_pre_post f ON f.source_deal_header_id=a.'+@deal_filter_clm  ELSE '' END 
				 + ' inner join '+@db_name+@tbl_name_with_rowid+' b on ' + @st_join_columns
				+CASE WHEN @as_of_date_filter_clm IS null THEN  '' ELSE ' where a.'+@as_of_date_filter_clm+'='''+@as_of_date+''' and a.'+@as_of_date_filter_clm+'='''+@as_of_date+'''' END 
				+';
				 Insert into '+@db_name+@tbl_name_with_rowid+ case when @list_dst_column_name='' then '' else '('+ @list_dst_column_name+') ' end +'
				SELECT  ' +@list_src_column_name +
				 '	FROM '++CASE WHEN object_id(@tbl2) IS NULL THEN @tbl_name ELSE  @tbl2 END +' a '
		end		
		set @st=@st+
				CASE WHEN @deal_filter_clm IS NOT null THEN 
					' inner join #deal_filter_pre_post f ON f.source_deal_header_id=a.'+@deal_filter_clm  ELSE '' END 
				+CASE WHEN @as_of_date_filter_clm IS null THEN  '' ELSE ' where '+@as_of_date_filter_clm+'='''+@as_of_date+'''' END 
				
		EXEC spa_print @st
		--return
		exec(@st)
		
		IF @@ROWCOUNT>0
		BEGIN
			set @st='
				insert into #pre_post_calc_status
				(
					process_id ,ErrorCode,Module,Source,type,[description]
				)
				select '''+@process_id+''' process_id,''Success'' ErrorCode,''Pre/Post Test'' Module,'''+@tbl_name_with_rowid+''' Source,''Success'' type
				,cast(count(1) as varchar)+'' record''+case when count(1)>1 then ''s'' else '''' end+'' imported into benchmark.'' [description]
				FROM '+case when object_id(@tbl2) IS NULL then @db_name+@tbl_name_with_rowid else @tbl2 end +' s '
				+CASE WHEN @deal_filter_clm IS NOT null THEN 
					' inner join #deal_filter_pre_post f ON f.source_deal_header_id=s.'+@deal_filter_clm  ELSE '' END 
				+CASE WHEN @as_of_date_filter_clm IS null THEN  '' ELSE ' where '+@as_of_date_filter_clm+'='''+@as_of_date+'''' END 
			
			EXEC spa_print @st
			exec(@st)		
		END		
		ELSE
		BEGIN
			set @st='
				insert into #pre_post_calc_status
				(
					process_id ,ErrorCode,Module,Source,type,[description]
				)
				select '''+@process_id+''' process_id,''Error'' ErrorCode,''Pre/Post Test'' Module,'''+@tbl_name_with_rowid+''' Source,''Data Error'' type
				,''Data not found to import into benchmark.'' [description]
				'
		
			EXEC spa_print @st
			exec(@st)		
		END						
	END
	else
	begin	
		

		if object_id( @db_name+@tbl_name_with_rowid) is  null
		begin

			insert into #pre_post_calc_status
			(
				process_id ,ErrorCode,Module,Source,type,[description]
			)
			select @process_id process_id,'Error' ErrorCode,'Pre/Post Test' Module, @tbl_name_with_rowid Source,'Error' [type]
			,'Benchmark table:'+ @db_name+@tbl_name_with_rowid +' not found.' [description]
			
			--CLOSE config
			--DEALLOCATE config

			GOTO messaging_lebel
			
		end				
		
		set @st='	
			SELECT '''+@tbl_name_with_rowid+''' TBL'+isnull(@select_columns,'')+isnull(@st_display_columns,'')+isnull(@st_compare_columns,'')+ '
				into '+@tbl1+'
			FROM '+CASE WHEN OBJECT_ID(@tbl2) IS NULL THEN @tbl_name ELSE @tbl2 end+' a
				full join
			'+@db_name+@tbl_name_with_rowid+' b on '
			+isnull(@st_join_columns,'')
			+CASE WHEN @deal_filter_clm IS NOT null THEN 
				' inner join #deal_filter_pre_post f ON f.source_deal_header_id=isnull(a.'+@deal_filter_clm+',b.'+@deal_filter_clm+')'  ELSE '' END 
			+CASE WHEN @as_of_date_filter_clm IS null THEN '' 
				ELSE ' where a.'+@as_of_date_filter_clm+'='''+@as_of_date+''' and b.'+@as_of_date_filter_clm+'='''+@as_of_date+'''' END +'
			group BY ' + isnull(@group_by_columns,'') +'
			HAVING '+isnull(@having_columns,'')+'	     
			order by ' +isnull(@order_by_column_no,'1')
		
		EXEC spa_print @st
		exec(@st)

		drop table #join_columns
		drop table #compare_columns
		drop table #display_columns
	end
	---------------End Main Import/Compare logic---------------------------------------------------
	----------------------------------------------------------------------------------



	----------------------------------------------------------------------------------
	---------------Start Messaging---------------------------------------------------


	if object_id(@tbl1) is not null
	begin
		set @st='
			insert into #pre_post_calc_status
			(
				process_id ,ErrorCode,Module,Source,type,[description]
			)
			select '''+@process_id+''' process_id,''Error'' ErrorCode,''Pre/Post Test'' Module,tbl Source,''Mismatch'' type
			,cast(count(1) as varchar)+'' record''+case when count(1)>1 then ''s'' else '''' end+'' found mismatch.'' [description]
			from '+@tbl1 +' group by tbl having count(1)>0 '
		
		EXEC spa_print @st
		exec(@st)
		
		IF @@ROWCOUNT<1
		BEGIN
			if object_id(@db_name+@tbl_name_with_rowid) is not null
			begin
				set @st='
				insert into #pre_post_calc_status
				(
					process_id ,ErrorCode,Module,Source,type,[description]
				)
				select '''+@process_id+''' process_id,''Success'' ErrorCode,''Pre/Post Test'' Module,'''+@tbl_name+''' Source,''Success'' type
				,cast(count(1) as varchar)+'' record''+case when count(1)>1 then ''s'' else '''' end+'' found match.'' [description]
				from '+@db_name+@tbl_name_with_rowid +' s '
				+CASE WHEN @deal_filter_clm IS NOT null THEN 
					' inner join #deal_filter_pre_post f ON f.source_deal_header_id=s.'+@deal_filter_clm  ELSE '' END 
				+CASE WHEN @as_of_date_filter_clm IS null THEN '' 
					ELSE ' where s.'+@as_of_date_filter_clm+'='''+@as_of_date+'''' END 
			
				EXEC spa_print @st
				exec(@st)	
			end	
		END
	END
	
messaging_lebel:

	insert into source_system_data_import_status(process_id,code,module,source,type,[description],recommendation)  
	select process_id,ErrorCode,module,source,type,[description],'' nextsteps from    #pre_post_calc_status

	---------------End Messaging----------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------
	
	FETCH NEXT FROM config INTO @module_id,@tbl_name,@description,@join_columns,@compare_columns,@exec_sp,@re_calc_sp
		,@as_of_date_filter_clm,@deal_filter_clm,@display_columns,@order_by_column_no,@rowid
END
CLOSE config
DEALLOCATE config

SELECT @module_desc=sdv.[description]
  FROM static_data_value sdv WHERE sdv.value_id=@module_id

set @error_code='s'	

SET @url = './dev/spa_html.php?__user_name__=' + @user_id + 
		'&spa=exec spa_get_import_process_status ''' +  @process_id  + ''','''+@user_id+''',null,''Regression Testing'''
	
SET @desc = '<a target="_blank" href="' + @url + '">' + @module_desc + 
			' complete for run date ' + isnull(dbo.FNADateFormat(@as_of_date), @as_of_date) + '[Mismatch Found].</a>'	
		
if exists(select 1 from source_system_data_import_status where process_id=@process_id AND code='Error')
BEGIN
	SET @desc = '<a target="_blank" href="' + @url + '">' + @module_desc + 
			' complete for run date ' + isnull(dbo.FNADateFormat(@as_of_date), @as_of_date) + CASE WHEN @action='i' THEN '[Data not found]' ELSE '[Mismatch Found]' END +'.</a>'	
	set @error_code='e'			
end
else 			
	SET @desc = '<a target="_blank" href="' + @url + '">' + @module_desc + 
			' complete for run date ' + isnull(dbo.FNADateFormat(@as_of_date), @as_of_date) + '.</a>'	
EXEC spa_print @desc

EXEC  spa_message_board 'u', @user_id, NULL, @module_desc,  @desc, '', '', @error_code, @process_id,NULL,@process_id,NULL,'n',null,'y', NULL, null 

insert import_data_files_audit(dir_path,
	imp_file_name,
	as_of_date,
	[status],
	elapsed_time,
	process_id,
	create_user,
	source_system_id)
VALUES
(	'Regression Testing',
	'Regression Testing run for '+@as_of_date+'',
	cast(floor(cast(getdate() as float)) as datetime),
	@error_code,
	datediff(ss,@run_start_time,getdate()),
	@process_id,
	@user_id,
	2)
