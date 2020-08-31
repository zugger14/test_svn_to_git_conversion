SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
/*
* Created date - 2013-03-21
* Template Table for index_fees_breakdown_settlement.
* ixp_location_template
* Template table - will not store any data, is used for import feature 
*/
IF OBJECT_ID(N'[dbo].[ixp_index_fees_breakdown_settlement_template]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_index_fees_breakdown_settlement_template] (
    	deal_id          VARCHAR(400),
    	fee_type         VARCHAR(400),
    	as_of_date       VARCHAR(400),
    	term_start       VARCHAR(400),
    	term_end         VARCHAR(400),
    	settlement_date  VARCHAR(400),
    	payment_date     VARCHAR(400),
    	volume           VARCHAR(400),
    	price            VARCHAR(400),
    	fees             VARCHAR(400),
    	currency         VARCHAR(400)
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_index_fees_breakdown_settlement_template EXISTS'
END
 
GO				