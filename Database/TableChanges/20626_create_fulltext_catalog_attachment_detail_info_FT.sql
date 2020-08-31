-- create the full-text catalog and fulltext index  on email notes
IF NOT EXISTS (SELECT 1
    FROM sys.fulltext_catalogs
    WHERE [name] = 'attachment_detail_info_FT')
BEGIN
    CREATE FULLTEXT CATALOG attachment_detail_info_FT AS DEFAULT
    PRINT 'FULLTEXT CATALOG attachment_detail_info_FT created.'
END
ELSE
    PRINT 'FULLTEXT CATALOG attachment_detail_info_FT exists'

IF EXISTS (SELECT * FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[attachment_detail_info]'))
    DROP FULLTEXT INDEX ON [dbo].[attachment_detail_info]
GO
IF NOT EXISTS (SELECT 1 FROM sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[attachment_detail_info]'))
	CREATE FULLTEXT INDEX ON [dbo].[attachment_detail_info](
		FS_Data TYPE COLUMN attachment_file_ext LANGUAGE [English], 
		attachment_file_name LANGUAGE [English]
	)
	KEY INDEX [PK_attachment_detail_info] ON ([attachment_detail_info_FT], FILEGROUP [PRIMARY])
	--WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)
GO
PRINT 'FULLTEXT INDEX on attachment_detail_info dropped and created.'

