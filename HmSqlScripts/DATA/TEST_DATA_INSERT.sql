﻿------------------------------------------------------------------------------------------------------------------------
-- TEST_DATA_INSERT
------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
PRINT N'[ ] SET TRANSACTION ISOLATION LEVEL READ COMMITTED';
DECLARE @DB_NAME_CUR VARCHAR(128) = NULL;
DECLARE @DB_NAME_DEV VARCHAR(128) = 'HRM_DEMO_DEV';
DECLARE @DB_NAME_PROD VARCHAR(128) = 'HRM_DEMO_PROD';
DECLARE @SCHEMA_REF_NAME VARCHAR(128) = 'REF';
DECLARE @SCHEMA_DIM_NAME VARCHAR(128) = 'DIM';
DECLARE @SCHEMA_REF_ID INT = (SELECT [SCHEMA_ID] FROM [SYS].[SCHEMAS] WHERE [NAME] = @SCHEMA_REF_NAME);
DECLARE @SCHEMA_DIM_ID INT = (SELECT [SCHEMA_ID] FROM [SYS].[SCHEMAS] WHERE [NAME] = @SCHEMA_DIM_NAME);
DECLARE @CMD NVARCHAR(MAX);
DECLARE @MEDICAL_CARD_DESCR NVARCHAR(MAX);
DECLARE @COUNTER SMALLINT;
DECLARE @LIMIT SMALLINT;
DECLARE @PERSON_ID INT;
DECLARE @PATIENT_ID INT;
DECLARE @DOCTOR_ID INT;
DECLARE @YEAR SMALLINT;
DECLARE @MONTH SMALLINT;
DECLARE @DAY SMALLINT;
DECLARE @HOUR SMALLINT;
DECLARE @MIN SMALLINT;
------------------------------------------------------------------------------------------------------------------------
DECLARE @IS_ACTION BIT = 1;
DECLARE @IS_COMMIT BIT = 1;
------------------------------------------------------------------------------------------------------------------------
IF (@IS_ACTION = 0) BEGIN
	PRINT N'[x] ACTION IS DISABLED';
