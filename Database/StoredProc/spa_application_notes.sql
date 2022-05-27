IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_application_notes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_application_notes]
 GO 

SET ANSI_NULLS ON
GO
  
SET QUOTED_IDENTIFIER ON
GO

/**
	Used to perform select, insert, update, count  and delete from application_notes table.

	Parameters
	@flag : Operational flag.
	@notes_id : primary key of the table application_notes
	@internal_type_value_id : value_id of the note type i.e.'Book' ,'Subsidiary'
	@notes_object_id : notes_object_id of table application_notes.
	@notes_subject : notes_subject of table application_notes.
	@notes_text : notes_text of the table application_notes.
	@attachment_file_name : attachment_file_name of table application_notes.
	@notes_attachment : notes_attachment of table application_notes.
	@docfilename : attachment_file_name of table application_notes.
	@content_type : content_type of table application_notes.
	@download_url : Path url to download file.
	@notes_ids : Multiple notes_ids to delete the many notes at a time.
	@category_value_id : Documents Type from the type id 42000
	@search_result_table : Table name from where data is searched.
	@call_from : To know where the SP is called from.
	@notes_status : status_id of table application_notes_status
	@status_date : status_date of table application_notes_status
	@comments : comments of table application_notes_status
	@notes_status_id : Primary key of table application_notes_status


*/

--EXEC spa_application_notes @flag='d', @notes_ids='1004'
--exec spa_application_notes 'u', 326,30,5006,'General','0','aaa',NULL,'',null,256,''
--exec spa_application_notes 'u', 326,30,5006,'General','0','help god',NULL,'',null,256,''

--exec spa_application_notes 'a',321
--exec spa_Get_All_Notes 1,0,Null,5006, NULL, NULL, NULL, NULL, NULL, 1
----exec spa_application_notes 'i', NULL,30,NULL,'General','0','help','','D:\FARRMS_APPLICATIONS\DEV\FASTracker_Master\fas2.1\adiha.php.scripts\dev\shared_docs\temp_note\TESTdoc_1191843140.jpg',null,NULL,'Bikes5.jpg','image/pjpeg'
CREATE PROCEDURE [dbo].[spa_application_notes]
	@flag						CHAR(1),
	@notes_id					INT = NULL,
	@internal_type_value_id		INT = NULL,
	@notes_object_id			VARCHAR(50) = NULL,
	@notes_subject				NVARCHAR(250) = NULL,
	@notes_text					NVARCHAR(MAX) = NULL,
	@attachment_file_name		NVARCHAR(500) = NULL,
	@notes_attachment			VARBINARY(MAX) = NULL,
	@docfilename				NVARCHAR(200) = NULL,
	@content_type				VARCHAR(500) = NULL,
	@download_url				NVARCHAR(MAX) = NULL,
	@notes_ids					VARCHAR(500) = NULL,
	@category_value_id			INT = NULL,
	@search_result_table		VARCHAR(500) = NULL,
	@call_from					VARCHAR(100) = NULL,
	@notes_status				INT = NULL,
	@status_date				DATE = NULL,
	@comments					NVARCHAR(1000) = NULL,
	@notes_status_id			INT = NULL
	AS

/*
declare @flag						CHAR(1),
	@notes_id					INT = NULL,
	@internal_type_value_id		INT = NULL,
	@notes_object_id			VARCHAR(50) = NULL,
	@notes_subject				VARCHAR(250) = NULL,
	@notes_text					VARCHAR(5000) = NULL,
	@attachment_file_name		VARCHAR(500) = NULL,
	@notes_attachment			VARBINARY(MAX) = NULL,
	@docfilename				VARCHAR(200) = NULL,
	@content_type				VARCHAR(500) = NULL,
	@download_url				VARCHAR(MAX) = NULL,
	@notes_ids					VARCHAR(500) = NULL,
	@category_value_id			INT = NULL,
	@search_result_table		VARCHAR(500) = NULL,
	@notes_status				INT = NULL,
	@status_date				DATE = NULL,
	@comments					VARCHAR(1000) = NULL,
	@notes_status_id			INT = NULL

select @flag='g',@internal_type_value_id='33',@category_value_id='42018',@notes_object_id='55049',@download_url='force_download.php'
--select @flag='g',@internal_type_value_id=NULL,@category_value_id='',@notes_object_id=NULL,@download_url='force_download.php'
--*/

