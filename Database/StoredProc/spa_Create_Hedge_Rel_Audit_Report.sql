


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].spa_Create_Hedge_Rel_Audit_Report') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Create_Hedge_Rel_Audit_Report]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON

GO
/* 
spa_Create_Hedge_Rel_Audit_Report @report_type = 'c' 
*/

CREATE PROC [dbo].[spa_Create_Hedge_Rel_Audit_Report](	
	@hedge_rel_id_from INT = NULL
	,@hedge_rel_id_to INT = NULL	
	,@effective_date_from VARCHAR(20) = NULL
	,@effective_date_to VARCHAR(20) = NULL
	,@report_type CHAR(1) = 's'
	,@relationship_type CHAR(1) = 'b'	-- b => both, d=>Designation, e=>De-designation
	,@active CHAR(1) = NULL
	,@prior_update_date VARCHAR(20) = NULL
	,@update_date_from VARCHAR(20) = NULL
	,@update_date_to VARCHAR(20) = NULL
	,@update_by VARCHAR(20) = NULL
	,@user_action VARCHAR(20) = NULL
	,@sort_order CHAR(1) = NULL
	,@fas_book_id VARCHAR(MAX) = NULL	
	,@link_ids VARCHAR(MAX) = NULL	
	,@batch_process_id varchar(250)=NULL
	,@batch_report_param varchar(500)=NULL 
	,@enable_paging INT = 0  --'1'=enable, '0'=disable
	,@page_size int = NULL
	,@page_no INT = NULL
)

AS



/*
----
	--uncommet to debug
	declare @hedge_rel_id_from INT 
	,@hedge_rel_id_to INT 	
	,@effective_date_from VARCHAR(20)
	,@effective_date_to VARCHAR(20)
	,@report_type CHAR(1)
	,@relationship_type CHAR(1) 	
	,@active CHAR(1) 
	,@prior_update_date VARCHAR(20) 
	,@update_date_from VARCHAR(20) 
	,@update_date_to VARCHAR(20) 
	,@update_by VARCHAR(20) 
	,@user_action VARCHAR(20) 
	,@sort_order CHAR(1) 
	,@fas_book_id INT 	
	,@link_ids VARCHAR(5000)
	,@batch_process_id varchar(250)
	,@batch_report_param varchar(500) 
	,@enable_paging INT 
	,@page_size int 
	,@page_no INT 
	
	--SET @str_batch_table = ''
	
--SET @hedge_rel_id_from =401
--SET @hedge_rel_id_to =401

--SET @effective_date_from  = '2010-08-18'
--SET @effective_date_to  = '2010-08-24'

set @report_type = 'c'
--SET @relationship_type = 'b'
SET @active = 'y'

SET @prior_update_date =  '2010-08-28'

SET @update_date_from = '2010-08-23'
SET @update_date_to = '2010-08-30'
--SET @update_by = 'farrms_admin'
--SET @user_action = 'update'
--SET @sort_order = 'f'
--SET @fas_book_id = 72
SET @link_ids = '418,419,420'


begin try	
	DROP TABLE #book
end try
begin catch
end catch

begin try
	DROP TABLE #fas_link_header_audit
end try
begin catch
end catch

begin try
	DROP TABLE #fas_link 
end try
begin catch
end catch

begin try
DROP TABLE #map
end try
begin catch
end CATCH

begin try
DROP TABLE #fas_link_tmp
end try
BEGIN CATCH
END CATCH
begin try
DROP TABLE #grid
end try
BEGIN CATCH
END catch
*/






SET NOCOUNT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table VARCHAR(MAX)
DECLARE @sql_paging VARCHAR(MAX)
DECLARE @is_batch BIT
DECLARE @user_login_id1 varchar(50)=NULL 

SET @str_batch_table = ''
SET @user_login_id1 = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
IF @is_batch = 1
   SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id1, @batch_process_id)
 
IF @enable_paging = 1 --paging processing
BEGIN
   IF @batch_process_id IS NULL
      SET @batch_process_id = dbo.FNAGetNewID()
 
   SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)
 
   --retrieve data from paging table instead of main table
   IF @page_no IS NOT NULL 
   BEGIN
      SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
      EXEC (@sql_paging) 
      RETURN 
   END
END
--////////////////////////////End_Batch///////////////////////////////////////////  

--*/
--set @report_type = 'd'

SELECT	 
	 book.entity_id fas_book_id,	 
	 book.entity_name book
	 ,stra.entity_name Strategy
	 ,sub.entity_name Sub
INTO #book	 
FROM portfolio_hierarchy book (nolock) 
	INNER JOIN portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id
	INNER JOIN portfolio_hierarchy sub ON stra.parent_entity_id = sub.entity_id
WHERE book.entity_id IN (SELECT fas_book_id FROM fas_link_header_audit)



DECLARE @sql VARCHAR(MAX)

IF @prior_update_date IS NULL 
	SET @prior_update_date = GETDATE()

