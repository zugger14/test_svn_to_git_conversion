IF OBJECT_ID(N'[dbo].[spa_alert_reports]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_alert_reports]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
 /**
	Operations for Alert Reports

	Parameters :
	@flag : Flag
			'i'-- Insert Alert Report
			'u'-- Update Alert Report
			'd'-- Delete Alert Report
			's'-- Get All Alert Report
			'a'-- Get Alert Report Details
	@alert_report_id : alert_reports_id FROM alert_reports
	@event_message_id : Event Message Id (event_message_id FROM workflow_event_message)
	@report_writer : 'y'- Report Manager Report, 'n'-SQL Report, 'a'-Alert Table Report
	@paramset_hash : Paramset Hash of for Report Manager Report
	@report_parameter : Report Parameter for Report Manager Report
	@report_description : Description
	@table_prefix : Process Table Prefix for SQL/ALert Table Report
	@table_suffix : Process Table Suffix for SQL/ALert Table Report
	@main_table_id : Main Table Id
	@report_params : Additional Report Parameters
	@report_where_clause : Where Clause for the SQL/Alert Report
 */

CREATE PROCEDURE [dbo].[spa_alert_reports]
    @flag NCHAR(1),
    @alert_report_id INT = NULL,
    @event_message_id INT = NULL,
	@report_writer NCHAR(1) = NULL,
	@paramset_hash NVARCHAR(200) = NULL,
	@report_parameter NVARCHAR(500) = NULL,
	@report_description NVARCHAR(500) = NULL,
	@table_prefix NVARCHAR(500) = NULL,
	@table_suffix NVARCHAR(500) = NULL,
	@main_table_id INT = NULL,
	@report_params NVARCHAR(MAX) = NULL,
	@report_where_clause NVARCHAR(MAX) = NULL,
	@file_option_type NCHAR(1) = NULL
AS
SET NOCOUNT ON

DECLARE @DESC NVARCHAR(500)
IF @flag = 'i'
BEGIN
	BEGIN TRY
		SELECT @report_parameter = 
		STUFF((Select ','+ a.column_name + '=' + CASE WHEN a.initial_value = '' THEN 'NULL' ELSE a.initial_value END
			FROM (
				select dsc.name [column_name], REPLACE(rp.initial_value, ',','!') initial_value
				from report_param rp
				inner join data_source_column dsc on dsc.data_source_column_id = rp.column_id
				inner join report_dataset_paramset rdp on rdp.report_dataset_paramset_id = rp.dataset_paramset_id
				inner join report_paramset rps on rps.report_paramset_id = rdp.paramset_id
				inner join report_param_operator rpo on rpo.report_param_operator_id = rp.operator
				where rps.paramset_hash = @paramset_hash
				UNION ALL
				select '2_' + dsc.name [column_name], REPLACE(rp.initial_value2, ',','!') initial_value2
				from report_param rp
				inner join data_source_column dsc on dsc.data_source_column_id = rp.column_id
				inner join report_dataset_paramset rdp on rdp.report_dataset_paramset_id = rp.dataset_paramset_id
				inner join report_paramset rps on rps.report_paramset_id = rdp.paramset_id
				inner join report_param_operator rpo on rpo.report_param_operator_id = rp.operator
				where rps.paramset_hash = @paramset_hash AND rpo.report_param_operator_id = 8
			) a
		FOR XML PATH('')),1,1,'')

		INSERT INTO alert_reports (event_message_id, report_writer, paramset_hash, report_param, report_desc, table_prefix, table_postfix, report_where_clause,file_option_type)
		SELECT @event_message_id, @report_writer, @paramset_hash, @report_parameter, 
				CASE WHEN @report_description = '' THEN (SELECT name FROM report_paramset WHERE paramset_hash = @paramset_hash) ELSE @report_description END,
				@table_prefix, @table_suffix, @report_where_clause,@file_option_type
		
		SET @alert_report_id = SCOPE_IDENTITY()
		
		IF @report_writer = 'y' AND @report_params IS NOT NULL AND @report_params <> '' 
		BEGIN
			INSERT INTO alert_report_params (
				event_message_id, 
				alert_report_id, 
				main_table_id, 
				parameter_name,
				parameter_value
			)
			SELECT 
				@event_message_id,
				@alert_report_id,
				@main_table_id,
				LEFT(item, CHARINDEX('=', item)-1),
				RIGHT(item, CHARINDEX('=', REVERSE(item))-1)
			FROM dbo.FNASplit(@report_params, ',')
		END
				
		EXEC spa_ErrorHandler 0,
		     'alert_reports',
		     'spa_alert_reports',
		     'Success',
		     'Successfully inserted data.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler @@ERROR,
		     'alert_reports',
		     'spa_alert_reports',
		     'Error',
		     @DESC,
		     ''
	END CATCH
END
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		SELECT @report_parameter = 
		STUFF((Select ','+ a.column_name + '=' + CASE WHEN a.initial_value = '' THEN 'NULL' ELSE a.initial_value END
			FROM (
				select dsc.name [column_name], rp.initial_value
				from report_param rp
				inner join data_source_column dsc on dsc.data_source_column_id = rp.column_id
				inner join report_dataset_paramset rdp on rdp.report_dataset_paramset_id = rp.dataset_paramset_id
				inner join report_paramset rps on rps.report_paramset_id = rdp.paramset_id
				inner join report_param_operator rpo on rpo.report_param_operator_id = rp.operator
				where rps.paramset_hash = @paramset_hash
				UNION ALL
				select '2_' + dsc.name [column_name], rp.initial_value2
				from report_param rp
				inner join data_source_column dsc on dsc.data_source_column_id = rp.column_id
				inner join report_dataset_paramset rdp on rdp.report_dataset_paramset_id = rp.dataset_paramset_id
				inner join report_paramset rps on rps.report_paramset_id = rdp.paramset_id
				inner join report_param_operator rpo on rpo.report_param_operator_id = rp.operator
				where rps.paramset_hash = @paramset_hash AND rpo.report_param_operator_id = 8
			) a
		FOR XML PATH('')),1,1,'')

		UPDATE alert_reports
		SET event_message_id = @event_message_id,
			report_writer = @report_writer,
			paramset_hash = @paramset_hash,
			report_param = @report_parameter,
			report_desc = CASE WHEN @report_description = '' THEN (SELECT name FROM report_paramset WHERE paramset_hash = @paramset_hash) ELSE @report_description END,
			table_prefix = @table_prefix,
			table_postfix = @table_suffix,
			report_where_clause = @report_where_clause,
			file_option_type = @file_option_type
		WHERE alert_reports_id = @alert_report_id		
		
		IF @report_writer = 'y' AND @report_params IS NOT NULL AND @report_params <> '' 
		BEGIN
			
			INSERT INTO alert_report_params  (
				event_message_id, 
				alert_report_id, 
				main_table_id, 
				parameter_name,
				parameter_value
			)
			SELECT 
				@event_message_id,
				@alert_report_id,
				@main_table_id,
				LEFT(item, CHARINDEX('=', item)-1),
				RIGHT(item, CHARINDEX('=', REVERSE(item))-1)
			FROM dbo.FNASplit(@report_params, ',')
		END	
		ELSE
		BEGIN
			DELETE FROM alert_report_params WHERE alert_report_id = @alert_report_id
		END	
		
		EXEC spa_ErrorHandler 0,
		     'alert_reports',
		     'spa_alert_reports',
		     'Success',
		     'Successfully updated data.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler @@ERROR,
		     'alert_reports',
		     'spa_alert_reports',
		     'Error',
		     @DESC,
		     ''
	END CATCH
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE FROM alert_report_params WHERE alert_report_id = @alert_report_id
		DELETE FROM alert_reports WHERE alert_reports_id = @alert_report_id		
		
		EXEC spa_ErrorHandler 0,
		     'alert_reports',
		     'spa_alert_reports',
		     'Success',
		     'Successfully deleted data.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to delete Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler @@ERROR,
		     'alert_reports',
		     'spa_alert_reports',
		     'Error',
		     @DESC,
		     ''
	END CATCH	
END
ELSE IF @flag = 's'
BEGIN
	SELECT ar.alert_reports_id [Reports ID],
	       CASE WHEN ar.report_writer = 'y' THEN 'Yes' ELSE 'No' END [Report Writer],
	       r.[name] + '_' + rp2.[name] + '_' + rp.[name] [Report Name],
		   ar.paramset_hash,
	       ar.report_param [Report Param],
	       ar.report_desc [Report Description],
	       ar.table_prefix [Table Prefix],
	       ar.table_postfix [Table Suffix],
		   ar.report_where_clause [Report Where Clause],
		   ar.report_writer [Report Type],
		   ar.file_option_type [File Option Type]
	FROM   alert_reports ar
	LEFT JOIN report_paramset rp ON rp.paramset_hash = ar.paramset_hash
	LEFT JOIN report_page rp2 ON rp.page_id = rp2.report_page_id
	LEFT JOIN report r ON r.report_id = rp2.report_id
	LEFT JOIN workflow_event_message as1 ON as1.event_message_id = ar.event_message_id
	WHERE ar.event_message_id = ISNULL(NULLIF(@event_message_id,''),-1)
END
ELSE IF @flag = 'a'
BEGIN
	SELECT ar.alert_reports_id,
	       ar.event_message_id,
	       ar.report_writer,
	       ar.paramset_hash,
	       r.[name] + '_' + rp2.[name] + '_' + rp.[name], 
	       ar.report_param,
	       ar.report_desc,
	       ar.table_prefix,
	       ar.table_postfix
	FROM   alert_reports ar
	LEFT JOIN report_paramset rp ON rp.paramset_hash = ar.paramset_hash
	LEFT JOIN report_page rp2 ON rp.page_id = rp2.report_page_id
	LEFT JOIN report r ON r.report_id = rp2.report_id
	WHERE ar.alert_reports_id = @alert_report_id
END