set nocount on

declare @shared_document_path nvarchar(1000) = null,
		@delete_notes_ids NVARCHAR(MAX)
select @shared_document_path = cs.document_path
from connection_string cs

IF @flag = 's' --and @notes_id is NOT NULL
BEGIN
	SELECT notes_id,
	internal_type_value_id,
	notes_object_id,
	notes_subject,
	notes_text,
	attachment_file_name,
	notes_attachment,
	create_user,
	update_user,
	update_ts,
	content_type
		FROM application_notes

END

ELSE IF @flag = 'u' --and @notes_id is NOT NULL
BEGIN
	DECLARE @st1 NVARCHAR(MAX)
	SET @st1='
	update application_notes 
	set 
	internal_type_value_id='+ cast(@internal_type_value_id AS VARCHAR)+',
	notes_object_id='+cast(isnull(@notes_object_id,'') AS VARCHAR)+',
	notes_subject='''+isnull(@notes_subject,'')+''',
	notes_text='''+isnull(@notes_text,'')+''','+
	CASE WHEN isnull(@attachment_file_name,'')<>'' THEN
	'attachment_file_name='''+@docfilename+''',
	content_type='''+@content_type+''',
	notes_attachment= (select a.* FROM OPENROWSET(BULK '''+@attachment_file_name+''',SINGLE_BLOB) AS a),
	'
	ELSE '' END
	+
	'where notes_id='+cast(@notes_id AS VARCHAR)
	--print @attachment_file_name
	--print(@st1)
	--return
	EXEC(@st1)
	--return
	IF @@ERROR <> 0
		BEGIN
			EXEC spa_ErrorHandler @@ERROR, "Appliction Notes", 
					"spa_application_notes", "DB Error", 
					"Insert of application notes failed.", ''
			RETURN
		END

			ELSE EXEC spa_ErrorHandler 0, 'Appliction Notes', 
					'spa_application_notes', 'Success', 
					'Application notess detail successfully selected.', ''
END	

ELSE IF @flag = 'm' --select image for view
BEGIN
	SELECT notes_id,
	attachment_file_name,
	notes_attachment,
	content_type
	FROM application_notes where notes_id=@notes_id
END

ELSE IF @flag = 'i'
BEGIN
	DECLARE @st NVARCHAR(MAX)

	SET @st='insert into application_notes (
	internal_type_value_id,
	notes_object_id,
	notes_subject,
	notes_text,
	content_type,
	attachment_file_name' +
	CASE WHEN isnull(@attachment_file_name,'')='' THEN '' ELSE ', 
	notes_attachment' END +
	' )
	select ' + cast(isnull(@internal_type_value_id,'') AS VARCHAR)+','+
	isnull(@notes_object_id,'')+''','''+
	isnull(@notes_subject,'')+''','''+
	isnull(@notes_text,'')+''','''+
	isnull(@content_type,'')+''','''+
	isnull(REPLACE(@docfilename, ' ', '_'),'')+''','+
	CASE WHEN isnull(@attachment_file_name,'')='' THEN '' ELSE ', 
	* FROM OPENROWSET(BULK ''' + REPLACE(@attachment_file_name, ' ', '_') + ''',SINGLE_BLOB) AS [Document1]' END


	EXEC(@st)

		IF @@ERROR <> 0
		BEGIN
			EXEC spa_ErrorHandler @@ERROR, "Appliction Notes", 
					"spa_application_notes", "DB Error", 
					"Insert of application notes failed.", ''
		
		END
	ELSE
			EXEC spa_ErrorHandler 0, 'Appliction Notes', 
					'spa_application_notes', 'Success', 
					'Application notess detail successfully selected.', ''

END
 
