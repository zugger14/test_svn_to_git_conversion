
--Delete duplicate Data
if OBJECT_ID('tempdb..#temp_data') is not null drop table #temp_data
SELECT source_deal_detail_id,curve_id, leg, fin_expiration_date INTO #temp_data FROM deal_position_break_down GROUP BY source_deal_detail_id,curve_id, leg, fin_expiration_date HAVING COUNT(*)>1

DELETE dpd FROM 
#temp_data td
INNER JOIN deal_position_break_down dpd ON td.source_deal_detail_id = dpd.source_deal_detail_id
	AND td.curve_id = dpd.curve_id
	AND td.leg = dpd.leg
	AND td.fin_expiration_date = dpd.fin_expiration_date
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[deal_position_break_down]') AND NAME = N'uci_deal_position_break_down')
	CREATE  UNIQUE INDEX uci_deal_position_break_down ON dbo.deal_position_break_down(source_deal_detail_id,curve_id, leg, fin_expiration_date)


--DELETE FROM deal_position_break_down WHERE source_deal_detail_id IN (SELECT source_deal_detail_id FROM deal_position_break_down GROUP BY source_deal_detail_id,curve_id,fin_expiration_date HAVING COUNT(*)>1)
