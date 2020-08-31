
IF OBJECT_ID(N'spa_GetAllUnapprovedItemGen', N'P') IS NOT NULL
DROP PROCEDURE spa_GetAllUnapprovedItemGen
GO 

CREATE PROCEDURE [dbo].[spa_GetAllUnapprovedItemGen] 
	@book_id VARCHAR(MAX), 
	@as_of_date_from VARCHAR(50),
	@as_of_date_to	VARCHAR(50),
	@create_ts VARCHAR(1)='n',
	@show_approved VARCHAR(1) = 'n',
	@status_flag CHAR(1) = NULL,
	@batch_process_id VARCHAR(50)=NULL,
	@batch_report_param VARCHAR(500)=NULL   ,
	@enable_paging INT = NULL,   --'1'=enable, '0'=disable
	@page_size INT = NULL,
	@page_no INT = NULL

AS

SET NOCOUNT ON

DECLARE @sql_statement VARCHAR(5000)
DECLARE @sql_statement1 VARCHAR(5000)
DECLARE @Sql_Select VARCHAR(8000)

--////////////////////////////Paging_Batch///////////////////////////////////////////
--PRINT	'@batch_process_id:'+@batch_process_id 
--PRINT	'@batch_report_param:'+	@batch_report_param

DECLARE @str_batch_table VARCHAR(MAX),@str_get_row_number VARCHAR(100)
DECLARE @temptablename VARCHAR(100),@user_login_id VARCHAR(50),@flag CHAR(1)
DECLARE @is_batch BIT
SET @str_batch_table=''
SET @str_get_row_number=''

DECLARE @sql_stmt VARCHAR(8000)
DECLARE @as_of_date_from_tm VARCHAR(50),@as_of_date_to_tm VARCHAR(50)


	SET @as_of_date_from_tm= CONVERT(VARCHAR(50),[dbo].FNAConvertTimezone( @as_of_date_from,1) ,120)
	SET @as_of_date_to_tm = CONVERT(VARCHAR(50),[dbo].FNAConvertTimezone( @as_of_date_to ,1),120)

IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
	SET @is_batch = 1
ELSE
	SET @is_batch = 0
	
	
IF (@is_batch = 1 OR @enable_paging = 1)
BEGIN
	IF (@batch_process_id IS NULL)
		SET @batch_process_id = REPLACE(NEWID(), '-', '_')
	
	SET @user_login_id = dbo.FNADBUser()	
	SET @temptablename = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
	--PRINT('@temptablename:' + @temptablename)
	SET @str_batch_table=' INTO ' + @temptablename
	SET @str_get_row_number=', ROWID=IDENTITY(int,1,1)'
	IF @enable_paging = 1
	BEGIN
		
		IF @page_size IS NOT NULL
		BEGIN
			DECLARE @row_to INT,@row_from INT
			SET @row_to=@page_no * @page_size
			IF @page_no > 1 
				SET @row_from =((@page_no-1) * @page_size)+1
			ELSE
				SET @row_from =@page_no
			SET @sql_stmt=''
			--	select @temptablename
			--select * from adiha_process.sys.columns where [object_id]=object_id(@temptablename) and [name]<>'ROWID' ORDER BY column_id

			SELECT @sql_stmt=@sql_stmt+',['+[name]+']' FROM adiha_process.sys.columns WHERE [OBJECT_ID]=OBJECT_ID(@temptablename) AND [name]<>'ROWID' ORDER BY column_id
			SET @sql_stmt=SUBSTRING(@sql_stmt,2,LEN(@sql_stmt))
			
			SET @sql_stmt='select '+@sql_stmt +'
				  from '+ @temptablename   +' 
				  where rowid between '+ CAST(@row_from AS VARCHAR) +' and '+ CAST(@row_to AS VARCHAR) 
				 
			--PRINT(@sql_stmt)		
			EXEC(@sql_stmt)
			RETURN
		END --else @page_size IS not NULL
	END --enable_paging = 1
END

--////////////////////////////End_Batch///////////////////////////////////////////

