SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_static_data_active_deactive]'))
    DROP TRIGGER [dbo].[TRGINS_static_data_active_deactive]
GO

-- insert trigger 
CREATE TRIGGER [dbo].[TRGINS_static_data_active_deactive]
ON [dbo].[static_data_active_deactive]
FOR INSERT
AS
BEGIN
	DECLARE @cmbobj_source VARCHAR(MAX)
	SELECT TOP 1  @cmbobj_source = CASE i.type_id 
					WHEN 4000 THEN 'source_book||Getsourcebookmapping' 
					WHEN 4001 THEN 'source_commodity' 
					WHEN 4002 THEN 'source_counterparty' 
					WHEN 4003 THEN 'source_currency' 
					WHEN 4007 THEN 'source_deal_type' 
					WHEN 4008 THEN 'source_price_curve_def' 
					WHEN 4010 THEN 'source_traders' 
					WHEN 4011 THEN 'source_uom' 
					WHEN 4014 THEN 'source_brokers' 
					WHEN 4016 THEN 'contract_group||source_contract' 
					WHEN 4017 THEN 'source_legal_entity' 
					WHEN 4020 THEN 'source_product' 
					WHEN 4030 THEN 'source_major_location' 
					WHEN 4031 THEN 'source_minor_location' 
					WHEN 4073 THEN 'contract_group||source_contract' 
					WHEN 4074 THEN 'contract_group||source_contract'  
					WHEN 4031 THEN 'source_minor_location' 
					WHEN 400000 THEN 'meter_id||spa_update_meter_data' 
						ELSE '%spa_StaticDataValues%h%' + CAST(i.type_id AS VARCHAR(20)) +'%'
				END			
		FROM INSERTED i


		--select @cmbobj_source
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC')) AND @cmbobj_source IS NOT NULL 
		BEGIN	
			EXEC [spa_manage_memcache] @flag = 'd', @key_prefix = NULL, @cmbobj_key_source = @cmbobj_source, @other_key_source=NULL, @source_object = 'TRGINS_static_data_active_deactive'
		END
	
END

GO
--update trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_static_data_active_deactive]'))
    DROP TRIGGER [dbo].[TRGUPD_static_data_active_deactive]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_static_data_active_deactive]
ON [dbo].[static_data_active_deactive]
FOR UPDATE
AS
BEGIN
	 --this check is required to prevent recursive trigger
    IF NOT UPDATE(update_ts)
    BEGIN
        DECLARE @cmbobj_source VARCHAR(MAX)
		SELECT TOP 1   @cmbobj_source = CASE i.type_id 
						WHEN 4000 THEN 'source_book||Getsourcebookmapping' 
					WHEN 4001 THEN 'source_commodity' 
					WHEN 4002 THEN 'source_counterparty' 
					WHEN 4003 THEN 'source_currency' 
					WHEN 4007 THEN 'source_deal_type' 
					WHEN 4008 THEN 'source_price_curve_def' 
					WHEN 4010 THEN 'source_traders' 
					WHEN 4011 THEN 'source_uom' 
					WHEN 4014 THEN 'source_brokers' 
					WHEN 4016 THEN 'contract_group||source_contract' 
					WHEN 4017 THEN 'source_legal_entity' 
					WHEN 4020 THEN 'source_product' 
					WHEN 4030 THEN 'source_major_location' 
					WHEN 4031 THEN 'source_minor_location' 
					WHEN 4073 THEN 'contract_group||source_contract' 
					WHEN 4074 THEN 'contract_group||source_contract'  
					WHEN 4031 THEN 'source_minor_location' 
					WHEN 400000 THEN 'meter_id||spa_update_meter_data' 
						ELSE '%spa_StaticDataValues%h%' + CAST(i.type_id AS VARCHAR(20)) +'%'
					END			
			FROM INSERTED i
			
			--select @cmbobj_source
			IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC')) AND @cmbobj_source IS NOT NULL 
			BEGIN	
				EXEC [spa_manage_memcache] @flag = 'd', @key_prefix = NULL, @cmbobj_key_source = @cmbobj_source, @other_key_source=NULL, @source_object =  'TRGUPD_static_data_active_deactive'
			END
    END

END

GO
-- delete trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGDEL_static_data_active_deactive]'))
    DROP TRIGGER [dbo].[TRGDEL_static_data_active_deactive]
GO
 
CREATE TRIGGER [dbo].[TRGDEL_static_data_active_deactive]
ON [dbo].[static_data_active_deactive]
FOR DELETE
AS
BEGIN
	DECLARE @cmbobj_source VARCHAR(MAX)
	SELECT TOP 1  @cmbobj_source = CASE d.type_id 
					WHEN 4000 THEN 'source_book||Getsourcebookmapping' 
					WHEN 4001 THEN 'source_commodity' 
					WHEN 4002 THEN 'source_counterparty' 
					WHEN 4003 THEN 'source_currency' 
					WHEN 4007 THEN 'source_deal_type' 
					WHEN 4008 THEN 'source_price_curve_def' 
					WHEN 4010 THEN 'source_traders' 
					WHEN 4011 THEN 'source_uom' 
					WHEN 4014 THEN 'source_brokers' 
					WHEN 4016 THEN 'contract_group||source_contract' 
					WHEN 4017 THEN 'source_legal_entity' 
					WHEN 4020 THEN 'source_product' 
					WHEN 4030 THEN 'source_major_location' 
					WHEN 4031 THEN 'source_minor_location' 
					WHEN 4073 THEN 'contract_group||source_contract' 
					WHEN 4074 THEN 'contract_group||source_contract'  
					WHEN 4031 THEN 'source_minor_location' 
					WHEN 400000 THEN 'meter_id||spa_update_meter_data' 
						ELSE '%spa_StaticDataValues%h%' + CAST(d.type_id AS VARCHAR(20)) +'%'
				END			
		FROM DELETED d


		--select @cmbobj_source
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC')) AND @cmbobj_source IS NOT NULL 
		BEGIN	
			EXEC [spa_manage_memcache] @flag = 'd', @key_prefix = NULL, @cmbobj_key_source = @cmbobj_source, @other_key_source=NULL, @source_object = 'TRGDEL_static_data_active_deactive'
		END
END