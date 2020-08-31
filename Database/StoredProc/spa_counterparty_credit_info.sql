-- =============================================================================================================================
-- Author: lhnepal@pioneersolutionsglobal.com
-- Create date: 2016-01-05
-- Description: Generic SP to insert/update values in the table counterparty_credit_info
 
-- Params:
-- @flag CHAR(1)        -  flag 
--						- 'i' - Insert Data 
--						- 'd' - delete data
-- @xml  VARCHAR(MAX) - @xml string of the Data to be inserted/updated

-- Sample Use = EXEC spa_counterparty_credit_info 'i',''<Root><PSRecordset user_login_id="test_test" user_pwd="asdasdasd" user_f_name="asd" user_m_name="asd" user_l_name="asd" user_title="asd" entity_id="300797" user_address1="asd" user_address2="asd" state_value_id="300797" user_off_tel="asd" user_main_tel="asd" user_pager_tel="asd" user_mobile_tel="asd" user_emal_add="asd" region_id="1" user_active="0" reports_to="" timezone_id=""  ></PSRecordset></Root>'
-- =============================================================================================================================
IF OBJECT_ID('[dbo].[spa_counterparty_credit_info]','p') IS NOT NULL
DROP PROC [dbo].[spa_counterparty_credit_info]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_counterparty_credit_info]
		@flag AS CHAR(1),
		@xml VARCHAR(MAX) = NULL,
		@counterparty_credit_info_id INT = NULL,
		@Counterparty_id INT = NULL,
		@cva_data INT = NULL
		
AS
SET NOCOUNT ON
DECLARE @sql VARCHAR(MAX), @idoc INT
DECLARE @status_pre INT,@credit_limit_pre FLOAT,@watch_list_pre CHAR(1),@counterparty_name NVARCHAR(1000), @debt_rating_pre VARCHAR(100)
DECLARE @risk_control_id INT
DECLARE @as_of_date DATETIME
DECLARE @message VARCHAR(500)
DECLARE @comp_function_id INT
SET @risk_control_id=20 ---- Credit file change risk control id
SET @as_of_date=getDate()

IF @flag='i'
BEGIN TRY
	BEGIN TRAN
	DECLARE @currency_id INT
	
	SELECT @currency_id = sc.source_currency_id
	FROM source_currency sc
	WHERE sc.currency_name = 'USD'

	INSERT INTO counterparty_credit_info(Counterparty_id, curreny_code)
	VALUES(@Counterparty_id, @currency_id)

	SET @counterparty_credit_info_id = SCOPE_IDENTITY()
	-- inserting into static_data_type (Counterparty Debt Rating) for CVA Data: Counterparty Default Values[7].
	IF @cva_data = 7 OR @cva_data = 8
	BEGIN
		IF NOT EXISTS (
			SELECT sdv.value_id
			FROM static_data_value sdv	
			INNER JOIN source_counterparty sc ON sdv.code = sc.counterparty_id AND sc.source_counterparty_id = @Counterparty_id
			WHERE sdv.[type_id] = 23000
		)
		BEGIN
			INSERT INTO static_data_value
			(
				[type_id],
				code,
				[description]
			)
			SELECT 
				23000
				, sc.counterparty_name
				, sc.counterparty_desc
			FROM source_counterparty sc WHERE sc.source_counterparty_id = @Counterparty_id
		END
	END	
	
	COMMIT				
	END TRY
	BEGIN CATCH
		ROLLBACK
		EXEC spa_ErrorHandler -1, 'Counterparty Credit Info', 
				'spa_counterparty_credit_info', 'DB Error', 
				'Insetion  of counterparty_credit_info failed.', ''
	END CATCH
