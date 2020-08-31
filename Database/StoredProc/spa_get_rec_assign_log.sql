/****** Object:  StoredProcedure [dbo].[spa_get_rec_assign_log]    Script Date: 08/25/2009 09:26:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_rec_assign_log]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_rec_assign_log]
/****** Object:  StoredProcedure [dbo].[spa_get_rec_assign_log]    Script Date: 08/25/2009 09:26:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[spa_get_rec_assign_log] @process_id varchar(50)
AS

-- 
-- select dbo.FNAGetSQLStandardDate(getdate())
-- 
-- 
-- select './spa_html.php?__user_name__=urbaral&spa=exec spa_create_lifecycle_of_recs ''' + 
-- 	dbo.FNAGetSQLStandardDate(getdate()) + ''', null, ''' + cast(source_deal_header_id as varchar) + ''''
-- 
-- 
-- 		SET @urlP = './dev/spa_perform_process.php?as_of_date= ' + dbo.FNAUserDateFormat(@as_of_date, @user_id) + 
-- 			'&process_id=115&process_attachment=Run Assessment ran on ' +
-- 			dbo.FNAUserDateTimeFormat(getdate(), 1, @user_id) +
-- 			'&spa=exec spa_get_mtm_test_run_log ''' + @process_id + '''' +
-- 			'&__user_name__=' + @user_id
-- 		
-- 	'<a target="_blank" href="' + 
-- 	'./spa_html.php?__user_name__=urbaral&spa=exec spa_create_lifecycle_of_recs ''' + 
-- 	dbo.FNAGetSQLStandardDate(getdate()) + ''', null, ''' + cast(source_deal_header_id as varchar) + ''''
-- 	+ '">' + 
-- 	description +
-- 	'</a>'

declare @as_of_date varchar(20)
set @as_of_date = dbo.FNAGetSQLStandardDate(getdate())


SELECT	code AS Code, 
	[module] AS Module, 
--	description AS [Action], 
	'<a target="_blank" href="' + 
	'./spa_html.php?__user_name__=urbaral&spa=exec spa_create_lifecycle_of_recs ''' + 
	isnull(dbo.FNAGetSQLStandardDate(sd.assigned_date), @as_of_date) 
	 + ''', null, ''' + cast(rec_assign_log.source_deal_header_id_sale_from as varchar) + ''''
		+ '">' + 
	description +  '</a>' AS [Action], 

	dbo.FNAHyperLinkText(10131010, cast(rec_assign_log.source_deal_header_id as varchar), 
	cast(rec_assign_log.source_deal_header_id as varchar)) 
	ID,
	case when (source_deal_header_id_sale_from is null) then '' else 
	dbo.FNAHyperLinkText(10131010, cast(rec_assign_log.source_deal_header_id_sale_from as varchar), 
	cast(rec_assign_log.source_deal_header_id_sale_from as varchar)) 
	end
	[Assigned From],
        rec_assign_log.create_user AS CreatedBy, 
	rec_assign_log.create_ts AS CreatedTS
	--drp.source_deal_header_id	
FROM    rec_assign_log left join source_deal_header sd
	on rec_assign_log.source_deal_header_id=sd.source_deal_header_id

WHERE   process_id = @process_id
ORDER BY rec_assign_log_id





