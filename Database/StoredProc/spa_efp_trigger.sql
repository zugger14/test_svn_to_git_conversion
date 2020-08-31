IF OBJECT_ID(N'[dbo].[spa_efp_trigger]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_efp_trigger]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**  
	Procedure to process EFP deals
	
	Parameters
	
	@flag			 : Operation flag that decides the action to be performed. Does not accept NULL.
    @detail_id 		 : Identity of Source Deal Detail table
    @floating_volume : Deal volume of Deal
    @fixed_price 	 : Fixed Price of Deal Detail
    @post_date 		 : Deal date 
    @deal_id 		 : Identity of Source Deal Header table
*/

CREATE PROCEDURE [dbo].[spa_efp_trigger]
    @flag NCHAR(1),
    @detail_id INT = NULL,
    @floating_volume NUMERIC(38,20) = NULL,
    @fixed_price NUMERIC(38, 20) = NULL,
    @post_date DATETIME = NULL,
    @deal_id INT = NULL
        
AS
SET NOCOUNT ON

DECLARE @sql NVARCHAR(MAX)
DECLARE @desc NVARCHAR(500)
 
IF @flag IN ('e', 't') 
BEGIN
    SELECT sdd.term_start,
           sdd.term_end,
           sdd.Leg,
           GETDATE() [post_date],
           CASE WHEN @flag = 'e' THEN 'Post' ELSE 'Trigger' END [type],
           dbo.FNARemoveTrailingZero(sdd.fixed_price) [price],
           dbo.FNARemoveTrailingZero((sdd.deal_volume - ISNULL(vol.volume, 0))) [floating_volume],
           su.uom_name [uom]
    FROM   source_deal_detail sdd
    LEFT JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
    OUTER APPLY (
    	SELECT SUM(sdd.deal_volume) [volume] 
    	FROM source_deal_header sdh
    	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
    	WHERE sdh.reference_detail_id = @detail_id
    ) vol
    WHERE sdd.source_deal_detail_id = @detail_id    
END
IF @flag IN ('g', 'h') 
BEGIN
	DECLARE @deal_type INT
	SELECT @deal_type = source_deal_type_id
	FROM source_deal_type 
	WHERE source_deal_type_name = CASE WHEN @flag = 'g' THEN 'Swap' ELSE 'Future' END 
	AND sub_type = 'n'
	
	SET @sql = 'SELECT dbo.FNATRMWinHyperlink(''i'', 10131010, sdh.source_deal_header_id, sdh.source_deal_header_id, ''n'', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 1) [deal_id], ' + CHAR(10)
			 + '           dbo.FNADateFormat(sdd.term_start) [term_start], ' + CHAR(10)
			 + '           dbo.FNADateFormat(sdd.term_end) [term_end], ' + CHAR(10)
			 + '           dbo.FNADateFormat(sdh.deal_date) [post_date], ' + CHAR(10)
			 + '           spcd.curve_name [index], ' + CHAR(10)
			 + CASE WHEN @flag = 'h' THEN + 'dbo.FNARemoveTrailingZero(sdd.price_adder) [adder_discount], ' ELSE '' END + CHAR(10)
			 + '           dbo.FNARemoveTrailingZero(sdd.total_volume) [volume], ' + CHAR(10)
			 + '           dbo.FNARemoveTrailingZero(sdd.fixed_price) [post_price] ' + CHAR(10)
			 + '    FROM source_deal_header sdh ' + CHAR(10)
			 + '    INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id ' + CHAR(10)
			 + '    INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id ' + CHAR(10)
			 + '    INNER JOIN ( ' + CHAR(10)
			 + '    	SELECT source_deal_detail_id FROM source_deal_detail sdd1 WHERE sdd1.source_deal_header_id = ' + CAST(@deal_id AS NVARCHAR(20)) + ' ' + CHAR(10)			 
			 + '    ) ref ON sdh.reference_detail_id = ref.source_deal_detail_id ' + CHAR(10)
			 + ' WHERE sdh.source_deal_type_id = ' + CAST(@deal_type AS NVARCHAR(20)) + ' ' + CHAR(10)	
			 +	CASE WHEN @detail_id IS NOT NULL THEN + ' AND sdh.reference_detail_id = ' + CAST(@detail_id AS NVARCHAR(20)) ELSE '' END + CHAR(10)
	exec spa_print @sql
	EXEC(@sql)
END
IF @flag IN ('m', 'n')
BEGIN
	DECLARE @template_id				INT 
			, @deal_prefix				NVARCHAR(50) 
			, @deal_type_name			NVARCHAR(50)
			, @new_source_deal_id		INT  
			, @ref_id					NVARCHAR(50)				
			, @err_msg					NVARCHAR(50)
			, @available_volume			NUMERIC(38, 20)
			, @source_deal_header_id	INT
			
	SELECT @template_id = ddpv.template_id
		 , @deal_prefix = ISNULL(drip.prefix, '')
		 , @source_deal_header_id = sdh.source_deal_header_id
		 , @deal_type_name = sdt.source_deal_type_name
	FROM  source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN default_deal_post_values ddpv 
		ON (ddpv.counterparty_id = sdh.counterparty_id OR ddpv.counterparty_id IS NULL)
		AND (ddpv.trader_id = sdh.trader_id OR ddpv.trader_id IS NULL)
		AND (ddpv.broker_id = sdh.broker_id OR ddpv.broker_id IS NULL)
		AND (ddpv.deal_type_id = sdh.source_deal_type_id OR ddpv.deal_type_id IS NULL)
		AND (ddpv.deal_sub_type_id = sdh.deal_sub_type_type_id OR ddpv.deal_sub_type_id IS NULL)
		AND (ddpv.internal_deal_type_subtype_id = sdh.internal_deal_type_value_id OR ddpv.internal_deal_type_subtype_id IS NULL)
		AND COALESCE(ddpv.counterparty_id, ddpv.trader_id, ddpv.broker_id, ddpv.deal_type_id, ddpv.deal_sub_type_id, ddpv.internal_deal_type_subtype_id, -1) <> -1
	INNER JOIN source_deal_header_template sdht ON sdht.template_id = ddpv.template_id
	INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdht.source_deal_type_id
	LEFT JOIN deal_reference_id_prefix drip ON drip.deal_type = sdht.source_deal_type_id
	WHERE sdd.source_deal_detail_id = @detail_id

	SELECT @available_volume = dbo.FNARemoveTrailingZero((sdd.deal_volume - ISNULL(vol.volume, 0)))
	FROM source_deal_detail sdd
	OUTER APPLY (
    	SELECT SUM(sdd.deal_volume) [volume] 
    	FROM source_deal_header sdh
    	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
    	WHERE sdh.reference_detail_id = @detail_id
    ) vol
    WHERE sdd.source_deal_detail_id = @detail_id
		
    IF @template_id IS NULL
    BEGIN      
		SET @err_msg = 'Incomplete setup.'      
		EXEC spa_ErrorHandler -1, @err_msg, 
			 'spa_efp_trigger', 'DB Error',  
			 @err_msg, ''  
          
		RETURN		
    END
    
	IF @available_volume = 0	
	BEGIN
		EXEC spa_ErrorHandler -1,
		     'Deal already posted.',
		     'spa_efp_trigger',
		     'DB Error',
		     'Deal already posted.',
		     '' 
		RETURN			 
	END
	ELSE IF ISNULL(@floating_volume, 0) > @available_volume
	BEGIN
		EXEC spa_ErrorHandler -1,
		     'Insufficient volume available.',
		     'spa_efp_trigger',
		     'DB Error',
		     'Insufficient volume available.',
		     ''
		RETURN		
	END

	--Create post/trigger deal      
	BEGIN TRAN 
	BEGIN TRY		  
		SET  @ref_id = dbo.FNAGetNewID()
		
		IF OBJECT_ID('#tempdb..#temp_sdh_post') IS NOT NULL
		 	DROP TABLE #temp_sdh_post
		IF OBJECT_ID('#tempdb..#temp_sdg_post') IS NOT NULL
		 	DROP TABLE #temp_sdg_post
		
		CREATE TABLE #temp_sdh_post (source_deal_header_id INT)
		CREATE TABLE #temp_sdg_post (source_deal_group_id INT)
		
		INSERT INTO [source_deal_header] (
		    [source_system_id],
		    [deal_id],
		    [deal_date],
		    [physical_financial_flag],
		    [counterparty_id],
		    [entire_term_start],
		    [entire_term_end],
		    [header_buy_sell_flag],
		    [source_deal_type_id],
		    [deal_sub_type_type_id],
		    [option_flag],
		    [option_type],
		    [source_system_book_id1],
		    [source_system_book_id2],
		    [source_system_book_id3],
		    [source_system_book_id4],
		    [description1],
		    [description2],
		    [description3],
		    [deal_category_value_id],
		    [trader_id],
		    [internal_deal_type_value_id],
		    [internal_deal_subtype_value_id],
		    [template_id],
		    broker_id,
		    [create_user],
		    [create_ts],
		    [update_user],
		    [update_ts],
		    contract_id,
		    deal_reference_type_id,
		    [reference_detail_id],
		    [deal_status],
		    [confirm_status_type],
		    product_id,
		    commodity_id,
			term_frequency
		)
		OUTPUT INSERTED.source_deal_header_id INTO #temp_sdh_post(source_deal_header_id)	    
		SELECT 2,
		       @ref_id,
		       @post_date,
		       t.physical_financial_flag,
		       sdh.counterparty_id,
		       sdd.term_start,
		       sdd.term_end,
		       CASE WHEN @flag = 'n' THEN sdh.header_buy_sell_flag 
					ELSE CASE 
						WHEN sdh.header_buy_sell_flag = 'b' THEN 's'
						ELSE 'b'
						END
		       END,
		       t.source_deal_type_id,
		       t.deal_sub_type_type_id,
		       t.option_flag,
		       t.option_type,
		       sdh.source_system_book_id1,
		       sdh.source_system_book_id2,
		       sdh.source_system_book_id3,
		       sdh.source_system_book_id4,
		       t.description1,
		       t.description2,
		       t.description3,
		       ISNULL(t.deal_category_value_id, 475),
		       sdh.trader_id,
		       t.internal_deal_type_value_id,
		       t.internal_deal_subtype_value_id,
		       @template_id,
		       t.broker_id,
		       dbo.fnadbuser(),
		       GETDATE(),
		       dbo.fnadbuser(),
		       GETDATE(),
		       t.contract_id,
		       12505,
		       @detail_id,
		       ISNULL(t.deal_status, 5604),
		       ISNULL(t.[confirm_status_type], 17200),
		       CASE @flag
		            WHEN 'n' THEN 4100
		            ELSE t.product_id
		       END,
		       t.commodity_id,
			   t.term_frequency_type
		FROM   [dbo].[source_deal_header_template] t
		INNER JOIN source_deal_header sdh ON  sdh.source_deal_header_id = @source_deal_header_id
		INNER JOIN source_deal_detail sdd 
			ON  sdd.source_deal_header_id = sdh.source_deal_header_id
			AND sdd.source_deal_detail_id = @detail_id
		WHERE t.template_id = @template_id
		
		UPDATE sdh 
		SET deal_id = @deal_prefix  + CASE WHEN @flag = 'n' THEN 'TRG_' ELSE 'POST_' END + CAST(@source_deal_header_id AS NVARCHAR(20)) + '_' + CAST(temp.source_deal_header_id AS NVARCHAR(10))
		FROM source_deal_header sdh
		INNER JOIN #temp_sdh_post temp ON temp.source_deal_header_id = sdh.source_deal_header_id   
      
		INSERT INTO source_deal_groups (
			source_deal_header_id,
			term_from,
			term_to,
			detail_flag,
			location_id,
			curve_id,
			leg
		)
		OUTPUT INSERTED.source_deal_groups_id INTO #temp_sdg_post(source_deal_group_id)
		SELECT temp.source_deal_header_id, sdd.term_start, sdd.term_end, 0, ISNULL(sddt.location_id, sdd.location_id), ISNULL(sddt.curve_id, sdd.curve_id), sdd.Leg
		FROM #temp_sdh_post temp
		INNER JOIN source_deal_detail sdd ON  sdd.source_deal_detail_id = @detail_id
		INNER JOIN source_deal_detail_template sddt 
			ON sddt.template_id = @template_id
			AND sddt.leg = sdd.Leg
			
		--insert in detail detail
		INSERT INTO [dbo].[source_deal_detail] (
		    [source_deal_header_id],
		    [term_start],
		    [term_end],
		    [Leg],
		    [contract_expiration_date],
		    [fixed_float_leg],
		    [buy_sell_flag],
		    [curve_id],
		    [fixed_price],
		    [fixed_price_currency_id],
		    [deal_volume],
		    [deal_volume_frequency],
		    [deal_volume_uom_id],
		    [block_description],
		    [location_id],
		    [physical_financial_flag],
		    process_deal_status,
		    price_uom_id,
		    category,
		    pv_party,
		    profile_code,
		    formula_id,
		    formula_curve_id,
		    multiplier,
		    volume_multiplier2,
		    source_deal_group_id,
			detail_commodity_id,
			position_uom
		  )   
		 SELECT sdh.source_deal_header_id
				, sdd.term_start      
				, sdd.term_end      
				, td.leg      
				, sdd.term_end      
				, td.fixed_float_leg      
				, CASE WHEN @flag = 'n' THEN sdd.buy_sell_flag
					ELSE CASE 
						WHEN sdd.buy_sell_flag = 'b' THEN 's'
						ELSE 'b'
						END
		         END
				,sdd.formula_curve_id
				, @fixed_price      
				, td.fixed_price_currency_id
				, @floating_volume    
				, sdd.deal_volume_frequency --td.deal_volume_frequency      
				, sdd.deal_volume_uom_id	-- td.[deal_volume_uom_id]      
				, td.block_description
				, td.location_id      
				, td.physical_financial_flag
				, 12505			--EFP_Trigger value id
				, td.price_uom_id
				, td.category
				, td.pv_party
				, td.profile_code  
				, sdd.formula_id  
				, CASE @flag WHEN 'n' THEN sdd.formula_curve_id  ELSE  NULL END
				, sdd.multiplier
				, sdd.volume_multiplier2
				, sdg.source_deal_group_id
				, sdd.detail_commodity_id
				, sdd.position_uom
		FROM [dbo].[source_deal_detail_template] td       
		INNER JOIN source_deal_detail sdd  
			ON  sdd.source_deal_detail_id = @detail_id 
			AND sdd.Leg = td.leg
		OUTER APPLY (SELECT source_deal_header_id FROM #temp_sdh_post) sdh 
		OUTER APPLY (SELECT source_deal_group_id FROM #temp_sdg_post) sdg   
		WHERE td.template_id = @template_id 
	
		--Update source deal detail fields
		UPDATE source_deal_detail 
		SET   fixed_price = CASE WHEN @flag = 'm' THEN @fixed_price ELSE fixed_price END		
			, formula_curve_id = CASE WHEN @flag = 'm' THEN NULL ELSE formula_curve_id END	 
		WHERE source_deal_detail_id = @detail_id
      
		--insert in udf fields. Note currently no udf fields defined for efp/trigger post deal. Need to modify later.
		--inserts hidden header udf
		INSERT INTO [dbo].[user_defined_deal_fields] (
			[source_deal_header_id],
			udf.udf_template_id,
			[udf_value]
		)
		SELECT temp.source_deal_header_id,
				uddft.udf_template_id,
				NULLIF(CAST(ISNULL(uddft.default_value, udft.default_value) AS NVARCHAR(100)), '')
		FROM #temp_sdh_post temp
		INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = @template_id
		INNER JOIN user_defined_fields_template udft ON uddft.field_name = udft.field_name
		LEFT JOIN user_defined_deal_fields uddf
			ON  uddft.udf_template_id = uddf.udf_template_id
		WHERE udft.udf_type = 'h'
		AND uddf.udf_template_id IS NULL
		AND uddf.source_deal_header_id = temp.source_deal_header_id
		
		--udf detail
		INSERT INTO [dbo].user_defined_deal_detail_fields (
			source_deal_detail_id,
			udf_template_id,
			[udf_value]
		)
		SELECT  sdd.source_deal_detail_id,
				uddft.udf_template_id,
				uddft.default_value
		FROM #temp_sdh_post temp
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = temp.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = @template_id AND uddft.leg = sdd.leg
		INNER JOIN user_defined_fields_template udft
			ON  uddft.udf_user_field_id = udft.udf_template_id
		LEFT JOIN user_defined_deal_detail_fields udddf
			ON  uddft.udf_template_id = udddf.udf_template_id
		WHERE  udddf.udf_template_id IS NULL
		AND udft.udf_type = 'd'
		AND udddf.source_deal_detail_id = sdd.source_deal_detail_id
		
		-- update fixed_price on original deal
		--IF @flag = 'm'
		--BEGIN
		--	UPDATE source_deal_detail
		--	SET fixed_price = @fixed_price
		--		,formula_curve_id = NULL
		--	WHERE source_deal_detail_id = @detail_id
		--END

		-- update audit info
		UPDATE sdh
		SET create_ts = GETDATE(),
			create_user = dbo.FNADBUser(),
			update_user = NULL,
			update_ts = NULL
		FROM source_deal_header sdh
		INNER JOIN #temp_sdh_post th ON sdh.source_deal_header_id = th.source_deal_header_id
			
		UPDATE sdd
		SET create_ts = GETDATE(),
			create_user = dbo.FNADBUser(),
			update_user = NULL,
			update_ts = NULL
		FROM source_deal_detail sdd
		INNER JOIN #temp_sdh_post th ON sdd.source_deal_header_id = th.source_deal_header_id
		
		SET @desc = 'Successfully ' + CASE WHEN @flag = 'n' THEN  'triggered.' ELSE 'posted.' END
		DECLARE @new_id INT 
		SELECT @new_id = source_deal_header_id FROM #temp_sdh_post

		INSERT INTO #temp_sdh_post (source_deal_header_id)
		SELECT source_deal_header_id 
		FROM source_deal_detail
		WHERE source_deal_detail_id = @detail_id
 
		COMMIT TRAN
		
		EXEC spa_ErrorHandler 0,
		     'source_deal_header',
		     'spa_efp_trigger',
		     'Success',
		     @desc,
		     @new_id      
		
		DECLARE @after_insert_process_table     NVARCHAR(300),
		        @job_name						NVARCHAR(200),
		        @user_name						NVARCHAR(200) = dbo.FNADBUser(),
		        @job_process_id					NVARCHAR(200) = dbo.FNAGETNEWID()
		SET @after_insert_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)
			
		IF OBJECT_ID(@after_insert_process_table) IS NOT NULL
		BEGIN
			EXEC('DROP TABLE ' + @after_insert_process_table)
		END
				
		EXEC ('CREATE TABLE ' + @after_insert_process_table + '(source_deal_header_id INT)')

		SET @sql = 'INSERT INTO ' + @after_insert_process_table + '(source_deal_header_id) 
					SELECT source_deal_header_id FROM #temp_sdh_post'
		EXEC(@sql)
			
		SET @sql = 'spa_deal_insert_update_jobs ''i'', ''' + @after_insert_process_table + ''''
		SET @job_name = 'spa_deal_insert_update_jobs_' + @job_process_id 		
		EXEC spa_run_sp_as_job @job_name, @sql, 'spa_deal_insert_update_jobs', @user_name
	END TRY
	BEGIN CATCH
		DECLARE @err_no INT
 
		IF @@TRANCOUNT > 0
			ROLLBACK
 
		SELECT @err_no = ERROR_NUMBER()
 
		SET @desc = 'Fail to ' + CASE WHEN @flag = 'n' THEN  'trigger ' ELSE ' post' END + ' ( Errr Description:' + ERROR_MESSAGE() + ').'
  
		EXEC spa_ErrorHandler @err_no
			, 'spa_insert_blotter_deal'
			, 'spa_insert_blotter_deal'
			, 'Error'
			, @desc
			, ''
	END CATCH
END
