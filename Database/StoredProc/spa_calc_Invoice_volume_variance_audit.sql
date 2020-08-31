IF OBJECT_ID(N'[dbo].[spa_calc_Invoice_volume_variance_audit]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_calc_Invoice_volume_variance_audit]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: bbishural@pioneersolutionsglobal.com
-- Create date: 2014-05-24
-- Description: CRUD operations for table calc_invoice_volume_variance_report
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @calc_id - Returns the calc_id
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_calc_Invoice_volume_variance_audit]
    @flag CHAR(1),
    @calc_Id VARCHAR(MAX)
AS
 
DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 's'
BEGIN
    SELECT  calc_id [Calc ID], 
			dbo.FNADateFormat(as_of_date) [As of Date],
			sc.[counterparty_id] [Counterparty ID],
			cg.[contract_name] [Contract Name],
			dbo.FNADateFormat(prod_date) [Delivery Date],
			su.uom_id [UOM],
			finalized [Finalized],
			invoice_number [Invoice Number],
			comment1 [Comment1],
			comment2 [Comment2],
			comment3 [Comment3],
			comment4 [Comment4],
			comment5 [Comment5],
			sdv.code [Invoice Status],
			invoice_lock [Invoice Lock],
			invoice_note [Invoice Note],
			CASE invoice_type WHEN 'i' THEN 'Invoice' ELSE 'Remittance' END [Invoice Type],
			dbo.FNADateFormat(prod_date_to) [Delivery Date To],
			dbo.FNADateFormat(civva.settlement_date) [Settlement Date],
			civva.create_user [Create User], 
			dbo.FNADateTimeFormat(civva.create_ts, 1) [Create TS],
			civva.update_user [Update User],
			dbo.FNADateTimeFormat(civva.update_ts, 1) [Update TS]
    FROM   calc_invoice_volume_variance_audit civva
    LEFT JOIN contract_group cg ON cg.contract_id = civva.contract_id
    LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = civva.counterparty_id
    LEFT JOIN source_uom su ON su.source_uom_id = civva.uom
    LEFT JOIN static_data_value sdv ON sdv.value_id = civva.invoice_status AND sdv.[type_id] = 20700 
    WHERE calc_id IN (SELECT scsv.item FROM dbo.SplitCommaSeperatedValues(@calc_Id) scsv)
    ORDER BY civva.calc_id 
END