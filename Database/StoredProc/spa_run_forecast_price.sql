/**
Forecast price Run
Created Date: 2016-04-30
By: sligal@pioneersolutionsglobal.com

flags:
	@flag CHAR(1) -> action flag
	@xml_param xml -> form data as a parameter on xml string
	@batch_process_id varchar(50) 
	@batch_report_param varchar(5000) 

exec spa_run_forecast_price 'r', '<Root><PSRecordset as_of_date="2016-05-02" date_from="2016-05-03" date_to="2016-05-03" demand_zone="1411,1413" profile="36,35" customer="4204,4205" approach="0" retrain_model="1"></PSRecordset></Root>'
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_run_forecast_price]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_run_forecast_price]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- spa_run_forecast_price @flag ='i',@call_from = 'ssis',@error_msg = 'this', @acknowledge = 'A',@process_id = '123123'

CREATE PROCEDURE [dbo].[spa_run_forecast_price]
	@flag CHAR(1),
	@xml_param xml = null,
	@batch_process_id varchar(50) = null,
	@batch_report_param varchar(5000) = null
	
	

AS 
set nocount on

/*
declare @flag CHAR(1),
	@xml_param xml = null,
	@batch_process_id varchar(50) = null,
	@batch_report_param varchar(5000) = null

	--EXEC spa_run_forecast_price @flag=''r'', @xml_param=''<Root><PSRecordset as_of_date="2016-05-03" date_from="2016-05-04" date_to="2016-05-04" price_curve="4412" approach="1" retrain_model="0"></PSRecordset></Root>''

select @flag='r', @xml_param='<Root><PSRecordset as_of_date="2016-05-03" date_from="2016-05-04" date_to="2016-05-04" price_curve="4412" approach="1" retrain_model="0"></PSRecordset></Root>'
--*/
declare @user_name VARCHAR(200) = dbo.FNADbuser()
declare @process_id varchar(40) = replace(cast(newid() as varchar(100)), '-', '_')

begin try
	if @flag = 'r'
	begin
		declare @idoc_r int
		IF OBJECT_ID('tempdb..#tmp_xml_param') IS NOT NULL 
			DROP TABLE #tmp_xml_param
		exec sp_xml_preparedocument @idoc_r output, @xml_param
	
		select *
		into #tmp_xml_param
		from openxml(@idoc_r,'/Root/PSRecordset',2)
		with (
			as_of_date		varchar(30)		'@as_of_date',
			date_from		varchar(30)		'@date_from',
			date_to			varchar(30)		'@date_to',
			price_curve		varchar(5000)	'@price_curve',
			approach		bit				'@approach',
			retrain_model	bit				'@retrain_model'
		)

		--select * from #tmp_xml_param
		--return

		declare	@error_code char(1) = 's'
		--EXEC spa_price_forecast_report '37',null,'2015-12-01','2015-12-01',null,null,'d','r','2',null

		declare @message varchar(5000) 
		select  @message = 'Forecast price has been completed for as of date: ' + dbo.FNADateFormat(as_of_date)
		from #tmp_xml_param

		declare @link varchar(5000) 
		declare @items_combined varchar(1000), @paramset_id varchar(10)
		select @paramset_id = rpm.report_paramset_id, @items_combined = dbo.FNARFXGenerateReportItemsCombined(rpg.report_page_id)
		--select *
		from report_paramset rpm 
		inner join report_page rpg on rpg.report_page_id = rpm.page_id
		where rpm.name = 'Price Curve Tablix' --HARDCODED VALUE FOR SYSTEM REPORT PARAMSET NAME
		
		
		select @link = '<a href="javascript: open_message_dhtmlx(''../../adiha.html.forms/_reporting/report_manager_dhx/report.viewer.php?report_name=Price Curve Tablix_Price Curve Tablix&report_filter=curve_id=' + txp.price_curve + ',as_of_date=' + txp.as_of_date + ',maturity_date=' + txp.date_from + ',to_maturity_date=' + txp.date_to + '&is_refresh=0&items_combined=' + @items_combined + '&paramset_id=' + @paramset_id + '&export_type=HTML4.0'', ''window name'');">' + @message + '</a>'
		from #tmp_xml_param txp
		
		declare @delay_time varchar(8)
		
		select @delay_time = case txp.retrain_model when 1 then '00:01:00' else '00:00:08' end
		from #tmp_xml_param txp

		WAITFOR DELAY @delay_time

		EXEC spa_message_board 'i',
			@user_name,
			NULL,
			'Run Forecast Price',
			@link,
			'',
			'',
			@error_code,
			@process_id
		
	end 
	
	
end try
begin catch
	rollback
	declare @err_msg varchar(2000) = 'Catch Error: ' + error_message()
	exec spa_ErrorHandler -1
		, 'Forecast price'
		, 'spa_run_forecast_price'
		, 'Error'
		, 'Error on Forecast price Run'
		, @err_msg
	EXEC spa_print 'Catch Error:' --+ error_message()
end catch