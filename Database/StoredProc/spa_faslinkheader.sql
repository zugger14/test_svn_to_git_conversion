IF OBJECT_ID('spa_faslinkheader') IS NOT NULL
	DROP PROC dbo.[spa_faslinkheader]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
/**
This SP is used for CRUD operation for FAS links

Parameters: 
	@flag					: 
								's' - select all links
								'h' - select all links with assessments
								'a' - select a link
								'i' - insert a link
								'u' - update a link
								'd' - delete a link
								'z' -  returns assessment_approach_id
								'get_assessment_result'- returns  get_assessment_result_id
	@link_id				: Link Ids
	@book_id				: Book Entity Ids
	@fully_dedesignated		: Is link fully dedesignated	
	@link_active			: Active link filter
	@effective_date_from	: Link effective date from 
	@effective_date_to		: Link effective date to
	@link_description		: Link description
	@link_effective_date	: Link effective date
	@link_type_value_id		: Static data for link type
	@perfect_hedge			: Perfect hedge flag
	@eff_test_profile_id	: Hedge group id
	@link_id_from			: Link ID from filter
	@link_id_to				: Link ID to filter
	@sort_order				: Sort id column data
	@deal_id				: Deal Ids
	@ref_id					: Deal Reference Ids
	@eff_date_create_date	: Take create date as effective date 
	@subsidiary_id			: Subsidiary Entity Ids
	@strategy_id			: Strategy Entity Ids
	@batch_process_id		: Batch unique identifer
	@batch_report_param		: Batch parameters
	@enable_paging			: Enable paging flag
	@page_size				: page size 
	@page_no				: Page Number
*/

CREATE PROC [dbo].[spa_faslinkheader]  
	@flag					VARCHAR(100),  
	@link_id				VARCHAR(MAX) = NULL,  
	@book_id				VARCHAR(MAX) = NULL,  
	@fully_dedesignated		CHAR(1) = NULL,  
	@link_active			CHAR(1) = NULL,  
	@effective_date_from	VARCHAR(20) = NULL,  
	@effective_date_to		VARCHAR(20) = NULL,  
	@link_description		VARCHAR(100) = NULL,  
	@link_effective_date	DATETIME = NULL,  
	@link_type_value_id		INT = NULL,  
	@perfect_hedge			CHAR(1) = NULL,  
	@eff_test_profile_id	INT = NULL,   
	@link_id_from			INT =  NULL,  
	@link_id_to				INT = NULL,  
	@sort_order				CHAR(1) = 'l',  
	@deal_id				VARCHAR(MAX) = NULL,  
	@ref_id					VARCHAR(MAX) = NULL,  
	@eff_date_create_date	CHAR(1) = NULL,  
	@subsidiary_id			VARCHAR(MAX) = NULL,  
	@strategy_id			VARCHAR(MAX) = NULL,
	@batch_process_id		VARCHAR(250) = NULL,
	@batch_report_param		VARCHAR(500) = NULL, 
	@enable_paging			INT = 0,  --'1' = enable, '0' = disable
	@page_size				INT = NULL,
	@page_no				INT = NULL	  
 
AS  

SET NOCOUNT ON
 
SET @ref_id = NULLIF(@ref_id, '')  
 
/*******************************************1st Paging Batch START**********************************************/
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch bit
			 
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 

SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END		

IF @is_batch = 1
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

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
/*******************************************1st Paging Batch END**********************************************/  
DECLARE @sql_stmt VARCHAR(MAX)  
DECLARE @st_where VARCHAR(100)  
DECLARE @error_no INT  
  
--IF @link_id_from IS NOT NULL AND @link_id_to IS NULL  
-- SET @link_id_to=@link_id_from  
  
--IF @link_id_from IS NULL AND @link_id_to IS NOT NULL  
-- SET @link_id_from=@link_id_to  
  
CREATE TABLE #books (fas_book_id INT)   
SET @sql_stmt = 'INSERT INTO  #books 
				SELECT distinct book.entity_id fas_book_id FROM portfolio_hierarchy book (nolock) 
				INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id 
				LEFT OUTER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id            
				WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) '  
				+ CASE WHEN @subsidiary_id IS NOT NULL THEN ' AND stra.parent_entity_id IN(' + @subsidiary_id + ')'  ELSE '' END  
				+ CASE WHEN @strategy_id IS NOT NULL THEN  ' AND stra.entity_id IN(' +  @strategy_id + ')'  ELSE '' END  
				+ CASE WHEN @book_id IS NOT NULL THEN  ' AND book.entity_id IN(' +  @book_id + ')'  ELSE '' END  
EXEC (@sql_stmt)  

