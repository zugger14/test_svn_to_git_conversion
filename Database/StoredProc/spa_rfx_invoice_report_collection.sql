IF OBJECT_ID(N'[dbo].[spa_rfx_invoice_report_collection]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_invoice_report_collection]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Invoice related operations 
	Parameters
	@invoice_ids	:	Invoice Ids
	@runtime_user	:	Runtime User
	@flag			:	'a' Deal invoice
						'b' Settlement invoice STMT
	@user_login_id : Application user to get number format.  
*/
CREATE PROC [dbo].[spa_rfx_invoice_report_collection] 
	@invoice_ids VARCHAR(MAX), 
	@runtime_user VARCHAR(MAX),
	@flag CHAR(1) = 'a', -- a: Deal invoice; b: Settlement invoice STMT
	@user_login_id VARCHAR(MAX) = NULL
AS 
SET NOCOUNT ON

SET @flag = ISNULL(NULLIF(@flag, ''), 'a')

IF @flag = 'a'
BEGIN  
 EXEC('SELECT
	DISTINCT
    CONVERT(VARCHAR(10),civv.as_of_date,120) as_of_date,  
    civv.counterparty_id,  
    CONVERT(VARCHAR(10),civv.prod_date,120) prod_date,  
    civv.contract_id ,
    civv.invoice_type ,
    ISNULL(civv.netting_group_id,-1) netting_group_id,
    CASE WHEN a.[item] < 0 THEN ''Netting'' ELSE CASE WHEN [status] = ''v'' THEN ''Credit Note'' WHEN civv.invoice_type = ''i'' THEN ''Invoice'' 
	ELSE ''Remittance'' END END report_type,
	CASE WHEN a.[item] < 0 THEN 21502 ELSE NULL END statement_type,
	CONVERT(VARCHAR(10),civv.settlement_date,120) settlement_date,
	--ISNULL(crp_civv_template.[filename],ISNULL(CASE WHEN a.[item] < 0 THEN crp_netting.filename WHEN civv.invoice_type = ''i'' THEN crp_invoice.filename 
	--ELSE crp_remittance.filename END, def_val.default_filename)) template_filename

	COALESCE(
		(CASE WHEN a.[item] < 0 THEN crp_netting.filename ELSE NULL END)			--if the invoice type is netting, show netting template
		, crp_civv_template.[filename]											--otherwise, show template defined in charge type (civv)
		, ISNULL(CASE WHEN civv.invoice_type = ''i'' THEN crp_invoice.filename 	--otherwise, show invoice template if the type if Invoice
					ELSE crp_remittance.filename END							--otherwise, show remittance template if type is remittance
			, def_val.default_filename)											--if none available (least chance), show a default template
		) template_filename
	,COALESCE(
		(CASE WHEN a.[item] < 0 THEN crp_netting.template_name ELSE NULL END)			--if the invoice type is netting, show netting template
		, crp_civv_template.[template_name]											--otherwise, show template defined in charge type (civv)
		, ISNULL(CASE WHEN civv.invoice_type = ''i'' THEN crp_invoice.template_name 	--otherwise, show invoice template if the type if Invoice
					ELSE crp_remittance.template_name END							--otherwise, show remittance template if type is remittance
			, def_val.default_filename)											--if none available (least chance), show a default template
		) template_name	,
		civv.calc_id
		,ISNULL(un.client_date_format, ''dd/MM/yyyy'') client_date_format
       FROM   Calc_invoice_Volume_variance civv
       INNER JOIN (SELECT [item] FROM dbo.SplitCommaSeperatedValues('''+@invoice_ids+''')) a ON ABS(a.item) =  civv.calc_id
       LEFT JOIN contract_group cg ON cg.contract_id = civv.contract_id
       LEFT JOIN Contract_report_template crp_invoice ON crp_invoice.template_id = cg.invoice_report_template
       LEFT JOIN Contract_report_template crp_remittance ON crp_remittance.template_id = cg.Contract_report_template
       LEFT JOIN Contract_report_template crp_netting ON crp_netting.template_id = cg.netting_template
	   LEFT JOIN contract_report_template crp_civv_template ON civv.invoice_template_id = crp_civv_template.template_id
       CROSS APPLY(
                    SELECT MAX([status]) [status]
                    FROM   calc_invoice_volume
                    WHERE  calc_id = civv.calc_id
                ) civ_status
       LEFT JOIN (
	   				SELECT crt2.[filename] [default_filename], crt2.template_type, crt2.template_name 
	   				FROM contract_report_template crt2 
	   				WHERE crt2.[default] = 1
					ANd crt2.[document_type] = ''r''
		) def_val ON def_val.template_type = 38
		OUTER APPLY (
		SELECT  REPLACE(date_format, ''mm'', ''MM'')  client_date_format
		FROM application_users au
		INNER JOIN region rg ON au.region_id = rg.region_id
		WHERE user_login_id = ('''+@runtime_user+''')
		) un
 ')     
END   
ELSE IF @flag = 'b'
BEGIN
	SELECT 
		 CASE 
		   WHEN @invoice_ids < 0 
				THEN 'Netting'
		   WHEN si.invoice_type = 'i' 
				THEN 'Invoice'
		   ELSE 'Remitance'
		 END report_type
		,CASE 
		   WHEN @invoice_ids < 0 
				THEN IIF(crp_netting.document_type ='e', crp_netting.template_name, crp_netting.filename) 
		   WHEN si.invoice_type = 'i' 
				THEN IIF(crp_invoice.document_type ='e', crp_invoice.template_name, crp_invoice.filename )
		   ELSE IIF(crp_remittance.document_type ='e', crp_remittance.template_name, crp_remittance.filename ) 
		 END template_filename
		, ABS(@invoice_ids) [save_invoice_id]
		, '' as_of_date
		, '' counterparty_id
		, '' prod_date
		, '' contract_id
		, '' invoice_type
		, '' netting_group_id
		, '' statement_type
		, '' settlement_date
		, '' template_name
		, ABS(@invoice_ids) calc_id
		, '' client_date_format
		, '' source_deal_header_id
		, un.global_number_format_region
	FROM stmt_invoice si
	INNER JOIN (
		SELECT [item] FROM dbo.SplitCommaSeperatedValues(ABS(@invoice_ids))
	) a
		ON ABS(a.item) = si.stmt_invoice_id
	LEFT JOIN contract_group cg
		ON cg.contract_id = si.contract_id
	LEFT JOIN Contract_report_template crp_invoice
		ON crp_invoice.template_id = cg.invoice_report_template
	LEFT JOIN Contract_report_template crp_remittance
		ON crp_remittance.template_id = cg.Contract_report_template
	LEFT JOIN Contract_report_template crp_netting
		ON crp_netting.template_id = cg.netting_template
	LEFT JOIN contract_report_template crp_civv_template
		ON si.invoice_template_id = crp_civv_template.template_id
	OUTER APPLY (
		SELECT  case when (ISNULL(decimal_separator, '.') = '.' and ISNULL(group_separator, ',') = ',') Then 'en-US' Else 'de-DE' end global_number_format_region
		FROM application_users au
		INNER JOIN region rg ON au.region_id = rg.region_id
		WHERE user_login_id = @user_login_id
	) un	
END 


