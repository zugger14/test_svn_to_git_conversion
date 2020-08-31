SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
/*
* Created date - 2013-03-21
* Template Table for source price curve def.
* ixp_location_template
* Template table - will not store any data, is used for import feature 
*/
IF OBJECT_ID(N'[dbo].[ixp_source_price_curve_def_template]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_source_price_curve_def_template] (
    	[curve_id]                    VARCHAR(500),
    	[curve_name]                  VARCHAR(500),
    	[curve_des]                   VARCHAR(500),
    	[commodity_id]                VARCHAR(500),
    	[market_value_id]             VARCHAR(500),
    	[market_value_desc]           VARCHAR(500),
    	[source_currency_id]          VARCHAR(500),
    	[source_currency_to_id]       VARCHAR(500),
    	[source_curve_type_value_id]  VARCHAR(500),
    	[uom_id]                      VARCHAR(500),
    	[proxy_source_curve_def_id]   VARCHAR(500),
    	Granularity                   VARCHAR(500),
    	exp_calendar_id               VARCHAR(500),
    	risk_bucket_id                VARCHAR(500)
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_source_price_curve_def_template EXISTS'
END
 
GO				