IF @flag IN ('s','h')  
BEGIN  
	--UB Changed always allow edit on links  
	--   (CASE dbo.FNAFasHeader(a.link_id) when ''y'' THEN ''Yes'' Else ''No'' END) as [Allow Change],  
	CREATE TABLE #TEMP(
		eff_test_profile_id INT,
		link_id INT,
		calc_level INT,
		id VARCHAR(50) COLLATE DATABASE_DEFAULT ,
		[name] VARCHAR(1000) COLLATE DATABASE_DEFAULT ,
		[description] VARCHAR(1000) COLLATE DATABASE_DEFAULT 
	)

	INSERT #TEMP
	EXEC spa_get_all_assessments_to_run  NULL, NULL, @book_id, NULL, 'y'

	SET @sql_stmt = 'SELECT * ' + @str_batch_table + ' 
					FROM (  
						SELECT dbo.FNATRMWinHyperlink(''a'', 10233700, a.link_id, ABS(a.link_id),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0) link_id ,  
							a.link_description, 
							sub.entity_name subsidiary, 
							stra.entity_name strategy,
							book.entity_name book,   
							dbo.FNADateFormat(a.link_effective_date) effective_date,       
							(CASE a.perfect_hedge when ''y'' THEN ''Yes'' Else ''No'' END) as perfect_hedge, 
							(CASE a.fully_dedesignated when ''y'' THEN ''Yes'' Else ''No'' END) as fully_dedesignated,   
							(CASE a.link_active when ''y'' THEN ''Yes'' Else ''No'' END) AS link_active, 
							(CASE dbo.FNAFasHeader(a.link_id) when ''y'' THEN ''Yes'' Else ''No'' END) as allow_change,
							CASE WHEN b.init_eff_test_approach_value_id IN (302,304) OR b.on_eff_test_approach_value_id IN (302,304) THEN 0 ELSE 1 END assessment_result,
							ass_link.id assessment_id, 
							b.hedge_doc_temp,
							a.link_id id
						FROM fas_link_header a 
						INNER JOIN fas_eff_hedge_rel_type b ON a.eff_test_profile_id = b.eff_test_profile_id 
						INNER JOIN portfolio_hierarchy book ON book.entity_id = a.fas_book_id 
						INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id 
						INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id 
						INNER JOIN fas_strategy strategy ON book.parent_entity_id = strategy.fas_strategy_id 
						INNER JOIN static_data_value sdv ON  sdv.value_id = strategy.hedge_type_value_id 
						LEFT JOIN #TEMP ass_link ON ass_link.link_id = a.link_id AND ass_link.eff_test_profile_id = a.eff_test_profile_id
					'   
					+ CASE WHEN @deal_id IS NOT NULL OR @ref_id IS NOT NULL THEN   
						'  
						INNER JOIN (SELECT link_id FROM fas_link_detail fld   
								INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = fld.source_deal_header_id  
							WHERE 1 = 1 ' 
					+ CASE WHEN @ref_id IS NOT NULL THEN 'AND sdh.deal_id LIKE (''%'+ @ref_id + '%'')' ELSE '' END    						
					+ CASE WHEN @deal_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN ('+ @deal_id + ')' ELSE '' END    
					+ '  GROUP BY fld.link_id) fldsdh ON fldsdh.link_id = a.link_id'  ELSE '' END  
					+' WHERE 1 = 1 '  
					+ CASE WHEN @subsidiary_id IS NOT NULL THEN  ' AND stra.parent_entity_id IN  ( ' + @subsidiary_id + ') '  ELSE '' END 
					+ CASE WHEN @strategy_id IS NOT NULL THEN  ' AND stra.entity_id IN  ( ' +  @strategy_id + ') '  ELSE '' END 
					+ CASE WHEN @book_id IS NOT NULL THEN  ' AND book.entity_id IN  ( ' +  @book_id + ') '  ELSE '' END    

	IF @link_id_from IS NOT NULL AND @link_id_to IS NOT NULL  
		SET @sql_stmt = @sql_stmt + ' AND a.link_id >= ' + CAST(@link_id_from AS VARCHAR) +   
						' AND a.link_id <= ' + CAST(@link_id_to AS VARCHAR)    
	ELSE IF  @link_id_from IS NOT NULL AND @link_id_to IS NULL  
		SET @sql_stmt = @sql_stmt + ' AND a.link_id >= ' + CAST(@link_id_from AS VARCHAR)    
	ELSE IF  @link_id_from IS NULL AND @link_id_to IS NOT NULL  
		SET @sql_stmt = @sql_stmt + ' AND a.link_id <= ' + CAST(@link_id_to AS VARCHAR)    
	ELSE IF @link_id_from IS NULL AND @link_id_to IS NULL AND @ref_id IS NULL AND @deal_id IS NULL  
	BEGIN  
		IF  @book_id IS NOT NULL  
			SET @sql_stmt = @sql_stmt + ' AND a.fas_book_id IN (' + @book_id  +')'  
		IF @eff_date_create_date = 'y'  
		BEGIN  
			SET @sql_stmt = @sql_stmt + ' AND (dbo.FNAConvertTZAwareDateFormat(a.create_ts, 1) BETWEEN  ''' + @effective_date_from + ''' AND ''' + @effective_date_to + ''')'  
		--SET @sql_stmt = @sql_stmt + ' AND (CONVERT(VARCHAR(10), a.create_ts, 120) between  ''' + @effective_date_from + ''' and ''' + @effective_date_to + ''')'  
		END  
	ELSE  
	BEGIN  
		SET @sql_stmt = @sql_stmt + ' AND (a.link_effective_date BETWEEN CONVERT(DATETIME, ''' + @effective_date_from + ''', 102) AND CONVERT(DATETIME, ''' + @effective_date_to + ''', 102))'  
	END  
      
	SET @sql_stmt = @sql_stmt + ' AND link_active = ''' + @link_active + ''''  
  
	IF @fully_dedesignated IS NOT NULL AND @fully_dedesignated = 'y'    
		SET @sql_stmt = @sql_stmt + ' AND link_type_value_id <> 450 '  
	ELSE IF @fully_dedesignated IS NOT NULL AND @fully_dedesignated = 'n'    
		SET @sql_stmt = @sql_stmt + ' AND link_type_value_id = 450 '  
	END  
   
	SET @sql_stmt = @sql_stmt + '  
					UNION ALL  
					SELECT CAST(-1 * fb.fas_book_id AS VARCHAR(50)) link_id,  
						eff_test_name + '' for Book '' + book.entity_name Description,  
						sub.entity_name subsidiary,
						strat.entity_name strategy,
						book.entity_name book,   
						dbo.FNADateFormat(rtype.effective_start_date) EffectiveDate,      
						''No'' PerfectHedge ,
						''No'' FullyDedesignated,
						(CASE profile_active when ''y'' THEN ''Yes'' Else ''No'' END) LinkActive,  
						''No'' allow_change,
						0 assessment_result 
						, NULL assessment_id
						, rtype.hedge_doc_temp,
						CAST(-1 * fb.fas_book_id AS VARCHAR(50)) id  
					FROM portfolio_hierarchy book 
					INNER JOIN portfolio_hierarchy strat ON strat.entity_id = book.parent_entity_id  
					INNER JOIN portfolio_hierarchy sub ON sub.entity_id = strat.parent_entity_id  
					INNER JOIN fas_strategy fs ON fs.fas_strategy_id = strat.entity_id 
					INNER JOIN fas_books fb ON fb.fas_book_id = book.entity_id  
					INNER JOIN fas_eff_hedge_rel_type rtype ON rtype.eff_test_profile_id = COALESCE(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id)  
					INNER JOIN static_data_value sdv ON  sdv.value_id = fs.hedge_type_value_id  
					INNER JOIN #books ON #books.fas_book_id= fb.fas_book_id  
					WHERE profile_approved = ''y'' and profile_active = ''' + @link_active + ''' 
					AND ( fs.hedge_type_value_id IN (150, 151) AND (fs.mes_gran_value_id IN (177, 178)   
					OR (individual_link_calc IS NOT NULL AND individual_link_calc = ''y'')))  
					AND (effective_start_date BETWEEN CONVERT(DATETIME, ''' + @effective_date_from + ''', 102) AND CONVERT(DATETIME, ''' + @effective_date_to + ''', 102))  '
	+ CASE WHEN @book_id IS NOT NULL THEN ' and fb.fas_book_id IN ('+ CAST(ISNULL(@book_id,0) AS VARCHAR(MAX)) + ')' ELSE '' END  
	
	SET @sql_stmt = @sql_stmt + ') l' 
    
	IF @flag = 'h'
	BEGIN
		SET @sql_stmt = @sql_stmt + ' WHERE l.assessment_id IS NOT NULL '
	END 

	IF @sort_order = 'l'  
		SET @sql_stmt = @sql_stmt + ' ORDER BY l.link_id DESC'  
	ELSE   
	  SET @sql_stmt = @sql_stmt + ' ORDER by l.link_id ASC'  
	
	EXEC spa_print @sql_stmt  
	EXEC(@sql_stmt)  
  
	--  If @fully_dedesignated = 'y'   
	--   SET @sql_stmt = 'select a.*, b.eff_test_name  
	--   from fas_link_header a, fas_eff_hedge_rel_type b  
	--   where a.fas_book_id = @book_id  
	--   and a.eff_test_profile_id = b.eff_test_profile_id  
	--   AND (a.link_effective_date between ''' + @effective_date_from + ''' and ''' + @effective_date_to + ''')   
	--   and link_active = ''' + @link_active + '''  
	--   and link_type_value_id <> 450'  
	--  else  
	--   select a.*, b.eff_test_name  
	--   from fas_link_header a, fas_eff_hedge_rel_type b  
	--   where a.fas_book_id = @book_id  
	--   and a.eff_test_profile_id = b.eff_test_profile_id  
	--   AND (a.link_effective_date between @effective_date_from and @effective_date_to)   
	--   and link_active = @link_active  
	--   and link_type_value_id = 450  
    
   
	IF @@ERROR <> 0  
		EXEC spa_ErrorHandler @@ERROR, 'Link Header table',   
		'spa_faslinkheader', 'DB Error',   
		'Failed to select fas Link header record.', ''  
	-- Else  
	--  Exec spa_ErrorHandler 0, 'Link Header table',   
	--    'spa_faslinkheader', 'Success',   
	--    'Fas Link Header record successfully selected.', ''  
END  
IF @flag = 'a'   
--this is to get the details of a link header information for a particular link id.  
BEGIN  
	DECLARE @close_as_of_date DATETIME  
	DECLARE @link_eff_date DATETIME  
	DECLARE @min_run_as_of_date DATETIME  
	DECLARE @allow_changes AS CHAR(1)  
	--DECLARE @fully_dedesignated as VARCHAR(1)  
  
	DECLARE @link_type AS INTEGER  
  
	--- check to see if the link has already been closed. If so certain  
	---- changes can not be made (i.e., change relationship type)  
	SELECT @close_as_of_date = MAX(as_of_date) FROM close_measurement_books   
	SELECT @link_type = link_type_value_id, @link_eff_date = CASE WHEN (link_type_value_id = 450) THEN link_effective_date ELSE link_end_date END   
	FROM fas_link_header   
	WHERE link_id = @link_id     
  
	SELECT @min_run_as_of_date = MIN(as_of_date) FROM close_measurement_books WHERE as_of_date >= @link_eff_date  
  
	IF @min_run_as_of_date IS NOT NULL   
		SET @allow_changes = 'n'  
	ELSE  
		SET @allow_changes = 'y'  
  
	/*  
	If @link_type = 450   
	begin  
	create table #max_date (as_of_date datetime)  
	set @st_where ='link_id='+cast(@link_id as VARCHAR)+ ' and link_deal_flag=''l'''  
	--print @st_where  
	insert into #max_date (as_of_date) exec  spa_get_Script_ProcessTableFunc 'min','as_of_date','report_measurement_values',@st_where  
	select @min_run_as_of_date = dbo.FNAGetSQLStandardDate(min(as_of_date)) from #max_date  
 
	--  select @min_run_as_of_date = min(as_of_date) from report_measurement_values rmv  
	--  WHERE rmv.link_id = @link_id and rmv.link_deal_flag = 'l'  
	END  
	Else  
	select @min_run_as_of_date = isnull(max(dedesignation_date), @close_as_of_date)   
	from fas_dedesignated_locked_aoci fdla WHERE fdla.link_id = @link_id   
	*/   
	-- If @close_as_of_date IS NULL OR @min_run_as_of_date IS NULL  
	--  SET @allow_changes = 'y'  
	-- Else If @min_run_as_of_date <= @close_as_of_date  
	--  SET @allow_changes = 'n'  
	-- Else  
	--  SET @allow_changes = 'y'  
  
  
	-- If (SELECT     TOP 1 ISNULL(fully_dedesignated, 'n') AS fully_dedesignated  
	-- FROM         calcprocess_rep_msmt_vals  
	-- WHERE     (link_id = @link_id) AND (calc_type = 'm')  
	-- ORDER BY as_of_date DESC) = 'y'  
	--  SET @fully_dedesignated = 'y'  
	-- else  
	--  SET @fully_dedesignated = 'n'  
  
	--print  @fully_dedesignated  
	IF @link_id > 0   
	BEGIN  
		SELECT  a.link_id AS LinkID, a.fas_book_id AS BookID, a.perfect_hedge PerfectHedge,   
			a.fully_dedesignated FullyDedesignated,  
			--CASE when (fully_dedesignated = 'y') THEN 'y' else @fully_dedesignated END FullyDedesignated,   
			a.link_description Description,   
			a.eff_test_profile_id RelTypeID,   
			dbo.FNAGetSQLStandardDate(a.link_effective_date) EffectiveDate,   
			a.link_type_value_id RelTypeId,   
			link_active LinkActive, a.create_user CreatedUser,   
			dbo.FNAGetSQLStandardDate(a.create_ts) AS CreateTS, a.update_user AS UpdateUser,   
			dbo.FNAGetSQLStandardDate(a.update_ts) AS UpdateTS,    
			b.eff_test_name AS RelName,   
			@allow_changes AS AllowChanges,  
			--'y',  
			sdv.value_id HedgeTypeId,  
			sdv.code HedgeType,  
			b.hedge_doc_temp,  
			original_link_id,  
			dbo.FNAGetSQLStandardDate(link_end_date) link_end_date,  
			dedesignated_percentage  
		FROM fas_link_header a 
		INNER JOIN fas_eff_hedge_rel_type b ON a.eff_test_profile_id = b.eff_test_profile_id 
		INNER JOIN portfolio_hierarchy book ON book.entity_id = a.fas_book_id 
		INNER JOIN fas_strategy strategy ON book.parent_entity_id = strategy.fas_strategy_id 
		INNER JOIN static_data_value sdv ON  sdv.value_id = strategy.hedge_type_value_id  
		WHERE a.link_id = @link_id  
	END   
	ELSE  
	BEGIN   
		SELECT -1 * fb.fas_book_id link_id,   
			fb.fas_book_id BookId,  
			0 PerfectHedge ,0 FullyDedesignated, -- UDAY  
			eff_test_name + ' for Book ' + book.entity_name Description,  
			rtype.eff_test_profile_id HedgeRelTypeID,   
			dbo.FNAGetSQLStandardDate(rtype.effective_start_date) EffectiveDate,  
			450 RelTypeId, -- UDAY    
			0  AS LinkActive,   
			rtype.create_user CreatedUser,   
			dbo.FNAGetSQLStandardDate(rtype.create_ts) AS CreateTS,   
			rtype.update_user AS UpdateUser,   
			dbo.FNAGetSQLStandardDate(rtype.update_ts) AS UpdateTS,   
			rtype.eff_test_name AS HedgeRelTypeName,  
			'n' AS [Allow Change],  
			sdv.value_id HedgeTypeId,  
			sdv.code [Hedge TYPE],  
			rtype.hedge_doc_temp,  
			NULL original_link_id,  
			NULL link_end_date,  
			NULL dedesignated_percentage ,
			sub.entity_name + '|' + strat.entity_name + '|' + book.entity_name + '|NULL'  [book_structure]
		FROM portfolio_hierarchy book 
		INNER JOIN portfolio_hierarchy strat ON strat.entity_id = book.parent_entity_id  
		INNER JOIN portfolio_hierarchy sub ON sub.entity_id = strat.parent_entity_id  
		INNER JOIN fas_strategy fs ON fs.fas_strategy_id = strat.entity_id 
		INNER JOIN fas_books fb ON fb.fas_book_id = book.entity_id  
		INNER JOIN fas_eff_hedge_rel_type rtype ON rtype.eff_test_profile_id = COALESCE(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id)  
		INNER JOIN static_data_value sdv ON  sdv.value_id = fs.hedge_type_value_id  
		WHERE -1 * fb.fas_book_id = @link_id  
	END 
	
	IF @@ERROR <> 0  
		EXEC spa_ErrorHandler @@ERROR, 'Link Header table',   
		'spa_faslinkheader', 'DB Error',   
		'Failed to select fas Link header record.', ''  
END   
ELSE IF @flag = 'i'  
BEGIN  
	IF @link_description IS NULL OR @link_description = ''  
	BEGIN  
		SET  @link_description = 'Hedging relationship for type: ' + CAST(@eff_test_profile_id AS VARCHAR) + ' created on: ' + CAST(GETDATE() AS VARCHAR)  
	END  
  
	INSERT INTO fas_link_header  
	(fas_book_id,  perfect_hedge,  fully_dedesignated,  link_description,  eff_test_profile_id,  link_effective_date,  link_type_value_id,  link_active)  
	VALUES (@book_id,  @perfect_hedge,  @fully_dedesignated,  @link_description,  @eff_test_profile_id,  @link_effective_date,  @link_type_value_id,  @link_active)  
	
	DECLARE @new_id VARCHAR(100)  
	
	SET @new_id = CAST(SCOPE_IDENTITY() AS VARCHAR)  
	
	IF @@ERROR <> 0  
		EXEC spa_ErrorHandler @@ERROR, 'Fas Link header table',   
		'spa_faslinkheader', 'DB Error',   
		'Failed to insert Fas Link Header data.', ''  
	ELSE  
		EXEC spa_ErrorHandler 0, 'Fas Link Header Table',   
		'spa_faslinkheader',@new_id ,   
		'Fas Link Header Data successfully Inserted.', @link_description  
END   
ELSE IF @flag = 'u'  
BEGIN  
	DECLARE @prior_link_active CHAR(1)  
  
	SET @prior_link_active = NULL  
  
	SELECT @prior_link_active = link_active FROM fas_link_header   
	WHERE link_id = @link_id  
   
	UPDATE fas_link_header  
	SET  fas_book_id = @book_id,  
		perfect_hedge = @perfect_hedge,  
		fully_dedesignated = @fully_dedesignated,  
		link_description = @link_description,  
		eff_test_profile_id = @eff_test_profile_id,  
		link_effective_date = @link_effective_date,  
		link_type_value_id = @link_type_value_id,  
		link_active = @link_active  
	WHERE link_id = @link_id  
  
	IF @@ERROR <> 0  
		EXEC spa_ErrorHandler @@ERROR, 'Fas Link header table',   
		'spa_faslinkheader', 'DB Error',   
		'Failed to update Fas Link Header data.', ''  
	ELSE  
	BEGIN  
		---Update percentage included of all detail to 0 if the link is made inactive  
		IF @prior_link_active = 'y' AND @link_active = 'n'   
		UPDATE fas_link_detail  
		SET percentage_included = 0.0  
		WHERE link_id = @link_id  
    
		EXEC spa_ErrorHandler 0, 'Fas Link Header Table',   
			'spa_faslinkheader', 'Success',   
			'Fas Link Header Data successfully updated.', ''  
	END  
END   
ELSE IF @flag = 'd'  
BEGIN  
  
	DECLARE @msg_desc VARCHAR(250)  
	DECLARE @original_link_id INT  
	DECLARE @dedesignation_date VARCHAR(20)  
  
	--BEGIN TRANSACTION  
  
	DECLARE @link_type_val  INT  
  
	SELECT @link_type_val = flh.link_type_value_id 
	FROM fas_link_header flh
	INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = flh.link_id

	DECLARE @validation_table_exists INT   
	IF OBJECT_ID('adiha_process.dbo.validation_table_farrms_admin_to_delete') IS NOT NULL -- table created in spa_reject_finalized_link to handle delete from Designation of Hedge
	BEGIN 
		SET @validation_table_exists = 1
	END

	IF @link_type_val <> 450  
	BEGIN  
		DECLARE @status_code VARCHAR(100)  
		BEGIN TRY  
			BEGIN TRANSACTION
			DECLARE @designate_link INT 
			DECLARE cur_link CURSOR LOCAL FOR
			SELECT item
			FROM dbo.SplitCommaSeperatedValues(@link_id)
			OPEN cur_link
				FETCH NEXT FROM cur_link INTO @designate_link
				WHILE @@FETCH_STATUS = 0   
				BEGIN 
					EXEC spa_get_percentage_dedesignation 'd', @designate_link  
					FETCH NEXT FROM cur_link INTO @designate_link
				END
			CLOSE cur_link
			DEALLOCATE  cur_link   
     
			SET @error_no = 0  
			SET @msg_desc = 'Hedging Relationship ID: ' + CAST(@link_id AS VARCHAR) + ' deleted.'  
			SET @status_code = 'Success'  
			COMMIT  
		END TRY  
		BEGIN CATCH  
			IF @@TRANCOUNT > 0  
			ROLLBACK  
      
		   SET @error_no = ERROR_NUMBER()  
		   SET @msg_desc = 'Failed to delete relationship header record for ID:' + CAST(@link_id AS VARCHAR)  
		   SET @status_code = 'DB Error'  
		END CATCH  
    
		IF OBJECT_ID('tempdb..#error_handler', 'U') IS NOT NULL  
		BEGIN  
			INSERT INTO #error_handler VALUES (@error_no, 'Link Header Table', 'spa_faslinkheader', @status_code, @msg_desc, '')  
		END  
		ELSE  
		BEGIN 
			IF @validation_table_exists = 1
			BEGIN
				INSERT INTO adiha_process.dbo.validation_table_farrms_admin_to_delete
				EXEC spa_ErrorHandler @error_no, 'Link Header Table',   
				'spa_faslinkheader', @status_code, @msg_desc, ''  
			END 
	
			EXEC spa_ErrorHandler @error_no, 'Link Header Table',   
			'spa_faslinkheader', @status_code, @msg_desc, ''   
		END  
		RETURN  
	END  
	ELSE  
	BEGIN  --Check if there are any dedesignaion for the original link  
    
		IF EXISTS(SELECT COUNT(1) FROM fas_link_header flh
				INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = flh.original_link_id
				HAVING COUNT(1) > 0
			)
		BEGIN  

			SET @msg_desc = 'The selected link has one to many dedesignations and can not be deleted without dedesignation links deleted.'  
			IF @validation_table_exists = 1
			BEGIN
				INSERT INTO adiha_process.dbo.validation_table_farrms_admin_to_delete
				EXEC spa_ErrorHandler -1, 'Designation',   
					'spa_faslinkheader', 'DB Error', @msg_desc, 'Please delete the dedesignation links first.'  
			END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler -1, 'Designation',   
				'spa_faslinkheader', 'DB Error', @msg_desc, 'Please delete the dedesignation links first.'  
			END 
			RETURN  
		END  
	END  

	BEGIN TRAN  
  
	--Delete all eff test results for this link  and associated what-if profiles  
	EXEC spa_delete_link_eff_test_results @link_id  
  
	--delete relationships detail
	DELETE ghdg
	FROM fas_link_header flh 
	INNER JOIN gen_hedge_group  ghd ON ghd.eff_test_profile_id= flh.eff_test_profile_id
	INNER JOIN gen_hedge_group_detail ghdg ON ghdg.gen_hedge_group_id = ghd.gen_hedge_group_id
	INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = flh.link_id

	--delete relationships header
	DELETE ghd
	FROM fas_link_header flh 
	INNER JOIN gen_hedge_group ghd ON ghd.eff_test_profile_id= flh.eff_test_profile_id
	INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = flh.link_id  
  
	--SET @st_where='link_id = '+CAST(@link_id AS VARCHAR)+' and link_deal_flag = ''l'''  
	----exec spa_delete_ProcessTable 'report_measurement_values',@st_where  
	-- EXEC('delete report_measurement_values where ' + @st_where)  
	DELETE rs
	FROM report_measurement_values rs
	INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = rs.link_id
	WHERE rs.link_deal_flag = 'l'
  
  
	-- delete from report_measurement_values  
	-- where link_id = @link_id and link_deal_flag = 'l'  
  
	--SET @st_where='link_id = '+CAST(@link_id AS VARCHAR)+' and link_type = ''link'''  
	----exec spa_delete_ProcessTable 'calcprocess_deals',@st_where  
	-- EXEC('delete calcprocess_deals where ' + @st_where)  
 
	DELETE rs
	FROM calcprocess_deals rs
	INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = rs.link_id
	WHERE rs.link_type = 'link'
  
	-- delete from calcprocess_deals  
	-- where link_id = @link_id and link_type = 'link'  
  
  
	--SET @st_where='link_id = '+CAST(@link_id AS VARCHAR)+' and link_type = ''link'''  
	----exec spa_delete_ProcessTable 'calcprocess_aoci_release',@st_where  
	-- EXEC('delete calcprocess_aoci_release where ' + @st_where)
	DELETE rs
	FROM calcprocess_aoci_release rs
	INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = rs.link_id
	WHERE rs.link_type = 'link'

	-- delete from calcprocess_aoci_release  
	-- where link_id = @link_id and link_type = 'link'  
  
	DELETE rs 
	FROM calcprocess_deals_expired rs 
	INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = rs.link_id
	WHERE rs.link_type = 'link'  

	DELETE rs
	FROM report_measurement_values_expired rs
	INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = rs.link_id
	WHERE rs.link_deal_flag = 'l' 
 
	DELETE rs
	FROM reclassify_aoci rs
	INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = rs.link_id
  
	DELETE rs
	FROM inventory_reclassify_aoci rs
	INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = rs.link_id 
  
  
	/*  
	 SELECT @original_link_id = original_link_id, @dedesignation_date = dbo.FNAGetSQLStandardDate(link_end_date)  
	 FROM fas_link_header  
	 WHERE link_id = @link_id  
   
	 IF @original_link_id IS NOT NULL  
	 --if this is de-designated link...  
	 BEGIN  
	  --TODO: same logic is used when deleting dedignated from designated detail window, can we move  
	  --common logic to one separte sp???  
    
	  --move the % included from de-designated link to original link  
	  UPDATE fas_link_detail SET percentage_included = fld.percentage_included + ISNULL(pre_link.percentage_included, 0)   
	  FROM fas_link_detail fld   
	  INNER JOIN  
	  (  
	   SELECT fdld.source_deal_header_id, fdlh.original_link_id link_id, ISNULL(fdld.percentage_included, 0) percentage_included  
	   FROM   fas_link_header fdlh   
	   INNER JOIN fas_link_detail fdld ON fdld.link_id = fdlh.link_id  
	   WHERE fdlh.link_id = @link_id   
	  ) pre_link ON pre_link.link_id = fld.link_id   
	   AND pre_link.source_deal_header_id = fld.source_deal_header_id  
       
	  UPDATE fas_link_header SET fully_dedesignated = 'n'  
	  WHERE link_id = @original_link_id  
    
	  DELETE fas_dedesignated_link_detail   
	  FROM fas_dedesignated_link_detail fdld  
	  INNER JOIN fas_dedesignated_link_header fdlh ON fdld.dedesignated_link_id = fdld.dedesignated_link_id  
	  WHERE fdlh.original_link_id = @original_link_id   
	   AND dedesignation_date = @dedesignation_date  
  
	  DELETE fas_dedesignated_link_header WHERE original_link_id = @original_link_id and dedesignation_date = @dedesignation_date  
	 END  
   
	 delete from fas_dedesignated_link_detail  
	 where dedesignated_link_id in   
	 (select dedesignated_link_id from fas_dedesignated_link_header where original_link_id = @link_id)  
  
	 delete from fas_dedesignated_link_header  
	 where original_link_id = @link_id  
     
	*/  
  
	DELETE rs 
	FROM fas_link_detail rs
	INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = rs.link_id
  
	IF @@ERROR = 0  
	BEGIN  
		DELETE rs FROM fas_link_header rs
		INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = rs.link_id
  
		DELETE rs FROM fas_link_detail_dicing rs 
		INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = rs.link_id
     
		IF @@ERROR <> 0  
		BEGIN  
			ROLLBACK  
			SET @msg_desc = 'Failed to delete relationship header record for ID: ' + CAST(@link_id AS VARCHAR)  
			IF @validation_table_exists = 1
			BEGIN	
				INSERT INTO adiha_process.dbo.validation_table_farrms_admin_to_delete
				EXEC spa_ErrorHandler @@ERROR, 'Link Header Table',   
				'spa_faslinkheader', 'DB Error', @msg_desc, ''  
			END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, 'Link Header Table',   
				'spa_faslinkheader', 'DB Error', @msg_desc, ''  
			END
		END  
		ELSE  
		BEGIN  
			COMMIT  
			SET @msg_desc = 'Hedging Relationship ID deleted.'  
   
			IF @validation_table_exists = 1
			BEGIN  
				INSERT INTO adiha_process.dbo.validation_table_farrms_admin_to_delete
				EXEC spa_ErrorHandler 0, 'Link Header Table',   
					'spa_faslinkheader', 'Success', @msg_desc, ''   
			END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler 0, 'Link Header Table',   
				'spa_faslinkheader', 'Success', @msg_desc, ''   
			END
		END  
	END  
	ELSE  
	BEGIN  
		ROLLBACK  
		SET @msg_desc = 'Failed to delete relationship detail record for ID: ' + CAST(@link_id AS VARCHAR)  
		IF @validation_table_exists = 1
		BEGIN
			INSERT INTO adiha_process.dbo.validation_table_farrms_admin_to_delete
			EXEC spa_ErrorHandler @@ERROR, 'Link Detail Table',   
			'spa_faslinkheader', 'DB Error', @msg_desc, ''  
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler @@ERROR, 'Link Detail Table',   
			'spa_faslinkheader', 'DB Error', @msg_desc, ''
		END	  
	END  
END  
ELSE IF @flag = 'z'
BEGIN
	SELECT feh.init_eff_test_approach_value_id [assessment_approach_id]
	FROM fas_link_header flh
	INNER JOIN fas_eff_hedge_rel_type feh
		ON flh.eff_test_profile_id=feh.eff_test_profile_id
	WHERE CAST(link_id AS VARCHAR(50)) = @link_id
END
ELSE IF @flag = 'get_assessment_result'
BEGIN 
	DECLARE @assessment_result INT = 0
	IF @link_id = 'NULL'	
		SET @link_id = NULL

	SELECT @assessment_result = CASE WHEN b.init_eff_test_approach_value_id IN (302,304) OR b.on_eff_test_approach_value_id IN (302,304) THEN 0 ELSE 1 END  
	FROM fas_link_header a 
	INNER JOIN fas_eff_hedge_rel_type b ON a.eff_test_profile_id = b.eff_test_profile_id 
	WHERE CAST(a.link_id AS VARCHAR(50)) = @link_id

	SELECT CASE WHEN @assessment_result = '' THEN 0 ELSE @assessment_result END  
END 
/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)   
	EXEC(@str_batch_table)                   

	SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_faslinkheader', 'Detailed Links Report')         
	EXEC(@str_batch_table)        
	RETURN
END

--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
	SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	EXEC(@sql_paging)
END
/*******************************************2nd Paging Batch END**********************************************/

GO
