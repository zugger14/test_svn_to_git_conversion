
IF OBJECT_ID(N'spa_static_data_audit', N'P') IS NOT NULL
    DROP PROCEDURE spa_static_data_audit
GO 

-- ============================================================================================================================
-- Author: Pawan Adhikari
-- Create date: 2012-04-20 00:00AM
-- Description: Static Data Audit Log.
--              
-- Params:
-- @flag -- s
-- @static_data : static_data_value.value_id OR NULL for show all report
-- @as_of_date_from null : AS OF DATE FROM
-- @as_of_date_to null : AS OF DATE TO 
-- @source_system_id NULL : DEFAULT 2
-- @source_id	:  Static data ID
-- Paging Parameters
-- @batch_process_id VARCHAR(250) = NULL,
-- @batch_report_param VARCHAR(500) = NULL, 
-- @enable_paging INT = 0,  --'1' = enable, '0' = disable
-- @page_size INT = NULL,
-- @page_no INT = NULL	
-- ============================================================================================================================

CREATE PROC [dbo].[spa_static_data_audit]
	@flag               CHAR(1),
	@static_data        INT				=	NULL,
	@as_of_date_from    VARCHAR(20)		=	NULL,
	@as_of_date_to      VARCHAR(20)		=	NULL,
	@source_system_id   INT				=	NULL,
	@user_action		VARCHAR(1000)	=	NULL,
	@source_id		    VARCHAR(MAX)	=	NULL,
	--Batch/Paging      Parameters
	@batch_process_id   VARCHAR(250)	=	NULL,
	@batch_report_param VARCHAR(500)	=	NULL, 
	@enable_paging      INT				=	0,  --'1' = enable, '0' = disable
	@page_size          INT				=	NULL,
	@page_no            INT				=	NULL	
AS

/* ---------------------------------DEBUG----------------
DECLARE
	@flag               CHAR(1)			=	's' ,
	@static_data        INT				=	19909,
	@as_of_date_from    VARCHAR(20)		=	'2018-04-03',
	@as_of_date_to      VARCHAR(20)		=	'2018-04-09',
	@source_system_id   INT				=	2,
	@user_action		VARCHAR(1000)	=	'all',
	@source_id		    VARCHAR(MAX)	=	NULL,
	@batch_process_id   VARCHAR(250)	=	NULL,
	@batch_report_param VARCHAR(500)	=	NULL, 
	@enable_paging      INT				=	1,  --'1' = enable, '0' = disable
	@page_size          INT				=	NULL,
	@page_no            INT				=	NULL	
----------------------------------------------------------*/

SET NOCOUNT ON

