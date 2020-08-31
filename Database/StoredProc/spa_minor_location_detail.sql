/****** Object:  StoredProcedure [dbo].[spa_minor_location_detail]    Script Date: 01/20/2009 14:47:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_minor_location_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_minor_location_detail]
GO

CREATE PROC [dbo].[spa_minor_location_detail]
@flag varchar(1),
@minor_location_detail_id int=null,
@minor_location_id [int]=null,
@owner Varchar(100)=null,
@operator varchar(100)=null,
@contract int=null,
@volume float=null,
@uom int=null,
@region VARCHAR(MAX) = null
as
SET NOCOUNT ON
DECLARE @Sql_Select varchar(3000), @msg_err varchar(2000)
IF  @flag = 's'
		SELECT   minor_location_detail_id [Minor Loc Detail ID],minor_location_id [Minor Loc ID],[owner] [Owner],operator [Operator],[contract] [Contract],volume [Volume],uom [UoM]
		  FROM minor_location_detail
			WHERE 1=1
ELSE IF  @flag = 'i'
	 INSERT INTO minor_location_detail
			   (minor_location_id,[owner],operator,[contract],volume,uom)
		 VALUES
			   (@minor_location_id,@owner,@operator,@contract,@volume,@uom)
ELSE IF  @flag = 'u'
		UPDATE minor_location_detail
		   SET 
			minor_location_id =@minor_location_id,
			[owner]=@owner,
			operator =@owner,
			[contract]=@contract,
			volume=@volume,
			uom=@uom
		 WHERE minor_location_detail_id=@minor_location_detail_id

ELSE IF  @flag = 'q'
		BEGIN
		SELECT smlm.source_minor_location_id, sml.location_name FROM source_minor_location_meter smlm
		INNER JOIN 
		source_minor_location sml ON
		sml.source_minor_location_id = smlm.source_minor_location_id
		END

ELSE IF @flag = 'c'
BEGIN

	SET @Sql_Select = 'SELECT source_minor_location_id, location_name 
						FROM source_minor_location 
						WHERE 1 = 1 '
						
	IF NULLIF(@region, 'NUll') IS NOT NULL 
	BEGIN
		SET @Sql_Select =	@Sql_Select +  ' AND region IN(' + @region + ') '
	END
	
	SET @Sql_Select =	@Sql_Select + ' ORDER BY location_name'
	EXEC(@Sql_Select)
END
ELSE IF  @flag = 'd'
		DELETE minor_location_detail WHERE minor_location_detail_id=@minor_location_detail_id

ELSE IF  @flag = 'a'
		SELECT   minor_location_detail_id,minor_location_id,[owner],operator,[contract],volume,uom
		  FROM minor_location_detail
			WHERE 
				minor_location_id=@minor_location_id

	DECLARE @msg varchar(2000)
	SELECT @msg=''
	if @flag='i'
		SET @msg='Data Successfully Inserted.'
	ELSE if @flag='u'
		SET @msg='Data Successfully Updated.'
	ELSE if @flag='d'
		SET @msg='Data Successfully Deleted.'

	IF @msg<>''
		Exec spa_ErrorHandler 0, 'Minor Location Detail ', 
				'spa_minor_location_detail', 'Success', 
				@msg, ''
--begin catch
DECLARE @error_number int
SET @error_number=error_number()
SET @msg_err=''


if @flag='i'
		SET @msg_err='Fail Insert Data.'
ELSE if @flag='u'
		SET @msg_err='Fail Update Data.'
ELSE if @flag='d'
		SET @msg_err='Fail Delete Data.'
		Exec spa_ErrorHandler @error_number, 'Minor Location Detail', 
					'spa_minor_location_detail', 'DB Error', 
					@msg_err, ''








