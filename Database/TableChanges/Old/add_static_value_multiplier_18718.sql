SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18718)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18718, 18700, 'Multiplier', 'Multiplier', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18718 - Multiplier.'
END
ELSE
BEGIN
	PRINT 'Static data value 18718 - Multiplier already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

go


update user_defined_deal_fields_template set internal_field_type=18718  from user_defined_deal_fields_template a
inner join (
select distinct arg1 from formula_breakdown where func_name='UDFValue'
) b on a.field_name=b.arg1