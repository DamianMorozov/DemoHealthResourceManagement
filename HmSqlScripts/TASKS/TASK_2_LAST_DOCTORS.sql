------------------------------------------------------------------------------------------------------------------------
-- TASK_2_LAST_DOCTORS | Для каждого пациента выбрать врача из последнего приёма
------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
PRINT N'[ ] SET TRANSACTION ISOLATION LEVEL READ COMMITTED';
DECLARE @DB_NAME_CUR VARCHAR(128) = NULL;
DECLARE @DB_NAME_DEV VARCHAR(128) = 'HRM_DEMO_DEV';
DECLARE @DB_NAME_PROD VARCHAR(128) = 'HRM_DEMO_PROD';
DECLARE @SCHEMA_NAME VARCHAR(128) = 'DIM';
DECLARE @SCHEMA_ID INT = (SELECT [SCHEMA_ID] FROM [SYS].[SCHEMAS] WHERE [NAME] = @SCHEMA_NAME);
DECLARE @CMD NVARCHAR(MAX);
------------------------------------------------------------------------------------------------------------------------
DECLARE @IS_ACTION BIT = 1;
------------------------------------------------------------------------------------------------------------------------
IF (@IS_ACTION = 0) BEGIN
	PRINT N'[x] ACTION IS DISABLED';
END ELSE BEGIN
	-- CHECK DB
	SET @DB_NAME_CUR = (SELECT DB_NAME());
	IF NOT (@DB_NAME_CUR = @DB_NAME_DEV OR @DB_NAME_CUR = @DB_NAME_PROD) BEGIN
		PRINT N'[x] CURRENT DB [' + @DB_NAME_CUR + '] IS NOT CORRECT';
	END ELSE BEGIN
		PRINT N'[✓] CURRENT DB [' + @DB_NAME_CUR + '] IS CORRECT';
		-- SELECT
		IF EXISTS (SELECT 1 FROM [SYS].[TABLES] WHERE [SCHEMA_ID] = @SCHEMA_ID AND [name] = N'RECEPTIONS') BEGIN
			SELECT
				 [REC].[LAST_RECEPTION] [Последний приём]
				-- Пациенты
				,[P1].[FAMILY] + N' ' + [P1].[NAME] + N' ' + [P1].[SURNAME] [ФИО пациента]
				,CASE WHEN [P1].[GENDER] = 'M' THEN N'Мужчина' WHEN [P1].[GENDER] = 'F' THEN 'Женщина' ELSE N'Ошибка природы' END [Пол пациента]
				,[P1].[CELLPHONE] [Мобильный пациента]
				,[P1].[EMAIL] [Почта пациента]
				-- Врачи
				,[P2].[FAMILY] + N' ' + [P2].[NAME] + N' ' + [P2].[SURNAME] [ФИО врача]
				,CASE WHEN [P2].[GENDER] = 'M' THEN N'Мужчина' WHEN [P2].[GENDER] = 'F' THEN 'Женщина' ELSE N'Ошибка природы' END [Пол пврача]
				,[P2].[CELLPHONE] [Мобильный врача]
				,[P2].[EMAIL] [Почта врача]
			FROM [REF].[PATIENTS] [PA] --ON [PA].[ID] = [GR].[PATIENT_ID]
			INNER JOIN [REF].[PERSONS] [P1] ON [PA].[PERSON_ID] = [P1].[ID]
			-- Рецепты (Приёмы) -- может быть пациент без приёма, может это потенциальный пацент из CRM или иного источника данных
			LEFT JOIN (
				SELECT 
					 [GREC].[DT_CREATE] [LAST_RECEPTION]
					,[GREC].[PATIENT_ID]
					,[GREC].[DOCTOR_ID]
				FROM (SELECT [R].[PATIENT_ID], MAX([R].[DT_CREATE]) [DT_CREATE], [R].[DOCTOR_ID]
					FROM [DIM].[RECEPTIONS] [R]
					GROUP BY [R].[PATIENT_ID], [R].[DOCTOR_ID]) [GREC]) [REC] ON [PA].[ID] = [REC].[PATIENT_ID]
			-- Врачи
			LEFT JOIN [REF].[DOCTORS] [D] ON [REC].[DOCTOR_ID] = [D].[ID]
			INNER JOIN [REF].[PERSONS] [P2] ON [D].[PERSON_ID] = [P2].[ID]
		END;
	END;
END;
------------------------------------------------------------------------------------------------------------------------