IF @flag = 's'
BEGIN
	DECLARE @static_data_name	VARCHAR(500)
	DECLARE @sql				VARCHAR(MAX)
	DECLARE @sql2				VARCHAR(MAX)
	DECLARE @sql3				VARCHAR(MAX)
	DECLARE @sql_a				VARCHAR(MAX)
	DECLARE @sql2_a             VARCHAR(MAX)
	DECLARE @sql3_a				VARCHAR(MAX)
	DECLARE @group_result		VARCHAR(MAX) 
	DECLARE @all_result			VARCHAR(200)
	
	SET @group_result = ''
	SET @sql2 = NULL
	SET @sql3 = NULL

	IF NULLIF(@source_id, '') IS NOT NULL
	BEGIN
	  SET @as_of_date_to = CAST(GETDATE() AS DATE)
	END
	
	-- Create temp table to store the results
	IF OBJECT_ID('tempdb..#store_all_result') IS NOT NULL
		DROP TABLE #store_all_result
	
	CREATE TABLE #store_all_result
	(
		[User Action]        NVARCHAR(50)	COLLATE DATABASE_DEFAULT NULL,
		[Static Data Name]   NVARCHAR(100)	COLLATE DATABASE_DEFAULT NULL,
		[Name]               NVARCHAR(500)	COLLATE DATABASE_DEFAULT NULL,
		[Field]              NVARCHAR(200)	COLLATE DATABASE_DEFAULT NULL,
		[Prior Value]        NVARCHAR(500)	COLLATE DATABASE_DEFAULT NULL,
		[Current Value]      NVARCHAR(500)	COLLATE DATABASE_DEFAULT NULL,
		[Update User]        NVARCHAR(100)	COLLATE DATABASE_DEFAULT NULL,
		[Update Time Stamp]  DATETIME
	)
	
	SET @group_result = '
	INSERT INTO #store_all_result (
		[User Action],
		[Static Data Name],
		[Name],
		[Field],
		[Prior Value],
		[Current Value],
		[Update User],
		[Update Time Stamp]
	)'
	
	SET @source_system_id  = ISNULL(NULLIF(@source_system_id, ''), 2)

	IF @static_data IS NULL
	BEGIN	
		SET @all_result = 'y'				
	END
	
	
	/*******************************************1st Paging Batch START**********************************************/
	DECLARE @str_batch_table  VARCHAR(8000)
	DECLARE @user_login_id    VARCHAR(50)
	DECLARE @sql_paging       VARCHAR(8000)
	DECLARE @is_batch         BIT

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
	
	-- Source Book
	IF @static_data = 19901 OR @all_result = 'y'
	BEGIN
		
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id = ISNULL(@static_data, 19901)	
			
		SET @sql =  @group_result + '
			SELECT UPPER(LEFT(sba_now.user_action, 1)) + SUBSTRING(sba_now.user_action, 2, LEN(sba_now.user_action)) [User Action],
				''' + @static_data_name + ''' [Static Data Name],
				sba_now.source_book_name [Name],						   
				cols.field [Field],
				prior_value [Prior Value],
				current_value [Current Value],
				CASE WHEN sba_now.user_action = ''insert'' 
					THEN COALESCE(sba_now.create_user, sba_now.update_user, dbo.FNADBUser())
					ELSE COALESCE(sba_now.update_user, sba_now.create_user, dbo.FNADBUser()) 
				END [Update User],
				ISNULL(sba_now.update_ts,sba_now.create_ts) [Update TS]
			FROM source_book_audit sba_now
			OUTER APPLY (
				SELECT TOP 1 * FROM source_book_audit 
				WHERE audit_id < sba_now.audit_id AND source_book_id = sba_now.source_book_id 
				ORDER BY audit_id DESC
			) sba_prior

			--Source System
			LEFT JOIN source_system_description ssd_now ON ssd_now.source_system_id = sba_now.source_system_id
			LEFT JOIN source_system_description ssd_prior ON ssd_prior.source_system_id = sba_prior.source_system_id

			--Source System Book Type Value Id
			LEFT JOIN static_data_value sdv_book_type_now ON sdv_book_type_now.value_id = sba_now.source_system_book_type_value_id
			LEFT JOIN static_data_value sdv_book_type_prior ON sdv_book_type_prior.value_id = sba_prior.source_system_book_type_value_id
						
			CROSS APPLY (
				SELECT N''Source System'' field,
					CASE WHEN sba_now.user_action = ''Delete'' THEN NULL 
					ELSE CAST(ssd_now.source_system_name AS VARCHAR(250)) END current_value,
					CAST(ssd_prior.source_system_name AS VARCHAR(250)) prior_value
											
				UNION ALL
						
				SELECT N''Source System Book Id'',
					CASE WHEN sba_now.user_action = ''Delete'' THEN NULL 
					ELSE CAST(sba_now.source_system_book_id AS VARCHAR(250)) END,
					CAST(sba_prior.source_system_book_id AS VARCHAR(250))
							   
				UNION ALL
						
				SELECT N''Name'',
					CASE WHEN sba_now.user_action = ''Delete'' THEN NULL 
					ELSE CAST(sba_now.source_book_name AS VARCHAR(250)) END,
					CAST(sba_prior.source_book_name AS VARCHAR(250))
							   
				UNION ALL
						
				SELECT N''Description'',
					CASE WHEN sba_now.user_action = ''Delete'' THEN NULL 
					ELSE CAST(sba_now.source_book_desc AS VARCHAR(250)) END,
					CAST(sba_prior.source_book_desc AS VARCHAR(250))
							   
				UNION ALL
						
				SELECT N''Source System Book Type Value Id'',
					CASE WHEN sba_now.user_action = ''Delete'' THEN NULL 
					ELSE CAST(sdv_book_type_now.code AS VARCHAR(250)) END,
					CAST(sdv_book_type_prior.code AS VARCHAR(250))
			) cols
			WHERE ISNULL(sba_now.update_ts,sba_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
				--CASE 1: if showing NULL value in case of delete
				AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''')	
				--CASE 2: if showing old value in case of delete
				--AND (sba_now.user_action <> ''Update'' OR (ISNULL(current_value, '''') <> ISNULL(prior_value, '''')))	
				AND sba_now.source_system_id = ''' + cast(@source_system_id AS VARCHAR(2)) + '''										
			ORDER BY sba_now.audit_id DESC'
			
		--PRINT @sql
		EXEC(@sql)			
	END	
	
	-- Contract
 	IF @static_data = 19902 OR @all_result = 'y'
 	BEGIN
 		
 		SELECT @static_data_name = sdv.code
 		FROM   static_data_value sdv
 		WHERE  sdv.value_id =  ISNULL(@static_data, 19902)
 		
 		SET @sql = @group_result + '
 			SELECT UPPER(LEFT(cga_now.user_action, 1)) + SUBSTRING(cga_now.user_action, 2, LEN(cga_now.user_action)) [User Action],
 				''' + @static_data_name + ''' [Static Data Name],
 				cga_now.contract_name [Name],
 				cols.field [Field],
 				prior_value [Prior Value],
 				current_value [Current Value],
 				CASE WHEN cga_now.user_action = ''insert'' 
 					THEN COALESCE(cga_now.create_user, cga_now.update_user, dbo.FNADBUser())
 					ELSE COALESCE(cga_now.update_user, cga_now.create_user, dbo.FNADBUser()) 
 				END [Update User],
 				ISNULL(cga_now.update_ts, cga_now.create_ts) [Update TS]
 			FROM contract_group_audit cga_now
 			OUTER APPLY(
 				SELECT TOP 1 * FROM contract_group_audit
 				WHERE  audit_id < cga_now.audit_id AND contract_id = cga_now.contract_id
 				ORDER BY audit_id DESC
 			) cga_prior
  
 			--Source System
 			LEFT JOIN source_system_description ssd_now ON  ssd_now.source_system_id = cga_now.source_system_id
 			LEFT JOIN source_system_description ssd_prior ON  ssd_prior.source_system_id = cga_prior.source_system_id
 
 			--Subsidiary
 			LEFT JOIN portfolio_hierarchy sub_now ON sub_now.entity_id = cga_now.sub_id
 			LEFT JOIN portfolio_hierarchy sub_prior ON sub_prior.entity_id = cga_prior.sub_id
 
 			--Currency
 			LEFT JOIN source_currency c_now ON c_now.source_currency_id = cga_now.currency
 			LEFT JOIN source_currency c_prior ON c_prior.source_currency_id = cga_prior.currency
 
 			--Billing Cycle
 			LEFT JOIN static_data_value bc_now ON bc_now.value_id = cga_now.billing_cycle
 			LEFT JOIN static_data_value bc_prior ON bc_prior.value_id = cga_prior.billing_cycle
 
 			--Volume Granularity
 			LEFT JOIN static_data_value vg_now ON vg_now.value_id = cga_now.volume_granularity
 			LEFT JOIN static_data_value vg_prior ON vg_prior.value_id = cga_prior.volume_granularity
 
 			--Volume UOM
 			LEFT JOIN source_uom vu_now ON vu_now.source_uom_id = cga_now.volume_uom
 			LEFT JOIN source_uom vu_prior ON vu_prior.source_uom_id = cga_prior.volume_uom
 
 			--Payment Calendar
 			LEFT JOIN static_data_value pc_now ON pc_now.value_id = cga_now.payment_calendar
 			LEFT JOIN static_data_value pc_prior ON pc_prior.value_id = cga_prior.payment_calendar
 
 			--Payment Rule
 			LEFT JOIN static_data_value pd_now ON pd_now.value_id = cga_now.invoice_due_date
 			LEFT JOIN static_data_value pd_prior ON pd_prior.value_id = cga_prior.invoice_due_date
 
 			--PNL Calendar
 			LEFT JOIN static_data_value pnlc_now ON pnlc_now.value_id = cga_now.pnl_calendar
 			LEFT JOIN static_data_value pnlc_prior ON pnlc_prior.value_id = cga_prior.pnl_calendar
 
 			--PNL Calendar
 			LEFT JOIN static_data_value pnld_now ON pnld_now.value_id = cga_now.pnl_date
 			LEFT JOIN static_data_value pnld_prior ON pnld_prior.value_id = cga_prior.pnl_date
 
 			--Contract Status
 			LEFT JOIN static_data_value cs_now ON cs_now.value_id = cga_now.contract_status
 			LEFT JOIN static_data_value cs_prior ON cs_prior.value_id = cga_prior.contract_status
 
 			--Cont Component Templete
 			LEFT JOIN contract_charge_type cct_now ON cct_now.contract_charge_type_id = cga_now.contract_charge_type_id
 			LEFT JOIN contract_charge_type cct_prior ON cct_prior.contract_charge_type_id = cga_prior.contract_charge_type_id
 
 			--Remittance Template
 			LEFT JOIN contract_report_template crt_now ON crt_now.template_id = cga_now.contract_report_template
 			LEFT JOIN contract_report_template crt_prior ON crt_prior.template_id = cga_prior.contract_report_template
 					
 			--Settlement Calendar
 			LEFT JOIN static_data_value sdv1_now ON sdv1_now.value_id = cga_now.settlement_calendar
 			LEFT JOIN static_data_value sdv1_prior ON sdv1_prior.value_id = cga_prior.settlement_calendar
 					
 			--Settlement Rule
 			LEFT JOIN static_data_value sdv2_now ON sdv2_now.value_id = cga_now.settlement_date
 			LEFT JOIN static_data_value sdv2_prior ON sdv2_prior.value_id = cga_prior.settlement_date
 					
 			--Holiday Calendar
 			LEFT JOIN static_data_value sdv3_now ON sdv3_now.value_id = cga_now.holiday_calendar_id
 			LEFT JOIN static_data_value sdv3_prior ON sdv3_prior.value_id = cga_prior.holiday_calendar_id
 					
 			--Invoice Template
 			LEFT JOIN contract_report_template crt1_now ON crt1_now.template_id = cga_now.invoice_report_template
 			LEFT JOIN contract_report_template crt1_prior ON crt1_prior.template_id = cga_prior.invoice_report_template
 					
 			--Netting Template
 			LEFT JOIN contract_report_template nett_now ON nett_now.template_id = cga_now.netting_template
 			LEFT JOIN contract_report_template nett_prior ON nett_prior.template_id = cga_prior.netting_template
 					
 			--Contract Email Template
 			LEFT JOIN admin_email_configuration email_now ON email_now.admin_email_configuration_id = cga_now.contract_email_template
 			LEFT JOIN admin_email_configuration email_prior ON email_prior.admin_email_configuration_id = cga_prior.contract_email_template
 
 			-- State
 			LEFT JOIN static_data_value cs1_now ON cs1_now.value_id = cga_now.state
 			LEFT JOIN static_data_value cs1_prior ON cs1_prior.value_id = cga_prior.state '
 
 		SET @sql2 ='
 					CROSS APPLY(
 						SELECT N''Source System'' field,
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(ssd_now.source_system_name AS VARCHAR(250)) END current_value,
 							CAST(ssd_prior.source_system_name AS VARCHAR(250)) prior_value
 						
 						UNION ALL
 										
 						SELECT N''Name'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.contract_name AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.contract_name AS VARCHAR(250)) prior_value				
 							   
 						UNION ALL
 						
 						SELECT N''Description'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.contract_desc AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.contract_desc AS VARCHAR(250)) prior_value	
 							   
 						UNION ALL
 						
 						SELECT N''Source Control Id'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.source_contract_id AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.source_contract_id AS VARCHAR(250)) prior_value				
 							
 						UNION ALL
 						
 						SELECT N''Customer ID'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.UD_Contract_id AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.UD_Contract_id AS VARCHAR(250)) prior_value
 						
 						UNION ALL
 						
 						SELECT N''Contact Name'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.name AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.name AS VARCHAR(50)) prior_value
 						
 						UNION ALL
 						
 						SELECT N''Company'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.company AS VARCHAR(100)) END current_value,
 							CAST(cga_prior.company AS VARCHAR(100)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Address'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.address AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.address AS VARCHAR(50)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Address2'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.address2 AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.address2 AS VARCHAR(50)) prior_value
 						UNION ALL
 						
 						SELECT N''City'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.city AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.city AS VARCHAR(50)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''State'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cs1_now.code AS VARCHAR(50)) END current_value,
 							CAST(cs1_prior.code AS VARCHAR(50)) prior_value
 						
 						UNION ALL
 						
 						SELECT N''Zip'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.zip AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.zip AS VARCHAR(50)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Telephone'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.telephone AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.telephone AS VARCHAR(50)) prior_value
 						
 						UNION ALL
 						
 						SELECT N''Fax'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.fax AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.fax AS VARCHAR(50)) prior_value
 						
 						UNION ALL
 						
 						SELECT N''Email'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.email AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.email AS VARCHAR(50)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Subledger Code'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.subledger_code AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.subledger_code AS VARCHAR(50)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Name2'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.name2 AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.name2 AS VARCHAR(50)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Company2'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.company2 AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.company2 AS VARCHAR(50)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Telephone2'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.telephone2 AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.telephone2 AS VARCHAR(50)) prior_value
 						
 						UNION ALL
 						
 						SELECT N''Fax2'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.fax2 AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.fax2 AS VARCHAR(50)) prior_value
 						
 						UNION ALL
 						
 						SELECT N''Email2'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.email2 AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.email2 AS VARCHAR(50)) prior_value
 						
 						UNION ALL
 						
 						SELECT N''Area Engineer'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.area_engineer AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.area_engineer AS VARCHAR(50)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Substation Name'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.substation_name AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.substation_name AS VARCHAR(50)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Metering Contract'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.metering_contract AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.metering_contract AS VARCHAR(50)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Project County'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.project_county AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.project_county AS VARCHAR(50)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''MISO Queue Number'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.miso_queue_number AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.miso_queue_number AS VARCHAR(50)) prior_value
 						
 						UNION ALL
 						
 						SELECT N''Voltage'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.voltage AS VARCHAR(50)) END current_value,
 							CAST(cga_prior.voltage AS VARCHAR(50)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Subsidiary'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(sub_now.entity_name AS VARCHAR(250)) END current_value,
 							CAST(sub_prior.entity_name AS VARCHAR(250)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Currency'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(c_now.currency_name AS VARCHAR(250)) END current_value,
 							CAST(c_prior.currency_name AS VARCHAR(250)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Settlement Accountant'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.settlement_accountant AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.settlement_accountant AS VARCHAR(250)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Billing Cycle'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(bc_now.code AS VARCHAR(250)) END current_value,
 							CAST(bc_prior.code AS VARCHAR(250)) prior_value'
 			
 			DECLARE @sql2_1  VARCHAR(4000)	
 			SET @sql2_1 = '
 						UNION ALL
 						
 						SELECT N''Contract Specialist'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.contract_specialist AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.contract_specialist AS VARCHAR(250)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Volume Granularity'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(vg_now.code AS VARCHAR(250)) END current_value,
 							CAST(vg_prior.code AS VARCHAR(250)) prior_value	
 							
 						UNION ALL
 						
 						SELECT N''Volume UOM'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(vu_now.uom_name AS VARCHAR(250)) END current_value,
 							CAST(vu_prior.uom_name AS VARCHAR(250)) prior_value	
 							
 						UNION ALL
 						
 						SELECT N''Payment Calendar'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(pc_now.code AS VARCHAR(250)) END current_value,
 							CAST(pc_prior.code AS VARCHAR(250)) prior_value	
 							
 						UNION ALL
 						
 						SELECT N''PNL Calendar'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(pnlc_now.code AS VARCHAR(250)) END current_value,
 							CAST(pnlc_prior.code AS VARCHAR(250)) prior_value	
 							
 						UNION ALL
 						
 						SELECT N''Payment Rule'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(pd_now.code AS VARCHAR(250)) END current_value,
 							CAST(pd_prior.code AS VARCHAR(250)) prior_value	
 							
 						UNION ALL
 						
 						SELECT N''PNL Calendar'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(pnld_now.code AS VARCHAR(250)) END current_value,
 							CAST(pnld_prior.code AS VARCHAR(250)) prior_value	
 						
 						UNION ALL
 						
 						SELECT N''Settlement Calendar'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(sdv1_now.code AS VARCHAR(250)) END current_value,
 							CAST(sdv1_prior.code AS VARCHAR(250)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Settlement Rule'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(sdv2_now.code AS VARCHAR(250)) END current_value,
 							CAST(sdv2_prior.code AS VARCHAR(250)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Holiday Calendar'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(sdv3_now.code AS VARCHAR(250)) END current_value,
 							CAST(sdv3_prior.code AS VARCHAR(250)) prior_value
 			
 						UNION ALL
 						
 						SELECT N''Contract Status'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cs_now.code AS VARCHAR(250)) END current_value,
 							CAST(cs_prior.code AS VARCHAR(250)) prior_value		
 							
 						UNION ALL
 						
 						SELECT N''Contract Date'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE dbo.FNADateFormat(CAST(cga_now.contract_date AS VARCHAR(250))) END current_value,
 							dbo.FNADateFormat(CAST(cga_prior.contract_date AS VARCHAR(250))) prior_value	
 							
 						UNION ALL
 						
 						SELECT N''Term End'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE dbo.FNADateFormat(CAST(cga_now.term_end AS VARCHAR(250))) END current_value,
 							dbo.FNADateFormat(CAST(cga_prior.term_end AS VARCHAR(250))) prior_value
 							
 						UNION ALL
 						
 						SELECT N''COD Date'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE dbo.FNADateFormat(CAST(cga_now.term_start AS VARCHAR(250))) END current_value,
 							dbo.FNADateFormat(CAST(cga_prior.term_start AS VARCHAR(250))) prior_value'	
 							
 			SET @sql3 = '
 						UNION ALL
 						
 						SELECT N''Receive Invoice'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 								 ELSE CASE WHEN cga_now.receive_invoice = ''y'' THEN ''Yes'' ELSE ''No'' END 
 							END current_value,
 							CASE WHEN cga_prior.receive_invoice = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value	
 							
 						UNION ALL
 						
 						SELECT N''No Meter Data'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 								 ELSE CASE WHEN cga_now.no_meterdata = ''y'' THEN ''Yes'' ELSE ''No'' END 
 							END current_value,
 							CASE WHEN cga_prior.no_meterdata = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value	
 							
 						UNION ALL
 						
 						SELECT N''Bookout Provision'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 								 ELSE CASE WHEN cga_now.bookout_provision = ''y'' THEN ''Yes'' ELSE ''No'' END 
 							END current_value,
 							CASE WHEN cga_prior.bookout_provision = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value	
 							
 						UNION ALL
 						
 						SELECT N''Type'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 								 ELSE 
 			 						CASE WHEN cga_now.type = ''i'' THEN ''Invoice'' 
 			 							 WHEN cga_now.type = ''r'' THEN ''Remittance''
 										 ELSE ''Automatic''
 									 END 
 							END current_value,
 							CASE WHEN cga_prior.type = ''i'' THEN ''Invoice'' 
 			 							 WHEN cga_now.type = ''r'' THEN ''Remittance''
 										 ELSE ''Automatic''
 							END  prior_value
 							
 						UNION ALL
 						
 						SELECT N''Energy Type'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 								 ELSE 
 			 						CASE WHEN cga_now.energy_type = ''p'' THEN ''Production'' 
 			 							 ELSE ''Test''
 									 END 
 							END current_value,
 							CASE WHEN cga_prior.energy_type = ''p'' THEN ''Production'' 
 	 							 ELSE ''Test''
 							END  prior_value
 							
 						UNION ALL
 						
 						SELECT N''Active'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 								 ELSE CASE WHEN cga_now.is_active = ''y'' THEN ''Yes'' ELSE ''No'' END 
 							END current_value,
 							CASE WHEN cga_prior.is_active = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value
 							
 						UNION ALL
 						
 						SELECT N''Cont Componenet Template'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cct_now.contract_charge_desc AS VARCHAR(250)) END current_value,
 							CAST(cct_prior.contract_charge_desc AS VARCHAR(250)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Cont Componenet Template'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cct_now.contract_charge_desc AS VARCHAR(250)) END current_value,
 							CAST(cct_prior.contract_charge_desc AS VARCHAR(250)) prior_value	
 							
 						UNION ALL
 						
 						SELECT N''Remittance Template'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(crt_now.template_name AS VARCHAR(250)) END current_value,
 							CAST(crt_prior.template_name AS VARCHAR(250)) prior_value	
 								
 						UNION ALL
 						
 						SELECT N''Payment Days'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.payment_days AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.payment_days AS VARCHAR(250)) prior_value	
 							
 						UNION ALL
 						
 						SELECT N''Settlement Days'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.settlement_days AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.settlement_days AS VARCHAR(250)) prior_value
 							
 						UNION ALL
 						
 						SELECT N''Invoice Template'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(crt1_now.template_name AS VARCHAR(100)) END current_value,
 							CAST(crt1_prior.template_name AS VARCHAR(100)) prior_value	
 							
 						UNION ALL
 						
 						SELECT N''Netting Template'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(nett_now.template_name AS VARCHAR(100)) END current_value,
 							CAST(nett_prior.template_name AS VARCHAR(100)) prior_value	
 							
 						UNION ALL
 						
 						SELECT N''Self Billing'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.self_billing AS VARCHAR(2)) END current_value,
 							CAST(cga_prior.self_billing AS VARCHAR(2)) prior_value		
 							
 						UNION ALL
 						
 						SELECT N''Neting Rule'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.neting_rule AS VARCHAR(2)) END current_value,
 							CAST(cga_prior.neting_rule AS VARCHAR(2)) prior_value						
 							
 						UNION ALL
 						
 						SELECT N''Netting Statement'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.netting_statement AS VARCHAR(2)) END current_value,
 							CAST(cga_prior.netting_statement AS VARCHAR(2)) prior_value	
 							
 						UNION ALL
 							
 						SELECT N''Contract Email Template'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(email_now.template_name AS VARCHAR(200)) END current_value,
 							CAST(email_prior.template_name AS VARCHAR(200)) prior_value	
 						
 						UNION ALL
 						
 						SELECT N''Billing Start Month'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.billing_start_month AS VARCHAR(200)) END current_value,
 							CAST(cga_prior.billing_start_month AS VARCHAR(200)) prior_value	
 						
 						UNION ALL
 						
 						SELECT N''Billing From Date'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.billing_from_date AS VARCHAR(200)) END current_value,
 							CAST(cga_prior.billing_from_date AS VARCHAR(200)) prior_value	
 							
 						UNION ALL
 						
 						SELECT N''Billing To Date'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.billing_to_date AS VARCHAR(200)) END current_value,
 							CAST(cga_prior.billing_to_date AS VARCHAR(200)) prior_value	
 							
 						UNION ALL
 						
 						SELECT N''Billing From Hour'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.billing_from_hour AS VARCHAR(200)) END current_value,
 							CAST(cga_prior.billing_from_hour AS VARCHAR(200)) prior_value	
 						
 						UNION ALL
 						
 						SELECT N''Billing To Hour'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.billing_to_hour AS VARCHAR(200)) END current_value,
 							CAST(cga_prior.billing_to_hour AS VARCHAR(200)) prior_value	
 							
 						
 							
 					) cols
 					WHERE ISNULL(cga_now.update_ts,cga_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
 						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') AND cga_now.source_system_id = ''' + cast(@source_system_id AS VARCHAR(2)) + '''' + CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND cga_now.contract_id IN (' + @source_id +')' ELSE '' END 
 					SET @sql3  = @sql3 + 'ORDER BY [Static Data Name] DESC, cga_now.audit_id DESC'		
 			
 		--PRINT @sql
 		--PRINT @sql2
 		--PRINT @sql2_1		
 		--PRINT @sql3
 		EXEC(@sql + @sql2 + @sql2_1 + @sql3)
 		
 		--Charge Type pop up form:
 		
 		SET @sql_a = @group_result + '
 					SELECT UPPER(LEFT(cga_now.user_action, 1)) + SUBSTRING(cga_now.user_action, 2, LEN(cga_now.user_action)) [User Action],
 						   ''Charge Type'' [Static Data Name],
 						   cc_now.code [Name],
 						   cols.field [Field],
 						   prior_value [Prior Value],
 						   current_value [Current Value],
 						   CASE WHEN cga_now.user_action = ''insert'' 
 								THEN COALESCE(cga_now.create_user, cga_now.update_user, dbo.FNADBUser())
 								ELSE COALESCE(cga_now.update_user, cga_now.create_user, dbo.FNADBUser()) 
 						   END [Update User],
 						   ISNULL(cga_now.update_ts, cga_now.create_ts) [Update TS]
 					FROM contract_group_detail_audit cga_now
 					inner join contract_group cg on cg.contract_id = cga_now.contract_id
 					OUTER APPLY(
 					   SELECT TOP 1 * FROM contract_group_detail_audit
 					   WHERE  audit_id < cga_now.audit_id AND contract_id = cga_now.contract_id
 					   ORDER BY audit_id DESC
 				   ) cga_prior
 				   
 					--Aggregation Level
 					LEFT JOIN static_data_value al_now ON al_now.value_id = cga_now.calc_aggregation
 					LEFT JOIN static_data_value al_prior ON al_prior.value_id = cga_prior.calc_aggregation
 					
 					--Volume Granularity
 					LEFT JOIN static_data_value vg_now ON vg_now.value_id = cga_now.volume_granularity
 					LEFT JOIN static_data_value vg_prior ON vg_prior.value_id = cga_prior.volume_granularity
 					
 					--Payment Calendar
 					LEFT JOIN static_data_value pc_now ON pc_now.value_id = cga_now.payment_calendar
 					LEFT JOIN static_data_value pc_prior ON pc_prior.value_id = cga_prior.payment_calendar
 					
 					--PNL Calendar
 					LEFT JOIN static_data_value pnlc_now ON pnlc_now.value_id = cga_now.pnl_calendar
 					LEFT JOIN static_data_value pnlc_prior ON pnlc_prior.value_id = cga_prior.pnl_calendar
 					
 					--PNL Date
 					LEFT JOIN static_data_value pnld_now ON pnld_now.value_id = cga_now.pnl_date
 					LEFT JOIN static_data_value pnld_prior ON pnld_prior.value_id = cga_prior.pnl_date
 					
 					--Deal Type
 					
 					--Time Of Use
 					LEFT JOIN static_data_value tou_now ON tou_now.value_id = cga_now.timeofuse
 					LEFT JOIN static_data_value tou_prior ON tou_prior.value_id = cga_prior.timeofuse
 					
 					--Product
 					LEFT JOIN static_data_value p_now ON p_now.value_id = cga_now.eqr_product_name
 					LEFT JOIN static_data_value p_prior ON p_prior.value_id = cga_prior.eqr_product_name
 					
 					--Group By
 					LEFT JOIN static_data_value gb_now ON gb_now.value_id = cga_now.group_by
 					LEFT JOIN static_data_value gb_prior ON gb_prior.value_id = cga_prior.group_by
 					
 					--Contract Component
 					LEFT JOIN static_data_value cc_now ON cc_now.value_id = cga_now.invoice_line_item_id
 					LEFT JOIN static_data_value cc_prior ON cc_prior.value_id = cga_prior.invoice_line_item_id
 					
 					--Contract Charge Type Group
 					LEFT JOIN static_data_value cctg_now ON cctg_now.value_id = cga_now.alias
 					LEFT JOIN static_data_value cctg_prior ON cctg_prior.value_id = cga_prior.alias
 					
 					--Template
 					LEFT JOIN contract_charge_type t_now ON t_now.contract_charge_type_id = cga_now.contract_template
 					LEFT JOIN contract_charge_type t_prior ON t_prior.contract_charge_type_id = cga_prior.contract_template
 					
 					--Template Contract Component
 					LEFT JOIN static_data_value tcc_now ON tcc_now.value_id = cga_now.contract_component_template
 					LEFT JOIN static_data_value tcc_prior ON tcc_prior.value_id = cga_prior.contract_component_template
 					
 					----Invoice Template
 					LEFT JOIN contract_report_template it_now ON it_now.template_id = cga_now.invoice_template_id
 					LEFT JOIN contract_report_template it_prior ON it_prior.template_id = cga_prior.invoice_template_id
 					
 					----Settlement Calendar
 					LEFT JOIN static_data_value setc_now ON setc_now.value_id = cga_now.settlement_calendar
 					LEFT JOIN static_data_value setc_prior ON setc_prior.value_id = cga_prior.settlement_calendar
 					
 					----Group 1
 					LEFT JOIN source_book g1_now ON g1_now.source_book_id = cga_now.group1
 					LEFT JOIN source_book g1_prior ON g1_prior.source_book_id = cga_prior.group1
 					
 					----Group 2
 					LEFT JOIN source_book g2_now ON g2_now.source_book_id = cga_now.group2
 					LEFT JOIN source_book g2_prior ON g2_prior.source_book_id = cga_prior.group2
 					
 					----Group 3
 					LEFT JOIN source_book g3_now ON g3_now.source_book_id = cga_now.group3
 					LEFT JOIN source_book g3_prior ON g3_prior.source_book_id = cga_prior.group3
 					
 					----Group 4
 					LEFT JOIN source_book g4_now ON g4_now.source_book_id = cga_now.group4
 					LEFT JOIN source_book g4_prior ON g4_prior.source_book_id = cga_prior.group4
 					
 					----Location
 					LEFT JOIN source_minor_location loc_now ON loc_now.source_minor_location_id = cga_now.location_id
 					LEFT JOIN source_minor_location loc_prior ON loc_prior.source_minor_location_id = cga_prior.location_id
 					
 					----Charge Type
 					LEFT JOIN static_data_value charget_now ON charget_now.value_id = cga_now.true_up_charge_type_id
 					LEFT JOIN static_data_value charget_prior ON charget_prior.value_id = cga_prior.true_up_charge_type_id

 				   
 				   '
 
 		SET @sql2_a ='
 					CROSS APPLY(
 						--Type
 						SELECT N''Type'' field,
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE 
 								CASE WHEN cga_now.radio_automatic_manual = ''c'' THEN ''Charges Map'' 
 									 WHEN cga_now.radio_automatic_manual = ''f'' THEN ''Formula''
 									 WHEN cga_now.radio_automatic_manual = ''t'' THEN ''Template''
 										ELSE '''' END 
 							END current_value,
 							
 							CASE WHEN cga_prior.radio_automatic_manual = ''c'' THEN ''Charges Map'' 
 								 WHEN cga_prior.radio_automatic_manual = ''f'' THEN ''Formula''
 								 WHEN cga_prior.radio_automatic_manual = ''t'' THEN ''Template''
 									ELSE '''' END prior_value
 							
 						UNION ALL 
 						
 						--Contract Component
 						SELECT N''Contract Component'' field,
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cc_now.code AS VARCHAR(500)) END current_value,
 							CAST(cc_prior.code AS VARCHAR(500)) prior_value	
 							
 						UNION ALL 
 						
 						--Contract Charge Type Group
 						SELECT N''Contract Charge Type Group'' field,
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cctg_now.code AS VARCHAR(500)) END current_value,
 							CAST(cctg_prior.code AS VARCHAR(500)) prior_value	
 						
 						UNION ALL 
 						
 						--Template*
 						SELECT N''Template'' field,
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(t_now.contract_charge_desc AS VARCHAR(500)) END current_value,
 							CAST(t_prior.contract_charge_desc AS VARCHAR(500)) prior_value	
 						
 						UNION ALL 
 						
 						--Template Contract Component
 						SELECT N''Template Contract Component'' field,
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(tcc_now.code AS VARCHAR(500)) END current_value,
 							CAST(tcc_prior.code AS VARCHAR(500)) prior_value	
 						
 						UNION ALL 
 						
 						--Aggregation Level
 						SELECT N''Aggregation Level'' field,
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(al_now.code AS VARCHAR(500)) END current_value,
 							CAST(al_prior.code AS VARCHAR(500)) prior_value	
 							
 						UNION ALL 
 						
 						--Volume Granularity
 						SELECT N''Volume Granularity'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(vg_now.code AS VARCHAR(500)) END current_value,
 							CAST(vg_prior.code AS VARCHAR(500)) prior_value	
 							
 						UNION ALL 
 						
 						--Flat Fee
 						SELECT N''Flat Fee'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.price AS VARCHAR(500)) END current_value,
 							CAST(cga_prior.price AS VARCHAR(500)) prior_value	
 							
 						UNION ALL 
 						
 						--Effective Date
 						SELECT N''Effective Date'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.effective_date AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.effective_date AS VARCHAR(250)) prior_value	
 						
 						UNION ALL 
 						
 						--End Date
 						SELECT N''End date'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.end_date AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.end_date AS VARCHAR(250)) prior_value	
 						
 						UNION ALL 
 						
 						--Invoice Template
 						SELECT N''Invoice Template'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(it_now.template_name AS VARCHAR(250)) END current_value,
 							CAST(it_prior.template_name AS VARCHAR(250)) prior_value	
 						
 						UNION ALL 
 						
 						
 						--Include/Exclude in Invoice*
 						SELECT N''Include/Exclude in Invoice'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE 
 								CASE WHEN cga_now.hideInInvoice = ''s'' THEN ''Show in invoice'' 
 									 WHEN cga_now.hideInInvoice = ''d'' THEN ''Do not show in invoice''
 									 WHEN cga_now.hideInInvoice = ''f'' THEN ''Do not show in invoice until finalized''
 										ELSE '''' END 
 							END current_value,
 							
 							CASE WHEN cga_prior.hideInInvoice = ''s'' THEN ''Show in invoice'' 
 								 WHEN cga_prior.hideInInvoice = ''d'' THEN ''Do not show in invoice''
 								 WHEN cga_prior.hideInInvoice = ''f'' THEN ''Do not show in invoice until finalized''
 									ELSE '''' END prior_value
 							
 						UNION ALL 
 						
 						--Include Charges
 						SELECT N''Include Charges'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.include_charges AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.include_charges AS VARCHAR(250)) prior_value	
 						
 						UNION ALL
 							
 						--Settlement Date
 						SELECT N''Settlement Date'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.settlement_date AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.settlement_date AS VARCHAR(250)) prior_value	
 						
 						UNION ALL 
 						
 						--Settlement Calendar
 						SELECT N''Settlement Calendar'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE 
 							CASE setc_now.value_id 
								WHEN 50 THEN setc_now.code + '' (Group 1)''
								WHEN 51 THEN setc_now.code + '' (Group 2)'' 
								WHEN 52 THEN setc_now.code + '' (Group 3)''
								WHEN 53 THEN setc_now.code + '' (Group 4)''
								ELSE setc_now.code 
							END END current_value,
							CASE setc_prior.value_id 
								WHEN 50 THEN setc_prior.code + '' (Group 1)''
								WHEN 51 THEN setc_prior.code + '' (Group 2)'' 
								WHEN 52 THEN setc_prior.code + '' (Group 3)''
								WHEN 53 THEN setc_prior.code + '' (Group 4)''
								ELSE setc_prior.code 
							END AS prior_value
 							
 						UNION ALL
 						
 						--Payment Calendar
 						SELECT N''Payment Calendar'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(pc_now.code AS VARCHAR(250)) END current_value,
 							CAST(pc_prior.code AS VARCHAR(250)) prior_value	
 							
 						UNION ALL
 						
 						--PNL Calendar
 						SELECT N''PNL Calendar'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(pnlc_now.code AS VARCHAR(250)) END current_value,
 							CAST(pnlc_prior.code AS VARCHAR(250)) prior_value	
 						
 						UNION ALL
 							
 						--PNL Date
 						SELECT N''PNL Date'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(pnld_now.code AS VARCHAR(250)) END current_value,
 							CAST(pnld_prior.code AS VARCHAR(250)) prior_value	
 						
 						UNION ALL
 							
 						--Deal Type
 						SELECT N''Deal Type'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.deal_type AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.deal_type AS VARCHAR(250)) prior_value	
 							
 						UNION ALL
 							
 						
 					 	--Group 1
 					 	SELECT N''Group 1'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(g1_now.source_book_name AS VARCHAR(250)) END current_value,
 							CAST(g1_prior.source_book_name AS VARCHAR(250)) prior_value	
 							
 						UNION ALL
 					 	
 					 	--Group 2
 					 	SELECT N''Group 2'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(g2_now.source_book_name AS VARCHAR(250)) END current_value,
 							CAST(g2_prior.source_book_name AS VARCHAR(250)) prior_value	
 							
 						UNION ALL
 					 	
 					 	--Group 3
 					  	SELECT N''Group 3'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(g3_now.source_book_name AS VARCHAR(250)) END current_value,
 							CAST(g3_prior.source_book_name AS VARCHAR(250)) prior_value	
 							
 						UNION ALL
 					 	
 					 	--Group 4
 						SELECT N''Group 4'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(g4_now.source_book_name AS VARCHAR(250)) END current_value,
 							CAST(g4_prior.source_book_name AS VARCHAR(250)) prior_value	
 							
 						UNION ALL
 					 	
 					 	--Leg
 					 	SELECT N''Leg'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.leg AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.leg AS VARCHAR(250)) prior_value	
 						
 						UNION ALL 
 					 	
 					 	--Time Of Use
 						SELECT N''Time Of Use'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(tou_now.code AS VARCHAR(250)) END current_value,
 							CAST(tou_prior.code AS VARCHAR(250)) prior_value	
 						
 						UNION ALL
 							
 						--Buy/Sell
 						SELECT N''Buy/Sell'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE 
 								CASE WHEN cga_now.buy_sell_flag = ''b'' THEN ''Buy'' 
 									 WHEN cga_now.buy_sell_flag = ''s'' THEN ''Sell''
 										ELSE '''' END 
 							END current_value,
 							
 							CASE WHEN cga_prior.buy_sell_flag = ''b'' THEN ''Buy'' 
 								 WHEN cga_prior.buy_sell_flag = ''s'' THEN ''Sell''
 									ELSE '''' END prior_value
 							
 						UNION ALL 
 						
 						--Product
 						SELECT N''Product'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(p_now.code AS VARCHAR(250)) END current_value,
 							CAST(p_prior.code AS VARCHAR(250)) prior_value	
 							
 						UNION ALL
 							
 						--Group By
 						SELECT N''Group By'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(gb_now.code AS VARCHAR(250)) END current_value,
 							CAST(gb_prior.code AS VARCHAR(250)) prior_value	
 							
 						UNION ALL
 							
 						--Location
 						SELECT N''Location'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(loc_now.Location_Name AS VARCHAR(250)) END current_value,
 							CAST(loc_prior.Location_Name AS VARCHAR(250)) prior_value	
 							
 						UNION ALL
 						
 						--Time Bucket
 						SELECT N''Time Bucket'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.time_bucket_formula_id AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.time_bucket_formula_id AS VARCHAR(250)) prior_value	
 						
 						UNION ALL
 						
 						--Applies To
 						SELECT N''Applies To'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE 
 								CASE WHEN cga_now.true_up_applies_to = ''c'' THEN ''Contract Start Month'' 
 									 WHEN cga_now.true_up_applies_to = ''y'' THEN ''Calendar Year''
 									 WHEN cga_now.true_up_applies_to = ''p'' THEN ''Prior Months''
 										ELSE '''' END 
 							END current_value,
 							
 							CASE WHEN cga_prior.true_up_applies_to = ''c'' THEN ''Contract Start Month'' 
 								 WHEN cga_prior.true_up_applies_to = ''y'' THEN ''Calendar Year''
 								 WHEN cga_prior.true_up_applies_to = ''p'' THEN ''Prior Months''
 									ELSE '''' END prior_value
 							
 						UNION ALL 
 						
 						--No. of Months
 						SELECT N''No. of Months'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.true_up_no_month AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.true_up_no_month AS VARCHAR(250)) prior_value	
 						
 						UNION ALL 
 						
 						--True Up
 						SELECT N''True Up'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cga_now.is_true_up AS VARCHAR(250)) END current_value,
 							CAST(cga_prior.is_true_up AS VARCHAR(250)) prior_value	
 							
 						UNION ALL 
 						
 						--Charge Type
 						SELECT N''Charge Type'',
 							CASE WHEN cga_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(charget_now.code AS VARCHAR(250)) END current_value,
 							CAST(charget_prior.code AS VARCHAR(250)) prior_value	
 						
 						'
 							
 			SET @sql3_a = '			
 							
 					) cols
 					WHERE ISNULL(cga_now.update_ts,cga_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
 						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') 	
 					' + CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND cga_now.contract_id IN (' + @source_id +')' ELSE '' END 
 			SET @sql3_a  = @sql3_a + '	ORDER BY [Static Data Name] DESC,cga_now.audit_id DESC'	
 			
 		EXEC(@sql_a + @sql2_a + @sql3_a)
 		
 ------Formula-------------------
 		
 		SET @sql_a = @group_result + '
 					SELECT UPPER(LEFT(fna_now.user_action, 1)) + SUBSTRING(fna_now.user_action, 2, LEN(fna_now.user_action)) [User Action],
 						   ''Formula'' [Static Data Name],
 						   fna_now.description1 [Name],
 						   cols.field [Field],
 						   prior_value [Prior Value],
 						   current_value [Current Value],
 						   CASE WHEN fna_now.user_action = ''insert'' 
 								THEN COALESCE(fna_now.create_user, fna_now.update_user, dbo.FNADBUser())
 								ELSE COALESCE(fna_now.update_user, fna_now.create_user, dbo.FNADBUser()) 
 						   END [Update User],
 						   ISNULL(fna_now.update_ts, fna_now.create_ts) [Update TS]
 					FROM formula_nested_audit fna_now
 					inner join contract_group_detail cgd on cgd.formula_id = fna_now.formula_group_id
 					inner join contract_group cg on cg.contract_id = cgd.contract_id
 				OUTER APPLY(
 					   SELECT TOP 1 * FROM formula_nested_audit
 					   WHERE  audit_id < fna_now.audit_id AND id = fna_now.id
 					   ORDER BY audit_id DESC
 				   ) fna_prior
 				   
 				   LEFT JOIN formula_editor fe_now on fe_now.formula_id = fna_now.formula_id
 				   LEFT JOIN formula_editor fe_prior on fe_prior.formula_id = fna_prior.formula_id
 				   
 				   '
 
 		SET @sql2_a ='
 					CROSS APPLY(

 						SELECT N''Name'' field,
 							CASE WHEN fna_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(fna_now.description1 AS VARCHAR(250)) END current_value,
 							CAST(fna_prior.description1 AS VARCHAR(250)) prior_value
 						
 						UNION ALL 
 						
 						SELECT N''Formula Name'',
 							CASE WHEN fna_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(fe_now.formula AS VARCHAR(250)) END current_value,
 							CAST(fe_prior.formula AS VARCHAR(250)) prior_value		
 							
 						UNION ALL 
 						
 						SELECT N''Sequence'' field,
 							CASE WHEN fna_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(fna_now.sequence_order AS VARCHAR(250)) END current_value,
 							CAST(fna_prior.sequence_order AS VARCHAR(250)) prior_value
 		
 						'
 							
 			SET @sql3_a = '			
 							
 					) cols
 					WHERE ISNULL(fna_now.update_ts,fna_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
 						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') ' + CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND cg.contract_id IN (' + @source_id +')' ELSE '' END 
 			SET @sql3_a = @sql3_a +	' ORDER BY fna_now.audit_id DESC'
 		--PRINT @sql_a + @sql2_a + @sql3_a

 		EXEC(@sql_a + @sql2_a + @sql3_a)
 		--SELECT * FROM #store_all_result
 		
------MDQ grid-------------------------------------
  		
  		SET @sql_a = @group_result + '
  					SELECT UPPER(LEFT(tcma_now.user_action, 1)) + SUBSTRING(tcma_now.user_action, 2, LEN(tcma_now.user_action)) [User Action],
  						   ''Contract - MDQ'' [Static Data Name],
  						   cg.contract_name [Name],
  						   cols.field [Field],
  						   prior_value [Prior Value],
  						   current_value [Current Value],
  						   CASE WHEN tcma_now.user_action = ''insert'' 
  								THEN COALESCE(tcma_now.create_user, tcma_now.update_user, dbo.FNADBUser())
  								ELSE COALESCE(tcma_now.update_user, tcma_now.create_user, dbo.FNADBUser()) 
  						   END [Update User],
  						   ISNULL(tcma_now.update_ts, tcma_now.create_ts) [Update TS]
  					FROM transportation_contract_mdq_audit tcma_now
  					inner join contract_group cg on cg.contract_id = tcma_now.contract_id
  				OUTER APPLY(
  					   SELECT TOP 1 * FROM transportation_contract_mdq_audit
  					   WHERE  audit_id < tcma_now.audit_id AND id = tcma_now.id
  					   ORDER BY audit_id DESC
  				   ) tcma_prior
  				   	   
  				   '
  
  		SET @sql2_a ='
  					CROSS APPLY(
  						SELECT N''Effective Date'' field,
  							CASE WHEN tcma_now.user_action = ''Delete'' THEN NULL 
  							ELSE CAST(tcma_now.effective_date AS VARCHAR(250)) END current_value,
  							CAST(tcma_prior.effective_date AS VARCHAR(250)) prior_value
  						
  						UNION ALL 
  						
  						SELECT N''Mdq'',
  							CASE WHEN tcma_now.user_action = ''Delete'' THEN NULL 
  							ELSE CAST(tcma_now.mdq AS VARCHAR(250)) END current_value,
  							CAST(tcma_prior.mdq AS VARCHAR(250)) prior_value	
  		
  						'
  							
  			SET @sql3_a = '			
  							
  					) cols
  					WHERE ISNULL(tcma_now.update_ts,tcma_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
  						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') 	
  					' + CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND tcma_now.contract_id IN (' + @source_id +')' ELSE '' END 
  			SET @sql3_a = @sql3_a +	'ORDER BY tcma_now.audit_id DESC'		
  		--PRINT @sql_a + @sql2_a + @sql3_a
 
  		EXEC(@sql_a + @sql2_a + @sql3_a)
  		--SELECT * FROM #store_all_result
  			 	
 ------Parties grid-------------------------------------
  		
  		SET @sql_a = @group_result + '
  					SELECT UPPER(LEFT(tcpa_now.user_action, 1)) + SUBSTRING(tcpa_now.user_action, 2, LEN(tcpa_now.user_action)) [User Action],
  						   ''Contract - Parties'' [Static Data Name],
  						   cg.contract_name [Name],
  						   cols.field [Field],
  						   prior_value [Prior Value],
  						   current_value [Current Value],
  						   CASE WHEN tcpa_now.user_action = ''insert'' 
  								THEN COALESCE(tcpa_now.create_user, tcpa_now.update_user, dbo.FNADBUser())
  								ELSE COALESCE(tcpa_now.update_user, tcpa_now.create_user, dbo.FNADBUser()) 
  						   END [Update User],
  						   ISNULL(tcpa_now.update_ts, tcpa_now.create_ts) [Update TS]
  					FROM transportation_contract_parties_audit tcpa_now
  					inner join contract_group cg on cg.contract_id = tcpa_now.contract_id
  				OUTER APPLY(
  					   SELECT TOP 1 * FROM transportation_contract_parties_audit
  					   WHERE  audit_id < tcpa_now.audit_id AND id = tcpa_now.id
  					   ORDER BY audit_id DESC
  				   ) tcpa_prior
  				   
  					--Type
 					LEFT JOIN static_data_value tsdv_now ON tsdv_now.value_id = tcpa_now.type
  					LEFT JOIN static_data_value tsdv_prior ON tsdv_prior.value_id = tcpa_prior.type
  					
  					--Party
  					LEFT JOIN source_counterparty sc_now ON sc_now.source_counterparty_id = tcpa_now.party
  					LEFT JOIN source_counterparty sc_prior ON sc_prior.source_counterparty_id = tcpa_prior.party	
  				   	   
  				   '
  
  		SET @sql2_a ='
  					CROSS APPLY(
  						SELECT N''Party'' field,
  							CASE WHEN tcpa_now.user_action = ''Delete'' THEN NULL 
  							ELSE CAST(sc_now.counterparty_name AS VARCHAR(250)) END current_value,
  							CAST(sc_prior.counterparty_name AS VARCHAR(250)) prior_value
  						
  						UNION ALL 
  						
  						SELECT N''Type'',
  							CASE WHEN tcpa_now.user_action = ''Delete'' THEN NULL 
  							ELSE CAST(tsdv_now.code AS VARCHAR(250)) END current_value,
  							CAST(tsdv_prior.code AS VARCHAR(250)) prior_value	
  						
  						UNION ALL 
  						
  						SELECT N''Effective Date'',
  							CASE WHEN tcpa_now.user_action = ''Delete'' THEN NULL 
  							ELSE CAST(tcpa_now.effective_date AS VARCHAR(250)) END current_value,
  							CAST(tcpa_prior.effective_date AS VARCHAR(250)) prior_value	
  		
  						'
  							
  			SET @sql3_a = '			
  							
  					) cols
  					WHERE ISNULL(tcpa_now.update_ts,tcpa_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
  						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') ' + CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND tcpa_now.contract_id IN (' + @source_id +')' ELSE '' END 

  				SET @sql3_a =  @sql3_a + 'ORDER BY tcpa_now.audit_id DESC'	
  		--PRINT @sql_a + @sql2_a + @sql3_a
 
  		EXEC(@sql_a + @sql2_a + @sql3_a)
  		--SELECT * FROM #store_all_result
  		
  		
------Location grid-------------------------------------
  		
  		SET @sql_a = @group_result + '
  					SELECT UPPER(LEFT(tcla_now.user_action, 1)) + SUBSTRING(tcla_now.user_action, 2, LEN(tcla_now.user_action)) [User Action],
  						   ''Contract - Location'' [Static Data Name],
  						   cg.contract_name [Name],
  						   cols.field [Field],
  						   prior_value [Prior Value],
  						   current_value [Current Value],
  						   CASE WHEN tcla_now.user_action = ''insert'' 
  								THEN COALESCE(tcla_now.create_user, tcla_now.update_user, dbo.FNADBUser())
  								ELSE COALESCE(tcla_now.update_user, tcla_now.create_user, dbo.FNADBUser()) 
  						   END [Update User],
  						   ISNULL(tcla_now.update_ts, tcla_now.create_ts) [Update TS]
  					FROM transportation_contract_location_audit tcla_now
  					inner join contract_group cg on cg.contract_id = tcla_now.contract_id
  				OUTER APPLY(
  					   SELECT TOP 1 * FROM transportation_contract_location_audit
  					   WHERE  audit_id < tcla_now.audit_id AND id = tcla_now.id
  					   ORDER BY audit_id DESC
  				   ) tcla_prior
  					
  					--Type
 					LEFT JOIN source_minor_location sml_now ON sml_now.source_minor_location_id = tcla_now.location_id
  					LEFT JOIN source_minor_location sml_prior ON sml_prior.source_minor_location_id = tcla_prior.location_id
  					
  					--Rank
 					LEFT JOIN static_data_value rank_now ON rank_now.value_id = tcla_now.rank
  					LEFT JOIN static_data_value rank_prior ON rank_prior.value_id = tcla_prior.rank
  					
  					--Fuel Group
  					LEFT JOIN time_series_definition tsd_now ON tsd_now.time_series_definition_id = tcla_now.fuel_group
  					LEFT JOIN time_series_definition tsd_prior ON tsd_prior.time_series_definition_id = tcla_prior.fuel_group	
  				   	   
  				   '
  
  		SET @sql2_a ='
  					CROSS APPLY(
  						
						SELECT N''Type'' field,
  							CASE WHEN tcla_now.user_action = ''Delete'' THEN NULL 
  							ELSE 
  								CASE WHEN tcla_now.type = ''1'' THEN ''Primary'' 
  										WHEN tcla_now.type = ''2'' THEN ''Secondary''
  										ELSE '''' END 
  							END current_value,
  							
  							CASE WHEN tcla_prior.type = ''1'' THEN ''Primary'' 
  									WHEN tcla_prior.type = ''2'' THEN ''Secondary''
  									ELSE '''' END prior_value
  							
  						UNION ALL 
  						
						SELECT N''Location'',
  							CASE WHEN tcla_now.user_action = ''Delete'' THEN NULL 
  							ELSE CAST(sml_now.Location_Name AS VARCHAR(250)) END current_value,
  							CAST(sml_prior.Location_Name AS VARCHAR(250)) prior_value	
  						
  						UNION ALL 
  						
  						SELECT N''Rec/Del'',
  							CASE WHEN tcla_now.user_action = ''Delete'' THEN NULL 
  							ELSE 
  								CASE WHEN tcla_now.rec_del = ''1'' THEN ''Reciept'' 
  										WHEN tcla_now.rec_del = ''2'' THEN ''Delivery''
  										ELSE '''' END 
  							END current_value,
  							
  							CASE WHEN tcla_prior.rec_del = ''1'' THEN ''Reciept'' 
  									WHEN tcla_prior.rec_del = ''2'' THEN ''Delivery''
  									ELSE '''' END prior_value
  							
  						UNION ALL 
  						
  						SELECT N''Effective Date'',
  							CASE WHEN tcla_now.user_action = ''Delete'' THEN NULL 
  							ELSE CAST(tcla_now.effective_date AS VARCHAR(250)) END current_value,
  							CAST(tcla_prior.effective_date AS VARCHAR(250)) prior_value	
  							
  						UNION ALL 
  						
  						SELECT N''Mdq'',
  							CASE WHEN tcla_now.user_action = ''Delete'' THEN NULL 
  							ELSE CAST(tcla_now.mdq AS VARCHAR(250)) END current_value,
  							CAST(tcla_prior.mdq AS VARCHAR(250)) prior_value
  						
  						UNION ALL 
  					
  						SELECT N''Rank'',
  							CASE WHEN tcla_now.user_action = ''Delete'' THEN NULL 
  							ELSE CAST(rank_now.code AS VARCHAR(250)) END current_value,
  							CAST(rank_prior.code AS VARCHAR(250)) prior_value	
  						
  						UNION ALL 	
  					
  						SELECT N''Surcharge'',
  							CASE WHEN tcla_now.user_action = ''Delete'' THEN NULL 
  							ELSE CAST(tcla_now.surcharge AS VARCHAR(250)) END current_value,
  							CAST(tcla_prior.surcharge AS VARCHAR(250)) prior_value
  						
  						UNION ALL 
  						
  						SELECT N''Fuel'',
  							CASE WHEN tcla_now.user_action = ''Delete'' THEN NULL 
  							ELSE CAST(tcla_now.fuel AS VARCHAR(250)) END current_value,
  							CAST(tcla_prior.fuel AS VARCHAR(250)) prior_value
  							
  						UNION ALL
  							
  						SELECT N''Fuel Group'',
  							CASE WHEN tcla_now.user_action = ''Delete'' THEN NULL 
  							ELSE CAST(tsd_now.time_series_name AS VARCHAR(250)) END current_value,
  							CAST(tsd_prior.time_series_name AS VARCHAR(250)) prior_value
  							
  						UNION ALL
  							
  						SELECT N''Rate'',
  							CASE WHEN tcla_now.user_action = ''Delete'' THEN NULL 
  							ELSE CAST(tcla_now.rate AS VARCHAR(250)) END current_value,
  							CAST(tcla_prior.rate AS VARCHAR(250)) prior_value
  						'
  							
  			SET @sql3_a = '			
  							
  					) cols
  					WHERE ISNULL(tcla_now.update_ts,tcla_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
  						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''')' + CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND tcla_now.contract_id IN (' + @source_id +')' ELSE '' END 
  				SET @sql3_a =	@sql3_a + ' ORDER BY tcla_now.audit_id DESC'	
  		--PRINT @sql_a + @sql2_a + @sql3_a
 
  		EXEC(@sql_a + @sql2_a + @sql3_a)
  		--SELECT * FROM #store_all_result
  		
