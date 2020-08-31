IF OBJECT_ID ('WF_Counterpartycreditinfo', 'V') IS NOT NULL
	DROP VIEW WF_Counterpartycreditinfo;
GO

-- ===============================================================================================================
-- Author: pamatya@pioneersolutionsglobal.com
-- Create date: 2014-01-02
-- Modified Date: 2019-01-18
-- Description: creates view for counterparty credit info audit from audit table
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - 
-- ===============================================================================================================
CREATE VIEW WF_Counterpartycreditinfo
AS 
WITH CTE AS (	
	SELECT ccia.*, ROW_NUMBER() OVER (PARTITION By counterparty_id ORDER BY ccia.audit_id DESC) row_no 
	FROM counterparty_credit_info_audit ccia
), ccia_previous AS (
	SELECT * FROM cte where cte.row_no = 2
), ccia_compare AS (
	SELECT
		cci.Counterparty_id [counterparty_id], 
		CASE WHEN COALESCE(cci.credit_limit, 0) = COALESCE(ccia.credit_limit, 0) THEN 1 ELSE 0 END [credit_limit_compare],
		CASE WHEN COALESCE(cci.Debt_rating, 0) = COALESCE(ccia.Debt_rating, 0) THEN 1 ELSE 0 END [debt_rating_compare],
		CASE WHEN COALESCE(cci.Debt_Rating2, 0) = COALESCE(ccia.Debt_Rating2, 0) THEN 1 ELSE 0 END [debt_rating2_compare],
		CASE WHEN COALESCE(cci.Debt_Rating3, 0) = COALESCE(ccia.Debt_Rating3, 0) THEN 1 ELSE 0 END [debt_rating3_compare],
		CASE WHEN COALESCE(cci.Debt_Rating4, 0) = COALESCE(ccia.Debt_Rating4, 0) THEN 1 ELSE 0 END [debt_rating4_compare],
		CASE WHEN COALESCE(cci.Debt_Rating5, 0) = COALESCE(ccia.Debt_Rating5, 0) THEN 1 ELSE 0 END [debt_rating5_compare],
		CASE WHEN COALESCE(cci.account_status, 0) =  COALESCE(ccia.account_status, 0) THEN 1 ELSE 0 END [account_status_compare],
		CASE WHEN COALESCE(cci.Risk_rating, 0) = COALESCE(ccia.Risk_rating, 0) THEN 1 ELSE 0 END [risk_rating_compare],
		ccia.credit_limit [previous_credit_limit],
		ccia.Debt_rating [previous_Debt_rating],
		ccia.Debt_Rating2 [previous_Debt_Rating2],
		ccia.Debt_Rating3 [previous_Debt_Rating3],
		ccia.Debt_Rating4 [previous_Debt_Rating4],
		ccia.Debt_Rating5 [previous_Debt_Rating5],
		ccia.account_status [previous_account_status],	
		ccia.Risk_rating [previous_risk_rating],
		cci.counterparty_credit_info_id,
		cci.account_status,
		cci.risk_rating,
		cci.Debt_rating,
		cci.Debt_Rating2,
		cci.Debt_Rating3,
		cci.Debt_Rating4,
		cci.Debt_Rating5,
		ISNULL(cci.Watch_list, 'n') Watch_list
	FROM counterparty_credit_info cci
    LEFT JOIN ccia_previous ccia  ON  cci.counterparty_credit_info_id = ccia.counterparty_credit_info_id
)

SELECT * FROM ccia_compare 