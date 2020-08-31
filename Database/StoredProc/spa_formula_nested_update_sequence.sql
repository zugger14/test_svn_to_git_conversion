IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_formula_nested_update_sequence]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_formula_nested_update_sequence]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================
-- Create date: 2011-02-21
-- Description:	Updates sequence in nested formulae and its reference in ROW() function when formula is added/updated/deleted.
-- Params:
--	@flag - 
--		i: insert u: update d: delete
--	@formula_group_id - 
--	@nested_id - formula item to be operated (eg. deleted)
--	@after_seq - In case of insert/update, new/updated formula will be put after @after_seq, in case of delete
--				, it is the item to be deleted
--	@old_seq - Old sequence value before updating any formula sequence
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_formula_nested_update_sequence] 
	@flag CHAR(1), 
	@formula_group_id INT = 0,
	@nested_id INT = NULL,
	@after_seq INT = NULL,
	@old_seq INT = NULL
AS

SET NOCOUNT OFF;
DECLARE @sequence_flag CHAR(1)

IF @flag = 'i'
BEGIN
	--update the sequence first
	UPDATE formula_nested SET sequence_order = sequence_order + 1
	WHERE sequence_order > @after_seq AND formula_group_id = @formula_group_id

	/*
	* Increment the sequence no in ROW() function. If a new function is inserted after 3 (@after_seq = 3),
	* then sequence after @after_seq (i.e. starting from 4) will have their sequence incremented by last statement, i.e.
	* previous 4 becomes 5, 5 becomes 6 and so on. So previous Row(4) used in any formula needs to be replaced
	* by Row(5). So, sequence under Row() function will be incremented starting from @after_seq + 1 (4)
	*/
	UPDATE formula_editor
	SET formula = dbo.FNAUpdateRowIDInFormula('i', fe.formula_id, fn.sequence_order, @after_seq + 1, NULL) 
	FROM formula_editor fe
	INNER JOIN formula_nested fn ON fe.formula_id = fn.formula_id
	WHERE fn.sequence_order > @after_seq AND formula_group_id = @formula_group_id
END
ELSE IF @flag = 'd'
BEGIN
	--read sequence of to-be-deleted item
	SELECT @after_seq = sequence_order
	FROM formula_nested
	WHERE id = @nested_id
	
	EXEC spa_print '@after_seq:', @after_seq
	
	/*
	* Update the orphaned ROW() with Undefined, the order of execution is important here. If sequence 3 (i.e. @after_seq = 3)
	* is to be deleted, then all formula using Row(3) needs to be replaced by Row(Undefined) as sequence will be deleted.
	*/
	UPDATE formula_editor
	SET formula = dbo.FNAUpdateRowIDInFormula('o', fe.formula_id, fn.sequence_order, @after_seq, NULL) 
	FROM formula_editor fe
	INNER JOIN formula_nested fn ON fe.formula_id = fn.formula_id
	WHERE fn.sequence_order > @after_seq AND formula_group_id = @formula_group_id
	
	--update the sequence, every sequence after @after_seq will be decremented
	UPDATE formula_nested SET sequence_order = sequence_order - 1
	WHERE sequence_order > @after_seq AND formula_group_id = @formula_group_id

	/*
	* Decrement the sequence no in ROW() function. If a function at 3rd sequence (@after_seq = 3) is deleted,
	* then sequence after @after_seq (i.e. starting from 4) will have their sequence decremented by last statement, i.e.
	* previous 4 becomes 3, 5 becomes 4 and so on. So previous Row(4) used in any formula needs to be replaced
	* by Row(3). So, sequence under Row() function will be decremented starting from @after_seq + 1 (4). Be sure to 
	* include seq 4 for update, as it is seq 5 orginally, but decremented by last statement (fn.sequence_order >= @after_seq).
	*/
	UPDATE formula_editor
	SET formula = dbo.FNAUpdateRowIDInFormula('d', fe.formula_id, fn.sequence_order, @after_seq + 1, NULL) 
	FROM formula_editor fe
	INNER JOIN formula_nested fn ON fe.formula_id = fn.formula_id
	WHERE fn.sequence_order >= @after_seq AND formula_group_id = @formula_group_id
		AND fn.id <> @nested_id
