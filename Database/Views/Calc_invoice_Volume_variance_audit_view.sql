IF OBJECT_ID(N'dbo.[Calc_invoice_Volume_variance_audit_view]', N'V') IS NOT NULL
	DROP VIEW dbo.[Calc_invoice_Volume_variance_audit_view]
GO 

CREATE VIEW [dbo].[Calc_invoice_Volume_variance_audit_view]
AS 

WITH cte AS (
       SELECT civv.*, ROW_NUMBER() OVER (PARTITION BY civv.calc_id ORDER BY civv.Calc_invoice_Volume_variance_audit_id DESC) row_no
       FROM Calc_invoice_Volume_variance_audit civv
), cte_previous AS (
       SELECT * FROM cte WHERE row_no = 2
)

SELECT * FROM cte_previous

GO