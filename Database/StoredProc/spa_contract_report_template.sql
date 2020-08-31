IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_contract_report_template]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_contract_report_template]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================
--	Author: navaraj@pioneersolutionsglobal.com 
--  Create date: 
--	@flag CHAR(1):  'x' - Select custom report template grid 
-- 'i' - insert ,  'u' - update ,'d'- Delete 'f'- used load combo of excel file , 'b'- used load combo excel sheet.

--	@template_name VARCHAR(50) = NULL: Template name param
--	@template_description VARCHAR(100) = NULL: Template description param
--	@sub_id INT = NULL:
--	@filename VARCHAR(1000) = NULL: filename param e.g RDL 
--	@contract_id INT = NULL:
--	@template_type INT = NULL: Template type param e.g Invoice, Deal etc.
--	@default BIT = 0: Default param to set default template.
--	@document_type CHAR(1) = NULL: Document type param used r for RDL, w for word, e for Excel.
--	@xml_map_filename VARCHAR(200) = NULL:
--	@template_category INT = NULL: Template category param e.g Trade Ticket, Invoice etc.
--	@data_source VARCHAR(500) = NULL:
--	@xml_data XML = NULL:
--	@excel_sheet_id INT = NULL: Excel Sheet param 
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_contract_report_template]
	@flag CHAR(1),
	@template_id INT = NULL,
	@template_name VARCHAR(50) = NULL,
	@template_description VARCHAR(100) = NULL,
	@sub_id INT = NULL,
	@filename VARCHAR(1000) = NULL,
	@contract_id INT = NULL,
	@template_type INT = NULL,
	@default BIT = 0,
	@document_type CHAR(1) = NULL,
	@xml_map_filename VARCHAR(200) = NULL,
	@template_category INT = NULL,
	@data_source VARCHAR(500) = NULL,
	@xml_data XML = NULL,
	@excel_sheet_id INT = NULL,
	--for multiple deletion
	@del_template_id VARCHAR(MAX) = NULL
