IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_attachment_detail_info]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_attachment_detail_info]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_attachment_detail_info]
	@flag CHAR(1) = 0,
	@attachment_detail_info_id varchar(1000) = null,
	@document_id varchar(1000) = null,
	@email_id varchar(1000) = null,
	@attachment_file_name varchar(2000) = null,
	@attachment_file_path varchar(5000) = null,
	@attachment_file_size int = null,
	@FS_Data varbinary(max) = null
	
AS
set nocount on

/*
declare @flag CHAR(1) = 0,
	@flag CHAR(1) = 0,
	@attachment_detail_info_id varchar(1000) = null,
	@document_id varchar(1000) = null,
	@email_id varchar(1000) = null,
	@attachment_file_name varchar(2000) = null,
	@attachment_file_path varchar(5000) = null

select @flag='g',@internal_type_value_id=NULL,@category_value_id='',@notes_object_id='0'

--*/
begin try
	begin tran
	if @flag = 'i'
	begin
		declare @attachment_file_ext varchar(10) = null


		if OBJECT_ID('tempdb..#file_parts') is not null
			drop table #file_parts
		select l.item , IDENTITY(int, 1, 1) rid
		into #file_parts
		from dbo.FNASplit(replace(@attachment_file_path,'/','\'), '\') l

		if nullif(@attachment_file_name,'') is null
		begin
			select top 1 @attachment_file_name = fp.item
			--select *
			from #file_parts fp
			order by rid desc
		end

		

		--declare @final_file_part_location varchar(1000) = null
		select @attachment_file_path = STUFF(
			(SELECT '/'  + fp.item
			from #file_parts fp
			where fp.rid > (select rid from #file_parts where item like 'shared_docs%')
			FOR XML PATH(''))
		, 1, 1, '')

		set @attachment_file_ext = reverse(left(reverse(@attachment_file_name),charindex('.',reverse(@attachment_file_name))-1))


		INSERT INTO attachment_detail_info (attachment_file_name, attachment_file_path, attachment_file_ext, attachment_file_size, email_id, FS_Data)
		values(@attachment_file_name, @attachment_file_path, @attachment_file_ext, @attachment_file_size, @email_id, @FS_Data)

		EXEC spa_ErrorHandler 1
		, 'spa_attachment_detail_info' 
		, 'Success'
		, 'Attachment Detail Info'
		, 'Data saved successfully.'
		, ''
	end
	else if @flag = 'a'
	begin
		select adi.attachment_detail_info_id, adi.email_id
			, adi.attachment_file_name [attachment_file_name]
			, cast(CEILING(adi.attachment_file_size/1024.0) as varchar(10)) + ' KB' [attachment_file_size]
			, replace(cs.document_path,'\','/') + '/' + adi.attachment_file_path [attachment_file_path]
		from attachment_detail_info adi
		cross join connection_string cs
		where adi.email_id = @email_id
		union all
		select null, en.notes_id, en.attachment_file_name, null, replace(cs.document_path,'\','/') + '/' +en.notes_attachment
		from email_notes en
		cross join connection_string cs
		where en.notes_id = @email_id and en.attachment_file_name is not null
	end

	commit
end try
begin catch
	rollback
	declare @err_msg varchar(5000) = error_message()
	EXEC spa_ErrorHandler 0
	, 'spa_attachment_detail_info' 
	, 'Error'
	, 'Attachment Detail Info'
	, @err_msg
	, ''
end catch
