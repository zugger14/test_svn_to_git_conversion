delete  [dbo].[internal_deal_type_subtype_types] where  [internal_deal_type_subtype_id]=155

insert into  [dbo].[internal_deal_type_subtype_types]
(
 [internal_deal_type_subtype_id]
      ,[internal_deal_type_subtype_type]
      ,[type_subtype_flag]
 )
values
(155,'Linear Model Option Leg 1','y')