------Rank grid-------------------------------------
  		
  		SET @sql_a = @group_result + '
  					SELECT UPPER(LEFT(tcra_now.user_action, 1)) + SUBSTRING(tcra_now.user_action, 2, LEN(tcra_now.user_action)) [User Action],
  						   ''Contract - Rank'' [Static Data Name],
  						   cg.contract_name [Name],
  						   cols.field [Field],
  						   prior_value [Prior Value],
  						   current_value [Current Value],
  						   CASE WHEN tcra_now.user_action = ''insert'' 
  								THEN COALESCE(tcra_now.create_user, tcra_now.update_user, dbo.FNADBUser())
  								ELSE COALESCE(tcra_now.update_user, tcra_now.create_user, dbo.FNADBUser()) 
  						   END [Update User],
  						   ISNULL(tcra_now.update_ts, tcra_now.create_ts) [Update TS]
  					FROM transportation_contract_rank_audit tcra_now
  					inner join contract_group cg on cg.contract_id = tcra_now.contract_id
  				OUTER APPLY(
  					   SELECT TOP 1 * FROM transportation_contract_rank_audit
  					   WHERE  audit_id < tcra_now.audit_id AND id = tcra_now.id
  					   ORDER BY audit_id DESC
  				   ) tcra_prior
  				   
  					--Rank
 					LEFT JOIN static_data_value rank_now ON rank_now.value_id = tcra_now.rank_id
  					LEFT JOIN static_data_value rank_prior ON rank_prior.value_id = tcra_prior.rank_id
  				   	   
  				   '
  
  		SET @sql2_a ='
  					CROSS APPLY(
  						SELECT N''Effective Date'' field,
  							CASE WHEN tcra_now.user_action = ''Delete'' THEN NULL 
  							ELSE CAST(tcra_now.effective_date AS VARCHAR(250)) END current_value,
  							CAST(tcra_prior.effective_date AS VARCHAR(250)) prior_value
  						
  						UNION ALL 
  						
  						SELECT N''Rank'',
  							CASE WHEN tcra_now.user_action = ''Delete'' THEN NULL 
  							ELSE CAST(rank_now.code AS VARCHAR(250)) END current_value,
  							CAST(rank_prior.code AS VARCHAR(250)) prior_value	
  		
  						'
  							
  			SET @sql3_a = '			
  							
  					) cols
  					WHERE ISNULL(tcra_now.update_ts,tcra_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
  						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') 	
  					 ' + CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND tcra_now.contract_id IN (' + @source_id +')' ELSE '' END
  			SET @sql3_a =	@sql3_a + ' ORDER BY tcra_now.audit_id DESC'		
  		--PRINT @sql_a + @sql2_a + @sql3_a
 
  		EXEC(@sql_a + @sql2_a + @sql3_a)
  		--SELECT * FROM #store_all_result
  		
 --------GL Code-----------------------------------
  		
  		SET @sql_a = @group_result + '
  					SELECT UPPER(LEFT(cgda1_now.user_action, 1)) + SUBSTRING(cgda1_now.user_action, 2, LEN(cgda1_now.user_action)) [User Action],
  						   ''GL Code Mapping'' [Static Data Name],
  						   cg.contract_name [Name],
  						   cols.field [Field],
  						   prior_value [Prior Value],
  						   current_value [Current Value],
  						   CASE WHEN cgda1_now.user_action = ''insert'' 
  								THEN COALESCE(cgda1_now.create_user, cgda1_now.update_user, dbo.FNADBUser())
  								ELSE COALESCE(cgda1_now.update_user, cgda1_now.create_user, dbo.FNADBUser()) 
  						   END [Update User],
  						   ISNULL(cgda1_now.update_ts, cgda1_now.create_ts) [Update TS]
  					FROM contract_group_detail_audit cgda1_now
  					inner join contract_group cg on cg.contract_id = cgda1_now.contract_id
  				OUTER APPLY(
  					   SELECT TOP 1 * FROM contract_group_detail_audit
  					   WHERE  audit_id < cgda1_now.audit_id AND id = cgda1_now.id
  					   ORDER BY audit_id DESC
  				   ) cgda1_prior
  				   
  					--Rank
 					--LEFT JOIN static_data_value rank_now ON rank_now.value_id = cgda_now.rank_id
  					--LEFT JOIN static_data_value rank_prior ON rank_prior.value_id = tcra_prior.rank_id
  					
  					--GL Account (Actual/Default)
  					LEFT JOIN adjustment_default_gl_codes glaccount_now ON glaccount_now.default_gl_id = cgda1_now.default_gl_id
  					LEFT JOIN adjustment_default_gl_codes glaccount_prior ON glaccount_prior.default_gl_id = cgda1_prior.default_gl_id
  					
  					LEFT JOIN static_data_value sdv_glaccount_now on sdv_glaccount_now.value_id = glaccount_now.adjustment_type_id
  				   	LEFT JOIN static_data_value sdv_glaccount_prior on sdv_glaccount_prior.value_id = glaccount_prior.adjustment_type_id   
  				   	
  				   	
  				   	-- GL Account Estimates
  				   	LEFT JOIN adjustment_default_gl_codes glaccount_now_1 ON glaccount_now_1.default_gl_id = cgda1_now.default_gl_id_estimates
  					LEFT JOIN adjustment_default_gl_codes glaccount_prior_1 ON glaccount_prior_1.default_gl_id = cgda1_prior.default_gl_id_estimates
  					
  					LEFT JOIN static_data_value sdv_glaccount_now_1 on sdv_glaccount_now_1.value_id = glaccount_now_1.adjustment_type_id
  				   	LEFT JOIN static_data_value sdv_glaccount_prior_1 on sdv_glaccount_prior_1.value_id = glaccount_prior_1.adjustment_type_id 
  				   	
  				   	-- Cash Apply
  				   	LEFT JOIN adjustment_default_gl_codes glaccount_now_2 ON glaccount_now_2.default_gl_id = cgda1_now.default_gl_code_cash_applied
  					LEFT JOIN adjustment_default_gl_codes glaccount_prior_2 ON glaccount_prior_2.default_gl_id = cgda1_prior.default_gl_code_cash_applied
  					
  					LEFT JOIN static_data_value sdv_glaccount_now_2 on sdv_glaccount_now_2.value_id = glaccount_now_2.adjustment_type_id
  				   	LEFT JOIN static_data_value sdv_glaccount_prior_2 on sdv_glaccount_prior_2.value_id = glaccount_prior_2.adjustment_type_id   
  				   '
  
  		SET @sql2_a ='
  					CROSS APPLY(
  						
  						SELECT N''GL Account (Actual/Default)'' field,
  							CASE WHEN cgda1_now.user_action = ''Delete'' THEN NULL 
  							ELSE 
  								CASE WHEN glaccount_now.estimated_actual = ''a'' THEN cast(sdv_glaccount_now.code as varchar)+ '' - Actual'' 
  										WHEN glaccount_now.estimated_actual = ''e'' THEN cast(sdv_glaccount_now.code as varchar) + '' - Estimated''
  										WHEN glaccount_now.estimated_actual = ''c'' THEN cast(sdv_glaccount_now.code as varchar)+ '' - Cash Applied''
  										ELSE '''' END 
  							END current_value,
  							
  							CASE WHEN glaccount_prior.estimated_actual = ''a'' THEN cast(sdv_glaccount_prior.code as varchar) + '' - Actual'' 
  										WHEN glaccount_prior.estimated_actual = ''e'' THEN cast(sdv_glaccount_prior.code as varchar)+ '' - Estimated''
  										WHEN glaccount_prior.estimated_actual = ''c'' THEN cast(sdv_glaccount_prior.code as varchar) + '' - Cash Applied''
  										ELSE '''' END prior_value
  							
  						UNION ALL   							
  							
  						SELECT N''GL Account Estimates'',
  							CASE WHEN cgda1_now.user_action = ''Delete'' THEN NULL 
  							ELSE 
  								CASE WHEN glaccount_now_1.estimated_actual = ''a'' THEN cast(sdv_glaccount_now_1.code as varchar)+ '' - Actual'' 
  										WHEN glaccount_now_1.estimated_actual = ''e'' THEN cast(sdv_glaccount_now_1.code as varchar) + '' - Estimated''
  										WHEN glaccount_now_1.estimated_actual = ''c'' THEN cast(sdv_glaccount_now_1.code as varchar)+ '' - Cash Applied''
  										ELSE '''' END 
  							END current_value,
  							
  							CASE WHEN glaccount_prior_1.estimated_actual = ''a'' THEN cast(sdv_glaccount_prior_1.code as varchar) + '' - Actual'' 
  										WHEN glaccount_prior_1.estimated_actual = ''e'' THEN cast(sdv_glaccount_prior_1.code as varchar)+ '' - Estimated''
  										WHEN glaccount_prior_1.estimated_actual = ''c'' THEN cast(sdv_glaccount_prior_1.code as varchar) + '' - Cash Applied''
  										ELSE '''' END prior_value
  							
  							
  						UNION ALL 							
  							
  						SELECT N''Cash Apply'',
  							CASE WHEN cgda1_now.user_action = ''Delete'' THEN NULL 
  							ELSE 
  								CASE WHEN glaccount_now_2.estimated_actual = ''a'' THEN cast(sdv_glaccount_now_2.code as varchar)+ '' - Actual'' 
  										WHEN glaccount_now_2.estimated_actual = ''e'' THEN cast(sdv_glaccount_now_2.code as varchar) + '' - Estimated''
  										WHEN glaccount_now_2.estimated_actual = ''c'' THEN cast(sdv_glaccount_now_2.code as varchar)+ '' - Cash Applied''
  										ELSE '''' END 
  							END current_value,
  							
  							CASE WHEN glaccount_prior_2.estimated_actual = ''a'' THEN cast(sdv_glaccount_prior_2.code as varchar) + '' - Actual'' 
  										WHEN glaccount_prior_2.estimated_actual = ''e'' THEN cast(sdv_glaccount_prior_2.code as varchar)+ '' - Estimated''
  										WHEN glaccount_prior_2.estimated_actual = ''c'' THEN cast(sdv_glaccount_prior_2.code as varchar) + '' - Cash Applied''
  										ELSE '''' END prior_value
  										
  						UNION ALL
  						--Include Volume in JE Report
  						SELECT N''Include Volume in JE Report'',
 							CASE WHEN cgda1_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(cgda1_now.manual AS VARCHAR(250)) END current_value,
 							CAST(cgda1_prior.manual AS VARCHAR(250)) prior_value
  						'
  							
  			SET @sql3_a = '			
  							
  					) cols
  					WHERE ISNULL(cgda1_now.update_ts,cgda1_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
  						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') 	
  					' + CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND cgda1_now.contract_id IN (' + @source_id +')' ELSE '' END
  		  SET @sql3_a = @sql3_a + '	ORDER BY cgda1_now.audit_id DESC'	
  		--PRINT @sql_a + @sql2_a + @sql3_a
 
  		EXEC(@sql_a + @sql2_a + @sql3_a)
  		--SELECT * FROM #store_all_result
  		

------Formula Additional-------------------------------------
  		
 		SET @sql_a = @group_result + '
 					SELECT UPPER(LEFT(fna1_now.user_action, 1)) + SUBSTRING(fna1_now.user_action, 2, LEN(fna1_now.user_action)) [User Action],
 						   ''Formula Additional'' [Static Data Name],
 						   fna1_now.description1 [Name],
 						   cols.field [Field],
 						   prior_value [Prior Value],
 						   current_value [Current Value],
 						   CASE WHEN fna1_now.user_action = ''insert'' 
 								THEN COALESCE(fna1_now.create_user, fna1_now.update_user, dbo.FNADBUser())
 								ELSE COALESCE(fna1_now.update_user, fna1_now.create_user, dbo.FNADBUser()) 
 						   END [Update User],
 						   ISNULL(fna1_now.update_ts, fna1_now.create_ts) [Update TS]
 					FROM formula_nested_audit fna1_now
 					inner join contract_group_detail cgd on cgd.formula_id = fna1_now.formula_group_id
 					inner join contract_group cg on cg.contract_id = cgd.contract_id
 				OUTER APPLY(
 					   SELECT TOP 1 * FROM formula_nested_audit
 					   WHERE  audit_id < fna1_now.audit_id AND id = fna1_now.id
 					   ORDER BY audit_id DESC
 				   ) fna1_prior
 				   
 					--Granularity
  					LEFT JOIN static_data_value sdv_granularity_now on sdv_granularity_now.value_id = fna1_now.granularity
  				   	LEFT JOIN static_data_value sdv_granularity_prior on sdv_granularity_prior.value_id = fna1_prior.granularity   

					--UOM
					LEFT JOIN source_uom su_now on su_now.source_uom_id = fna1_now.uom_id
  				   	LEFT JOIN source_uom su_prior on su_prior.source_uom_id = fna1_prior.uom_id  
  				   	
  				   	LEFT JOIN source_system_description ssd_now on ssd_now.source_system_id =  su_now.source_system_id
  				   	LEFT JOIN source_system_description ssd_prior on ssd_prior.source_system_id =  su_prior.source_system_id

					--Show as Rate
					LEFT JOIN source_uom sar_now on sar_now.source_uom_id = fna1_now.rate_id
  				   	LEFT JOIN source_uom sar_prior on sar_prior.source_uom_id = fna1_prior.rate_id   
  				   	
  				   	LEFT JOIN source_system_description ssd_now1 on ssd_now1.source_system_id =  sar_now.source_system_id
  				   	LEFT JOIN source_system_description ssd_prior1 on ssd_prior1.source_system_id =  sar_prior.source_system_id
  				   	
  				   	--Show as Total
  					LEFT JOIN static_data_value sdv_sat_now on sdv_sat_now.value_id = fna1_now.total_id
  				   	LEFT JOIN static_data_value sdv_sat_prior on sdv_sat_prior.value_id = fna1_prior.total_id   
  				   	
  				   	--Show Value as
  					LEFT JOIN static_data_value sdv_sva_now on sdv_sva_now.value_id = fna1_now.show_value_id
  				   	LEFT JOIN static_data_value sdv_sva_prior on sdv_sva_prior.value_id = fna1_prior.show_value_id   
 
 				   '
 
 		SET @sql2_a ='
 					CROSS APPLY(
 						
						--Granularity
 						SELECT N''Granularity'' field,
 							CASE WHEN fna1_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(sdv_granularity_now.code AS VARCHAR(250)) END current_value,
 							CAST(sdv_granularity_prior.code AS VARCHAR(250)) prior_value
 							
 						UNION ALL 
 						
 						--UOM
 						SELECT N''UOM'',
 							CASE WHEN fna1_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(su_now.uom_name AS VARCHAR(250)) END current_value,
 							CAST(su_prior.uom_name AS VARCHAR(250)) prior_value
 							
 						UNION ALL 
 						
 						--Show as Rate
 						SELECT N''Show as Rate'',
 							CASE WHEN fna1_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(sar_now.uom_name AS VARCHAR(250)) END current_value,
 							CAST(sar_prior.uom_name AS VARCHAR(250)) prior_value
 							
 						UNION ALL 
 						
 						--Show as Total
 						SELECT N''Show as Total'',
 							CASE WHEN fna1_now.user_action = ''Delete'' THEN NULL 
 							ELSE 
 							CASE sdv_sat_now.value_id 
								WHEN 50 THEN sdv_sat_now.code + '' (Group 1)''
								WHEN 51 THEN sdv_sat_now.code + '' (Group 2)'' 
								WHEN 52 THEN sdv_sat_now.code + '' (Group 3)''
								WHEN 53 THEN sdv_sat_now.code + '' (Group 4)''
								ELSE sdv_sat_now.code 
							END END current_value,
							CASE sdv_sat_now.value_id 
								WHEN 50 THEN sdv_sat_prior.code + '' (Group 1)''
								WHEN 51 THEN sdv_sat_prior.code + '' (Group 2)'' 
								WHEN 52 THEN sdv_sat_prior.code + '' (Group 3)''
								WHEN 53 THEN sdv_sat_prior.code + '' (Group 4)''
								ELSE sdv_sat_prior.code 
							END AS prior_value
						
						UNION ALL 
							
						--Show Value as
 						SELECT N''Show Value as'',
 							CASE WHEN fna1_now.user_action = ''Delete'' THEN NULL 
 							ELSE 
 							CASE sdv_sva_now.value_id 
								WHEN 50 THEN sdv_sva_now.code + '' (Group 1)''
								WHEN 51 THEN sdv_sva_now.code + '' (Group 2)'' 
								WHEN 52 THEN sdv_sva_now.code + '' (Group 3)''
								WHEN 53 THEN sdv_sva_now.code + '' (Group 4)''
								ELSE sdv_sva_now.code 
							END END current_value,
							CASE sdv_sat_now.value_id 
								WHEN 50 THEN sdv_sva_prior.code + '' (Group 1)''
								WHEN 51 THEN sdv_sva_prior.code + '' (Group 2)'' 
								WHEN 52 THEN sdv_sva_prior.code + '' (Group 3)''
								WHEN 53 THEN sdv_sva_prior.code + '' (Group 4)''
								ELSE sdv_sva_prior.code 
							END AS prior_value
						 						
						UNION ALL 
							
						--Do not show volume in invoice
						SELECT N''Do not show volume in invoice'',
 							CASE WHEN fna1_now.user_action = ''Delete'' THEN NULL 
 							ELSE CAST(fna1_now.include_item AS VARCHAR(250)) END current_value,
 							CAST(fna1_prior.include_item AS VARCHAR(250)) prior_value
 						'
 							
 			SET @sql3_a = '			
 							
 					) cols
 					WHERE ISNULL(fna1_now.update_ts,fna1_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
 						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') 	
 					' + CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND cgd.contract_id IN (' + @source_id +')' ELSE '' END
 			SET @sql3_a = @sql3_a + ' ORDER BY fna1_now.audit_id DESC'		
 		--PRINT @sql_a + @sql2_a + @sql3_a

 		EXEC(@sql_a + @sql2_a + @sql3_a)
 		--SELECT * FROM #store_all_result
 			
 	END
	
	-- Counterparty
	IF @static_data = 19903 OR @all_result = 'y'
	BEGIN
		
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id =  ISNULL(@static_data, 19903)
		
		SET @sql = @group_result + '
					SELECT UPPER(LEFT(sca_now.user_action, 1)) + SUBSTRING(sca_now.user_action, 2, LEN(sca_now.user_action)) [User Action],
						   ''' + @static_data_name + ''' [Static Data Name],
						   sca_now.counterparty_name [Name],
						   cols.field [Field],
						   prior_value [Prior Value],
						   current_value [Current Value],
						   CASE WHEN sca_now.user_action = ''insert'' 
								THEN COALESCE(sca_now.create_user, sca_now.update_user, dbo.FNADBUser())
								ELSE COALESCE(sca_now.update_user, sca_now.create_user, dbo.FNADBUser()) 
						   END [Update User],
						   ISNULL(sca_now.update_ts, sca_now.create_ts) [Update TS]						   
					FROM source_counterparty_audit sca_now
					   OUTER APPLY(
								   SELECT TOP 1 * FROM source_counterparty_audit
								   WHERE  audit_id < sca_now.audit_id AND source_counterparty_id = sca_now.source_counterparty_id
								   ORDER BY audit_id DESC
							   ) sca_prior	
					   
					   --Source System
					   LEFT JOIN source_system_description ssd_now ON  ssd_now.source_system_id = sca_now.source_system_id
					   LEFT JOIN source_system_description ssd_prior ON  ssd_prior.source_system_id = sca_prior.source_system_id
					   
					   -- Netting Counterparty ID
					   LEFT JOIN source_counterparty nsc_now ON nsc_now.source_counterparty_id = sca_now.netting_parent_counterparty_id
					   LEFT JOIN source_counterparty nsc_prior ON nsc_prior.source_counterparty_id = sca_prior.netting_parent_counterparty_id
					   
					   -- Parent Counterparty ID
					   LEFT JOIN source_counterparty psc_now ON psc_now.source_counterparty_id = sca_now.parent_counterparty_id
					   LEFT JOIN source_counterparty psc_prior ON psc_prior.source_counterparty_id = sca_prior.parent_counterparty_id
					   
					   -- Entity Type
					   LEFT JOIN static_data_value et_now ON et_now.value_id = sca_now.type_of_entity
					   LEFT JOIN static_data_value et_prior ON et_prior.value_id = sca_prior.type_of_entity  
					   
						-- Invoice Delivery Method
						LEFT JOIN static_data_value idm_now ON idm_now.value_id = sca_now.delivery_method
						LEFT JOIN static_data_value idm_prior ON idm_prior.value_id = sca_prior.delivery_method  
					      
						--Payables
						LEFT JOIN counterparty_contacts cc_payables_now ON cc_payables_now.counterparty_contact_id = sca_now.payables
						LEFT JOIN counterparty_contacts cc_payables_prior ON cc_payables_prior.counterparty_contact_id = sca_prior.payables

						--Receivables
						LEFT JOIN counterparty_contacts cc_receivables_now ON cc_receivables_now.counterparty_contact_id = sca_now.receivables
						LEFT JOIN counterparty_contacts cc_receivables_prior ON cc_receivables_prior.counterparty_contact_id = sca_prior.receivables

						--Confirmation
						LEFT JOIN counterparty_contacts cc_confirmation_now ON cc_confirmation_now.counterparty_contact_id = sca_now.confirmation
						LEFT JOIN counterparty_contacts cc_confirmation_prior ON cc_confirmation_prior.counterparty_contact_id = sca_prior.confirmation

						--Credit
						LEFT JOIN counterparty_contacts cc_credit_now ON cc_credit_now.counterparty_contact_id = sca_now.credit
						LEFT JOIN counterparty_contacts cc_credit_prior ON cc_credit_prior.counterparty_contact_id = sca_prior.credit

						--Counterparty Status
						LEFT JOIN static_data_value sdv_cs_now ON sdv_cs_now.value_id = sca_now.counterparty_status
						LEFT JOIN static_data_value sdv_cs_prior ON sdv_cs_prior.value_id = sca_prior.counterparty_status  

						--Analyst
						LEFT JOIN application_users au_now ON au_now.user_login_id = sca_now.analyst
						LEFT JOIN application_users au_prior ON au_prior.user_login_id = sca_prior.analyst  

					   CROSS APPLY(
							SELECT N''Source System'' field,
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(ssd_now.source_system_name AS VARCHAR(250)) END current_value,
								CAST(ssd_prior.source_system_name AS VARCHAR(250)) prior_value
							
							UNION ALL
											
							SELECT N''Name'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.counterparty_name AS VARCHAR(250)) END current_value,
								CAST(sca_prior.counterparty_name AS VARCHAR(250)) prior_value
											   
							UNION ALL
							
							SELECT N''Description'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.counterparty_desc AS VARCHAR(250)) END current_value,
								CAST(sca_prior.counterparty_desc AS VARCHAR(250)) prior_value   
								   
							UNION ALL
							
							SELECT N''Counterparty ID'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.counterparty_id AS VARCHAR(250)) END current_value,
								CAST(sca_prior.counterparty_id AS VARCHAR(250)) prior_value
								
							UNION ALL

							SELECT N''CC Email'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.cc_email AS VARCHAR(250)) END current_value,
								CAST(sca_prior.cc_email AS VARCHAR(250)) prior_value
								
							UNION ALL

							SELECT N''BCC Email'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.bcc_email AS VARCHAR(250)) END current_value,
								CAST(sca_prior.bcc_email AS VARCHAR(250)) prior_value
								
							UNION ALL

							SELECT N''CC Remittance'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.cc_remittance AS VARCHAR(250)) END current_value,
								CAST(sca_prior.cc_remittance AS VARCHAR(250)) prior_value
								
							UNION ALL

							SELECT N''BCC Remittance'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.bcc_remittance AS VARCHAR(250)) END current_value,
								CAST(sca_prior.bcc_remittance AS VARCHAR(250)) prior_value
								
							UNION ALL

							SELECT N''Email Remittance To'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.email_remittance_to AS VARCHAR(250)) END current_value,
								CAST(sca_prior.email_remittance_to AS VARCHAR(250)) prior_value
								
							UNION ALL

							SELECT N''Invoice Delivery Method'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(idm_now.code AS VARCHAR(250)) END current_value,
								CAST(idm_prior.code AS VARCHAR(250)) prior_value
								
							UNION ALL

							SELECT N''Tax Id'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.tax_id AS VARCHAR(50)) END current_value,
								CAST(sca_prior.tax_id AS VARCHAR(50)) prior_value '
									
				SET @sql2 = '
							UNION ALL
											
							SELECT N''Netting Counterparty Name'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(nsc_now.counterparty_name AS VARCHAR(250)) END current_value,
								CAST(nsc_prior.counterparty_name AS VARCHAR(250)) prior_value
									
							UNION ALL
											
							SELECT N''Parent Counterparty Name'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(psc_now.counterparty_name AS VARCHAR(250)) END current_value,
								CAST(psc_prior.counterparty_name AS VARCHAR(250)) prior_value
								   
							UNION ALL
							
							SELECT N''Entity Type'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(et_now.code AS VARCHAR(250)) END current_value,
								CAST(et_prior.code AS VARCHAR(250)) prior_value
						
							UNION ALL	   
							
							SELECT N''Customer Duns Number'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.customer_duns_number AS VARCHAR(250)) END current_value,
								CAST(sca_prior.customer_duns_number AS VARCHAR(250)) prior_value
										   
							UNION ALL	   
							
							SELECT N''Int Ext Flag'',
								CASE 
									WHEN sca_now.user_action = ''Delete'' THEN NULL 
									ELSE CASE 
											WHEN sca_now.int_ext_flag = ''e'' THEN ''External'' 
											WHEN sca_now.int_ext_flag = ''i'' THEN ''Internal'' 
											ELSE ''Broker'' 
										 END 
								END current_value,
								CASE 
									WHEN sca_prior.int_ext_flag = ''e'' THEN ''External'' 
									WHEN sca_prior.int_ext_flag = ''i'' THEN ''Internal'' 
									ELSE ''Broker'' 
								END prior_value
								
							UNION ALL
							
							SELECT N''Counterparty Contact Title'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.counterparty_contact_title AS VARCHAR(250)) END current_value,
								CAST(sca_prior.counterparty_contact_title AS VARCHAR(250)) prior_value  
								   
							UNION ALL
							
							SELECT N''Counterparty Contact Name'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.counterparty_contact_name AS VARCHAR(250)) END current_value,
								CAST(sca_prior.counterparty_contact_name AS VARCHAR(250)) prior_value  

							UNION ALL
							
							SELECT N''Counterparty Contact ID'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.counterparty_contact_id AS VARCHAR(250)) END current_value,
								CAST(sca_prior.counterparty_contact_id AS VARCHAR(250)) prior_value  
								   
							UNION ALL
							
							SELECT N''Counterparty Contact Address 1'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.[address] AS VARCHAR(250)) END current_value,
								CAST(sca_prior.[address] AS VARCHAR(250)) prior_value  
								   
							UNION ALL
							
							SELECT N''Counterparty Contact Address 2'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.mailing_address AS VARCHAR(250)) END current_value,
								CAST(sca_prior.mailing_address AS VARCHAR(250)) prior_value
								   
							UNION ALL
							
							SELECT N''Counterparty Contact City'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.city AS VARCHAR(250)) END current_value,
								CAST(sca_prior.city AS VARCHAR(250)) prior_value
							   
							UNION ALL
							
							SELECT N''Counterparty Contact Zip'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.zip AS VARCHAR(250)) END current_value,
								CAST(sca_prior.zip AS VARCHAR(250)) prior_value
							
							UNION ALL
							
							SELECT N''Counterparty Contact Phone No'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.phone_no AS VARCHAR(250)) END current_value,
								CAST(sca_prior.phone_no AS VARCHAR(250)) prior_value
							   
							UNION ALL
							
							SELECT N''Counterparty Contact Fax'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.fax AS VARCHAR(250)) END current_value,
								CAST(sca_prior.fax AS VARCHAR(250)) prior_value 
								   
							UNION ALL
							
							SELECT N''Counterparty Contact Email'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.email AS VARCHAR(250)) END current_value,
								CAST(sca_prior.email AS VARCHAR(250)) prior_value
								   
							UNION ALL
							
							SELECT N''Payment Contact Detail Name'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.contact_name AS VARCHAR(250)) END current_value,
								CAST(sca_prior.contact_name AS VARCHAR(250)) prior_value
						   
							UNION ALL
							
							SELECT N''Payment Contact Detail Title'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.contact_title AS VARCHAR(250)) END current_value,
								CAST(sca_prior.contact_title AS VARCHAR(250)) prior_value
								
							UNION ALL
					
							SELECT N''Instruction'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.instruction AS VARCHAR(250)) END current_value,
								CAST(sca_prior.instruction AS VARCHAR(250)) prior_value '
								   
			SET @sql3 =		'
							UNION ALL
							
							SELECT N''Payment Contact Detail Address1'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.contact_address AS VARCHAR(250)) END current_value,
								CAST(sca_prior.contact_address AS VARCHAR(250)) prior_value
								   
							UNION ALL
							
							SELECT N''Payment Contact Detail Address2'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.contact_address2 AS VARCHAR(250)) END current_value,
								CAST(sca_prior.contact_address2 AS VARCHAR(250)) prior_value
								   
							UNION ALL
							
							SELECT N''Payment Contact Detail Phone'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.contact_phone AS VARCHAR(250)) END current_value,
								CAST(sca_prior.contact_phone AS VARCHAR(250)) prior_value
								   
							UNION ALL
							
							SELECT N''Payment Contact Detail Fax'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.contact_fax AS VARCHAR(250)) END current_value,
								CAST(sca_prior.contact_fax AS VARCHAR(250)) prior_value
								   
							UNION ALL
							
							SELECT N''Payment Contact Detail Email'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.contact_email AS VARCHAR(250)) END current_value,
								CAST(sca_prior.contact_email AS VARCHAR(250)) prior_value
								   
							UNION ALL
							
							SELECT N''Active'',
								CASE 
									WHEN sca_now.user_action = ''Delete'' THEN NULL 
									ELSE CASE WHEN sca_now.is_active = ''y'' THEN ''Yes'' ELSE ''No'' END 
								END current_value,
								CASE 
									WHEN sca_prior.is_active = ''y'' THEN ''Yes'' ELSE ''No'' 
								END prior_value
							
							UNION ALL
							SELECT N''Notes'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sca_now.counterparty_contact_notes AS VARCHAR(250)) END current_value,
								CAST(sca_prior.counterparty_contact_notes AS VARCHAR(250)) prior_value
											
							UNION ALL

							SELECT N''Payables'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(cc_payables_now.id AS VARCHAR(100)) END current_value,
								CAST(cc_payables_prior.id AS VARCHAR(100)) prior_value
								   
							UNION ALL

							SELECT N''Receivables'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(cc_receivables_now.id AS VARCHAR(100)) END current_value,
								CAST(cc_confirmation_prior.id AS VARCHAR(100)) prior_value
								   
							UNION ALL

							SELECT N''Confirmation'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(cc_confirmation_now.id AS VARCHAR(100)) END current_value,
								CAST(cc_confirmation_prior.id AS VARCHAR(100)) prior_value
								   
							UNION ALL
							
							SELECT N''Credit'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(cc_credit_now.id AS VARCHAR(100)) END current_value,
								CAST(cc_credit_prior.id AS VARCHAR(100)) prior_value
								   
							UNION ALL
							SELECT N''Counterparty Status'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sdv_cs_now.code AS VARCHAR(500)) END current_value,
								CAST(sdv_cs_prior.code AS VARCHAR(500)) prior_value

							UNION ALL
							SELECT N''Counterparty Status'',
								CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(au_now.user_f_name + '' '' + ISNULL(au_now.user_m_name, '''') + '' '' + au_now.user_l_name AS VARCHAR(250)) END current_value,
								CAST(au_prior.user_f_name + '' '' + ISNULL(au_prior.user_m_name, '''') + '' '' + au_prior.user_l_name AS VARCHAR(250)) prior_value
											
						) cols
					WHERE ISNULL(sca_now.update_ts, sca_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') AND ssd_now.source_system_id = ''' + CAST(@source_system_id AS VARCHAR(2)) + '''' + CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND sca_now.source_counterparty_id IN (' + @source_id +')' ELSE '' END 
					
			DECLARE @sql4 VARCHAR(MAX)
			DECLARE @sql5 VARCHAR(MAX)
			
			SET @sql4 = ' 
							UNION ALL 
							SELECT  UPPER(LEFT(CASE WHEN sca_now.user_action= ''INSERT'' THEN ''update'' ELSE sca_now.user_action END, 1))   
									+ SUBSTRING(CASE WHEN sca_now.user_action = ''INSERT'' THEN ''Update'' ELSE sca_now.user_action END, 2, LEN(sca_now.user_action)) [User Action],
								   ''Counterparty'' [Static Data Name],
								   sca_now.counterparty_name [Name],
								   cols.field [Field],
								   prior_value [Prior Value],
								   current_value [Current Value],
								   CASE WHEN sca_now.user_action = ''insert'' 
										THEN COALESCE(sca_now.create_user, sca_now.update_user, dbo.FNADBUser())
										ELSE COALESCE(sca_now.update_user, sca_now.create_user, dbo.FNADBUser()) 
								   END [Update User],
								   sca_now.create_ts [Update TS]
								   --,sc_now.currency_name child_unique_value
						FROM counterparty_bank_info_audit sca_now 
						INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sca_now.counterparty_id
								OUTER APPLY(
								   SELECT TOP 1 * FROM counterparty_bank_info_audit oa
									WHERE oa.counterparty_id = sca_now.counterparty_id
										and oa.bank_id = sca_now.bank_id
										AND oa.audit_id < sca_now.audit_id
						   ORDER BY counterparty_id, update_ts DESC
					
						) sca_prior	
						LEFT JOIN source_currency sc_now ON sc_now.source_currency_id = sca_now.currency
						LEFT JOIN source_currency sc_prior ON sc_prior.source_currency_id = sca_prior.currency
						CROSS APPLY(
									SELECT CASE WHEN sca_now.user_action = ''delete'' THEN ''Bank Information Deleted'' ELSE N''Bank ID'' END field,
										CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
										ELSE CAST(sca_now.bank_id AS VARCHAR(250)) END current_value,
										CASE WHEN sca_now.user_action = ''Insert'' THEN NULL 
										ELSE  CAST(sca_prior.bank_id AS VARCHAR(250)) END prior_value
										
									
									UNION ALL 
									
									SELECT CASE WHEN sca_now.user_action = ''delete'' THEN ''Bank Information Deleted'' ELSE N''Bank name'' END field,
										CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
										ELSE CAST(sca_now.bank_name AS VARCHAR(250)) END current_value,
										CASE WHEN sca_now.user_action = ''Insert'' THEN NULL 
										ELSE  CAST(sca_prior.bank_name AS VARCHAR(250)) END prior_value
										
										UNION ALL 
									
									SELECT CASE WHEN sca_now.user_action = ''delete'' THEN ''Bank Information Deleted'' ELSE N''Wire ABA'' END field,
										CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
										ELSE CAST(sca_now.wire_ABA AS VARCHAR(250)) END current_value,
										CASE WHEN sca_now.user_action = ''Insert'' THEN NULL 
										ELSE  CAST(sca_prior.wire_ABA AS VARCHAR(250)) END prior_value
										
										UNION ALL 
									
									SELECT CASE WHEN sca_now.user_action = ''delete'' THEN ''Bank Information Deleted'' ELSE N''Swift Number'' END field,
										CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
										ELSE CAST(sca_now.ACH_ABA AS VARCHAR(250)) END current_value,
										CASE WHEN sca_now.user_action = ''Insert'' THEN NULL 
										ELSE  CAST(sca_prior.ACH_ABA AS VARCHAR(250)) END prior_value
										
										UNION ALL 
									
									SELECT CASE WHEN sca_now.user_action = ''delete'' THEN ''Bank Information Deleted'' ELSE N''Account No'' END field,
										CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
										ELSE CAST(sca_now.Account_no AS VARCHAR(250)) END current_value,
										CASE WHEN sca_now.user_action = ''Insert'' THEN NULL 
										ELSE  CAST(sca_prior.Account_no AS VARCHAR(250)) END prior_value
										
									UNION ALL 
									
									SELECT CASE WHEN sca_now.user_action = ''delete'' THEN ''Bank Information Deleted'' ELSE N''Address1'' END field,
										CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
										ELSE CAST(sca_now.Address1 AS VARCHAR(250)) END current_value,
										CASE WHEN sca_now.user_action = ''Insert'' THEN NULL 
										ELSE  CAST(sca_prior.Address1 AS VARCHAR(250)) END prior_value			
										
									UNION ALL 
									
									SELECT CASE WHEN sca_now.user_action = ''delete'' THEN ''Bank Information Deleted'' ELSE N''Address2'' END field,
										CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
										ELSE CAST(sca_now.Address2 AS VARCHAR(250)) END current_value,
										CASE WHEN sca_now.user_action = ''Insert'' THEN NULL 
										ELSE  CAST(sca_prior.Address2 AS VARCHAR(250)) END prior_value
										
									UNION ALL
									 
									SELECT CASE WHEN sca_now.user_action = ''delete'' THEN ''Bank Information Deleted'' ELSE N''Account Name'' END  field,
										CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
										ELSE CAST(sca_now.account_name AS VARCHAR(250)) END current_value,
										CASE WHEN sca_now.user_action = ''Insert'' THEN NULL 
										ELSE  CAST(sca_prior.account_name AS VARCHAR(250)) END prior_value
									
									UNION ALL 
										
									SELECT CASE WHEN sca_now.user_action = ''delete'' THEN ''Bank Information Deleted'' ELSE N''Reference'' END field,
										CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
										ELSE CAST(sca_now.reference AS VARCHAR(250)) END current_value,
										CASE WHEN sca_now.user_action = ''Insert'' THEN NULL 
										ELSE  CAST(sca_prior.reference AS VARCHAR(250)) END prior_value
										
									UNION ALL 
										
									SELECT CASE WHEN sca_now.user_action = ''delete'' THEN ''Bank Information Deleted'' ELSE N''Currency'' END field,
										CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
										ELSE CAST(sc_now.currency_name AS VARCHAR(250)) END current_value,
										CASE WHEN sca_now.user_action = ''INSERT'' THEN NULL 
										ELSE  CAST(sc_prior.currency_name AS VARCHAR(250)) END prior_value
								) cols
						WHERE ISNULL(sca_now.update_ts, sca_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
							AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') 
							AND sca_now.source_system = ''' + CAST(@source_system_id AS VARCHAR(2)) + ''' '+ CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND sca_now.counterparty_id IN (' + @source_id +')' ELSE '' END 
							
				SET @sql5 = ' 
					UNION ALL
					SELECT  UPPER(LEFT(CASE WHEN sca_now.user_action= ''insert'' THEN ''Update'' ELSE sca_now.user_action END, 1))   
								+ SUBSTRING(CASE WHEN sca_now.user_action = ''insert'' THEN ''Update'' ELSE sca_now.user_action END, 2, LEN(sca_now.user_action)) [User Action],
							   ''Counterparty'' [Static Data Name],
							   sca_now.counterparty_name [Name],
							   cols.field [Field],
							   prior_value [Prior Value],
							   current_value [Current Value],
							   CASE WHEN sca_now.user_action = ''insert'' 
									THEN COALESCE(sca_now.create_user, sca_now.update_user, dbo.FNADBUser())
									ELSE COALESCE(sca_now.update_user, sca_now.create_user, dbo.FNADBUser()) 
							   END [Update User],
							   sca_now.create_ts [Update TS]							   
					FROM counterparty_epa_account_audit sca_now 
					INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sca_now.counterparty_id
					OUTER APPLY(
					   SELECT TOP 1 * FROM counterparty_epa_account_audit oa
					   WHERE oa.counterparty_epa_account_id = sca_now.counterparty_epa_account_id
							AND oa.audit_id < sca_now.audit_id
					   ORDER BY counterparty_epa_account_id, update_ts DESC
					) sca_prior	
					LEFT JOIN static_data_value ext_now ON ext_now.value_id = sca_now.external_type_id
					LEFT JOIN static_data_value ext_prior ON ext_prior.value_id = sca_prior.external_type_id
					CROSS APPLY(
								SELECT CASE WHEN sca_now.user_action = ''delete'' THEN ''External ID Deleted'' ELSE  N''External Type ID'' END field,
									CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
									ELSE CAST(ext_now.code AS VARCHAR(250)) END current_value,
									CASE WHEN sca_now.user_action = ''Insert'' THEN NULL 
									ELSE  CAST(ext_prior.code AS VARCHAR(250)) END prior_value
								
								UNION ALL 
								
								SELECT CASE WHEN sca_now.user_action = ''delete'' THEN ''External ID Deleted'' ELSE  N''External Value'' END field,
									CASE WHEN sca_now.user_action = ''Delete'' THEN NULL 
									ELSE CAST(sca_now.external_value AS VARCHAR(250)) END current_value,
									CASE WHEN sca_now.user_action = ''Insert'' THEN NULL 
									ELSE  CAST(sca_prior.external_value AS VARCHAR(250)) END prior_value
								) cols
					WHERE ISNULL(sca_now.update_ts, sca_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') 
						AND sca_now.source_system = ''' + CAST(@source_system_id AS VARCHAR(2)) + ''' '+ CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND sca_now.counterparty_id IN (' + @source_id +')' ELSE '' END 
					
		--PRINT @sql 
		--PRINT @sql2 
		--PRINT @sql3	
		--PRINT @sql4
		--PRINT @sql5
		EXEC(@sql + @sql2 + @sql3 + @sql4 + @sql5)	
	END
	
	-- Deal Type
	IF @static_data = 19904 OR @all_result = 'y'
	BEGIN
		
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id =  ISNULL(@static_data, 19904)
		
		SET @sql = @group_result + '
					SELECT UPPER(LEFT(sdta_now.user_action, 1)) + SUBSTRING(sdta_now.user_action, 2, LEN(sdta_now.user_action)) [User Action],
						   ''' + @static_data_name + ''' [Static Data Name],
						   sdta_now.source_deal_type_name [Name],
						   cols.field [Field],
						   prior_value [Prior Value],
						   current_value [Current Value],
						   CASE WHEN sdta_now.user_action = ''insert'' 
								THEN COALESCE(sdta_now.create_user, sdta_now.update_user, dbo.FNADBUser())
								ELSE COALESCE(sdta_now.update_user, sdta_now.create_user, dbo.FNADBUser()) 
						   END [Update User],
						   ISNULL(sdta_now.update_ts,sdta_now.create_ts) [Update TS]
					FROM   source_deal_type_audit sdta_now
					OUTER APPLY(
								   SELECT TOP 1 * FROM source_deal_type_audit
								   WHERE  audit_id < sdta_now.audit_id AND source_deal_type_id = sdta_now.source_deal_type_id
								   ORDER BY audit_id DESC
							   ) sdta_prior

					--Source System
					LEFT JOIN source_system_description ssd_now ON  ssd_now.source_system_id = sdta_now.source_system_id
					LEFT JOIN source_system_description ssd_prior ON  ssd_prior.source_system_id = sdta_prior.source_system_id

					CROSS APPLY(
						SELECT N''Source System'' field,
							CASE WHEN sdta_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(ssd_now.source_system_name AS VARCHAR(250)) END current_value,
							CAST(ssd_prior.source_system_name AS VARCHAR(250)) prior_value
						
						UNION ALL
						
						SELECT N''Name'',
							CASE WHEN sdta_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(sdta_now.source_deal_type_name AS VARCHAR(250)) END current_value,
							CAST(sdta_prior.source_deal_type_name AS VARCHAR(250)) prior_value
							   
						UNION ALL
						
						SELECT N''Description'',
							CASE WHEN sdta_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(sdta_now.source_deal_desc AS VARCHAR(250)) END current_value,
							CAST(sdta_prior.source_deal_desc AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Deal Type ID'',
							CASE WHEN sdta_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(sdta_now.deal_type_id AS VARCHAR(250)) END current_value,
							CAST(sdta_prior.deal_type_id AS VARCHAR(250)) prior_value

						UNION ALL
						
						SELECT N''Sub Type'',		   
							CASE 
								WHEN sdta_now.user_action = ''Delete'' THEN NULL 
								ELSE CASE WHEN sdta_now.sub_type = ''y'' THEN ''Yes'' ELSE ''No'' END 
							END current_value,
							CASE WHEN sdta_prior.sub_type = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value
						
						UNION ALL
						
						SELECT N''Expiration Applies'',
							CASE 
								WHEN sdta_now.user_action = ''Delete'' THEN NULL 
								ELSE CASE WHEN sdta_now.expiration_applies = ''y'' THEN ''Yes'' ELSE ''No'' END 
							END current_value,
							CASE WHEN sdta_prior.expiration_applies = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value

						UNION ALL
						
						SELECT N''Credit Source not required'',
							CASE 
								WHEN sdta_now.user_action = ''Delete'' THEN NULL 
								ELSE CASE WHEN sdta_now.disable_gui_groups = ''y'' THEN ''Yes'' ELSE ''No'' END 
							END current_value,
							CASE WHEN sdta_prior.disable_gui_groups = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value		   				
					)  cols
					WHERE ISNULL(sdta_now.update_ts,sdta_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') AND sdta_now.source_system_id = ''' + cast(@source_system_id AS VARCHAR(2)) + '''		
					ORDER BY sdta_now.audit_id DESC'
					
		--PRINT @sql			
		EXEC(@sql)		
	END
	
	-- Traders
	IF @static_data = 19905 OR @all_result = 'y'
	BEGIN
		
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id =  ISNULL(@static_data, 19905)
		
		SET @sql = @group_result + '
					SELECT UPPER(LEFT(sta_now.user_action, 1)) + SUBSTRING(sta_now.user_action, 2, LEN(sta_now.user_action)) [User Action],
						   ''' + @static_data_name + ''' [Static Data Name],
						   sta_now.trader_name [Name],
						   cols.field [Field],
						   prior_value [Prior Value],
						   current_value [Current Value],
						   CASE WHEN sta_now.user_action = ''insert'' 
								THEN COALESCE(sta_now.create_user, sta_now.update_user, dbo.FNADBUser())
								ELSE COALESCE(sta_now.update_user, sta_now.create_user, dbo.FNADBUser()) 
						   END [Update User],
						   ISNULL(sta_now.update_ts,sta_now.create_ts) [Update TS]
					FROM   source_traders_audit sta_now		
					OUTER APPLY(
							   SELECT TOP 1 * FROM source_traders_audit
							   WHERE  audit_id < sta_now.audit_id AND source_trader_id = sta_now.source_trader_id
							   ORDER BY audit_id DESC
						   ) sta_prior
						   
					--Source System
					LEFT JOIN source_system_description ssd_now ON  ssd_now.source_system_id = sta_now.source_system_id
					LEFT JOIN source_system_description ssd_prior ON  ssd_prior.source_system_id = sta_prior.source_system_id

					CROSS APPLY(
						SELECT N''Source System'' field,
							CASE WHEN sta_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(ssd_now.source_system_name AS VARCHAR(250)) END current_value,
							CAST(ssd_prior.source_system_name AS VARCHAR(250)) prior_value
						
						UNION ALL
						
						SELECT N''Name'',
							CASE WHEN sta_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(sta_now.trader_name AS VARCHAR(250)) END current_value,
							CAST(sta_prior.trader_name AS VARCHAR(250)) prior_value

						UNION ALL
						
						SELECT N''Description'',
							CASE WHEN sta_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(sta_now.trader_desc AS VARCHAR(250)) END current_value,
							CAST(sta_prior.trader_desc AS VARCHAR(250)) prior_value
							   
						UNION ALL
						
						SELECT N''Trader Id'',
							CASE WHEN sta_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(sta_now.trader_id AS VARCHAR(250)) END current_value,
							CAST(sta_prior.trader_id AS VARCHAR(250)) prior_value				   			   
							   
						UNION ALL
						
						SELECT N''User'',
							CASE WHEN sta_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(sta_now.user_login_id AS VARCHAR(250)) END current_value,
							CAST(sta_prior.user_login_id AS VARCHAR(250)) prior_value
								
					) cols
					WHERE ISNULL(sta_now.update_ts,sta_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') AND sta_now.source_system_id = ''' + cast(@source_system_id AS VARCHAR(2)) + '''		
					ORDER BY sta_now.audit_id DESC'	

		--PRINT @sql			
		EXEC(@sql)
	END
	
	-- UOM
	IF @static_data = 19906 OR @all_result = 'y'
	BEGIN
		
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id =  ISNULL(@static_data, 19906)
		
		SET @sql = @group_result + '
					SELECT UPPER(LEFT(sua_now.user_action, 1)) + SUBSTRING(sua_now.user_action, 2, LEN(sua_now.user_action)) [User Action],
						   ''' + @static_data_name + ''' [Static Data Name],
						   sua_now.uom_name [Name],
						   cols.field [Field],
						   prior_value [Prior Value],
						   current_value [Current Value],
						   CASE WHEN sua_now.user_action = ''insert'' 
								THEN COALESCE(sua_now.create_user, sua_now.update_user, dbo.FNADBUser())
								ELSE COALESCE(sua_now.update_user, sua_now.create_user, dbo.FNADBUser()) 
						   END [Update User],
						   ISNULL(sua_now.update_ts,sua_now.create_ts) [Update TS]
					FROM source_uom_audit sua_now		   
					   OUTER APPLY(
								   SELECT TOP 1 * FROM source_uom_audit
								   WHERE  audit_id < sua_now.audit_id AND source_uom_id = sua_now.source_uom_id
								   ORDER BY audit_id DESC
							   ) sua_prior 
					   
					   --Source System
					   LEFT JOIN source_system_description ssd_now ON  ssd_now.source_system_id = sua_now.source_system_id
					   LEFT JOIN source_system_description ssd_prior ON  ssd_prior.source_system_id = sua_prior.source_system_id
					          
					   CROSS APPLY(
							SELECT N''Source System'' field,
								CASE WHEN sua_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(ssd_now.source_system_name AS VARCHAR(250)) END current_value,
								CAST(ssd_prior.source_system_name AS VARCHAR(250)) prior_value
							
							UNION ALL
							
							SELECT N''Name'',
								CASE WHEN sua_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sua_now.uom_name AS VARCHAR(250)) END current_value,
								CAST(sua_prior.uom_name AS VARCHAR(250)) prior_value   	   

							UNION ALL
							
							SELECT N''Description'',
								CASE WHEN sua_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sua_now.uom_desc AS VARCHAR(250)) END current_value,
								CAST(sua_prior.uom_desc AS VARCHAR(250)) prior_value			   
								   
							UNION ALL
							
							SELECT N''UOM Id'',
								CASE WHEN sua_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(sua_now.uom_id AS VARCHAR(250)) END current_value,
								CAST(sua_prior.uom_id AS VARCHAR(250)) prior_value			   
								
					   ) cols
					WHERE ISNULL(sua_now.update_ts,sua_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') AND sua_now.source_system_id = ''' + cast(@source_system_id AS VARCHAR(2)) + '''		
					ORDER BY sua_now.audit_id DESC'

		--PRINT @sql			
		EXEC(@sql)
	END
	
	-- UOM Conversion
	IF @static_data = 19907 OR @all_result = 'y'
	BEGIN
		
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id =  ISNULL(@static_data, 19907)
		
		SET @sql = @group_result + '
					SELECT UPPER(LEFT(rvuca_now.user_action, 1)) + SUBSTRING(rvuca_now.user_action, 2, LEN(rvuca_now.user_action)) [User Action],
						   ''' + @static_data_name + ''' [Static Data Name],
						   u_now.uom_name + '' To '' + t_now.uom_name [Name],
						   cols.field [Field],
						   prior_value [Prior Value],
						   current_value [Current Value],
						   CASE WHEN rvuca_now.user_action = ''insert'' 
								THEN COALESCE(rvuca_now.create_user, rvuca_now.update_user, dbo.FNADBUser())
								ELSE COALESCE(rvuca_now.update_user, rvuca_now.create_user, dbo.FNADBUser()) 
						   END [Update User],
						   ISNULL(rvuca_now.update_ts,rvuca_now.create_ts) [Update TS]
					FROM rec_volume_unit_conversion_audit rvuca_now		   
					OUTER APPLY(
							   SELECT TOP 1 * FROM rec_volume_unit_conversion_audit
							   WHERE  audit_id < rvuca_now.audit_id AND rec_volume_unit_conversion_id = rvuca_now.rec_volume_unit_conversion_id
							   ORDER BY audit_id DESC
						) rvuca_prior
					   
					--State
					LEFT JOIN static_data_value state_now ON state_now.value_id = rvuca_now.state_value_id
					LEFT JOIN static_data_value state_prior ON state_prior.value_id = rvuca_prior.state_value_id

					--Curve
					LEFT JOIN source_price_curve_def curve_now ON curve_now.source_curve_def_id = rvuca_now.curve_id
					LEFT JOIN source_price_curve_def curve_prior ON curve_prior.source_curve_def_id = rvuca_now.curve_id

					--To Curve
					LEFT JOIN source_price_curve_def to_curve_now ON to_curve_now.source_curve_def_id = rvuca_now.to_curve_id
					LEFT JOIN source_price_curve_def to_curve_prior ON to_curve_prior.source_curve_def_id = rvuca_now.to_curve_id

					--Assignment
					LEFT JOIN static_data_value a_now ON  a_now.value_id = rvuca_now.assignment_type_value_id
					LEFT JOIN static_data_value a_prior ON  a_prior.value_id = rvuca_prior.assignment_type_value_id

					--From UOM
					LEFT JOIN source_uom u_now ON u_now.source_uom_id = rvuca_now.from_source_uom_id 
					LEFT JOIN source_uom u_prior ON u_prior.source_uom_id = rvuca_prior.from_source_uom_id

					--To UOM
					LEFT JOIN source_uom t_now ON t_now.source_uom_id = rvuca_now.to_source_uom_id 
					LEFT JOIN source_uom t_prior ON t_prior.source_uom_id = rvuca_prior.to_source_uom_id

					CROSS APPLY(
						SELECT N''State'' field,
							CASE WHEN rvuca_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(state_now.code AS VARCHAR(250)) END current_value,
							CAST(state_prior.code AS VARCHAR(250)) prior_value
						
						UNION ALL
						
						SELECT N''Curve'',
							CASE WHEN rvuca_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(curve_now.curve_name AS VARCHAR(250)) END current_value,
							CAST(curve_prior.curve_name AS VARCHAR(250)) prior_value		   	 

						UNION ALL
						
						SELECT N''To Curve'',
							CASE WHEN rvuca_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(to_curve_now.curve_name AS VARCHAR(250)) END current_value,
							CAST(to_curve_prior.curve_name AS VARCHAR(250)) prior_value

						UNION ALL
						
						SELECT N''Assignment'',
							CASE WHEN rvuca_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(a_now.code AS VARCHAR(250)) END current_value,
							CAST(a_prior.code AS VARCHAR(250)) prior_value		   
							   
						UNION ALL
						
						SELECT N''From UOM'',
							CASE WHEN rvuca_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(u_now.uom_name AS VARCHAR(250)) END current_value,
							CAST(u_prior.uom_name AS VARCHAR(250)) prior_value	

						UNION ALL
						
						SELECT N''To UOM'',
							CASE WHEN rvuca_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(t_now.uom_name AS VARCHAR(250)) END current_value,
							CAST(t_prior.uom_name AS VARCHAR(250)) prior_value		   
							   
						UNION ALL
						
						SELECT N''Conv Factor'',
							CASE WHEN rvuca_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(rvuca_now.conversion_factor AS VARCHAR(250)) END current_value,
							CAST(rvuca_prior.conversion_factor AS VARCHAR(250)) prior_value
							   
						UNION ALL
						
						SELECT N''Convert Env Product Label'',
							CASE WHEN rvuca_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(rvuca_now.curve_label AS VARCHAR(250)) END current_value,
							CAST(rvuca_prior.curve_label AS VARCHAR(250)) prior_value
							   
						UNION ALL
						
						SELECT N''Convert UOM Label'',
							CASE WHEN rvuca_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(rvuca_now.uom_label AS VARCHAR(250)) END current_value,
							CAST(rvuca_prior.uom_label AS VARCHAR(250)) prior_value
						) cols
					WHERE ISNULL(rvuca_now.update_ts,rvuca_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''')		
					ORDER BY rvuca_now.audit_id DESC'
		
		--PRINT @sql	
		EXEC(@sql)
	END
	
	-- Price Curve Definitions
	IF @static_data = 19908 OR @all_result = 'y'
	BEGIN
		
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id =  ISNULL(@static_data, 19908)
		
		SET @sql = @group_result + '
					SELECT UPPER(LEFT(spcda_now.user_action, 1)) + SUBSTRING(spcda_now.user_action, 2, LEN(spcda_now.user_action)) [User Action],
						   ''' + @static_data_name + ''' [Static Data Name],
						   spcda_now.curve_name [Name],
						   cols.field [Field],
						   prior_value [Prior Value],
						   current_value [Current Value],
						   CASE WHEN spcda_now.user_action = ''insert'' 
								THEN COALESCE(spcda_now.create_user, spcda_now.update_user, dbo.FNADBUser())
								ELSE COALESCE(spcda_now.update_user, spcda_now.create_user, dbo.FNADBUser()) 
						   END [Update User],
						   ISNULL(spcda_now.update_ts,spcda_now.create_ts) [Update TS]
					FROM   source_price_curve_def_audit spcda_now
					OUTER APPLY(
								   SELECT TOP 1 * FROM source_price_curve_def_audit
								   WHERE  audit_id < spcda_now.audit_id AND source_curve_def_id = spcda_now.source_curve_def_id
								   ORDER BY audit_id DESC
							   ) spcda_prior

					--Source System
					LEFT JOIN source_system_description ssd_now ON  ssd_now.source_system_id = spcda_now.source_system_id
					LEFT JOIN source_system_description ssd_prior ON  ssd_prior.source_system_id = spcda_prior.source_system_id

					--Commodity 
					LEFT JOIN source_commodity sc_now ON sc_now.source_commodity_id = spcda_now.commodity_id
					LEFT JOIN source_commodity sc_prior ON sc_prior.source_commodity_id = spcda_prior.commodity_id 

					--UOM ID
					LEFT JOIN source_uom su_now ON su_now.source_uom_id = spcda_now.uom_id
					LEFT JOIN source_uom su_prior ON su_prior.source_uom_id = spcda_prior.uom_id

					--Source Curve Type Value ID
					LEFT JOIN static_data_value sdv_now ON sdv_now.value_id = spcda_now.source_curve_type_value_id
					LEFT JOIN static_data_value sdv_prior ON sdv_prior.value_id = spcda_prior.source_curve_type_value_id

					--Source Currency ID
					LEFT JOIN source_currency sco_now ON sco_now.source_currency_id = spcda_now.source_currency_id
					LEFT JOIN source_currency sco_prior ON sco_prior.source_currency_id = spcda_prior.source_currency_id

					--Source Currency To ID
					LEFT JOIN source_currency sco_to_now ON sco_to_now.source_currency_id = spcda_now.source_currency_to_id
					LEFT JOIN source_currency sco_to_prior ON sco_to_prior.source_currency_id = spcda_prior.source_currency_to_id

					--Granularity
					LEFT JOIN static_data_value g_now ON g_now.value_id = spcda_now.Granularity
					LEFT JOIN static_data_value g_prior ON g_prior.value_id = spcda_prior.Granularity

					--Proxy Curve
					LEFT JOIN source_price_curve_def pc_now ON pc_now.source_curve_def_id = spcda_now.proxy_source_curve_def_id
					LEFT JOIN source_price_curve_def pc_prior ON pc_prior.source_curve_def_id = spcda_prior.proxy_source_curve_def_id

					--Proxy Curve 2
					LEFT JOIN source_price_curve_def pc2_now ON pc2_now.source_curve_def_id = spcda_now.monthly_index
					LEFT JOIN source_price_curve_def pc2_prior ON pc2_prior.source_curve_def_id = spcda_prior.monthly_index 

					--Proxy Curve Name
					LEFT JOIN source_price_curve_def pcn_now ON pcn_now.source_curve_def_id = spcda_now.proxy_curve_id
					LEFT JOIN source_price_curve_def pcn_prior ON pcn_prior.source_curve_def_id = spcda_prior.proxy_curve_id

					--Expiration Calendar
					LEFT JOIN static_data_value ec_now ON ec_now.value_id = spcda_now.exp_calendar_id
					LEFT JOIN static_data_value ec_prior ON ec_prior.value_id = spcda_prior.exp_calendar_id

					--Fair Value Reporting Group
					LEFT JOIN static_data_value fv_now ON fv_now.value_id = spcda_now.fv_level
					LEFT JOIN static_data_value fv_prior ON fv_prior.value_id = spcda_prior.fv_level

					--Risk Bucket
					LEFT JOIN source_price_curve_def rb_now ON rb_now.source_curve_def_id = spcda_now.risk_bucket_id
					LEFT JOIN source_price_curve_def rb_prior ON rb_prior.source_curve_def_id = spcda_prior.risk_bucket_id 

					--Block Definition
					LEFT JOIN static_data_value bd_now ON bd_now.value_id = spcda_now.block_define_id
					LEFT JOIN static_data_value bd_prior ON bd_prior.value_id = spcda_prior.block_define_id

					--Pro_nowgram Scope
					LEFT JOIN static_data_value ps_now ON ps_now.value_id = spcda_now.program_scope_value_id
					LEFT JOIN static_data_value ps_prior ON ps_prior.value_id = spcda_prior.program_scope_value_id

					--Simulation Model
					--LEFT JOIN monte_carlo_model_parameter mcmp_now ON mcmp_now.monte_carlo_model_parameter_id = spcda_now.monte_carlo_model_parameter_id
					--LEFT JOIN monte_carlo_model_parameter mcmp_prior ON mcmp_prior.monte_carlo_model_parameter_id = spcda_prior.monte_carlo_model_parameter_id

					--Index Group
					LEFT JOIN static_data_value ig_now ON ig_now.value_id = spcda_now.index_group
					LEFT JOIN static_data_value ig_prior ON ig_prior.value_id = spcda_prior.index_group

					--Position UOM
					LEFT JOIN source_uom pu_now ON pu_now.source_uom_id = spcda_now.display_uom_id
					LEFT JOIN source_uom pu_prior ON pu_prior.source_uom_id = spcda_prior.display_uom_id

					--Settlement Curve
					LEFT JOIN source_price_curve_def sec_now ON sec_now.source_curve_def_id = spcda_now.settlement_curve_id
					LEFT JOIN source_price_curve_def sec_prior ON sec_prior.source_curve_def_id = spcda_prior.settlement_curve_id

					--Hourly Break Down
					LEFT JOIN static_data_value hbd_now ON hbd_now.value_id = spcda_now.hourly_volume_allocation
					LEFT JOIN static_data_value hbd_prior ON hbd_prior.value_id = spcda_prior.hourly_volume_allocation

					--Time Zone
					LEFT JOIN static_data_value tz_now ON tz_now.value_id = spcda_now.time_zone
					LEFT JOIN static_data_value tz_prior ON tz_prior.value_id = spcda_prior.time_zone

					--User Defined Block
					LEFT JOIN static_data_value udfb_now ON udfb_now.value_id = spcda_now.udf_block_group_id
					LEFT JOIN static_data_value udfb_prior ON udfb_prior.value_id = spcda_prior.udf_block_group_id

					--Ratio Option
					LEFT JOIN static_data_value ro_now ON ro_now.value_id = spcda_now.ratio_option
					LEFT JOIN static_data_value ro_prior ON ro_prior.value_id = spcda_prior.ratio_option

					--Time of Use
					LEFT JOIN static_data_value tou_now ON tou_now.value_id = spcda_now.curve_tou
					LEFT JOIN static_data_value tou_prior ON tou_prior.value_id = spcda_prior.curve_tou

					--Pro_nowxy Curve 3
					LEFT JOIN source_price_curve_def pxc_now ON pxc_now.source_curve_def_id = spcda_now.proxy_curve_id3
					LEFT JOIN source_price_curve_def pxc_prior ON pxc_prior.source_curve_def_id = spcda_prior.proxy_curve_id3

					--Formula
					LEFT JOIN formula_editor fe_now ON fe_now.formula_id = spcda_now.formula_id
					LEFT JOIN formula_editor fe_prior ON fe_prior.formula_id = spcda_prior.formula_id

					--Reference Curve
					LEFT JOIN source_price_curve_def rfc_now ON rfc_now.source_curve_def_id = spcda_now.reference_curve_id
					LEFT JOIN source_price_curve_def rfc_prior ON rfc_prior.source_curve_def_id = spcda_prior.reference_curve_id' 

		SET @sql2  = '
						CROSS APPLY(
						SELECT N''Source System'' field,
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(ssd_now.source_system_name AS VARCHAR(250)) END current_value,
							CAST(ssd_prior.source_system_name AS VARCHAR(250)) prior_value
						       
						UNION ALL
						
						SELECT N''Name'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(spcda_now.curve_name AS VARCHAR(250)) END current_value,
							CAST(spcda_prior.curve_name AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Description'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(spcda_now.curve_des AS VARCHAR(250)) END current_value,
							CAST(spcda_prior.curve_des AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Curve ID'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(spcda_now.curve_id AS VARCHAR(250)) END current_value,
							CAST(spcda_prior.curve_id AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Market Value ID'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(spcda_now.market_value_id AS VARCHAR(250)) END current_value,
							CAST(spcda_prior.market_value_id AS VARCHAR(250)) prior_value

						UNION ALL
	
						SELECT N''Market Value Description'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(spcda_now.market_value_desc AS VARCHAR(250)) END current_value,
							CAST(spcda_prior.market_value_desc AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Commodity ID'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(sc_now.commodity_id AS VARCHAR(250)) END current_value,
							CAST(sc_prior.commodity_id AS VARCHAR(250)) prior_value
						          
						UNION ALL
						
						SELECT N''UOM ID'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(su_now.uom_name AS VARCHAR(250)) END current_value,
							CAST(su_prior.uom_name AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Source Curve Type Value ID'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(sdv_now.code AS VARCHAR(250)) END current_value,
							CAST(sdv_prior.code AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Source Currency ID'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(sco_now.currency_name AS VARCHAR(250)) END current_value,
							CAST(sco_prior.currency_name AS VARCHAR(250)) prior_value
					       
						UNION ALL
	
						SELECT N''Source Currency To ID'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(sco_to_now.currency_name AS VARCHAR(250)) END current_value,
							CAST(sco_to_prior.currency_name AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Granularity'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(g_now.code AS VARCHAR(250)) END current_value,
							CAST(g_prior.code AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Proxy Curve'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(pc_now.curve_name AS VARCHAR(250)) END current_value,
							CAST(pc_prior.curve_name AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Proxy Curve 2'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(pc2_now.curve_name AS VARCHAR(250)) END current_value,
							CAST(pc2_prior.curve_name AS VARCHAR(250)) prior_value

						UNION ALL
						
						SELECT N''Proxy Curve Name'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(pcn_now.curve_name AS VARCHAR(250)) END current_value,
							CAST(pcn_prior.curve_name AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Expiration Calendar'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(ec_now.code AS VARCHAR(250)) END current_value,
							CAST(ec_prior.code AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Fair Value Reporting Group'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(fv_now.code AS VARCHAR(250)) END current_value,
							CAST(fv_prior.code AS VARCHAR(250)) prior_value
					      
						UNION ALL
	
						SELECT N''Risk Bucket'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(rb_now.curve_name AS VARCHAR(250)) END current_value,
							CAST(rb_prior.curve_name AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Block Definition'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(bd_now.code AS VARCHAR(250)) END current_value,
							CAST(bd_prior.code AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Program Scope'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(ps_now.code AS VARCHAR(250)) END current_value,
							CAST(ps_prior.code AS VARCHAR(250)) prior_value
					      
						--UNION ALL
						
						--SELECT N''Simulation Model'',
						--	CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
						--  ELSE CAST(mcmp_now.monte_carlo_model_parameter_name AS VARCHAR(250)) END current_value,
						--	CAST(mcmp_prior.monte_carlo_model_parameter_name AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Index Group'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(ig_now.code AS VARCHAR(250)) END current_value,
							CAST(ig_prior.code AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Position UOM'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(pu_now.uom_name AS VARCHAR(250)) END current_value,
							CAST(pu_prior.uom_name AS VARCHAR(250)) prior_value
					       
						UNION ALL
	
						SELECT N''Settlement Curve'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(sec_now.curve_name AS VARCHAR(250)) END current_value,
							CAST(sec_prior.curve_name AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Hourly Break Down'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(hbd_now.code AS VARCHAR(250)) END current_value,
							CAST(hbd_prior.code AS VARCHAR(250)) prior_value'
					       
		  SET @sql3  = '
						UNION ALL
						
						SELECT N''Time Zone'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(tz_now.code AS VARCHAR(250)) END current_value,
							CAST(tz_prior.code AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''User Defined Block'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(udfb_now.code AS VARCHAR(250)) END current_value,
							CAST(udfb_prior.code AS VARCHAR(250)) prior_value
					       
						UNION ALL
						
						SELECT N''Ratio Option'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(ro_now.code AS VARCHAR(250)) END current_value,
							CAST(ro_prior.code AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Time of Use'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(tou_now.code AS VARCHAR(250)) END current_value,
							CAST(tou_prior.code AS VARCHAR(250)) prior_value
					       
						UNION ALL
	
						SELECT N''Proxy Curve 3'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(pxc_now.curve_name AS VARCHAR(250)) END current_value,
							CAST(pxc_prior.curve_name AS VARCHAR(250)) prior_value
						

						UNION ALL
						
						SELECT N''Formula'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(fe_now.formula AS VARCHAR(250)) END current_value,
							CAST(fe_prior.formula AS VARCHAR(250)) prior_value
							
						UNION ALL
						
						SELECT N''Environment Product'',
							CASE 
								WHEN spcda_now.user_action = ''Delete'' THEN NULL 
								ELSE CASE WHEN spcda_now.obligation = ''y'' THEN ''Yes'' ELSE ''No'' END 
							END current_value,
							CASE WHEN spcda_prior.obligation = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value
									
						UNION ALL
						
						SELECT N''Reference Curve'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(rfc_now.curve_name AS VARCHAR(250)) END current_value,
							CAST(rfc_prior.curve_name AS VARCHAR(250)) prior_value
							
						UNION ALL
						
						SELECT N''Active'',
							CASE 
								WHEN spcda_now.user_action = ''Delete'' THEN NULL 
								ELSE CASE WHEN spcda_now.is_active = ''y'' THEN ''Yes'' ELSE ''No'' END 
							END current_value,
							CASE WHEN spcda_prior.is_active = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value
								
						UNION ALL
	
						SELECT N''Always use as of date in current month'',
							CASE 
								WHEN spcda_now.user_action = ''Delete'' THEN NULL 
								ELSE CASE WHEN spcda_now.asofdate_current_month = ''y'' THEN ''Yes'' ELSE ''No'' END 
							END current_value,
							CASE WHEN spcda_prior.asofdate_current_month = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value
								
						UNION ALL
						
						SELECT N''Long Description'',
							CASE WHEN spcda_now.user_action = ''Delete'' THEN NULL 
							ELSE CAST(spcda_now.curve_definition AS VARCHAR(250)) END current_value,
							CAST(spcda_prior.curve_definition AS VARCHAR(250)) prior_value
							     
					) cols
					WHERE ISNULL(spcda_now.update_ts,spcda_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') AND spcda_now.source_system_id = ''' + cast(@source_system_id AS VARCHAR(2)) + '''' + CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND spcda_now.source_curve_def_id IN (' + @source_id +')' ELSE '' END

				SET @sql3  = @sql3 + ' ORDER BY spcda_now.audit_id DESC'
					
		--PRINT @sql
		--PRINT @sql2
		--PRINT @sql3
		EXEC(@sql + @sql2 + @sql3)
	END
	
	-- User
	IF @static_data = 19911 OR @all_result = 'y'
	BEGIN
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id = ISNULL(@static_data, 19911)	
			
		SET @sql =  @group_result + '
					SELECT UPPER(LEFT(aua_now.user_action, 1)) + SUBSTRING(aua_now.user_action, 2, LEN(aua_now.user_action)) [User Action],
							''' + @static_data_name + ''' [Static Data Name],
						   aua_now.user_f_name [Name],
						   cols.field [Field],
						   prior_value [Prior Value],
						   current_value [Current Value],
						   CASE WHEN aua_now.user_action = ''insert'' 
								THEN COALESCE(aua_now.create_user, aua_now.update_user, dbo.FNADBUser())
								ELSE COALESCE(aua_now.update_user, aua_now.create_user, dbo.FNADBUser()) 
						   END [Update User],
						   ISNULL(aua_now.update_ts,aua_now.create_ts) [Update TS]
					FROM   application_users_audit aua_now
					OUTER APPLY (
						SELECT TOP 1 * FROM application_users_audit 
						 WHERE audit_id < aua_now.audit_id AND user_login_id = aua_now.user_login_id 
						 ORDER BY audit_id DESC
					) aua_prior

					--State
					LEFT JOIN static_data_value state_now ON state_now.value_id = aua_now.state_value_id
					LEFT JOIN static_data_value state_prior ON state_prior.value_id = aua_prior.state_value_id

					--Region
					LEFT JOIN region region_now ON region_now.region_id = aua_now.region_id
					LEFT JOIN region region_prior ON region_prior.region_id = aua_prior.region_id

					--Time zone
					LEFT JOIN time_zones tz_now ON tz_now.TIMEZONE_ID = aua_now.timezone_id
					LEFT JOIN time_zones tz_prior ON tz_prior.TIMEZONE_ID = aua_prior.timezone_id

					CROSS APPLY (
						SELECT N''First Name'' field,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(aua_now.user_f_name AS VARCHAR(250)) END current_value,
							   CAST(aua_prior.user_f_name AS VARCHAR(250)) prior_value
							   
						UNION ALL
						
						SELECT N''Middle Name'' field,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(aua_now.user_m_name AS VARCHAR(250)) END current_value,
							   CAST(aua_prior.user_m_name AS VARCHAR(250)) prior_value
							   
						UNION ALL
						
						SELECT N''Last Name'' field,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(aua_now.user_l_name AS VARCHAR(250)) END current_value,
							   CAST(aua_prior.user_l_name AS VARCHAR(250)) prior_value
						
						   
						UNION ALL	   
						
						SELECT N''Title'' ,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(aua_now.user_title AS VARCHAR(250)) END current_value,
							   CAST(aua_prior.user_title AS VARCHAR(250)) prior_value
							   
						UNION ALL	   
						
						SELECT N''Employee ID'' ,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(aua_now.user_address3 AS VARCHAR(250)) END current_value,
							   CAST(aua_prior.user_address3 AS VARCHAR(250)) prior_value
							   
						UNION ALL	   
						
						SELECT N''State'' ,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(state_now.code AS VARCHAR(250)) END current_value,
							   CAST(state_prior.code AS VARCHAR(250)) prior_value
							   
						UNION ALL	   
						
						SELECT N''Address (1)'' ,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(aua_now.user_address1 AS VARCHAR(250)) END current_value,
							   CAST(aua_prior.user_address1 AS VARCHAR(250)) prior_value
							   
						UNION ALL	   
						
						SELECT N''Address (2)'' ,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(aua_now.user_address2 AS VARCHAR(250)) END current_value,
							   CAST(aua_prior.user_address2 AS VARCHAR(250)) prior_value
							   
						UNION ALL	   
						
						SELECT N''City'' ,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(aua_now.city_value_id AS VARCHAR(250)) END current_value,
							   CAST(aua_prior.city_value_id AS VARCHAR(250)) prior_value
							   
						UNION ALL	   
						
						SELECT N''Zip'' ,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(aua_now.user_zipcode AS VARCHAR(250)) END current_value,
							   CAST(aua_prior.user_zipcode AS VARCHAR(250)) prior_value
							   
						UNION ALL	   
						
						SELECT N''Office Phone'' ,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(aua_now.user_off_tel AS VARCHAR(250)) END current_value,
							   CAST(aua_prior.user_off_tel AS VARCHAR(250)) prior_value
							   
						UNION ALL	   
						
						SELECT N''Home Phone'' ,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(aua_now.user_main_tel AS VARCHAR(250)) END current_value,
							   CAST(aua_prior.user_main_tel AS VARCHAR(250)) prior_value
							   
						UNION ALL	   
						
						SELECT N''Mobile'' ,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(aua_now.user_mobile_tel AS VARCHAR(250)) END current_value,
							   CAST(aua_prior.user_mobile_tel AS VARCHAR(250)) prior_value
							   
						UNION ALL	   
						
						SELECT N''Pager'' ,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(aua_now.user_pager_tel AS VARCHAR(250)) END current_value,
							   CAST(aua_prior.user_pager_tel AS VARCHAR(250)) prior_value
							   
						UNION ALL	   
						
						SELECT N''Fax'' ,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(aua_now.user_fax_tel AS VARCHAR(250)) END current_value,
							   CAST(aua_prior.user_fax_tel AS VARCHAR(250)) prior_value
							   
						UNION ALL	   
						
						SELECT N''Email'' ,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(aua_now.user_emal_add AS VARCHAR(250)) END current_value,
							   CAST(aua_prior.user_emal_add AS VARCHAR(250)) prior_value
							   
						UNION ALL	   
						
						SELECT N''Region'' ,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(region_now.region_name AS VARCHAR(250)) END current_value,
							   CAST(region_prior.region_name AS VARCHAR(250)) prior_value
							   
						UNION ALL	   
						
						SELECT N''Time Zone'' ,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(tz_now.TIMEZONE_NAME AS VARCHAR(250)) END current_value,
							   CAST(tz_prior.TIMEZONE_NAME AS VARCHAR(250)) prior_value
							   
						UNION ALL	   
						
						SELECT N''Active User'' ,
								CASE 
									WHEN aua_now.user_action = ''Delete'' THEN NULL 
									ELSE CASE WHEN aua_now.user_active = ''y'' THEN ''Yes'' ELSE ''No'' END 
								END current_value,
								CASE WHEN aua_prior.user_active = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value
								
						UNION ALL	   
						
						SELECT N''Message Refresh Time (in secs)'' ,
							   CASE WHEN aua_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(aua_now.message_refresh_time/1000 AS VARCHAR(250)) END current_value,
							   CAST(aua_prior.message_refresh_time/1000 AS VARCHAR(250)) prior_value
							   
						UNION ALL	   
						
						SELECT N''Locked Account'' ,
								CASE 
									WHEN aua_now.user_action = ''Delete'' THEN NULL 
									ELSE CASE WHEN aua_now.lock_account = ''y'' THEN ''Yes'' ELSE ''No'' END 
								END current_value,
								CASE WHEN aua_prior.lock_account = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value
					) cols
					WHERE ISNULL(aua_now.update_ts,aua_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''')		
					ORDER BY aua_now.audit_id DESC'
			
		--PRINT @sql
		EXEC(@sql)			
	END
	
	
	-- Roles
	IF @static_data = 19912 OR @all_result = 'y'
	BEGIN
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id = ISNULL(@static_data, 19912)	
			
		SET @sql =  @group_result + '
					SELECT UPPER(LEFT(asra_now.user_action, 1)) + SUBSTRING(asra_now.user_action, 2, LEN(asra_now.user_action)) [User Action],
							''' + @static_data_name + ''' [Static Data Name],
							asra_now.role_name [Name],
							cols.field [Field],
							prior_value [Prior Value],
							current_value [Current Value],
							CASE WHEN asra_now.user_action = ''insert'' 
								THEN COALESCE(asra_now.create_user, asra_now.update_user, dbo.FNADBUser())
								ELSE COALESCE(asra_now.update_user, asra_now.create_user, dbo.FNADBUser()) 
						    END [Update User],
							ISNULL(asra_now.update_ts,asra_now.create_ts) [Update Timestamp]						   
					FROM   application_security_role_audit asra_now
					OUTER APPLY (
						SELECT TOP 1 * FROM application_security_role_audit 
						 WHERE audit_id < asra_now.audit_id AND role_id = asra_now.role_id 
						 ORDER BY audit_id DESC
					) asra_prior

					--Role Type
					LEFT JOIN static_data_value rt_now ON rt_now.value_id = asra_now.role_type_value_id
					LEFT JOIN static_data_value rt_prior ON rt_prior.value_id = asra_prior.role_type_value_id

					CROSS APPLY (
						SELECT N''Role Name'' field,
							   CASE WHEN asra_now.user_action = ''Delete'' THEN NULL 
							   ELSE CAST(asra_now.role_name AS VARCHAR(250)) END current_value,
							   CAST(asra_prior.role_name AS VARCHAR(250)) prior_value
							   
						UNION ALL
						
						SELECT N''Role Description'' field,
						   CASE WHEN asra_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(asra_now.role_description AS VARCHAR(250)) END current_value,
						   CAST(asra_prior.role_description AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Role Type'' field,
						   CASE WHEN asra_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(rt_now.code AS VARCHAR(250)) END current_value,
						   CAST(rt_prior.code AS VARCHAR(250)) prior_value
											
					) cols
					WHERE ISNULL(asra_now.update_ts,asra_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''')		
					ORDER BY asra_now.audit_id DESC'
					
		--PRINT @sql
		EXEC(@sql)	
	END
	
	-- Hourly Block
	IF @static_data = 19910 OR @all_result = 'y'
	BEGIN
		
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id = ISNULL(@static_data, 19910)	
		
		SET @sql =  @group_result + '
					SELECT 
						[User Action],
						[Static Data Name],
						[Name],
						[Field],
						[Prior Value],
						[Current Value],
						[User],
						[Timestamp]
					FROM (
						
					SELECT UPPER(LEFT(hbs_now.user_action, 1)) + SUBSTRING(hbs_now.user_action, 2, LEN(hbs_now.user_action)) [User Action],
						''' + @static_data_name + ''' [Static Data Name],
						hbs_now.code [Name],
						cols.field [Field],
						prior_value [Prior Value],
						current_value [Current Value],
						ISNULL(hbs_now.update_user, dbo.FNADBUser()) [User],
						hbs_now.update_ts [Timestamp]
					FROM   hourly_block_sdv_audit hbs_now
					OUTER APPLY (
						SELECT TOP 1 * FROM hourly_block_sdv_audit WHERE audit_id < hbs_now.audit_id AND value_id = hbs_now.value_id		 
						ORDER BY audit_id DESC
					) hbs_prior

					CROSS APPLY (
						SELECT N''Name'' field,
						   CASE WHEN hbs_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(hbs_now.code AS VARCHAR(250)) END current_value,
						   CAST(hbs_prior.code AS VARCHAR(250)) prior_value						

						UNION ALL
						
						SELECT N''Description'' ,
						   CASE WHEN hbs_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(hbs_now.description AS VARCHAR(250)) END current_value,
						   CAST(hbs_prior.description AS VARCHAR(250)) prior_value		
					) cols
					WHERE ISNULL(hbs_now.update_ts,hbs_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''')	
					
					UNION ALL
					
					SELECT UPPER(LEFT(hba_now.user_action, 1)) + SUBSTRING(hba_now.user_action, 2, LEN(hba_now.user_action)) [User Action],
							''' + @static_data_name + ''' [Static Data Name],
						   sdv.code [Name],
						   cols.field [Field],
						   prior_value [Prior Value],
						   current_value [Current Value],
						   ISNULL(hba_now.update_user, dbo.FNADBUser()) [User],
						   ISNULL(hba_now.update_ts,hba_now.create_ts) [Timestamp]
					FROM   hourly_block_audit hba_now
					OUTER APPLY(
						SELECT TOP 1 * 
						FROM   hourly_block_audit
						WHERE  audit_id < hba_now.audit_id
							   AND block_value_id = hba_now.block_value_id
							   AND week_day = hba_now.week_day
							   AND onpeak_offpeak = hba_now.onpeak_offpeak
						ORDER BY audit_id DESC
					) hba_prior
					
					LEFT JOIN static_data_value sdv ON sdv.value_id = hba_now.block_value_id

					CROSS APPLY(
							SELECT N''Block Definition'' field,
							   CASE 
									WHEN hba_now.user_action = ''Delete'' THEN ''Deleted''
									ELSE ''Block definition hours were rearranged''
							   END current_value,
							   '''' prior_value
						
					) cols
					WHERE  ISNULL(current_value, '''') <> ISNULL(prior_value, '''')
					AND ISNULL(hba_prior.update_ts,hba_prior.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''
					GROUP BY sdv.code,hba_now.user_action,hba_now.update_user,hba_now.update_ts,hba_now.create_ts, current_value, cols.field, cols.prior_value 
										
					UNION ALL
					
					SELECT UPPER(LEFT(hba_now.user_action, 1)) + SUBSTRING(hba_now.user_action, 2, LEN(hba_now.user_action)) [User Action],
							''' + @static_data_name + ''' [Static Data Name],
						   sdv.code [Name],
						   cols.field [Field],
						   prior_value [Prior Value],
						   current_value [Current Value],
						   ISNULL(hba_now.update_user, dbo.FNADBUser()) [User],
						   ISNULL(hba_now.update_ts,hba_now.create_ts) [Timestamp]
					FROM   holiday_block_audit hba_now
					OUTER APPLY(
						SELECT TOP 1 * 
						FROM   holiday_block_audit
						WHERE  audit_id < hba_now.audit_id
							   AND block_value_id = hba_now.block_value_id
							   AND onpeak_offpeak = hba_now.onpeak_offpeak
							   AND holiday_block_id = hba_now.holiday_block_id
						ORDER BY audit_id DESC
					) hba_prior

					LEFT JOIN hourly_block_audit hba ON hba.block_value_id = hba_now.block_value_id
					LEFT JOIN static_data_value sdv ON sdv.value_id = hba.block_value_id

					CROSS APPLY(
							SELECT N''Block Definition'' field,
							   CASE WHEN hba_now.user_action = ''Delete'' THEN NULL
									ELSE ''Block definition hours were rearranged''
							   END current_value,
							   '''' prior_value
						
					) cols
					WHERE ISNULL(current_value, '''') <> ISNULL(prior_value, '''')
					AND ISNULL(hba_now.update_ts,hba_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''
					GROUP BY sdv.code,hba_now.user_action,hba_now.update_user,hba_now.create_ts,hba_now.update_ts, current_value, cols.field, cols.prior_value
					
					) a
					WHERE ISNULL(a.[Prior Value], '''') <> ISNULL(a.[Current Value], '''') and a.[Name] IS NOT NULL
					GROUP BY a.[User Action], a.[Static Data Name], a.[Name], a.[Timestamp], a.Field, a.[User], a.[Timestamp], a.[Prior Value], a.[Current Value]
					'
	
		--PRINT @sql
		EXEC(@sql)
	END
		
	-- Subsidiary
	IF @static_data = 19915 OR @all_result = 'y'
	BEGIN
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id = ISNULL(@static_data, 19915)	
			
		SET @sql =  @group_result + '
					SELECT a.[User Action],
						   a.[Static Data Name],
						   a.[Name],
						   a.Field,
						   a.[Prior Value],
						   a.[Current Value],
						   a.[User],
						   a.[Timestamp]
					FROM   (
					SELECT UPPER(LEFT(fsa_now.user_action, 1)) + SUBSTRING(fsa_now.user_action, 2, LEN(fsa_now.user_action)) [User Action],
						''' + @static_data_name + ''' [Static Data Name],
						ISNULL(ph_audit_now.entity_name, ph_now.entity_name) [Name],
						cols.field [Field],
						prior_value [Prior Value],
						current_value [Current Value],
						ISNULL(fsa_now.update_user, dbo.FNADBUser()) [User]	,
						fsa_now.update_ts [Timestamp]					
					FROM fas_subsidiaries_audit fsa_now

					OUTER APPLY (
						SELECT TOP 1 * FROM fas_subsidiaries_audit 
						WHERE audit_id < fsa_now.audit_id 
							AND fas_subsidiary_id = fsa_now.fas_subsidiary_id		 
						ORDER BY audit_id DESC
					) fsa_prior

					OUTER APPLY (
						SELECT TOP 1 * FROM portfolio_hierarchy_audit 
						WHERE ISNULL(update_ts, create_ts) <= ''' + @as_of_date_to + ' 23:59:59''	
							AND entity_id = fsa_now.fas_subsidiary_id			 
						ORDER BY ISNULL(update_ts, create_ts) DESC
					) ph_audit_now

					--Name
					LEFT JOIN portfolio_hierarchy ph_now ON  ph_now.entity_id = fsa_now.fas_subsidiary_id	

					--Entity Type
					LEFT JOIN static_data_value et_now ON et_now.value_id = fsa_now.entity_type_value_id
					LEFT JOIN static_data_value et_prior ON et_prior.value_id = fsa_prior.entity_type_value_id

					--Functional Currency
					LEFT JOIN source_currency sc_now ON sc_now.source_currency_id = fsa_now.func_cur_value_id
					LEFT JOIN source_currency sc_prior ON sc_prior.source_currency_id = fsa_prior.func_cur_value_id

					--Discount Type
					LEFT JOIN static_data_value dt_now ON dt_now.value_id = fsa_now.disc_type_value_id
					LEFT JOIN static_data_value dt_prior ON dt_prior.value_id = fsa_prior.disc_type_value_id

					--Primary Counterparty
					LEFT JOIN source_counterparty pc_now ON pc_now.source_counterparty_id = fsa_now.counterparty_id
					LEFT JOIN source_counterparty pc_prior ON pc_prior.source_counterparty_id = fsa_prior.counterparty_id

					CROSS APPLY (	
						
						SELECT N''Entity Type'' field,
						   CASE WHEN fsa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(et_now.code AS VARCHAR(250)) END current_value,
						   CAST(et_prior.code AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Functional Currency'',
						   CASE WHEN fsa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(sc_now.currency_name AS VARCHAR(250)) END current_value,
						   CAST(sc_prior.currency_name AS VARCHAR(250)) prior_value

						UNION ALL
						
						SELECT N''Discount Type'',
						   CASE WHEN fsa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(dt_now.code AS VARCHAR(250)) END current_value,
						   CAST(dt_prior.code AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Discount Parameter'',
						   CASE WHEN fsa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(fsa_now.days_in_year AS VARCHAR(250)) END current_value,
						   CAST(fsa_prior.days_in_year AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Long Term Months'',
						   CASE WHEN fsa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(fsa_now.long_term_months AS VARCHAR(250)) END current_value,
						   CAST(fsa_prior.long_term_months AS VARCHAR(250)) prior_value


						UNION ALL
						
						SELECT N''Tax Percentage'',
						   CASE WHEN fsa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(fsa_now.tax_perc AS VARCHAR(250)) END current_value,
						   CAST(fsa_prior.tax_perc AS VARCHAR(250)) prior_value
						   
						UNION ALL

						SELECT N''Primary Counterparty'',
						   CASE 
								WHEN fsa_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(pc_now.counterparty_name AS VARCHAR(250)) END current_value,
						   CAST(pc_prior.counterparty_name AS VARCHAR(250)) prior_value	   
						   
					) cols
					WHERE fsa_now.update_ts BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''')	

					UNION ALL

					SELECT UPPER(LEFT(pha_now.user_action, 1)) + SUBSTRING(pha_now.user_action, 2, LEN(pha_now.user_action)) [User Action],
						''' + @static_data_name + ''' [Static Data Name],
						ISNULL(pha_now.entity_name,pha_prior.entity_name) [Name],
						cols.field [Field],
						prior_value [Prior Value],
						current_value [Current Value],
						ISNULL(pha_now.update_user, dbo.FNADBUser()) [User],
						pha_now.update_ts [Timestamp]
					FROM   portfolio_hierarchy_audit pha_now
					OUTER APPLY (
						SELECT TOP 1 * FROM portfolio_hierarchy_audit 
						WHERE audit_id < pha_now.audit_id 
							AND entity_id = pha_now.entity_id		 
						ORDER BY audit_id DESC
					) pha_prior

					--INNER JOIN portfolio_hierarchy ph ON ph.entity_id = pha_now.entity_id 

					CROSS APPLY (
					SELECT N''Name'' field,
					   CASE WHEN pha_now.user_action = ''Delete'' THEN NULL ELSE CAST(pha_now.entity_name AS VARCHAR(250)) END current_value,
					   CAST(pha_prior.entity_name AS VARCHAR(250)) prior_value						
					   
					) cols
					WHERE pha_now.update_ts BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''')	
						AND pha_now.hierarchy_level = 2
					) a 
					GROUP BY a.[User Action],a.[Static Data Name],a.[Name],a.Field,a.[Prior Value],a.[Current Value],a.[User],a.[Timestamp]'
					
		--PRINT @sql
		EXEC(@sql)	
	END
	
	-- Strategy
	IF @static_data = 19916 OR @all_result = 'y'
	BEGIN
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id = ISNULL(@static_data, 19916)	
			
		SET @sql =  @group_result + '
					SELECT UPPER(LEFT(fasa_now.user_action, 1)) + SUBSTRING(fasa_now.user_action, 2, LEN(fasa_now.user_action)) [User Action],
						''' + @static_data_name + ''' [Static Data Name],
						ISNULL(ph_audit_now.entity_name, ph_now.entity_name) [Name],	
						cols.field [Field],
						prior_value [Prior Value],
						current_value [Current Value],
						--ISNULL(fasa_now.update_user, dbo.FNADBUser()) [User],
						COALESCE(CAST(fas.create_ts AS VARCHAR),fasa_now.update_user, dbo.FNADBUser()) [User],
						fasa_now.update_ts [Timestamp]		
					FROM fas_strategy_audit fasa_now
					LEFT JOIN fas_strategy fas ON fas.fas_strategy_id = fasa_now.fas_strategy_id					
					OUTER APPLY (
						SELECT TOP 1 * FROM fas_strategy_audit 
						WHERE audit_id < fasa_now.audit_id 
							AND fas_strategy_id = fasa_now.fas_strategy_id		 
						ORDER BY audit_id DESC
					) fasa_prior
					
					OUTER APPLY (
						SELECT TOP 1 * FROM portfolio_hierarchy_audit 
						WHERE ISNULL(update_ts, create_ts) <= ''' + @as_of_date_to + ' 23:59:59''	
							AND entity_id = fasa_now.fas_strategy_id		 
						ORDER BY ISNULL(update_ts, create_ts) DESC
					) ph_audit_now
					
					--Name
					LEFT JOIN portfolio_hierarchy ph_now ON  ph_now.entity_id = fasa_now.fas_strategy_id		
					--LEFT JOIN portfolio_hierarchy ph_prior ON  ph_prior.entity_id = fasa_prior.fas_strategy_id
					
					--Source System
					LEFT JOIN source_system_description ssd_now ON ssd_now.source_system_id = fasa_now.source_system_id
					LEFT JOIN source_system_description ssd_prior ON ssd_prior.source_system_id = fasa_prior.source_system_id

					--Functional Currency
					LEFT JOIN source_currency fsc_now ON fsc_now.source_currency_id = fasa_now.fun_cur_value_id
					LEFT JOIN source_currency fsc_prior ON fsc_prior.source_currency_id = fasa_prior.fun_cur_value_id

					--Accounting Type
					LEFT JOIN static_data_value at_now ON at_now.value_id = fasa_now.hedge_type_value_id
					LEFT JOIN static_data_value at_prior ON at_prior.value_id = fasa_prior.hedge_type_value_id

					--Measurement Granularity
					LEFT JOIN static_data_value mg_now ON mg_now.value_id = fasa_now.mes_gran_value_id
					LEFT JOIN static_data_value mg_prior ON mg_prior.value_id = fasa_prior.mes_gran_value_id

					--Rolling Hedge Forward
					LEFT JOIN static_data_value rhf_now ON rhf_now.value_id = fasa_now.mismatch_tenor_value_id
					LEFT JOIN static_data_value rhf_prior ON rhf_prior.value_id = fasa_prior.mismatch_tenor_value_id

					--GL Entry Grouping
					LEFT JOIN static_data_value gl_eg_now ON gl_eg_now.value_id = fasa_now.gl_grouping_value_id
					LEFT JOIN static_data_value gl_eg_prior ON gl_eg_prior.value_id = fasa_prior.gl_grouping_value_id

					--Rollout Per Type
					LEFT JOIN static_data_value rrt_now ON rrt_now.value_id = fasa_now.rollout_per_type
					LEFT JOIN static_data_value rrt_prior ON rrt_prior.value_id = fasa_prior.rollout_per_type

					--Measuremnt Values
					LEFT JOIN static_data_value mv_now ON mv_now.value_id = fasa_now.mes_cfv_value_id
					LEFT JOIN static_data_value mv_prior ON mv_prior.value_id = fasa_prior.mes_cfv_value_id

					--Strip Transactions
					LEFT JOIN static_data_value st_now ON st_now.value_id = fasa_now.strip_trans_value_id
					LEFT JOIN static_data_value st_prior ON st_prior.value_id = fasa_prior.strip_trans_value_id

					--Exclude Values
					LEFT JOIN static_data_value ev_now ON ev_now.value_id = fasa_now.mes_cfv_values_value_id
					LEFT JOIN static_data_value ev_prior ON ev_prior.value_id = fasa_prior.mes_cfv_values_value_id

					--OCI Rollout
					LEFT JOIN static_data_value ocir_now ON ocir_now.value_id = fasa_now.oci_rollout_approach_value_id
					LEFT JOIN static_data_value ocir_prior ON ocir_prior.value_id = fasa_prior.oci_rollout_approach_value_id'

		SET @sql2 = '
		  		    CROSS APPLY (
	
						SELECT N''Source System'' field,
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(ssd_now.source_system_name AS VARCHAR(250)) END current_value,
						   CAST(ssd_prior.source_system_name AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Functional Currency'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(fsc_now.currency_name AS VARCHAR(250)) END current_value,
						   CAST(fsc_prior.currency_name AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Accounting Type'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(at_now.code AS VARCHAR(250)) END current_value,
						   CAST(at_prior.code AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Measurement Granularity'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(mg_now.code AS VARCHAR(250)) END current_value,
						   CAST(mg_prior.code AS VARCHAR(250)) prior_value
						   
						UNION ALL

						SELECT N''Rolling Hedge Forward'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(rhf_now.code AS VARCHAR(250)) END current_value,
						   CAST(rhf_prior.code AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''GL Entry Grouping'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(gl_eg_now.code AS VARCHAR(250)) END current_value,
						   CAST(gl_eg_prior.code AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Rollout Per Type'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(rrt_now.code AS VARCHAR(250)) END current_value,
						   CAST(rrt_prior.code AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Measuremnt Values'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(mv_now.code AS VARCHAR(250)) END current_value,
						   CAST(mv_prior.code AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Strip Transactions'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(st_now.code AS VARCHAR(250)) END current_value,
						   CAST(st_prior.code AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Exclude Values'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(ev_now.code AS VARCHAR(250)) END current_value,
						   CAST(ev_prior.code AS VARCHAR(250)) prior_value
						   
						UNION ALL

						SELECT N''OCI Rollout'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(ocir_now.code AS VARCHAR(250)) END current_value,
						   CAST(ocir_prior.code AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Test Range From 1'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(fasa_now.test_range_from AS VARCHAR(250)) END current_value,
						   CAST(fasa_prior.test_range_from AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Test Range To 1'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(fasa_now.test_range_to AS VARCHAR(250)) END current_value,
						   CAST(fasa_prior.test_range_to AS VARCHAR(250)) prior_value
						   
						UNION ALL'
						
			SET @sql3 = '
						SELECT N''Test Range From 2'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(fasa_now.additional_test_range_from AS VARCHAR(250)) END current_value,
						   CAST(fasa_prior.additional_test_range_from AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Test Range To 2'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(fasa_now.additional_test_range_to AS VARCHAR(250)) END current_value,
						   CAST(fasa_prior.additional_test_range_to AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Test Range From 3'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(fasa_now.additional_test_range_from2 AS VARCHAR(250)) END current_value,
						   CAST(fasa_prior.additional_test_range_from2 AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Test Range To 3'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(fasa_now.additional_test_range_to2 AS VARCHAR(250)) END current_value,
						   CAST(fasa_prior.additional_test_range_to2 AS VARCHAR(250)) prior_value
						   
						UNION ALL

						SELECT N''Include Unlink Hedges'',
							CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
								 ELSE CASE WHEN fasa_now.include_unlinked_hedges = ''y'' THEN ''Yes'' ELSE ''No'' END 
							END current_value,
							CASE WHEN fasa_prior.include_unlinked_hedges = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value
						   
						UNION ALL
						
						SELECT N''Include Unlink Items'', 
							CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
								 ELSE CASE WHEN fasa_now.include_unlinked_items = ''y'' THEN ''Yes'' ELSE ''No'' END 
							END current_value,
							CASE WHEN fasa_prior.include_unlinked_items = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value
						   
						UNION ALL
						
						SELECT N''Only Short Term'',
							CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
								 ELSE CASE WHEN fasa_now.no_links = ''y'' THEN ''Yes'' ELSE ''No'' END 
							END current_value,
							CASE WHEN fasa_prior.no_links = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value
						   
						UNION ALL
						
						SELECT N''FX Hedges fro Net Investment in Foreign Operations'',
							CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
								 ELSE CASE WHEN fasa_now.fx_hedge_flag = ''y'' THEN ''Yes'' ELSE ''No'' END 
							END current_value,
							CASE WHEN fasa_prior.fx_hedge_flag = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value
						   
						UNION ALL

						SELECT N''First Day PNL Threshold'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(fasa_now.first_day_pnl_threshold AS VARCHAR(250)) END current_value,
						   CAST(fasa_prior.first_day_pnl_threshold AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Functional Currency'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(fsc_now.currency_name AS VARCHAR(250)) END current_value,
						   CAST(fsc_prior.currency_name AS VARCHAR(250)) prior_value	
						
						UNION ALL
						
						SELECT N''Tenor Options'',
						   CASE WHEN fasa_now.user_action = ''Delete'' THEN NULL 
								--ELSE CAST(fasa_now.gl_tenor_option AS VARCHAR(250)) 
								ELSE CASE 
										WHEN fasa_now.gl_tenor_option = ''a'' THEN ''Show All'' 
										WHEN fasa_now.gl_tenor_option = ''s'' THEN ''Show Settlement Values Only''
										WHEN fasa_now.gl_tenor_option = ''c'' THEN ''Show Current and Forward Months Only''
										WHEN fasa_now.gl_tenor_option = ''f'' THEN ''Show Forward Month Only''						
										ELSE '''' 
									 END
						   END current_value,
						   CASE 
								WHEN fasa_prior.gl_tenor_option = ''a'' THEN ''Show All'' 
								WHEN fasa_prior.gl_tenor_option = ''s'' THEN ''Show Settlement Values Only''
								WHEN fasa_prior.gl_tenor_option = ''c'' THEN ''Show Current and Forward Months Only''
								WHEN fasa_prior.gl_tenor_option = ''f'' THEN ''Show Forward Month Only''						
								ELSE '''' 
							 END prior_value

						) cols	
						WHERE fasa_now.update_ts BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
							AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''')						

				UNION ALL

				SELECT UPPER(LEFT(pha_now.user_action, 1)) + SUBSTRING(pha_now.user_action, 2, LEN(pha_now.user_action)) [User Action],
					''' + @static_data_name + ''' [Static Data Name],
					ISNULL(pha_now.entity_name,pha_prior.entity_name) [Name],
					cols.field [Field],
					prior_value [Prior Value],
					current_value [Current Value],
					ISNULL(pha_now.update_user, dbo.FNADBUser()) [User],
					pha_now.update_ts [Timestamp]
				FROM   portfolio_hierarchy_audit pha_now
				OUTER APPLY (
					SELECT TOP 1 * FROM portfolio_hierarchy_audit 
					WHERE audit_id < pha_now.audit_id 
						AND entity_id = pha_now.entity_id		 
					ORDER BY audit_id DESC
				) pha_prior

				LEFT JOIN portfolio_hierarchy ph ON ph.entity_id = pha_now.entity_id 

				CROSS APPLY (
				SELECT N''Name'' field,
				   CASE WHEN pha_now.user_action = ''Delete'' THEN NULL ELSE CAST(pha_now.entity_name AS VARCHAR(250)) END current_value,
				   CAST(pha_prior.entity_name AS VARCHAR(250)) prior_value						
				   
				) cols
				WHERE pha_now.update_ts BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''		 
					AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') 
					AND pha_now.hierarchy_level = 1 '
					
		--PRINT @sql
		--PRINT @sql2
		--PRINT @sql3
		EXEC(@sql + @sql2 + @sql3)	
	END
	
	-- Book
	IF @static_data = 19917 OR @all_result = 'y'
	BEGIN
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id = ISNULL(@static_data, 19917)	
			
		SET @sql =  @group_result + '
					SELECT UPPER(LEFT(fsa_now.user_action, 1)) + SUBSTRING(fsa_now.user_action, 2, LEN(fsa_now.user_action)) [User Action],
						''' + @static_data_name + ''' [Static Data Name],
						ISNULL(ph_audit_now.entity_name, ph_now.entity_name) [Name],
						cols.field [Field],
						prior_value [Prior Value],
						current_value [Current Value],
						ISNULL(fsa_now.update_user, dbo.FNADBUser()) [User],
						fsa_now.update_ts [Timestamp]
					FROM fas_books_audit fsa_now
					
					OUTER APPLY (
						SELECT TOP 1 * FROM fas_books_audit 
						WHERE audit_id < fsa_now.audit_id 
							AND fas_book_id = fsa_now.fas_book_id		 
						ORDER BY audit_id DESC
					) fsa_prior
					
					OUTER APPLY (
						SELECT TOP 1 * FROM portfolio_hierarchy_audit 
						WHERE ISNULL(update_ts, create_ts) <= ''' + @as_of_date_to + ' 23:59:59''
							AND entity_id = fsa_now.fas_book_id			 
						ORDER BY ISNULL(update_ts, create_ts) DESC
					) ph_audit_now

					--Name
					LEFT JOIN portfolio_hierarchy ph_now ON  ph_now.entity_id = fsa_now.fas_book_id
					
					--Cost Approach
					LEFT JOIN static_data_value ca_now ON ca_now.value_id = fsa_now.cost_approach_id
					LEFT JOIN static_data_value ca_prior ON ca_prior.value_id = fsa_prior.cost_approach_id
					
					--Convert UOM
					LEFT JOIN source_uom cu_now ON cu_now.source_uom_id = fsa_now.convert_uom_id
					LEFT JOIN source_uom cu_prior ON cu_prior.source_uom_id = fsa_prior.convert_uom_id
					
					--Legal Entity
					LEFT JOIN source_legal_entity sle_now ON sle_now.source_legal_entity_id = fsa_now.legal_entity
					LEFT JOIN source_legal_entity sle_prior ON sle_prior.source_legal_entity_id = fsa_prior.legal_entity
					
					--Functional Currency
					LEFT JOIN source_currency fc_now ON fc_now.source_currency_id = fsa_now.fun_cur_value_id
					LEFT JOIN source_currency fc_prior ON fc_prior.source_currency_id = fsa_prior.fun_cur_value_id

					CROSS APPLY (	
						
						SELECT N''Cost Approach'' field,
						   CASE WHEN fsa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(ca_now.code AS VARCHAR(250)) END current_value,
						   CAST(ca_prior.code AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Convert UOM'' ,
						   CASE WHEN fsa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(cu_now.uom_name AS VARCHAR(250)) END current_value,
						   CAST(cu_prior.uom_name AS VARCHAR(250)) prior_value
						   
						UNION ALL

						SELECT N''Legal Entity'' ,
						   CASE WHEN fsa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(sle_now.legal_entity_name AS VARCHAR(250)) END current_value,
						   CAST(sle_prior.legal_entity_name AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Hypothetical'' ,
						   CASE WHEN fsa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CASE WHEN fsa_now.no_link = ''y'' THEN ''Yes'' ELSE ''No'' END END current_value,		   	
						   CASE WHEN fsa_prior.no_link = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value
						   
						UNION ALL
						
						SELECT N''Tax Percentage'' ,
						   CASE WHEN fsa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(fsa_now.tax_perc AS VARCHAR(250)) END current_value,
						   CAST(fsa_prior.tax_perc AS VARCHAR(250)) prior_value
						   
						UNION ALL
						
						SELECT N''Hedge And Item Same Sign'' ,
						   CASE WHEN fsa_now.user_action = ''Delete'' THEN NULL    
						   ELSE CASE WHEN fsa_now.hedge_item_same_sign = ''y'' THEN ''Yes'' ELSE ''No'' END END current_value,		   	
						   CASE WHEN fsa_prior.hedge_item_same_sign = ''y'' THEN ''Yes'' ELSE ''No'' END prior_value
						
						UNION ALL
						
						SELECT N''Functional Currency'' ,
						   CASE WHEN fsa_now.user_action = ''Delete'' THEN NULL 
						   ELSE CAST(fc_now.currency_name AS VARCHAR(250)) END current_value,
						   CAST(fc_prior.currency_name AS VARCHAR(250)) prior_value

					) cols
					WHERE fsa_now.update_ts BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
					AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''')		
				
					UNION ALL

					SELECT UPPER(LEFT(pha_now.user_action, 1)) + SUBSTRING(pha_now.user_action, 2, LEN(pha_now.user_action)) [User Action],
						''' + @static_data_name + ''' [Static Data Name],
						ISNULL(pha_now.entity_name,pha_prior.entity_name) [Name],
						cols.field [Field],
						prior_value [Prior Value],
						current_value [Current Value],
						ISNULL(pha_now.update_user, dbo.FNADBUser()) [User],
						ISNULL(pha_now.update_ts,pha_now.create_ts) [Timestamp]
					FROM   portfolio_hierarchy_audit pha_now
					OUTER APPLY (
						SELECT TOP 1 * FROM portfolio_hierarchy_audit 
						WHERE audit_id < pha_now.audit_id 
							AND entity_id = pha_now.entity_id		 
						ORDER BY audit_id DESC
					) pha_prior

					LEFT JOIN portfolio_hierarchy ph ON ph.entity_id = pha_now.entity_id 

					CROSS APPLY (
					SELECT N''Name'' field,
					   CASE WHEN pha_now.user_action = ''Delete'' THEN NULL 
					   ELSE CAST(pha_now.entity_name AS VARCHAR(250)) END current_value,
					   CAST(pha_prior.entity_name AS VARCHAR(250)) prior_value						
					   
					) cols
					WHERE ISNULL(pha_now.update_ts,pha_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''		 
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''')
						AND pha_now.hierarchy_level = 0'
					
		--PRINT @sql
		EXEC(@sql)	
	END
	
	-- Price Curves
	IF @static_data = 19909
	BEGIN
		SET @sql = 'SELECT UPPER(LEFT(spca_now.user_action, 1)) + SUBSTRING(spca_now.user_action, 2, LEN(spca_now.user_action)) [User Action],
							dbo.FNADateTimeFormat(ISNULL(spca_now.update_ts,spca_now.create_ts),1) [Timestamp],
							CASE WHEN spca_now.user_action = ''insert'' 
								THEN COALESCE(spca_now.create_user, spca_now.update_user, dbo.FNADBUser())
								ELSE COALESCE(spca_now.update_user, spca_now.create_user, dbo.FNADBUser()) 
						    END [Update User],	
							ISNULL(spcd_now.curve_name,spcd_prior.curve_name) [Curve Name],
							dbo.FNADateFormat(spca_now.as_of_date) [As of Date],
							dbo.FNADateFormat(spca_now.maturity_date) [Maturity Date],
							CASE WHEN spcd_now.Granularity = 982 
									THEN CAST(DATEPART(hh,spca_now.maturity_date)  + 1  AS VARCHAR)+ '':'' + CAST(DATEPART(MINUTE,spca_now.maturity_date) AS VARCHAR) 
									ELSE CAST(DATEPART(hh,spca_now.maturity_date) AS VARCHAR) + '':'' + CAST(DATEPART(MINUTE,spca_now.maturity_date) AS VARCHAR) 
							END	[Hour],							
							prior_value [Prior Value],
							current_value [Current Value]  
					' + @str_batch_table + '
		            FROM   source_price_curve_audit spca_now
					OUTER APPLY (
						SELECT TOP 1 * FROM source_price_curve_audit 
						 WHERE audit_id < spca_now.audit_id 
							AND source_curve_def_id = spca_now.source_curve_def_id
							AND maturity_date = spca_now.maturity_date 
							and DATEPART(HH,maturity_date) = DATEPART(HH,spca_now.maturity_date)
						 ORDER BY audit_id DESC
					) spca_prior

					--Source Curve Def
					LEFT JOIN source_price_curve_def spcd_now ON spcd_now.source_curve_def_id = spca_now.source_curve_def_id						
					LEFT JOIN source_price_curve_def spcd_prior ON spcd_prior.source_curve_def_id = spca_prior.source_curve_def_id
											
					CROSS APPLY (
							SELECT N''Curve Value'' field,
							   CASE WHEN spca_now.user_action = ''delete'' THEN NULL 
									ELSE CAST(spca_now.curve_value AS VARCHAR(250)) 
							   END current_value,			    
							   CASE WHEN spca_prior.user_action = ''delete'' THEN NULL 
									ELSE CAST(spca_prior.curve_value AS VARCHAR(250)) 
							   END prior_value					
					) cols
					WHERE ISNULL(spca_now.update_ts,spca_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + '''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''')	' + CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND spca_now.source_curve_def_id IN (' + @source_id +')' ELSE '' END
				SET @sql = @sql + ' ORDER BY spca_now.audit_id DESC'
		--PRINT @sql
		EXEC(@sql)
	END
	
	-- Currency
	IF @static_data = 19918 OR @all_result = 'y'
	BEGIN
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id =  ISNULL(@static_data, 19918)
		
		SET @sql = @group_result + '
					SELECT UPPER(LEFT(scca_now.user_action, 1)) + SUBSTRING(scca_now.user_action, 2, LEN(scca_now.user_action)) [User Action],
						   ''' + @static_data_name + ''' [Static Data Name],
						   scca_now.currency_name,
						   cols.field [Field],
						   prior_value [Prior Value],
						   current_value [Current Value],
						   CASE WHEN scca_now.user_action = ''insert'' 
								THEN COALESCE(scca_now.create_user, scca_now.update_user, dbo.FNADBUser())
								ELSE COALESCE(scca_now.update_user, scca_now.create_user, dbo.FNADBUser()) 
						   END [Update User],
						   ISNULL(scca_now.update_ts, scca_now.create_ts) [Update TS]
					FROM source_currency_audit scca_now
					   OUTER APPLY(
								   SELECT TOP 1 * FROM source_currency_audit 
								   WHERE  audit_id < scca_now.audit_id AND source_currency_id = scca_now.source_currency_id
								   ORDER BY audit_id DESC
							   ) scca_prior	
							   
					   LEFT JOIN source_system_description ssd_now ON  ssd_now.source_system_id = scca_now.source_system_id
					   LEFT JOIN source_system_description ssd_prior ON  ssd_prior.source_system_id = scca_prior.source_system_id
						
					   CROSS APPLY(
							SELECT N''Source System'' field,
								CASE WHEN scca_now.user_action = ''Delete'' THEN NULL
								ELSE CAST(ssd_now.source_system_name AS VARCHAR(250)) END current_value,
								CAST(ssd_prior.source_system_name AS VARCHAR(250)) prior_value 
							
							UNION ALL
											
							SELECT N''Currency Name'',
								CASE WHEN scca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(scca_now.currency_name AS VARCHAR(100)) END current_value,
								CAST(scca_prior.currency_name AS VARCHAR(100)) prior_value
											   
							UNION ALL
							
							SELECT N''Currency Description'',
								CASE WHEN scca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(scca_now.currency_desc AS VARCHAR(250)) END current_value,
								CAST(scca_prior.currency_desc AS VARCHAR(250)) prior_value   
								   
							UNION ALL
							
							SELECT N''Currency ID'',
								CASE WHEN scca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(scca_now.currency_id AS VARCHAR(50)) END current_value,
								CAST(scca_prior.currency_id AS VARCHAR(50)) prior_value'
												   
			SET @sql2 =		' ) cols
					WHERE ISNULL(scca_now.update_ts, scca_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') AND scca_now.source_system_id = ''' + cast(@source_system_id AS VARCHAR(2)) + ''' 		
					ORDER BY scca_now.audit_id DESC'
					
		--PRINT @sql 
		--PRINT @sql2 
		EXEC(@sql + @sql2)	
	END
	
	-- Commodity
	IF @static_data = 19919 OR @all_result = 'y'
	BEGIN
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id =  ISNULL(@static_data, 19919)
		
		SET @sql = @group_result + '
					SELECT UPPER(LEFT(soca_now.user_action, 1)) + SUBSTRING(soca_now.user_action, 2, LEN(soca_now.user_action)) [User Action],
						   ''' + @static_data_name + ''' [Static Data Name],
						   soca_now.commodity_name,
						   cols.field [Field],
						   prior_value [Prior Value],
						   current_value [Current Value],
						   CASE WHEN soca_now.user_action = ''insert'' 
								THEN COALESCE(soca_now.create_user, soca_now.update_user, dbo.FNADBUser())
								ELSE COALESCE(soca_now.update_user, soca_now.create_user, dbo.FNADBUser()) 
						   END [Update User],
						   ISNULL(soca_now.update_ts, soca_now.create_ts) [Update TS]
					FROM source_commodity_audit soca_now
					   OUTER APPLY(
								   SELECT TOP 1 * FROM source_commodity_audit 
								   WHERE  audit_id < soca_now.audit_id AND source_commodity_id = soca_now.source_commodity_id
								   ORDER BY audit_id DESC
							   ) soca_prior	
							   
					   LEFT JOIN source_system_description ssd_now ON  ssd_now.source_system_id = soca_now.source_system_id
					   LEFT JOIN source_system_description ssd_prior ON  ssd_prior.source_system_id = soca_prior.source_system_id
						
					   CROSS APPLY(
							SELECT N''Source System'' field,
								CASE WHEN soca_now.user_action = ''Delete'' THEN NULL
								ELSE CAST(ssd_now.source_system_name AS VARCHAR(250)) END current_value,
								CAST(ssd_prior.source_system_name AS VARCHAR(250)) prior_value 
							
							UNION ALL
											
							SELECT N''Commodity Name'',
								CASE WHEN soca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(soca_now.commodity_name AS VARCHAR(100)) END current_value,
								CAST(soca_prior.commodity_name AS VARCHAR(100)) prior_value
											   
							UNION ALL
							
							SELECT N''Commodity Description'',
								CASE WHEN soca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(soca_now.commodity_desc AS VARCHAR(250)) END current_value,
								CAST(soca_prior.commodity_desc AS VARCHAR(250)) prior_value   
								   
							UNION ALL
							
							SELECT N''Commodity ID'',
								CASE WHEN soca_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(soca_now.commodity_id AS VARCHAR(50)) END current_value,
								CAST(soca_prior.commodity_id AS VARCHAR(50)) prior_value'
												   
			SET @sql2 =		' ) cols
					WHERE ISNULL(soca_now.update_ts, soca_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''')  AND soca_now.source_system_id = ''' + cast(@source_system_id AS VARCHAR(2)) + '''	
					ORDER BY soca_now.audit_id DESC'
					
		--PRINT @sql 
		--PRINT @sql2 
		EXEC(@sql + @sql2)	
	END	
	
	-- Source Minor Location
	IF @static_data = 19920 OR @all_result = 'y'
	BEGIN
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id =  ISNULL(@static_data, 19920)
		
		SET @sql = @group_result + '
					SELECT UPPER(LEFT(smla_now.user_action, 1)) + SUBSTRING(smla_now.user_action, 2, LEN(smla_now.user_action)) [User Action],
						   ''' + @static_data_name + ''' [Static Data Name],
						   smla_now.location_name,
						   cols.field [Field],
						   prior_value [Prior Value],
						   current_value [Current Value],
						   CASE WHEN smla_now.user_action = ''insert'' 
								THEN COALESCE(smla_now.create_user, smla_now.update_user, dbo.FNADBUser())
								ELSE COALESCE(smla_now.update_user, smla_now.create_user, dbo.FNADBUser()) 
						   END [Update User],
						   ISNULL(smla_now.update_ts, smla_now.create_ts) [Update TS]
					FROM source_minor_location_audit smla_now
					   OUTER APPLY(
								   SELECT TOP 1 * FROM source_minor_location_audit 
								   WHERE  audit_id < smla_now.audit_id AND source_minor_location_id = smla_now.source_minor_location_id
								   ORDER BY audit_id DESC
							   ) smla_prior	
							   
					   LEFT JOIN source_system_description ssd_now ON  ssd_now.source_system_id = smla_now.source_system_id
					   LEFT JOIN source_system_description ssd_prior ON  ssd_prior.source_system_id = smla_prior.source_system_id

					   CROSS APPLY(
							SELECT N''Source System'' field,
								CASE WHEN smla_now.user_action = ''Delete'' THEN NULL
								ELSE CAST(ssd_now.source_system_name AS VARCHAR(250)) END current_value,
								CAST(ssd_prior.source_system_name AS VARCHAR(250)) prior_value 
							
							UNION ALL
											
							SELECT N''Location Name'',
								CASE WHEN smla_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(smla_now.location_name AS VARCHAR(250)) END current_value,
								CAST(smla_prior.location_name AS VARCHAR(250)) prior_value
											   
							UNION ALL
							
							SELECT N''Description'',
								CASE WHEN smla_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(smla_now.location_description AS VARCHAR(250)) END current_value,
								CAST(smla_prior.location_description AS VARCHAR(250)) prior_value   
								   
							UNION ALL
							
							SELECT N''Location ID'',
								CASE WHEN smla_now.user_action = ''Delete'' THEN NULL 
								ELSE CAST(smla_now.location_id AS VARCHAR(250)) END current_value,
								CAST(smla_prior.location_id AS VARCHAR(250)) prior_value'
												   
			SET @sql2 =		' ) cols
					WHERE ISNULL(smla_now.update_ts, smla_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') AND smla_now.source_system_id = ''' + cast(@source_system_id AS VARCHAR(2)) + '''		
					 ' + CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND smla_now.source_minor_location_id IN (' + @source_id +')' ELSE '' END 
		 SET @sql2 = @sql2 +'	ORDER BY smla_now.audit_id DESC'
					
		--PRINT @sql 
		--PRINT @sql2 
		EXEC(@sql + @sql2)	
	END

	--Counterparty Contacts
	IF @static_data = 19923 OR @all_result = 'y'
	BEGIN
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id =  ISNULL(@static_data, 19923)

		SET @sql = @group_result + '
					SELECT UPPER(LEFT(cca_now.user_action, 1)) + SUBSTRING(cca_now.user_action, 2, LEN(cca_now.user_action)) [User Action],
						   ''' + @static_data_name + ''' [Static Data Name],
						   sc_counterparty_id_now.counterparty_name + '' - '' + cca_now.id,
						   cols.field [Field],
						   prior_value [Prior Value],
						   current_value [Current Value],
						   CASE WHEN cca_now.user_action = ''insert'' 
								THEN COALESCE(cca_now.create_user, cca_now.update_user, dbo.FNADBUser())
								ELSE COALESCE(cca_now.update_user, cca_now.create_user, dbo.FNADBUser()) 
						   END [Update User],
						   ISNULL(cca_now.update_ts, cca_now.create_ts) [Update TS]
					FROM counterparty_contacts_audit cca_now
					OUTER APPLY(
								SELECT TOP 1 * FROM counterparty_contacts_audit 
								WHERE  counterparty_contacts_audit_id < cca_now.counterparty_contacts_audit_id AND counterparty_contact_id = cca_now.counterparty_contact_id
								ORDER BY counterparty_contacts_audit_id DESC
					) cca_prior	
							 
					--Counterparty ID
					LEFT JOIN source_counterparty sc_counterparty_id_now ON sc_counterparty_id_now.source_counterparty_id = cca_now.counterparty_id
					LEFT JOIN source_counterparty sc_counterparty_id_prior ON sc_counterparty_id_prior.source_counterparty_id = cca_prior.counterparty_id

					--Contact Type
					LEFT JOIN static_data_value sdv_contact_type_now ON sdv_contact_type_now.value_id = cca_now.contact_type
					LEFT JOIN static_data_value sdv_contact_type_prior ON sdv_contact_type_prior.value_id = cca_prior.contact_type

					--State
					LEFT JOIN static_data_value sdv_state_now ON sdv_state_now.value_id = cca_now.state
					LEFT JOIN static_data_value sdv_state_prior ON sdv_state_prior.value_id = cca_prior.state

					--Region
					LEFT JOIN static_data_value sdv_region_now ON sdv_region_now.value_id = cca_now.region
					LEFT JOIN static_data_value sdv_region_prior ON sdv_region_prior.value_id = cca_prior.region

					--Country
					LEFT JOIN static_data_value sdv_country_now ON sdv_country_now.value_id = cca_now.country
					LEFT JOIN static_data_value sdv_country_prior ON sdv_country_prior.value_id = cca_prior.country				  
						'

					   SET @sql2 = ' CROSS APPLY(

									SELECT N''Counterparty ID'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(sc_counterparty_id_now.counterparty_name AS VARCHAR(250)) END current_value,
									CAST(sc_counterparty_id_prior.counterparty_name AS VARCHAR(250)) prior_value
									UNION ALL

									SELECT N''Contact Type'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(sdv_contact_type_now.code AS VARCHAR(250)) END current_value,
									CAST(sdv_contact_type_prior.code AS VARCHAR(250)) prior_value
									UNION ALL

									SELECT N''Title'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(cca_now.title AS VARCHAR(200)) END current_value,
									CAST(cca_prior.title AS VARCHAR(200)) prior_value
									UNION ALL

									SELECT N''Name'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(cca_now.name AS VARCHAR(100)) END current_value,
									CAST(cca_prior.name AS VARCHAR(100)) prior_value
									UNION ALL

									SELECT N''Contact ID'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(cca_now.id AS VARCHAR(100)) END current_value,
									CAST(cca_prior.id AS VARCHAR(100)) prior_value
									UNION ALL

									SELECT N''Address 1'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(cca_now.address1 AS VARCHAR(255)) END current_value,
									CAST(cca_prior.address1 AS VARCHAR(255)) prior_value
									UNION ALL

									SELECT N''Address 2'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(cca_now.address2 AS VARCHAR(255)) END current_value,
									CAST(cca_prior.address2 AS VARCHAR(255)) prior_value
									UNION ALL

									SELECT N''City'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(cca_now.city AS VARCHAR(100)) END current_value,
									CAST(cca_prior.city AS VARCHAR(100)) prior_value
									UNION ALL

									SELECT N''State'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(sdv_state_now.code AS VARCHAR(250)) END current_value,
									CAST(sdv_state_prior.code AS VARCHAR(250)) prior_value
									UNION ALL

									SELECT N''ZIP'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(cca_now.zip AS VARCHAR(100)) END current_value,
									CAST(cca_prior.zip AS VARCHAR(100)) prior_value
									UNION ALL

									SELECT N''Region'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(sdv_region_now.code AS VARCHAR(250)) END current_value,
									CAST(sdv_region_prior.code AS VARCHAR(250)) prior_value
									UNION ALL

									SELECT N''Country'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(sdv_country_now.code AS VARCHAR(250)) END current_value,
									CAST(sdv_country_prior.code AS VARCHAR(250)) prior_value
									UNION ALL

									SELECT N''Phone Number'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(cca_now.telephone AS VARCHAR(20)) END current_value,
									CAST(cca_prior.telephone AS VARCHAR(20)) prior_value
									UNION ALL

									SELECT N''Cell Number'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(cca_now.cell_no AS VARCHAR(20)) END current_value,
									CAST(cca_prior.cell_no AS VARCHAR(20)) prior_value
									UNION ALL

									SELECT N''Fax'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(cca_now.fax AS VARCHAR(50)) END current_value,
									CAST(cca_prior.fax AS VARCHAR(50)) prior_value
									UNION ALL

									SELECT N''Email'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(cca_now.email AS VARCHAR(8000)) END current_value,
									CAST(cca_prior.email AS VARCHAR(8000)) prior_value
									UNION ALL

									SELECT N''Email CC'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(cca_now.email_cc AS VARCHAR(5000)) END current_value,
									CAST(cca_prior.email_cc AS VARCHAR(5000)) prior_value
									UNION ALL

									SELECT N''Email BCC'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(cca_now.email_bcc AS VARCHAR(100)) END current_value,
									CAST(cca_prior.email_bcc AS VARCHAR(100)) prior_value
									UNION ALL

									SELECT N''Active'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CASE WHEN ISNULL(cca_now.is_active,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END END current_value,
									CASE WHEN ISNULL(cca_prior.is_active,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END prior_value
									UNION ALL

									SELECT N''Primary'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CASE WHEN ISNULL(cca_now.is_primary,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END END current_value,
									CASE WHEN ISNULL(cca_prior.is_primary,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END prior_value
									UNION ALL

									SELECT N''Comment'' [field] ,
									CASE WHEN cca_now.user_action = ''Delete'' THEN NULL
									ELSE CAST(cca_now.comment AS VARCHAR(8000)) END current_value,
									CAST(cca_prior.comment AS VARCHAR(8000)) prior_value							
							'												   
			SET @sql3 =		' ) cols
					WHERE ISNULL(cca_now.update_ts, cca_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''')' 
						+ CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND cca_now.counterparty_id IN (' + @source_id +')' ELSE '' END
			SET @sql3 =	@sql3 + 'ORDER BY cca_now.counterparty_contacts_audit_id DESC'
					
		--PRINT @sql 
		--PRINT @sql2 
		--PRINT @sql3 
		EXEC(@sql + @sql2 + @sql3)
	END

    --Counterparty Credit Info
	IF @static_data = 19924 OR @all_result = 'y'
	BEGIN
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id =  ISNULL(@static_data, 19924)

		SET @sql = @group_result + '
					SELECT UPPER(LEFT(cci_now.user_action, 1)) + SUBSTRING(cci_now.user_action, 2, LEN(cci_now.user_action)) [User Action],
						   ''' + @static_data_name + ''' [Static Data Name],
						   sc_Counterparty_id_now.counterparty_name,
						   cols.field [Field],
						   prior_value [Prior Value],
						   current_value [Current Value],
						   CASE WHEN cci_now.user_action = ''insert'' 
								THEN COALESCE(cci_now.create_user, cci_now.update_user, dbo.FNADBUser())
								ELSE COALESCE(cci_now.update_user, cci_now.create_user, dbo.FNADBUser()) 
						   END [Update User],
						   ISNULL(cci_now.update_ts, cci_now.create_ts) [Update TS]
					FROM counterparty_credit_info_audit cci_now
					OUTER APPLY(
								SELECT TOP 1 * FROM counterparty_credit_info_audit 
								WHERE  audit_id < cci_now.audit_id AND counterparty_credit_info_id = cci_now.counterparty_credit_info_id
								ORDER BY audit_id DESC
					) cci_prior	
							
						--Counterparty
						LEFT JOIN source_counterparty sc_Counterparty_id_now ON sc_Counterparty_id_now.source_counterparty_id = cci_now.Counterparty_id
						LEFT JOIN source_counterparty sc_Counterparty_id_prior ON sc_Counterparty_id_prior.source_counterparty_id = cci_prior.Counterparty_id

						--Analyst
						LEFT JOIN application_users au_analyst_now ON au_analyst_now.user_login_id = cci_now.analyst
						LEFT JOIN application_users au_analyst_prior ON au_analyst_prior.user_login_id = cci_prior.analyst

						--Account Status
						LEFT JOIN static_data_value sdv_account_status_now ON sdv_account_status_now.value_id = cci_now.account_status
						LEFT JOIN static_data_value sdv_account_status_prior ON sdv_account_status_prior.value_id = cci_prior.account_status

						--Risk Rating
						LEFT JOIN static_data_value sdv_Risk_rating_now ON sdv_Risk_rating_now.value_id = cci_now.Risk_rating
						LEFT JOIN static_data_value sdv_Risk_rating_prior ON sdv_Risk_rating_prior.value_id = cci_prior.Risk_rating

						--S&P
						LEFT JOIN static_data_value sdv_Debt_rating_now ON sdv_Debt_rating_now.value_id = cci_now.Debt_rating
						LEFT JOIN static_data_value sdv_Debt_rating_prior ON sdv_Debt_rating_prior.value_id = cci_prior.Debt_rating

						--Moody''s
						LEFT JOIN static_data_value sdv_Debt_Rating2_now ON sdv_Debt_Rating2_now.value_id = cci_now.Debt_Rating2
						LEFT JOIN static_data_value sdv_Debt_Rating2_prior ON sdv_Debt_Rating2_prior.value_id = cci_prior.Debt_Rating2

						--Fitch
						LEFT JOIN static_data_value sdv_Debt_Rating3_now ON sdv_Debt_Rating3_now.value_id = cci_now.Debt_Rating3
						LEFT JOIN static_data_value sdv_Debt_Rating3_prior ON sdv_Debt_Rating3_prior.value_id = cci_prior.Debt_Rating3

						--D&B
						LEFT JOIN static_data_value sdv_Debt_Rating4_now ON sdv_Debt_Rating4_now.value_id = cci_now.Debt_Rating4
						LEFT JOIN static_data_value sdv_Debt_Rating4_prior ON sdv_Debt_Rating4_prior.value_id = cci_prior.Debt_Rating4

						--Debt Rating 5
						LEFT JOIN static_data_value sdv_Debt_Rating5_now ON sdv_Debt_Rating5_now.value_id = cci_now.Debt_Rating5
						LEFT JOIN static_data_value sdv_Debt_Rating5_prior ON sdv_Debt_Rating5_prior.value_id = cci_prior.Debt_Rating5

						--Rating Outlook
						LEFT JOIN static_data_value sdv_rating_outlook_now ON sdv_rating_outlook_now.value_id = cci_now.rating_outlook
						LEFT JOIN static_data_value sdv_rating_outlook_prior ON sdv_rating_outlook_prior.value_id = cci_prior.rating_outlook

						--Qualitative Rating
						LEFT JOIN static_data_value sdv_qualitative_rating_now ON sdv_qualitative_rating_now.value_id = cci_now.qualitative_rating
						LEFT JOIN static_data_value sdv_qualitative_rating_prior ON sdv_qualitative_rating_prior.value_id = cci_prior.qualitative_rating

						--Industry Type 1
						LEFT JOIN static_data_value sdv_Industry_type1_now ON sdv_Industry_type1_now.value_id = cci_now.Industry_type1
						LEFT JOIN static_data_value sdv_Industry_type1_prior ON sdv_Industry_type1_prior.value_id = cci_prior.Industry_type1

						--Industry Type 2
						LEFT JOIN static_data_value sdv_Industry_type2_now ON sdv_Industry_type2_now.value_id = cci_now.Industry_type2
						LEFT JOIN static_data_value sdv_Industry_type2_prior ON sdv_Industry_type2_prior.value_id = cci_prior.Industry_type2

						--SIC Code
						LEFT JOIN static_data_value sdv_SIC_Code_now ON sdv_SIC_Code_now.value_id = cci_now.SIC_Code
						LEFT JOIN static_data_value sdv_SIC_Code_prior ON sdv_SIC_Code_prior.value_id = cci_prior.SIC_Code

						--Approved By
						LEFT JOIN application_users au_approved_by_now ON au_approved_by_now.user_login_id = cci_now.Approved_by
						LEFT JOIN application_users au_approved_by_prior ON au_approved_by_prior.user_login_id = cci_prior.Approved_by

						--PFE Criteria
						LEFT JOIN var_measurement_criteria_detail vmcd_now ON vmcd_now.id = cci_now.pfe_criteria
						LEFT JOIN var_measurement_criteria_detail vmcd_prior ON vmcd_prior.id = cci_prior.pfe_criteria

						--Currency
						LEFT JOIN source_currency sc_source_currency_now ON sc_source_currency_now.source_currency_id = cci_now.curreny_code
						LEFT JOIN source_currency sc_source_currency_prior ON sc_source_currency_prior.source_currency_id = cci_prior.curreny_code	
								  
						'

					   SET @sql2 = ' CROSS APPLY(
							SELECT N''Counterparty'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sc_Counterparty_id_now.counterparty_name AS VARCHAR(250)) END current_value,
							CAST(sc_Counterparty_id_prior.counterparty_name AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Analyst'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(au_analyst_now.user_f_name + '' '' + ISNULL(au_analyst_now.user_m_name + '' '', '''') + au_analyst_now.user_l_name AS VARCHAR(200)) END current_value,
							CAST(au_analyst_prior.user_f_name + '' '' + ISNULL(au_analyst_prior.user_m_name + '' '', '''') + au_analyst_prior.user_l_name AS VARCHAR(200)) prior_value
							UNION ALL

							SELECT N''Account Status'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sdv_account_status_now.code AS VARCHAR(250)) END current_value,
							CAST(sdv_account_status_prior.code AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Risk Rating'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sdv_Risk_rating_now.code AS VARCHAR(250)) END current_value,
							CAST(sdv_Risk_rating_prior.code AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''S&P'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sdv_Debt_rating_now.code AS VARCHAR(250)) END current_value,
							CAST(sdv_Debt_rating_prior.code AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Moody''''s'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sdv_Debt_Rating2_now.code AS VARCHAR(250)) END current_value,
							CAST(sdv_Debt_Rating2_prior.code AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Fitch'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sdv_Debt_Rating3_now.code AS VARCHAR(250)) END current_value,
							CAST(sdv_Debt_Rating3_prior.code AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''D&B'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sdv_Debt_Rating4_now.code AS VARCHAR(250)) END current_value,
							CAST(sdv_Debt_Rating4_prior.code AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Debt Rating 5'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sdv_Debt_Rating5_now.code AS VARCHAR(250)) END current_value,
							CAST(sdv_Debt_Rating5_prior.code AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Rating Outlook'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sdv_rating_outlook_now.code AS VARCHAR(250)) END current_value,
							CAST(sdv_rating_outlook_prior.code AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Qualitative Rating'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sdv_qualitative_rating_now.code AS VARCHAR(250)) END current_value,
							CAST(sdv_qualitative_rating_prior.code AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Industry Type 1'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sdv_Industry_type1_now.code AS VARCHAR(250)) END current_value,
							CAST(sdv_Industry_type1_prior.code AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Industry Type 2'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sdv_Industry_type2_now.code AS VARCHAR(250)) END current_value,
							CAST(sdv_Industry_type2_prior.code AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Ticker Symbol'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(cci_now.Ticker_symbol AS VARCHAR(100)) END current_value,
							CAST(cci_prior.Ticker_symbol AS VARCHAR(100)) prior_value
							UNION ALL

							SELECT N''SIC Code'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sdv_SIC_Code_now.code AS VARCHAR(250)) END current_value,
							CAST(sdv_SIC_Code_prior.code AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Customer Since'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(cci_now.Customer_since AS VARCHAR(20)) END current_value,
							CAST(cci_prior.Customer_since AS VARCHAR(20)) prior_value
							UNION ALL

							SELECT N''Duns Number'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(cci_now.Duns_No AS VARCHAR(100)) END current_value,
							CAST(cci_prior.Duns_No AS VARCHAR(100)) prior_value
							UNION ALL

							SELECT N''Approved By'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(au_approved_by_now.user_f_name + '' '' + ISNULL(au_approved_by_now.user_m_name + '' '', '''') + au_approved_by_now.user_l_name AS VARCHAR(50)) END current_value,
							CAST(au_approved_by_prior.user_f_name + '' '' + ISNULL(au_approved_by_prior.user_m_name + '' '', '''') + au_approved_by_prior.user_l_name AS VARCHAR(50)) prior_value
							UNION ALL

							SELECT N''Date Established'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(cci_now.Date_established AS VARCHAR(20)) END current_value,
							CAST(cci_prior.Date_established AS VARCHAR(20)) prior_value
							UNION ALL

							SELECT N''Last Review Date'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(cci_now.Last_review_date AS VARCHAR(20)) END current_value,
							CAST(cci_prior.Last_review_date AS VARCHAR(20)) prior_value
							UNION ALL

							SELECT N''New Review Date'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(cci_now.Next_review_date AS VARCHAR(20)) END current_value,
							CAST(cci_prior.Next_review_date AS VARCHAR(20)) prior_value
							UNION ALL

							SELECT N''PFE Criteria'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(vmcd_now.name AS VARCHAR(250)) END current_value,
							CAST(vmcd_prior.name AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Exclude Exposure After (Months)'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(cci_now.exclude_exposure_after AS VARCHAR(250)) END current_value,
							CAST(cci_prior.exclude_exposure_after AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Currency'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sc_source_currency_now.currency_id AS VARCHAR(250)) END current_value,
							CAST(sc_source_currency_prior.currency_id AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Watch List'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CASE WHEN ISNULL(cci_now.Watch_list,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END END current_value,
							CASE WHEN ISNULL(cci_prior.Watch_list,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END prior_value
							UNION ALL

							SELECT N''Do not Calculate Credit Exposure'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CASE WHEN ISNULL(cci_now.check_apply,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END END current_value,
							CASE WHEN ISNULL(cci_prior.check_apply,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END prior_value
							UNION ALL

							SELECT N''Buy Notional Month'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(cci_now.buy_notional_month AS VARCHAR(250)) END current_value,
							CAST(cci_prior.buy_notional_month AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Sell Notional Month'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(cci_now.sell_notional_month AS VARCHAR(250)) END current_value,
							CAST(cci_prior.sell_notional_month AS VARCHAR(250)) prior_value

							UNION ALL

							SELECT N''Rating for CVA'' [field] ,
							CASE WHEN cci_now.user_action = ''Delete'' THEN NULL
							ELSE CASE cci_now.cva_data WHEN ''1'' THEN ''Primary Debt Rating'' 
															WHEN ''2'' THEN ''Debt Rating 2'' 
															WHEN ''3'' THEN ''Debt Rating 3'' 
															WHEN ''4'' THEN ''Debt Rating 4'' 
															WHEN ''5'' THEN ''Debt Rating 5'' 
															WHEN ''6'' THEN ''Risk Rating'' 
															WHEN ''7'' THEN ''Counterparty Default Values'' 
															WHEN ''8'' THEN ''Counterparty Credit Spread'' 
															ELSE ''Primary Debt Rating'' 
										END 
								END current_value,
							CASE cci_prior.cva_data WHEN ''1'' THEN ''Primary Debt Rating'' 
															WHEN ''2'' THEN ''Debt Rating 2'' 
															WHEN ''3'' THEN ''Debt Rating 3'' 
															WHEN ''4'' THEN ''Debt Rating 4'' 
															WHEN ''5'' THEN ''Debt Rating 5'' 
															WHEN ''6'' THEN ''Risk Rating'' 
															WHEN ''7'' THEN ''Counterparty Default Values'' 
															WHEN ''8'' THEN ''Counterparty Credit Spread'' 
															ELSE ''Primary Debt Rating'' 
										END 
								 prior_value
														
							'												   
			SET @sql3 =		' ) cols
					WHERE ISNULL(cci_now.update_ts, cci_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') 	
						
				'+ CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND cci_now.counterparty_id IN (' + @source_id +')' ELSE '' END
			SET @sql3 = @sql3+	' ORDER BY cci_now.audit_id DESC'
					
		--PRINT @sql 
		--PRINT @sql2 
		--PRINT @sql3 
		EXEC(@sql + @sql2 + @sql3)
	END

    --Counterparty Credit Enhancements
	IF @static_data = 19925 OR @all_result = 'y'
	BEGIN
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id =  ISNULL(@static_data, 19925)

		SET @sql = @group_result + '
					SELECT UPPER(LEFT(ccea_now.user_action, 1)) + SUBSTRING(ccea_now.user_action, 2, LEN(ccea_now.user_action)) [User Action],
						   ''' + @static_data_name + ''' [Static Data Name],
						   sc_now.counterparty_name + '' - '' + sc_internal_counterparty_now.counterparty_name + '' - '' + cg_contract_id_now.contract_name,
						   cols.field [Field],
						   prior_value [Prior Value],
						   current_value [Current Value],
						   CASE WHEN ccea_now.user_action = ''insert'' 
								THEN COALESCE(ccea_now.create_user, ccea_now.update_user, dbo.FNADBUser())
								ELSE COALESCE(ccea_now.update_user, ccea_now.create_user, dbo.FNADBUser()) 
						   END [Update User],
						   ISNULL(ccea_now.update_ts, ccea_now.create_ts) [Update TS]
					FROM counterparty_credit_enhancements_audit ccea_now
					LEFT JOIN counterparty_credit_info cci
						ON cci.counterparty_credit_info_id = ccea_now.counterparty_credit_info_id
					LEFT JOIN source_counterparty sc_now
						ON sc_now.source_counterparty_id = cci.counterparty_id
					OUTER APPLY(
								SELECT TOP 1 * FROM counterparty_credit_enhancements_audit 
								WHERE  counterparty_credit_enhancements_audit_id < ccea_now.counterparty_credit_enhancements_audit_id AND counterparty_credit_enhancement_id = ccea_now.counterparty_credit_enhancement_id
								ORDER BY counterparty_credit_enhancements_audit_id DESC
					) ccea_prior	
							
						--Internal Counterparty
						LEFT JOIN source_counterparty sc_internal_counterparty_now ON sc_internal_counterparty_now.source_counterparty_id = ccea_now.internal_counterparty
						LEFT JOIN source_counterparty sc_internal_counterparty_prior ON sc_internal_counterparty_prior.source_counterparty_id = ccea_prior.internal_counterparty

						--Contract
						LEFT JOIN contract_group cg_contract_id_now ON cg_contract_id_now.contract_id = ccea_now.contract_id
						LEFT JOIN contract_group cg_contract_id_prior ON cg_contract_id_prior.contract_id = ccea_prior.contract_id

						--Enhancement Type
						LEFT JOIN static_data_value sdv_enhance_type_now ON sdv_enhance_type_now.value_id = ccea_now.enhance_type
						LEFT JOIN static_data_value sdv_enhance_type_prior ON sdv_enhance_type_prior.value_id = ccea_prior.enhance_type

						--Guarantee Counterparty
						LEFT JOIN source_counterparty sc_guarantee_counterparty_now ON sc_guarantee_counterparty_now.source_counterparty_id = ccea_now.guarantee_counterparty
						LEFT JOIN source_counterparty sc_guarantee_counterparty_prior ON sc_guarantee_counterparty_prior.source_counterparty_id = ccea_prior.guarantee_counterparty

						--Currency
						LEFT JOIN source_currency sc_currency_code_now ON sc_currency_code_now.source_currency_id = ccea_now.currency_code
						LEFT JOIN source_currency sc_currency_code_prior ON sc_currency_code_prior.source_currency_id = ccea_prior.currency_code

						--Approved By
						LEFT JOIN application_users au_analyst_approved_by_now ON au_analyst_approved_by_now.user_login_id = ccea_now.approved_by
						LEFT JOIN application_users au_analyst_approved_by_prior ON au_analyst_approved_by_prior.user_login_id = ccea_prior.approved_by

						--Collateral Status
						LEFT JOIN static_data_value sdv_collateral_status_now ON sdv_collateral_status_now.value_id = ccea_now.collateral_status
						LEFT JOIN static_data_value sdv_collateral_status_prior ON sdv_collateral_status_prior.value_id = ccea_prior.collateral_status

						--Deal ID deal_id
						LEFT JOIN source_deal_header sdh_now ON sdh_now.source_deal_header_id = ccea_now.deal_id
						LEFT JOIN source_deal_header sdh_prior ON sdh_prior.source_deal_header_id = ccea_prior.deal_id		  
						'
	
					   SET @sql2 = ' CROSS APPLY(
							
							SELECT N''Internal Counterparty'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sc_internal_counterparty_now.counterparty_name AS VARCHAR(250)) END current_value,
							CAST(sc_internal_counterparty_prior.counterparty_name AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Contract'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(cg_contract_id_now.contract_name AS VARCHAR(250)) END current_value,
							CAST(cg_contract_id_prior.contract_name AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Deal ID'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sdh_now.deal_id AS VARCHAR(50)) END current_value,
							CAST(sdh_prior.deal_id AS VARCHAR(50)) prior_value
							UNION ALL

							SELECT N''Enhancement Type'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sdv_enhance_type_now.code AS VARCHAR(250)) END current_value,
							CAST(sdv_enhance_type_prior.code AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Guarantee Counterparty'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sc_guarantee_counterparty_now.counterparty_name AS VARCHAR(250)) END current_value,
							CAST(sc_guarantee_counterparty_prior.counterparty_name AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Effective Date'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE dbo.FNADateFormat(ccea_now.eff_date) END current_value,
							dbo.FNADateFormat(ccea_prior.eff_date) prior_value
							UNION ALL

							SELECT N''Expiration Date'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE dbo.FNADateFormat(ccea_now.expiration_date) END current_value,
							dbo.FNADateFormat(ccea_prior.expiration_date) prior_value
							UNION ALL

							SELECT N''Amount'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(ccea_now.amount AS VARCHAR(250)) END current_value,
							CAST(ccea_prior.amount AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Currency'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sc_currency_code_now.currency_name AS VARCHAR(250)) END current_value,
							CAST(sc_currency_code_prior.currency_name AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Approved By'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(au_analyst_approved_by_now.user_f_name + '' '' + ISNULL(au_analyst_approved_by_now.user_m_name + '' '', '''') + au_analyst_approved_by_now.user_l_name AS VARCHAR(50)) END current_value,
							CAST(au_analyst_approved_by_prior.user_f_name + '' '' + ISNULL(au_analyst_approved_by_prior.user_m_name + '' '', '''') + au_analyst_approved_by_prior.user_l_name AS VARCHAR(50)) prior_value
							UNION ALL

							SELECT N''Collateral Status'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(sdv_collateral_status_now.code AS VARCHAR(250)) END current_value,
							CAST(sdv_collateral_status_prior.code AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Comment'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(ccea_now.comment AS VARCHAR(100)) END current_value,
							CAST(ccea_prior.comment AS VARCHAR(100)) prior_value
							UNION ALL

							SELECT N''Receive'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CASE WHEN ISNULL(ccea_now.margin,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END END current_value,
							CASE WHEN ISNULL(ccea_prior.margin,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END prior_value
							UNION ALL

							SELECT N''Auto Renewal'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CASE WHEN ISNULL(ccea_now.auto_renewal,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END END current_value,
							CASE WHEN ISNULL(ccea_prior.auto_renewal,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END prior_value
							UNION ALL

							SELECT N''Do not use as Credit Collateral'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CASE WHEN ISNULL(ccea_now.exclude_collateral,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END END current_value,
							CASE WHEN ISNULL(ccea_prior.exclude_collateral,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END prior_value
							UNION ALL

							SELECT N''Blocked'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CASE WHEN ISNULL(ccea_now.blocked,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END END current_value,
							CASE WHEN ISNULL(ccea_prior.blocked,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END prior_value
							UNION ALL

							SELECT N''Info ID'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CAST(ccea_now.counterparty_credit_info_id AS VARCHAR(250)) END current_value,
							CAST(ccea_prior.counterparty_credit_info_id AS VARCHAR(250)) prior_value
							UNION ALL

							SELECT N''Transfer'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CASE WHEN ISNULL(ccea_now.transferred,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END END current_value,
							CASE WHEN ISNULL(ccea_prior.transferred,''n'') = ''n'' THEN ''No'' ELSE ''Yes'' END prior_value
							UNION ALL

							SELECT N''Primary'' [field] ,
							CASE WHEN ccea_now.user_action = ''Delete'' THEN NULL
							ELSE CASE WHEN ISNULL(ccea_now.is_primary,0) = 0 THEN ''No'' ELSE ''Yes'' END END current_value,
							CASE WHEN ISNULL(ccea_prior.is_primary,0) = 0 THEN ''No'' ELSE ''Yes'' END prior_value

														
							'												   
			SET @sql3 =		' ) cols
					WHERE ISNULL(ccea_now.update_ts, ccea_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') 
					'+ CASE WHEN NULLIF(@source_id,'') IS NOT NULL THEN 'AND cci.counterparty_id IN (' + @source_id +')' ELSE '' END
			
			SET @sql3 =	@sql3 + 'ORDER BY ccea_now.counterparty_credit_enhancements_audit_id DESC'
					
		--PRINT @sql 
		--PRINT @sql2 
		--PRINT @sql3 
		EXEC(@sql + @sql2 + @sql3)
	END

    --Counterparty Credit Limits
	IF @static_data = 19926 OR @all_result = 'y'
	BEGIN
		SELECT @static_data_name = sdv.code
		FROM   static_data_value sdv
		WHERE  sdv.value_id =  ISNULL(@static_data, 19926)

		SET @sql = @group_result + '
					SELECT UPPER(LEFT(ccl_now.user_action, 1)) + SUBSTRING(ccl_now.user_action, 2, LEN(ccl_now.user_action)) [User Action],
						   ''' + @static_data_name + ''' [Static Data Name],
						   sc_counterparty_id_now.counterparty_name,
						   cols.field [Field],
						   prior_value [Prior Value],
						   current_value [Current Value],
						   CASE WHEN ccl_now.user_action = ''insert'' 
								THEN COALESCE(ccl_now.create_user, ccl_now.update_user, dbo.FNADBUser())
								ELSE COALESCE(ccl_now.update_user, ccl_now.create_user, dbo.FNADBUser()) 
						   END [Update User],
						   ISNULL(ccl_now.update_ts, ccl_now.create_ts) [Update TS]
					FROM counterparty_credit_limits_audit ccl_now
					OUTER APPLY(
								SELECT TOP 1 * FROM counterparty_credit_limits_audit 
								WHERE  audit_id < ccl_now.audit_id AND counterparty_credit_limit_id = ccl_now.counterparty_credit_limit_id
								ORDER BY audit_id DESC
					) ccl_prior	

						--Internal Counterparty
						LEFT JOIN source_counterparty sc_internal_counterparty_id_now ON sc_internal_counterparty_id_now.source_counterparty_id = ccl_now.internal_counterparty_id
						LEFT JOIN source_counterparty sc_internal_counterparty_id_prior ON sc_internal_counterparty_id_prior.source_counterparty_id = ccl_prior.internal_counterparty_id

						--Contract
						LEFT JOIN contract_group cg_contract_id_now ON cg_contract_id_now.contract_id = ccl_now.contract_id
						LEFT JOIN contract_group cg_contract_id_prior ON cg_contract_id_prior.contract_id = ccl_prior.contract_id

						--Currency
						LEFT JOIN source_currency sc_currency_id_now ON sc_currency_id_now.source_currency_id = ccl_now.currency_id
						LEFT JOIN source_currency sc_currency_id_prior ON sc_currency_id_prior.source_currency_id = ccl_prior.currency_id

						--Counterparty ID
						LEFT JOIN source_counterparty sc_counterparty_id_now ON sc_counterparty_id_now.source_counterparty_id = ccl_now.counterparty_id
						LEFT JOIN source_counterparty sc_counterparty_id_prior ON sc_counterparty_id_prior.source_counterparty_id = ccl_prior.counterparty_id

						--Limit Status
						LEFT JOIN static_data_value sdv_limit_status_now ON sdv_limit_status_now.value_id = ccl_now.limit_status
						LEFT JOIN static_data_value sdv_limit_status_prior ON sdv_limit_status_prior.value_id = ccl_prior.limit_status								  
						'
	
					   SET @sql2 = ' CROSS APPLY(
								
								SELECT N''Internal Counterparty'' [field] ,
								CASE WHEN ccl_now.user_action = ''Delete'' THEN NULL
								ELSE CAST(sc_internal_counterparty_id_now.counterparty_name AS VARCHAR(250)) END current_value,
								CAST(sc_internal_counterparty_id_prior.counterparty_name AS VARCHAR(250)) prior_value
								UNION ALL

								SELECT N''Contract'' [field] ,
								CASE WHEN ccl_now.user_action = ''Delete'' THEN NULL
								ELSE CAST(cg_contract_id_now.contract_name AS VARCHAR(250)) END current_value,
								CAST(cg_contract_id_prior.contract_name AS VARCHAR(250)) prior_value
								UNION ALL

								SELECT N''Effective Date'' [field] ,
								CASE WHEN ccl_now.user_action = ''Delete'' THEN NULL
								ELSE dbo.FNADateFormat(ccl_now.effective_Date) END current_value,
								dbo.FNADateFormat(ccl_prior.effective_Date) prior_value
								UNION ALL

								SELECT N''Credit Limit'' [field] ,
								CASE WHEN ccl_now.user_action = ''Delete'' THEN NULL
								ELSE CAST(ccl_now.credit_limit AS VARCHAR(250)) END current_value,
								CAST(ccl_prior.credit_limit AS VARCHAR(250)) prior_value
								UNION ALL

								SELECT N''Credit Limit to Us'' [field] ,
								CASE WHEN ccl_now.user_action = ''Delete'' THEN NULL
								ELSE CAST(ccl_now.credit_limit_to_us AS VARCHAR(250)) END current_value,
								CAST(ccl_prior.credit_limit_to_us AS VARCHAR(250)) prior_value
								UNION ALL

								SELECT N''Currency'' [field] ,
								CASE WHEN ccl_now.user_action = ''Delete'' THEN NULL
								ELSE CAST(sc_currency_id_now.currency_name AS VARCHAR(250)) END current_value,
								CAST(sc_currency_id_prior.currency_name AS VARCHAR(250)) prior_value
								UNION ALL

								SELECT N''Maximum Threshold (%)'' [field] ,
								CASE WHEN ccl_now.user_action = ''Delete'' THEN NULL
								ELSE CAST(ccl_now.max_threshold AS VARCHAR(250)) END current_value,
								CAST(ccl_prior.max_threshold AS VARCHAR(250)) prior_value
								UNION ALL

								SELECT N''Minimum Threshold (%)'' [field] ,
								CASE WHEN ccl_now.user_action = ''Delete'' THEN NULL
								ELSE CAST(ccl_now.min_threshold AS VARCHAR(250)) END current_value,
								CAST(ccl_prior.min_threshold AS VARCHAR(250)) prior_value
								UNION ALL

								SELECT N''Tenor Limit (#Days)'' [field] ,
								CASE WHEN ccl_now.user_action = ''Delete'' THEN NULL
								ELSE CAST(ccl_now.tenor_limit AS VARCHAR(250)) END current_value,
								CAST(ccl_prior.tenor_limit AS VARCHAR(250)) prior_value
								UNION ALL

								SELECT N''Counterparty ID'' [field] ,
								CASE WHEN ccl_now.user_action = ''Delete'' THEN NULL
								ELSE CAST(sc_counterparty_id_now.counterparty_name AS VARCHAR(250)) END current_value,
								CAST(sc_counterparty_id_prior.counterparty_name AS VARCHAR(250)) prior_value
								UNION ALL

								SELECT N''Threshold Provided'' [field] ,
								CASE WHEN ccl_now.user_action = ''Delete'' THEN NULL
								ELSE CAST(ccl_now.threshold_provided AS VARCHAR(250)) END current_value,
								CAST(ccl_prior.threshold_provided AS VARCHAR(250)) prior_value
								UNION ALL

								SELECT N''Threshold Received'' [field] ,
								CASE WHEN ccl_now.user_action = ''Delete'' THEN NULL
								ELSE CAST(ccl_now.threshold_received AS VARCHAR(250)) END current_value,
								CAST(ccl_prior.threshold_received AS VARCHAR(250)) prior_value
								UNION ALL

								SELECT N''Limit Status'' [field] ,
								CASE WHEN ccl_now.user_action = ''Delete'' THEN NULL
								ELSE CAST(sdv_limit_status_now.code AS VARCHAR(250)) END current_value,
								CAST(sdv_limit_status_prior.code AS VARCHAR(250)) prior_value
										
							'												   
			SET @sql3 =		' ) cols
					WHERE ISNULL(ccl_now.update_ts, ccl_now.create_ts) BETWEEN ''' + @as_of_date_from + ''' AND ''' + @as_of_date_to + ' 23:59:59''						  
						AND ISNULL(current_value, '''') <> ISNULL(prior_value, '''') 		
					ORDER BY ccl_now.audit_id DESC'
					
		--PRINT @sql 
		--PRINT @sql2 
		--PRINT @sql3 
		EXEC(@sql + @sql2 + @sql3)
	END

	--Counterparty Contacts
	--Print Result	
	IF @static_data IS NULL OR @static_data <> 19909
	BEGIN
		
		--SELECT * INTO adiha_process.dbo.store_all_result FROM #store_all_result		
		
		SET @sql = '
			SELECT [User Action],
				   dbo.FNADateTimeFormat([Timestamp], 1) [Timestamp],
				   [User],
				   [Static Data Name],
				   [Name],
				   Field,
				   [Prior Value],
				   [Current Value] 
			' + @str_batch_table + ' 
			FROM (
				SELECT [User Action],
					   MAX([Timestamp]) [Timestamp],
					   MAX([User]) [User],
					   [Static Data Name],
					   [Name],
					   Field,
					   [Prior Value],
					   [Current Value] 
				FROM (
					SELECT [User Action],
						   [Static Data Name],
						   [Name],
						   CASE 
								WHEN [User Action] = ''Insert'' OR [User Action] = ''Delete'' 
									THEN CASE 
											WHEN [Field] = ''Block Definition'' THEN [Field]  
											ELSE ''''
											END
								ELSE [Field] 
						   END Field,
						   CASE 
								WHEN [User Action] = ''Insert'' OR [User Action] = ''Delete'' THEN ''''
								ELSE [Prior Value] 
						   END [Prior Value],
						   CASE 
								WHEN [User Action] = ''Insert'' THEN 
									CASE WHEN [Field] = ''Block Definition'' THEN [Current Value] ELSE [Name] END 
								WHEN [User Action] = ''Delete'' THEN ''''														   
								ELSE [Current Value]							
						   END [Current Value],
						   dbo.FNAGetUserName([Update User]) [User],
						   [Update Time Stamp] [Timestamp]
					FROM   #store_all_result	
					WHERE [User Action] = CASE WHEN ''' + ISNULL(@user_action, 'all' ) + ''' = ''all'' THEN [User Action] ELSE ''' + ISNULL(@user_action, 'all' ) + ''' END
				) ar
				GROUP BY ar.[User Action],ar.[Static Data Name],ar.[Name],ar.Field,ar.[Prior Value],ar.[Current Value]--,ar.[User]
			) fn
			GROUP BY [User Action],[Static Data Name],[Name],Field,[Prior Value],[Current Value],[User],[Timestamp]
			ORDER BY [Timestamp] DESC'
		
		EXEC spa_print @sql
		EXEC(@sql)
		
	END			
END


/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)

   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_static_data_audit', 'Static Data Audit Log')
   EXEC(@sql_paging)  

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