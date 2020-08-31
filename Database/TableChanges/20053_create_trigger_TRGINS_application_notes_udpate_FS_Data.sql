/*
create insert trigger for applciation_notes to store filestream data from single place since documents are inserted on application notes from different areas.

*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_application_notes_udpate_FS_Data]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_application_notes_udpate_FS_Data]
GO

CREATE TRIGGER [dbo].[TRGINS_application_notes_udpate_FS_Data]
ON [dbo].[application_notes]
FOR INSERT, UPDATE
AS
    IF @@ROWCOUNT = 0
        RETURN
	ELSE IF TRIGGER_NESTLEVEL() > 1
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
        i.attachment_file_name,
        dp.document_path + '\attach_docs\' + attachment_folder + '\' + attachment_file_name [file_path],
		reverse(left(reverse(i.attachment_file_name),charindex('.',reverse(i.attachment_file_name))-1)) [file_ext]
    FROM inserted i
    CROSS APPLY (SELECT
        document_path
    FROM connection_string) dp
    WHERE NULLIF(i.attachment_file_name, '') IS NOT NULL

    OPEN db_bulk_insert_cursor
    FETCH NEXT FROM db_bulk_insert_cursor INTO @c_notes_id, @c_file_name, @c_file_path, @c_file_ext

    WHILE @@FETCH_STATUS = 0
    BEGIN
		IF (dbo.FNAFileExists(@c_file_path) = 1)
		BEGIN
			SET @sqln = '
				select @file_content = x.bulkcolumn from openrowset(bulk ''' + @c_file_path + ''', SINGLE_BLOB) AS x
			'
			EXEC sp_executesql @sqln,
							   N'@file_content varbinary(max) OUTPUT',
							   @file_content OUT
		END
        UPDATE application_notes
        SET type_column_name = @c_file_ext, FS_Data = @file_content, notes_attachment = REPLACE(@c_file_path, '\', '/')
        WHERE notes_id = @c_notes_id

        FETCH NEXT FROM db_bulk_insert_cursor INTO @c_notes_id, @c_file_name, @c_file_path, @c_file_ext
    END

    CLOSE db_bulk_insert_cursor;
    DEALLOCATE db_bulk_insert_cursor;


GO