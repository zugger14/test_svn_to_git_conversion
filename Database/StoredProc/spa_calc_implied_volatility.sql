IF OBJECT_ID('[dbo].[spa_calc_implied_volatility]','p') IS NOT NULL
DROP PROC [dbo].[spa_calc_implied_volatility]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE procedure [dbo].[spa_calc_implied_volatility]
@flag char(1),
@calc_implied_volatility_id int=null,
@option_type char(1)=null,
@exercise_type char(1)=null,
@commodity_id int=null,
@curve_id int= null,
@term varchar(100)=null,
@expiration varchar(100)=null,
@strike float=null,
@premium float=null,
@seed float=null

As
declare @sql varchar(1000)

IF @option_type IS NULL  
	SET @option_type='c'

IF @exercise_type IS NULL  
	SET @exercise_type='a'

if @flag='s'
Begin
	select calc_implied_volatility_id,case when option_type='c' then 'Call' else 'Put' end [Options],
			  case when exercise_type='a' then 'American' else 'European' end [Excercise Type],
			  commodity_id [Commodity],
			  curve_id [Index],
			  dbo.fnadateformat(term) [Term],
			  dbo.fnadateformat(expiration) [Expiration],
			  strike [Strike],
			  premium [Premium],
			  seed [Seed]
	from calc_implied_volatility

End

else if @flag='a'
Begin
	set @sql='select option_type [Options],
			  exercise_type [Excercise Type],
			  commodity_id [Commodity],
			  curve_id [Index],
			  dbo.fnadateformat(term) [Term],
			  dbo.fnadateformat(expiration) [Expiration],
			  strike [Strike],
			  premium [Premium],
			  seed [Seed]
	from calc_implied_volatility where 1=1'

	if @calc_implied_volatility_id is not null
		Begin
			set @sql=@sql+'and calc_implied_volatility_id='+@calc_implied_volatility_id
		End

	exec(@sql)
End

else if @flag='i'
Begin
	insert into calc_implied_volatility(option_type,exercise_type,commodity_id,curve_id,term,expiration,strike,premium,seed)
	values(@option_type,@exercise_type,@commodity_id,@curve_id,@term,@expiration,@strike,@premium,@seed)

	if @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'Calculate Implied Volatility', 
				'spa_calc_implied_volatility', 'DB Error', 
				'Failed to insert Calculate Implied Volatility.',''
		Else
		Exec spa_ErrorHandler 0, 'Calculate Implied Volatility ', 
				'spa_calc_implied_volatility', 'Success', 
				'Calculate Implied Volatility inserted.',''


End

else if @flag='u'
Begin
	update 	calc_implied_volatility set option_type = @option_type,
										exercise_type = @exercise_type,
										commodity_id = @commodity_id,
										curve_id = @curve_id,
										term = @term,
										expiration = @expiration,
										strike = @strike,
										premium = @premium,
										seed=@seed

					where calc_implied_volatility_id = @calc_implied_volatility_id

		if @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'Calculate Implied Volatility', 
				'spa_calc_implied_volatility', 'DB Error', 
				'Failed to update Calculate Implied Volatility.',''
		Else
		Exec spa_ErrorHandler 0, 'Calculate Implied Volatility ', 
				'spa_calc_implied_volatility', 'Success', 
				'Calculate Implied Volatility updated.',''


End

else if @flag='d'
Begin
	delete from calc_implied_volatility where calc_implied_volatility_id = @calc_implied_volatility_id

	if @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'Calculate Implied Volatility', 
				'spa_calc_implied_volatility', 'DB Error', 
				'Failed to delete Calculate Implied Volatility.',''
		Else
		Exec spa_ErrorHandler 0, 'Calculate Implied Volatility ', 
				'spa_calc_implied_volatility', 'Success', 
				'Calculate Implied Volatility deleted.',''


End
else if @flag='c'
BEGIN
	--select NULL as [Term],NULL as [Curve],NULL as [Value],NULL as [Currency]
		SELECT calc_implied_volatility_id,term [Term],curve_id [Curve],premium [Value],seed [Currency] FROM calc_implied_volatility
		WHERE option_type ='p'
END

ELSE IF @flag='p'
BEGIN
	INSERT INTO calc_implied_volatility(option_type,term,curve_id,premium,seed)
	VALUES('p',@term,@curve_id,@premium,@seed)

	IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error, 'Calculate Incremental Var', 
				'spa_calc_implied_volatility', 'DB Error', 
				'Failed to insert Incremental Var Data.',''
		ELSE
		EXEC spa_ErrorHandler 0, 'Calculate Incremental Var ', 
				'spa_calc_implied_volatility', 'Success', 
				'ncremental Var Data inserted.',''


END

