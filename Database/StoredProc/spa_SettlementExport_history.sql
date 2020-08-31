/****** Object:  StoredProcedure [dbo].spa_SettlementExport_history    Script Date: 10/09/2015  ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_SettlementExport_history]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_SettlementExport_history]
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].spa_SettlementExport_history
	@flag CHAR = NULL  
	, @counterparty_id NVARCHAR(1000)  = NULL	
	, @contract_id VARCHAR(250) = NULL
	, @as_of_date DATETIME = NULL
	, @invoice_date DATETIME = NULL
	
	
AS 
/*
DECLARE @flag VARCHAR(250) = 'a'
DECLARE @contract_id VARCHAR(250) = NULL
DECLARE @counterparty_id VARCHAR(250) = NULL 
DECLARE @invoice_date DATETIME = '2015-02-02'
DECLARE @as_of_date DATETIME = '2015-01-31'
--*/
/*
DECLARE @flag VARCHAR(250) = 'a'
DECLARE @contract_id VARCHAR(250) = NULL
DECLARE @counterparty_id VARCHAR(250) = NULL 
DECLARE @invoice_date DATETIME = '2015-02-02'
DECLARE @as_of_date DATETIME = '2015-01-31'
--*/
SET NOCOUNT ON;
IF object_id('tempdb..#counterparty') IS NOT NULL
	DROP TABLE #counterparty
IF object_id('tempdb..#contract') IS NOT NULL
	DROP TABLE #contract
CREATE TABLE #counterparty(item INT)
CREATE TABLE #contract(item INT)	
IF NULLIF(@counterparty_id,'') is NOT NULL
BEGIN
	INSERT INTO #counterparty(item)
	SELECT item
	FROM dbo.SplitCommaSeperatedValues(@counterparty_id)
END
ELSE
BEGIN
	INSERT INTO #counterparty(item)
	Select source_counterparty_id FROM source_counterparty
END
IF NULLIF(@contract_id,'') IS NOT NULL 
BEGIN 
	INSERT INTO #contract(item)
	SELECT item
	FROM dbo.SplitCommaSeperatedValues(@contract_id)
END
ELSE
BEGIN 
	INSERT INTO #contract(item)
	Select contract_id FROM contract_group
END	

IF @flag= 's'
BEGIN
	SELECT document_header,comp_code,doc_type,doc_date,fisc_year,pstng_date,currency,header_txt,ref_doc_no,reason_rev, extension_field,text,quantity,base_unit_of_measure,settlement_period,''process_id,create_user,create_ts
		FROM settlement_export  s  INNER JOIN #counterparty c on c.item = s.counterparty_id 
		INNER JOIN #contract c1 ON c1.item = s.contract_id
		WHERE  TYPE= 'E' AND (  as_of_date = @as_of_date AND  invoice_date = @invoice_date)
		ORDER BY create_ts,row_type,Distinct_value
END
ELSE IF @flag= 'a'
BEGIN
	SELECT document_header,comp_code,doc_type,doc_date,fisc_year,pstng_date,currency,header_txt,ref_doc_no,reason_rev, extension_field,text,quantity,base_unit_of_measure,settlement_period,''process_id,create_user,create_ts,Distinct_value,row_type
	FROM settlement_export s
	INNER JOIN #counterparty c on c.item = s.counterparty_id 
		INNER JOIN #contract c1 ON c1.item = s.contract_id
	WHERE TYPE= 'f' AND (as_of_date = @as_of_date AND  invoice_date = @invoice_date)
	ORDER BY create_ts,row_type,Distinct_value
END
IF @flag= 'm'
BEGIN
	SELECT document_header,comp_code,doc_type,doc_date,fisc_year,pstng_date,currency,header_txt,ref_doc_no,reason_rev, extension_field,text,quantity,base_unit_of_measure,settlement_period FROM settlement_export WHERE document_header = 'I' AND TYPE= 'E' AND (counterparty_id = @counterparty_id AND  contract_id = @contract_id AND  as_of_date = @as_of_date AND  invoice_date = @invoice_date)
END
ELSE IF @flag= 'n'
BEGIN
	SELECT document_header,comp_code,doc_type,doc_date,fisc_year,pstng_date,currency,header_txt,ref_doc_no,reason_rev, extension_field,text,quantity,base_unit_of_measure,settlement_period FROM settlement_export WHERE document_header = 'I' AND TYPE= 'f' AND (counterparty_id = @counterparty_id AND  contract_id = @contract_id AND  as_of_date = @as_of_date AND  invoice_date = @invoice_date)
END

