-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--drop proc spa_edr_file_import_prototype
--go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_edr_file_import_prototype]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_edr_file_import_prototype]
GO 

create proc [dbo].[spa_edr_file_import_prototype]
as
declare @max_col tinyint
declare @i tinyint
declare @st varchar(8000)
set @i=1
select @max_col=max(sub_type_id) from edr_file_import_prototype
set @st='select record_type_code,'
while @i<=@max_col
begin
	set @st=@st+' max(case sub_type_id when '+cast(@i as varchar) +' then start_position else 0 end) as s'+cast(@i as varchar)+', max(case sub_type_id when '+cast(@i as varchar) +' then data_length else 0 end) as l'+cast(@i as varchar)+', max(case sub_type_id when '+cast(@i as varchar) +' then uom_id else 0 end) as u'+cast(@i as varchar)+', max(case sub_type_id when '+cast(@i as varchar) +' then curve_id else 0 end) as c'+cast(@i as varchar)+','
	set @i=@i+1
end
set @st=substring(@st,1,len(@st)-1)+ ' from edr_file_import_prototype group by record_type_code'
exec spa_print @st
EXEC(@st)



