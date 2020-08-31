IF EXISTS( SELECT 1 FROM sys.[columns] WHERE [name]='source_deal_header_id' AND [object_id]=OBJECT_ID('deal_detail_hour'))
	alter TABLE [dbo].[deal_detail_hour] DROP COLUMN
		[source_deal_header_id],
		[commodity_id],
		[counterparty_id],
		[fas_book_id],
		[leg] ,
		[curve_id],
		[source_system_book_id1],
		[source_system_book_id2],
		[source_system_book_id3] ,
		[source_system_book_id4],
		[deal_date] ,
		[multiplier] ,
		[volume_multiplier2],
		[buy_sell_flag]
