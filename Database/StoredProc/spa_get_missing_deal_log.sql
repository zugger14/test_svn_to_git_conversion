IF OBJECT_ID(N'[dbo].[spa_get_missing_deal_log]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_missing_deal_log]
GO 

-- exec spa_get_import_process_status_detail '222222','Static_Data','Deal type COMM not found'
create PROCEDURE [dbo].[spa_get_missing_deal_log]
	@process_id varchar(50)				
AS
select deal_num [Deal Id],price_region [Price Region],Counterparty,
	Source_system System,dbo.fnadateformat(as_of_date) [As Of Date],create_ts [Create Time] from interface_missing_deal_log
where process_id=@process_id
order by deal_num,price_region,Counterparty