ELSE IF @flag ='a' 
BEGIN
	SELECT 
	notes_id,
	internal_type_value_id,
	notes_object_id,
	notes_subject,
	--REPLACE(REPLACE(notes_text, CHAR(13), '<br/>'), CHAR(10), '<br/>') notes_text,
	--col notes_text has both encoded and raw strings so encode only the raw texts searching with '<' char
	iif(charindex('<',notes_text)=0,notes_text,replace(replace(dbo.FNAEncodeXML(notes_text),char(10),'\n'),char(13),'\n')) notes_text,
	notes_attachment,
	content_type,
	attachment_file_name,
	notes_share_email_enable,
	source_system_id,
	url,
	user_category,
	category_value_id,
	document_type,
	aps.status_id,
	aps.status_date
	FROM application_notes an 
	OUTER APPLY (
		SELECT MAX(application_notes_status_id) notes_status_id,application_notes_id  FROM application_notes_status ans
		WHERE ans.application_notes_id = an.notes_id
		GROUP BY application_notes_id
	) sts 
	LEFT JOIN application_notes_status aps ON aps.application_notes_status_id = sts.notes_status_id
	WHERE notes_id=@notes_id	
END


ELSE IF @flag = 'd'
BEGIN try
	begin tran
	DECLARE @sql VARCHAR(5000)

	declare @c_notes_id int = null
	declare @c_file_path nvarchar(max) = null
	declare @err_message_delete varchar(300) = '.'

	/* Pull ids containing same file name and extension.*/
	SELECT @delete_notes_ids = STUFF((SELECT DISTINCT ',' +  CAST(an1.notes_id AS VARCHAR(10))
									FROM application_notes an
									INNER JOIN dbo.SplitCommaSeperatedValues(@notes_ids) scsv 
										ON scsv.item = an.notes_id
									INNER JOIN application_notes an1
										ON an1.internal_type_value_id = an.internal_type_value_id
										AND an1.attachment_file_name = an.attachment_file_name
										AND an1.attachment_folder = an.attachment_folder
										AND an1.type_column_name = an.type_column_name
									WHERE NULLIF(an.notes_attachment, '') IS NOT NULL
							FOR XML PATH('')), 1, 1, '') 

	declare cur_delete_file cursor for
	select an.notes_id, an.notes_attachment
	from application_notes an
	inner join dbo.SplitCommaSeperatedValues(@notes_ids) scsv on scsv.item = an.notes_id
	where nullif(notes_attachment, '') is not null
	
	open cur_delete_file
	fetch next from cur_delete_file into @c_notes_id, @c_file_path
	while @@FETCH_STATUS = 0
	begin
		declare @status nvarchar(max) = null

		if dbo.FNAFileExists(@c_file_path) = 1
		begin
			EXEC spa_delete_file @c_file_path, @status OUTPUT
			if @status = '1' set @err_message_delete = 'delete_file_success'
			else set @err_message_delete = 'delete_file_failed'
		end
		else
		begin
			select @err_message_delete = 'delete_file_not_exist'
		end
		

		fetch next from cur_delete_file into @c_notes_id, @c_file_path
	end
	close cur_delete_file
	deallocate cur_delete_file

	SELECT @notes_ids = @notes_ids + IIF(NULLIF(@delete_notes_ids,'') IS NULL, '', ',' + @delete_notes_ids)

	SET @sql = 'DELETE FROM application_notes_status WHERE application_notes_id in (' + @notes_ids + ')
				DELETE application_notes WHERE notes_id in (' + @notes_ids + ')';
	EXEC(@sql)
	
	COMMIT

	if @err_message_delete = 'delete_file_success' set @err_message_delete = 'Document deleted successfully.'
	else if @err_message_delete = 'delete_file_failed' set @err_message_delete = 'Document deleted successfully. (Physical File delete error)'
	else if @err_message_delete = 'delete_file_not_exist' set @err_message_delete = 'Document deleted successfully. (Physical File does not exist)'
	else if @err_message_delete = '.' set @err_message_delete = 'Document deleted successfully. (No file attached)'

	EXEC spa_ErrorHandler 0, 'Appliction Notes', 
				'spa_application_notes', 'Success', 
				@err_message_delete, @err_message_delete
	
END try
begin catch
	rollback
	EXEC spa_ErrorHandler 1, 'Appliction Notes', 
				'spa_application_notes', 'DB Error', 
				'Delete document failed.', 'Delete document failed.'
