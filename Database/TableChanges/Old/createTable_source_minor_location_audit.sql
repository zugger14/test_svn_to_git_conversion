SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[source_minor_location_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[source_minor_location_audit]
    (
    	[audit_id]							INT IDENTITY(1, 1) NOT NULL,
    	[source_minor_location_id]			INT NOT NULL,
		[source_system_id]					INT NOT NULL,
		[source_major_location_ID]			INT NULL,
		[Location_Name]						VARCHAR(100) NOT NULL,
		[Location_Description]				VARCHAR(500) NULL,
		[Meter_ID]							VARCHAR(100) NULL,
		[Pricing_Index]						INT NULL,
		[Commodity_id]						INT NULL,
		[location_type]						INT NULL,
		[time_zone]							INT NULL,
		[x_position]						INT NULL,
		[y_position]						INT NULL,
		[region]							INT NULL,
		[is_pool]							CHAR(1) NULL,
		[term_pricing_index]				INT NULL ,
		[owner]								VARCHAR(100) NULL,
		[operator]							VARCHAR(100) NULL,
		[contract]							INT NULL,
		[volume]							FLOAT NULL,
		[uom]								INT NULL,
		[bid_offer_formulator_id]			INT NULL,
		[proxy_location_id]					INT NULL,
		[external_identification_number]	VARCHAR(200) NULL,
		[profile_id]						INT NULL,
		[proxy_profile_id]					INT NULL,
		[grid_value_id]						INT NULL,
		[country]							INT NULL,
		[is_active]							CHAR(1) NULL,
		[postal_code]						VARCHAR(50) NULL,
		[province]							VARCHAR(100) NULL,
		[physical_shipper]					VARCHAR(50) NULL,
		[sicc_code]							VARCHAR(50) NULL,
		[profile_code]						VARCHAR(50) NULL,
		[nominatorsapcode]					VARCHAR(50) NULL,
		[forecast_needed]					CHAR(1) NULL,
		[forecast_group]					VARCHAR(50) NULL,
		[external_profile]					VARCHAR(50) NULL,
		[calculation_method]				VARCHAR(50) NULL,
		[profile_additional]				VARCHAR(100) NULL,
		[location_id]						VARCHAR(500) NULL,
		[create_user]						VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]							DATETIME NULL DEFAULT GETDATE(),
		[update_user]						VARCHAR(50) NULL,
		[update_ts]							DATETIME NULL,
    	[user_action]                       VARCHAR(50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table source_minor_location_audit EXISTS'
END

GO
