if object_id('dbo.spa_rfx_run_sql_external') is not null
	drop proc dbo.spa_rfx_run_sql_external

go

create PROCEDURE  dbo.spa_rfx_run_sql_external 
	@report_name varchar(500)
	,@component_name varchar(500) 
	,@filter varchar(max)
	,@process_id varchar(250)= null

AS

/*

declare @report_name varchar(500)= 'Credit Risks Dashboard'
	, @component_name varchar(500) = 'ITEM_Top10CreditExposures'
	,@filter varchar(max)
	,@process_id varchar(250)= null


--*/

declare @paramset_id int ,@component_id int

SELECT @paramset_id= rp.report_paramset_id
	, @component_id=rpt.report_page_tablix_id 
FROM report r
	INNER JOIN report_page rpage ON r.report_id = rpage.report_id
	INNER JOIN report_page_tablix rpt ON rpt.page_id = rpage.report_page_id
	INNER JOIN report_paramset rp ON rpage.report_page_id = rp.page_id
WHERE rp.name = @report_name
	AND 'ITEM_' + REPLACE(rpt.name, ' ', '') = @component_name


exec spa_rfx_run_sql @paramset_id, @component_id, @filter
	,null,'t',null,null,null,@process_id