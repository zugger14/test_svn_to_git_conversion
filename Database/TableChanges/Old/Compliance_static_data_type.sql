-- Sishir 07/16/2009
if not exists(select 'x' from static_data_type where [type_id] = 11000)
INSERT INTO dbo.static_data_type ([type_id],[type_name],internal,description) VALUES (11000, 'Next Action', 1, 'Compliance Activity Next Action')

--Bikash Agrawal
if not exists (select 'x' from static_data_type where [type_id] = 10099)
insert into static_data_type(type_id,type_name,description,internal) 
values(10099,'Holiday Calendar','Holiday Calendar',0)

if not exists (select 'x' from static_data_type where [type_id] = 2050)
insert into static_data_type(type_id,type_name,description,internal) 
values(2050,'Working Days','Working Days',0)

