IF OBJECT_ID(N'[dbo].[etag_header]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[etag_header] (
		etag_id					INT,
		tag_id					VARCHAR(100),
		oati_tag_id				VARCHAR(100),
		source_deal_header_id	INT,
		match_status			INT,
		create_user				VARCHAR(100),
		create_ts				DATETIME
    )
END


