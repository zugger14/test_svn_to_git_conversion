IF OBJECT_ID ('[WF_Counterpartycreditenhancements]', 'V') IS NOT NULL
	DROP VIEW [WF_Counterpartycreditenhancements];
GO

-- ===============================================================================================================
-- Author: ryadav@pioneersolutionsglobal.com
-- Create date: 2019-04-16
-- Modified Date: 2019-04-16
-- Description: created view for incident log
-- ===============================================================================================================

CREATE VIEW [dbo].[WF_Counterpartycreditenhancements]

AS
SELECT counterparty_credit_enhancement_id --Primary Column
	, amount
	, approved_by
	, collateral_status
	, comment
	, contract_id
	, counterparty_credit_info_id
	, currency_code
	, eff_date
	, enhance_type
	, exclude_collateral
	, expiration_date
	, guarantee_counterparty
	, internal_counterparty
	, margin
	, rely_self
FROM counterparty_credit_enhancements
