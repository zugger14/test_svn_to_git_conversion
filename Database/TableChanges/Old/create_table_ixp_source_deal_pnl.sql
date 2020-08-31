SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/*
* Created date - 2015-02-26
* Template Table for source_deal_pnl.
* ixp_source_deal_pnl
* Template table - will not store any data, is used for import feature 
*/
IF OBJECT_ID(N'[dbo].[ixp_source_deal_pnl]', N'U') IS NOT NULL
BEGIN
	DROP TABLE ixp_source_deal_pnl
END
IF OBJECT_ID(N'[dbo].[ixp_source_deal_pnl]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_source_deal_pnl] (
    	[source_deal_header_id]     VARCHAR(250),
    	[term_start]				VARCHAR(250),
    	[term_end]					VARCHAR(250),
    	[Leg]						VARCHAR(250),
    	[pnl_as_of_date]            VARCHAR(250),
		[und_pnl]					VARCHAR(250),
		[und_intrinsic_pnl]			VARCHAR(250),
		[und_extrinsic_pnl]			VARCHAR(250),
		[dis_pnl]					VARCHAR(250),
		[dis_intrinsic_pnl]			VARCHAR(250),
		[dis_extrinisic_pnl]		VARCHAR(250),
		[pnl_source_value_id]		VARCHAR(250),
		[pnl_currency_id]			VARCHAR(250),
		[pnl_conversion_factor]		VARCHAR(250),
		[pnl_adjustment_value]		VARCHAR(250),
		[deal_volume]				VARCHAR(250),
		[create_user]				VARCHAR(250),
		[create_ts]					VARCHAR(250),
		[update_user]				VARCHAR(250),
		[update_ts]					VARCHAR(250),
		[source_deal_pnl_id]		VARCHAR(250),
		[und_pnl_set]				VARCHAR(250),
		[market_value]				VARCHAR(250),
		[contract_value]			VARCHAR(250),
		[dis_market_value]			VARCHAR(250),
		[dis_contract_value	]		VARCHAR(250),
		[pnl_currency]				VARCHAR(250),
		[reference_id]				VARCHAR(250),
		[discount_factor]			VARCHAR(250),
		[discount_rate]				VARCHAR(250)
    	
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_source_deal_pnl EXISTS'
END
 
 
 