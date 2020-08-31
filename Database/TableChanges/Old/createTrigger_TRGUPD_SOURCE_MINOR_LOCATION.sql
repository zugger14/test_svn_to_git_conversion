SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[dbo].[TRGUPD_SOURCE_MINOR_LOCATION]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_SOURCE_MINOR_LOCATION]
GO

CREATE TRIGGER [dbo].[TRGUPD_SOURCE_MINOR_LOCATION]
ON [dbo].[source_minor_location]
FOR UPDATE
AS                                 
    DECLARE @update_user  VARCHAR(200)
    DECLARE @update_ts    DATETIME

	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.source_minor_location
       SET update_user = @update_user,
           update_ts = @update_ts
    FROM dbo.source_minor_location sml
      INNER JOIN DELETED u ON sml.source_minor_location_id = u.source_minor_location_id  
	    
	INSERT INTO source_minor_location_audit
	  (
	    [source_minor_location_id],			
		[source_system_id],						
		[source_major_location_ID],				
		[Location_Name]	,					
		[Location_Description],				
		[Meter_ID],						
		[Pricing_Index],						
		[Commodity_id],						
		[location_type],						
		[time_zone],							
		[x_position],						
		[y_position],						
		[region],							
		[is_pool],							
		[term_pricing_index],				
		[owner],								
		[operator],							
		[contract],							
		[volume],							
		[uom],								
		[bid_offer_formulator_id],			
		[proxy_location_id],					
		[external_identification_number],	
		[profile_id],						
		[proxy_profile_id],					
		[grid_value_id],						
		[country],							
		[is_active],							
		[postal_code],						
		[province],							
		[physical_shipper],					
		[sicc_code],						
		[profile_code],						
		[nominatorsapcode],					
		[forecast_needed],					
		[forecast_group],					
		[external_profile],					
		[calculation_method],				
		[profile_additional],				
		[location_id],						
		[create_user],						
		[create_ts],							
		[update_user],						
		[update_ts],							
    	[user_action]                       
	  )
	SELECT source_minor_location_id,
	       source_system_id,
	       source_major_location_ID,
	       Location_Name,
	       Location_Description,
	       Meter_ID,
	       Pricing_Index,
	       Commodity_id,
	       location_type,
	       time_zone,
	       x_position,
	       y_position,
	       region,
	       is_pool,
	       [term_pricing_index],
	       [owner],
	       [operator],
	       [contract],
	       [volume],
	       [uom],
	       [bid_offer_formulator_id],
	       [proxy_location_id],
	       [external_identification_number],
	       [profile_id],
	       [proxy_profile_id],
	       [grid_value_id],
	       [country],
	       [is_active],
	       [postal_code],
	       [province],
	       [physical_shipper],
	       [sicc_code],
	       [profile_code],
	       [nominatorsapcode],
	       [forecast_needed],
	       [forecasting_group],
	       [external_profile],
	       [calculation_method],
	       [profile_additional],
	       [location_id],
	       [create_user],
	       [create_ts],
	       @update_user,
	       @update_ts,
	       'update' [user_action]
	FROM   INSERTED