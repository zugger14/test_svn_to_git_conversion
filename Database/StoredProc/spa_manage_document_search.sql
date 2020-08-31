IF OBJECT_ID('[spa_manage_document_search]') IS NOT NULL
	DROP  PROCEDURE [dbo].[spa_manage_document_search]
GO

CREATE PROC [dbo].[spa_manage_document_search]
@flag CHAR(1),
@search_text NVARCHAR(1000) = NULL,
@object_id varchar(200) = NULL,
@notes_object_id INT = NULL,
@activity_id INT = NULL,
@search_result_table varchar(200) = null
AS
SET NOCOUNT ON
/*
declare 
@flag CHAR(1),
@search_text VARCHAR(1000) = NULL,
@object_id INT = NULL,
@notes_object_id INT = NULL,
@activity_id INT = NULL,
@search_result_table varchar(200)

select @flag='s',@object_id=NULL,@notes_object_id=NULL,@search_result_table = '-1'

--select * from application_notes
----EXEC spa_application_notes @flag='g',@internal_type_value_id='33',@category_value_id=NULL,@notes_object_id='0',@download_url='force_download.php'
--EXEC spa_manage_document_search @flag='s',@search_text='test',@object_id='33'
--*/



declare @sql varchar(max)

IF @flag = 's' --final select for search should match exact number of columns and column names as on flag 's' on spa_application_notes that loads the grid
BEGIN
	declare @selected_match_id varchar(100)
	if isnull(@object_id, 1) = 33 --only when call from deal
	begin
		if OBJECT_ID('tempdb..#match_table') is not null drop table #match_table
		select mg.match_group_id, sdd.source_deal_detail_id, sdd.source_deal_header_id
		into #match_table
		from application_notes an
		inner join match_group mg on mg.match_group_id = an.notes_object_id
		inner join match_group_header mgh on mgh.match_group_id = mg.match_group_id
		inner join match_group_detail mgd on mgd.match_group_header_id = mgh.match_group_header_id
		inner join source_deal_detail sdd on sdd.source_deal_detail_id = mgd.source_deal_detail_id
		where an.internal_type_value_id in (45) and sdd.source_deal_header_id = isnull(@notes_object_id, -1)

		SELECT @selected_match_id = STUFF(
			(SELECT distinct ','  + cast(m.match_group_id AS varchar)
			from #match_table m
			FOR XML PATH(''))
		, 1, 1, '')
	end

	set @sql = '
	SELECT ' + case when @search_result_table = '-1' then ' top(0) ' else '' end + '
		isnull(sdv_cat.code, ''General'') [category],
		isnull(sdv_sub_cat.code, ''General'') [sub_category],
		an.notes_subject,
		an.attachment_file_name + ''^javascript:fx_download_file("'' + an.notes_attachment + ''")^_self'' [notes_attachment],
		case when an.internal_type_value_id in (33,37) then
		cast(isnull(an.parent_object_id, an.notes_object_id) as varchar(500)) + '' ('' + isnull(sdv_cat.code, '''') + '')^javascript:fx_click_parent_object_id_link('' + cast(sdv_cat.value_id as varchar(10)) + '','' + cast(isnull(an.parent_object_id, an.notes_object_id) as varchar(500))+ '')^_self'' else null end parent_object_id,
		sdv_user_cat.code user_category,
		(an.url + ''^'' + an.url) url,
		dbo.FNADateFormat(an.create_ts) create_ts,
		an.create_user,
		an.attachment_file_name,
		CASE an.notes_share_email_enable
			WHEN 0 THEN ''Disabled''
			WHEN 1 THEN ''Enabled''
		END AS notes_share_email_enable
		, an.notes_id,an.category_value_id [sub_category_id]
		, sdv_cat.value_id [category_id]
		, an.notes_object_id [notes_object_id]
	FROM application_notes an
	' + case when @search_result_table = '-1' then '' else 
	' inner join ' + @search_result_table + ' srt on srt.notes_id = an.notes_id ' end + '
	left join static_data_value sdv_cat on sdv_cat.value_id = an.internal_type_value_id
	left join static_data_value sdv_sub_cat on sdv_sub_cat.value_id = an.category_value_id
	left join static_data_value sdv_user_cat on sdv_user_cat.value_id = an.user_category
	left join dbo.SplitCommaSeperatedValues(''' + cast(isnull(@object_id,'') as varchar(20)) + ''') scsv on scsv.item = an.internal_type_value_id
	WHERE (isnull(an.notes_object_id,-1) = ' + case when @notes_object_id is not null then cast(@notes_object_id as varchar(20)) else ' isnull(an.notes_object_id,-1)' end + ' or isnull(an.parent_object_id, -1) = ' + case when @notes_object_id is not null then cast(@notes_object_id as varchar(20)) else ' an.notes_object_id' end + 
	+ 
	case when @notes_object_id is not null and isnull(@object_id, -1) = 33 then '
	OR an.notes_object_id in (' + isnull(@selected_match_id, '-1') + ')' else '' 
	end +
	')
	order by notes_id
	'
	exec(@sql)
	
END
else if @flag = 'w'
begin
	select distinct sdv.value_id [category_id], sdv.code [category_name], wa.event_message_id [workflow_message_id], wa.workflow_process_id [workflow_process_id], wa.source_id [source_deal_header_id]
	from workflow_activities wa 
	left join static_data_value sdv on sdv.type_id = 25 --document type (main category)
		and sdv.value_id = case wa.source_column 
								when 'source_deal_header_id' then 33 --deal
								when 'calc_id' then 38 --invoice
								when 'contract_id' then 40 --contract
								when 'counterparty_id' then 37 --counterparty
								when 'mgs_match_group_shipment_id' then 45
								else sdv.value_id + 1
						   end
	where wa.workflow_activity_id = @activity_id

end
else if @flag = 'x'
begin
	set @sql = '
	select sdv.value_id [category_id], sdv.code [category_name] 
	from static_data_value sdv
	where sdv.type_id=25'
	+ case when @object_id is not null then ' and sdv.value_id in (' + @object_id + ')' else '' end
	exec(@sql)
end