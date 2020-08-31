IF OBJECT_ID ('[dbo].[maxId]','fn') IS NOT NULL
DROP FUNCTION [dbo].[maxId]
GO

CREATE  function [dbo].[maxId]()
returns varchar(500) as
begin
declare @max_id  varchar(500)

select @max_id = isnull(max(requirements_revision_id),1)+1   from process_requirements_revisions

return @max_id
end

