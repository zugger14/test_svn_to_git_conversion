/****** Object:  StoredProcedure [dbo].[spa_system_formula]    Script Date: 03/24/2009 17:42:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_system_formula]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_system_formula]
go
--exec spa_system_formula 'a',null,327
-- spa_system_formula 'r',NULL,NULL
--exec spa_system_formula 'f',NULL,NULL
--exec spa_system_formula 's',NULL,NULL
--exec spa_system_formula 'd',NULL,317
--spa_system_formula 'c',
--select * from system_formula

CREATE PROCEDURE [dbo].[spa_system_formula]
@flag CHAR, -- i : Insert,s: Combo Change Event , f: Grid Populate, r: report,a : Append, u : Update, d: Delete
@dealType INT,
@formulaId INT = NULL
AS
DECLARE @errorCode INT
DECLARE @sql VARCHAR(MAX)
BEGIN
	IF @flag = 'i'
	BEGIN
		IF EXISTS (SELECT 'x' FROM dbo.system_formula WHERE dealType = @dealType)
			UPDATE dbo.system_formula SET formulaId = @formulaId WHERE dealType = @dealType
		ELSE
		BEGIN
			INSERT INTO dbo.system_formula (dealType,formulaId) VALUES (@dealType,@formulaId)			
			UPDATE dbo.formula_editor SET system_defined = 'y' WHERE formula_id = @formulaId
		END

		Set @errorCode = @@ERROR
			If @errorCode <> 0
				Exec spa_ErrorHandler @errorCode, 'System Formula', 
						'spa_system_formula', 'DB Error', 
						'Failed to insert System Formula.', ''
			Else
				Exec spa_ErrorHandler 0, 'StaticDataMgmt', 
						'spa_system_formula', 'Success', 
						'System Formula inserted.', ''
			End
	
	ELSE IF @flag = 's'
	BEGIN
		IF @dealType IS NULL
			SELECT NULL 'FormulaId'
		ELSE
		BEGIN
			IF EXISTS (SELECT 'x' FROM dbo.system_formula WHERE dealType = @dealType)
			BEGIN
				SELECT formulaId 'FormulaId' FROM dbo.system_formula WHERE dealType = @dealType
			END
			ELSE
				SELECT NULL 'FormulaId'			
		END
	END
	ELSE IF @flag = 'f'
	BEGIN		
		SELECT 
			distinct fe.formula_id [Formula ID],
			dt.source_deal_type_name [Deal Type],
			sf.dealtype [Deal Type],
			--CASE WHEN fn.formula_id IS NOT NULL THEN 'Nested Formula' ELSE ISNULL(fe.formula_name,fe.formula)  END AS [Formula]
			CASE WHEN fe.formula_type='n' THEN 'Nested Formula' ELSE ISNULL(fe.formula_name,dbo.FNAFormulaFormat(fe.formula,'r'))  END AS [Formula],
			fe.formula_type
		from 
			system_formula sf 
			inner join source_deal_type dt on dt.source_deal_type_id=sf.dealType
			--LEFT JOIN formula_nested fn on fn.formula_group_id=sf.formulaId
			LEFT JOIN formula_editor fe on fe.formula_id=sf.formulaId

		WHERE 
			sf.formulaId=fe.formula_id	

	
	END

	ELSE IF @flag = 'c'	-- for use in Maintain Contract Detail window
	BEGIN		
		IF EXISTS (		
			SELECT 'x'	from system_formula sf 
				inner join source_deal_type dt on dt.source_deal_type_id=sf.dealType
				LEFT JOIN formula_editor fe on fe.formula_id=sf.formulaId
			WHERE 
				sf.formulaId=fe.formula_id
				and dealType = @dealType
		)
		begin
			SELECT 
				distinct fe.formula_id [Formula ID],
				dt.source_deal_type_name [Deal Type Name],
				sf.dealtype [Deal Type],
				--CASE WHEN fn.formula_id IS NOT NULL THEN 'Nested Formula' ELSE ISNULL(fe.formula_name,fe.formula)  END AS [Formula]
				CASE WHEN fe.formula_type='n' THEN 'Nested Formula' ELSE ISNULL(fe.formula_name,dbo.FNAFormulaFormat(fe.formula,'r'))  END AS [Formula],
				fe.formula_type as [Formula Type]	
			from 
				system_formula sf 
				inner join source_deal_type dt on dt.source_deal_type_id=sf.dealType
				--LEFT JOIN formula_nested fn on fn.formula_group_id=sf.formulaId
				LEFT JOIN formula_editor fe on fe.formula_id=sf.formulaId

			WHERE 
				sf.formulaId=fe.formula_id
				and dealType = @dealType
		end
		else
		begin
			select null [Formula ID],null [Deal Type Name], null [Deal Type], null [Formula], null [Formula Type]
		end

	
	END
	
	ELSE IF @flag = 'r'
	BEGIN		
		SELECT dt.source_deal_type_name [Deal Type], CASE WHEN fe.formula_type='n' THEN 'Nested Formula' ELSE dbo.FNAFormulaFormat(fe.formula,'r') END as [Formula] from formula_editor fe 
		inner join system_formula sf on fe.formula_id=sf.formulaId
		inner join source_deal_type dt on dt.source_deal_type_id=sf.dealType
		WHERE sf.formulaId=fe.formula_id	

	
	END
	ELSE IF @flag = 'a'
	BEGIN		
		SELECT fe.formula_id [Formula ID],
		CASE WHEN fe.formula_type='n' THEN 'Nested Formula' ELSE fe.formula END as [Formula],
--		fe.formula [Formula],
		sf.dealtype [Deal Type] from formula_editor fe 
		inner join system_formula sf on fe.formula_id=sf.formulaId
		and sf.formulaId=fe.formula_id	
		WHERE formula_id = @formulaId
	end
	ELSE IF @flag = 'u'
	BEGIN	
		
		SET @sql = 'UPDATE system_formula
					SET formulaId = ' + cast(@formulaId AS VARCHAR(10)) + '
		            WHERE dealType = ' + cast(@dealType AS VARCHAR(10))
		EXEC spa_print @sql
		EXEC(@sql)
		Set @errorCode = @@ERROR
		--SELECT @errorCode,@dealType,@formulaId
			If @errorCode <> 0
				Exec spa_ErrorHandler @errorCode, 'System Formula', 
						'spa_system_formula', 'DB Error', 
						'Failed to update System Formula.', ''
			Else
				Exec spa_ErrorHandler 0, 'StaticDataMgmt', 
						'spa_system_formula', 'Success', 
						'System Formula updated.', ''
	END
							
	ELSE IF @flag = 'd'
	BEGIN		
		DELETE system_formula
		WHERE formulaId = @formulaId

	Set @errorCode = @@ERROR
			If @errorCode <> 0
				Exec spa_ErrorHandler @errorCode, 'System Formula', 
						'spa_system_formula', 'DB Error', 
						'Failed to delete System Formula.', ''
			Else
				Exec spa_ErrorHandler 0, 'StaticDataMgmt', 
						'spa_system_formula', 'Success', 
						'System Formula deleted.', ''
			
	END
END
