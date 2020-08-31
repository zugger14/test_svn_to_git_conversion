SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_commodity_grade]') AND TYPE IN (N'P', N'PC'))
BEGIN
DROP PROCEDURE [dbo].[spa_commodity_grade]
END
GO 

CREATE PROCEDURE [dbo].[spa_commodity_grade]	
	@flag  CHAR(1),	
	@source_commodity_id INT = NULL,
	@xml TEXT  = NULL
AS 

SET NOCOUNT ON
DECLARE @sql_select VARCHAR(5000)

IF @flag = 'g'
BEGIN
	SELECT	commodity_origin_id [ID],
			co.origin [Origin],
			source_commodity_id
	FROM commodity_origin co
	INNER JOIN static_data_value sdv ON sdv.value_id = co.origin
	WHERE source_commodity_id = @source_commodity_id
END
ELSE IF @flag = 'f'
BEGIN
	SELECT	commodity_form_id [ID],
			cf.form [Form],
			co.commodity_origin_id
	FROM commodity_form cf
	INNER JOIN commodity_origin co ON co.commodity_origin_id = cf.commodity_origin_id
	WHERE cf.commodity_origin_id = @source_commodity_id
END
ELSE IF @flag = 'a'
BEGIN
	SELECT	a.commodity_form_attribute1_id [ID],
			a.attribute_id,
			a.attribute_form_id,
			a.commodity_form_id
	FROM commodity_form_attribute1 a
	INNER JOIN commodity_form cf ON cf.commodity_form_id = a.commodity_form_id
	WHERE cf.commodity_form_id = @source_commodity_id
END
ELSE IF @flag = 'b'
BEGIN
	SELECT	b.commodity_form_attribute2_id [ID],
			b.attribute_id,
			b.attribute_form_id,
			b.commodity_form_attribute1_id
	FROM commodity_form_attribute2 b
	INNER JOIN commodity_form_attribute1 a ON a.commodity_form_attribute1_id = b.commodity_form_attribute1_id
	WHERE b.commodity_form_attribute1_id = @source_commodity_id
END
ELSE IF @flag = 'c'
BEGIN
	SELECT	c.commodity_form_attribute3_id [ID],
			c.attribute_id,
			c.attribute_form_id,
			c.commodity_form_attribute2_id
	FROM commodity_form_attribute3 c
	INNER JOIN commodity_form_attribute2 b ON b.commodity_form_attribute2_id = c.commodity_form_attribute2_id
	WHERE b.commodity_form_attribute2_id = @source_commodity_id
END
ELSE IF @flag = 'd'
BEGIN
	SELECT	c.commodity_form_attribute4_id [ID],
			c.attribute_id,
			c.attribute_form_id,
			c.commodity_form_attribute3_id
	FROM commodity_form_attribute4 c
	INNER JOIN commodity_form_attribute3 b ON b.commodity_form_attribute3_id = c.commodity_form_attribute3_id
	WHERE b.commodity_form_attribute3_id = @source_commodity_id
END
ELSE IF @flag = 'e'
BEGIN
	SELECT	c.commodity_form_attribute5_id [ID],
			c.attribute_id,
			c.attribute_form_id,
			c.commodity_form_attribute4_id
	FROM commodity_form_attribute5 c
	INNER JOIN commodity_form_attribute4 b ON b.commodity_form_attribute4_id = c.commodity_form_attribute4_id
	WHERE b.commodity_form_attribute4_id = @source_commodity_id
END
ELSE IF @flag = 'h'
BEGIN
	IF EXISTS(
		SELECT  1 
		FROM commodity_form cf
		INNER JOIN  commodity_origin co ON co.commodity_origin_id = cf.commodity_origin_id
		WHERE co.source_commodity_id = @source_commodity_id
	)
	BEGIN
		SELECT 'false' [status]
	END
	ELSE
	BEGIN
		SELECT 'true' [status]
	END