AS
/*
DECLARE @flag CHAR(1),
	@template_id INT = NULL,
	@template_name VARCHAR(50) = NULL,
	@template_description VARCHAR(100) = NULL,
	@sub_id INT = NULL,
	@filename VARCHAR(1000) = NULL,
	@contract_id INT = NULL,
	@template_type INT = NULL,
	@default BIT = 0,
	@document_type CHAR(1) = NULL,
	@xml_map_filename VARCHAR(200) = NULL,
	@template_category INT = NULL,
	@data_source VARCHAR(500) = NULL,
	@xml_data XML = NULL

	SELECT  @flag='u',@template_id=83,@template_name='Outward Collection Instructions Purchase CAD to Ba',@template_description='Outward Collection Instructions Purchase CAD to Ba', @sub_id=null, @filename='',@contract_id= null,@template_type= 45,@default=0, @document_type= 'w',@xml_map_filename= 'Outward_Collection_Instructions _Purchase_CAD_to_Bank_XML', @template_category='42011',@data_source= '2589',
	@xml_data= '<Grid><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " Account_no" mapping_column = " Account_no" data_source_column_id = " 16181" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " ACH_ABA" mapping_column = " ACH_ABA" data_source_column_id = " 16182" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " address" mapping_column = " address" data_source_column_id = " 16183" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " address1" mapping_column = " address1" data_source_column_id = " 16184" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " address2" mapping_column = " address2" data_source_column_id = " 16185" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " attribute1" mapping_column = " attribute1" data_source_column_id = " 16186" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " attribute2" mapping_column = " attribute2" data_source_column_id = " 16187" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " attribute3" mapping_column = " attribute3" data_source_column_id = " 16188" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " attribute4" mapping_column = " attribute4" data_source_column_id = " 16189" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " attribute5" mapping_column = " attribute5" data_source_column_id = " 16190" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " bank_id" mapping_column = " bank_id" data_source_column_id = " 16191" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " bank_name" mapping_column = " bank_name" data_source_column_id = " 16192" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " bcc_email" mapping_column = " bcc_email" data_source_column_id = " 16193" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " bcc_remittance" mapping_column = " bcc_remittance" data_source_column_id = " 16194" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " buyer_contact_name" mapping_column = " buyer_contact_name" data_source_column_id = " 16195" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " buyer_contract_address" mapping_column = " buyer_contract_address" data_source_column_id = " 16196" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " buyer_contract_address2" mapping_column = " buyer_contract_address2" data_source_column_id = " 16197" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " buyer_contract_phone" mapping_column = " buyer_contract_phone" data_source_column_id = " 16198" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " buyer_fax" mapping_column = " buyer_fax" data_source_column_id = " 16199" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " buyer_name" mapping_column = " buyer_name" data_source_column_id = " 16200" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " cc_email" mapping_column = " cc_email" data_source_column_id = " 16201" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " cc_remittance" mapping_column = " cc_remittance" data_source_column_id = " 16202" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " cell_no" mapping_column = " cell_no" data_source_column_id = " 16203" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " city" mapping_column = " city" data_source_column_id = " 16204" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " comment" mapping_column = " comment" data_source_column_id = " 16205" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " confirm_from_text" mapping_column = " confirm_from_text" data_source_column_id = " 16206" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " confirm_instruction" mapping_column = " confirm_instruction" data_source_column_id = " 16207" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " confirm_to_text" mapping_column = " confirm_to_text" data_source_column_id = " 16208" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_address" mapping_column = " contact_address" data_source_column_id = " 16209" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_address2" mapping_column = " contact_address2" data_source_column_id = " 16210" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_city" mapping_column = " contact_city" data_source_column_id = " 16211" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_country1" mapping_column = " contact_country1" data_source_column_id = " 16212" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_email" mapping_column = " contact_email" data_source_column_id = " 16213" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_email1" mapping_column = " contact_email1" data_source_column_id = " 16214" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_fax" mapping_column = " contact_fax" data_source_column_id = " 16215" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_fax1" mapping_column = " contact_fax1" data_source_column_id = " 16216" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_is_active1" mapping_column = " contact_is_active1" data_source_column_id = " 16217" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_isPrimary" mapping_column = " contact_isPrimary" data_source_column_id = " 16218" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_name" mapping_column = " contact_name" data_source_column_id = " 16219" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_phone" mapping_column = " contact_phone" data_source_column_id = " 16220" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_region1" mapping_column = " contact_region1" data_source_column_id = " 16221" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_state" mapping_column = " contact_state" data_source_column_id = " 16222" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_telephone" mapping_column = " contact_telephone" data_source_column_id = " 16223" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_title" mapping_column = " contact_title" data_source_column_id = " 16224" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_type" mapping_column = " contact_type" data_source_column_id = " 16225" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " contact_zip" mapping_column = " contact_zip" data_source_column_id = " 16226" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " counterparty_contact_id" mapping_column = " counterparty_contact_id" data_source_column_id = " 16227" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " counterparty_contact_name" mapping_column = " counterparty_contact_name" data_source_column_id = " 16228" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " counterparty_contact_title" mapping_column = " counterparty_contact_title" data_source_column_id = " 16229" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " counterparty_desc" mapping_column = " counterparty_desc" data_source_column_id = " 16230" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " counterparty_id" mapping_column = " counterparty_id" data_source_column_id = " 16231" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " counterparty_name" mapping_column = " counterparty_name" data_source_column_id = " 16232" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " country" mapping_column = " country" data_source_column_id = " 16233" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " currency_name" mapping_column = " currency_name" data_source_column_id = " 16234" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " customer_duns_number" mapping_column = " customer_duns_number" data_source_column_id = " 16235" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " cycle" mapping_column = " cycle" data_source_column_id = " 16236" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " delivery_method" mapping_column = " delivery_method" data_source_column_id = " 16237" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " email" mapping_column = " email" data_source_column_id = " 16238" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " email_bcc" mapping_column = " email_bcc" data_source_column_id = " 16239" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " email_cc" mapping_column = " email_cc" data_source_column_id = " 16240" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " email_remittance_to" mapping_column = " email_remittance_to" data_source_column_id = " 16241" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " fax" mapping_column = " fax" data_source_column_id = " 16242" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " fixed_cost_currency_id" mapping_column = " fixed_cost_currency_id" data_source_column_id = " 16243" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " fixed_price" mapping_column = " fixed_price" data_source_column_id = " 16244" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " form" mapping_column = " form" data_source_column_id = " 16245" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " id" mapping_column = " id" data_source_column_id = " 16246" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " instruction" mapping_column = " instruction" data_source_column_id = " 16247" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " int_ext_flag" mapping_column = " int_ext_flag" data_source_column_id = " 16248" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " internal_bank_accountname" mapping_column = " internal_bank_accountname" data_source_column_id = " 16249" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " internal_bank_address" mapping_column = " internal_bank_address" data_source_column_id = " 16250" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " internal_bank_address2" mapping_column = " internal_bank_address2" data_source_column_id = " 16251" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " internal_bank_reference" mapping_column = " internal_bank_reference" data_source_column_id = " 16252" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " is_active" mapping_column = " is_active" data_source_column_id = " 16253" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " is_jurisdiction" mapping_column = " is_jurisdiction" data_source_column_id = " 16254" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " mailing_address" mapping_column = " mailing_address" data_source_column_id = " 16255" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " name" mapping_column = " name" data_source_column_id = " 16256" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " netting_parent_counterparty_id" mapping_column = " netting_parent_counterparty_id" data_source_column_id = " 16257" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " organic" mapping_column = " organic" data_source_column_id = " 16258" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " origin" mapping_column = " origin" data_source_column_id = " 16259" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " parent_counterparty_id" mapping_column = " parent_counterparty_id" data_source_column_id = " 16260" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " phone_no" mapping_column = " phone_no" data_source_column_id = " 16261" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " region" mapping_column = " region" data_source_column_id = " 16262" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " sale_deal_id" mapping_column = " sale_deal_id" data_source_column_id = " 16263" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " seller_contact_name" mapping_column = " seller_contact_name" data_source_column_id = " 16264" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " seller_contract_address" mapping_column = " seller_contract_address" data_source_column_id = " 16265" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " seller_contract_address2" mapping_column = " seller_contract_address2" data_source_column_id = " 16266" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " seller_contract_phone" mapping_column = " seller_contract_phone" data_source_column_id = " 16267" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " seller_fax" mapping_column = " seller_fax" data_source_column_id = " 16268" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " seller_name" mapping_column = " seller_name" data_source_column_id = " 16269" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " source_counterparty_id" mapping_column = " source_counterparty_id" data_source_column_id = " 16270" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " source_system_id" mapping_column = " source_system_id" data_source_column_id = " 16271" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " state" mapping_column = " state" data_source_column_id = " 16272" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " tax_id" mapping_column = " tax_id" data_source_column_id = " 16273" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " title" mapping_column = " title" data_source_column_id = " 16274" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " type_of_entity" mapping_column = " type_of_entity" data_source_column_id = " 16275" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " wire_ABA" mapping_column = " wire_ABA" data_source_column_id = " 16276" data_source_id = " 2589"  /><GridRow mapping_id = " " name = " Counterparty_info" data_source_column = " zip" mapping_column = " zip" data_source_column_id = " 16277" data_source_id = " 2589"  /></Grid>'

--*/

