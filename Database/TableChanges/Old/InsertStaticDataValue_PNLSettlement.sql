/**********************************
Insert into static_data_value, formula for PNL Settlement
select * from static_data_value where type_id=800 order by value_id

***********************************/
--IF exists(select value_id from static_data_value where value_id=859)
--return

	SET IDENTITY_INSERT static_data_value ON
	GO
	Insert into static_data_value(value_id,type_id,code,description)
	SELECT 859,800,'MTMSettlement','This function brings PNL Settlement from source_deal_PNL table'
	GO
	SET IDENTITY_INSERT static_data_value OFF
	GO



