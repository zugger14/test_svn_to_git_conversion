IF not exists (SELECT * FROM static_data_value WHERE code = 'Extrinsic Values in AOCI'  and [TYPE_ID]=225)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id,[type_id], code, [description]) VALUES (401055,'225', 'Extrinsic Values in AOCI', 'Extrinsic Values in AOCI')
	SET IDENTITY_INSERT static_data_value OFF

END
ELSE
BEGIN

	if not exists(select 1 from static_data_value where value_id=401055)
	begin
		update static_data_value set code='Extrinsic Values in AOCI old', [description]='Extrinsic Values in AOCI old'
			 WHERE code = 'Extrinsic Values in AOCI' and [TYPE_ID]=225
	
		SET IDENTITY_INSERT static_data_value ON

		INSERT INTO static_data_value (value_id,[type_id], code, [description]) VALUES (401055,'225', 'Extrinsic Values in AOCI', 'Extrinsic Values in AOCI')

		SET IDENTITY_INSERT static_data_value OFF

		update fas_strategy set mes_cfv_values_value_id=401055 from fas_strategy fs inner join static_data_value sdv on fs.mes_cfv_values_value_id=sdv.value_id and sdv.code='Extrinsic Values in AOCI old' and sdv.[TYPE_ID]=225
	
		delete top(1) static_data_value  where  [TYPE_ID]=225 and code='Extrinsic Values in AOCI old' 

		PRINT ('Value ID of Extrinsic Values in AOCI code changed into 401055.')
	end
END

