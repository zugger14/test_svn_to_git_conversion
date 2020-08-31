IF OBJECT_ID ('contract_group_audit_view', 'V') IS NOT NULL
	DROP VIEW contract_group_audit_view ;
GO

CREATE VIEW contract_group_audit_view
AS 

WITH cte AS (
	SELECT cga.*, ROW_NUMBER() OVER (PARTITION BY cga.contract_id ORDER BY cga.audit_id DESC) row_no
	FROM contract_group_audit cga
), cte_previous AS (
	SELECT * FROM cte WHERE row_no = 2
)

SELECT * FROM cte_previous