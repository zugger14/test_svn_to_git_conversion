if exists(select 1 from dbo.internal_deal_type_subtype_types where internal_deal_type_subtype_id=101)
print ' The id 101 already exists'
else
insert into dbo.internal_deal_type_subtype_types 
(internal_deal_type_subtype_id,internal_deal_type_subtype_type,type_subtype_flag)
select 101,'Calendar Spread','y'
