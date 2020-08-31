Declare 
@report_id_1 INT, 
@report_id_2 INT
 
SET @report_id_1 = (SELECT report_id FROM report WHERE NAME = 'Gas Storage Position Report')
EXEC spa_rfx_report_dhx  @flag='d',@report_id = @report_id_1, @process_id=NULL    
 

SET @report_id_2 = (SELECT report_id FROM report WHERE NAME = 'Option Greeks Report')
EXEC spa_rfx_report_dhx  @flag='d',@report_id = @report_id_2, @process_id=NULL
