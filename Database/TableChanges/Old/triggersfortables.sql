set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-----------------source_major_location
create TRIGGER [TRGUPD_source_major_location]
ON [dbo].source_major_location
FOR UPDATE
AS
UPDATE source_major_location SET update_user =  dbo.FNADBUser(), update_ts = getdate() 
FROM  source_major_location s INNER JOIN deleted d ON s.source_major_location_ID = d.source_major_location_ID

go

create TRIGGER [TRGINS_source_major_location]
ON [dbo].source_major_location
FOR INSERT
AS
UPDATE source_major_location SET create_user =  dbo.FNADBUser(), create_ts = getdate()  
FROM source_major_location s INNER JOIN inserted i ON s.source_major_location_ID= i.source_major_location_ID


-----------------------------source_minor_location

go


create TRIGGER [TRGUPD_source_minor_location]
ON [dbo].source_minor_location
FOR UPDATE
AS
UPDATE source_minor_location SET update_user =  dbo.FNADBUser(), update_ts = getdate() 
FROM  source_minor_location s INNER JOIN deleted d ON s.source_minor_location_id = d.source_minor_location_id

go

create TRIGGER [TRGINS_source_minor_location]
ON [dbo].source_minor_location
FOR INSERT
AS
UPDATE source_minor_location SET create_user =  dbo.FNADBUser(), create_ts = getdate()  
FROM source_minor_location s INNER JOIN inserted i ON s.source_minor_location_id= i.source_minor_location_id

go



-----------------------------user_defined_deal_fields_template

create TRIGGER [TRGUPD_user_defined_deal_fields_template]
ON [dbo].user_defined_deal_fields_template
FOR UPDATE
AS
UPDATE user_defined_deal_fields_template SET update_user =  dbo.FNADBUser(), update_ts = getdate() 
FROM  user_defined_deal_fields_template s INNER JOIN deleted d ON s.udf_template_id = d.udf_template_id

go

create TRIGGER [TRGINS_user_defined_deal_fields_template]
ON [dbo].user_defined_deal_fields_template
FOR INSERT
AS
UPDATE user_defined_deal_fields_template SET create_user =  dbo.FNADBUser(), create_ts = getdate()  
FROM user_defined_deal_fields_template s INNER JOIN inserted i ON s.udf_template_id= i.udf_template_id

go

-----------------------------user_defined_deal_fields
create TRIGGER [TRGUPD_user_defined_deal_fields]
ON [dbo].user_defined_deal_fields
FOR UPDATE
AS
UPDATE user_defined_deal_fields SET update_user =  dbo.FNADBUser(), update_ts = getdate() 
FROM  user_defined_deal_fields s INNER JOIN deleted d ON s.udf_deal_id = d.udf_deal_id

go

create TRIGGER [TRGINS_user_defined_deal_fields]
ON [dbo].user_defined_deal_fields
FOR INSERT
AS
UPDATE user_defined_deal_fields SET create_user =  dbo.FNADBUser(), create_ts = getdate()  
FROM user_defined_deal_fields s INNER JOIN inserted i ON s.udf_deal_id= i.udf_deal_id

go

