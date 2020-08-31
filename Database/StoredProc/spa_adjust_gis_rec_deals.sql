
IF OBJECT_ID(N'[dbo].[spa_adjust_gis_rec_deals]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_adjust_gis_rec_deals]
GO



-- exec spa_adjust_gis_rec_deals '2006-06-01', '2006-06-30', 'urbaral', null

CREATE PROCEDURE [dbo].[spa_adjust_gis_rec_deals] (	@gen_date_from varchar(20), 
						@gen_date_to varchar(20), 
						@user_id varchar(50), 
						@deal_id varchar(50) = null -- not used now.. we might  need in  the  future
						)
AS

DECLARE @spa varchar(500)
DECLARE @job_name varchar(100)
DECLARE @process_id varchar(50)

SET @process_id = REPLACE(newid(),'-','_')
SET @job_name = 'gisrecon_' + @process_id



SET @spa = 'spa_adjust_gis_rec_deals_JOB ''' + @gen_date_from + ''', ''' + @gen_date_to + ''', ''' +
		@user_id + ''', NULL ' + ', ''' + 
		 @process_id + ''', ''' + @job_name + ''''

EXEC spa_print @spa

EXEC spa_run_sp_as_job @job_name, @spa, 'GISRecon', @user_id


Exec spa_ErrorHandler 0, 'GISRecon', 
			'Process run', 'Status', 
			'GIS Certificates updates and adjustments of approved RECs have been scheduled and will complete shortly.', 
			'Plese check/refresh your message board.'