SET NOCOUNT ON
IF OBJECT_ID('tempdb..#contract_views') IS NOT NULL
    DROP TABLE #contract_views
IF OBJECT_ID('tempdb..#data_source') IS NOT NULL
    DROP TABLE #data_source

IF OBJECT_ID('tempdb..#mapping_table_detail') IS NOT NULL
    DROP TABLE #mapping_table_detail

IF @document_type = 'r' AND @flag = 'u'
BEGIN
	SET @excel_sheet_id = NULL
END

IF @document_type = 'e' AND @flag = 'u'
BEGIN
	SET @filename = NULL
END

IF @excel_sheet_id = ''
	SET @excel_sheet_id = NULL

IF OBJECT_ID('tempdb..#contract_report_views_id') IS NOT NULL
    DROP TABLE #contract_report_views_id
	
	CREATE TABLE #data_source(data_source_id INT,template_id VARCHAR(100) COLLATE DATABASE_DEFAULT ) 
	CREATE TABLE #contract_report_views_id (ID INT)

	INSERT INTO #data_source(data_source_id,template_id)
	SELECT *,@template_id FROM dbo.SplitCommaSeperatedValues( @data_source)

	DECLARE @idoc INT
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data
	
	SELECT 
	mapping_id
		,name
		,data_source_column
		,mapping_column
		,data_source_column_id
		,data_source_id
	INTO #mapping_table_detail
	FROM OPENXML(@idoc, '/Grid/GridRow', 1) WITH (
			mapping_id INT
			,name VARCHAR(200)
			,data_source_column VARCHAR(200)
			,mapping_column VARCHAR(200)
			,data_source_column_id VARCHAR(200)
			,data_source_id VARCHAR(200)
			)
	
