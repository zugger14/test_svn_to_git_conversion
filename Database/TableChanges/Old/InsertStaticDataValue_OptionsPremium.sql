/**********************************
Insert into static_data_value, formula for Options Premium
select * from static_data_value where type_id=800 order by value_id
delete from static_data_value where value_id=860

***********************************/
--IF exists(select value_id from static_data_value where value_id=859)
	--return

	SET IDENTITY_INSERT static_data_value ON
	GO
	Insert into static_data_value(value_id,type_id,code,description)
	SELECT 860,800,'OptionsPremium','This function brings Options for Premium'
	UNION
	SELECT 861,800,'UDFCharges','This function brings UDF Charges from Deals'
	GO
	SET IDENTITY_INSERT static_data_value OFF
	GO



