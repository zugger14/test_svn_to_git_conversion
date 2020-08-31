
if object_id('dbo.FNAReverseCommaSeparatedString','fn') is not null
drop function dbo.FNAReverseCommaSeparatedString
go
/*
Author : Vishwas Khanal
Dated  : 14.Aug.2009
Desc   : This will get reverese the Comma Seperated String from right to left.
*/
create function dbo.FNAReverseCommaSeparatedString(@a varchar(8000))
returns varchar(8000)
as
begin
--declare @a varchar(8000)
declare @reverse varchar(8000)
declare @table table (sno int identity(1,1),item varchar(8000))


insert into @table select item from dbo.splitCommaSeperatedValues(@a)

select @reverse = isnull(@reverse+',','') + item from @table order by sno desc
return @reverse
end

--select dbo.FNAReverseCommaSeparatedString('a,b,c,d,e,f,g')