DECLARE @last_id INT
DECLARE @custom_template_id_val INT
IF @flag = 's'

BEGIN
    SELECT template_id AS [Template ID],
           template_name AS [Template Name],
           template_desc AS [Template Description],
           sub_id AS [Sub ID],
           [filename] AS [File Name]
    FROM   contract_report_template
    WHERE  sub_id = @sub_id
END
ELSE 
IF @flag = 'm'

BEGIN
    SELECT template_id,
           template_name
    FROM   contract_report_template
END
ELSE 
IF @flag = 'i'
BEGIN
	IF NOT EXISTS (SELECT 1 FROM [contract_report_template]   WHERE  template_type = @template_type)
	BEGIN
		 INSERT INTO contract_report_template
		  (
			template_name,
			template_desc,
			sub_id,
			[filename],
			template_type,
			[default],
			document_type,
			xml_map_filename,
			template_category,
			excel_sheet_id
 
		  )
		VALUES
		  (
			@template_name,
			@template_description,
			@sub_id,
			@filename,
			@template_type,
			1,
			@document_type,
			@xml_map_filename,
			@template_category,
			@excel_sheet_id
		  )
   
		SET @custom_template_id_val = SCOPE_IDENTITY();

		INSERT INTO contract_report_template_views (
				template_id
				,data_source_id
				)
			OUTPUT inserted.contract_report_template_views_id
			INTO #contract_report_views_id
			SELECT @custom_template_id_val
				,data_source_id
			FROM #data_source where data_source_id <> 0


	  	INSERT INTO template_view_mapping (
				contract_template_views_id
				,columns_id
				,tag_name
				)
			SELECT id.ID AS contract_template_views_id
				,data_source_column_id
				,mapping_column
		FROM #contract_report_views_id id
			INNER JOIN contract_report_template_views crtv ON crtv.contract_report_template_views_id = id.ID
			INNER JOIN #mapping_table_detail mtd ON mtd.data_source_id = crtv.data_source_id
			
		EXEC spa_ErrorHandler 0,
			'Setup Custom Report Template',
			'spa_contract_report_template',
			'Success',
			'Changes have been saved successfully.',
			@custom_template_id_val
	END
	ELSE
	BEGIN
		IF EXISTS(
				SELECT 1 FROM contract_report_template crt 
				WHERE (crt.template_category = 42022 AND @template_category = 42022)
					OR (crt.template_category = 42023 AND @template_category = 42023)
					OR (crt.template_category = 42024 AND @template_category = 42024)
				)
		BEGIN
    		EXEC spa_ErrorHandler -1,
				 'SetupContractReportTemplate',
				 'spa_contract_report_template',
				 'DB Error',
				 'Collection Template already exists.',
				 ''
			RETURN
		END
		
		IF EXISTS(SELECT 1 FROM contract_report_template crt WHERE template_name = @template_name)
		BEGIN
    		EXEC spa_ErrorHandler -1,
				 'SetupContractReportTemplate',
				 'spa_contract_report_template',
				 'DB Error',
				 'Template Name already exists.',
				 ''
			RETURN
		END
		
		IF EXISTS(SELECT 1 FROM contract_report_template crt WHERE  crt.template_type = @template_type AND crt.[filename] = ISNULL(NULLIF(@filename,''),'aaaaa'))
		BEGIN
    		EXEC spa_ErrorHandler -1,
				 'SetupContractReportTemplate',
				 'spa_contract_report_template',
				 'DB Error',
				 'Filename already exists.',
				 ''
			RETURN
		END
		IF @default = 1
		BEGIN
			UPDATE contract_report_template
			SET [default] = 0
			WHERE template_type = @template_type AND template_category = @template_category
		END
		INSERT INTO contract_report_template
			  (
				template_name,
				template_desc,
				sub_id,
				[filename],
				template_type,
				[default],
				document_type,
				xml_map_filename,
				template_category,
				excel_sheet_id
			  )
			VALUES
			  (
				@template_name,
				@template_description,
				@sub_id,
				@filename,
				@template_type,
				@default,
				@document_type,
				@xml_map_filename,
				@template_category,
				@excel_sheet_id
			  )		  
		
		SET @custom_template_id_val = SCOPE_IDENTITY();
    
		INSERT INTO contract_report_template_views (
				template_id
				,data_source_id
				)
			OUTPUT inserted.contract_report_template_views_id
			INTO #contract_report_views_id
			SELECT @custom_template_id_val
				,data_source_id
			FROM #data_source where data_source_id <> 0
	   	   
			INSERT INTO template_view_mapping (
				contract_template_views_id
				,columns_id
				,tag_name
				)
			SELECT id.ID AS contract_template_views_id
				,data_source_column_id
				,mapping_column
			FROM #contract_report_views_id id
			INNER JOIN contract_report_template_views crtv ON crtv.contract_report_template_views_id = id.ID
			INNER JOIN #mapping_table_detail mtd ON mtd.data_source_id = crtv.data_source_id

		IF @@Error <> 0
			EXEC spa_ErrorHandler @@Error,
				 'SetupContractReportTemplate',
				 'spa_contract_report_template',
				 'DB Error',
				 'Failed to save Data.',
				 ''
		ELSE
			EXEC spa_ErrorHandler 0,
				 'Setup Custom Report Template',
				 'spa_contract_report_template',
				 'Success',
				 'Changes have been saved successfully.',
				 @custom_template_id_val
	END
	
