IF OBJECT_ID('spa_rpt_get_erroneous_RDB_deal_reason') IS NOT NULL
	DROP  PROCEDURE [dbo].[spa_rpt_get_erroneous_RDB_deal_reason]
GO


-- =============================================
-- Create date: 2009-03-03 05:01PM
-- Description:	Get a list of deals which were not loaded in FT system from RDB
-- Params:
-- @as_of_date varchar(20) - As of date
-- @deal_id varchar(255) - deal id (from 3rd party system like Endur)
-- =============================================
CREATE PROCEDURE [dbo].[spa_rpt_get_erroneous_RDB_deal_reason]
	@as_of_date		varchar(20),
	@deal_id		varchar(255)
	
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @sql	varchar(8000)

	SET @sql = 'SELECT DISTINCT dbo.FNADateFormat(as_of_date), ''' + @deal_id + ''' AS deal_num, d.source, d.type, d.description AS description, d.type_error
				FROM import_data_files_audit a
				INNER JOIN source_system_data_import_status_detail d ON a.process_id = d.process_id
				WHERE a.as_of_date = ''' + @as_of_date + '''
				--AND d.source IN (''source_deal_pnl'', ''source_deal_detail'', ''MTM'', ''Position'')
				AND ( d.description LIKE ''%Data error for Deal ID :' + @deal_id + '%''
					OR d.description LIKE ''%Data error for source_deal_header_id :' + @deal_id + '%''
					OR d.description LIKE ''%Data error for id :' + @deal_id + '%''
					OR d.description LIKE ''%Data error for deal_id :' + @deal_id + '%''
					)
				'
	exec spa_print @sql

	EXEC (@sql)

END                

GO
