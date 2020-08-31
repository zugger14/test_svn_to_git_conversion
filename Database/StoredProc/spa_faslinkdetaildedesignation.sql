IF OBJECT_ID(N'spa_faslinkdetaildedesignation', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_faslinkdetaildedesignation]
 GO 








-- EXEC spa_faslinkdetaildedesignation 's', 697
-- EXEC spa_faslinkdetaildedesignation 'u', 111, 110, 1.1, '9/24/2004'
-- EXEC spa_faslinkdetaildedesignation 'i', 80, 52, 1, '1/1/2004'


create proc [dbo].[spa_faslinkdetaildedesignation]
@flag char(1),
@link_id int=NULL,
@dedesignated_link_id int=NULL, 
@percentage_dedesignated float=NULL,
@effective_date datetime=NULL AS


DECLARE @percentage_available float
DECLARE @error_message VARCHAR(100)

If @flag = 's'
begin
-- 	select *
-- 	from fas_link_detail_dedesignation
-- 	where link_id = @link_id

SELECT  flh.original_link_id AS DeDesignatedID, 
		dbo.FNAHyperLinkText(10233710, isnull(flh1.link_description, cast(flh1.link_id as varchar)), flh1.link_id) AS DeDesignatedDesc,
		cast(round(flh.dedesignated_percentage, 2) as varchar) AS PercDedesignated, 
		dbo.FNADateFormat(flh.link_effective_date) AS EffDate, 
		flh.create_user AS CreateBy, 
		dbo.FNADateFormat(flh.create_ts) AS CreateTS, 
		flh.update_user AS UpdateBy, 
		dbo.FNADateFormat(flh.update_ts) AS UpdateTS,
		flh.link_id As LinkID	
FROM   fas_link_header flh inner join
		fas_link_header 	flh1 on flh1.link_id = flh.original_link_id
WHERE  flh.link_id = @link_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Link Dedesignation table', 
				'spa_faslinkdetaildedesignation', 'DB Error', 
				'Failed to select Link Dedesignation record.', ''
-- 	Else
-- 		Exec spa_ErrorHandler 0, 'Link Dedesignation Table', 
-- 				'spa_faslinkdetaildedesignation', 'Success', 
-- 				'Link Dedesignation records successfully selected.', ''
End
Else if @flag = 'i'
begin
	--select 'in here'
	--check to make sure total percentage_dedesignated does not exceed 100%
	SET @percentage_available = 1.0

	SELECT    @percentage_available = (1.0 - isnull(SUM(percentage_dedesignated), 0))
	FROM      fas_link_detail_dedesignation
	WHERE     link_id = @link_id
	
	If @percentage_dedesignated > @percentage_available
	BEGIN	
		SET @error_message = 'De-designation  relationship: ' + cast(@link_id as varchar) + 
					' can only be included up to: ' + cast(@percentage_available as varchar)

		Select 'Error' As ErrorCode, 'Link detail' As Module, 
					'spa_fas_link-detail' AS Area , 'Application Error' AS Status,
			('Failed to Insert De-designation record. ' + @error_message) AS Message, @error_message AS Recommendation
		--RETURN
	END
	ELSE
	BEGIN
		--RETURN
		insert into fas_link_detail_dedesignation
			(link_id,
			dedesignated_link_id,
			percentage_dedesignated,
			effective_date)
		values 
			(@link_id,
			@dedesignated_link_id,
			@percentage_dedesignated,
			@effective_date)
	
		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, 'Link Dedesignation table', 
					'spa_faslinkdetaildedesignation', 'DB Error', 
					'Failed to Insert Link Dedesignation record.', ''
		Else
			Exec spa_ErrorHandler 0, 'Link Dedesignation Table', 
					'spa_faslinkdetaildedesignation', 'Success', 
					'Link Dedesignation records successfully Inserted.', ''
	END
end	

Else if @flag = 'u'
begin


	--check to make sure total percentage_dedesignated does not exceed 100%
	SET @percentage_available = 1.0

	SELECT    @percentage_available = (1.0 - isnull(SUM(percentage_dedesignated), 0))
	FROM      fas_link_detail_dedesignation
	WHERE     link_id = @link_id AND dedesignated_link_id <> @dedesignated_link_id AND
			effective_date <> @effective_date
	
	If @percentage_dedesignated > @percentage_available
	BEGIN	
		SET @error_message = 'De-designation  relationship: ' + cast(@link_id as varchar) + 
					' can only be included up to: ' + cast(@percentage_available as varchar)

		Select 'Error' As ErrorCode, 'Link detail' As Module, 
					'spa_fas_link-detail' AS Area , 'Application Error' AS Status,
			('Failed to Insert De-designation record. ' + @error_message) AS Message, @error_message AS Recommendation
		--RETURN
	END
	ELSE
	BEGIN
		--RETURN
		Update fas_link_detail_dedesignation
		Set link_id=@link_id,
			dedesignated_link_id=@dedesignated_link_id,
			percentage_dedesignated=@percentage_dedesignated,
			effective_date=@effective_date
		Where 	link_id = @link_id and
			dedesignated_link_id = @dedesignated_link_id
		
		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, 'Link Dedesignation table', 
					'spa_faslinkdetaildedesignation', 'DB Error', 
					'Failed to update Link Dedesignation record.', ''
		Else
			Exec spa_ErrorHandler 0, 'Link Dedesignation Table', 
					'spa_faslinkdetaildedesignation', 'Success', 
					'Link Dedesignation records successfully Updated.', ''
	END
end	

Else if @flag = 'd'
begin

	declare @min_as_of_date datetime
	declare @closed_book_count int


	select @effective_date = effective_date from fas_link_detail_dedesignation
	Where 	link_id = @link_id and dedesignated_link_id = @dedesignated_link_id

	create table #max_date (as_of_date datetime)
	declare @st_where varchar(100)
	set @st_where ='as_of_date>='''+@effective_date+''' and link_id='+cast(@dedesignated_link_id as varchar)
--print @st_where
	insert into #max_date (as_of_date) exec  spa_get_Script_ProcessTableFunc 'max','as_of_date','report_measurement_values',@st_where
	select @min_as_of_date = dbo.FNAGetSQLStandardDate(max(as_of_date)) from #max_date





--	select @min_as_of_date = min(as_of_date) from report_measurement_values
--	where link_id = @dedesignated_link_id and as_of_date >= @effective_date


	if @min_as_of_date is not null
	begin
		SELECT     @closed_book_count  = COUNT(*) 
		FROM         close_measurement_books
		WHERE     (as_of_date >= 
			CAST (dbo.FNAGetContractMonth(@min_as_of_date) as datetime))

		
		if (isnull(@closed_book_count, 0) > 0)
		begin
			Select 'Error' ErrorCode, 'Dedesignation' Module, 'spa_get_percentage_dedesignation' Area, 
				'Error' Status, 
				'The selected dedesignation can not be deleted as the measurement book has already been closed.' Message, 
				'Please unclose the measurement book before deleting.' Recommendation

			return
		end
	end


	EXEC spa_delete_calc_values_for_dedesignation_link @dedesignated_link_id

	delete from fas_link_detail_dedesignation
	Where 	link_id = @link_id and
		dedesignated_link_id = @dedesignated_link_id
		
	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Link Dedesignation table', 
				'spa_faslinkdetaildedesignation', 'DB Error', 
				'Failed to delete Link Dedesignation record.', ''
	Else
		Exec spa_ErrorHandler 0, 'Link Dedesignation Table', 
				'spa_faslinkdetaildedesignation', 'Success', 
				'Link Dedesignation records successfully deleted.', ''
end














