IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_invoice_lineitem_default_glcode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_invoice_lineitem_default_glcode]
 

GO
Create PROCEDURE [dbo].[spa_invoice_lineitem_default_glcode]
	@flag char(1),
	@default_id int=NULL,
	@invoice_line_item_id int=NULL,
	@sub_id int=NULL,
	@default_gl_id int=NULL,
	@estimated_actual char(1)=NULL

AS 
BEGIN

declare @sql varchar(5000)

if @flag='s'
BEGIN
	set @sql= '
	select 
		default_id [ID],ph.entity_name [Subsidiary],sd.description [Contract Components],sd1.description [GL Account],
			case when a.estimated_actual=''a'' then ''Actual''
				 when a.estimated_actual=''e'' then ''Estimated''
				 when a.estimated_actual=''c'' then ''Cash Applied''
				when a.estimated_actual=''b'' then ''Both'' end as [Estimated/Actual]

	from 
		invoice_lineitem_default_glcode a left join 
		static_data_value sd on a.invoice_line_item_id=sd.value_id
		left join portfolio_hierarchy ph on ph.entity_id=a.sub_id
		left join adjustment_default_gl_codes adgc on a.default_gl_id=adgc.default_gl_id
		left join static_data_value sd1 on adgc.adjustment_type_id=sd1.value_id 
	where 1=1 '
		+case when @sub_id is not null then ' AND sub_id='+cast(@sub_id as varchar) else '' end
	exec(@sql)
		
END
else if @flag='a'
BEGIN
	
	select 
		default_id,sub_id,invoice_line_item_id,default_gl_id,estimated_actual
	from 
		invoice_lineitem_default_glcode 
	where default_id=@default_id
			

END	
else if @flag='c' -- select for combo box value
BEGIN
	
	select 
		default_gl_id
	from 
		invoice_lineitem_default_glcode 
	where sub_id=@sub_id and invoice_line_item_id=@invoice_line_item_id
			

END	
else if @flag='i'
BEGIN
	insert into invoice_lineitem_default_glcode(
		invoice_line_item_id,
		sub_id,
		default_gl_id,
		estimated_actual
	)
	select
		@invoice_line_item_id,
		@sub_id,	
		@default_gl_id,
		@estimated_actual

	If @@ERROR <> 0
		Begin
		Exec spa_ErrorHandler @@ERROR, 'Setup default gl code', 
		'spa_invoice_lineitem_default_glcode', 'DB Error', 
		'Failed updating record.', ''
		End
	Else
	Begin
		Exec spa_ErrorHandler 0, 'Setup default gl code', 

		'spa_invoice_lineitem_default_glcode', 'Success', 
		'Record successfully updated.', ''
	End
END

else if @flag='u'
BEGIN
	update invoice_lineitem_default_glcode
		set 
		invoice_line_item_id=@invoice_line_item_id,
		sub_id=@sub_id,
		default_gl_id=@default_gl_id,
		estimated_actual=@estimated_actual
	where
		default_id=@default_id

	If @@ERROR <> 0
		Begin
		Exec spa_ErrorHandler @@ERROR, 'Setup default gl code', 
		'spa_invoice_lineitem_default_glcode', 'DB Error', 
		'Failed updating record.', ''
		End
	Else
	Begin
		Exec spa_ErrorHandler 0, 'Setup default gl code', 

		'spa_invoice_lineitem_default_glcode', 'Success', 
		'Record successfully updated.', ''
	End

END

else if @flag='d'
BEGIN
	delete from  invoice_lineitem_default_glcode
		where
		default_id=@default_id


	If @@ERROR <> 0
		Begin
		Exec spa_ErrorHandler @@ERROR, 'Setup default gl code', 
		'spa_invoice_lineitem_default_glcode', 'DB Error', 
		'Failed deleting record.', ''
		End
	Else
	Begin
		Exec spa_ErrorHandler 0, 'Setup default gl code', 

		'spa_invoice_lineitem_default_glcode', 'Success', 
		'Record successfully deleted.', ''
	End

END

ELSE IF @flag = 'g' 
BEGIN
	SELECT	ildg.default_id,
			sdv.code ,
			ph.entity_name,
	       
	       CASE 
	            WHEN ildg.estimated_actual = 'a' THEN 'Actual'
	            WHEN ildg.estimated_actual = 'e' THEN 'Estimated'
	            WHEN ildg.estimated_actual = 'c' THEN 'Cash Applied'
	            WHEN ildg.estimated_actual = 'b' THEN 'Both'
	       END AS estimated_actual,
		   sd.code + 
				CASE WHEN ildg.estimated_actual = 'a' THEN ' -> Actual' 
					WHEN  ildg.estimated_actual = 'e' THEN ' -> Estimated' 
					WHEN  ildg.estimated_actual = 'c' THEN ' -> Cash Applied' 
					WHEN  ildg.estimated_actual = 'b' THEN ' -> Both'
				ELSE '' 
				END default_gl_id
	FROM   invoice_lineitem_default_glcode ildg
			INNER JOIN static_data_value sdv
	            ON  sdv.value_id = ildg.invoice_line_item_id
	            AND sdv.[type_id] = 10019
			LEFT JOIN portfolio_hierarchy ph
	            ON  ph.entity_id = ildg.sub_id
	            AND ph.hierarchy_level = 2
			LEFT JOIN adjustment_default_gl_codes adj  
				ON adj.default_gl_id = ildg.default_gl_id
			LEFT JOIN static_data_value sd 
				ON adj.adjustment_type_id = sd.value_id
	ORDER BY sdv.code ASC 


END 

END




