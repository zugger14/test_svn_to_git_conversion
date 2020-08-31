IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292017 AND weekday = '1')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 292017 AND weekday = 1
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292017, '1',0
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292017 AND weekday = '2')
		BEGIN
			UPDATE working_days
			SET val = 1
			 WHERE block_value_id = 292017 AND weekday = 2
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292017, '2',1
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292017 AND weekday = '3')
		BEGIN
			UPDATE working_days
			SET val = 1
			 WHERE block_value_id = 292017 AND weekday = 3
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292017, '3',1
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292017 AND weekday = '4')
		BEGIN
			UPDATE working_days
			SET val = 1
			 WHERE block_value_id = 292017 AND weekday = 4
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292017, '4',1
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292017 AND weekday = '5')
		BEGIN
			UPDATE working_days
			SET val = 1
			 WHERE block_value_id = 292017 AND weekday = 5
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292017, '5',1
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292017 AND weekday = '6')
		BEGIN
			UPDATE working_days
			SET val = 1
			 WHERE block_value_id = 292017 AND weekday = 6
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292017, '6',1
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292017 AND weekday = '7')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 292017 AND weekday = 7
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292017, '7',0
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292018 AND weekday = '1')
		BEGIN
			UPDATE working_days
			SET val = 1
			 WHERE block_value_id = 292018 AND weekday = 1
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292018, '1',1
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292018 AND weekday = '2')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 292018 AND weekday = 2
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292018, '2',0
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292018 AND weekday = '3')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 292018 AND weekday = 3
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292018, '3',0
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292018 AND weekday = '4')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 292018 AND weekday = 4
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292018, '4',0
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292018 AND weekday = '5')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 292018 AND weekday = 5
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292018, '5',0
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292018 AND weekday = '6')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 292018 AND weekday = 6
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292018, '6',0
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292018 AND weekday = '7')
		BEGIN
			UPDATE working_days
			SET val = 1
			 WHERE block_value_id = 292018 AND weekday = 7
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292018, '7',1
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292061 AND weekday = '1')
		BEGIN
			UPDATE working_days
			SET val = 1
			 WHERE block_value_id = 292061 AND weekday = 1
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292061, '1',1
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292061 AND weekday = '2')
		BEGIN
			UPDATE working_days
			SET val = 1
			 WHERE block_value_id = 292061 AND weekday = 2
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292061, '2',1
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292061 AND weekday = '3')
		BEGIN
			UPDATE working_days
			SET val = 1
			 WHERE block_value_id = 292061 AND weekday = 3
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292061, '3',1
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292061 AND weekday = '4')
		BEGIN
			UPDATE working_days
			SET val = 1
			 WHERE block_value_id = 292061 AND weekday = 4
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292061, '4',1
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292061 AND weekday = '5')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 292061 AND weekday = 5
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292061, '5',0
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292061 AND weekday = '6')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 292061 AND weekday = 6
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292061, '6',0
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 292061 AND weekday = '7')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 292061 AND weekday = 7
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 292061, '7',0
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 303144 AND weekday = '1')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 303144 AND weekday = 1
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 303144, '1',0
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 303144 AND weekday = '2')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 303144 AND weekday = 2
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 303144, '2',0
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 303144 AND weekday = '3')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 303144 AND weekday = 3
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 303144, '3',0
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 303144 AND weekday = '4')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 303144 AND weekday = 4
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 303144, '4',0
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 303144 AND weekday = '5')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 303144 AND weekday = 5
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 303144, '5',0
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 303144 AND weekday = '6')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 303144 AND weekday = 6
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 303144, '6',0
		END
		
IF EXISTS(SELECT 1 FROM working_days WHERE block_value_id = 303144 AND weekday = '7')
		BEGIN
			UPDATE working_days
			SET val = 0
			 WHERE block_value_id = 303144 AND weekday = 7
		END
		ELSE
		BEGIN
			INSERT INTO working_days(block_value_id,weekday,val)
			SELECT 303144, '7',0
		END
		