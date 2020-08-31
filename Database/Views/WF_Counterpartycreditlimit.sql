IF OBJECT_ID ('WF_Counterpartycreditlimit', 'V') IS NOT NULL
	DROP VIEW WF_Counterpartycreditlimit;
GO

-- ===============================================================================================================
-- Author: sbohara@pioneersolutionsglobal.com
-- Create date: 2016-01-11
-- Modified Date: 2019-01-18
-- Description: View of counterparty credit info audit
-- ===============================================================================================================

CREATE VIEW WF_Counterpartycreditlimit
AS 
WITH CTE AS (	
	SELECT ccla.*, ROW_NUMBER() OVER (PARTITION By counterparty_credit_limit_id ORDER BY ccla.audit_id DESC) row_no 
	FROM counterparty_credit_limits_audit ccla
), ccla_previous AS (
	SELECT * FROM cte where cte.row_no = 2
), ccla_compare AS (
	SELECT
		cci.Counterparty_id [counterparty_id],
		cci.counterparty_credit_limit_id [counterparty_credit_limit_id],  
		CASE WHEN COALESCE(cci.credit_limit, 0) = COALESCE(ccla.credit_limit, 0) THEN 1 ELSE 0 END [credit_limit_compare],
		CASE WHEN COALESCE(cci.credit_limit_to_us, 0) = COALESCE(ccla.credit_limit_to_us, 0) THEN 1 ELSE 0 END [credit_limit_to_us_compare],
		ccla.credit_limit [previous_credit_limit],
		ccla.credit_limit_to_us [previous_credit_limit_to_us],
		cci.effective_Date,
		cci.credit_limit,
		cci.credit_limit_to_us,
		cci.tenor_limit,
		cci.max_threshold,
		cci.min_threshold,
		cci.internal_counterparty_id,
		cci.contract_id,
		cci.currency_id,
		cci.threshold_provided,
		cci.threshold_received,
		cci.limit_status
	FROM counterparty_credit_limits cci 
	LEFT JOIN ccla_previous ccla ON  cci.counterparty_credit_limit_id = ccla.counterparty_credit_limit_id
)

SELECT * FROM ccla_compare 