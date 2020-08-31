if OBJECT_ID('dbo.FNAGetTotalVolume') is  null -- this sp is used in source_deal_detail.total_volume as compute column
exec('

/**
	Get total volume of deal detail.

	Parameters 
	@source_deal_detail_id : Get volume of deal detail ID.
	

*/




CREATE FUNCTION [dbo].[FNAGetTotalVolume] (@source_deal_detail_id int)  
RETURNS numeric(38,10)
AS  
BEGIN  
    DECLARE @total_volume numeric(38,10)
    SELECT @total_volume = total_volume FROM source_deal_detail_position WHERE source_deal_detail_id = @source_deal_detail_id
    RETURN @total_volume
END
')