/*
create insert trigger for email_notes to store filestream data.

*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_email_notes_udpate_FS_Data]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_email_notes_udpate_FS_Data]
GO

CREATE TRIGGER [dbo].[TRGINS_email_notes_udpate_FS_Data]
ON [dbo].[email_notes]
FOR INSERT, UPDATE
AS
    IF @@ROWCOUNT = 0
        RETURN
	ELSE IF TRIGGER_NESTLEVEL() > 1
		RETURN
	ELSE IF NOT UPDATE(attachment_file_name) AND EXISTS(SELECT TOP 1 1 FROM deleted)
		RETURN

    DECLARE @sqln nvarchar(max)
    DECLARE @file_content varbinary(max)

    DECLARE @c_notes_id int,
            @c_file_name varchar(300),
            @c_file_path varchar(2000),
			@c_file_ext varchar(10)
    DECLARE db_bulk_insert_cursor CURSOR FOR
    SELECT
        i.notes_id,
        i.attachment_file_name [file_path],
		reverse(left(reverse(i.attachment_file_name),charindex('.',reverse(i.attachment_file_name))-1)) [file_ext]
    FROM inserted i
    CROSS APPLY (SELECT
        document_path
    FROM connection_string) dp
    WHERE NULLIF(i.attachment_file_name, '') IS NOT NULL

    OPEN db_bulk_insert_cursor
    FETCH NEXT FROM db_bulk_insert_cursor INTO @c_notes_id, @c_file_path, @c_file_ext

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (dbo.FNAFileExists(@c_file_path) = 1)
		BEGIN
			SET @sqln = '
				select @file_content = x.bulkcolumn from openrowset(bulk ''' + replace(@c_file_path, '/', '\') + ''', SINGLE_BLOB) AS x
			'
			EXEC sp_executesql @sqln,
                           N'@file_content varbinary(max) OUTPUT',
                           @file_content OUT
		END
		
		declare @final_file_name varchar(1000) = null, @final_file_part_location varchar(1000) = null
	
		if OBJECT_ID('tempdb..#file_parts') is not null
			drop table #file_parts
		select l.item , IDENTITY(int, 1, 1) rid
		into #file_parts
		from dbo.FNASplit(replace(@c_file_path,'/','\'), '\') l

		select top 1 @final_file_name = fp.item
		--select *
		from #file_parts fp
		order by rid desc

		select @final_file_part_location = STUFF(
			(SELECT '/'  + fp.item
			from #file_parts fp
			where fp.rid > (select rid from #file_parts where item like 'shared_docs%')
			FOR XML PATH(''))
		, 1, 1, '')
		
	

        UPDATE email_notes
        SET type_column_name = @c_file_ext, FS_Data = @file_content
			, notes_attachment = @final_file_part_location
			, attachment_file_name = @final_file_name

        WHERE notes_id = @c_notes_id

		
        FETCH NEXT FROM db_bulk_insert_cursor INTO @c_notes_id, @c_file_path, @c_file_ext
    END

    CLOSE db_bulk_insert_cursor;
    DEALLOCATE db_bulk_insert_cursor;

	--update values of email notes for blank and non-numeric
	UPDATE en
    SET en.attachment_file_name = NULLIF(en.attachment_file_name, '')
		, en.email_type = ISNULL(NULLIF(en.email_type, ''), 'o')
		, en.notes_object_id = IIF(ISNUMERIC(en.notes_object_id) = 0, NULL, en.notes_object_id)
	FROM email_notes en
	INNER JOIN inserted i ON i.notes_id = en.notes_id


GO