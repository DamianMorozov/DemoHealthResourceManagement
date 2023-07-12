﻿------------------------------------------------------------------------------------------------------------------------
-- CLIENTS_ALTER
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
		-- ALTER TABLE
		IF EXISTS (SELECT 1 FROM [SYS].[TABLES] WHERE [SCHEMA_ID] = @SCHEMA_ID AND [NAME] = N'CLIENTS') BEGIN
			-- PRIMARY KEY
			IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLE_CONSTRAINTS]
				WHERE [CONSTRAINT_TYPE] = 'PRIMARY KEY' AND [TABLE_SCHEMA] = @SCHEMA_NAME AND [TABLE_NAME] = 'CLIENTS') BEGIN
				ALTER TABLE [REF].[CLIENTS] ADD CONSTRAINT [PK_CLIENTS_ID] PRIMARY KEY CLUSTERED ([ID] ASC) WITH 
					(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [FG_REF];
				PRINT N'[✓] PRIMARY KEY [PK_CLIENTS_ID] WAS CREATED';
			END;
			-- DEFAULT
			IF NOT EXISTS (SELECT 1 FROM [SYS].[DEFAULT_CONSTRAINTS] WHERE [schema_id] = @SCHEMA_ID AND [NAME] = 'DF_CLIENTS_DT_CREATE') BEGIN
				ALTER TABLE [REF].[CLIENTS] ADD CONSTRAINT [DF_CLIENTS_DT_CREATE] DEFAULT (GETDATE()) FOR [DT_CREATE];
				PRINT N'[✓] CONSTRAINT [DF_CLIENTS_DT_CREATE] WAS CREATED';
			END;
			IF NOT EXISTS (SELECT 1 FROM [SYS].[DEFAULT_CONSTRAINTS] WHERE [schema_id] = @SCHEMA_ID AND [NAME] = 'DF_CLIENTS_DT_CHANGE') BEGIN
				ALTER TABLE [REF].[CLIENTS] ADD CONSTRAINT [DF_CLIENTS_DT_CHANGE] DEFAULT (GETDATE()) FOR [DT_CHANGE];
				PRINT N'[✓] CONSTRAINT [DF_CLIENTS_DT_CHANGE] WAS CREATED';
			END;
			-- FOREIGN KEY
			IF EXISTS (SELECT 1 FROM [SYS].[TABLES] WHERE [NAME] = N'CLIENTS') BEGIN
				IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLE_CONSTRAINTS] 
					WHERE [CONSTRAINT_NAME] = 'FK_CLIENTS_PERSON_ID') BEGIN
					ALTER TABLE [REF].[CLIENTS] ADD CONSTRAINT [FK_CLIENTS_PERSON_ID] 
						FOREIGN KEY([PERSON_ID]) REFERENCES [REF].[PERSONS] ([ID]);
					ALTER TABLE [REF].[CLIENTS] CHECK CONSTRAINT [FK_CLIENTS_PERSON_ID]
					PRINT N'[✓] FOREIGN KEY [FK_CLIENTS_PERSON_ID] WAS CREATED';
				END;
			END;
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
