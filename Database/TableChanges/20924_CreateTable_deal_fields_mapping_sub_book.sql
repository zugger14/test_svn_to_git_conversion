SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[deal_fields_mapping_sub_book]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_fields_mapping_sub_book] (
    	[deal_fields_mapping_sub_book_id] INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
		[deal_fields_mapping_id]  INT REFERENCES deal_fields_mapping(deal_fields_mapping_id) NOT NULL,
		[sub_book_id]			  INT REFERENCES source_system_book_map(book_deal_type_map_id)  NULL,
    	[create_user]             VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]               DATETIME NULL DEFAULT GETDATE(),
    	[update_user]             VARCHAR(50) NULL,
    	[update_ts]               DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_fields_mapping_sub_book EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_fields_mapping_sub_book]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_fields_mapping_sub_book]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_fields_mapping_sub_book]
ON [dbo].[deal_fields_mapping_sub_book]
FOR UPDATE
AS
    UPDATE deal_fields_mapping_sub_book
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_fields_mapping_sub_book t
      INNER JOIN DELETED u ON t.[deal_fields_mapping_sub_book_id] = u.[deal_fields_mapping_sub_book_id]
GO