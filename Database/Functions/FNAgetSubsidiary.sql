if object_id('dbo.FNAGetSubsidiary','fn') is not null
drop function dbo.FNAGetSubsidiary
go
create function dbo.FNAGetSubsidiary
(@entityId int,@flag char(1)) 
returns varchar(1000)
begin
/*when flag = i : it will return the subsidiary ID
  when flag = n : it will return the subsidiary Name
  when flag = a : it will return the subsidiary Name/Strat Name/Book Name
*/		    declare @subsidiary varchar(1000)
			    
			select @subsidiary=case when @flag = 'i' then cast(sub.entity_id as varchar)
			when @flag = 'n' then sub.entity_name else sub.entity_name+'/'+stra.entity_name+'/'+book.entity_name end
			from portfolio_hierarchy book join 
             portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id INNER JOIN
             portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id 
			where book.entity_id = @entityId

			return ltrim(rtrim(@subsidiary))
end

--select * from portfolio_hierarchy

--select  dbo.FNAgetSubsidiary(228,'i')
--select  dbo.FNAgetSubsidiary(228,'n')
-- select  dbo.FNAgetSubsidiary(228,'a')


