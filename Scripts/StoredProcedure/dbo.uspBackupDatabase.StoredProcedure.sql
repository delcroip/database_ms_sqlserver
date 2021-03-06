/****** Object:  StoredProcedure [dbo].[uspBackupDatabase]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspBackupDatabase]
(
	@Path NVARCHAR(255)= '', 
	@Save BIT  = 0
)
AS
BEGIN
	
	DECLARE @DefaultPath NVARCHAR(255) = (select DatabaseBackupFolder from tblIMISDefaults)
	
	IF @Path = '' 
		SET @Path= @DefaultPath
	
	
	SET @Path += CASE WHEN RIGHT(LTRIM(RTRIM(@Path)), 1) <> '\' THEN '\' ELSE '' END;
		
	IF LOWER(@DefaultPath) <> LOWER(@Path) AND @Save = 1
	BEGIN
		UPDATE tblIMISDefaults SET DatabaseBackupFolder = @Path
	END
	
	DECLARE @DBName NVARCHAR(50) = DB_NAME();
	DECLARE @FileName NVARCHAR(255) = @Path + ''+ @DBName +'_BACKUP_' + CONVERT(NVARCHAR(50),GETDATE(),105) + '_' + CONVERT(NVARCHAR(2),DATEPART(HOUR,GETDATE())) + '-' + CONVERT(NVARCHAR(2),DATEPART(MINUTE,GETDATE())) + '.bak';
	
	DECLARE @SQL NVARCHAR(500) = 'BACKUP DATABASE ' + @DBName + ' TO DISK = ''' + @FileName + '''';

	EXEC (@SQL);


	
END
GO
