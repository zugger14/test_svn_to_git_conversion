/********************************************************************
 * Create date: 2010-08-12											*
 * Description: populate data in grid for fas link					*
 * Params:															*
 * @flag			->	s: list all selected deals					*
 *						a: select particular deal					*
 *						u: list all selected deals in update mode	*
 * @assign_percent	->	percent assigned to deals					*
 * #effective_date	->	effective date for deals					*
 * ******************************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'[dbo].[spa_fas_link_detail]')
                    AND type in ( N'P', N'PC' ) ) 
    DROP PROCEDURE [dbo].[spa_fas_link_detail]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--header comments
CREATE PROCEDURE [dbo].[spa_fas_link_detail]
	@flag					CHAR(1),
	@assign_percent			FLOAT			= NULL,
	@effective_date			VARCHAR(10)		= NULL,
	@deal_id				VARCHAR(MAX)	= NULL,
	@source_deal_header_id	INT				= NULL,
	@reference_id			VARCHAR(50)		= NULL,
	@hedge_or_item			CHAR(1)			= NULL,
	@link_id				INT				= NULL,
	@mode					CHAR(1)			= NULL
AS
	SET NOCOUNT ON 
	DECLARE @idoc		INT
	DECLARE @sql		VARCHAR(MAX)
	DECLARE @where		VARCHAR(MAX)
	DECLARE @group_by	VARCHAR(MAX)
	DECLARE @full_sql	VARCHAR(MAX)
	DECLARE @msg		VARCHAR(500)

IF @assign_percent IS NULL
BEGIN
	SET @assign_percent = 1.0
END


DECLARE @link_deal_term_used_per VARCHAR(200),@process_id VARCHAR(150),@user_login_id VARCHAR(30)

SELECT @process_id=dbo.fnagetnewid(),@user_login_id =dbo.FNADBUser()

SET @link_deal_term_used_per = dbo.FNAProcessTableName('link_deal_term_used_per', @user_login_id, @process_id)


SET @where = ' WHERE 1=1 '
EXEC spa_print @effective_date


CREATE TABLE #temp_per_used (
	source_deal_header_id int,
	term_start date,
	used_per float
)

SET @where = ' WHERE 1=1 '
EXEC spa_print @effective_date


IF @flag = 's' -- populate all selected deals grd

BEGIN
--	DECLARE @deal_id VARCHAR(200)
--	DECLARE @effective_date VARCHAR(10)
--	DECLARE @assign_percent float
--	SET @deal_id = '136,16,7,5'
--	SET @effective_date = '2005-12-31'
--	SET @assign_percent = 0.3
	
	
	if OBJECT_ID(@link_deal_term_used_per) is not null
		exec('drop table '+@link_deal_term_used_per)
		
	exec dbo.spa_get_link_deal_term_used_per @as_of_date =@effective_date,@link_ids=@link_id,@header_deal_id =@source_deal_header_id,@term_start=null
		,@no_include_link_id =NULL,@output_type =1	,@include_gen_tranactions  = 'b',@process_table=@link_deal_term_used_per

	SET @sql = 'INSERT INTO #temp_per_used (source_deal_header_id  ,term_start,used_per )	
	SELECT source_deal_header_id,	term_start, sum(isnull(percentage_used ,1)) percentage_used from ' +@link_deal_term_used_per 
	+ ' GROUP BY source_deal_header_id,term_start	'
					
	exec(@sql)			
	

	
	SELECT 
		sdh.source_deal_header_id [Source Deal Header Id], 
		MAX(sdh.deal_id) [Reference Id],
		1-isnull(avg(tpu.used_per),0) [Percentage Included],
		 '' [Effective Date], 
		CAST(dbo.FNADateFormat(MAX(sdh.deal_date)) AS VARCHAR(10))
		+ '; ' + CAST(dbo.FNADateFormat(MAX(sdh.entire_term_start)) AS VARCHAR(10))
		+ ' : ' + CAST(dbo.FNADateFormat(MAX(sdh.entire_term_end)) AS VARCHAR(10))
		+ '; ' + CAST(dbo.FNARemoveTrailingZeroes(SUM(sdd.deal_volume)) AS VARCHAR(50))
		+ '; ' + MAX(spcd.curve_name)
		+ '.' + MAX(ssd.source_system_name)
		+ '; ' + CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' THEN 'Buy' ELSE 'Sell' END
		+ '; ' + MAX(sc.counterparty_name) [Description]
		
	FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN source_price_curve_def spcd
			ON spcd.source_curve_def_id = sdd.curve_id
		INNER JOIN source_system_description ssd
			ON ssd.source_system_id = spcd.source_system_id
		INNER JOIN source_counterparty sc
			ON sc.source_counterparty_id = sdh.counterparty_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@deal_id) deals
			ON deals.item = sdh.source_deal_header_id
		LEFT JOIN #temp_per_used tpu
			ON sdd.source_deal_header_id = tpu.source_deal_header_id	
				and sdd.term_start=tpu.term_start			
	GROUP BY sdh.source_deal_header_id

END
ELSE IF @flag = 'a'
BEGIN
	
	/************************************************
	 *			CHECK DEAL Already selected 		*
	 ************************************************/
	 
	 
	CREATE TABLE #deal_exists ( test int)
	SET @sql = '
					INSERT INTO #deal_exists 
					SELECT 1 
					FROM fas_link_detail fld
					INNER JOIN source_deal_header sdh
						ON fld.source_deal_header_id = sdh.source_deal_header_id 
					INNER JOIN source_deal_detail sdd
					ON sdh.source_deal_header_id = sdd.source_deal_header_id
					WHERE 1 = 1 
					AND fld.link_id = ' + CAST(@link_id AS VARCHAR(50))
	IF @source_deal_header_id IS NOT NULL
	BEGIN 
		SET @sql = @sql + ' AND sdh.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(50))
	END 
	
	IF @reference_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND sdh.deal_id = ''' + CAST (@reference_id AS VARCHAR(50)) + '''' 
	END
	exec spa_print @sql
	EXEC(@sql)

	IF EXISTS (SELECT * FROM #deal_exists)
	BEGIN
		Exec spa_ErrorHandler -1, 'Fas Link detail table', 
				'spa_fasLink', 'DB Error', 
				'The selected deal already exists in the link.', ''
		RETURN
	END
	DROP TABLE #deal_exists
	
	/************************************************
	 *			CHECK DEAL Already selected END		*
	 ************************************************/
	
	/************************************************
	 *			CHECK DEAL EXISTS					*
	 ************************************************/

	CREATE TABLE #deal_check ( test int)
	
	DECLARE @source_system_id INT
	
	SELECT TOP 1 @source_system_id = fs.source_system_id
	FROM fas_link_header flh
	INNER JOIN portfolio_hierarchy book ON flh.fas_book_id = book.entity_id
	INNER JOIN fas_strategy fs ON book.parent_entity_id = fs.fas_strategy_id
	WHERE flh.link_id = @link_id 
	
					
	SET @sql = '
					INSERT INTO #deal_check
					SELECT 1 FROM source_deal_header sdh
					WHERE sdh.source_system_id = ' + CAST(@source_system_id AS VARCHAR(10))
					
	IF @source_deal_header_id IS NOT NULL
	BEGIN 
		SET @sql = @sql + ' AND sdh.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(50))
	END 
	
	IF @reference_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND sdh.deal_id = ''' + CAST (@reference_id AS VARCHAR(50)) + ''''
	END
	exec spa_print @sql
	EXEC(@sql)

	IF NOT EXISTS (SELECT * FROM #deal_check)
	BEGIN
		Exec spa_ErrorHandler -1, 'Fas Link detail table', 
				'spa_fasLink', 'DB Error', 
				'The entered deal does not exist.', ''
		RETURN
	END
	DROP TABLE #deal_check

	/************************************************
	 *			CHECK DEAL EXISTS END				*
	 ************************************************/
	
	/************************************************
	 *			CHECK DEAL MAPPING					*
	 ************************************************/

	CREATE TABLE #deal_mapping ( test int)
	SET @sql =	'
					INSERT INTO #deal_mapping
					SELECT 1 
					FROM source_deal_header sdh
					INNER JOIN source_system_book_map ssb1 
						ON sdh.source_system_book_id1 = ssb1.source_system_book_id1
						AND sdh.source_system_book_id2 = ssb1.source_system_book_id2
						AND sdh.source_system_book_id3 = ssb1.source_system_book_id3
						AND sdh.source_system_book_id4 = ssb1.source_system_book_id4
					WHERE 1 = 1 
				'
	IF @source_deal_header_id IS NOT NULL
	BEGIN 
		SET @sql = @sql + ' AND sdh.source_deal_header_id = ' + CAST ( @source_deal_header_id AS VARCHAR(50) )
	END 
	
	IF @reference_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND sdh.deal_id = ''' + CAST (@reference_id AS VARCHAR(50)) + '''' 
	END
	exec spa_print @sql
	EXEC(@sql)
	
	IF NOT EXISTS (SELECT * FROM #deal_mapping)
	BEGIN
		Exec spa_ErrorHandler -1, 'Fas Link detail table', 
				'spa_fasLink', 'DB Error', 
				'You are not allowed to select a unmapped deal.', ''
		RETURN
	END
	DROP TABLE #deal_mapping
	
	/************************************************
	 *			CHECK DEAL MAPPING END				*
	 ************************************************/


	/************************************************
	 *		CHECK DEAL IS HEDGE OR ITEM				*
	 ************************************************/
	CREATE TABLE #deal_hedge_item ( test int)
	SET @sql =	'
					INSERT INTO #deal_hedge_item
					SELECT 1 
					FROM source_deal_header sdh
					INNER JOIN source_system_book_map ssb1 
						ON sdh.source_system_book_id1 = ssb1.source_system_book_id1
						AND sdh.source_system_book_id2 = ssb1.source_system_book_id2
						AND sdh.source_system_book_id3 = ssb1.source_system_book_id3
						AND  sdh.source_system_book_id4 = ssb1.source_system_book_id4
						AND isnull(sdh.fas_deal_type_value_id,ssb1.fas_deal_type_value_id) = CASE WHEN ''' + @hedge_or_item + ''' = ''h'' THEN 400 ELSE 401 END
					WHERE 1=1 
				'
	IF @source_deal_header_id IS NOT NULL
	BEGIN 
		SET @sql = @sql + ' AND sdh.source_deal_header_id = ' + CAST ( @source_deal_header_id AS VARCHAR(50) )
	END 
	
	IF @reference_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND sdh.deal_id = ''' + CAST (@reference_id AS VARCHAR(50)) + ''''
	END
	EXEC spa_print @sql
	EXEC(@sql)
	IF NOT EXISTS (SELECT * FROM #deal_hedge_item)
	BEGIN
		
		SET @msg = 'The selected deal is not a ' + CASE WHEN @hedge_or_item = 'h' THEN 'Hedge' ELSE 'Hedged Item' END + '.'
		EXEC spa_ErrorHandler -1, 'Fas Link detail table', 
				'spa_fasLink', 'DB Error', 
				@msg, ''
		RETURN
	END
	DROP TABLE #deal_hedge_item

	/************************************************
	 *		CHECK DEAL IS HEDGE OR ITEM	END			*
	 ************************************************/

	/************************************************
	 *		CHECK DEAL IS Assigned Percent			*
	 ************************************************/
		IF @reference_id IS NOT NULL
		BEGIN
			select @source_deal_header_id  = source_deal_header_id from source_deal_header where deal_id = @reference_id
		END
	

		if OBJECT_ID(@link_deal_term_used_per) is not null
				exec('drop table '+@link_deal_term_used_per)
			
		exec dbo.spa_get_link_deal_term_used_per @as_of_date =@effective_date,@link_ids=@link_id,@header_deal_id =@source_deal_header_id,@term_start=null
			,@no_include_link_id =@link_id , @output_type =1	,@include_gen_tranactions  = 'b',@process_table=@link_deal_term_used_per

		SET @sql = 'INSERT INTO #temp_per_used (source_deal_header_id  ,used_per )	
		SELECT source_deal_header_id, AVG(percentage_used) percentage_used from 
		 (
			SELECT source_deal_header_id,	term_start, sum(isnull(percentage_used,1)) percentage_used from ' +@link_deal_term_used_per + ' GROUP BY source_deal_header_id,term_start
		) p GROUP BY source_deal_header_id'
						
		exec(@sql)			
			 

		if exists (select 1 from #temp_per_used where used_per>.9988 )
		BEGIN
			
			SET @msg = 'The entered deal is fully assigned as of ' + dbo.FNADateFormat(@effective_date) + '.Please change the effective date to include the deal in relationship.'
			EXEC spa_ErrorHandler -1, 'Fas Link detail table', 
					'spa_fasLink', 'DB Error', 
					@msg, '1'
			RETURN
		END
	 
	/************************************************
	 *		CHECK DEAL IS Assigned Percent END		*
	 ************************************************/
	
	SET @sql = '	SELECT 
						MAX([Source Deal Header Id]) [Source Deal Header Id]
						, MAX([Reference Id]) [Reference Id]
						,  1 - ISNULL(MAX(tpu.used_per), 0) [Percentage Included]
						, ''' + CASE 
								WHEN @effective_date IS NULL THEN 'NULL'
								ELSE dbo.FNADateFormat(@effective_date)
							END + ''' [Effective Date]
						, MAX([Description]) [Description] 
					FROM (
						SELECT 
							sdh.source_deal_header_id [Source Deal Header Id], 
							MAX(sdh.deal_id) [Reference Id], 
							CAST(dbo.FNADateFormat(MAX(sdh.deal_date))  AS VARCHAR(50))
							+ ''; '' + CAST(dbo.FNADateFormat(MAX(sdh.entire_term_start)) AS VARCHAR(50))
							+ '' : '' + CAST(dbo.FNADateFormat(MAX(sdh.entire_term_end)) AS VARCHAR(50))
							+ ''; '' + CAST(dbo.FNARemoveTrailingZeroes(SUM(sdd.deal_volume))  AS VARCHAR(50))
							+ ''; '' + MAX(spcd.curve_name)
							+ ''.'' + MAX(ssd.source_system_name)
							+ ''; '' + CASE WHEN MAX(sdh.header_buy_sell_flag) = ''b'' THEN ''Buy'' ELSE ''Sell'' END
							+ ''; '' + CAST(MAX(sc.counterparty_name) AS VARCHAR(50)) [Description]
						FROM source_deal_header sdh 
							INNER JOIN source_deal_detail sdd
								ON sdh.source_deal_header_id = sdd.source_deal_header_id
							INNER JOIN source_price_curve_def spcd
								ON spcd.source_curve_def_id = sdd.curve_id
							INNER JOIN source_system_description ssd
								ON ssd.source_system_id = spcd.source_system_id
							INNER JOIN source_counterparty sc
								ON sc.source_counterparty_id = sdh.counterparty_id
						WHERE 1 = 1 
				'
	IF @source_deal_header_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND sdh.source_deal_header_id=' + CAST(@source_deal_header_id AS VARCHAR(50))
	END

	IF @reference_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND sdh.deal_id=''' + CAST(@reference_id AS VARCHAR) + ''''
	END	
	
	SET @sql = @sql + '	GROUP BY sdh.source_deal_header_id
						) aa
									LEFT JOIN #temp_per_used tpu
										ON aa.[Source Deal Header Id] = tpu.source_deal_header_id
							GROUP BY aa.[Source Deal Header Id]'

	
	exec spa_print @sql
	EXEC(@sql)

END
ELSE IF @flag = 'g'
BEGIN

	SELECT 
		sdh.source_deal_header_id [Source Deal Header Id], 
		MAX(sdh.deal_id) [Reference Id], 
		MAX(fld.percentage_included) [Percentage Included],
		ISNULL(dbo.FNADateFormat(MAX(fld.effective_date)), '') [Effective Date],	
		--NULL AS [Effective Date],
		CAST(MAX(dbo.FNADateFormat(sdh.deal_date))  AS VARCHAR(10))
		+ '; ' + CAST(dbo.FNADateFormat(MAX(sdh.entire_term_start)) AS VARCHAR(10))
		+ ' - ' + CAST(dbo.FNADateFormat(MAX(sdh.entire_term_end)) AS VARCHAR(10))
		+ '; ' + CAST(dbo.FNARemoveTrailingZeroes(SUM(sdd.deal_volume))  AS VARCHAR(50))
		+ '; ' + MAX(spcd.curve_name)
		+ '.' + MAX(ssd.source_system_name)
		+ '; ' + CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' THEN 'Buy' ELSE 'Sell' END
		+ '; ' + MAX(sc.counterparty_name) [Description]
	FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd
		ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN source_price_curve_def spcd
		ON spcd.source_curve_def_id = sdd.curve_id
	INNER JOIN source_system_description ssd
		ON ssd.source_system_id = spcd.source_system_id
	INNER JOIN source_counterparty sc
		ON sc.source_counterparty_id = sdh.counterparty_id
	INNER JOIN fas_link_detail fld
		ON fld.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN dbo.SplitCommaSeperatedValues(@deal_id) deals
		ON deals.item = sdh.source_deal_header_id
	WHERE fld.link_id = @link_id
	GROUP BY sdh.source_deal_header_id
END 
ELSE IF @flag = 'v'
BEGIN
	DECLARE @avl_per FLOAT
	DECLARE @used_per FLOAT
	
	if OBJECT_ID(@link_deal_term_used_per) is not null
		exec('drop table '+@link_deal_term_used_per)
	
	exec dbo.spa_get_link_deal_term_used_per @as_of_date =@effective_date,@link_ids=null,@header_deal_id =@source_deal_header_id,@term_start=null
		,@no_include_link_id =@link_id,@output_type =0	,@include_gen_tranactions  = 'b',@process_table=@link_deal_term_used_per

	SET @sql = 'INSERT INTO #temp_per_used  (term_start  ,used_per ) SELECT 	term_start, percentage_used from  ' +@link_deal_term_used_per
					
	exec(@sql)		

	declare @msg_per varchar(max)

	select @msg_per =isnull(@msg_per+'; ','') + dbo.FNADateFormat(term_start)+'='+ str((used_per+@assign_percent)*100,6,2) 
	from #temp_per_used 
	where used_per +@assign_percent>1.00002

	IF isnull(@msg_per,'') <>''
	BEGIN
		SET @msg_per='The following terms exceed 100 percentage('+@msg_per+').'
	
		EXEC spa_ErrorHandler -1, 'Fas Link', 'spa_fas_link', 'DB Error', @msg_per, @avl_per
	END 
	ELSE
		EXEC spa_ErrorHandler 0, 'Fas Link', 'spa_fas_link', 'Success', '', @avl_per
END
ELSE IF @flag = 'e'
BEGIN
	DECLARE @usd_per float
	

	if OBJECT_ID(@link_deal_term_used_per) is not null
			exec('drop table '+@link_deal_term_used_per)
		
	EXEC dbo.spa_get_link_deal_term_used_per @as_of_date =@effective_date,@link_ids=null,@header_deal_id =@source_deal_header_id,@term_start=null
		,@no_include_link_id =@link_id,@output_type =1	,@include_gen_tranactions  = 'b',@process_table=@link_deal_term_used_per

	SET @sql = 'INSERT INTO #temp_per_used (source_deal_header_id  ,used_per )	
	SELECT source_deal_header_id, AVG(percentage_used) percentage_used from 
	 (
		SELECT source_deal_header_id,	term_start, sum(isnull(percentage_used,1)) percentage_used from ' +@link_deal_term_used_per + ' GROUP BY source_deal_header_id,term_start
	) p GROUP BY source_deal_header_id'
					
	EXEC(@sql)				
	
	
	
	--IF @mode = 'u'
	--BEGIN
	--	SELECT @usd_per = CAST(percentage_included AS NUMERIC(6,5))
	--	  FROM fas_link_detail WHERE link_id = @link_id AND source_deal_header_id = @source_deal_header_id 
	--	--SET @avl_per = @avl_per + @used_per
	--END
	
	SELECT	dbo.FNARemoveTrailingZero(1 - used_per) [Available Percentage], dbo.FNADateFormat(@effective_date) [Effective Date] 
	FROM	#temp_per_used
	WHERE	source_deal_header_id = @source_deal_header_id
END