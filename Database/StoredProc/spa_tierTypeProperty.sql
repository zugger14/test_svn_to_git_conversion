/***************************************************
* Created By : Mukesh Singh
* Created Date : 11-Sept-2009
* Purpose :To store date from screen Tier Type Properties 
*
****************************************************/
--exec [spa_tierTypeProperty] 's',NULL,NULL
/****** Object:  StoredProcedure [dbo].[spa_tierTypeProperty]    Script Date: 09/11/2009 11:28:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_tierTypeProperty]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_tierTypeProperty]
GO
CREATE  proc [dbo].[spa_tierTypeProperty]
@flag varchar(1),
@tierTypePropertyID INT=null ,
@tierTypeValueId INT=null,
@environmentalProduct INT=null,
@tierTypePercentage FLOAT=null

AS
declare @sql varchar(8000)
declare @total float

IF @flag='i'
BEGIN 

IF @tierTypePercentage > 100
BEGIN
		Exec spa_ErrorHandler -1, 'Total Percentage cannot be greater than 100%.', 
				'spa_tierTypeProperty', 'DB Error', 
				'Total Percentage cannot be greater than 100%.', ''
				return
	END

IF EXISTS (SELECT 1 FROM tierTypeProperty WHERE  environmentalProduct = @environmentalProduct and tierTypeValueId = @tierTypeValueId)
	BEGIN
		Exec spa_ErrorHandler -1, 'Cannot insert duplicate data.', 
				'spa_tierTypeProperty', 'DB Error', 
				'Cannot insert duplicate data.', ''
				return
	END


	select  @total =  sum(tierTypePercentage) from tierTypeProperty where tierTypeValueId = @tierTypeValueId

	select @total = @total + @tierTypePercentage

	if(@total > 100)
	BEGIN
		Exec spa_ErrorHandler -1, 'Total Percentage cannot be greater than 100%.', 
				'spa_tierTypeProperty', 'DB Error', 
				'Total Percentage cannot be greater than 100%.', ''
				return
	END		

	insert into tierTypeProperty(tierTypeValueId,environmentalProduct,tierTypePercentage)
	values(@tierTypeValueId,@environmentalProduct,@tierTypePercentage)

If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "Insert of Tier TYPE Property  failed.", 
				"spa_tierTypeProperty", "DB Error", 
				"Insert of Tier TYPE Property  failed.", ''
		RETURN
	END

		ELSE Exec spa_ErrorHandler 0, 'Successfully inserted Tier TYPE Property.', 
				'spa_tierTypeProperty', 'Success', 
				'Successfully inserted Tier TYPE Property.', ''

End
ELSE IF @flag='s'	
BEGIN 
	select @sql = '
	SELECT  tp.tierTypePropertyID [Tier Type Property ID],
			sdv.code [Tier Type],
			spcd.curve_name [Curve Name],
			tp.tierTypePercentage [Percentage (%)]	
			FROM  tierTypeProperty tp 
			LEFT JOIN static_data_value sdv ON sdv.value_id = tp.tierTypeValueId
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tp.environmentalProduct
			where 1=1 '

	if @tierTypeValueId is not null 
	select @sql = @sql + 
			' AND tierTypeValueId = ' + cast(@tierTypeValueId as varchar)

	EXEC spa_print @sql
	exec (@sql)

END

ELSE IF @flag='a'
BEGIN 
	select tierTypePropertyID,tierTypeValueId,environmentalProduct,tierTypePercentage from  tierTypeProperty WHERE tierTypePropertyID=@tierTypePropertyID
End


ELSE IF @flag='u'
BEGIN

IF @tierTypePercentage > 100
BEGIN
		Exec spa_ErrorHandler -1, 'Total Percentage cannot be greater than 100%.', 
				'spa_tierTypeProperty', 'DB Error', 
				'Total Percentage cannot be greater than 100%.', ''
				return
	END
	
	
IF EXISTS (SELECT 1 FROM tierTypeProperty WHERE  environmentalProduct = @environmentalProduct and tierTypeValueId = @tierTypeValueId and tierTypePropertyID <> @tierTypePropertyID )
	BEGIN
		Exec spa_ErrorHandler -1, 'Cannot insert duplicate data.', 
				'spa_tierTypeProperty', 'DB Error', 
				'Cannot insert duplicate data.', ''
				return
	END


	select  @total =  sum(tierTypePercentage) from tierTypeProperty where tierTypeValueId = @tierTypeValueId  and tierTypePropertyID <> @tierTypePropertyID

	select @total = @total + @tierTypePercentage

	if(@total > 100)
	BEGIN
		Exec spa_ErrorHandler -1, 'Total Percentage cannot be greater than 100%.', 
				'spa_tierTypeProperty', 'DB Error', 
				'Total Percentage cannot be greater than 100%.', ''
				return
	END	
	UPDATE tierTypeProperty
	SET
	tierTypeValueId = @tierTypeValueId,
	environmentalProduct= @environmentalProduct,
	tierTypePercentage = @tierTypePercentage
	where 
	tierTypePropertyID = @tierTypePropertyID

If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "Tier Type Proeprty Updated  failed.", 
				"spa_tierTypeProperty", "DB Error", 
				"Tier Type Proeprty Updated  failed.", ''
		RETURN
	END

		ELSE Exec spa_ErrorHandler 0, 'Tier Type Proeprty Updated Successfully.', 
				'spa_tierTypeProperty', 'Success', 
				'Tier Type Proeprty Updated Successfully.', ''

End


ELSE IF @flag='d'
BEGIN 
	DELETE  tierTypeProperty WHERE tierTypePropertyID=@tierTypePropertyID
	If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "Tier Type Proeprty Delete  failed.", 
				"spa_tierTypeProperty", "DB Error", 
				"Tier Type Proeprty Delete  failed.", ''
		RETURN
	END

		ELSE Exec spa_ErrorHandler 0, 'Tier Type Proeprty Successfully Deleted.', 
				'spa_tierTypeProperty', 'Success', 
				'Tier Type Proeprty Successfully Deleted.', ''

END