END
ELSE 
IF @flag = 'a'
BEGIN
    IF @template_id IS NOT NULL
        SELECT template_id AS [Template ID],
           template_name AS [Template Name],
           template_desc AS [Template Description],
           sub_id AS [Sub ID],
           [filename] AS [File Name]
        FROM   contract_report_template
        WHERE  template_id = @template_id
    
    IF @contract_id IS NOT NULL
        SELECT DISTINCT template_id AS [Template ID],
           template_name AS [Template Name],
           template_desc AS [Template Description],
           crt.sub_id AS [Sub ID],
           [filename] AS [File Name]
        FROM   contract_report_template crt
               JOIN contract_group cg
                    ON  crt.template_id = cg.contract_report_template
        WHERE  cg.contract_id = @contract_id
END

ELSE 
IF @flag = 'u'

BEGIN	

	IF EXISTS(SELECT 1 FROM contract_report_template crt WHERE template_name = @template_name AND crt.template_id <> @template_id)
    BEGIN
    	EXEC spa_ErrorHandler -1,
             'SetupContractReportTemplate',
             'spa_contract_report_template',
             'DB Error',
             'Template Name already exists.',
             ''
        RETURN
    END
	
	IF @default = 1
	BEGIN
		UPDATE contract_report_template
		SET [default] = 0
		WHERE template_type = @template_type AND template_category = @template_category
	END

    UPDATE contract_report_template
    SET    template_name = @template_name,
           template_desc = @template_description,
           sub_id = @sub_id,
           [filename] = @filename,
           template_type = @template_type,
		   [default] = @default,
		   document_type = @document_type,
		   xml_map_filename = @xml_map_filename,
		   template_category = @template_category,
		   excel_sheet_id = @excel_sheet_id
    WHERE  template_id = @template_id
    
	IF EXISTS(SELECT * FROM contract_report_template_views crtv INNER JOIN #data_source d ON d.template_id = crtv.template_id)
	BEGIN
		--UPDATE crtv
		--SET crtv.data_source_id = d.data_source_id
		--OUTPUT Inserted.contract_report_template_views_id
		--INTO #contract_report_views_id
		--FROM contract_report_template_views crtv
		--INNER JOIN #data_source d ON d.template_id = crtv.template_id
		DELETE crtv FROM  contract_report_template_views crtv
		INNER JOIN #data_source d ON d.template_id = crtv.template_id
	END
		INSERT INTO contract_report_template_views(template_id,data_source_id)
		OUTPUT inserted.contract_report_template_views_id
			INTO #contract_report_views_id
		SELECT DISTINCT template_id,data_source_id FROM #data_source where data_source_id <> 0
	
		
	IF EXISTS(SELECT 1 FROM template_view_mapping) 
	BEGIN
		DELETE tvm FROM template_view_mapping tvm 
			INNER JOIN #contract_report_views_id cid ON cid.ID = tvm.contract_template_views_id
	END
	 
	 INSERT INTO template_view_mapping (
				contract_template_views_id
				,columns_id
				,tag_name
				)
			SELECT id.ID AS contract_template_views_id
				,data_source_column_id
				,mapping_column
			FROM #contract_report_views_id id
			INNER JOIN contract_report_template_views crtv ON crtv.contract_report_template_views_id = id.ID
			INNER JOIN #mapping_table_detail mtd ON mtd.data_source_id = crtv.data_source_id

   
   IF @@Error <> 0
        EXEC spa_ErrorHandler @@Error,
             'SetupContractReportTemplate',
             'spa_contract_report_template',
             'DB Error',
             'Data Update Failed.',
             ''
    ELSE
        EXEC spa_ErrorHandler 0,
             'Setup Custom Report Template',
             'spa_contract_report_template',
             'Success',
             'Changes have been saved successfully.',
             ''
END
ELSE 
IF @flag = 'd'
BEGIN
	IF EXISTS(
		SELECT 1 
		FROM contract_report_template crt
		INNER JOIN dbo.FNASplit(@del_template_id, ',') a ON a.item = crt.template_id
			AND crt.template_category IN (42022, 42023, 42024)
	)
    BEGIN
    	EXEC spa_ErrorHandler -1,
             'SetupContractReportTemplate',
             'spa_contract_report_template',
             'DB Error',
             'Collection Template cannot be deleted.',
             ''
        RETURN
    END
    
    IF EXISTS(
		SELECT 1 
		FROM contract_report_template crt 
		INNER JOIN dbo.FNASplit(@del_template_id, ',') b ON b.item = crt.template_id AND crt.[default] = 1
	)
    BEGIN
    	EXEC spa_ErrorHandler -1,
             'SetupContractReportTemplate',
             'spa_contract_report_template',
             'DB Error',
             'Template cannot be deleted. Change default template first.',
             ''
        RETURN
    END
	
	DELETE tvm
	FROM template_view_mapping tvm
	INNER JOIN contract_report_template_views crtv ON tvm.contract_template_views_id = crtv.contract_report_template_views_id
	INNER JOIN dbo.FNASplit(@del_template_id, ',') c ON c.item = crtv.template_id

	DELETE crtv
	FROM contract_report_template_views crtv
	INNER JOIN dbo.FNASplit(@del_template_id, ',') d ON d.item = crtv.template_id

    DELETE crt
    FROM contract_report_template crt
    INNER JOIN dbo.FNASplit(@del_template_id, ',') e ON e.item = crt.template_id
    
    IF @@ERROR <> 0
        EXEC spa_ErrorHandler @@ERROR,
			'Setup Custom Report Template',
			'spa_contract_report_template',
			'DB Error',
			'Data Delete Failed.',
			''
    ELSE
        EXEC spa_ErrorHandler 0,
			'Setup Custom Report Template',
			'spa_contract_report_template',
			'Success',
			'Changes have been saved successfully.',
			@del_template_id
END
IF @flag = 'x'
BEGIN


SELECT DISTINCT [template_id]
, STUFF((SELECT ',' + CAST(A.data_source_id AS VARCHAR(10)) FROM contract_report_template_views A
Where A.[template_id]=B.[template_id] FOR XML PATH('')),1,1,'') As data_list
INTO #contract_views From contract_report_template_views B
Group By [template_id], [data_source_id]

SELECT crt.template_id AS [Template ID],
			sdv.code + ISNULL(' - ' + sdv1.code, '') AS [Template Type],
           crt.template_name AS [Template Name],
			crt.template_type AS [Template_Type_Id],
           crt.[filename] AS [Filename],
           CASE WHEN crt.[default] = 1 THEN 'Yes' ELSE 'No' END AS [default_template],
		   crt.document_type AS [document_type],
		   crt.xml_map_filename AS [xml_map_filename],
		   crt.template_category AS [template_category],
		   cv.data_list,
		   crt.excel_sheet_id 
    FROM   contract_report_template crt
    INNER JOIN static_data_value sdv 
		ON sdv.value_id = crt.template_type
	LEFT JOIN static_data_value sdv1 ON sdv1.value_id = crt.template_category
	LEFT JOIN #contract_views cv ON cv.template_id = crt.template_id
	ORDER BY [Template Type], [Template Name]
	
END

IF @flag = 'y'
BEGIN
	SELECT sdv.value_id [value_id], sdv.code [code]
	FROM static_data_value sdv WHERE sdv.[type_id] = 25
	--AND sdv.value_id NOT IN (4301,4305,4306)
END
IF @flag = 'g'
BEGIN
	DECLARE @value_id INT
	SELECT @value_id = value_id FROM static_data_value WHERE code = 'Hedge Documentation' AND type_id = 25 
	SELECT ISNULL(filename, template_name) filename
		, template_name
    FROM   contract_report_template crt
    INNER JOIN static_data_value sdv 
		ON sdv.value_id = crt.template_type
	WHERE 1 = 1 AND value_id = @value_id
END

IF @flag = 't'
/** Retrieve template filename for trade ticket*/
BEGIN
	IF EXISTS (
		SELECT 1
			FROM contract_report_template crt
			WHERE crt.template_id = @template_id AND crt.template_type = 33 AND crt.template_category = @template_type 
	)
	BEGIN
		SELECT template_name, [filename]
		FROM contract_report_template crt
		WHERE crt.template_id = @template_id AND crt.template_type = 33 AND crt.template_category = @template_type 
	END
	ELSE
	BEGIN
		SELECT crt.template_name, crt.[filename], crt.document_type
		FROM contract_report_template crt
		WHERE crt.template_type = 33 AND crt.template_category = @template_type AND crt.[default] = 1 AND crt.document_type IN ( 'r', 'e') 
	END
END
IF @flag = 'z'
BEGIN 

	SELECT tvm.id,ds1.name,dsc.name data_source_column,ISNULL(tag_name,dsc.name) mapping_column,data_source_column_id,ds.data_source_id FROM #data_source ds 
	INNER JOIN data_source ds1 ON ds1.data_source_id = ds.data_source_id
	LEFT JOIN contract_report_template_views crtv On crtv.data_source_id = ds.data_source_id AND ds.template_id = crtv.template_id
	LEFT JOIN data_source_column dsc ON   ds.data_source_id = dsc.source_id
	LEFT JOIN  template_view_mapping tvm ON tvm.contract_template_views_id = crtv.contract_report_template_views_id AND dsc.data_source_column_id = tvm.columns_id
END 


IF @flag = 'f'
BEGIN 
	SELECT --es.excel_file_id [excel_sheet_id]
		  es.excel_sheet_id
		, es.sheet_name
	FROM excel_file ef
	INNER JOIN excel_sheet es ON ef.excel_file_id = es.excel_file_id
		AND es.snapshot = 1
		AND es.document_type = 106701
	WHERE es.excel_sheet_id = @excel_sheet_id
END 


IF @flag = 'b' 
BEGIN
	SELECT es.excel_sheet_id [excel_file_id]
		, ef.[file_name]
	FROM excel_file ef
	INNER JOIN excel_sheet es ON ef.excel_file_id = es.excel_file_id
		AND es.snapshot = 1
		AND es.document_type = 106701
END
 
GO