END
ELSE IF @flag = 'u'
BEGIN
	DECLARE @min_seq INT
	DECLARE @max_seq INT
	DECLARE @direction TINYINT -- 0: moving downward, 1: moving upward			
	SET @direction = 0
	
	IF (@old_seq <> @after_seq) --if sequence not updated, no need to do shifting
	BEGIN 
		IF (@old_seq > @after_seq)
			SET @direction = 1
				
		IF (@direction = 0) --edited item being moved downward, so need to shift other effected items upward
		BEGIN
			/*
			eg. @old_seq = 2, @after_seq = 5 i.e. item at 2nd index is to be put after 5th item (or at 6th index).
			So indexes between 3 to 5 has to be shifted upward to make room for old 2nd indexed item.
			The new index of that item will be 5
			*/
			UPDATE formula_nested
			SET sequence_order = sequence_order - 1
			WHERE formula_group_id = @formula_group_id
			AND sequence_order BETWEEN @old_seq + 1 AND @after_seq
			
			SET @min_seq = @old_seq
			SET @max_seq = @after_seq
			
			SET @sequence_flag = 'd'
		END
		ELSE  --edited item being moved upward, so need to shift other effected items downward
		BEGIN
			/*
			eg. @old_seq = 5, @after_seq = 1 i.e. item at 5th index is to be put after 1th item (or at2nd index).
			So indexes between 2 to 4 has to be shifted downward to make room for old 5th indexed item.
			The new index of that item will be 2
			*/
			UPDATE formula_nested
			SET sequence_order = sequence_order + 1
			WHERE formula_group_id = @formula_group_id
			AND sequence_order BETWEEN @after_seq + 1 AND @old_seq - 1
			
			SET @min_seq = @after_seq + 1
			SET @max_seq = @old_seq
			
			SET @sequence_flag = 'i'
		END
		
		DECLARE @new_seq int
		SET @new_seq  = (CASE WHEN @old_seq > @after_seq --moving upward
								THEN @after_seq + 1 
								ELSE @after_seq END)
		
		EXEC spa_print '@min_seq:', @min_seq, '@max_seq:', @max_seq
		
		/*
		* Hash references of sequence of currently updated formula to prevent from alternation from incrementation/decrementation
		* eg. for eg. if old sequence 4 is going to be updated, hash its usage, means put Row(###) in all Row(4) instance
		* in that formula group
		*/
		UPDATE formula_editor
		SET formula = dbo.FNAUpdateRowIDInFormula('h', fe.formula_id, fn.sequence_order, @old_seq, @after_seq) 
		FROM formula_editor fe
		INNER JOIN formula_nested fn ON fe.formula_id = fn.formula_id
		WHERE formula_group_id = @formula_group_id
			AND fn.sequence_order >= @min_seq
			AND fn.formula_id <> @nested_id
		
		--increment or decrement sequence in ROW() function
		UPDATE formula_editor
		SET formula = dbo.FNAUpdateRowIDInFormula(@sequence_flag , fe.formula_id, fn.sequence_order, @min_seq, @max_seq) 
		FROM formula_editor fe
		INNER JOIN formula_nested fn ON fe.formula_id = fn.formula_id
		WHERE formula_group_id = @formula_group_id AND fn.sequence_order >= @min_seq
			AND fn.id <> @nested_id
		
		--revert changes done by hashing, replace Row(###) by updated sequence. If old seq 4 is moved to new seq 9, 
		--then Row(###) will be replaced by Row(9)
		UPDATE formula_editor
		SET formula = dbo.FNAUpdateRowIDInFormula('r', fe.formula_id, fn.sequence_order, @old_seq, @new_seq)  
		FROM formula_editor fe
		INNER JOIN formula_nested fn ON fe.formula_id = fn.formula_id
		WHERE formula_group_id = @formula_group_id
			AND fn.sequence_order >= @min_seq
			AND fn.formula_id <> @nested_id 
		
		--update sequence of the current formula (which is relocated) to check for Undefined. Many ROW() references may break 
		--due to sequence change, mark them Undefined if they are orphaned
		UPDATE formula_editor
		SET formula = dbo.FNAUpdateRowIDInFormula('u', fe.formula_id, @new_seq, @min_seq, @max_seq)  
		FROM formula_editor fe
		INNER JOIN formula_nested fn ON fe.formula_id = fn.formula_id
		WHERE fn.id = @nested_id 
	END
END

GO
