IF OBJECT_ID ('[WF_Counterpartycontracttype]', 'V') IS NOT NULL
	DROP VIEW [WF_Counterpartycontracttype];
GO

-- ===============================================================================================================
-- Author: anuj@pioneersolutionsglobal.com
-- Create date: 2020-06-26
-- Modified Date: 2020-06-26
-- Description: created view for Contract Amendment 
-- ===============================================================================================================

CREATE VIEW [dbo].[WF_Counterpartycontracttype]

AS
SELECT
	counterparty_contract_type_id -- primary column
	,counterparty_contract_address_id
	,counterparty_id
	,contract_id
	,counterparty_contract_type
	,application_notes_id
	,description
	,ammendment_date
	,number
	,contract_status
FROM counterparty_contract_type
