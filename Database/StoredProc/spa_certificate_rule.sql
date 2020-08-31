IF OBJECT_ID(N'[dbo].[spa_certificate_rule]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_certificate_rule]
GO


CREATE PROCEDURE [dbo].[spa_certificate_rule]  @flag as char(1),
					@gis_id as Integer,
					@curve_id as integer=NULL,
					@cert_rule as varchar(1000)=NULL,
					@reporting_type varchar(100)=NULL,
					@address varchar(255)=NULL,
					@phone_no varchar(100)=NULL,
					@fax_email varchar(255)=null,
					@website varchar(500)=null,
					@contact_name varchar(100)=null,
					@contact_address varchar(255)=null,
					@contact_phone varchar(100)=null,
					@contact_email varchar(255)=null,
					@control_area_operator varchar(100)=null,
					@interconnecting_utility varchar(255)=NULL,
					@voltage_level varchar(100)=null
					
AS

SET NOCOUNT ON

DECLARE @errorCode Int

If @flag = 'a' 
Begin

	Declare @selectStr1 Varchar(5000)

	Set @selectStr1 = 'select gis_id,s.code,curve_id,cert_rule,reporting_type,address,
	phone_no,fax_email,website,contact_name,
	contact_address,contact_phone,contact_email,control_area_operator,
	interconnecting_utility,voltage_level
	 from certificate_rule  c join static_data_value s
		on c.gis_id=s.value_id where gis_id = ' + CAST(@gis_id AS Varchar) 
	exec(@selectStr1)

end	
Else If @flag='i'
Begin
	Insert into certificate_rule
	(gis_id,curve_id,cert_rule,reporting_type,address,
	phone_no,fax_email,website,contact_name,
	contact_address,contact_phone,contact_email,control_area_operator,
	interconnecting_utility,voltage_level)
	values (@gis_id,@curve_id,@cert_rule,@reporting_type,@address,
@phone_no,@fax_email,@website,@contact_name,
@contact_address,@contact_phone,@contact_email,@control_area_operator,
@interconnecting_utility,@voltage_level)

	Set @errorCode = @@ERROR
	If @errorCode <> 0
		Exec spa_ErrorHandler @errorCode, 'StaticDataMgmt', 
				'spa_certificate_rule', 'DB Error', 
				'Failed to insert Certificate Rule value.', ''
	Else
		Exec spa_ErrorHandler 0, 'StaticDataMgmt', 
				'spa_certificate_rule', 'Success', 
				'Certificate Rule value inserted.', ''
End
Else If @flag = 'u'
Begin
	Update certificate_rule
	set curve_id = @curve_id, cert_rule = @cert_rule,
	reporting_type=@reporting_type,
	address=@address,
	phone_no=@phone_no,fax_email=@fax_email,
	website=@website,contact_name=@contact_name,
	contact_address=@contact_address,
	contact_phone=@contact_phone,
	contact_email=@contact_email,
	control_area_operator=@control_area_operator,
	interconnecting_utility=@interconnecting_utility,
	voltage_level=@voltage_level
	where gis_id = @gis_id

	Set @errorCode = @@ERROR
	If @errorCode <> 0
	BEGIN
		
		Exec spa_ErrorHandler @errorCode, 'StaticDataMgmt', 
				'spa_certificate_rule', 'DB Error', 
				'Failed to update Certificate Rule value.', ''
		Return
	END
	Else
	BEGIN
		
		Exec spa_ErrorHandler 0, 'StaticDataMgmt', 
				'spa_certificate_rule', 'Success', 
				'Certificate Rule value updated.', ''
		Return
	END
End





