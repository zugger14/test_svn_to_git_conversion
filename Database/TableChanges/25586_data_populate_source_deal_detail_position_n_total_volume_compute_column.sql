
if OBJECT_ID('dbo.FNAGetTotalVolume') is null
begin
	exec(
	'
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
	'
	)



	IF not exists(select 1 from source_deal_detail_position)
	BEGIN

		insert into source_deal_detail_position(source_deal_detail_id,total_volume)
		select source_deal_detail_id,total_volume from source_deal_detail 
	
		if  exists(select 1 from sys.indexes where [name]='IX_PT_source_deal_detail_term_start')
			drop index IX_PT_source_deal_detail_term_start on dbo.source_deal_detail

		EXEC sp_rename 'source_deal_detail.[total_volume]', 'total_volume_old', 'COLUMN'
	
		ALTER TABLE source_deal_detail add total_volume AS dbo.FNAGetTotalVolume(source_deal_detail_id);

		if  exists(select 1 from sys.indexes where [name]='IX_PT_source_deal_detail_term_start')
			drop index IX_PT_source_deal_detail_term_start on dbo.source_deal_detail

		ALTER TABLE source_deal_detail drop column total_volume_old;
	END

end
