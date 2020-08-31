/*
select * from state_properties_duration
*/
ALTER TABLE state_properties_duration DROP CONSTRAINT [IX_state_properties_duration]

ALTER TABLE state_properties_duration
ADD CONSTRAINT [IX_state_properties_duration] UNIQUE NONCLUSTERED 
(
	[code_value] ASC,
	[technology] ASC,
	[assignment_type_Value_id] ASC,
	[gen_code_value] ASC,
	[curve_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 



