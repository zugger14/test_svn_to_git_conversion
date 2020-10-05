SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[TRGINS_email_notes_udpate_FS_Data]
ON [dbo].[email_notes]
FOR INSERT, UPDATE
AS
    IF @@ROWCOUNT = 0
        RETURN
	ELSE IF TRIGGER_NESTLEVEL() > 1
		RETURN
	ELSE IF NOT UPDATE(attachment_file_name) AND EXISTS(SELECT TOP 1 1 FROM deleted)
		RETURN
  
DECLARE @sqln NVARCHAR(MAX)
DECLARE @file_content VARBINARY(MAX)

DECLARE @c_notes_id INT,
        @c_file_name VARCHAR(300),
        @c_file_path VARCHAR(2000),
		@c_file_ext VARCHAR(10)
DECLARE db_bulk_insert_cursor CURSOR FOR
SELECT
    i.notes_id,
    i.attachment_file_name [file_path],
	REVERSE(LEFT(REVERSE(i.attachment_file_name),CHARINDEX('.',REVERSE(i.attachment_file_name))-1)) [file_ext]
FROM inserted i
CROSS APPLY (SELECT
    document_path
FROM connection_string) dp
WHERE NULLIF(i.attachment_file_name, '') IS NOT NULL

OPEN db_bulk_insert_cursor
FETCH NEXT FROM db_bulk_insert_cursor INTO @c_notes_id, @c_file_path, @c_file_ext

WHILE @@FETCH_STATUS = 0
BEGIN

	/* Email file */
	DECLARE @file_names VARCHAR(MAX)
	DECLARE file_name_cur CURSOR FOR
	SELECT
		item
	FROM [dbo].SplitCommaSeperatedValues(@c_file_path)
	OPEN file_name_cur
	FETCH NEXT FROM file_name_cur INTO @file_names
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--SELECT @file_names
		--SELECT dbo.FNAFileExists(@file_names)

		IF (dbo.FNAFileExists(@file_names) = 1)
		BEGIN
			SET @sqln = '
				select @file_content = x.bulkcolumn from openrowset(bulk ''' + replace(@file_names, '/', '\') + ''', SINGLE_BLOB) AS x
			'
			EXEC sp_executesql @sqln,
							N'@file_content varbinary(max) OUTPUT',
							@file_content OUT
		END
		
		DECLARE @final_file_name VARCHAR(1000) = NULL, @final_file_part_location VARCHAR(1000) = NULL
	
		IF OBJECT_ID('tempdb..#file_parts') IS NOT NULL
			DROP TABLE #file_parts
		SELECT l.item , IDENTITY(INT, 1, 1) rid
		INTO #file_parts
		FROM dbo.FNASplit(REPLACE(@file_names,'/','\'), '\') l


		SELECT TOP 1 @final_file_name = fp.item
		--select *
		FROM #file_parts fp
		ORDER BY rid DESC

		SELECT @final_file_part_location = STUFF(
			(SELECT '/'  + fp.item
			FROM #file_parts fp
			WHERE fp.rid > (SELECT rid FROM #file_parts WHERE item LIKE 'shared_docs%')
			FOR XML PATH(''))
		, 1, 1, '')
		
		INSERT INTO attachment_detail_info (
			document_id
			,email_id
			,attachment_file_name
			,attachment_file_path
			,FS_Data
			,UI
			,attachment_file_ext
			,attachment_file_size
		) 
		SELECT NULL, @c_notes_id, @final_file_name, @final_file_part_location, @file_content, CONVERT(CHAR(255), NEWID()), @c_file_ext, NULL

    FETCH NEXT FROM file_name_cur INTO @file_names
	END

	CLOSE file_name_cur;
	DEALLOCATE file_name_cur;

	/* End : Email file */
 
    UPDATE email_notes
    SET type_column_name = @c_file_ext 
		,FS_Data = NULL
		, notes_attachment = NULL
		, attachment_file_name = NULL
    WHERE notes_id = @c_notes_id
	
    FETCH NEXT FROM db_bulk_insert_cursor INTO @c_notes_id, @c_file_path, @c_file_ext
END

CLOSE db_bulk_insert_cursor;
DEALLOCATE db_bulk_insert_cursor;

--update values of email notes for blank and non-numeric
--UPDATE en
--SET en.attachment_file_name = NULLIF(en.attachment_file_name, '')
--	, en.email_type = ISNULL(NULLIF(en.email_type, ''), 'o')
--	, en.notes_object_id = IIF(ISNUMERIC(en.notes_object_id) = 0, NULL, en.notes_object_id)
--FROM email_notes en
--INNER JOIN inserted i ON i.notes_id = en.notes_id



