if object_id('[dbo].[spa_control_activities_proof_view]','p') is not null
drop proc [dbo].[spa_control_activities_proof_view]
go
/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/


CREATE proc [dbo].[spa_control_activities_proof_view]
                                   	@asOfDate varchar(200)=null, 
                                    @riskControlID int=null,
                                    @unapprovedRole char(1)=null,
                                    @notes_id int=null
                                     
                                    
                                
AS
   
declare @sqlStmt varchar(5000)
declare @sqlStmt1 varchar(5000)

declare @note_object_id_u varchar(100)
declare @note_object_id_r varchar(100)

set @note_object_id_u = ''''+cast(@riskControlID as varchar) + '-' + ''+@asOfDate+'' + '-' + 'u'+''''

set @note_object_id_r = ''''+cast(@riskControlID as varchar) + '-' + ''+@asOfDate+'' + '-' + 'r'+''''


BEGIN

  set @sqlStmt = 'SELECT CAST(an.notes_id as varchar) As ''ID'','
  set @sqlStmt = @sqlStmt + 'an.notes_subject ''Subject'',' 
  set @sqlStmt = @sqlStmt + 'an.category_value_id ''CategoryId'','
  set @sqlStmt = @sqlStmt + 'an.notes_text ''Text'','
  set @sqlStmt = @sqlStmt + 'dbo.FNADateFormat(an.create_ts) As Date,'
  set @sqlStmt = @sqlStmt + '(au.user_l_name + '', '' + au.user_f_name + '' '' + au.user_m_name) As  ''User'','
  set @sqlStmt = @sqlStmt + 'isnull(an.attachment_file_name,'''') As Attachment,'
  set @sqlStmt = @sqlStmt + '''E-mail'' As Action '
  set @sqlStmt = @sqlStmt +  'FROM application_notes an inner join  application_users au on an.create_user = au.user_login_id  '
  set @sqlStmt = @sqlStmt +  'WHERE notes_object_name = ''Process'' AND internal_type_value_id = 31'

  if(upper(@unapprovedRole) = 'U')
   
     set @sqlStmt = @sqlStmt + ' AND notes_object_id =' + @note_object_id_u

  if(upper(@unapprovedRole) = 'R')
     set @sqlStmt = @sqlStmt + ' AND notes_object_id =' + @note_object_id_r

  if(@notes_id is not null)
     set @sqlStmt = @sqlStmt + ' AND notes_id =' + cast(@notes_id as varchar)
 
      set @sqlStmt = @sqlStmt + ' ORDER BY an.create_ts DESC, an.notes_id DESC '
exec(@sqlStmt)



  --print @sqlStmt
                
END





