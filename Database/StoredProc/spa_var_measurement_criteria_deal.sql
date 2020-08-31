IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_var_measurement_criteria_deal]')AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_var_measurement_criteria_deal]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_var_measurement_criteria_deal]
	@flag CHAR(1),
	@var_measurement_deal_id VARCHAR(5000) = NULL,
	@var_criteria_id INT = NULL,
	@deal_id VARCHAR(5000) = NULL
AS
DECLARE @sql VARCHAR(MAX)
--START :: Var Measurement Criteria Deal Select
IF @flag = 's'
BEGIN
		SELECT vmd.var_measurement_deal_id AS [ID],
		       vmd.var_criteria_id AS [Var Measurement Deal ID],
		       dbo.FNAHyperLinkText(10131010, vmd.deal_id, vmd.deal_id) AS 
		       [Deal ID],
		       sdh.deal_id AS [Ref ID],
		       dbo.FNADateFormat(sdh.deal_date) AS [Deal Date],
		       CASE WHEN sdh.physical_financial_flag = 'p' THEN 'Physical' ELSE 'Financial'END [Physical/Financial],
		       sc.counterparty_name AS [Counterparty Name],
		       dbo.FNADateFormat(sdh.entire_term_start) AS [Term Start],
		       dbo.FNADateFormat(sdh.entire_term_end) AS [Term End]
		FROM   var_measurement_deal vmd
		       LEFT JOIN source_deal_header sdh ON  sdh.source_deal_header_id = vmd.deal_id
		       LEFT JOIN source_counterparty sc ON  sdh.counterparty_id = sc.source_counterparty_id
		WHERE  vmd.var_criteria_id = @var_criteria_id 
END
--END :: Var Measurement Criteria Deal Select
IF @flag = 'x'
BEGIN
		
SELECT sdh.deal_id [Ref ID],
			    vmd.deal_id AS [Deal ID],
			    dbo.FNADateFormat(sdh.deal_date) [Deal Date],
			   dbo.FNADateFormat(sdh.entire_term_start) AS [Term Start],
			    dbo.FNADateFormat(sdh.entire_term_end) AS [Term End],
			    sml.Location_Name [Index],
			    sdht.template_name [Template],
			    sc2.currency_name [Currency],
			    sdt.source_deal_type_name [Deal Type],
			    sdd.deal_volume [Deal Volume],
			    su.uom_name [deal_volume_uom_id]
		FROM   var_measurement_deal vmd
		       LEFT JOIN source_deal_header sdh ON  sdh.source_deal_header_id = vmd.deal_id
		       OUTER APPLY(SELECT MAX(sdd.fixed_price_currency_id) fixed_price_currency_id, MAX(sdd.location_id) location_id, MAX(sdd.deal_volume) deal_volume,
			   MAX(sdd.deal_volume_uom_id) deal_volume_uom_id from source_deal_detail sdd
			    where sdd.source_deal_header_id = sdh.source_deal_header_id group by sdd.source_deal_header_id) sdd
		       LEFT JOIN source_counterparty sc ON  sdh.counterparty_id = sc.source_counterparty_id
		       LEFT JOIN source_minor_location sml ON sdd.location_id = sml.source_minor_location_id
		       LEFT JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
		       LEFT JOIN source_currency sc2 ON sc2.source_currency_id = sdd.fixed_price_currency_id
		       LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
		       LEFT JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
		WHERE  vmd.var_criteria_id = @var_criteria_id 
END
--START :: Var Measurement Criteria Deal Delete
ELSE IF @flag = 'd'
BEGIN
    SET @sql = 'DELETE 
				FROM   var_measurement_deal
				WHERE  var_measurement_deal_id IN ( ' + @var_measurement_deal_id + ' )' 
	EXEC(@sql)
    
    IF @@ERROR <> 0
    BEGIN
        EXEC spa_ErrorHandler @@ERROR,
             "VaR Criteria Measurement Criteria",
             "spa_var_measurement_criteria_deal",
             "DB Error",
             "Deletion  of VaR Criteria Measurement Criteria  failed.",
             ''
        
        RETURN
    END
    ELSE
        EXEC spa_ErrorHandler 0,
             'VaR Criteria Measurement Criteria',
             'spa_var_measurement_criteria_deal',
             'Success',
             'VaR Criteria Measurement  Criteria  successfully deleted.',
             ''
END
--END :: Var Measurement Criteria Deal Delete

--START :: Var Measurement Criteria Deal Insert
ELSE IF @flag = 'i' 
BEGIN
	
	IF OBJECT_ID('tempdb..#selected_deals') IS NOT NULL  
		DROP TABLE #selected_deals  
	
	SELECT @var_criteria_id AS [var_criteria_id],d.item AS [deal_id]
	INTO #selected_deals
	FROM   dbo.SplitCommaSeperatedValues(@deal_id) d
	
	INSERT INTO var_measurement_deal(var_criteria_id,deal_id)
	SELECT * FROM #selected_deals
	WHERE deal_id NOT IN (
		SELECT vmd.deal_id
	    FROM   var_measurement_deal vmd
	    WHERE  vmd.var_criteria_id = @var_criteria_id
	)   
	
		
	IF @@ERROR <> 0
    BEGIN
        EXEC spa_ErrorHandler @@ERROR,
             "VaR Criteria Measurement Criteria",
             "spa_var_measurement_criteria_deal",
             "DB Error",
             "Insertion of Var Measurement Criteria Deal failed.",
             ''
        
        RETURN
    END
    ELSE
        EXEC spa_ErrorHandler 0,
             'VaR Criteria Measurement Criteria',
             'spa_var_measurement_criteria_deal',
             'Success',
             'Var Measurement Criteria Deal successfully inserted.',
             ''
END
-- END :: Var Measurement Criteria Deal Insert