END
ELSE IF @flag = 'v'
BEGIN
	BEGIN TRY
		DECLARE @idoc INT
		--SET @xml='<Root><FormXML commodity_origin_id="5" commodity_form_id="" commodity_form_attribute1_id="" commodity_form_attribute2_id="" commodity_form_attribute3_id="" commodity_form_attribute4_id="" commodity_form_attribute5_id=""></FormXML></Root>'
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		IF OBJECT_ID('tempdb..#commodity_grade_details') IS NOT NULL
			DROP TABLE #commodity_grade_details
		
		SELECT	NULLIF(commodity_origin_id, '')				[commodity_origin_id],
				NULLIF(commodity_form_id, '')				[commodity_form_id],
				NULLIF(commodity_form_attribute1_id, '')	[commodity_form_attribute1_id],
				NULLIF(commodity_form_attribute2_id, '')	[commodity_form_attribute2_id],
				NULLIF(commodity_form_attribute3_id, '')	[commodity_form_attribute3_id],
				NULLIF(commodity_form_attribute4_id, '')	[commodity_form_attribute4_id],
				NULLIF(commodity_form_attribute5_id, '')	[commodity_form_attribute5_id]
		INTO #commodity_grade_details
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
			commodity_origin_id					VARCHAR(20),
			commodity_form_id					VARCHAR(20),
			commodity_form_attribute1_id		VARCHAR(20),
			commodity_form_attribute2_id		VARCHAR(20),
			commodity_form_attribute3_id		VARCHAR(20),
			commodity_form_attribute4_id		VARCHAR(20),
			commodity_form_attribute5_id		VARCHAR(20)
		)

		DECLARE @origin_id INT, @form_id INT, @attribute1 INT, @attribute2 INT, @attribute3 INT, @attribute4 INT, @attribute5 INT
	
		SELECT	@origin_id = commodity_origin_id,
				@form_id = commodity_form_id,
				@attribute1 = commodity_form_attribute1_id, 
				@attribute2 = commodity_form_attribute2_id, 
				@attribute3 = commodity_form_attribute3_id, 
				@attribute4 = commodity_form_attribute4_id, 
				@attribute5 = commodity_form_attribute5_id
		FROM #commodity_grade_details
		
		DECLARE @commodity_origin_id INT
		DECLARE @commodity_form_id INT
		DECLARE @commodity_form_attribute1_id INT
		DECLARE @commodity_form_attribute2_id INT
		DECLARE @commodity_form_attribute3_id INT
		DECLARE @commodity_form_attribute4_id INT
		DECLARE @new_origin_id INT
		DECLARE @new_form_id INT
		DECLARE @attribute1_id INT
		DECLARE @attribute2_id INT
		DECLARE @attribute3_id INT
		DECLARE @attribute4_id INT

		IF @origin_id IS NOT NULL
		BEGIN
			INSERT INTO commodity_origin(source_commodity_id, origin)
			SELECT source_commodity_id, origin
			FROM commodity_origin
			WHERE commodity_origin_id = @origin_id

			SET @new_origin_id = SCOPE_IDENTITY()

			DECLARE origin_cursor CURSOR FOR
				SELECT a.commodity_form_id
				FROM commodity_form a
				WHERE a.commodity_origin_id = @origin_id
			OPEN origin_cursor
			FETCH NEXT FROM origin_cursor INTO @commodity_form_id
			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO commodity_form(commodity_origin_id, form)
				SELECT @new_origin_id, a.form
				FROM commodity_form a
				WHERE a.commodity_form_id = @commodity_form_id

				SET @new_form_id = SCOPE_IDENTITY()

				DECLARE form_cursor CURSOR FOR
					SELECT a.commodity_form_attribute1_id
					FROM commodity_form_attribute1 a
					INNER JOIN commodity_form b ON a.commodity_form_id = b.commodity_form_id
					WHERE b.commodity_form_id = @commodity_form_id
				OPEN form_cursor
				FETCH NEXT FROM form_cursor INTO @commodity_form_attribute1_id
				WHILE @@FETCH_STATUS = 0
				BEGIN
					INSERT INTO commodity_form_attribute1(commodity_form_id, attribute_id, attribute_form_id)
					SELECT @new_form_id, a.attribute_id, a.attribute_form_id
					FROM commodity_form_attribute1 a
					WHERE a.commodity_form_attribute1_id = @commodity_form_attribute1_id
				
					SET @attribute1_id = SCOPE_IDENTITY()

					DECLARE grade_1_cursor CURSOR FOR
						SELECT a.commodity_form_attribute2_id
						FROM commodity_form_attribute2 a
						INNER JOIN commodity_form_attribute1 b ON a.commodity_form_attribute1_id = b.commodity_form_attribute1_id
						WHERE b.commodity_form_attribute1_id = @commodity_form_attribute1_id
					OPEN grade_1_cursor
					FETCH NEXT FROM grade_1_cursor INTO @commodity_form_attribute2_id
					WHILE @@FETCH_STATUS = 0
					BEGIN
						INSERT INTO commodity_form_attribute2(commodity_form_attribute1_id, attribute_id, attribute_form_id)
						SELECT @attribute1_id, attribute_id, attribute_form_id
						FROM commodity_form_attribute2
						WHERE commodity_form_attribute2_id = @commodity_form_attribute2_id

						SET @attribute2_id = SCOPE_IDENTITY()
						DECLARE grade_2_cursor CURSOR FOR
							SELECT a.commodity_form_attribute3_id
							FROM commodity_form_attribute3 a
							INNER JOIN commodity_form_attribute2 b ON a.commodity_form_attribute2_id = b.commodity_form_attribute2_id
							WHERE b.commodity_form_attribute2_id = @commodity_form_attribute2_id
						OPEN grade_2_cursor
						FETCH NEXT FROM grade_2_cursor INTO @commodity_form_attribute3_id
						WHILE @@FETCH_STATUS = 0
						BEGIN
							INSERT INTO commodity_form_attribute3(commodity_form_attribute2_id, attribute_id, attribute_form_id)
							SELECT @attribute2_id, a.attribute_id, a.attribute_form_id
							FROM commodity_form_attribute3 a
							WHERE a.commodity_form_attribute3_id = @commodity_form_attribute3_id

							SET @attribute3_id = SCOPE_IDENTITY()
				
							DECLARE grade_3_cursor CURSOR FOR
								SELECT a.commodity_form_attribute4_id
								FROM commodity_form_attribute4 a
								INNER JOIN commodity_form_attribute3 b ON a.commodity_form_attribute3_id = b.commodity_form_attribute3_id
								WHERE b.commodity_form_attribute3_id = @commodity_form_attribute3_id
							OPEN grade_3_cursor
							FETCH NEXT FROM grade_3_cursor INTO @commodity_form_attribute4_id
							WHILE @@FETCH_STATUS = 0
							BEGIN
								INSERT INTO commodity_form_attribute4(commodity_form_attribute3_id, attribute_id, attribute_form_id)
								SELECT @attribute3_id, a.attribute_id, a.attribute_form_id
								FROM commodity_form_attribute4 a
								WHERE a.commodity_form_attribute4_id = @commodity_form_attribute4_id

								SET @attribute4_id = SCOPE_IDENTITY()

								INSERT INTO commodity_form_attribute5(commodity_form_attribute4_id, attribute_id, attribute_form_id)
								SELECT @attribute4_id, a.attribute_id, a.attribute_form_id
								FROM commodity_form_attribute5 a
								INNER JOIN commodity_form_attribute4 b ON a.commodity_form_attribute4_id = b.commodity_form_attribute4_id
								WHERE b.commodity_form_attribute4_id = @commodity_form_attribute4_id

								FETCH NEXT FROM grade_3_cursor INTO @commodity_form_attribute4_id
							END
							CLOSE grade_3_cursor
							DEALLOCATE grade_3_cursor

							FETCH NEXT FROM grade_2_cursor INTO @commodity_form_attribute3_id
						END
						CLOSE grade_2_cursor
						DEALLOCATE grade_2_cursor

						FETCH NEXT FROM grade_1_cursor INTO @commodity_form_attribute2_id
					END
					CLOSE grade_1_cursor
					DEALLOCATE grade_1_cursor

					FETCH NEXT FROM form_cursor INTO @commodity_form_attribute1_id
				END
				CLOSE form_cursor
				DEALLOCATE form_cursor

				FETCH NEXT FROM origin_cursor INTO @commodity_form_id
			END
			CLOSE origin_cursor
			DEALLOCATE origin_cursor
		END
		ELSE IF @form_id IS NOT NULL
		BEGIN
			INSERT INTO commodity_form(commodity_origin_id, form)
			SELECT commodity_origin_id, form
			FROM commodity_form
			WHERE commodity_form_id = @form_id

			SET @new_form_id = SCOPE_IDENTITY()

			DECLARE form_cursor CURSOR FOR
				SELECT a.commodity_form_attribute1_id
				FROM commodity_form_attribute1 a
				INNER JOIN commodity_form b ON a.commodity_form_id = b.commodity_form_id
				WHERE b.commodity_form_id = @form_id
			OPEN form_cursor
			FETCH NEXT FROM form_cursor INTO @commodity_form_attribute1_id
			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO commodity_form_attribute1(commodity_form_id, attribute_id, attribute_form_id)
				SELECT @new_form_id, a.attribute_id, a.attribute_form_id
				FROM commodity_form_attribute1 a
				WHERE a.commodity_form_attribute1_id = @commodity_form_attribute1_id
				
				SET @attribute1_id = SCOPE_IDENTITY()

				DECLARE grade_1_cursor CURSOR FOR
					SELECT a.commodity_form_attribute2_id
					FROM commodity_form_attribute2 a
					INNER JOIN commodity_form_attribute1 b ON a.commodity_form_attribute1_id = b.commodity_form_attribute1_id
					WHERE b.commodity_form_attribute1_id = @commodity_form_attribute1_id
				OPEN grade_1_cursor
				FETCH NEXT FROM grade_1_cursor INTO @commodity_form_attribute2_id
				WHILE @@FETCH_STATUS = 0
				BEGIN
					INSERT INTO commodity_form_attribute2(commodity_form_attribute1_id, attribute_id, attribute_form_id)
					SELECT @attribute1_id, attribute_id, attribute_form_id
					FROM commodity_form_attribute2
					WHERE commodity_form_attribute2_id = @commodity_form_attribute2_id

					SET @attribute2_id = SCOPE_IDENTITY()
					DECLARE grade_2_cursor CURSOR FOR
						SELECT a.commodity_form_attribute3_id
						FROM commodity_form_attribute3 a
						INNER JOIN commodity_form_attribute2 b ON a.commodity_form_attribute2_id = b.commodity_form_attribute2_id
						WHERE b.commodity_form_attribute2_id = @commodity_form_attribute2_id
					OPEN grade_2_cursor
					FETCH NEXT FROM grade_2_cursor INTO @commodity_form_attribute3_id
					WHILE @@FETCH_STATUS = 0
					BEGIN
						INSERT INTO commodity_form_attribute3(commodity_form_attribute2_id, attribute_id, attribute_form_id)
						SELECT @attribute2_id, a.attribute_id, a.attribute_form_id
						FROM commodity_form_attribute3 a
						WHERE a.commodity_form_attribute3_id = @commodity_form_attribute3_id

						SET @attribute3_id = SCOPE_IDENTITY()
				
						DECLARE grade_3_cursor CURSOR FOR
							SELECT a.commodity_form_attribute4_id
							FROM commodity_form_attribute4 a
							INNER JOIN commodity_form_attribute3 b ON a.commodity_form_attribute3_id = b.commodity_form_attribute3_id
							WHERE b.commodity_form_attribute3_id = @commodity_form_attribute3_id
						OPEN grade_3_cursor
						FETCH NEXT FROM grade_3_cursor INTO @commodity_form_attribute4_id
						WHILE @@FETCH_STATUS = 0
						BEGIN
							INSERT INTO commodity_form_attribute4(commodity_form_attribute3_id, attribute_id, attribute_form_id)
							SELECT @attribute3_id, a.attribute_id, a.attribute_form_id
							FROM commodity_form_attribute4 a
							WHERE a.commodity_form_attribute4_id = @commodity_form_attribute4_id

							SET @attribute4_id = SCOPE_IDENTITY()

							INSERT INTO commodity_form_attribute5(commodity_form_attribute4_id, attribute_id, attribute_form_id)
							SELECT @attribute4_id, a.attribute_id, a.attribute_form_id
							FROM commodity_form_attribute5 a
							INNER JOIN commodity_form_attribute4 b ON a.commodity_form_attribute4_id = b.commodity_form_attribute4_id
							WHERE b.commodity_form_attribute4_id = @commodity_form_attribute4_id

							FETCH NEXT FROM grade_3_cursor INTO @commodity_form_attribute4_id
						END
						CLOSE grade_3_cursor
						DEALLOCATE grade_3_cursor

						FETCH NEXT FROM grade_2_cursor INTO @commodity_form_attribute3_id
					END
					CLOSE grade_2_cursor
					DEALLOCATE grade_2_cursor

					FETCH NEXT FROM grade_1_cursor INTO @commodity_form_attribute2_id
				END
				CLOSE grade_1_cursor
				DEALLOCATE grade_1_cursor

				FETCH NEXT FROM form_cursor INTO @commodity_form_attribute1_id
			END
			CLOSE form_cursor
			DEALLOCATE form_cursor
		END
		ELSE IF @attribute1 IS NOT NULL
		BEGIN
			INSERT INTO commodity_form_attribute1(commodity_form_id, attribute_id, attribute_form_id)
			SELECT commodity_form_id, attribute_id, attribute_form_id
			FROM commodity_form_attribute1
			WHERE commodity_form_attribute1_id = @attribute1
			
			SET @attribute1_id = SCOPE_IDENTITY()

			DECLARE grade_1_cursor CURSOR FOR
				SELECT a.commodity_form_attribute2_id
				FROM commodity_form_attribute2 a
				INNER JOIN commodity_form_attribute1 b ON a.commodity_form_attribute1_id = b.commodity_form_attribute1_id
				WHERE b.commodity_form_attribute1_id = @attribute1
			OPEN grade_1_cursor
			FETCH NEXT FROM grade_1_cursor INTO @commodity_form_attribute2_id
			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO commodity_form_attribute2(commodity_form_attribute1_id, attribute_id, attribute_form_id)
				SELECT @attribute1_id, attribute_id, attribute_form_id
				FROM commodity_form_attribute2
				WHERE commodity_form_attribute2_id = @commodity_form_attribute2_id

				SET @attribute2_id = SCOPE_IDENTITY()
				DECLARE grade_2_cursor CURSOR FOR
					SELECT a.commodity_form_attribute3_id
					FROM commodity_form_attribute3 a
					INNER JOIN commodity_form_attribute2 b ON a.commodity_form_attribute2_id = b.commodity_form_attribute2_id
					WHERE b.commodity_form_attribute2_id = @commodity_form_attribute2_id
				OPEN grade_2_cursor
				FETCH NEXT FROM grade_2_cursor INTO @commodity_form_attribute3_id
				WHILE @@FETCH_STATUS = 0
				BEGIN
					INSERT INTO commodity_form_attribute3(commodity_form_attribute2_id, attribute_id, attribute_form_id)
					SELECT @attribute2_id, a.attribute_id, a.attribute_form_id
					FROM commodity_form_attribute3 a
					WHERE a.commodity_form_attribute3_id = @commodity_form_attribute3_id

					SET @attribute3_id = SCOPE_IDENTITY()
				
					DECLARE grade_3_cursor CURSOR FOR
						SELECT a.commodity_form_attribute4_id
						FROM commodity_form_attribute4 a
						INNER JOIN commodity_form_attribute3 b ON a.commodity_form_attribute3_id = b.commodity_form_attribute3_id
						WHERE b.commodity_form_attribute3_id = @commodity_form_attribute3_id
					OPEN grade_3_cursor
					FETCH NEXT FROM grade_3_cursor INTO @commodity_form_attribute4_id
					WHILE @@FETCH_STATUS = 0
					BEGIN
						INSERT INTO commodity_form_attribute4(commodity_form_attribute3_id, attribute_id, attribute_form_id)
						SELECT @attribute3_id, a.attribute_id, a.attribute_form_id
						FROM commodity_form_attribute4 a
						WHERE a.commodity_form_attribute4_id = @commodity_form_attribute4_id

						SET @attribute4_id = SCOPE_IDENTITY()

						INSERT INTO commodity_form_attribute5(commodity_form_attribute4_id, attribute_id, attribute_form_id)
						SELECT @attribute4_id, a.attribute_id, a.attribute_form_id
						FROM commodity_form_attribute5 a
						INNER JOIN commodity_form_attribute4 b ON a.commodity_form_attribute4_id = b.commodity_form_attribute4_id
						WHERE b.commodity_form_attribute4_id = @commodity_form_attribute4_id

						FETCH NEXT FROM grade_3_cursor INTO @commodity_form_attribute4_id
					END
					CLOSE grade_3_cursor
					DEALLOCATE grade_3_cursor

					FETCH NEXT FROM grade_2_cursor INTO @commodity_form_attribute3_id
				END
				CLOSE grade_2_cursor
				DEALLOCATE grade_2_cursor

				FETCH NEXT FROM grade_1_cursor INTO @commodity_form_attribute2_id
			END
			CLOSE grade_1_cursor
			DEALLOCATE grade_1_cursor
		END
		ELSE IF @attribute2 IS NOT NULL
		BEGIN
			INSERT INTO commodity_form_attribute2(commodity_form_attribute1_id, attribute_id, attribute_form_id)
			SELECT commodity_form_attribute1_id, attribute_id, attribute_form_id
			FROM commodity_form_attribute2
			WHERE commodity_form_attribute2_id = @attribute2

			SET @commodity_form_attribute2_id = SCOPE_IDENTITY()
			DECLARE grade_2_cursor CURSOR FOR
				SELECT a.commodity_form_attribute3_id
				FROM commodity_form_attribute3 a
				INNER JOIN commodity_form_attribute2 b ON a.commodity_form_attribute2_id = b.commodity_form_attribute2_id
				WHERE b.commodity_form_attribute2_id = @attribute2
			OPEN grade_2_cursor
			FETCH NEXT FROM grade_2_cursor INTO @commodity_form_attribute3_id
			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO commodity_form_attribute3(commodity_form_attribute2_id, attribute_id, attribute_form_id)
				SELECT @commodity_form_attribute2_id, a.attribute_id, a.attribute_form_id
				FROM commodity_form_attribute3 a
				WHERE a.commodity_form_attribute3_id = @commodity_form_attribute3_id

				SET @attribute3_id = SCOPE_IDENTITY()
				
				DECLARE grade_3_cursor CURSOR FOR
					SELECT a.commodity_form_attribute4_id
					FROM commodity_form_attribute4 a
					INNER JOIN commodity_form_attribute3 b ON a.commodity_form_attribute3_id = b.commodity_form_attribute3_id
					WHERE b.commodity_form_attribute3_id = @commodity_form_attribute3_id
				OPEN grade_3_cursor
				FETCH NEXT FROM grade_3_cursor INTO @commodity_form_attribute4_id
				WHILE @@FETCH_STATUS = 0
				BEGIN
					INSERT INTO commodity_form_attribute4(commodity_form_attribute3_id, attribute_id, attribute_form_id)
					SELECT @attribute3_id, a.attribute_id, a.attribute_form_id
					FROM commodity_form_attribute4 a
					WHERE a.commodity_form_attribute4_id = @commodity_form_attribute4_id

					SET @attribute4_id = SCOPE_IDENTITY()

					INSERT INTO commodity_form_attribute5(commodity_form_attribute4_id, attribute_id, attribute_form_id)
					SELECT @attribute4_id, a.attribute_id, a.attribute_form_id
					FROM commodity_form_attribute5 a
					INNER JOIN commodity_form_attribute4 b ON a.commodity_form_attribute4_id = b.commodity_form_attribute4_id
					WHERE b.commodity_form_attribute4_id = @commodity_form_attribute4_id

					FETCH NEXT FROM grade_3_cursor INTO @commodity_form_attribute4_id
				END
				CLOSE grade_3_cursor
				DEALLOCATE grade_3_cursor

				FETCH NEXT FROM grade_2_cursor INTO @commodity_form_attribute3_id
			END
			CLOSE grade_2_cursor
			DEALLOCATE grade_2_cursor
		END
		ELSE IF @attribute3 IS NOT NULL
		BEGIN
			INSERT INTO commodity_form_attribute3(commodity_form_attribute2_id, attribute_id, attribute_form_id)
			SELECT commodity_form_attribute2_id, attribute_id, attribute_form_id
			FROM commodity_form_attribute3
			WHERE commodity_form_attribute3_id = @attribute3
			
			SET @commodity_form_attribute3_id = SCOPE_IDENTITY()
			DECLARE grade_3_cursor CURSOR FOR
				SELECT a.commodity_form_attribute4_id
				FROM commodity_form_attribute4 a
				INNER JOIN commodity_form_attribute3 b ON a.commodity_form_attribute3_id = b.commodity_form_attribute3_id
				WHERE b.commodity_form_attribute3_id = @attribute3
			OPEN grade_3_cursor
			FETCH NEXT FROM grade_3_cursor INTO @commodity_form_attribute4_id
			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO commodity_form_attribute4(commodity_form_attribute3_id, attribute_id, attribute_form_id)
				SELECT @commodity_form_attribute3_id, a.attribute_id, a.attribute_form_id
				FROM commodity_form_attribute4 a
				WHERE a.commodity_form_attribute4_id = @commodity_form_attribute4_id

				INSERT INTO commodity_form_attribute5(commodity_form_attribute4_id, attribute_id, attribute_form_id)
				SELECT SCOPE_IDENTITY(), a.attribute_id, a.attribute_form_id
				FROM commodity_form_attribute5 a
				INNER JOIN commodity_form_attribute4 b ON a.commodity_form_attribute4_id = b.commodity_form_attribute4_id
				WHERE b.commodity_form_attribute4_id = @commodity_form_attribute4_id

				FETCH NEXT FROM grade_3_cursor INTO @commodity_form_attribute4_id
			END
			CLOSE grade_3_cursor
			DEALLOCATE grade_3_cursor
		END
		ELSE IF @attribute4 IS NOT NULL
		BEGIN
			INSERT INTO commodity_form_attribute4(commodity_form_attribute3_id, attribute_id, attribute_form_id)
			SELECT commodity_form_attribute3_id, attribute_id, attribute_form_id
			FROM commodity_form_attribute4
			WHERE commodity_form_attribute4_id = @attribute4

			INSERT INTO commodity_form_attribute5(commodity_form_attribute4_id, attribute_id, attribute_form_id)
			SELECT SCOPE_IDENTITY(), a.attribute_id, a.attribute_form_id
			FROM commodity_form_attribute5 a
			INNER JOIN commodity_form_attribute4 b ON a.commodity_form_attribute4_id = b.commodity_form_attribute4_id
			WHERE a.commodity_form_attribute4_id = @attribute4

		END
		ELSE IF @attribute5 IS NOT NULL
		BEGIN
			INSERT INTO commodity_form_attribute5(commodity_form_attribute4_id, attribute_id, attribute_form_id)
			SELECT commodity_form_attribute4_id, attribute_id, attribute_form_id
			FROM commodity_form_attribute5
			WHERE commodity_form_attribute5_id = @attribute5
		END

		EXEC spa_ErrorHandler @@ERROR,
			'Commodity Grade',
			'spa_commodity_grade',
			'Success',
			'Changes have been saved successfully.',
			''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	
		DECLARE @desc VARCHAR(1000)	
		SET @desc = dbo.FNAHandleDBError(10101112)
			
		EXEC spa_ErrorHandler -1
			, 'Commodity Grade'
			, 'spa_commodity_grade'
			, 'Error'
			, @desc
			, ''
	END CATCH
END