CREATE TABLE  #fas_link_header_audit(
	link_id	INT 
	,fas_book_id	INT 
	,perfect_hedge	CHAR(1) COLLATE DATABASE_DEFAULT  
	,fully_dedesignated	CHAR(1) COLLATE DATABASE_DEFAULT 
	,link_description	VARCHAR(1000) COLLATE DATABASE_DEFAULT 
	,eff_test_profile_id	INT 
	,link_effective_date	DATETIME 
	,link_type_value_id	INT 
	,link_active	CHAR(1) COLLATE DATABASE_DEFAULT 
	,create_user	VARCHAR(50) COLLATE DATABASE_DEFAULT 
	,create_ts	DATETIME 
	,update_user	VARCHAR(50) COLLATE DATABASE_DEFAULT 
	,update_ts	DATETIME 
	,original_link_id INT 
	,link_end_date	DATETIME
	,dedesignated_percentage	FLOAT
	,user_action	VARCHAR(50) COLLATE DATABASE_DEFAULT 
	,audit_id	INT
	,is_deleted CHAR(1) COLLATE DATABASE_DEFAULT  
)


SET @sql ='INSERT INTO #fas_link_header_audit	
	SELECT DISTINCT
		flha.link_id
		,flha.fas_book_id
		,flha.perfect_hedge
		,flha.fully_dedesignated
		,flha.link_description
		,flha.eff_test_profile_id
		,flha.link_effective_date
		,flha.link_type_value_id
		,flha.link_active
		,flha.create_user
		,flha.create_ts
		,flha.update_user
		,flha.update_ts
		,flha.original_link_id
		,flha.link_end_date
		,flha.dedesignated_percentage
		,flha.user_action
		,flha.audit_id
		,CASE WHEN flh.link_id IS NULL THEN ''y'' ELSE ''n'' END is_deleted
	FROM fas_link_header_audit flha	
	LEFT JOIN fas_link_header flh ON flha.link_id = flh.link_id
	INNER JOIN fas_link_header_detail_audit_map flhdam on flhdam.header_audit_id = flha.audit_id
		WHERE 1 = 1 
	    '	    
	    + CASE WHEN @hedge_rel_id_from IS NOT NULL THEN ' AND flha.link_id >=' + CAST(@hedge_rel_id_from AS VARCHAR) ELSE '' END
		+ CASE WHEN @hedge_rel_id_to IS NOT NULL THEN	' AND flha.link_id <=' + CAST(@hedge_rel_id_to AS VARCHAR) ELSE ''END
		+ CASE 
			WHEN @hedge_rel_id_from IS NOT NULL OR  @hedge_rel_id_to IS NOT NULL THEN ''
			ELSE (	            
				  CASE 
					WHEN @update_date_from IS NOT NULL THEN 		
					' AND flhdam.update_ts >=''' + dbo.FNAConvertTZAwareDateFormat(@update_date_from, 1) + ''''
					ELSE ''
				  END
				+ CASE WHEN @update_date_to IS NOT NULL THEN		
					' AND  flhdam.update_ts <=''' + dbo.FNAConvertTZAwareDateFormat(@update_date_to, 1) + ' 23:59:59'''
					ELSE ''
				  END
				+ CASE WHEN @fas_book_id IS NOT NULL THEN ' AND flha.fas_book_id IN ('+ @fas_book_id + ')' ELSE '' END
				--+ CASE WHEN @update_by IS NOT NULL THEN ' AND  flhdam.update_user ='''+ @update_by + '''' ELSE '' END 
				--+ CASE WHEN ISNULL(@user_action, 'all') <> 'all' THEN ' AND flhdam.user_action ='''+ @user_action + '''' ELSE '' END
			  )
		  END
		 
		  
EXEC spa_print @sql
EXEC (@sql)

CREATE TABLE #grid (
	[Rel ID] INT
	,[Book ID] INT
	,[Perfect Hedge] VARCHAR(10) COLLATE DATABASE_DEFAULT 
	,[Fully De designated] VARCHAR(10) COLLATE DATABASE_DEFAULT 
	,[Description] VARCHAR(1000) COLLATE DATABASE_DEFAULT 
	,[Hedging Rel Type ID] VARCHAR(50) COLLATE DATABASE_DEFAULT 
	,[Effective Date] VARCHAR(20) COLLATE DATABASE_DEFAULT 
	,[Rel Type]	VARCHAR(100) COLLATE DATABASE_DEFAULT 
	,[Link Active] VARCHAR(10) COLLATE DATABASE_DEFAULT 
	,[Create User] VARCHAR(50) COLLATE DATABASE_DEFAULT 
	,[Create TS] VARCHAR(20) COLLATE DATABASE_DEFAULT 
	,[Update User] VARCHAR(50) COLLATE DATABASE_DEFAULT 
	,[Update TS] VARCHAR(20) COLLATE DATABASE_DEFAULT 
	
)

SET @sql = '
		INSERT INTO #grid
		SELECT	DISTINCT	
			flha.link_id [Rel ID]		
			,MAX(flha.fas_book_id) [Book ID]
			,MAX(CASE WHEN flha.perfect_hedge = ''y'' THEN ''Yes'' ELSE ''No'' end) [Perfect Hedge]				
			,MAX(CASE WHEN flha.fully_dedesignated = ''y'' THEN ''Yes'' ELSE ''No'' end) [Fully De designated]
			,MAX(flha.link_description) [Description]
			,MAX(flha.eff_test_profile_id) [Hedging Rel Type ID]
			,MAX(dbo.FNADateFormat(flha.link_effective_date)) [Effective Date]
			,MAX(flha.link_type_value_id )[Rel Type]				
			,MAX(CASE WHEN flha.link_active = ''y'' THEN ''Yes'' ELSE ''No'' end) [Link Active]
			,MAX(flha.create_user) [Create User]
			,MIN(dbo.FNADateTimeFormat( flha.create_ts, 1)) [Create TS]
			,MAX(flha.update_user ) [Update User]
			,MAX(dbo.FNADateTimeFormat(flha.update_ts, 1)) [Update TS]			
			FROM #fas_link_header_audit flha
				INNER  JOIN
					(
						SELECT flha1.* FROM fas_link_header_audit flha1 
						INNER JOIN (
							SELECT link_id, MAX(audit_id) audit_id
							FROM fas_link_header_audit
							GROUP BY link_id
						) tmp1 ON flha1.audit_id = tmp1.audit_id
					) flha1 On flha1.link_id = flha.link_id
				INNER JOIN fas_link_header_detail_audit_map flhdam on flhdam.header_audit_id = flha.audit_id 	
			'
			+
			--+ CASE WHEN @hedge_rel_id_from IS NOT NULL THEN ' AND flha.link_id >=' + CAST(@hedge_rel_id_from AS VARCHAR) ELSE '' END
			--+ CASE WHEN @hedge_rel_id_to IS NOT NULL THEN	' AND flha.link_id <=' + CAST(@hedge_rel_id_to AS VARCHAR) ELSE ''END
			+ CASE 
				WHEN @hedge_rel_id_from IS NOT NULL OR  @hedge_rel_id_to IS NOT NULL THEN ''
				ELSE ( 
					 CASE 
						WHEN @effective_date_from IS NOT NULL THEN 		
							' AND flha1.link_effective_date >=''' + dbo.FNAConvertTZAwareDateFormat(@effective_date_from, 1) + ''''
						ELSE ''
					  END
					+ CASE WHEN @effective_date_to IS NOT NULL THEN		
							 ' AND  flha1.link_effective_date <=''' + dbo.FNAConvertTZAwareDateFormat(@effective_date_to, 1) + ' 23:59:59'''
						ELSE ''
					  END 
					+ CASE ISNULL(@relationship_type, 'b') -- b => both, d=>Designation, e=>De-designation
						WHEN 'd' THEN ' AND flha1.original_link_id IS NULL '
						WHEN 'e' THEN ' AND flha1.original_link_id IS NOT NULL '
						ELSE ''
					  END 
					+ CASE WHEN @active IS NOT NULL  THEN ' AND  flha1.link_active =''' + @active + '''' ELSE '' END
					+ CASE WHEN @update_by IS NOT NULL THEN ' AND  flhdam.update_user ='''+ @update_by + '''' ELSE '' END 
					+ CASE WHEN ISNULL(@user_action, 'all') <> 'all' THEN ' AND flhdam.user_action ='''+ @user_action + '''' ELSE '' END
					
				)
			END	
			+					
			' 
		GROUP BY flha.link_id 
		ORDER BY flha.link_id  ' + CASE WHEN ISNULL(@sort_order,'f') = 'f' THEN 'ASC' ELSE 'DESC' END 	  
		
		
EXEC spa_print @sql
EXEC(@sql)


IF @report_type = 'g'
BEGIN
	EXEC spa_print '--GRID--'
	SELECT * FROM #grid
END
ELSE IF @report_type = 's'
BEGIN
	EXEC spa_print '--Summary--'
	SET @sql = '
	SELECT 	
		flha.user_action [User Action]
		,dbo.FNADateTimeFormat(flhdam.update_ts, 1) [Link update timestamp]	
		,flhdam.update_user [Update User]		
		,CASE 
			WHEN flha.is_deleted = ''y'' THEN
				CAST(flha.link_id AS VARCHAR)
			ELSE
				''<span style=cursor:hand onClick=openHyperLink(10233710,'' + CAST(flha.link_id AS VARCHAR)+'')><font color=#0000ff><u>''+ CAST(flha.link_id AS VARCHAR)+''</u></font></span>'' 
		END	[Rel ID]
		,CASE WHEN flha.fully_dedesignated = ''y'' THEN ''Yes'' ELSE ''No'' END [Fully De designated]		
		,flha.original_link_id  [De designation Rel ID]
		,flha.dedesignated_percentage [De designation percentage]
		,sdv.[description] [Description]
		,dbo.FNADateFormat(flha.link_effective_date) [Effective Date]
		,dbo.FNADateFormat(flha.link_end_date) [End Date]
		,CASE WHEN flha.perfect_hedge = ''y'' THEN ''Yes'' ELSE ''No'' end [Perfect Hedge]		
		,dbo.FNAHyperLinkText(10232000,fehrt.eff_test_description, fehrt.eff_test_profile_id) [Hedging Relationship Type]
		,CASE WHEN flha.link_active = ''y'' THEN ''Yes'' ELSE ''No'' END [Active]  
		'
		+ 
		@str_batch_table + 
		'		
	 FROM #fas_link_header_audit flha		
		INNER JOIN static_data_value sdv ON flha.link_type_value_id = sdv.value_id
		INNER JOIN fas_eff_hedge_rel_type fehrt ON fehrt.eff_test_profile_id = flha.eff_test_profile_id
		INNER JOIN #grid g on g.[Rel ID] = flha.link_id
		LEFT JOIN fas_link_header_detail_audit_map flhdam ON flhdam.header_audit_id = flha.audit_id
			AND flhdam.detail_audit_id = 0	
		WHERE 1 = 1
		' 
		+ CASE WHEN @link_ids IS NOT NULL THEN ' AND flha.link_id in (' + @link_ids + ')' ELSE '' END
		+ CASE 
			WHEN @hedge_rel_id_from IS NOT NULL OR  @hedge_rel_id_to IS NOT NULL THEN ''
			ELSE (
				+ CASE WHEN @link_ids IS NOT NULL THEN ' AND flha.link_id in (' + @link_ids + ')' ELSE '' END
				+ CASE WHEN @update_by IS NOT NULL THEN ' AND flhdam.update_user ='''+ @update_by + '''' ELSE '' END
				+ CASE WHEN ISNULL(@user_action, 'all') <> 'all' THEN ' AND flhdam.user_action ='''+ @user_action + '''' ELSE '' END		
			)
		  END
		+
		' ORDER BY flha.link_id ASC, flhdam.update_ts DESC'
		
	
	EXEC spa_print @sql	
	EXEC (@sql)

END

ELSE IF @report_type = 'd'
BEGIN
	EXEC spa_print '--Details--'
	SET @sql = '
	SELECT		
		flhdam.user_action [User Action]
		,dbo.FNADateTimeFormat(flhdam.update_ts, 1) [Link update Timestamp]		
		,flhdam.update_user [Link update User]
		,book.Sub
		,book.Strategy
		,book.Book		
		,CASE 
			WHEN flha.is_deleted = ''y'' THEN
				CAST(flha.link_id AS VARCHAR)
			ELSE
				''<span style=cursor:hand onClick=openHyperLink(10233710,'' + CAST(flha.link_id AS VARCHAR)+'')><font color=#0000ff><u>''+ CAST(flha.link_id AS VARCHAR)+''</u></font></span>'' 
		END	[Rel ID]						
		,CASE WHEN flha.fully_dedesignated = ''y'' THEN ''Yes'' ELSE ''No'' END [Fully De designated]
		,flha.original_link_id  [De designation Rel ID]
		,flha.dedesignated_percentage [De designation percentage]
		,sdv.[description] [Rel Type]
		,dbo.FNADateFormat(CASE WHEN ISNULL(flhdam.changed_by, ''h'') = ''h'' THEN flha.link_effective_date ELSE flda.effective_date END) [Effective Date]						
		,dbo.FNADateFormat(flha.link_end_date) [End Date]
		,CASE WHEN flha.perfect_hedge = ''y'' THEN ''Yes'' ELSE ''No'' END [Perfect Hedge]
		,CASE 
			WHEN flhdam.changed_by = ''d'' THEN
				CASE flda.hedge_or_item 
					WHEN ''h'' THEN ''Hedge'' 
					WHEN ''i'' THEN ''Item''
					ELSE NULL 
				END
			ELSE NULL 
		END Type
		,CASE 
			WHEN flhdam.changed_by <> ''d'' THEN NULL
			ELSE		 
				CASE 
					WHEN sdh.source_deal_header_id  IS NOT NULL THEN 
						CASE 
							WHEN flha.is_deleted = ''y'' THEN cast(flda.source_deal_header_id  as VARCHAR)
							ELSE dbo.FNAHyperLinkText(10131010,cast(flda.source_deal_header_id  as VARCHAR),flda.source_deal_header_id)
						END 
					ELSE NULL
				END 
		END [Deal Id]					
		,CASE WHEN flhdam.changed_by = ''d'' THEN CAST(round(flda.percentage_included, 2) as varchar) ELSE NULL END [Percentage Included]		
		,dbo.FNAHyperLinkText(10232000,fehrt.eff_test_description, fehrt.eff_test_profile_id) [Hedging Relationship Type]
		,flha.link_description [Description]
		,CASE WHEN flha.link_active = ''y'' THEN ''Yes'' ELSE ''No'' END [Active] 
		' + @str_batch_table + '
	FROM #fas_link_header_audit flha
		INNER JOIN #grid g on g.[Rel ID] = flha.link_id
		LEFT JOIN static_data_value sdv ON flha.link_type_value_id = sdv.value_id
		LEFT JOIN #book book ON flha.fas_book_id = book.fas_book_id
		LEFT JOIN fas_eff_hedge_rel_type fehrt ON fehrt.eff_test_profile_id = flha.eff_test_profile_id		
		LEFT JOIN fas_link_header_detail_audit_map flhdam ON flhdam.header_audit_id = flha.audit_id		
		LEFT JOIN fas_link_detail_audit flda ON flda.audit_id = flhdam.detail_audit_id
		LEFT JOIN source_deal_header sdh ON flda.source_deal_header_id = sdh.source_deal_header_id
		WHERE 1 = 1 AND ISNULL(flda.auto_update, ''N'') = ''N''
		'
		+ CASE WHEN @link_ids IS NOT NULL THEN ' AND flha.link_id in (' + @link_ids + ')' ELSE '' END
		+ CASE 
			WHEN @hedge_rel_id_from IS NOT NULL OR  @hedge_rel_id_to IS NOT NULL THEN ''
			ELSE (		
				+ CASE WHEN @update_date_from IS NOT NULL THEN ' AND flhdam.update_ts >=''' + dbo.FNAConvertTZAwareDateFormat(@update_date_from, 1) + '''' ELSE '' END
				+ CASE WHEN @update_date_to IS NOT NULL THEN ' AND flhdam.update_ts <=''' + dbo.FNAConvertTZAwareDateFormat(@update_date_to, 1) + ' 23:59:59''' ELSE '' END
				+ CASE WHEN @update_by IS NOT NULL THEN ' AND flhdam.update_user ='''+ @update_by + '''' ELSE '' END
				--+ CASE WHEN @update_by IS NOT NULL THEN ' AND flha.update_user ='''+ @update_by + '''' ELSE '' END  
				+ CASE WHEN ISNULL(@user_action, 'all') <> 'all' THEN ' AND flhdam.user_action ='''+ @user_action + '''' ELSE '' END
				--+ CASE WHEN ISNULL(@user_action, 'all') <> 'all' THEN ' AND flhdam.user_action ='''+ @user_action + '''' ELSE '' END
			)
		  END
		+
		' ORDER BY flha.link_id ASC , flhdam.update_ts DESC
		'
	
	EXEC spa_print @sql	
	EXEC(@sql)	
	
END

ELSE IF @report_type = 'c'
BEGIN	
			
	CREATE TABLE #map (
		map_id INT,
		header_audit_id INT,
		detail_audit_id INT,
		CREATE_USER VARCHAR(50) COLLATE DATABASE_DEFAULT ,
		CREATE_ts DATETIME,
		UPDATE_USER VARCHAR(50) COLLATE DATABASE_DEFAULT ,
		UPDATE_ts DATETIME,
		changed_by CHAR(1) COLLATE DATABASE_DEFAULT ,
		user_action VARCHAR(50) COLLATE DATABASE_DEFAULT ,
		hedge_or_item CHAR(1) COLLATE DATABASE_DEFAULT ,
		fas_link_detail_id INT,
		source_deal_header_id INT
		
	)
		
	SET @sql = 'INSERT INTO #map
		SELECT 
			map.map_id
			,map.header_audit_id
			,map.detail_audit_id
			,map.create_user
			,map.create_ts
			,map.update_user
			,map.update_ts
			,map.changed_by
			,map.user_action		
			,flda.hedge_or_item
			,flda.fas_link_detail_id
			,flda.source_deal_header_id
		
		FROM fas_link_header_detail_audit_map map
		INNER JOIN #fas_link_header_audit flha ON flha.audit_id = map.header_audit_id
		LEFT JOIN fas_link_detail_audit flda ON  map.detail_audit_id  = flda.audit_id
			AND flha.link_id = flda.link_id
		WHERE 1 = 1 			
	'
	+ CASE WHEN @link_ids IS NOT NULL THEN ' AND flha.link_id in (' + @link_ids + ')' ELSE '' END	
	+ CASE 
		WHEN @hedge_rel_id_from IS NOT NULL OR  @hedge_rel_id_to IS NOT NULL THEN ''
		ELSE (
			+ CASE WHEN @update_date_from IS NOT NULL THEN ' AND map.update_ts >=''' + dbo.FNAConvertTZAwareDateFormat(@update_date_from, 1) + '''' ELSE '' END
			+ CASE WHEN @update_date_to IS NOT NULL THEN ' AND map.update_ts <=''' + dbo.FNAConvertTZAwareDateFormat(@update_date_to, 1) + ' 23:59:59''' ELSE '' END
			--+ CASE WHEN @update_by IS NOT NULL THEN ' AND map.update_user ='''+ @update_by + '''' ELSE '' END
			--+ CASE WHEN ISNULL(@user_action, 'all') <> 'all' THEN ' AND map.user_action ='''+ @user_action + '''' ELSE '' END
		)
	 END
	
	EXEC spa_print @sql
	EXEC(@sql)
		
	CREATE TABLE #fas_link_tmp (
		link_id INT,
		map_id1 INT,
		map_id2 INT,
		header_audit_id1 INT,
		header_audit_id2 INT,
		detail_audit_id1 INT,
		detail_audit_id2 INT		
	)
		
	SET @sql = '	
	INSERT  INTO #fas_link_tmp
		SELECT  
			flha1.link_id,			
			MAX(flhdam1.map_id) map_id1,
			MAX(flhdam2.map_id) map_id2,
			
			MAX(flhdam1.header_audit_id) header_audit_id1,
			MAX(flhdam2.header_audit_id) header_audit_id2,			
			MAX(flhdam1.detail_audit_id) detail_audit_id1,
			MAX(flhdam2.detail_audit_id) detail_audit_id2
			
		FROM #fas_link_header_audit flha1
			INNER JOIN #grid g on g.[Rel ID] = flha1.link_id
			INNER JOIN #map flhdam1 ON flhdam1.header_audit_id = flha1.audit_id			
			LEFT JOIN #fas_link_header_audit flha2 ON flha2.link_id = flha1.link_id
				AND g.[Rel ID] = flha1.link_id				
			INNER JOIN #map flhdam2 ON flhdam2.header_audit_id = flha2.audit_id
				and flhdam1.map_id > flhdam2.map_id
											
		WHERE 1 = 1 AND flhdam2.update_ts <='''+ dbo.FNAConvertTZAwareDateFormat(@prior_update_date, 1) + ' 23:59:59'''
		
		--+ CASE WHEN ISNULL(@user_action, 'all') <> 'all' THEN ' AND flha1.user_action ='''+ @user_action + '''' ELSE '' END
		--+ CASE WHEN ISNULL(@user_action, 'all') <> 'all' THEN ' AND flha2.user_action ='''+ @user_action + '''' ELSE '' END 
		
		+ CASE WHEN @link_ids IS NOT NULL THEN ' AND flha1.link_id in (' + @link_ids + ')' ELSE '' END
		+ CASE WHEN @link_ids IS NOT NULL THEN ' AND flha2.link_id in (' + @link_ids + ')' ELSE '' END 
		+ CASE 
			WHEN @hedge_rel_id_from IS NOT NULL OR  @hedge_rel_id_to IS NOT NULL THEN ''
			ELSE (
				--+ CASE WHEN @update_by IS NOT NULL THEN ' AND flhdam1.update_user ='''+ @update_by + '''' ELSE '' END
				--+ CASE WHEN @update_by IS NOT NULL THEN ' AND flhdam2.update_user ='''+ @update_by + '''' ELSE '' END
				+ CASE WHEN @update_date_from IS NOT NULL THEN ' AND flhdam1.update_ts >=''' + dbo.FNAConvertTZAwareDateFormat(@update_date_from, 1) + '''' ELSE '' END
				+ CASE WHEN @update_date_to IS NOT NULL THEN ' AND flhdam1.update_ts <=''' + dbo.FNAConvertTZAwareDateFormat(@update_date_to, 1) + ' 23:59:59''' ELSE '' END
				+ CASE WHEN @update_date_from IS NOT NULL THEN ' AND flhdam2.update_ts >=''' + dbo.FNAConvertTZAwareDateFormat(@update_date_from, 1) + '''' ELSE '' END
				+ CASE WHEN @update_date_to IS NOT NULL THEN ' AND flhdam2.update_ts <=''' + dbo.FNAConvertTZAwareDateFormat(@update_date_to, 1) + ' 23:59:59''' ELSE '' END
			)
		  END
		+
		'	 	
		GROUP BY flha1.link_id '
		
		EXEC spa_print @sql
		EXEC(@sql)


	-- Either header or detail can be changed at a time
	-- If there is a change in header part, changes in detail part must not be shown  and vice versa
	
	SELECT
		fas.link_id
		,MAX(fas.map_id1) map_id1
		,MAX(fas.map_id2) map_id2	
		,MAX(CASE 
			WHEN map.changed_by = 'd' THEN 0
			ELSE fas.header_audit_id1
		END) header_audit_id1
		,MAX(CASE 
			WHEN map.changed_by = 'd' THEN 0
			ELSE fas.header_audit_id2
		END) header_audit_id2
		,MAX(CASE 
			WHEN map.changed_by = 'h' THEN 0
			ELSE fas.detail_audit_id1
		END) detail_audit_id1
		,MAX(CASE 
			WHEN map.changed_by = 'h' THEN 0
			ELSE fas.detail_audit_id2
		END) detail_audit_id2
		
		INTO #fas_link
	FROM  #fas_link_tmp fas 
	LEFT JOIN #map map ON map.map_id = fas.map_id1
		--AND fas.detail_audit_id1 = map.detail_audit_id		
	LEFT JOIN #map map1 ON fas.detail_audit_id1 = map.detail_audit_id
		AND map1.detail_audit_id < detail_audit_id1
		AND map.hedge_or_item = map1.hedge_or_item
		AND map.fas_link_detail_id = map1.fas_link_detail_id
		AND map1.update_ts <= dbo.FNAConvertTZAwareDateFormat(@prior_update_date, 1) + ' 23:59:59'
	GROUP BY fas.link_id
	
		
	
	
	
