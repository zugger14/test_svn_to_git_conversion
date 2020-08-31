IF OBJECT_ID(N'dbo.[WF_Creditexposure]', N'V') IS NOT NULL
	DROP VIEW dbo.[WF_Creditexposure]
GO 
-- ===============================================================================================================
-- Author: pamatya@pioneersolutionsglobal.com
-- Create date: 2014-01-02
-- Modified Date: 2019-01-18
-- Description: Creats view for the Deal capture Trade Value validation alert
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - 
-- ===============================================================================================================

CREATE VIEW dbo.[WF_Creditexposure]
As
	       
	SELECT	ISNULL(cca.internal_counterparty_id, ced.internal_counterparty_id) as [internal_counterparty_id],
			ced.contract_id,
			ced.Source_Counterparty_ID [counterparty_id],
			MAX(ced.counterparty_name) AS counterparty_name,
			MAX(ced.parent_counterparty_name) AS parent_counterparty_us,
            ROUND(SUM(ISNULL(ced.net_exposure_to_us, 0)), 2) AS net_exposure_to_us, 
			ROUND(MAX(ced.limit_to_us_avail), 2) AS limit_to_us_avail, 
			ROUND(MAX(ced.total_limit_provided), 2) AS total_limit_provided, 
            ROUND(MAX(ced.total_limit_provided) - SUM(ISNULL(ced.net_exposure_to_us, 0)), 2) AS limit_variance, 
			ced.as_of_date AS as_of_date,
			ROUND(ABS(MAX(ced.total_limit_provided) - SUM(ISNULL(ced.net_exposure_to_us, 0))) / MAX(ISNULL(NULLIF (ced.total_limit_provided, 0), 1)) * 100, 2) AS exposure_percent,
			SUM(ced.net_exposure_to_them) AS net_exposure_to_them, 
            SUM(ced.cash_collateral_provided) AS cash_collateral_provided, 
			SUM(ced.cash_collateral_received) AS cash_collateral_received,
			SUM(ced.effective_exposure_to_us) AS effective_Exposure_to_us, 
            SUM(ced.effective_exposure_to_them) AS effective_exposure_to_them,
			SUM(ced.collateral_received) AS collateral_received,
			SUM(ced.collateral_provided) AS collateral_provided,
			SUM(ced.limit_received) AS limit_received, 
			SUM(ced.limit_provided) AS limit_provided, 
			MAX(cca.margin_provision) AS margin_provision, 
			CASE WHEN MAX(cca.margin_provision) IS NOT NULL AND ROUND(SUM(ISNULL(ced.net_exposure_to_us, 0)), 2) >			ISNULL(MAX(cca.threshold_provided),0) AND (ROUND(SUM(ISNULL(ced.net_exposure_to_us, 0)), 2) -		ISNULL(MAX(cca.threshold_provided),0)) >= ISNULL(MAX(cca.min_transfer_amount),0) THEN 1 ELSE 0 END AS Is_Margin_call,
			MAX(cca.threshold_provided) [threshold_provided],
			MAX(cca.threshold_received) [threshold_received],
			MAX(cca.min_transfer_amount) [min_transfer_amount]
	FROM  dbo.credit_exposure_detail AS ced 
			LEFT OUTER JOIN dbo.counterparty_contract_address AS cca ON cca.counterparty_id = ced.Source_Counterparty_ID AND ISNULL(cca.internal_counterparty_id, ced.internal_counterparty_id) = ced.internal_counterparty_id AND cca.contract_id = ced.contract_id
GROUP BY ced.Source_Counterparty_ID, ISNULL(cca.internal_counterparty_id, ced.internal_counterparty_id), ced.contract_id, ced.as_of_date
GO

