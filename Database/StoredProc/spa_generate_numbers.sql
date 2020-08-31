--exec spa_generate_numbers 1000
/******
		Created by: Bikash Subba 
		Object: Generate integer number to populate in combo box 

******/
/****** Object:  StoredProcedure [dbo].[spa_generate_numbers]    Script Date: 03/09/2009 16:37:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_generate_numbers]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_generate_numbers]
go
Create procedure [dbo].[spa_generate_numbers]
@upto int=null
As
declare @num int
Begin
	set @num=1;
	create table #temp (num int,num1 int)
	while @num<=@upto
	Begin
		insert into #temp values (@num,@num)
		set @num=@num+1;
	end
	select * from #temp

End