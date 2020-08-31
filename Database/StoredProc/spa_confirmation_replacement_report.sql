IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_confirmation_replacement_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_confirmation_replacement_report]
GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_confirmation_replacement_report] 
	@source_deal_header_id VARCHAR(MAX)

AS
SET NOCOUNT ON

--DECLARE @source_deal_header_id VARCHAR(MAX) = '1842, 1843, 1849'

--SELECT DISTINCT(scsv.item) [source_deal_header_id], 
--	   --scs.status, scs.confirm_id ,
--	   CASE WHEN scs.status <> '' THEN 'r' ELSE 'c'  END flag
--FROM save_confirm_status scs 
--RIGHT JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv
--ON scsv.item = scs.source_deal_header_id


SELECT *
FROM
(
SELECT 
	sdh.source_deal_header_id [source_deal_header_id],
	CASE WHEN scs.status = 'v' THEN 'r' ELSE 'c'  END flag, 
	CASE 
		WHEN crt.[filename] IS NULL
		THEN
			(SELECT crt2.[filename] FROM Contract_report_template crt2 
			 WHERE crt2.template_category = CASE WHEN scs.status = 'v' THEN 42021 ELSE 42018 END 
				AND crt2.[default] = 1 AND crt2.template_type = 33 AND crt2.document_type = 'r')
		ELSE
			REPLACE(crt.[filename], '.rdl', '')		
	END	[template_filename],
	ROW_NUMBER() OVER (PARTITION BY scsv.item ORDER BY CASE WHEN scs.status = 'v' THEN '1' ELSE '2'  END) rnk	
FROM source_deal_header sdh
INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv ON scsv.item = sdh.source_deal_header_id
LEFT JOIN deal_confirmation_rule dcr_1 ON dcr_1.counterparty_id = sdh.counterparty_id 
     AND ISNULL(dcr_1.commodity_id, 0) = ISNULL(sdh.commodity_id, 0)        
     AND ISNULL(dcr_1.contract_id, 0) = ISNULL(sdh.contract_id, 0)    
     AND ISNULL(dcr_1.deal_type_id, 0) = ISNULL(sdh.source_deal_type_id, 0)
	 AND ISNULL(dcr_1.deal_template_id, 0) = ISNULL(sdh.template_id, 0)
     AND ISNULL(dcr_1.buy_sell_flag, 'b') = ISNULL(sdh.header_buy_sell_flag, 'b') 

LEFT JOIN deal_confirmation_rule dcr_2 ON dcr_2.counterparty_id = sdh.counterparty_id 
     AND ISNULL(dcr_2.commodity_id, 0) = ISNULL(sdh.commodity_id, 0)        
     AND ISNULL(dcr_2.contract_id, 0) = ISNULL(sdh.contract_id, 0)    
     AND ISNULL(dcr_2.deal_type_id, 0) = ISNULL(sdh.source_deal_type_id, 0)
	 AND ISNULL(dcr_2.deal_template_id, 0) = ISNULL(sdh.template_id, 0)

LEFT JOIN deal_confirmation_rule dcr_3 ON dcr_3.counterparty_id = sdh.counterparty_id 
     AND ISNULL(dcr_3.commodity_id, 0) = ISNULL(sdh.commodity_id, 0)        
     AND ISNULL(dcr_3.contract_id, 0) = ISNULL(sdh.contract_id, 0)    
     AND ISNULL(dcr_3.deal_type_id, 0) = ISNULL(sdh.source_deal_type_id, 0)

LEFT JOIN deal_confirmation_rule dcr_4 ON dcr_4.counterparty_id = sdh.counterparty_id 
     AND ISNULL(dcr_4.commodity_id, 0) = ISNULL(sdh.commodity_id, 0)        
     AND ISNULL(dcr_4.contract_id, 0) = ISNULL(sdh.contract_id, 0) 

LEFT JOIN deal_confirmation_rule dcr_5 ON dcr_5.counterparty_id = sdh.counterparty_id 
     AND ISNULL(dcr_5.commodity_id, 0) = ISNULL(sdh.commodity_id, 0)        

LEFT JOIN deal_confirmation_rule dcr_6 ON dcr_6.counterparty_id = sdh.counterparty_id
LEFT JOIN save_confirm_status scs ON sdh.source_deal_header_id = scs.source_deal_header_id
LEFT JOIN contract_report_template crt 
	ON crt.template_id = CASE WHEN scs.status <> '' 
	THEN 
		COALESCE(dcr_1.revision_confirm_template_id, dcr_2.revision_confirm_template_id, dcr_3.revision_confirm_template_id, dcr_4.revision_confirm_template_id, dcr_5.revision_confirm_template_id, dcr_6.revision_confirm_template_id) 
	ELSE 
		COALESCE(dcr_1.confirm_template_id, dcr_2.confirm_template_id, dcr_3.confirm_template_id, dcr_4.confirm_template_id, dcr_5.confirm_template_id, dcr_6.confirm_template_id)
	END
) cte 
WHERE rnk = 1