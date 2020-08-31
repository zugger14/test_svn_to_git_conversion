IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_listReportWriterElements]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_listReportWriterElements]
GO 



CREATE PROC [dbo].[spa_ems_listReportWriterElements]
@flag char(1),
@name varchar(500)=NULL,
@id int=NULL,
@xType int=NULL

as

if @flag = 'U'
begin
	 select * from sysobjects where xtype=@flag order by name
end

if @flag='C' and @id is not null
begin
	select c.name, t.name as type from syscolumns c
left outer join systypes t on c.xtype=t.xtype
where c.id = @id order by c.name
end