end catch
ELSE IF @flag = 'g'
BEGIN
	
	declare @additional_object varchar(2000) = '', @additional_object_value varchar(5000) = ''
	-- add additional cateogry along with main category
	if @internal_type_value_id = -26
	begin
		set @additional_object = ',45'
		
		SELECT @additional_object_value = isnull(',' + STUFF(
			(SELECT distinct ','  + cast(mgs.match_group_shipment_id AS varchar)
			from match_group_shipment mgs
			where mgs.match_group_id = @notes_object_id
			FOR XML PATH(''))
		, 1, 1, ''), '')
	end
	

	if nullif(@notes_object_id,'') is not null --no email records when call from manage document main menu
	begin
		if OBJECT_ID('tempdb..##email_notes') is not null drop table ##email_notes --select * from ##email_notes
		SET @sql = '
		select isnull(sdv_cat.code, ''General'') [category],
				case en.email_type when ''o'' then ''Outgoing Email'' when ''i'' then ''Incoming Email'' else ''Email'' end [sub_category],
				en.notes_subject,

				isnull(att.attachment_file_name, en.attachment_file_name) + ''^javascript:fx_download_file("'' + isnull(att.attachment_file_path,file_path.notes_attachment) + ''")^_self'' [notes_attachment],

				cast(en.notes_object_id as varchar(500)) + '' ('' + isnull(sdv_cat.code, '''') + '')^javascript:fx_click_parent_object_id_link('' + cast(sdv_cat.value_id as varchar(10)) + '','' + cast(en.notes_object_id as varchar(500))+ '')^_self'' parent_object_id,
				sdv_user_cat.code user_category,
				dbo.FNADateFormat(en.create_ts) create_ts,
				en.create_user,
				en.attachment_file_name,
				en.notes_id,en.category_value_id [sub_category_id], ''none'' [search_criteria], sdv_cat.value_id [category_id]
				,en.notes_object_id [notes_object_id]
		into ##email_notes
		from email_notes en
		outer apply (
			select iif(charindex(replace(cs.document_path,''\'',''/''),en.notes_attachment)=0, replace(cs.document_path,''\'',''/'') + ''/'' + en.notes_attachment, en.notes_attachment) [notes_attachment]
			from connection_string cs
			where nullif(en.notes_attachment,'''') is not null
		) file_path
		outer apply (
			select top 1
				adi.attachment_file_name [attachment_file_name]
				, replace(cs.document_path,''\'',''/'') + ''/'' + adi.attachment_file_path [attachment_file_path]
			from attachment_detail_info adi 
			cross join connection_string cs
			where adi.email_id = en.notes_id
			
		) att
		left join static_data_value sdv_cat on sdv_cat.value_id = en.internal_type_value_id
		left join static_data_value sdv_sub_cat on sdv_sub_cat.value_id = en.category_value_id
		left join static_data_value sdv_user_cat on sdv_user_cat.value_id = en.user_category
		where 1=1 AND en.internal_type_value_id is not null ' + iif(ISNULL(@category_value_id, '') = 42018, ' and 1=2 ', '') + ' --do not fetch email data if documents opened from confirm status
		'
		IF @internal_type_value_id IS NOT NULL
		BEGIN
			SET @sql = @sql + ' AND en.internal_type_value_id IN ( ' + CAST(@internal_type_value_id  AS VARCHAR) + @additional_object + ')'
		END
		IF @notes_object_id IS NOT NULL
		BEGIN
			SET @sql = @sql + ' AND en.notes_object_id IN ( ' + @notes_object_id + @additional_object_value + ') '
		END 
		
		--also pick workflow related objects emails
		SET @sql += '
		union all
		select  sdv_map_obj.code [category],
				case en.email_type when ''o'' then ''Outgoing Email'' when ''i'' then ''Incoming Email'' else ''Email'' end [sub_category],
				en.notes_subject,
				isnull(att.attachment_file_name, en.attachment_file_name) + ''^javascript:fx_download_file("'' + isnull(att.attachment_file_path,file_path.notes_attachment) + ''", "'' + isnull(att.attachment_file_name, en.attachment_file_name) + ''")^_self'' [notes_attachment],

				cast(isnull(en.workflow_activity_id,en.notes_object_id) as varchar(500)) + '' ('' + isnull(case when en.workflow_activity_id is not null then ''Workflow'' else sdv_map_obj.code end, '''') + '')^javascript:fx_click_parent_object_id_link('' + cast(case when en.workflow_activity_id is not null then -1 else sdv_map_obj.value_id end as varchar(10)) + '','' + cast(isnull(en.workflow_activity_id,en.notes_object_id) as varchar(500))+ '')^_self'' [parent_object_id],

				sdv_user_cat.code user_category,
				dbo.FNADateTimeFormat(en.create_ts,1) create_ts,
				en.create_user,
				en.attachment_file_name,
				en.notes_id,en.category_value_id [sub_category_id], ''none'' [search_criteria], sdv_map_obj.value_id [category_id]
				,en.notes_object_id [notes_object_id]
		from email_notes en
		inner join workflow_activities wa on wa.workflow_activity_id = en.workflow_activity_id
		inner join workflow_event_message wea on wea.event_message_id = wa.event_message_id
		inner join event_trigger et on et.event_trigger_id = wea.event_trigger_id
		inner join module_events me on me.module_events_id = et.modules_event_id
		inner join static_data_value sdv_modules on sdv_modules.value_id = me.modules_id
		outer apply (
			select iif(charindex(replace(cs.document_path,''\'',''/''),en.notes_attachment)=0, replace(cs.document_path,''\'',''/'') + ''/'' + en.notes_attachment, en.notes_attachment) [notes_attachment]
			from connection_string cs
			where nullif(en.notes_attachment,'''') is not null
		) file_path
		outer apply (
			select top 1
				adi.attachment_file_name [attachment_file_name]
				, replace(cs.document_path,''\'',''/'') + ''/'' + adi.attachment_file_path [attachment_file_path]
			from attachment_detail_info adi 
			cross join connection_string cs
			where adi.email_id = en.notes_id
			
		) att
		left join static_data_value sdv_user_cat on sdv_user_cat.value_id = en.user_category
		inner join static_data_value sdv_map_obj on sdv_map_obj.type_id = 25
			and sdv_modules.code = sdv_map_obj.code --match module name and document category
			' + isnull('and sdv_map_obj.value_id = ' + cast(@internal_type_value_id as varchar(8)), '') + '
		where 1=1
			' + isnull('and wa.source_id in (' + @notes_object_id + ')','') + '
			' + iif(ISNULL(@category_value_id, '') = 42018, ' and 1=2 ', '') + ' --do not fetch email data if documents opened from confirm status
		'
		
		exec(@sql)
	end

	

	declare @selected_match_id varchar(100), @selected_shipping_id VARCHAR(100)
	if isnull(@internal_type_value_id, 1) = 33 --only when call from deal
	begin
		/* 
		--commented since specific fix for RWE_DE so that document grid can be loaded. Match Window is not used till now.
		--date: 2016-06-10
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
		*/

		if OBJECT_ID('tempdb..#shipping_table') is not null drop table #shipping_table
		select mgs.match_group_shipment_id, sdd.source_deal_detail_id, sdd.source_deal_header_id
		into #shipping_table
		from application_notes an
		inner join match_group mg on mg.match_group_id = an.notes_object_id
		inner join match_group_shipment mgs ON mgs.match_group_id = mg.match_group_id
		inner join match_group_header mgh on mgh.match_group_id = mg.match_group_id
		inner join match_group_detail mgd on mgd.match_group_header_id = mgh.match_group_header_id
		inner join source_deal_detail sdd on sdd.source_deal_detail_id = mgd.source_deal_detail_id
		where an.internal_type_value_id in (-26) and sdd.source_deal_header_id = isnull(@notes_object_id, -1)

		SELECT @selected_shipping_id = STUFF(
			(SELECT distinct ','  + cast(s.match_group_shipment_id AS varchar)
			from #shipping_table s
			FOR XML PATH(''))
		, 1, 1, '')
		
	end

	if isnull(@internal_type_value_id, 1) = -26 --only when call from match group
	begin
		SELECT @selected_shipping_id = STUFF(
			(SELECT distinct ','  + cast(mgs.match_group_shipment_id AS varchar)
			from match_group_shipment mgs
			WHERE mgs.match_group_id = isnull(@notes_object_id, -1)
			FOR XML PATH(''))
		, 1, 1, '')
	end
	if OBJECT_ID('tempdb..#split_table') is not null drop table #split_table
	select 
	notes_id,
	'<a href=' + @download_url +'?path=' + replace(notes_attachment, attachment_file_name, '') + item + ' download>' + item + '</a>' items
	into #split_table from application_notes
	cross apply dbo.fnasplit(attachment_file_name, ', ')
	WHERE internal_type_value_id = @internal_type_value_id AND ISNULL(category_value_id, '') = ISNULL(@category_value_id, '')

	if OBJECT_ID('tempdb..#link_table') is not null drop table #link_table
	SELECT
		notes_id,
		STUFF((SELECT ', ' + CAST(items AS VARCHAR(MAX)) [text()]
			 FROM #split_table 
			 WHERE notes_id = an.notes_id
			 FOR XML PATH(''), TYPE)
			.value('.','NVARCHAR(MAX)'),1,2,' ') List_Output
	into #link_table	
	FROM application_notes an
	WHERE internal_type_value_id = @internal_type_value_id AND ISNULL(category_value_id, '') = ISNULL(@category_value_id, '')
	GROUP BY notes_id

	SET @sql = 'select * from ( 
	SELECT ' + case when isnull(@search_result_table, '') = '-1' then ' top(0) ' else '' end + '
		isnull(sdv_cat.code, ''General'') [category],
		isnull(sdv_sub_cat.code, ''General'') [sub_category],
		an2.notes_subject,
		an2.attachment_file_name + ''^javascript:fx_download_file("'' + replace(((select document_path from connection_string) + SUBSTRING(an2.notes_attachment, CHARINDEX(''/attach_docs/'',an2.notes_attachment), LEN(an2.notes_attachment))),''\'',''/'') + ''")^_self'' [notes_attachment],
		cast(isnull(an2.parent_object_id, an2.notes_object_id) as varchar(500)) + '' ('' + isnull(sdv_cat.code, '''') + '')^javascript:fx_click_parent_object_id_link('' + cast(sdv_cat.value_id as varchar(10)) + '','' + cast(isnull(an2.parent_object_id, an2.notes_object_id) as varchar(500))+ '')^_self'' parent_object_id,
		sdv_user_cat.code user_category,
		(an2.url + ''^'' + an2.url) url,
		dbo.FNADateTimeFormat(an2.create_ts,1) create_ts,
		dbo.FNAGetUserName(an2.create_user) create_user,
		an2.attachment_file_name,
		CASE an2.notes_share_email_enable
			WHEN 0 THEN ''Disabled''
			WHEN 1 THEN ''Enabled''
		END AS notes_share_email_enable
		,an2.notes_id,an2.category_value_id [sub_category_id], ''none'' [search_criteria], sdv_cat.value_id [category_id]
		,an2.notes_object_id [notes_object_id]

	FROM application_notes an2
	' + case when isnull(@search_result_table, '-1') = '-1' then '' else 
	' inner join ' + @search_result_table + ' srt on srt.notes_id = an2.notes_id ' end + '
	left join static_data_value sdv_cat on sdv_cat.value_id = an2.internal_type_value_id
	left join static_data_value sdv_sub_cat on sdv_sub_cat.value_id = an2.category_value_id
	left join static_data_value sdv_user_cat on sdv_user_cat.value_id = an2.user_category
	WHERE 1=1 --AND ISNULL(an2.category_value_id,'''') <> 42027
	' + iif(ISNULL(@category_value_id, '') = 42018, ' and nullif(an2.workflow_process_id, '''') is null ', '') + ' --do not fetch workflow document data if documents opened from confirm status
	'
	IF @internal_type_value_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND an2.internal_type_value_id IN ( ' + CAST(@internal_type_value_id  AS VARCHAR) + ')'
	END
	IF @notes_object_id > 0
	BEGIN
		SET @sql = @sql + ' AND (CASE WHEN an2.notes_object_id IS NOT NULL THEN an2.notes_object_id ELSE '''' END = ' + CAST(@notes_object_id AS VARCHAR) + '
								OR isnull(an2.parent_object_id, -1) = ' + CAST(@notes_object_id AS VARCHAR) + '
							)'
							+ 
							case when isnull(@internal_type_value_id, -1) = 33 then '
							OR an2.notes_object_id in (' + isnull(@selected_match_id, '-1') + ')
							OR an2.notes_object_id in (' + isnull(@selected_shipping_id, '-1') + ')' 
							when isnull(@internal_type_value_id, -1) = -26 then '
							OR an2.notes_object_id in (' + isnull(@selected_shipping_id, '-1') + ')'
							else '' 
							end
	END
	IF nullif(@category_value_id, '') IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND category_value_id = ' + CAST(@category_value_id AS VARCHAR)
	END

	if nullif(@notes_object_id,'') is not null --no email records when call from manage document main menu
	begin
		SET @sql = @sql + 
		'
		union all
		select ' + case when isnull(@search_result_table, '') = '-1' then ' top(0) ' else '' end + '
				en.[category],
				en.[sub_category],
				en.notes_subject,
				en.[notes_attachment],
				en.parent_object_id,
				en.user_category,
				null url,
				en.create_ts,
				en.create_user,
				en.attachment_file_name,
				null notes_share_email_enable
				,en.notes_id,en.[sub_category_id], en.[search_criteria], en.[category_id]
				,en.[notes_object_id]
		from ##email_notes en
		' + case when isnull(@search_result_table, '-1') = '-1' then '' else 
		' inner join ' + @search_result_table + ' srt on srt.notes_id = en.notes_id ' end 
	end
	set @sql += + '
	) a
	order by case a.[sub_category] when ''Outgoing Email'' then 100 when ''Incoming Email'' then 99 when ''Email'' then 98 else 1 end, a.notes_id'
	--print(@sql)
	EXEC(@sql)
END
ELSE IF @flag = 'c'
BEGIN
	SET @sql = '
	SELECT attachment_file_name	as status, ' + @notes_object_id + '
	FROM application_notes
	WHERE internal_type_value_id = ' + CAST(@internal_type_value_id AS VARCHAR) + ' 
		AND (notes_object_id = ' + CAST(@notes_object_id AS VARCHAR) + ' OR isnull(parent_object_id, -1) = ' + CAST(@notes_object_id AS VARCHAR) + ')
		--AND ISNULL(category_value_id,'''') <> 42027
	'

	IF NULLIF(@category_value_id, '') IS NOT NULL
		SET @sql += ' AND category_value_id = ' + CAST(@category_value_id AS VARCHAR) 
	set @sql = @sql + '
	UNION ALL
	SELECT attachment_file_name, ' + @notes_object_id + '
	FROM email_notes en
	WHERE en.internal_type_value_id = ' + CAST(@internal_type_value_id AS VARCHAR) + '
		AND en.notes_object_id = ' + CAST(@notes_object_id AS VARCHAR) + '
	'
	--ELSE
	--	SET @sql += ' AND category_value_id IS NULL'

	EXEC(@sql)
END

-- For Application Notes Status Grid
ELSE IF @flag = 'x'
BEGIN
	SELECT	ans.application_notes_status_id,
			sdv.code,
			dbo.FNADateFormat(ans.status_date),
			ans.comments 
	FROM application_notes_status ans
	LEFT JOIN static_data_value sdv ON ans.status_id = sdv.value_id
	WHERE application_notes_id = @notes_id
	ORDER BY ans.status_date DESC
END

-- Add Application notes status
ELSE IF @flag = 'y'
BEGIN
	BEGIN TRY
	BEGIN TRAN 	

		INSERT INTO application_notes_status(application_notes_id,status_id,status_date,comments)
		SELECT @notes_id, @notes_status, @status_date, @comments
		
	COMMIT 
		EXEC spa_ErrorHandler 0
			, 'spa_application_notes' 
			, 'application_notes'
			, 'application_notes'
			, 'Change have been saved successfully.'
			, ''
	END TRY 
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			,'spa_application_notes' 
			, 'application_notes'
			, 'application_notes'
			, 'Failed adding template'
			, ''
		ROLLBACK 
	END CATCH
END

-- Delete Application notes status
ELSE IF @flag = 'z'
BEGIN
	BEGIN TRY
	BEGIN TRAN 	

		DELETE FROM application_notes_status WHERE application_notes_status_id = @notes_status_id
		
	COMMIT 
		EXEC spa_ErrorHandler 0
			, 'spa_application_notes' 
			, 'application_notes'
			, 'application_notes'
			, 'Change have been saved successfully.'
			, ''
	END TRY 
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			,'spa_application_notes' 
			, 'application_notes'
			, 'application_notes'
			, 'Failed adding template'
			, ''
		ROLLBACK 
	END CATCH
END