IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_manage_email]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_manage_email]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_manage_email]
	@flag CHAR(1) = NULL,
	@email_type char(1) = null,
	@view_mapped char(1) = null,
	@search_result_table varchar(200) = null,
	@notes_id varchar(5000) = null,
	@internal_type_value_id varchar(200) = null,
	@notes_object_id varchar(200) = null,
	@category_value_id varchar(200) = null,
	@domain varchar(100) = null,
	@email_subject varchar(max) = null,
	@parse_pattern varchar(10) = null,
	@silent int = 0,
	@email_body varchar(max) = null
	
AS
SET NOCOUNT ON

/*
declare @flag CHAR(1) = NULL,
	@email_type char(1) = null,
	@view_mapped char(1) = null,
	@search_result_table varchar(200) = null,
	@notes_id varchar(5000) = null,
	@internal_type_value_id varchar(200) = null,
	@notes_object_id varchar(200) = null,
	@category_value_id varchar(200) = null,
	@domain varchar(100) = null,
	@email_subject varchar(max) = null,
	@parse_pattern varchar(10) = null,
	@silent int = 0,
	@email_body varchar(max) = null
	

select @flag='r', @search_result_table='adiha_process.dbo.email_notes_farrms_admin_449807C3_1CFE_4721_873F_F14AE43C6563'

--*/
SET NOCOUNT ON
BEGIN TRY
	--if object_id('adiha_process.dbo.spa_manage_email_parameters_999') is not null
	--begin
	--	insert into adiha_process.dbo.spa_manage_email_parameters_999
	--	select 
	--	@flag flag,
	--	@email_type email_type,
	--	@view_mapped view_mapped,
	--	@search_result_table search_result_table,
	--	@notes_id notes_id,
	--	@internal_type_value_id internal_type_value_id,
	--	@notes_object_id notes_object_id,
	--	@category_value_id category_value_id,
	--	@domain domain,
	--	@email_subject email_subject,
	--	@parse_pattern parse_pattern,
	--	@silent silent,
	--	@email_body email_body,
	--	getdate() log_date,
	--	null [extra_message]
		
	--end
	--else 
	--begin
	--	select 
	--	@flag flag,
	--	@email_type email_type,
	--	@view_mapped view_mapped,
	--	@search_result_table search_result_table,
	--	@notes_id notes_id,
	--	@internal_type_value_id internal_type_value_id,
	--	@notes_object_id notes_object_id,
	--	@category_value_id category_value_id,
	--	@domain domain,
	--	@email_subject email_subject,
	--	@parse_pattern parse_pattern,
	--	@silent silent,
	--	@email_body email_body,
	--	getdate() log_date,
	--	null [extra_message]
	--	into adiha_process.dbo.spa_manage_email_parameters_999
	--end

	--begin tran --remove tran since this hangs the process when workflow approval gets some error
	set @silent = ISNULL(nullif(@silent,''),0)
	declare @result_nvar nvarchar(max) = null
	declare @shared_document_path varchar(1000) = null
	select @shared_document_path = cs.document_path
	from connection_string cs




	--explicit set
	--set @shared_document_path = '\\PSDL13\shared_docs_TRMTracker_Branch1'

	declare @sql varchar(max)
	declare @error_message varchar(300)

	
	IF @flag = 'l'
	BEGIN
		if OBJECT_ID(N'tempdb..#tmp_result') is not null drop table #tmp_result
		select distinct case en.email_type when 'i' then 'Incoming' when 'o' then 'Outgoing' when 'f' then 'Failed' else 'Outgoing' end [folder_name]
			, case en.email_type when 'o' then  SUBSTRING(en.send_to,charindex('@',en.send_to,0) + 1,
case when charindex(';',en.send_to,0) = 0 then len(en.send_to) else charindex(';',en.send_to,0) - charindex('@',en.send_to,0) -1 end) else SUBSTRING(en.send_from,charindex('@',en.send_from,0) + 1,len(en.send_from)) end [domain]
			, en.email_type
		into #tmp_result
		from email_notes en
		
		select * from (
			select * from #tmp_result
			union all select 'Incoming', NULL, 'i' from seq s where s.n = 1 and not exists(select top 1 1 from #tmp_result where folder_name = 'Incoming')
			union all select 'Outgoing', NULL, 'o' from seq s where s.n = 1 and not exists(select top 1 1 from #tmp_result where folder_name = 'Outgoing')
			union all select 'Failed', NULL, 'f' from seq s where s.n = 1 and not exists(select top 1 1 from #tmp_result where folder_name = 'Failed')
		) a
		order by case a.email_type when 'i' then 1 when 'o' then 2 when 'f' then 3 else 100 end
		
		--select * from #tmp_result
		
	END 
	ELSE IF @flag = 'r' --load grid and search result load grid
	BEGIN
		set @sql = '
		select ' + case when @search_result_table is not null and @search_result_table = '-1' then ' top(0) ' else '' end + '
		en.notes_id, dbo.FNAEmailHyperlink(en.send_from) [send_from], dbo.FNAEmailHyperlink(en.send_to) [send_to], en.notes_subject [subject], dbo.FNADateTimeFormat(en.create_ts,1) [date]
		
		, ''<span class="attachment_list_link" onclick=fx_open_attachment_list('' + cast(en.notes_id as varchar(10)) + '',this) > '' + cast(case when att.attachment_count is null and en.attachment_file_name is not null then 1 else att.attachment_count end as varchar(5)) + '' File(s) </span>^javascript:void(0)^_self'' 
		  [attachment]

		, sdv_user_cat.code user_category, CASE WHEN en.email_type = ''o'' THEN ''Outgoing'' ELSE ''Incoming'' END email_type
		
		--, cast(isnull(en.workflow_activity_id,en.notes_object_id) as varchar(500)) + '' ('' + isnull(case when en.workflow_activity_id is not null then ''Workflow'' else sdv_map_obj.code end, '''') + '')^javascript:fx_click_parent_object_id_link('' + cast(case when en.workflow_activity_id is not null then -1 else sdv_map_obj.value_id end as varchar(10)) + '',&quot;'' + cast(isnull(en.workflow_activity_id,en.notes_object_id) as varchar(500))+ ''&quot;)^_self'' [mapped_object]
		
		,case 
			when en.workflow_activity_id is not null then
				cast(ltrim(rtrim(wa.source_id)) as varchar(10)) + '' (Workflow '' +  sdv_wf_obj.code + '')^javascript:fx_click_parent_object_id_link('' + cast(sdv_wf_obj.value_id as varchar(10)) + '',&quot;'' + cast(ltrim(rtrim(wa.source_id)) as varchar(10))+ ''&quot;)^_self'' 
			else 
				cast(isnull(en.workflow_activity_id,en.notes_object_id) as varchar(500)) + '' ('' + isnull(case when en.workflow_activity_id is not null then ''Workflow'' else sdv_map_obj.code end, '''') + '')^javascript:fx_click_parent_object_id_link('' + cast(case when en.workflow_activity_id is not null then -1 else sdv_map_obj.value_id end as varchar(10)) + '',&quot;'' + cast(isnull(en.workflow_activity_id,en.notes_object_id) as varchar(500))+ ''&quot;)^_self'' 
		  end
		  [mapped_object]
		, dbo.FNADateTimeFormat(en.update_ts,1) [update_ts]
		
		, CASE WHEN en.email_type = ''o'' THEN ''<span style="color:#4153ab">N/A</span>'' WHEN import_completed = ''n'' THEN ''<span style="color:red">No</span>'' WHEN import_completed = ''y'' THEN ''<span style="color:#078a60">Yes</span>'' ELSE ''<span style="color:#4153ab">N/A</span>'' END import_completed
		from email_notes en
		' + case when @search_result_table is null or @search_result_table = '-1' then '' else 
			' inner join ' + @search_result_table + ' srt on srt.notes_id = en.notes_id ' 
			end + '
		left join static_data_value sdv_map_obj on sdv_map_obj.value_id = isnull(en.internal_type_value_id, sdv_map_obj.value_id + 1) and sdv_map_obj.type_id = 25
		left join static_data_value sdv_user_cat on sdv_user_cat.value_id = en.user_category
		left join workflow_activities wa on wa.workflow_activity_id = en.workflow_activity_id
		left join static_data_value sdv_wf_obj 
			on ltrim(rtrim(sdv_wf_obj.code)) = case ltrim(rtrim(wa.source_column)) 
				when ''source_deal_header_id'' then ''Deal''
				when ''source_counterparty_id'' then ''Counterparty''
				when ''counterparty_id'' then ''Counterparty''
				when ''contract_id'' then ''Contract''
			end
			and sdv_wf_obj.type_id = 25
		outer apply (
			--select SUBSTRING(adi.attachment_file_name,charindex(''_-_'',adi.attachment_file_name)+3,len(adi.attachment_file_name)) [attachment_file_name]
			select count(*) [attachment_count], MIN(ISNULL(is_imported,''n'')) [import_completed]
			from attachment_detail_info adi 
			where adi.email_id = en.notes_id
			having count(*) > 0
		) att
		where 1=1 '
		+	case	when @email_type is not null then ' and en.email_type =''' + @email_type + '''' else '' end
		+	case	when @view_mapped is not null and @view_mapped = 'm' then ' and (en.internal_type_value_id is not null or en.workflow_activity_id is not null)'
					when @view_mapped is not null and @view_mapped = 'u' then ' and (en.internal_type_value_id is null and en.workflow_activity_id is null)'
					else '' 
			end
		+	case	when @domain is not null then ' and case en.email_type when ''o'' then  SUBSTRING(en.send_to,charindex(''@'',en.send_to,0) + 1,
case when charindex('';'',en.send_to,0) = 0 then len(en.send_to) else charindex('';'',en.send_to,0) - charindex(''@'',en.send_to,0) -1 end) else SUBSTRING(en.send_from,charindex(''@'',en.send_from,0) + 1,len(en.send_from)) end = ''' + @domain + '''' else ''
			end
		+ ' order by en.notes_id desc'
		--print(@sql)
		exec(@sql)
			   

	END 
	ELSE IF @flag = 'x' --final select for search should match exact number of columns and column names as on flag 'g' on spa_email_notes that loads the grid
	BEGIN
	
		set @sql = '
		SELECT ' + case when @search_result_table = '-1' then ' top(0) ' else '' end + '
			case en.email_type when ''o'' then ''Outgoing'' else ''Incoming'' end [email_type],
			isnull(sdv_cat.code, ''General'') [category],
			isnull(sdv_sub_cat.code, ''General'') [sub_category],
			en.notes_subject,
			en.attachment_file_name + ''^javascript:fx_download_file("'' + en.notes_attachment + ''")^_self'' [notes_attachment],
			case en.send_status when ''y'' then ''Sent'' else ''Not Sent'' end email_status,
			null user_category,
			null url,
			dbo.FNADateFormat(en.create_ts) create_ts,
			en.create_user,
			en.attachment_file_name,
			null notes_share_email_enable
			,en.notes_id,en.category_value_id [sub_category_id], ''none'' [search_criteria], sdv_cat.value_id [category_id]
			,en.notes_object_id [notes_object_id]
		FROM email_notes en
		' + case when @search_result_table = '-1' then '' else 
		' inner join ' + @search_result_table + ' srt on srt.notes_id = en.notes_id ' end + '
		left join static_data_value sdv_cat on sdv_cat.value_id = en.internal_type_value_id
		left join static_data_value sdv_sub_cat on sdv_sub_cat.value_id = en.category_value_id
		order by notes_id
		'
		exec(@sql)
	
	END
	ELSE IF @flag = 'm'
	BEGIN
		set @error_message = 'Email map failed.'
		
		update en 
		set en.internal_type_value_id = @internal_type_value_id
			, notes_object_id = @notes_object_id
		from email_notes en
		inner join dbo.SplitCommaSeperatedValues(@notes_id) scsv on scsv.item = en.notes_id
		
		if @silent <> 1
			EXEC spa_ErrorHandler 0, 'Manage Email', 'spa_manage_email', 'Success', 'Email mapped successfully.', ''

	END
	ELSE IF @flag = 'n'
	BEGIN
		set @error_message = 'Email unmap failed.'

		update en 
		set en.internal_type_value_id = null
			, notes_object_id = null
		from email_notes en
		inner join dbo.SplitCommaSeperatedValues(@notes_id) scsv on scsv.item = en.notes_id
		
		EXEC spa_ErrorHandler 0, 'Manage Email', 'spa_manage_email', 'Success', 'Email unmapped successfully.', ''

	END
	else if @flag = 'd'
	begin
		set @error_message = 'Email delete failed.'
		
		/** DELETE EMAIL START **/
		declare @c_notes_id int = null
		declare @c_email_type char(1) = null
		declare @c_process_id varchar(200) = null
		declare @err_message_delete varchar(300) = '.'

		IF (SELECT CURSOR_STATUS('local','cur_delete_inbox')) >= -1
		BEGIN
			IF (SELECT CURSOR_STATUS('local','cur_delete_inbox')) > -1
			BEGIN
				CLOSE cur_delete_inbox
			END
			DEALLOCATE cur_delete_inbox
		END

		declare cur_delete_inbox cursor local 
		for
		select en.notes_id, en.email_type, en.process_id
		from email_notes en
		inner join dbo.SplitCommaSeperatedValues(@notes_id) scsv on scsv.item = en.notes_id
		where isnull(en.email_type, 'o') = 'i'

		open cur_delete_inbox
		fetch next from cur_delete_inbox into @c_notes_id, @c_email_type, @c_process_id
		while @@FETCH_STATUS = 0
		begin

			declare @email_file varchar(5000) = null
			declare @message_id varchar(200) = @c_process_id

			select @email_file = fi.[filename]
			from dbo.FNAListFiles(@shared_document_path + '\attach_docs\inbox\', '*.eml', 'n') fi 
			where fi.[filename] like '%' + @c_process_id + '%' 

			if (dbo.FNAFileExists(@email_file) = 1)
			begin
				EXEC spa_delete_file @email_file, @result_nvar OUTPUT
			end
			
			-- delete from mail server
			--commented as per discussion we do not delete actual mails for now
			/*
			declare @imap_email_address varchar(100) = null
			declare @imap_email_password varchar(500) = null
			declare @imap_server_host varchar(100) = null
			declare @imap_server_port int = null
			declare @imap_require_ssl bit = 1

			select @imap_email_address = cs.imap_email_address
				, @imap_email_password = dbo.FNADecrypt(cs.imap_email_password)
				, @imap_server_host = cs.imap_server_host
				, @imap_server_port = cs.imap_server_port
				, @imap_require_ssl = cs.imap_require_ssl

			from connection_string cs
			
			exec spa_dump_incoming_email_clr 
				@email_id=@imap_email_address
				, @email_pwd=@imap_email_password
				, @email_host=@imap_server_host
				, @email_port=@imap_server_port
				, @document_path=@shared_document_path
				, @email_require_ssl=@imap_require_ssl
				, @message_id=@c_process_id
				, @flag='d'
				, @output_result=@result_nvar output
			*/


			/** DELETE EMAIL ATTACHMENTS START **/
			declare @c1_att_file_path varchar(5000) = null
			IF (SELECT CURSOR_STATUS('local','cur_delete_att')) >= -1
			BEGIN
				IF (SELECT CURSOR_STATUS('local','cur_delete_att')) > -1
				BEGIN
					CLOSE cur_delete_att
				END
				DEALLOCATE cur_delete_att
			END

			declare cur_delete_att cursor local 
			for
			select @shared_document_path + '\' + replace(adi.attachment_file_path, '/', '\') attachment_file_path
			from attachment_detail_info adi
			where adi.email_id = @c_notes_id

			open cur_delete_att
			fetch next from cur_delete_att into @c1_att_file_path
			while @@FETCH_STATUS = 0
			begin
				if (dbo.FNAFileExists(@c1_att_file_path) = 1)
				begin
					EXEC spa_delete_file @c1_att_file_path, @result_nvar OUTPUT
				end
				fetch next from cur_delete_att into @c1_att_file_path
			end
			close cur_delete_att
			deallocate cur_delete_att

			/** DELETE EMAIL ATTACHMENTS END **/
			
			fetch next from cur_delete_inbox into @c_notes_id, @c_email_type, @c_process_id
		end
		close cur_delete_inbox
		deallocate cur_delete_inbox

		/** DELETE EMAIL END **/


		SET @sql = 'DELETE email_notes WHERE notes_id in (' + @notes_id + ')';
		EXEC(@sql)
	
		EXEC spa_ErrorHandler 0, 'Email Notes', 
					'spa_manage_email', 'Success', 
					'Data deleted successfully.', ''

	end
	ELSE IF @flag ='a' 
	BEGIN
		SELECT 
			notes_id
			,internal_type_value_id
			,notes_object_id
			,notes_subject
			--col notes_text has both encoded and raw strings so encode only the raw texts searching with '<' char
			,iif(charindex('<',notes_text)=0,replace(replace(notes_text,char(10),'\n'),char(13),'\n'),replace(replace(dbo.FNAEncodeXML(notes_text),char(10),'\n'),char(13),'\n')) [notes_text]
			,ISNULL(att.attachment_file_path,en.notes_attachment) [notes_attachment]
			,ISNULL(att.attachment_file_name,en.attachment_file_name) [attachment_file_name]
			,user_category
			,category_value_id
			,send_from
			,send_to
			,send_cc
			,send_bcc
			,send_status
			,active_flag
			,sys_users
			,admin_email_configuration_id
			,non_sys_users
		FROM email_notes en
		outer apply (
			select top 1
				adi.attachment_file_name [attachment_file_name]
				, adi.attachment_file_path [attachment_file_path]
			from attachment_detail_info adi 
			cross join connection_string cs
			where adi.email_id = en.notes_id
		) att
		WHERE notes_id=@notes_id	

	
	END
	else IF @flag = 'v' AND @notes_id IS NOT NULL
	BEGIN
		DECLARE @sys_users VARCHAR(200)
		SELECT @sys_users = REPLACE(
		           REPLACE(RTRIM(LTRIM('''' + sys_users + '''')), ',', ''','''),
		           ' ',
		           ''
		       )
		FROM   email_notes
		WHERE  notes_id = @notes_id
		
		SET @sql = 
			'SELECT 
				user_login_id,
				user_f_name + '' '' + ISNULL(user_m_name + '' '', '''') + user_l_name
			FROM application_users
		    WHERE user_login_id IN (' + @sys_users + ')'
				
		EXEC (@sql)
	END
	else IF @flag = 'p' --parse email subject to trigger mapping and workflow
	BEGIN
		declare @pattern_start varchar(5) = '[#', @pattern_end varchar(5) = '#]', @seperator char(1) = ':'
		
		declare @pattern_content varchar(2000) = SUBSTRING(@email_subject, charindex(@pattern_start, @email_subject),charindex(@pattern_end, @email_subject)+2-charindex(@pattern_start, @email_subject))
		
		set @pattern_content = ltrim(rtrim(replace(replace(@pattern_content, @pattern_start, ''), @pattern_end, '')))
		
		declare @object varchar(100) = ltrim(rtrim(left(@pattern_content,charindex(@seperator, @pattern_content)-1)))
		
		declare @object_value varchar(1000) = ltrim(rtrim(right(@pattern_content,len(@pattern_content)-charindex(@seperator,@pattern_content))))

		
		
		if @object = 'workflow'
		begin
			--trigger workflow taking @object_value
			declare @workflow_id int = substring(@object_value, 0, charindex('|', @object_value))
			declare @workflow_approve int = substring(@object_value, charindex('|', @object_value)+1, len(@object_value))
			
			--map workflow email with activity id
			if exists(select top 1 1 from workflow_activities where workflow_activity_id = @workflow_id)
			begin
				update email_notes
				set workflow_activity_id = @workflow_id
				where notes_id = @notes_id
			end

			declare @email_user_from varchar(200)
			
			select @email_user_from = au.user_login_id
			from email_notes en 
			inner join application_users au on au.user_emal_add = en.send_from
			where en.notes_id = @notes_id

			IF @email_user_from IS NULL
			BEGIN
				SELECT @email_user_from = en.create_user
				FROM email_notes en 
				INNER JOIN application_users au 
					ON au.user_login_id = en.create_user
				where en.notes_id = @notes_id

				SET @email_user_from = ISNULL(@email_user_from, 'farrms_admin')
			END

			--select '@flag'='c',' @activity_id'=@workflow_id, '@approved'=@workflow_approve, '@comments'='', '@approved_by'=@email_user_from, '@call_from'='email_parse'

			--SET CONTEXT INFO AS DBUSER IS USED TO STORE USER (APPROVED BY) INFO
			DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), @email_user_from)
			SET CONTEXT_INFO @contextinfo
			EXEC spa_setup_rule_workflow  @flag='c', @activity_id=@workflow_id, @approved=@workflow_approve, @comments='', @approved_by=@email_user_from, @call_from='email_parse'
			
		end
		else 
		begin
			declare @object_id int = null
			declare @object_folder_name varchar(500) = ''

			if @object = 'deal' 
			begin
				set @object_id = 33
				set @object_folder_name = 'Deal'
				
				select @object_value = (select sdh.source_deal_header_id
				from source_deal_header sdh
				where sdh.deal_id = @object_value or cast(sdh.source_deal_header_id as varchar(1000)) = @object_value)
			end 
			else if @object = 'counterparty' 
			begin
				set @object_id = 37
				set @object_folder_name = 'Counterparty'
				
				select @object_value = (select sc.source_counterparty_id
				from source_counterparty sc
				where sc.counterparty_id = @object_value or cast(sc.source_counterparty_id as varchar(1000)) = @object_value)
			end 
			else if @object = 'contract' 
			begin
				set @object_id = 40
				set @object_folder_name = 'Contract'
				
				select @object_value = (select cg.contract_id
				from contract_group cg
				where cg.source_contract_id = @object_value or cast(cg.contract_id as varchar(1000)) = @object_value)
			end
			else if @object = 'shipment' 
			begin
				set @object_id = 45
				set @object_folder_name = 'Shipment'
				
				select @object_value = (select mgs.match_group_shipment_id
				from match_group_shipment mgs
				where mgs.match_group_shipment = @object_value or cast(mgs.match_group_shipment_id as varchar(1000)) = @object_value)
			end
			else 
			begin
				set @object = null
			end
			
			if @object_id is null or @object_value is null
			begin
				set @error_message = 'Invalid object'
				raiserror(@error_message, 16, 1)
			end
			
			--map email to corresponding object with object value
			exec spa_manage_email @flag = 'm', @notes_id = @notes_id, @internal_type_value_id = @object_id, @notes_object_id = @object_value, @silent=1
			
			if exists(select top 1 1 from attachment_detail_info where email_id = @notes_id)
			begin
				
				declare @att_files varchar(5000)

				SELECT @att_files = STUFF(
					(SELECT ','  + adi.attachment_file_path
					from attachment_detail_info adi
					where adi.email_id = @notes_id
					FOR XML PATH(''))
				, 1, 1, '')

				
				IF (SELECT CURSOR_STATUS('local','cur_att')) >= -1
				BEGIN
					IF (SELECT CURSOR_STATUS('local','cur_att')) > -1
					BEGIN
						CLOSE cur_att
					END
					DEALLOCATE cur_att
				END
				declare @c_att_file_path varchar(5000),@c_att_file_name varchar(5000)

				

				declare cur_att cursor local
				for
				select replace(@shared_document_path + '\' + adi.attachment_file_path, '/', '\') attachment_file_path
					, adi.attachment_file_name
				from attachment_detail_info adi
				where adi.email_id = @notes_id
				
				open cur_att
				fetch next from cur_att into @c_att_file_path, @c_att_file_name

				while @@FETCH_STATUS = 0
				begin
					
					--source file existence check
					if(dbo.FNAFileExists(@c_att_file_path) = 0)
					begin
						set @error_message = 'Attachment file (' + @c_att_file_path + ') does not exist.'
						raiserror(@error_message, 16, 1)
					end
	
					
					--declare @renamed_file_name varchar(500) = SUBSTRING(@c_att_file_path,charindex('_-_',@c_att_file_path)+3,len(@c_att_file_path))

					declare @copy_dest_path varchar(5000) = @shared_document_path + '\attach_docs\' + @object_folder_name + '\' + @c_att_file_name

					declare @dest_folder varchar(5000) = @shared_document_path + '\attach_docs\' + @object_folder_name
									

					--destination folder check
					if(dbo.FNACheckWriteAccessToFolder(@dest_folder) <> 1)
					begin
						if(dbo.FNACheckWriteAccessToFolder(@dest_folder) = -1)
						begin
							
							exec spa_create_folder @folder_path=@dest_folder,@result=@result_nvar output
							if(@result_nvar <> '1')
							begin
								set @error_message = 'Destination Folder (' + @shared_document_path + '\attach_docs\' + @object_folder_name + ') could not be created.'
								raiserror(@error_message, 16, 1)
							end
						end
						else 
						begin
							set @error_message = 'Destination Folder (' + @shared_document_path + '\attach_docs\' + @object_folder_name + ') is not accesible.'
							raiserror(@error_message, 16, 1)
						end
						
					end	

					-- if file exists on destination folder, delete the file
					if(dbo.FNAFileExists(@copy_dest_path) = 1)
					begin
						exec spa_delete_file @filename=@copy_dest_path,@result=@result_nvar output
						if(@result_nvar <> '1')
						begin
							set @error_message = 'File already exists and could not be deleted.'
							raiserror(@error_message, 16, 1)
						end
					end


					
					-- copy the file to respective folder
					exec spa_copy_file @source_file=@c_att_file_path, @destination_file=@copy_dest_path,@result=@result_nvar output
					if(@result_nvar <> '1')
					begin
						set @error_message = 'File copy to destination folder failed.'
						raiserror(@error_message, 16, 1)
					end
					
					-- insert attachments as documents for related object values
					exec spa_post_template @flag='i'
						,@internal_type_value_id=@object_id
						,@notes_object_id=@object_value
						,@notes_subject=@email_subject
						,@notes_text=@email_body
						,@doc_file_unique_name=@c_att_file_name
						--,@doc_file_name=@copy_dest_path
						,@notes_share_email_enable=0
					
					fetch next from cur_att into @c_att_file_path, @c_att_file_name
				end
				
				CLOSE cur_att
				DEALLOCATE cur_att
			end
			
		end
		
	END

	--commit
END TRY
BEGIN CATCH
	--if @@TRANCOUNT > 0
	--rollback
	declare @catch_err varchar(max) = ERROR_MESSAGE()
	EXEC spa_ErrorHandler 1, 'Email Notes', 'spa_manage_email', 'Failed', @catch_err, @notes_id
	--PRINT ERROR_MESSAGE()
END CATCH
GO
