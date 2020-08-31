IF COL_LENGTH('calcprocess_storage_wacog', 'inj_deal_total_volume') IS NOT NULL
BEGIN
	ALTER TABLE  
	/**
	 Parameters:
		inj_deal_total_volume : Injection Deal Total Volume
	*/
	dbo.calcprocess_storage_wacog ALTER COLUMN inj_deal_total_volume	NUMERIC(38,18 )

	ALTER TABLE  
	/**
	 Parameters:
		inj_deal_total_volume : Withdrawal Deal Total Volume
	*/
	dbo.calcprocess_storage_wacog ALTER COLUMN wth_deal_total_volume	NUMERIC(38,18 )
END 
GO