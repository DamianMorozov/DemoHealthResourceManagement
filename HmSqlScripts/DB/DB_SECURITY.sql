------------------------------------------------------------------------------------------------------------------------
-- DB_SECURITY_DEV
------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
PRINT N'[ ] SET TRANSACTION ISOLATION LEVEL READ COMMITTED';
DECLARE @DB_NAME_CUR VARCHAR(128) = NULL;
DECLARE @DB_NAME_DEV VARCHAR(128) = 'HRM_DEMO_DEV';
DECLARE @DB_NAME_PROD VARCHAR(128) = 'HRM_DEMO_PROD';
DECLARE @CMD NVARCHAR(MAX);
------------------------------------------------------------------------------------------------------------------------
DECLARE @IS_ACTION_DEV BIT = 1;
DECLARE @IS_ACTION_PROD BIT = 0;
------------------------------------------------------------------------------------------------------------------------
-- DEVELOP
IF (@IS_ACTION_DEV = 1) BEGIN
	IF (DB_ID(@DB_NAME_DEV) IS NOT NULL) BEGIN
		SET @DB_NAME_CUR = @DB_NAME_DEV;
	END;
END;
------------------------------------------------------------------------------------------------------------------------
-- PRODUCT
IF (@IS_ACTION_PROD = 1) BEGIN
	IF (DB_ID(@DB_NAME_PROD) IS NOT NULL) BEGIN
		SET @DB_NAME_CUR = @DB_NAME_PROD;
	END;
END;
------------------------------------------------------------------------------------------------------------------------
-- JOB
IF (@DB_NAME_CUR IS NULL) BEGIN
	PRINT '[x] DB IS NOT EXISTS';
END ELSE BEGIN
	PRINT '[✓] DB IS SET [' + @DB_NAME_CUR + ']';
	-- DROP LOGINS & USERS
	USE [MASTER];
	SET @CMD = N'IF EXISTS(SELECT 1 FROM [SYS].[SERVER_PRINCIPALS] WHERE [NAME] = ''HM_USER'') BEGIN
	DROP LOGIN [HM_USER];
	PRINT ''[✓] DROP LOGIN [HM_USER] IS DONE'';
END;
IF EXISTS(SELECT 1 FROM [SYS].[SERVER_PRINCIPALS] WHERE [NAME] = ''HM_ADMIN'') BEGIN
	DROP LOGIN [HM_ADMIN];
	PRINT ''[✓] DROP LOGIN [HM_ADMIN] IS DONE'';
END;
USE [' + @DB_NAME_CUR + N'];
IF EXISTS (SELECT [NAME] FROM [SYS].[DATABASE_PRINCIPALS] WHERE [TYPE] = ''S'' AND [name] = ''HM_USER'') BEGIN
	DROP USER [HM_USER];
	PRINT ''[✓] DROP USER [HM_USER] IS DONE'';
END;
IF EXISTS (SELECT [NAME] FROM [SYS].[DATABASE_PRINCIPALS] WHERE [TYPE] = ''S'' AND [name] = ''HM_ADMIN'') BEGIN
	DROP USER [HM_ADMIN];
	PRINT ''[✓] DROP USER [HM_ADMIN] IS DONE'';
END;'
	EXEC(@CMD);
	-- CREATE LOGINS & USERS
	SET @CMD = N'USE [master];
-- CREATE LOGINS
CREATE LOGIN [HM_USER] WITH PASSWORD = ''HM_USER'', DEFAULT_DATABASE = [' + @DB_NAME_CUR + N'], DEFAULT_LANGUAGE = [us_english], 
	CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF;
PRINT ''[✓] CREATE LOGIN [HM_USER] IS DONE'';
CREATE LOGIN [HM_ADMIN] WITH PASSWORD = ''HM_ADMIN'', DEFAULT_DATABASE = [' + @DB_NAME_CUR + N'], DEFAULT_LANGUAGE = [us_english], 
	CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF;
PRINT ''[✓] CREATE LOGIN [HM_ADMIN] IS DONE'';
-- CREATE USER [HM_USER]
USE [' + @DB_NAME_CUR + N'];
CREATE USER [HM_USER] FOR LOGIN [HM_USER];
PRINT ''[✓] CREATE USER [HM_USER] FOR LOGIN [HM_USER] IS DONE'';
ALTER USER [HM_USER] WITH DEFAULT_SCHEMA = [dbo];
ALTER ROLE [db_datareader] ADD MEMBER [HM_USER];
PRINT ''[✓] ALTER ROLE [db_datareader] ADD MEMBER [HM_USER] IS DONE'';
ALTER ROLE [db_datawriter] ADD MEMBER [HM_USER];
PRINT ''[✓] ALTER ROLE [db_datawriter] ADD MEMBER [HM_USER] IS DONE'';
-- CREATE USER [HM_ADMIN]
USE [' + @DB_NAME_CUR + N'];
CREATE USER [HM_ADMIN] FOR LOGIN [HM_ADMIN];
PRINT ''[✓] CREATE USER [HM_ADMIN] FOR LOGIN [HM_ADMIN] IS DONE'';
ALTER USER [HM_ADMIN] WITH DEFAULT_SCHEMA = [dbo];
ALTER ROLE [db_datareader] ADD MEMBER [HM_ADMIN];
PRINT ''[✓] ALTER ROLE [db_datareader] ADD MEMBER [HM_ADMIN] IS DONE'';
ALTER ROLE [db_datawriter] ADD MEMBER [HM_ADMIN];
PRINT ''[✓] ALTER ROLE [db_datawriter] ADD MEMBER [HM_ADMIN] IS DONE'';
ALTER ROLE [db_owner] ADD MEMBER [HM_ADMIN];
PRINT ''[✓] ALTER ROLE [db_owner] ADD MEMBER [HM_ADMIN] IS DONE'';
ALTER ROLE [db_securityadmin] ADD MEMBER [HM_ADMIN];
PRINT ''[✓] ALTER ROLE [db_securityadmin] ADD MEMBER [HM_ADMIN] IS DONE'';';
	EXEC(@CMD);
END;
------------------------------------------------------------------------------------------------------------------------
