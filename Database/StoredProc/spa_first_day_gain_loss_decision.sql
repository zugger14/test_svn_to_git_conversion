IF OBJECT_ID(N'spa_first_day_gain_loss_decision', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_first_day_gain_loss_decision]
 GO 



----exec dbo.spa_first_day_gain_loss_decision 'd',2,577,'2007-01-02',4

create proc [dbo].[spa_first_day_gain_loss_decision]
	@flag as Char(1),
	@first_day_gain_loss_decision_id int=null,
	@source_deal_header_id VARCHAR(2000) = null,
	@deal_date varchar(20)=null,
	@treatment_value_id int=null,
	@FDGL float=null
AS 
SET NOCOUNT ON

DECLARE @sql varchar(5000)

if @flag='s'

SELECT [first_day_gain_loss_decision_id]
source_deal_header_id,
deal_date
,code
  FROM [first_day_gain_loss_decision] inner join static_data_value on [first_day_gain_loss_decision].treatment_value_id=static_data_value.value_id

else if @flag='i'
begin


INSERT INTO first_day_gain_loss_decision
		(
      [source_deal_header_id]
      ,deal_date
      ,treatment_value_id,
		first_day_pnl
		)
	select
	   @source_deal_header_id
      ,@deal_date
      ,@treatment_value_id,
		@FDGL
	

		if @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'first_day_gain_loss_decision', 
				'spa_first_day_gain_loss_decision', 'DB Error', 
				'Failed to insert first_day_gain_loss_decision.', ''
		Else
		Exec spa_ErrorHandler 0, 'first_day_gain_loss_decision', 
				'spa_first_day_gain_loss_decision', 'Success', 
				'first_day_gain_loss_decision value inserted.', ''
end

else if @flag='a' 
begin
set @sql=
' SELECT 
	  rs.[first_day_gain_loss_decision_id]
      , sdh.[source_deal_header_id]
      , rs.deal_date
      , sdv.value_id
	  , rs.first_day_pnl
	  , sdh.deal_id
	FROM source_deal_header sdh
	LEFT JOIN [first_day_gain_loss_decision] rs  ON sdh.source_deal_header_id = rs.source_deal_header_id
	LEFT JOIN static_data_value sdv on rs.treatment_value_id = sdv.value_id
where 1=1'
+case when @first_day_gain_loss_decision_id is not null then ' and rs.first_day_gain_loss_decision_id='+cast(@first_day_gain_loss_decision_id as varchar) else '' end
+case when @source_deal_header_id is not null then ' and sdh.source_deal_header_id='+cast(@source_deal_header_id as varchar) else '' end

exec(@sql)	
end
Else if @flag = 'u'
begin
	update first_day_gain_loss_decision set 
      [source_deal_header_id]=@source_deal_header_id
      ,treatment_value_id=@treatment_value_id,
	deal_date=@deal_date,
	first_day_pnl=@fdgl
     where first_day_gain_loss_decision_id = @first_day_gain_loss_decision_id

	if @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'first_day_gain_loss_decision', 
				'spa_first_day_gain_loss_decision', 'DB Error', 
				'Failed to update first_day_gain_loss_decision.', ''
		Else
		Exec spa_ErrorHandler 0, 'first_day_gain_loss_decision', 
				'spa_first_day_gain_loss_decision', 'Success', 
				'Defination data value updated.', ''
end

Else if @flag = 'd'
begin
	DELETE fdgld
	FROM first_day_gain_loss_decision fdgld
	INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) i ON i.item = fdgld.source_deal_header_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "first_day_gain_loss_decision", 
				"spa_first_day_gain_loss_decision", "DB Error", 
				"Delete of first_day_gain_loss_decision Data failed.", ''
	Else
		Exec spa_ErrorHandler 0, 'first_day_gain_loss_decision', 
				'spa_first_day_gain_loss_decision', 'Success', 
				'Data has been successfully deleted.', ''
end














