/****** Object:  StoredProcedure [dbo].[spa_major_location_detail]    Script Date: 01/20/2009 14:47:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_major_location_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_major_location_detail]
GO

CREATE PROC [dbo].[spa_major_location_detail]
@flag varchar(1),
@major_location_detail_id int=null,
@major_location_id int=null,
@owner Varchar(100)=null,
@operator varchar(100)=null,
@counterparty int=null,
@contract int=null,
@volume float=null,
@uom int=null

as
DECLARE @Sql_Select varchar(3000), @msg_err varchar(2000)
IF  @flag = 's'
		SELECT major_location_detail_id[Major Loc Detail ID],major_location_id [Major Loc ID],[owner] [Owner],operator [Operator],counterparty [Counterparty],[contract][Contract],volume [Volume],uom [UoM]
		FROM  major_location_detail 
		WHERE 1=1
IF  @flag = 'i'
	 INSERT INTO major_location_detail
			   (major_location_id,[owner],operator,counterparty,[contract],volume,uom)
		 VALUES
			   (@major_location_id,@owner,@operator,@counterparty,@contract,@volume,@uom)
ELSE IF  @flag = 'u'
		UPDATE major_location_detail
		   SET 
			major_location_id =@major_location_id,
			[owner]=@owner,
			operator =@owner,
			counterparty=@counterparty,
			[contract]=@contract,
			volume=@volume,
			uom=@uom
		 WHERE major_location_detail_id=@major_location_detail_id
			--where major_location_id=@major_location_id


ELSE IF  @flag = 'd'
		DELETE major_location_detail WHERE major_location_detail_id=@major_location_detail_id

ELSE IF  @flag = 'a'
		SELECT   major_location_detail_id,major_location_id,[owner],operator,counterparty,[contract],volume,uom
		  FROM major_location_detail
			WHERE 
				major_location_id=@major_location_id

	DECLARE @msg varchar(2000)
	SELECT @msg=''
	if @flag='i'
		SET @msg='Data Successfully Inserted.'
	ELSE if @flag='u'
		SET @msg='Data Successfully Updated.'
	ELSE if @flag='d'
		SET @msg='Data Successfully Deleted.'

	IF @msg<>''
		Exec spa_ErrorHandler 0, 'Major Location Detail ', 
				'spa_major_location_detail', 'Success', 
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
		Exec spa_ErrorHandler @error_number, 'Major Location Detail', 
					'spa_major_location_detail', 'DB Error', 
					@msg_err, ''





