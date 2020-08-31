IF OBJECT_ID(N'dbo.[source_deal_header_audit_view]', N'V') IS NOT NULL
	DROP VIEW dbo.[source_deal_header_audit_view]
GO 

CREATE VIEW [dbo].[source_deal_header_audit_view]
AS 

WITH cte AS (
       SELECT sdh.*, ROW_NUMBER() OVER (PARTITION BY sdh.source_deal_header_id ORDER BY sdh.audit_id DESC) row_no
       FROM source_deal_header_audit sdh
), cte_previous AS (
       SELECT * FROM cte WHERE row_no = 2
)

SELECT * FROM cte_previous

GO