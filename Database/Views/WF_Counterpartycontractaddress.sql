IF OBJECT_ID ('[WF_Counterpartycontractaddress]', 'V') IS NOT NULL
	DROP VIEW [WF_Counterpartycontractaddress];
GO

-- ===============================================================================================================
-- Author: ryadav@pioneersolutionsglobal.com
-- Create date: 2019-04-16
-- Modified Date: 2019-04-16
-- Description: created view for incident log
-- ===============================================================================================================

CREATE VIEW [dbo].[WF_Counterpartycontractaddress]

AS
SELECT
	 counterparty_contract_address_id -- Primary Column
    , analyst
	, comments
	, company_trigger
	, ISNULL(contract_active, 'n') contract_active
	, contract_date
	, contract_end_date
	, contract_id
	, contract_start_date
	, contract_status
	, counterparty_id
	, counterparty_trigger
	, internal_counterparty_id
	, margin_provision
FROM counterparty_contract_address
