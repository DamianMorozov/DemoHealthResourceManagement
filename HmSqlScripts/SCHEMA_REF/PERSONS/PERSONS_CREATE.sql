------------------------------------------------------------------------------------------------------------------------
-- PERSONS_CREATE
------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
PRINT N'[ ] SET TRANSACTION ISOLATION LEVEL READ COMMITTED';
DECLARE @DB_NAME_CUR VARCHAR(128) = NULL;
DECLARE @DB_NAME_DEV VARCHAR(128) = 'HRM_DEMO_DEV';
DECLARE @DB_NAME_PROD VARCHAR(128) = 'HRM_DEMO_PROD';
DECLARE @SCHEMA_NAME VARCHAR(128) = 'REF';
DECLARE @SCHEMA_ID INT = (SELECT [SCHEMA_ID] FROM [SYS].[SCHEMAS] WHERE [NAME] = @SCHEMA_NAME);
DECLARE @CMD NVARCHAR(MAX);
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
		-- CREATE TABLE
		IF NOT EXISTS (SELECT 1 FROM [SYS].[TABLES] WHERE [SCHEMA_ID] = @SCHEMA_ID AND [name] = N'PERSONS') BEGIN
			CREATE TABLE [REF].[PERSONS] (
				[ID] [INT] IDENTITY(1,1) NOT NULL,
				[DT_CREATE] [DATETIME] NOT NULL,
				[DT_CHANGE] [DATETIME] NOT NULL,
				[FAMILY] [NVARCHAR](128) NOT NULL,
				[NAME] [NVARCHAR](128) NOT NULL,
				[SURNAME] [NVARCHAR](128) NULL,
				[GENDER] [VARCHAR](1) NOT NULL,
				[DT_BIRTH] [DATE] NULL,
				[CELLPHONE] [VARCHAR](11) NOT NULL,
				[EMAIL] [VARCHAR](128) NULL,
				[INN] [VARCHAR](12) NULL,
			) ON [FG_REF];
			PRINT N'[✓] CREATED TABLE [' + @SCHEMA_NAME + '].[PERSONS]';
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
