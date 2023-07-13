------------------------------------------------------------------------------------------------------------------------
-- RECEPTIONS_SELECT
------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
PRINT N'[ ] SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED';
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
				 [R].[ID] [RECEPTION_ID]
				,[R].[DT_CREATE] [RECEPTION_DT_CREATE]
				,[R].[DT_CHANGE] [RECEPTION_DT_CHANGE]
				,[R].[DT_START] [RECEPTION_DT_START]
				,[P1].[FAMILY] [PATIENT_FAMILY]
				,[P1].[NAME] [PATIENT_NAME]
				,[P1].[SURNAME] [PATIENT_SURNAME]
				,[P1].[GENDER] [PATIENT_GENDER]
				,[P1].[DT_BIRTH] [PATIENT_DT_BIRTH]
				,[P1].[CELLPHONE] [PATIENT_CELLPHONE]
				,[P1].[EMAIL] [PATIENT_EMAIL]
				,[P2].[FAMILY] [DOCTOR_FAMILY]
				,[P2].[NAME] [DOCTOR_NAME]
				,[P2].[SURNAME] [DOCTOR_SURNAME]
				,[P2].[GENDER] [DOCTOR_GENDER]
				,[P2].[DT_BIRTH] [DOCTOR_DT_BIRTH]
				,[P2].[CELLPHONE] [DOCTOR_CELLPHONE]
				,[P2].[EMAIL] [DOCTOR_EMAIL]
			FROM [DIM].[RECEPTIONS] [R]
			INNER JOIN [REF].[PATIENTS] [PA] ON [R].[PATIENT_ID] = [PA] .[ID]
			INNER JOIN [REF].[PERSONS] [P1] ON [PA].[PERSON_ID] = [P1].[ID]
			INNER JOIN [REF].[DOCTORS] [D] ON [R].[DOCTOR_ID] = [D].[ID]
			INNER JOIN [REF].[PERSONS] [P2] ON [D].[PERSON_ID] = [P2].[ID]
			ORDER BY [R].[DT_CREATE], [P1].[FAMILY], [P1].[NAME], [P1].[SURNAME];
		END;
	END;
END;
------------------------------------------------------------------------------------------------------------------------