IF @status_flag = 'e' 
BEGIN
	
	SET @sql_statement = '
	SELECT  ghg.gen_hedge_group_id AS [Deals Group] FROM 	gen_hedge_group ghg 
	INNER JOIN gen_fas_link_header glh ON ghg.gen_hedge_group_id = glh.gen_hedge_group_id 
	LEFT OUTER JOIN
		(SELECT gen_hedge_group_id, error_code FROM  gen_transaction_status  
		WHERE error_code IN (''Error'', ''Warning'')) gts ON gts.gen_hedge_group_id = ghg.gen_hedge_group_id 
	WHERE ghg.reprice_items_id IS NULL AND glh.gen_approved = ''' + @show_approved + ''' and glh.gen_status <> ''p''' 
	+ CASE WHEN ISNULL(@book_id,'') = '' THEN '' ELSE ' AND glh.fas_book_id IN (' + @book_id + ')' END 
	+CASE WHEN @create_ts='y' THEN ' and ghg.create_ts  between ''' + @as_of_date_from_tm + ''' and ''' + @as_of_date_to_tm + '''' ELSE ' AND ghg.hedge_effective_date  between ''' + @as_of_date_from + ''' and ''' + @as_of_date_to + '''' END 
	+ CASE WHEN @show_approved = 'y' THEN ' AND glh.gen_status <> ''r''' ELSE '' END 

	SET @sql_statement1 = ' UNION SELECT ghg.gen_hedge_group_id as GenGroupID
	from gen_hedge_group ghg INNER JOIN 
	(SELECT	gen_transaction_status.gen_hedge_group_id, count(gen_transaction_status.error_code) as error_counts
	FROM    gen_transaction_status INNER JOIN
        	(SELECT  gen_transaction_status.gen_hedge_group_id, MAX(create_ts) create_ts
        	FROM     gen_transaction_status
        	WHERE    error_code = ''Error''
		GROUP BY gen_transaction_status.gen_hedge_group_id) 
	recent_row 
		ON recent_row.create_ts = gen_transaction_status.create_ts AND
		  recent_row.gen_hedge_group_id =  gen_transaction_status.gen_hedge_group_id
	GROUP BY gen_transaction_status.gen_hedge_group_id) got_errors  
	ON 
		ghg.gen_hedge_group_id = got_errors.gen_hedge_group_id INNER JOIN
	 gen_hedge_group_detail ghgd ON ghgd.gen_hedge_group_id = ghg.gen_hedge_group_id INNER JOIN 
	 source_deal_header ON ghgd.source_deal_header_id = source_deal_header.source_deal_header_id INNER JOIN
	 source_system_book_map ON source_deal_header.source_system_book_id1 = source_system_book_map.source_system_book_id1 AND 
	 source_deal_header.source_system_book_id2 = source_system_book_map.source_system_book_id2 AND 
	 source_deal_header.source_system_book_id3 = source_system_book_map.source_system_book_id3 AND 
	 source_deal_header.source_system_book_id4 = source_system_book_map.source_system_book_id4

	WHERE ghg.reprice_items_id IS NULL AND ghg.hedge_effective_date between ''' + @as_of_date_from + ''' and ''' + @as_of_date_to + '''' +  
		' AND source_system_book_map.fas_book_id in (' + @book_id + ')' 
		+ ' AND ghg.gen_hedge_group_id NOT IN (' + 
		'select ghg.gen_hedge_group_id
		from gen_hedge_group ghg inner join
		gen_fas_link_header glh ON ghg.gen_hedge_group_id = glh.gen_hedge_group_id 
		WHERE glh.gen_approved = ''' + @show_approved + ''' and glh.gen_status <> ''p''' +
		CASE WHEN @show_approved = 'y' THEN  ' AND glh.gen_status <> ''r''' ELSE '' END +
		' AND glh.fas_book_id in (' + @book_id + ')' +
		' AND ghg.hedge_effective_date between ''' + @as_of_date_from + ''' and ''' + @as_of_date_to + '''' + ')'
		+ ' order by ghg.gen_hedge_group_id  '

--PRINT @sql_statement 
--PRINT @sql_statement1
	EXEC(@sql_statement + @sql_statement1)
END
ELSE
BEGIN 

	CREATE TABLE #DATA(
		portfolio VARCHAR(150) COLLATE DATABASE_DEFAULT NULL, 
		gen_hedge_group_id VARCHAR(150) COLLATE DATABASE_DEFAULT NULL,  
		[status] VARCHAR(150) COLLATE DATABASE_DEFAULT NULL, 
		gen_hedge_group_name VARCHAR(200) COLLATE DATABASE_DEFAULT NULL,
		relationship_type VARCHAR(100) COLLATE DATABASE_DEFAULT NULL, 
		effective_date VARCHAR(100) COLLATE DATABASE_DEFAULT NULL, 
		hedging_relationship_type VARCHAR(150) COLLATE DATABASE_DEFAULT NULL, 
		perfect_hedge VARCHAR(200) COLLATE DATABASE_DEFAULT NULL, 
		[created_user] VARCHAR(100) COLLATE DATABASE_DEFAULT NULL, 
		[created_ts] VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
		[updated_user] VARCHAR(150) COLLATE DATABASE_DEFAULT NULL, 
		[updated_ts] VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
		[transaction_type] VARCHAR(100) COLLATE DATABASE_DEFAULT NULL
	)

--dbo.FNAHyperLinkText(600,
	SET @sql_statement = '
		insert into #DATA

		select isnull(p_sub.entity_name,'''')+ case when p_str.entity_name is null then '''' else  ''|''+p_str.entity_name end 
				+ case when p_book.entity_name is null or p_book.entity_id=-1 then '''' else  ''|''+p_book.entity_name end [Subsidiary/Strategy/Book]
				, ghg.gen_hedge_group_id as GenGroupID, 
			case when (ghg.eff_test_profile_id = -1) 
				then ''Error(Select Appropriate Relationship Type)''
				--dbo.FNAHyperLinkText(10234515,''Error(Select Appropriate Relationship Type)'',ghg.gen_hedge_group_id) 
				else 
				--dbo.FNAHyperLinkText(10234515,isnull(gts.error_code, ''Success''),ghg.gen_hedge_group_id) 
				isnull(gts.error_code, ''Success'')
			end + ''^javascript:open_gen_hedge_status('' + CAST(ghg.gen_hedge_group_id AS VARCHAR(50)) + '','' + CAST(glh.fas_book_id AS VARCHAR(50))+'')^'' As Status
		--	isnull(gts.error_code, ''Success'') As Status
		, ghg.gen_hedge_group_name as GenGroupName,
		ghg.link_type_value_id as RelType, 
		dbo.FNADateFormat(ghg.hedge_effective_date) as EffDate, 
		ghg.eff_test_profile_id as RelTypeID, ghg.perfect_hedge as PerfectHedge, 
		ghg.create_user as CreatedUser, dbo.FNADateTimeFormat(ghg.create_ts,1) as CreatedTS,
		ghg.update_user as UpdatedUser, dbo.FNADateTimeFormat(ghg.update_ts,1) as UpdatedTS ,ghg.tran_type
	from 	gen_hedge_group ghg inner join  
		gen_fas_link_header glh ON ghg.gen_hedge_group_id = glh.gen_hedge_group_id left outer join
		(select gen_hedge_group_id, error_code from  gen_transaction_status  
			where error_code IN (''Error'', ''Warning'')) gts on gts.gen_hedge_group_id = ghg.gen_hedge_group_id 
		left  join portfolio_hierarchy p_book on glh.fas_book_id=p_book.entity_id
				left join portfolio_hierarchy p_str on  p_book.parent_entity_id=p_str.entity_id 
		left join portfolio_hierarchy p_sub on  p_str.parent_entity_id=p_sub.entity_id 
	WHERE ghg.reprice_items_id IS NULL AND glh.gen_approved = ''' + @show_approved + ''' AND glh.gen_status <> ''p''' +
	CASE WHEN ISNULL(@book_id,'')='' THEN '' ELSE ' AND glh.fas_book_id in (' + @book_id + ')' END +
	CASE WHEN @create_ts='y' THEN  ' and ghg.create_ts  between ''' + @as_of_date_from_tm + ''' and ''' + @as_of_date_to_tm + '''' ELSE ' AND ghg.hedge_effective_date  between ''' + @as_of_date_from + ''' and ''' + @as_of_date_to + '''' END+
	CASE WHEN @show_approved = 'y' THEN  ' AND glh.gen_status <> ''r''' ELSE '' END 
	--case when @create_ts='y' then ' and cast(convert(varchar(10),ghg.create_ts,120) as datetime) ' else ' AND cast(convert(varchar(10),ghg.hedge_effective_date,120) as datetime) ' end+ ' between ''' + @as_of_date_from + ''' and ''' + @as_of_date_to + ''''
	 
	--PRINT @sql_statement
	SET @sql_statement1 = '  UNION
	select 	'''' [Subsidiary/Strategy/Book], ghg.gen_hedge_group_id as GenGroupID, 
		''Error'' As Status, 
		ghg.gen_hedge_group_name as GenGroupName,
		ghg.link_type_value_id as [Relation Type ID], 
		dbo.FNADateFormat(ghg.hedge_effective_date) as EffDate, 
		ghg.eff_test_profile_id as RelTypeID, 
		ghg.perfect_hedge as PerfectHedge, 
		ghg.create_user as CreatedUser, 
		dbo.FNADateTimeFormat(ghg.create_ts,1) as CreatedTS,
		ghg.update_user as UpdatedUser, 
		dbo.FNADateTimeFormat(ghg.update_ts,1) as UpdatedTS,ghg.tran_type
	from gen_hedge_group ghg INNER JOIN 
		(SELECT	gen_transaction_status.gen_hedge_group_id, count(gen_transaction_status.error_code) as error_counts
		FROM    gen_transaction_status INNER JOIN
        		(SELECT  gen_transaction_status.gen_hedge_group_id, MAX(create_ts) create_ts
        		FROM     gen_transaction_status
        		WHERE    error_code = ''Error''
			GROUP BY gen_transaction_status.gen_hedge_group_id) 
		recent_row 
			ON recent_row.create_ts = gen_transaction_status.create_ts AND
			  recent_row.gen_hedge_group_id =  gen_transaction_status.gen_hedge_group_id
		GROUP BY gen_transaction_status.gen_hedge_group_id) got_errors  
		ON ghg.gen_hedge_group_id = got_errors.gen_hedge_group_id INNER JOIN
		 gen_hedge_group_detail ghgd ON ghgd.gen_hedge_group_id = ghg.gen_hedge_group_id INNER JOIN 
		 source_deal_header ON ghgd.source_deal_header_id = source_deal_header.source_deal_header_id INNER JOIN
		 source_system_book_map ON source_deal_header.source_system_book_id1 = source_system_book_map.source_system_book_id1 AND 
		 source_deal_header.source_system_book_id2 = source_system_book_map.source_system_book_id2 AND 
		 source_deal_header.source_system_book_id3 = source_system_book_map.source_system_book_id3 AND 
		 source_deal_header.source_system_book_id4 = source_system_book_map.source_system_book_id4

		WHERE ghg.reprice_items_id IS NULL AND ghg.hedge_effective_date between ''' + @as_of_date_from + ''' and ''' + @as_of_date_to + '''' +  
			' AND source_system_book_map.fas_book_id in (' + @book_id + ')' 
			+ ' AND ghg.gen_hedge_group_id NOT IN (' + 
			'select ghg.gen_hedge_group_id
			from gen_hedge_group ghg inner join
			gen_fas_link_header glh ON ghg.gen_hedge_group_id = glh.gen_hedge_group_id 
			WHERE glh.gen_approved = ''' + @show_approved + ''' and glh.gen_status <> ''p''' +
			CASE WHEN @show_approved = 'y' THEN  ' AND glh.gen_status <> ''r''' ELSE '' END +
			' AND glh.fas_book_id in (' + @book_id + ')' +
			' AND ghg.hedge_effective_date between ''' + @as_of_date_from + ''' and ''' + @as_of_date_to + '''' + ')'
			+ ' order by ghg.gen_hedge_group_id  '

--PRINT 'kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk'
--PRINT @sql_statement1
EXEC(@sql_statement + @sql_statement1)

--SET @Sql_Select='SELECT * ' + @str_get_row_number + @str_batch_table +' FROM #DATA'
SET @Sql_Select='SELECT rs.gen_hedge_group_id
					, rs.gen_hedge_group_name
					, rs.effective_date
					, rel.eff_test_name
					, CASE WHEN perfect_hedge = ''y'' THEN ''Yes'' ELSE ''No'' END perfect_hedge
					, sdv.code
					, status
					, portfolio
				FROM #DATA rs
				INNER JOIN fas_eff_hedge_rel_type rel ON rel.eff_test_profile_id = rs.hedging_relationship_type
				INNER JOIN static_data_value sdv on sdv.value_id = rs.relationship_type and sdv.type_id = 450
				'
				

END
 
EXEC(@Sql_Select)


IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'Transaction Processing', 
				'spa_GetAllUnapprovedItemGen', 'DB Error', 
				'Failed to select outstanding transaction gen groups.', ''

IF @is_batch = 1
BEGIN
	--RINT ('@str_batch_table')  
	 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)   
		  
	 EXEC(@str_batch_table)                   
	        
	 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_GetAllUnapprovedItemGen','Get All Inapproved Item Gen')         
	 
	 EXEC(@str_batch_table)        
	
	RETURN
END

IF @enable_paging = 1
BEGIN
		IF @page_size IS NULL
		BEGIN
			SET @sql_stmt='select count(*) TotalRow,'''+@batch_process_id +''' process_id  from '+ @temptablename
			
			EXEC(@sql_stmt)
		END
		RETURN
END 

