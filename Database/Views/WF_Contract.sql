IF OBJECT_ID ('WF_Contract', 'V') IS NOT NULL
	DROP VIEW WF_Contract;
GO

-- ===============================================================================================================
-- Author: ryadav@pioneersolutionsglobal.com
-- Create date: 2018-08-15
-- Modified Date: 2019-01-18
-- Description: created view for counterparty and audit information
-- ===============================================================================================================

CREATE VIEW [dbo].[WF_Contract]

AS
WITH cte AS (
		SELECT cg.*, ROW_NUMBER() OVER (PARTITION BY cg.contract_id ORDER BY cg.audit_id DESC) row_no
		FROM contract_group_audit cg
	), cte_previous AS (
		SELECT * FROM cte WHERE row_no = 2
	), cg_compare AS (
		SELECT
			  cg.contract_id
			, cg.sub_id
			, cg.[contract_name]
			, cg.contract_date
			, cg.settlement_accountant
			, cg.[type]
			, cg.term_start
			, cg.term_end
			, cg.source_contract_id
			, cg.contract_desc
			, cg.create_user
			, cg.create_ts
			, cg.update_user
			, cg.update_ts
			, cg.time_zone
			, cg.contract_charge_type_id
			, cg.contract_status
			, cg.is_active
			, cg.transportation_contract
			, cg.pipeline
			, cg.flow_start_date
			, cg.flow_end_date
			, cg.[path]
			, cg.is_lock
			, cg.commodity
			, cg.storage_asset_id
			, cgc.contract_status [previous_contract_status]
			--, cgc.is_lock [previous_is_lock]
			, cgc.is_active [previous_is_active]
		FROM contract_group cg
		LEFT JOIN cte_previous cgc  ON cgc.contract_id = cg.contract_id 
	)

	SELECT * FROM cg_compare

