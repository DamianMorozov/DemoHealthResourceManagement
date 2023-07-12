﻿------------------------------------------------------------------------------------------------------------------------
-- INDEXES_RECREATE
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
DECLARE @INDEX SYSNAME;
DECLARE @INDEXES TABLE([SCHEMA] SYSNAME NULL, [TABLE] SYSNAME NOT NULL, [COLUMN] SYSNAME NOT NULL, 
	[INDEX_ID] INT NOT NULL, [INDEX] SYSNAME NULL, [TYPE_DESC] NVARCHAR(256) NULL);
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
		---------------------------------------------------------------------------------------------------------------------
		-- [INDEXES]
		INSERT INTO @INDEXES([SCHEMA], [TABLE], [COLUMN], [INDEX_ID], [INDEX], [TYPE_DESC])
		SELECT (CASE 
				WHEN [T].[schema_id] = @SCHEMA_REF_ID THEN @SCHEMA_REF_NAME
				WHEN [T].[schema_id] = @SCHEMA_DIM_ID THEN @SCHEMA_DIM_NAME
				ELSE NULL END)
			,[T].[name] [TABLE]
			,[COL].[name] [COLUMN]
			,[IND].[index_id] [INDEX_ID]
			,[IND].[name] [INDEX]
			,[IND].[type_desc] [TYPE_DESC]
		FROM [sys].[indexes] [IND]
		INNER JOIN [sys].[index_columns] [IC] ON [IND].[object_id] = [IC].[object_id] AND [IND].[index_id] = [IC].[index_id]
		INNER JOIN [sys].[columns] [COL] ON [IC].[object_id] = [COL].[object_id] AND [IC].[column_id] = [COL].[column_id]
		INNER JOIN [sys].[tables] [T] ON [IND].[object_id] = [T].[object_id];
		---------------------------------------------------------------------------------------------------------------------
		-- PERSONS
		PRINT N'[✓] TABLE [PERSONS]';
		-- [PERSONS] & [DT_CREATE]
		SET @INDEX = (SELECT [INDEX] FROM @INDEXES WHERE [SCHEMA] = @SCHEMA_REF_NAME AND [INDEX] = 'IX_PERSONS_DT_CREATE');
		IF (@INDEX IS NOT NULL) BEGIN
			SET @CMD = 'DROP INDEX IF EXISTS [' + @INDEX + '] ON [REF].[PERSONS]';
			EXEC (@CMD);
			PRINT N'[✓] INDEX DROPPED [' + @INDEX + N']';
		END;
		SET @INDEX = 'IX_PERSONS_DT_CREATE';
		SET @CMD = 'CREATE INDEX [' + @INDEX + '] ON [REF].[PERSONS] ([DT_CREATE])';
		EXEC (@CMD);
		PRINT N'[✓] INDEX CREATED [' + @INDEX + N']';
		-- [PERSONS] & [DT_CHANGE]
		SET @INDEX = (SELECT [INDEX] FROM @INDEXES WHERE [SCHEMA] = @SCHEMA_REF_NAME AND [INDEX] = 'IX_PERSONS_DT_CHANGE');
		IF (@INDEX IS NOT NULL) BEGIN
			SET @CMD = 'DROP INDEX IF EXISTS [' + @INDEX + '] ON [REF].[PERSONS]';
			EXEC (@CMD);
			PRINT N'[✓] INDEX DROPPED [' + @INDEX + N']';
		END;
		SET @INDEX = 'IX_PERSONS_DT_CHANGE';
		SET @CMD = 'CREATE INDEX [' + @INDEX + '] ON [REF].[PERSONS] ([DT_CHANGE])';
		EXEC (@CMD);
		PRINT N'[✓] INDEX CREATED [' + @INDEX + N']';
		-- [PERSONS] & [FAMILY]
		SET @INDEX = (SELECT [INDEX] FROM @INDEXES WHERE [SCHEMA] = @SCHEMA_REF_NAME AND [INDEX] = 'IX_PERSONS_FAMILY');
		IF (@INDEX IS NOT NULL) BEGIN
			SET @CMD = 'DROP INDEX IF EXISTS [' + @INDEX + '] ON [REF].[PERSONS]';
			EXEC (@CMD);
			PRINT N'[✓] INDEX DROPPED [' + @INDEX + N']';
		END;
		SET @INDEX = 'IX_PERSONS_FAMILY';
		SET @CMD = 'CREATE INDEX [' + @INDEX + '] ON [REF].[PERSONS] ([FAMILY])';
		EXEC (@CMD);
		PRINT N'[✓] INDEX CREATED [' + @INDEX + N']';
		-- [PERSONS] & [NAME]
		SET @INDEX = (SELECT [INDEX] FROM @INDEXES WHERE [SCHEMA] = @SCHEMA_REF_NAME AND [INDEX] = 'IX_PERSONS_NAME');
		IF (@INDEX IS NOT NULL) BEGIN
			SET @CMD = 'DROP INDEX IF EXISTS [' + @INDEX + '] ON [REF].[PERSONS]';
			EXEC (@CMD);
			PRINT N'[✓] INDEX DROPPED [' + @INDEX + N']';
		END;
		SET @INDEX = 'IX_PERSONS_NAME';
		SET @CMD = 'CREATE INDEX [' + @INDEX + '] ON [REF].[PERSONS] ([NAME])';
		EXEC (@CMD);
		PRINT N'[✓] INDEX CREATED [' + @INDEX + N']';
		-- [PERSONS] & [SURNAME]
		SET @INDEX = (SELECT [INDEX] FROM @INDEXES WHERE [SCHEMA] = @SCHEMA_REF_NAME AND [INDEX] = 'IX_PERSONS_SURNAME');
		IF (@INDEX IS NOT NULL) BEGIN
			SET @CMD = 'DROP INDEX IF EXISTS [' + @INDEX + '] ON [REF].[PERSONS]';
			EXEC (@CMD);
			PRINT N'[✓] INDEX DROPPED [' + @INDEX + N']';
		END;
		SET @INDEX = 'IX_PERSONS_SURNAME';
		SET @CMD = 'CREATE INDEX [' + @INDEX + '] ON [REF].[PERSONS] ([SURNAME])';
		EXEC (@CMD);
		PRINT N'[✓] INDEX CREATED [' + @INDEX + N']';
		-- [PERSONS] & [GENDER]
		SET @INDEX = (SELECT [INDEX] FROM @INDEXES WHERE [SCHEMA] = @SCHEMA_REF_NAME AND [INDEX] = 'IX_PERSONS_GENDER');
		IF (@INDEX IS NOT NULL) BEGIN
			SET @CMD = 'DROP INDEX IF EXISTS [' + @INDEX + '] ON [REF].[PERSONS]';
			EXEC (@CMD);
			PRINT N'[✓] INDEX DROPPED [' + @INDEX + N']';
		END;
		SET @INDEX = 'IX_PERSONS_GENDER';
		SET @CMD = 'CREATE INDEX [' + @INDEX + '] ON [REF].[PERSONS] ([GENDER])';
		EXEC (@CMD);
		PRINT N'[✓] INDEX CREATED [' + @INDEX + N']';
		-- [PERSONS] & [DT_BIRTH]
		SET @INDEX = (SELECT [INDEX] FROM @INDEXES WHERE [SCHEMA] = @SCHEMA_REF_NAME AND [INDEX] = 'IX_PERSONS_DT_BIRTH');
		IF (@INDEX IS NOT NULL) BEGIN
			SET @CMD = 'DROP INDEX IF EXISTS [' + @INDEX + '] ON [REF].[PERSONS]';
			EXEC (@CMD);
			PRINT N'[✓] INDEX DROPPED [' + @INDEX + N']';
		END;
		SET @INDEX = 'IX_PERSONS_DT_BIRTH';
		SET @CMD = 'CREATE INDEX [' + @INDEX + '] ON [REF].[PERSONS] ([DT_BIRTH])';
		EXEC (@CMD);
		PRINT N'[✓] INDEX CREATED [' + @INDEX + N']';
		-- [PERSONS] & [CELLPHONE]
		SET @INDEX = (SELECT [INDEX] FROM @INDEXES WHERE [SCHEMA] = @SCHEMA_REF_NAME AND [INDEX] = 'IX_PERSONS_CELLPHONE');
		IF (@INDEX IS NOT NULL) BEGIN
			SET @CMD = 'DROP INDEX IF EXISTS [' + @INDEX + '] ON [REF].[PERSONS]';
			EXEC (@CMD);
			PRINT N'[✓] INDEX DROPPED [' + @INDEX + N']';
		END;
		SET @INDEX = 'IX_PERSONS_CELLPHONE';
		SET @CMD = 'CREATE INDEX [' + @INDEX + '] ON [REF].[PERSONS] ([CELLPHONE])';
		EXEC (@CMD);
		PRINT N'[✓] INDEX CREATED [' + @INDEX + N']';
		-- [PERSONS] & [EMAIL]
		SET @INDEX = (SELECT [INDEX] FROM @INDEXES WHERE [SCHEMA] = @SCHEMA_REF_NAME AND [INDEX] = 'AK_PERSONS_EMAIL');
		IF (@INDEX IS NOT NULL) BEGIN
			SET @CMD = 'DROP INDEX IF EXISTS [' + @INDEX + '] ON [REF].[PERSONS]';
			EXEC (@CMD);
			PRINT N'[✓] INDEX DROPPED [' + @INDEX + N']';
		END;
		SET @INDEX = 'AK_PERSONS_EMAIL';
		SET @CMD = 'CREATE UNIQUE INDEX [' + @INDEX + '] ON [REF].[PERSONS] ([EMAIL])';
		EXEC (@CMD);
		PRINT N'[✓] INDEX CREATED [' + @INDEX + N']';
		---------------------------------------------------------------------------------------------------------------------
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
