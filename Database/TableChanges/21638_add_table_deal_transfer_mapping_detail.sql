SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[deal_transfer_mapping_detail]', N'U') IS NULL
BEGIN

	CREATE TABLE [dbo].[deal_transfer_mapping_detail](
		[deal_transfer_mapping_detail_id] [int] IDENTITY(1,1) NOT NULL,
		deal_transfer_mapping_id [int] NOT NULL,
		source_book_mapping_id_offset INT NULL,
		trader_id_offset INT,
		counterparty_id_offset INT,
		contract_id_offset INT ,
		template_id_offset INT ,
		source_book_mapping_id_to INT NULL,
		trader_id_to INT NULL,
		counterparty_id INT NULL,
		contract_id INT NULL,
		template_id_to INT NULL,
		transfer_type INT NOT NULL,
		fixed FLOAT NULL,
		index_adder INT NULL,
		fixed_adder FLOAT NULL,
		[create_user] [varchar](50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] [datetime] NULL  DEFAULT GETDATE(),
		[update_user] [varchar](50) NULL,
		[update_ts] [datetime] NULL
		CONSTRAINT fk_deal_transfer_mapping_id FOREIGN KEY (deal_transfer_mapping_id)
		REFERENCES deal_transfer_mapping(deal_transfer_mapping_id),
		CONSTRAINT fk_deal_transfer_counterparty_id FOREIGN KEY (counterparty_id)
		REFERENCES source_counterparty(source_counterparty_id),
		CONSTRAINT fk_deal_transfer_contract_id FOREIGN KEY (contract_id)
		REFERENCES contract_group(contract_id)
	) ON [PRIMARY]
END 
ELSE 
BEGIN
    PRINT 'Table deal_transfer_mapping_detail EXISTS.'
	return
END
GO

IF OBJECT_ID('[dbo].[TRGUPD_deal_transfer_mapping_detail]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_transfer_mapping_detail]
	
GO

CREATE TRIGGER [dbo].[TRGUPD_deal_transfer_mapping_detail]
ON [dbo].[deal_transfer_mapping_detail]
FOR UPDATE
AS
    UPDATE deal_transfer_mapping_detail
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_transfer_mapping_detail t
      INNER JOIN DELETED u ON t.[deal_transfer_mapping_detail_id] = u.[deal_transfer_mapping_detail_id]
GO



