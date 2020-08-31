IF OBJECT_ID(N'dbo.[vwDealContractValue]', N'V') IS NOT NULL
	DROP VIEW dbo.[vwDealContractValue]
GO 
-- ===============================================================================================================
-- Author: pamatya@pioneersolutionsglobal.com
-- Create date: 2014-01-02
-- Modified date: 2014-01-07
-- Description: Creats view for the Deal capture Trade Value validation alert
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - 
-- ===============================================================================================================

CREATE VIEW dbo.[vwDealContractValue]
AS
	SELECT source_deal_header_id, ABS(SUM(contract_value)) AS [sum] FROM source_deal_pnl 
	GROUP BY source_deal_header_id
	
	--SELECT sdh.Source_deal_header_id, SUM(sdd.deal_volume) * SUM(sdd.fixed_price) AS [Sum] FROM source_deal_header sdh 
	--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	
	
GO


