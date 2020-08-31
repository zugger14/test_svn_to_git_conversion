IF OBJECT_ID ('WF_Counterparty', 'V') IS NOT NULL
	DROP VIEW WF_Counterparty;
GO

-- ===============================================================================================================
-- Author: ryadav@pioneersolutionsglobal.com
-- Create date: 2018-08-15
-- Modified Date: 2019-01-18
-- Description: created view for contract and audit information
-- ===============================================================================================================

CREATE VIEW [dbo].[WF_Counterparty]

AS
WITH cte AS (
		SELECT sc.*, ROW_NUMBER() OVER (PARTITION BY sc.source_counterparty_id ORDER BY sc.audit_id DESC) row_no
		FROM source_counterparty_audit sc
		LEFT JOIN counterparty_bank_info_audit cbia ON sc.source_counterparty_id = cbia.counterparty_id
	), cte_previous AS (
		SELECT * FROM cte WHERE row_no = 2
	), sc_compare AS (
		SELECT 
			  sc.source_counterparty_id
			, sc.counterparty_id
			, sc.counterparty_name
			, sc.counterparty_desc
			, sc.int_ext_flag
			, sc.netting_parent_counterparty_id
			, sc.create_user
			, sc.create_ts
			, sc.update_user
			, sc.update_ts
			, sc.parent_counterparty_id
			, sc.customer_duns_number
			, sc.is_active
			, sc.counterparty_status
			, sc.analyst
			, scc.is_active [previous_is_active]
			--, scc.counterparty_status [previous_counterparty_status]
			, cbi.bank_name
			, cbi.wire_ABA
			, cbi.ACH_ABA
			, cbi.Account_no
			, cbi.Address1
			, cbi.Address2
			, cbi.accountname
			, cbi.reference
			, cbi.currency
			, cbi.primary_account
		FROM source_counterparty sc
		LEFT JOIN counterparty_bank_info cbi ON sc.source_counterparty_id = cbi.counterparty_id
		LEFT JOIN cte_previous scc  ON  scc.source_counterparty_id = sc.source_counterparty_id
	)

	SELECT * FROM sc_compare

