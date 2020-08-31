IF OBJECT_ID(N'[dbo].[spa_get_month_list]', N'P') IS NOT NULL
DROP proc [dbo].[spa_get_month_list]
GO
CREATE proc [dbo].[spa_get_month_list]
as
BEGIN
	select 1 as [month_value],'January' as [month_name]
	UNION
	select 2 as [month_value],'February' as [month_name]
	UNION
	select 3 as [month_value],'March' as [month_name]
	UNION
	select 4 as [month_value],'April' as [month_name]
	UNION
	select 5 as [month_value],'May' as [month_name]
	UNION
	select 6 as [month_value],'June' as [month_name]
	UNION
	select 7 as [month_value],'July' as [month_name]
	UNION
	select 8 as [month_value],'August' as [month_name]
	UNION
	select 9 as [month_value],'September' as [month_name]
	UNION
	select 10 as [month_value],'October' as [month_name]
	UNION
	select 11 as [month_value],'November' as [month_name]
	UNION
	select 12 as [month_value],'December' as [month_name]
END



