IF OBJECT_ID(N'[dbo].[spa_get_regions]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_regions]
GO 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec spa_get_regions
--exec spa_get_regions 'urbaral'

CREATE PROCEDURE [dbo].[spa_get_regions] 
	@user_login_id varchar(50) = NULL
AS

SET NOCOUNT ON

If @user_login_id IS NULL
	select region_id, region_name from region ORDER BY region_name
Else
	select date_format, message_refresh_time, COALESCE(dbo.FNAChangeDateFormat(), '%Y-%m-%d') AS [dhtmlx_date_format] from 
		application_users au INNER JOIN region r
		ON au.region_id = r.region_id
		WHERE au.user_login_id = @user_login_id





