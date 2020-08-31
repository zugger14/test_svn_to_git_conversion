SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

if exists(select 1 from static_data_value where type_id = 25 and code = 'Deal Status')
begin
	delete an 
	from application_notes an 
	inner join static_data_value sdv on sdv.value_id = an.internal_type_value_id
	where sdv.code = 'Deal Status' and sdv.type_id = 25

	delete from static_data_value where type_id = 25 and code = 'Deal Status'
	print 'Deleted sdv ''Deal Status'' of type_id 25.'
end
else print 'Record for sdv ''Deal Status'' of type_id 25 does not exists.'
