if object_id('dbo.FNAGetActivityHierarchy','fn') is not null
drop function dbo.FNAGetActivityHierarchy
go
create function dbo.FNAGetActivityHierarchy
(@activity int) 
returns varchar(1000)
begin

declare @detail varchar(100)

select @detail = process_name+'>'+risk_description+'>'+risk_control_description
from 
process_control_header process
inner join process_risk_description risk on risk.process_id = process.process_id
inner join process_risk_controls activity on risk.risk_description_id = activity.risk_description_id
where activity.risk_control_id = @activity
return @detail

end

