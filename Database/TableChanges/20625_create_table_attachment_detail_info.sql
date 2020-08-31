if OBJECT_ID(N'[dbo].[attachment_detail_info]', N'U') is null --drop table [dbo].[attachment_detail_info]
begin
	create table [dbo].[attachment_detail_info] (
		attachment_detail_info_id INT IDENTITY(1,1) CONSTRAINT PK_attachment_detail_info PRIMARY KEY,
		document_id int null,
		email_id int null,
		attachment_file_name varchar(1000) null,
		attachment_file_path varchar(5000) null,
		FS_Data varbinary(max) FILESTREAM NULL,
		UI uniqueidentifier ROWGUIDCOL NOT NULL UNIQUE DEFAULT (NEWID()),
		attachment_file_ext varchar(30) null,
		attachment_file_size bigint null,
		create_ts datetime null default getdate(),
		create_user varchar(500) null default dbo.FNADBUser(),
		update_ts datetime null,
		update_user varchar(500) null,

		CONSTRAINT [FK_application_notes_attachment_detail_info_document_id] 
			FOREIGN KEY([document_id])
			REFERENCES [dbo].[application_notes] ([notes_id])
			ON DELETE CASCADE,

		CONSTRAINT [FK_email_notes_attachment_detail_info_email_id] 
			FOREIGN KEY([email_id])
			REFERENCES [dbo].[email_notes] ([notes_id])
			ON DELETE CASCADE
	
	)
	print 'Object ''[dbo].[attachment_detail_info]'' created. FK ''[FK_application_notes_attachment_detail_info_document_id]'', ''[FK_email_notes_attachment_detail_info_email_id]''
	'
end
else print 'Object ''[dbo].[attachment_detail_info]'' already exists.'
go

/** trigger for update_ts,update_user **/
IF OBJECT_ID('[dbo].[TRGUPD_attachment_detail_info]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_attachment_detail_info]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_attachment_detail_info]
ON [dbo].[attachment_detail_info]
FOR UPDATE
AS
begin
    UPDATE attachment_detail_info
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM attachment_detail_info t
      INNER JOIN DELETED u ON t.attachment_detail_info_id = u.attachment_detail_info_id
end
GO
print 'Trigger ''[TRGUPD_attachment_detail_info]'' created.'
