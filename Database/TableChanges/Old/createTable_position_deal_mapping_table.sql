SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[position_deal_mapping_table]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[position_deal_mapping_table]
    (
    	[id]                   [INT] IDENTITY(1, 1) NOT NULL,
    	source_deal_header_id  INT,
    	sub_ph_entity_id       INT,
    	str_ph_entity_id       INT,
    	book_ph_entity_id      INT,
    	counterparty_id        INT,
    	deal_type_id           INT,
    	volume_type_id         VARCHAR(100),
    	category_id            INT
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table position_deal_mapping_table EXISTS'
END

GO

   