ELSE IF @flag='u'
BEGIN TRY	
	SELECT 
		@status_pre=account_status,
		@watch_list_pre=Watch_list,
		@counterparty_name=sc.counterparty_name,
		@debt_rating_pre = sdv.code
	FROM
		counterparty_credit_info cci
		LEFT JOIN source_counterparty sc on sc.source_counterparty_id=cci.counterparty_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = cci.Debt_rating
	WHERE 
		counterparty_credit_info_id=@counterparty_credit_info_id	

	--start xml
	BEGIN TRAN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

	IF OBJECT_ID('tempdb..#temp_counterparty_credit_info') IS NOT NULL
		DROP TABLE #temp_counterparty_credit_info
	SELECT
		NULLIF(Counterparty_id,'') AS Counterparty_id,
		NULLIF(account_status,'') AS account_status,
		limit_expiration,
		credit_limit,
		NULLIF(curreny_code,'') AS curreny_code,
		Tenor_limit,
		NULLIF(Industry_type1,'') AS Industry_type1,
		NULLIF(Industry_type2,'') AS Industry_type2,
		NULLIF(SIC_Code,'') AS SIC_Code,
		Duns_No,
		NULLIF(Risk_rating,'') AS Risk_rating,
		NULLIF(Debt_rating,'') AS Debt_rating,
		Ticker_symbol,
		Date_established,
		Next_review_date,
		Last_review_date,
		Customer_since,
		NULLIF(Approved_by,'') AS Approved_by,
		NULLIF(analyst,'') AS analyst,
		NULLIF(rating_outlook,'') AS rating_outlook,
		NULLIF(qualitative_rating,'') AS qualitative_rating,
		NULLIF(formula,'') AS formula,
		Watch_list,
		Settlement_contact_name,
		Settlement_contact_address,
		Settlement_contact_address2,
		Settlement_contact_phone,
		Settlement_contact_email,
		payment_contact_name,
		payment_contact_address,
		contactfax,
		payment_contact_phone,
		payment_contact_email,
		Debt_Rating2,
		Debt_Rating3,
		Debt_Rating4,
		Debt_Rating5,
		credit_limit_from,
		max_threshold,
		min_threshold,
		check_apply,
		cva_data,
		pfe_criteria,
		NULLIF(exclude_exposure_after,'') AS exclude_exposure_after,
		NULLIF(buy_notional_month,'') AS buy_notional_month,
		NULLIF(sell_notional_month,'') AS sell_notional_month
		INTO #temp_counterparty_credit_info
	FROM OPENXML(@idoc, '/Root/FormXML', 1)
	WITH (
		Counterparty_id INT,
		account_status INT,
		limit_expiration DATETIME,
		credit_limit FLOAT,
		curreny_code INT,
		Tenor_limit INT,
		Industry_type1 INT,
		Industry_type2 INT,
		SIC_Code INT,
		Duns_No VARCHAR(100),
		Risk_rating INT,
		Debt_rating INT,
		Ticker_symbol VARCHAR(100),
		Date_established DATETIME,
		Next_review_date DATETIME,
		Last_review_date DATETIME,
		Customer_since DATETIME,
		Approved_by VARCHAR(50),
		analyst VARCHAR(100),
		rating_outlook INT,
		qualitative_rating INT,
		formula INT,
		Watch_list CHAR(1),
		Settlement_contact_name VARCHAR(100),
		Settlement_contact_address  VARCHAR(100),
		Settlement_contact_address2  VARCHAR(100),
		Settlement_contact_phone  VARCHAR(10),
		Settlement_contact_email  VARCHAR(50),
		payment_contact_name  VARCHAR(100),
		payment_contact_address  VARCHAR(100),
		contactfax  VARCHAR(100),
		payment_contact_phone  VARCHAR(10),
		payment_contact_email  VARCHAR(50),
		Debt_Rating2 INT,
		Debt_Rating3 INT,
		Debt_Rating4 INT,
		Debt_Rating5 INT,
		credit_limit_from FLOAT,
		max_threshold FLOAT,
		min_threshold FLOAT,
		check_apply CHAR(1),
		cva_data INT,
		pfe_criteria INT,
		exclude_exposure_after INT,
		buy_notional_month FLOAT,
		sell_notional_month FLOAT
	)
	UPDATE c
	SET Counterparty_id = t.Counterparty_id,
		account_status = t.account_status,
		limit_expiration = cast(NULLIF(t.limit_expiration, '') AS DATE),
		credit_limit = t.credit_limit,
		curreny_code = t.curreny_code,
		Tenor_limit = t.Tenor_limit,
		Industry_type1 = t.Industry_type1,
		Industry_type2 = t.Industry_type2,
		SIC_Code = t.SIC_Code,
		Duns_No = NULLIF(t.Duns_No, ''),
		Risk_rating = t.Risk_rating,
		Debt_rating = t.Debt_rating,
		Ticker_symbol = t.Ticker_symbol,
		Date_established = cast(NULLIF(t.Date_established, '') AS DATE),
		Next_review_date = cast(NULLIF(t.Next_review_date, '') AS DATE),
		Last_review_date = cast(NULLIF(t.Last_review_date, '') AS DATE),
		Customer_since = cast(NULLIF(t.Customer_since, '') AS DATE),
		Approved_by = t.Approved_by,
		analyst = t.analyst,
		rating_outlook = t.rating_outlook,
		qualitative_rating = t.qualitative_rating,
		formula=  t.formula,
		Watch_list = t.Watch_list,
		Settlement_contact_name = t.Settlement_contact_name,
		Settlement_contact_address = t.Settlement_contact_address,
		Settlement_contact_address2 = t.Settlement_contact_address2,
		Settlement_contact_phone = t.Settlement_contact_phone,
		Settlement_contact_email = t.Settlement_contact_email,
		payment_contact_name = t.payment_contact_name,
		payment_contact_address  = t.payment_contact_address,
		contactfax = t.contactfax,
		payment_contact_phone = t.payment_contact_phone,
		payment_contact_email = t.payment_contact_email,
		Debt_Rating2 = t.Debt_Rating2,
		Debt_Rating3 = t.Debt_Rating3,
		Debt_Rating4 = t.Debt_Rating4,
		Debt_Rating5 = t.Debt_Rating5,
		credit_limit_from = t.credit_limit_from,
		max_threshold = t.max_threshold,
		min_threshold = t.min_threshold,
		check_apply = t.check_apply,
		cva_data = t.cva_data,
		pfe_criteria = t.pfe_criteria,
		exclude_exposure_after = t.exclude_exposure_after,
		buy_notional_month = t.buy_notional_month,
		sell_notional_month = t.sell_notional_month
	FROM #temp_counterparty_credit_info AS t
	INNER JOIN counterparty_credit_info c ON c.Counterparty_id=t.Counterparty_id

	SELECT @cva_data = t.cva_data FROM #temp_counterparty_credit_info AS t
	SELECT @counterparty_id = t.counterparty_id FROM #temp_counterparty_credit_info AS t
	--end xml

	-- inserting into static_data_type (Counterparty Debt Rating) for CVA Data: Counterparty Default Values[7].
	IF @cva_data = 7 OR @cva_data = 8
	BEGIN
		IF NOT EXISTS (
			SELECT sdv.value_id
			FROM static_data_value sdv	
			INNER JOIN source_counterparty sc ON sdv.code = sc.counterparty_id AND sc.source_counterparty_id = @Counterparty_id
			WHERE sdv.[type_id] = 23000
		)
		BEGIN
			INSERT INTO static_data_value
			(
				[type_id],
				code,
				[description]
			)
			SELECT 
				23000
				, sc.counterparty_name
				, sc.counterparty_desc
			FROM source_counterparty sc WHERE sc.source_counterparty_id = @Counterparty_id
		END
	END	
	
	-- Save Nettings Grid Start
	CREATE TABLE #credit_netting (
		netting_group_id INT,
		netting_parent_group_id INT,
		netting_group_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		effective_date DATE,
		end_date DATE,
		source_deal_type_id INT,
		source_deal_sub_type_id INT,
		source_commodity_id INT,
		physical_financial_flag CHAR(1) COLLATE DATABASE_DEFAULT,
		hedge_type_value_id INT,
		internal_counterparty INT,
		contract_id VARCHAR(4000) COLLATE DATABASE_DEFAULT
	)
	CREATE TABLE #credit_netting_delete (
		netting_group_id INT
	)
	
	INSERT INTO #credit_netting (
				netting_group_id,
				netting_parent_group_id,
				netting_group_name,
				effective_date,
				end_date,
				source_deal_type_id,
				source_deal_sub_type_id,
				source_commodity_id,
				physical_financial_flag,
				hedge_type_value_id,
				internal_counterparty,
				contract_id
	)
	SELECT 
				NULLIF(netting_group_id, ''),
				NULLIF(netting_parent_group_id, ''),
				NULLIF(netting_group_name, ''),
				NULLIF(effective_date, ''),
				NULLIF(end_date, ''),
				NULLIF(source_deal_type_id, ''),
				NULLIF(source_deal_sub_type_id, ''),
				NULLIF(source_commodity_id, ''),
				NULLIF(physical_financial_flag, ''),
				NULLIF(hedge_type_value_id, ''),
				NULLIF(internal_counterparty, ''),
				NULLIF(contract_id, '')
	FROM   OPENXML (@idoc, '/Root/GridGroup/Grid/GridRow', 2)
		WITH ( 
			netting_group_id				VARCHAR(20)	 '@netting_group_id'
			,netting_parent_group_id		VARCHAR(20)	 '@netting_parent_group_id'
			,netting_group_name				VARCHAR(20)	 '@netting_group_name'
			,effective_date					VARCHAR(50)	 '@effective_date'
			,end_date						VARCHAR(50)	 '@end_date'
			,source_deal_type_id			VARCHAR(50)	 '@source_deal_type_id'
			,source_deal_sub_type_id		VARCHAR(50)	 '@source_deal_sub_type_id'
			,source_commodity_id			VARCHAR(50)	 '@source_commodity_id'
			,physical_financial_flag		VARCHAR(50)	 '@physical_financial_flag'
			,hedge_type_value_id			VARCHAR(50)	 '@hedge_type_value_id'
			,internal_counterparty			VARCHAR(50)	 '@internal_counterparty'
			,contract_id					VARCHAR(50)	 '@contract_id'
			,grid_id						VARCHAR(50)  '../@grid_id'
		)x
	WHERE x.grid_id = 'netting_group'

	INSERT INTO #credit_netting_delete (
				netting_group_id
	)
	SELECT 
		NULLIF(netting_group_id,'')
	FROM   OPENXML (@idoc, '/Root/GridGroup/GridDelete/GridRow', 2)
		WITH ( 
			netting_group_id	VARCHAR(20)	 '@netting_group_id'
			,grid_id					VARCHAR(50)  '../@grid_id'
		)x
	WHERE x.grid_id = 'netting_group'

	UPDATE ng
		SET  ng.netting_parent_group_id	= cn.netting_parent_group_id
			,ng.netting_group_name		= cn.netting_group_name		
			,ng.effective_date			= cn.effective_date			
			,ng.end_date				= cn.end_date				
			--,ng.source_deal_type_id		= cn.source_deal_type_id	
			--,ng.source_deal_sub_type_id	= cn.source_deal_sub_type_id
			--,ng.source_commodity_id		= cn.source_commodity_id	
			--,ng.physical_financial_flag	= cn.physical_financial_flag
			--,ng.hedge_type_value_id		= cn.hedge_type_value_id	
			--,ng.internal_counterparty	= cn.internal_counterparty	
	FROM #credit_netting cn
	INNER JOIN netting_group ng ON cn.netting_group_id = ng.netting_group_id
	WHERE cn.netting_group_id IS NOT NULL

	DELETE ngdc
	FROM netting_group_detail_contract ngdc
	LEFT JOIN netting_group_detail ngd ON ngd.netting_group_detail_id = ngdc.netting_group_detail_id
	INNER JOIN #credit_netting cn ON cn.netting_group_id = ngd.netting_group_id

	INSERT INTO netting_group_detail_contract(netting_group_detail_id, source_contract_id)
	SELECT ngd.netting_group_detail_id, s.item
	FROM #credit_netting cn
	INNER JOIN netting_group_detail ngd ON ngd.netting_group_id = cn.netting_group_id
	OUTER APPLY dbo.SplitCommaSeperatedValues(cn.contract_id) s

	DELETE FROM #credit_netting WHERE netting_group_id IS NOT NULL 
	
	DELETE ngdc
	FROM netting_group_detail_contract ngdc 
	LEFT JOIN netting_group_detail ngd ON  ngd.netting_group_detail_id = ngdc.netting_group_detail_id 
	LEFT JOIN netting_group ng ON ng.netting_group_id = ngd.netting_group_id
	INNER JOIN #credit_netting_delete cnd ON cnd.netting_group_id = ng.netting_group_id		  
	
	DELETE ngd
	FROM netting_group_detail ngd
	LEFT JOIN netting_group ng ON ng.netting_group_id = ngd.netting_group_id
	INNER JOIN #credit_netting_delete cnd ON cnd.netting_group_id = ng.netting_group_id
	

	DELETE ng
	FROM netting_group ng
	INNER JOIN #credit_netting_delete cnd ON cnd.netting_group_id = ng.netting_group_id

	CREATE TABLE #credit_netting_output (
		netting_group_id INT,
		netting_parent_group_id INT,
		netting_group_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		effective_date DATE,
		end_date DATE,
		source_deal_type_id INT,
		source_deal_sub_type_id INT,
		source_commodity_id INT,
		physical_financial_flag CHAR(1) COLLATE DATABASE_DEFAULT,
		hedge_type_value_id INT,
		internal_counterparty INT
	)
	
	INSERT INTO netting_group(
			netting_parent_group_id
			,netting_group_name		
			,effective_date			
			,end_date				
			,source_deal_type_id	
			,source_deal_sub_type_id
			,source_commodity_id	
			,physical_financial_flag
			,hedge_type_value_id	
			,internal_counterparty )
	OUTPUT INSERTED.netting_group_id,
		   INSERTED.netting_parent_group_id,
		   INSERTED.netting_group_name,
		   INSERTED.effective_date,
		   INSERTED.end_date,
		   INSERTED.source_deal_type_id,
		   INSERTED.source_deal_sub_type_id,
		   INSERTED.source_commodity_id,
		   INSERTED.physical_financial_flag,
		   INSERTED.hedge_type_value_id,
		   INSERTED.internal_counterparty
		INTO #credit_netting_output(
			netting_group_id,
			netting_parent_group_id,
			netting_group_name,
			effective_date,
			end_date,
			source_deal_type_id,
			source_deal_sub_type_id,
			source_commodity_id,
			physical_financial_flag,
			hedge_type_value_id,
			internal_counterparty
			)
	SELECT  netting_parent_group_id
			,netting_group_name		
			,effective_date			
			,end_date				
			,source_deal_type_id	
			,source_deal_sub_type_id
			,source_commodity_id	
			,physical_financial_flag
			,hedge_type_value_id	
			,internal_counterparty	
	FROM #credit_netting
	WHERE netting_group_id IS NULL

	CREATE TABLE #credit_netting_detail_output (
		netting_group_detail_id INT,
		netting_group_id INT,
		source_counterparty_id INT
	)

	INSERT INTO netting_group_detail (netting_group_id, source_counterparty_id)
	OUTPUT INSERTED.netting_group_detail_id,
			INSERTED.netting_group_id,
			INSERTED.source_counterparty_id
			INTO #credit_netting_detail_output (netting_group_detail_id, netting_group_id, source_counterparty_id)
	SELECT cno.netting_group_id, tcci.Counterparty_id
	FROM #credit_netting_output cno
	CROSS JOIN #temp_counterparty_credit_info tcci
	
	INSERT INTO netting_group_detail_contract(netting_group_detail_id, source_contract_id)
	SELECT cndo.netting_group_detail_id, s.item 
	FROM #credit_netting_output cno
	INNER JOIN #credit_netting_detail_output cndo 
		ON cno.netting_group_id = cndo.netting_group_id
	INNER JOIN #credit_netting cn 
		ON ISNULL(cn.netting_parent_group_id, -1)		= ISNULL(cno.netting_parent_group_id, -1)
			AND ISNULL(cn.netting_group_name, -1)		= ISNULL(cno.netting_group_name, -1)		
			AND ISNULL(cn.effective_date, '1900-01-01')	= ISNULL(cno.effective_date, '1900-01-01')		
			AND ISNULL(cn.end_date, '1900-01-01')		= ISNULL(cno.end_date, '1900-01-01')				
			AND ISNULL(cn.source_deal_type_id, -1)		= ISNULL(cno.source_deal_type_id, -1)	
			AND ISNULL(cn.source_deal_sub_type_id, -1)	= ISNULL(cno.source_deal_sub_type_id, -1)
			AND ISNULL(cn.source_commodity_id, -1)		= ISNULL(cno.source_commodity_id, -1)	
			AND ISNULL(cn.physical_financial_flag, -1)	= ISNULL(cno.physical_financial_flag, -1)
			AND ISNULL(cn.hedge_type_value_id, -1)		= ISNULL(cno.hedge_type_value_id, -1)	
			AND ISNULL(cn.internal_counterparty, -1)	= ISNULL(cno.internal_counterparty, -1)
	OUTER APPLY dbo.SplitCommaSeperatedValues(cn.contract_id) s

	DECLARE @process_table VARCHAR(500)
	DECLARE @sql_stmt VARCHAR(MAX)
	DECLARE @process_id VARCHAR(200)
	DECLARE @set_up_as_of_date VARCHAR(30)
	SELECT @set_up_as_of_date = as_of_date FROM module_asofdate
	
	SET @process_id = dbo.FNAGetNewID()  
	SET @process_table = 'adiha_process.dbo.alert_counterparty_credit_info_' + @process_id + '_acci'
	SET @sql_stmt = 'CREATE TABLE ' + @process_table + '
	                 (
	                 	counterparty_id    INT,
	                 	counterparty_name  VARCHAR(200),
	                 	debt_rating        VARCHAR(200),
	                 	credit_limit       INT,
	                 	as_of_date			VARCHAR(30),
	                 	hyperlink1 VARCHAR(5000), 
         				hyperlink2 VARCHAR(5000), 
         				hyperlink3 VARCHAR(5000), 
         				hyperlink4 VARCHAR(5000), 
         				hyperlink5 VARCHAR(5000)
	                 )
					INSERT INTO ' + @process_table + '(
						counterparty_id,
						counterparty_name,
						debt_rating,
						as_of_date
					  )
					SELECT ' +  CAST(@Counterparty_id AS VARCHAR(30)) + ',
					       ''' + REPLACE(@counterparty_name, '''', '''''') + ''',
					       ''' + ISNULL(@debt_rating_pre, '') + ''',
					       ''' + @set_up_as_of_date + '''
					FROM   counterparty_credit_info cci
					LEFT JOIN static_data_value sdv ON  sdv.value_id = cci.Debt_rating
					WHERE  cci.Counterparty_id = ' +  CAST(@Counterparty_id AS VARCHAR(30)) + ''

	EXEC(@sql_stmt)
	EXEC spa_register_event 20604, 20507, @process_table, 1, @process_id
	
	EXEC spa_register_event 20604, 20578, @process_table, 1, @process_id
	
	COMMIT
	
	EXEC spa_ErrorHandler 0,
	     'Counterparty Credit Info',
	     'spa_counterparty_credit_info',
	     'Success',
	     'Changes have been saved successfully.',
	     ''

	END TRY
	BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
	DECLARE @error_desc VARCHAR(500) = ERROR_MESSAGE()

	EXEC spa_ErrorHandler -1,
	     'Counterparty Credit Info',
	     'spa_counterparty_credit_info',
	     'DB Error',
	     'Update  of Counterparty Credit Info failed.',
	     @error_desc

	END CATCH
ELSE IF @flag='d'
BEGIN
	DELETE FROM master_view_counterparty_credit_info WHERE counterparty_credit_info_id=@counterparty_credit_info_id

	DELETE FROM counterparty_credit_info WHERE counterparty_credit_info_id=@counterparty_credit_info_id
	
	EXEC spa_maintain_udf_header 'd', NULL, @counterparty_credit_info_id

	IF @@ERROR <> 0
		BEGIN
		EXEC spa_ErrorHandler @@ERROR, 
			'Counterparty Credit Info', 
			'spa_counterparty_credit_info', 
			'DB Error', 
			'Deletion  of counterparty_credit_info failed.', 
			''
		RETURN
		END
	ELSE 
		EXEC spa_ErrorHandler 0, 
			'Counterparty Credit Info', 
			'spa_counterparty_credit_info', 
			'Success', 
			'Changes have been saved successfully.', 
			''
END

ELSE IF @flag='g' --getting counterparty_credit_info_id from Counterparty_id
BEGIN
	SELECT counterparty_credit_info_id 
		FROM counterparty_credit_info 
	WHERE Counterparty_id = @Counterparty_id
END
GO
