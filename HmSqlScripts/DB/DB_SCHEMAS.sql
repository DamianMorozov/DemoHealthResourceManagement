------------------------------------------------------------------------------------------------------------------------
-- DB_SCHEMAS
------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
PRINT N'[ ] SET TRANSACTION ISOLATION LEVEL READ COMMITTED';
DECLARE @DB_NAME_CUR VARCHAR(128) = NULL;
DECLARE @DB_NAME_DEV VARCHAR(128) = 'HRM_DEMO_DEV';
DECLARE @DB_NAME_PROD VARCHAR(128) = 'HRM_DEMO_PROD';
DECLARE @SCHEMA_ID INT = 0;
DECLARE @CMD NVARCHAR(MAX);
------------------------------------------------------------------------------------------------------------------------
DECLARE @IS_ACTION BIT = 1;
DECLARE @IS_COMMIT BIT = 0;
------------------------------------------------------------------------------------------------------------------------
IF (@IS_ACTION = 0) BEGIN
	PRINT N'[x] ACTION IS DISABLED';
END ELSE BEGIN
	-- USE [HRM_DEMO_DEV] | USE [HRM_DEMO_PROD]
	BEGIN TRAN
	-- CHECK DB
	SET @DB_NAME_CUR = (SELECT DB_NAME());
	IF NOT (@DB_NAME_CUR = @DB_NAME_DEV OR @DB_NAME_CUR = @DB_NAME_PROD) BEGIN
		PRINT N'[x] CURRENT DB [' + @DB_NAME_CUR + '] IS NOT CORRECT';
	END ELSE BEGIN
		PRINT N'[✓] CURRENT DB [' + @DB_NAME_CUR + '] IS CORRECT';
		-- [REF]
		SET @SCHEMA_ID = (SELECT [SCHEMA_ID] FROM [SYS].[SCHEMAS] WHERE [NAME] = 'REF');
		IF (@SCHEMA_ID > 0) BEGIN
			PRINT N'[x] SCHEMA [REF] IS EXISTS';
		END ELSE BEGIN
			SET @CMD = N'CREATE SCHEMA [REF] AUTHORIZATION [HM_ADMIN];'
			EXEC (@CMD);
			PRINT N'[✓] SCHEMA [REF] WAS CREATED';
		END;
		-- [DIM]
		SET @SCHEMA_ID = (SELECT [SCHEMA_ID] FROM [SYS].[SCHEMAS] WHERE [NAME] = 'DIM');
		IF (@SCHEMA_ID > 0) BEGIN
			PRINT N'[x] SCHEMA [DIM] IS EXISTS';
		END ELSE BEGIN
			SET @CMD = N'CREATE SCHEMA [DIM] AUTHORIZATION [HM_ADMIN];'
			EXEC (@CMD);
			PRINT N'[✓] SCHEMA [DIM] WAS CREATED';
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