END ELSE BEGIN
	BEGIN TRAN
	-- CHECK DB
	SET @DB_NAME_CUR = (SELECT DB_NAME());
	IF NOT (@DB_NAME_CUR = @DB_NAME_DEV OR @DB_NAME_CUR = @DB_NAME_PROD) BEGIN
		PRINT N'[x] CURRENT DB [' + @DB_NAME_CUR + '] IS NOT CORRECT';
	END ELSE BEGIN
		PRINT N'[✓] CURRENT DB [' + @DB_NAME_CUR + '] IS CORRECT';
		-- INSERT VALUES INTO [PERSONS]
		IF EXISTS (SELECT 1 FROM [SYS].[TABLES] WHERE [SCHEMA_ID] = @SCHEMA_REF_ID AND [name] = N'PERSONS') BEGIN
			SET @COUNTER = 101;
			IF NOT EXISTS(SELECT 1 FROM [REF].[PERSONS] WHERE [GENDER] = 'M' AND [EMAIL] LIKE 'test%@gmail.com') BEGIN
				SET @YEAR = 1990;
				SET @MONTH = 1;
				SET @DAY = 1;
				WHILE (@COUNTER < 201) BEGIN
					INSERT INTO [REF].[PERSONS]([FAMILY], [NAME], [SURNAME], [GENDER], [DT_BIRTH], [CELLPHONE], [EMAIL], [INN])
						VALUES(N'Мужская фамилия ' + CAST(@COUNTER AS NVARCHAR), N'Имя ' + CAST(@COUNTER AS NVARCHAR), N'Отчество ' + CAST(@COUNTER AS NVARCHAR), 'M', 
							DATEFROMPARTS(@YEAR,@MONTH,@DAY), '79001001' + CAST(@COUNTER AS VARCHAR(3)), 'test' + CAST(@COUNTER AS NVARCHAR) + '@gmail.com',
							'123456789' + CAST(@COUNTER AS VARCHAR(3)));
					SET @COUNTER = @COUNTER + 1;
					SET @YEAR = @YEAR + 1;
					IF (@YEAR > 2010) SET @YEAR = 1990;
					SET @MONTH = @MONTH + 1;
					IF (@MONTH > 12) SET @MONTH = 1;
					SET @DAY = @DAY + 1;
					IF (@DAY > 28) SET @DAY = 1;
				END;
				PRINT N'[✓] INSERTED VALUES INTO [REF].[PERSONS] - MALE';
			END;
			SET @COUNTER = 201;
			IF NOT EXISTS(SELECT 1 FROM [REF].[PERSONS] WHERE [GENDER] = 'F' AND [EMAIL] LIKE 'test%@gmail.com') BEGIN
				SET @YEAR = 1990;
				SET @MONTH = 1;
				SET @DAY = 1;
				WHILE (@COUNTER < 301) BEGIN
					INSERT INTO [REF].[PERSONS]([FAMILY], [NAME], [SURNAME], [GENDER], [DT_BIRTH], [CELLPHONE], [EMAIL], [INN])
						VALUES(N'Женская фамилия ' + CAST(@COUNTER AS NVARCHAR), N'Имя ' + CAST(@COUNTER AS NVARCHAR), N'Отчество ' + CAST(@COUNTER AS NVARCHAR), 'F', 
							DATEFROMPARTS(@YEAR,@MONTH,@DAY), '79001001' + CAST(@COUNTER AS VARCHAR(3)), 'test' + CAST(@COUNTER AS NVARCHAR) + '@gmail.com',
							'123456789' + CAST(@COUNTER AS VARCHAR(3)));
					SET @COUNTER = @COUNTER + 1;
					SET @YEAR = @YEAR + 1;
					IF (@YEAR > 2010) SET @YEAR = 1990;
					SET @MONTH = @MONTH + 1;
					IF (@MONTH > 12) SET @MONTH = 1;
					SET @DAY = @DAY + 1;
					IF (@DAY > 28) SET @DAY = 1;
				END;
				PRINT N'[✓] INSERTED VALUES INTO [REF].[PERSONS] - FEMALE';
			END;
		END;
		-- INSERT VALUES INTO [DOCTORS]
		IF EXISTS (SELECT 1 FROM [SYS].[TABLES] WHERE [SCHEMA_ID] = @SCHEMA_REF_ID AND [name] = N'DOCTORS') BEGIN
			IF NOT EXISTS(SELECT 1 FROM [REF].[DOCTORS] WHERE [PERSON_ID] = (
				SELECT TOP 1 [ID] FROM [REF].[PERSONS] WHERE [GENDER] = 'F' AND [EMAIL] LIKE 'test%@gmail.com')) BEGIN
				DECLARE CUR_PERSONS CURSOR FOR SELECT [ID] FROM [REF].[PERSONS] WHERE [GENDER] = 'F' AND [EMAIL] LIKE 'test%@gmail.com';
				OPEN CUR_PERSONS;
					FETCH NEXT FROM CUR_PERSONS INTO @PERSON_ID;
					WHILE (@@FETCH_STATUS = 0) BEGIN
						INSERT INTO [REF].[DOCTORS]([PERSON_ID]) VALUES(@PERSON_ID);
						FETCH NEXT FROM CUR_PERSONS INTO @PERSON_ID;
					END;
				CLOSE CUR_PERSONS;
				DEALLOCATE CUR_PERSONS;
				PRINT N'[✓] INSERTED VALUES INTO [REF].[DOCTORS]';
			END;
		END;
		-- INSERT VALUES INTO [MEDICAL_CARDS]
		IF EXISTS (SELECT 1 FROM [SYS].[TABLES] WHERE [SCHEMA_ID] = @SCHEMA_REF_ID AND [name] = N'MEDICAL_CARDS') BEGIN
			IF NOT EXISTS(SELECT 1 FROM [REF].[MEDICAL_CARDS] WHERE [DESCRIPTION] LIKE N'test%') BEGIN
				SET @COUNTER = 1;
				WHILE (@COUNTER < 121) BEGIN
					INSERT INTO [REF].[MEDICAL_CARDS]([DESCRIPTION]) VALUES(N'test ' + CAST(@COUNTER AS NVARCHAR));
					SET @COUNTER = @COUNTER + 1;
				END;
				PRINT N'[✓] INSERTED VALUES INTO [REF].[MEDICAL_CARDS]';
			END;
		END;
		-- INSERT VALUES INTO [PATIENTS]
		IF EXISTS (SELECT 1 FROM [SYS].[TABLES] WHERE [SCHEMA_ID] = @SCHEMA_REF_ID AND [name] = N'PATIENTS') BEGIN
			IF NOT EXISTS(SELECT 1 FROM [REF].[PATIENTS] WHERE [PERSON_ID] IN (
				SELECT [ID] FROM [REF].[PERSONS] WHERE [GENDER] = 'M' AND [EMAIL] LIKE 'test%@gmail.com')) BEGIN
				SET @COUNTER = 1;
				DECLARE CUR_PERSONS CURSOR FOR SELECT [ID] FROM [REF].[PERSONS] WHERE [GENDER] = 'M' AND [EMAIL] LIKE 'test%@gmail.com';
				OPEN CUR_PERSONS;
					FETCH NEXT FROM CUR_PERSONS INTO @PERSON_ID;
					WHILE (@@FETCH_STATUS = 0) BEGIN
						INSERT INTO [REF].[PATIENTS]([PERSON_ID], [MEDICAL_CARD_ID]) 
							VALUES(@PERSON_ID, 
								(SELECT [ID] FROM [REF].[MEDICAL_CARDS] WHERE [DESCRIPTION] = 'test ' + CAST(@COUNTER AS NVARCHAR)));
						SET @COUNTER = @COUNTER + 1;
						FETCH NEXT FROM CUR_PERSONS INTO @PERSON_ID;
					END;
				CLOSE CUR_PERSONS;
				DEALLOCATE CUR_PERSONS;
				PRINT N'[✓] INSERTED VALUES INTO [REF].[PATIENTS] - MALE';
			END;
			-- DOCTORS AS PATIENTS
			IF NOT EXISTS(SELECT 1 FROM [REF].[PATIENTS] WHERE [PERSON_ID] IN (
				SELECT [ID] FROM [REF].[PERSONS] WHERE [GENDER] = 'F' AND [EMAIL] LIKE 'test%@gmail.com')) BEGIN
				SET @COUNTER = 101;
				DECLARE CUR_PERSONS CURSOR FOR SELECT [ID] FROM [REF].[PERSONS] WHERE [GENDER] = 'F' AND [EMAIL] LIKE 'test%@gmail.com';
				OPEN CUR_PERSONS;
					FETCH NEXT FROM CUR_PERSONS INTO @PERSON_ID;
					WHILE (@@FETCH_STATUS = 0 AND @COUNTER < 121) BEGIN
						INSERT INTO [REF].[PATIENTS]([PERSON_ID], [MEDICAL_CARD_ID]) 
							VALUES(@PERSON_ID, 
								(SELECT [ID] FROM [REF].[MEDICAL_CARDS] WHERE [DESCRIPTION] = 'test ' + CAST(@COUNTER AS NVARCHAR)));
						SET @COUNTER = @COUNTER + 1;
						FETCH NEXT FROM CUR_PERSONS INTO @PERSON_ID;
					END;
				CLOSE CUR_PERSONS;
				DEALLOCATE CUR_PERSONS;
				PRINT N'[✓] INSERTED VALUES INTO [REF].[PATIENTS] - FEMALE';
			END;
		END;
		-- INSERT VALUES INTO [RECEPTIONS]
		IF EXISTS (SELECT 1 FROM [SYS].[TABLES] WHERE [SCHEMA_ID] = @SCHEMA_DIM_ID AND [name] = N'RECEPTIONS') BEGIN
			DECLARE CUR_DOCTORS CURSOR FOR SELECT [ID] FROM [REF].[DOCTORS];
			OPEN CUR_DOCTORS;
				FETCH NEXT FROM CUR_DOCTORS INTO @DOCTOR_ID;
				WHILE (@@FETCH_STATUS = 0) BEGIN
					DECLARE CUR_PATIENTS CURSOR FOR SELECT [ID] FROM [REF].[PATIENTS];
					OPEN CUR_PATIENTS;
						FETCH NEXT FROM CUR_PATIENTS INTO @PATIENT_ID;
						IF NOT EXISTS(SELECT 1 FROM [DIM].[RECEPTIONS] WHERE [PATIENT_ID] = @PATIENT_ID) BEGIN
							WHILE (@@FETCH_STATUS = 0) BEGIN
								SET @YEAR = 2015;
								WHILE (@YEAR < 2024) BEGIN
									SET @COUNTER = 1;
									SET @LIMIT = ROUND(RAND() * (10-1)+1, 0);
									WHILE (@COUNTER < @LIMIT) BEGIN
										SET @MONTH = ROUND(RAND() * (12-1)+1, 0);
										SET @DAY = ROUND(RAND() * (28-1)+1, 0);
										SET @HOUR = ROUND(RAND() * (19-8)+8, 0);
										SET @MIN = ROUND(RAND() * (59-1)+1, 0);
										INSERT INTO [DIM].[RECEPTIONS]([DT_CREATE], [DT_CHANGE], [DT_START], [PATIENT_ID], [DOCTOR_ID]) 
											VALUES(DATETIMEFROMPARTS(@YEAR, @MONTH, @DAY, @HOUR, @MIN, 0, 0), DATETIMEFROMPARTS(@YEAR, @MONTH, @DAY, @HOUR, @MIN, 0, 0), 
												DATEFROMPARTS(@YEAR, @MONTH, @DAY), @PATIENT_ID, @DOCTOR_ID);
										--PRINT CAST(@PATIENT_ID AS VARCHAR) + ' | ' + CAST(@DOCTOR_ID AS VARCHAR) + ' | ' + CAST(DATETIMEFROMPARTS(@YEAR, @MONTH, @DAY, @HOUR, @MIN, 0, 0) AS VARCHAR)
										SET @COUNTER = @COUNTER  + 1;
									END;
									SET @YEAR = @YEAR + 1;
								END;
								FETCH NEXT FROM CUR_PATIENTS INTO @PATIENT_ID;
							END;
						END;
					CLOSE CUR_PATIENTS;
					DEALLOCATE CUR_PATIENTS;
					FETCH NEXT FROM CUR_DOCTORS INTO @DOCTOR_ID;
				END;
			CLOSE CUR_DOCTORS;
			DEALLOCATE CUR_DOCTORS;
			PRINT N'[✓] INSERTED VALUES INTO [DIM].[RECEPTIONS]';
		END;
	END;
	-- COMMIT
	IF (@IS_COMMIT = 1) BEGIN
		COMMIT TRAN;
		PRINT N'[✓] JOB WAS COMMITTED';
	END ELSE BEGIN
		ROLLBACK TRAN;
		PRINT N'[x] JOB WAS ROLLBACKED';
	END;
END;
------------------------------------------------------------------------------------------------------------------------
