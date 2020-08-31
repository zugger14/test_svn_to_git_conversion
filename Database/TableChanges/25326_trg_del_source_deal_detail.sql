
/****** Object:  Trigger [TRGDEL_SOURCE_DEAL_DETAIL]    Script Date: 12/18/2009 17:00:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGDEL_SOURCE_DEAL_DETAIL]'))
DROP TRIGGER [dbo].[TRGDEL_SOURCE_DEAL_DETAIL]

GO

CREATE TRIGGER [TRGDEL_SOURCE_DEAL_DETAIL]
ON [dbo].[source_deal_detail]
FOR Delete
AS
INSERT INTO [source_deal_detail_audit]
           ([source_deal_detail_id]
           ,[source_deal_header_id]
           ,[term_start]
           ,[term_end]
           ,[Leg]
           ,[contract_expiration_date]
           ,[fixed_float_leg]
           ,[buy_sell_flag]
           ,[curve_id]
           ,[fixed_price]
           ,[fixed_price_currency_id]
           ,[option_strike_price]
           ,[deal_volume]
           ,[deal_volume_frequency]
           ,[deal_volume_uom_id]
           ,[block_description]
           ,[deal_detail_description]
           ,[formula_id]
           ,[volume_left]
           ,[settlement_volume]
           ,[settlement_uom]
           ,[update_user]
           ,[update_ts]
           ,[user_action],price_adder,
			price_multiplier,
			settlement_date,
			day_count_id,
			[physical_financial_flag],
			fixed_cost,
			shipper_code1,
			shipper_code2)
select [source_deal_detail_id]
           ,[source_deal_header_id]
           ,[term_start]
           ,[term_end]
           ,[Leg]
           ,[contract_expiration_date]
           ,[fixed_float_leg]
           ,[buy_sell_flag]
           ,[curve_id]
           ,[fixed_price]
           ,[fixed_price_currency_id]
           ,[option_strike_price]
           ,[deal_volume]
           ,[deal_volume_frequency]
           ,[deal_volume_uom_id]
           ,[block_description]
           ,[deal_detail_description]
           ,[formula_id]
           ,[volume_left]
           ,[settlement_volume]
           ,[settlement_uom]
           , dbo.FNADBUser()
           ,getDate()
           ,'Delete',price_adder,
			price_multiplier,
			settlement_date,
			day_count_id,
			[physical_financial_flag],
			fixed_cost,
			shipper_code1,
			shipper_code2
from deleted


 INSERT  INTO [user_defined_deal_detail_fields_audit]
                (
                  [udf_deal_id],
                  [source_deal_detail_id],
                  [udf_template_id],
                  [udf_value],
                  [create_user],
                  [create_ts],
                  [update_user],
                  [update_ts],
                  [user_action]
			
                )
                SELECT  [udf_deal_id],
                        d.[source_deal_detail_id],
                        [udf_template_id],
                        [udf_value],
                       udddf. [create_user],
                        udddf.[create_ts],
                        dbo.FNADBUser(),
                        GETDATE(),
                        'Delete'
 FROM    DELETED d INNER JOIN user_defined_deal_detail_fields udddf ON d.source_deal_detail_id = udddf.source_deal_detail_id