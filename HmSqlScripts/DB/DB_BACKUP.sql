------------------------------------------------------------------------------------------------------------------------
-- DB_BACKUP
------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
PRINT N'[ ] SET TRANSACTION ISOLATION LEVEL READ COMMITTED';
DECLARE @DB_NAME_CUR VARCHAR(128) = NULL;
DECLARE @DB_NAME_DEV VARCHAR(128) = 'HRM_DEMO_DEV';
DECLARE @DB_NAME_PROD VARCHAR(128) = 'HRM_DEMO_PROD';
DECLARE @FILE_BACKUP_CUR VARCHAR(256) = NULL;
DECLARE @FILE_BACKUP_DEV VARCHAR(256) = 'HRM_DEMO_DEV.BAK';
DECLARE @FILE_BACKUP_PROD VARCHAR(256) = 'HRM_DEMO_PROD.BAK';
DECLARE @FILE_EXIST INT;
DECLARE @CMD NVARCHAR(MAX);
USE [MASTER];
------------------------------------------------------------------------------------------------------------------------
DECLARE @IS_ACTION_DEV BIT = 1;
DECLARE @IS_ACTION_PROD BIT = 0;
------------------------------------------------------------------------------------------------------------------------
-- DEFAULT DIRS
DECLARE @DEFAULT_DATA NVARCHAR(512);	-- DATA
DECLARE @DEFAULT_LOG NVARCHAR(512);		-- LOGS
DECLARE @DEFAULT_BACKUP NVARCHAR(512);	-- BACKUP
DECLARE @MASTER_DATA NVARCHAR(512);		-- master.mdf
DECLARE @MASTER_LOG NVARCHAR(512);		-- master.ldf
EXEC MASTER.DBO.XP_INSTANCE_REGREAD N'HKEY_LOCAL_MACHINE', N'SOFTWARE\MICROSOFT\MSSQLSERVER\MSSQLSERVER', N'DEFAULTDATA', @DEFAULT_DATA OUTPUT;
EXEC MASTER.DBO.XP_INSTANCE_REGREAD N'HKEY_LOCAL_MACHINE', N'SOFTWARE\MICROSOFT\MSSQLSERVER\MSSQLSERVER', N'DEFAULTLOG', @DEFAULT_LOG OUTPUT;
EXEC MASTER.DBO.XP_INSTANCE_REGREAD N'HKEY_LOCAL_MACHINE', N'SOFTWARE\MICROSOFT\MSSQLSERVER\MSSQLSERVER', N'BACKUPDIRECTORY', @DEFAULT_BACKUP OUTPUT;
EXEC MASTER.DBO.XP_INSTANCE_REGREAD N'HKEY_LOCAL_MACHINE', N'SOFTWARE\MICROSOFT\MSSQLSERVER\MSSQLSERVER\PARAMETERS', N'SQLARG0', @MASTER_DATA OUTPUT;
SELECT @MASTER_DATA = SUBSTRING(@MASTER_DATA, 3, 255);
SELECT @MASTER_DATA = SUBSTRING(@MASTER_DATA, 1, LEN(@MASTER_DATA) - CHARINDEX('\', REVERSE(@MASTER_DATA)));
EXEC MASTER.DBO.XP_INSTANCE_REGREAD N'HKEY_LOCAL_MACHINE', N'SOFTWARE\MICROSOFT\MSSQLSERVER\MSSQLSERVER\PARAMETERS', N'SQLARG2', @MASTER_LOG OUTPUT;
SELECT @MASTER_LOG = SUBSTRING(@MASTER_LOG, 3, 255);
SELECT @MASTER_LOG = SUBSTRING(@MASTER_LOG, 1, LEN(@MASTER_LOG) - CHARINDEX('\', REVERSE(@MASTER_LOG)));
PRINT N'[✓] FOUND DEFAULT DIRS IS SUCCESS';
------------------------------------------------------------------------------------------------------------------------
-- DEVELOP
IF (@IS_ACTION_DEV = 1) BEGIN
	IF (DB_ID(@DB_NAME_DEV) IS NOT NULL) BEGIN
		SET @DB_NAME_CUR = @DB_NAME_DEV;
		SET @FILE_BACKUP_CUR = @FILE_BACKUP_DEV;
	END;
END;
------------------------------------------------------------------------------------------------------------------------
-- PRODUCT
IF (@IS_ACTION_PROD = 1) BEGIN
	IF (DB_ID(@DB_NAME_PROD) IS NOT NULL) BEGIN
		SET @DB_NAME_CUR = @DB_NAME_PROD;
		SET @FILE_BACKUP_CUR = @FILE_BACKUP_PROD;
	END;
END;
------------------------------------------------------------------------------------------------------------------------
-- JOB
IF (@DB_NAME_CUR IS NULL) BEGIN
	PRINT N'[x] DB IS NOT SET';
END ELSE BEGIN
	PRINT N'[✓] DB IS SET [' + @DB_NAME_CUR + N']';
	SET @FILE_BACKUP_CUR = @DEFAULT_BACKUP + '\' + @FILE_BACKUP_CUR;
	PRINT N'[✓] BACKUP CONFIGURED [' + @FILE_BACKUP_CUR + N']';
    EXEC [master].[dbo].[xp_fileexist] @FILE_BACKUP_CUR, @FILE_EXIST OUT;
    -- FULL BACKUP
    IF (@FILE_EXIST = 0) BEGIN
        SET @CMD = N'BACKUP DATABASE [' + @DB_NAME_CUR + N'] TO DISK=''' + @FILE_BACKUP_CUR + 
            N''' WITH NOFORMAT, NOINIT, NAME=''' + @DB_NAME_CUR + ' - FULL DATABASE BACKUP'', SKIP, NOREWIND, NOUNLOAD, STATS = 10;';
        PRINT @CMD;
        EXEC (@CMD);
        PRINT N'[✓] FULL BACKUP DEVELOP DB: ' + @FILE_BACKUP_CUR;
    -- DIFF BACKUP
    END ELSE BEGIN
        SET @CMD = N'BACKUP DATABASE [' + @DB_NAME_CUR + N'] TO DISK=''' + @FILE_BACKUP_CUR+
            N''' WITH  DIFFERENTIAL, NOFORMAT, NOINIT, NAME=''' + @DB_NAME_CUR + ' - DIFF DATABASE BACKUP'', SKIP, NOREWIND, NOUNLOAD, STATS = 10;';
        EXEC (@CMD);
		PRINT N'[✓] DIFF BACKUP DEVELOP DB: ' + @FILE_BACKUP_CUR;
    END;
END;
------------------------------------------------------------------------------------------------------------------------