--		SELECT
--			fas.link_id,				
--			MAX(fas.map_id1) map_id1,
--			MAX(fas.map_id2) map_id2,			
--			MAX(fas.header_audit_id1) header_audit_id1,
--			MAX(fas.header_audit_id2) header_audit_id2,			
--			--MAX(fas.detail_audit_id1) detail_audit_id1,
--			--MAX(fas.detail_audit_id1) detail_audit_id2
--			ISNULL(MAX(CASE 
--				WHEN fas.header_audit_id1 = fas.header_audit_id2 THEN  fas.detail_audit_id1
--				ELSE 0
--			END),0) detail_audit_id1,
--			
--			
--			ISNULL(MAX(CASE 
--				WHEN fas.header_audit_id1 = fas.header_audit_id2 THEN  map1.detail_audit_id
--				ELSE 0
--			END),0) detail_audit_id2
--			
--						
--			INTO #fas_link
--		FROM  #fas_link_tmp fas 
--		LEFT JOIN #map map ON fas.detail_audit_id1 = map.detail_audit_id
--		LEFT JOIN #map map1 ON fas.detail_audit_id1 = map.detail_audit_id
--			AND map1.detail_audit_id < detail_audit_id1
--			AND map.hedge_or_item = map1.hedge_or_item
--			AND map.source_deal_header_id = map1.source_deal_header_id
--			AND map1.update_ts <= (dbo.FNAConvertTZAwareDateFormat(@prior_update_date, 1) + ' 23:59:59')
--		GROUP BY fas.link_id
	
	SET @sql = '
	
		SELECT
			 --map1,
			 --map2,
			CASE 
				WHEN flha.is_deleted = ''y'' THEN
					CAST([Rel ID] AS VARCHAR)
				ELSE
					''<span style=cursor:hand onClick=openHyperLink(10233710,'' + CAST([Rel ID] AS VARCHAR)+'')><font color=#0000ff><u>''+ CAST([Rel ID] AS VARCHAR)+''</u></font></span>'' 
			END	[Rel ID]			
			
			,CASE 
				WHEN sdh.source_deal_header_id IS NOT NULL THEN 
					CASE 
						WHEN flha.is_deleted = ''y'' THEN cast([Deal ID]  as VARCHAR)
						ELSE dbo.FNAHyperLinkText(10131010,cast([Deal ID]  as VARCHAR),[Deal ID])
					END 
				ELSE NULL
			 END [Deal ID]
	 		,Field
			,[Prior Value]
			,[Current Value]
			,CASE [Type]
				WHEN ''h'' THEN ''Hedge''
				WHEN ''i'' THEN ''Item''
				ELSE NULL
			END [Type]
			,dbo.FNAConvertTZAwareDateFormat([Update TS],4) [Update TS]
			,[Update User] ' + @str_batch_table + '
		FROM (	
	 		SELECT 
	 		--fas_link.map_id1 map1,
			--fas_link.map_id2 map2,
	 			flha1.link_id [Rel ID]
	 			,NULL [Deal ID]	 			
	 			,Field
				,[Prior Value]
				,[Current Value]
				,NULL [Type]
				,flha1.update_ts [Update TS]
				,flha1.update_user [Update User] 
	 		FROM #fas_link fas_link	 			
	 			LEFT JOIN #fas_link_header_audit flha1 ON flha1.audit_id = fas_link.header_audit_id1
				LEFT JOIN #fas_link_header_audit flha2 ON flha2.audit_id = fas_link.header_audit_id2
				LEFT JOIN #book book1 ON book1.fas_book_id = flha1.fas_book_id
				LEFT JOIN #book book2 ON book2.fas_book_id = flha2.fas_book_id
				LEFT JOIN fas_eff_hedge_rel_type fehrt1 ON fehrt1.eff_test_profile_id = flha1.eff_test_profile_id
				LEFT JOIN fas_eff_hedge_rel_type fehrt2 ON fehrt2.eff_test_profile_id = flha2.eff_test_profile_id						 
			CROSS APPLY (
						SELECT    
							''Sub'',
							book1.Sub,
							book2.Sub
						UNION ALL
						SELECT
							''Strategy'',
							book1.Strategy,
							book2.Strategy
						UNION ALL
						SELECT
							''Book'',
							book1.Book,
							book2.Book
						UNION ALL
						SELECT    
							''Perfect Hedge'',
							CASE WHEN flha1.perfect_hedge = ''y'' THEN ''Yes'' ELSE ''No'' END,
							CASE WHEN flha2.perfect_hedge = ''y'' THEN ''Yes'' ELSE ''No'' END
							
						UNION ALL
						SELECT    
							''Fully De designated'',
							CASE WHEN flha1.fully_dedesignated = ''y'' THEN ''Yes'' ELSE ''No'' END,
							CASE WHEN flha2.fully_dedesignated = ''y'' THEN ''Yes'' ELSE ''No'' END								
						
						UNION ALL
						SELECT    
							''Description'',
							CAST(flha1.link_description AS VARCHAR(250)),
							CAST(flha2.link_description AS VARCHAR(250))
						
						UNION ALL
						SELECT    
							''Hedging Relationship Type'',
							fehrt1.eff_test_description,
							fehrt2.eff_test_description
							
						UNION ALL
						SELECT    
							''Effective Date'',
							dbo.FNADateFormat(flha1.link_effective_date),
							dbo.FNADateFormat(flha2.link_effective_date)
																					
						UNION ALL
						SELECT    
							''Active'',
							CASE WHEN flha1.link_active = ''y'' THEN ''Yes'' ELSE ''No'' END,
							CASE WHEN flha2.link_active = ''y'' THEN ''Yes'' ELSE ''No'' END
						
						UNION ALL
						SELECT    
							''End date'',
							dbo.FNADateFormat(flha1.link_end_date),
							dbo.FNADateFormat(flha2.link_end_date)
						
						UNION ALL
						SELECT    
							''De Designated Percentage'',
							CAST(flha1.dedesignated_percentage AS VARCHAR(250)),
							CAST(flha2.dedesignated_percentage AS VARCHAR(250))
				) TMP ( Field, [Current Value],[Prior Value] )
				WHERE   ISNULL([Current Value], '''') <> ISNULL([Prior Value], '''')
		
				--Detail		
				UNION ALL			
					SELECT 
					--fas_link.map_id1 map1,
					--fas_link.map_id2 map2,
	 					flda1.link_id [Rel ID]
	 					,flda1.source_deal_header_id [Deal ID]	 					
	 					,Field
						,[Prior Value]
						,[Current Value]
						,flda1.hedge_or_item [Type]
						,flda1.update_ts [Update TS]
						,flda1.update_user [Update User]
	 				FROM #fas_link fas_link	 			
	 					LEFT JOIN fas_link_detail_audit flda1 ON flda1.audit_id = fas_link.detail_audit_id1
	 					AND flda1.auto_update = ''n''
						LEFT JOIN fas_link_detail_audit flda2 ON flda2.audit_id = fas_link.detail_audit_id2
							AND flda1.auto_update = ''n''
							AND flda1.fas_link_detail_id = flda2.fas_link_detail_id								
					CROSS APPLY (
								SELECT    
									''Percentage Included'',
									CASE 
										WHEN flda1.user_action = ''delete'' THEN ''''							
										ELSE CAST(ROUND(flda1.percentage_included, 2) AS VARCHAR)
									END,
									CASE 
										WHEN flda1.user_action = ''insert'' THEN ''''
										ELSE CAST(ROUND(flda2.percentage_included, 2) AS VARCHAR)
									END							
								UNION ALL
								SELECT    
									''Effective Date'',
									CASE 
										WHEN flda1.user_action = ''delete'' THEN ''''							
										ELSE dbo.FNADateFormat(flda1.effective_date)
									END,
									CASE 
										WHEN flda1.user_action = ''insert'' THEN ''''									
										ELSE dbo.FNADateFormat(flda2.effective_date)					
									END
								
								/*UNION ALL
								SELECT    
									''Type'',
									CASE flda1.hedge_or_item
										WHEN ''h'' THEN ''Hedge'' 
										WHEN ''i'' THEN ''Item''
										ELSE '''' 
									END,
									CASE flda2.hedge_or_item
										WHEN ''h'' THEN ''Hedge'' 
										WHEN ''i'' THEN ''Item''
										ELSE '''' 
									END	
								UNION ALL
								SELECT    
									''Deal ID'',
									CAST(flda1.source_deal_header_id AS VARCHAR),
									CAST(flda2.source_deal_header_id AS VARCHAR)*/
								
									
					) TMP ( Field, [Current Value],[Prior Value] )
					WHERE   ISNULL([Current Value], '''') <> ISNULL([Prior Value], '''')
					
				)tmp
			INNER JOIN (
						SELECT DISTINCT link_id,is_deleted FROM #fas_link_header_audit
				) flha ON flha.link_id = tmp.[Rel ID]
			LEFT JOIN source_deal_header sdh ON tmp.[Deal ID] = sdh.source_deal_header_id
			ORDER BY [Rel ID] ASC,[Deal ID] ASC, [Update TS] DESC, Field ASC
		'	
	
	EXEC spa_print @sql
	EXEC(@sql)
	
END


IF @is_batch = 1
BEGIN
    exec spa_print '@str_batch_table'    
    SELECT @str_batch_table = dbo.FNABatchProcess(
               'u',
               @batch_process_id,
               @batch_report_param,
               GETDATE(),
               NULL,
               NULL
           )
    
    exec spa_print @str_batch_table  
    EXEC (@str_batch_table)                     
    
    SELECT @str_batch_table = dbo.FNABatchProcess(
               'c',
               @batch_process_id,
               @batch_report_param,
               GETDATE(),
               'spa_Create_Hedge_Rel_Audit_Report',
               'Hedging Relationship Audit Report'
           )
    
    EXEC spa_print @str_batch_table  
    EXEC (@str_batch_table) 
    EXEC spa_print 'finsh spa_Create_Hedge_Rel_Audit_Report' 
    RETURN
END  


/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_Create_Hedge_Rel_Audit_Report', 'Hedging Relationship Audit Report')
   EXEC(@sql_paging)  
 
   RETURN
END
 
--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END
GO


