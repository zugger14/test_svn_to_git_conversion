
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


SET ARITHABORT ON
GO

SET CONCAT_NULL_YIELDS_NULL ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

SET ANSI_PADDING ON
GO

SET ANSI_WARNINGS ON
GO

SET NUMERIC_ROUNDABORT OFF
GO


if OBJECT_ID('vwposition_breakdown') is not null
drop view [vwposition_breakdown]
go

CREATE VIEW [dbo].[vwposition_breakdown] WITH schemabinding 	AS
	SELECT COUNT_BIG(*) cnt,term_start,term_end,curve_id financial_curve_id,deal_volume_uom_id, rowid,deal_date,expiration_date,
		sum(isnull(calc_volume,0)) calc_volume,formula
	FROM dbo.report_hourly_position_breakdown_main
	GROUP BY term_start,term_end,curve_id,rowid,deal_volume_uom_id,deal_date,expiration_date,formula

GO

if not exists(select 1 from sys.indexes where [name]='ucindx_vwposition_breakdown')
create unique clustered index ucindx_vwposition_breakdown on vwposition_breakdown  
(term_start,term_end,financial_curve_id,deal_volume_uom_id,rowid,deal_date,expiration_date,formula) 
--ON PS_position_report_hourly_position_breakdown(term_start)
	