IF OBJECT_ID(N'dbo.[vwCreditExposureLimitVarienceDetail]', N'V') IS NOT NULL
	DROP VIEW dbo.[vwCreditExposureLimitVarienceDetail]
GO 
-- ===============================================================================================================
-- Author: pamatya@pioneersolutionsglobal.com
-- Create date: 2014-01-02
-- Modified date: 2014-01-07
-- Description: Creats view for the Deal capture Trade Value validation alert
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - 
-- ===============================================================================================================

CREATE VIEW dbo.[vwCreditExposureLimitVarienceDetail]
AS
	SELECT 
		MAX(ced.Source_Counterparty_ID) [Id],
		MAX(ced.counterparty_name) [counterparty_name],
		MAX(ced.parent_counterparty_name) [parent_counterparty_us],
		ROUND(SUM(ISNULL(net_exposure_to_us,0)), 2) [net_exposure_to_us],
		ROUND(MAX(limit_to_us_avail), 2) [limit_to_us_avail],
		ROUND(MAX(total_limit_provided), 2) [total_limit_provided],
		ROUND(SUM(ced.limit_to_us_variance), 2) [limit_variance],
		MAX(ced.as_of_date) [as_of_date],
		MAX((net_exposure_to_us/NULLIF(limit_to_us_avail,0))*100) [exposure_percent]
	FROM credit_exposure_detail ced
	GROUP BY ced.Source_Counterparty_ID	
GO





