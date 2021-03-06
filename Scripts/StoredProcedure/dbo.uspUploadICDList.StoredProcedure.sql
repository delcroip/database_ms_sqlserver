/****** Object:  StoredProcedure [dbo].[uspUploadICDList]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspUploadICDList]
(
	@FilePath NVARCHAR(255),
	@AuditUserID INT,
	@DeleteRecord BIT = 0
)
AS
BEGIN
	
	DECLARE @BulkInsert NVARCHAR(2000)
	
	IF NOT OBJECT_ID('tempdb..#tempICD') IS NULL DROP TABLE #tempICD
	CREATE TABLE #tempICD(ICDCode NVARCHAR(6) ,ICDName NVARCHAR(255))
	
	SET @BulkInsert = N'BULK INSERT #tempICD FROM ''' + @FilePath + '''' +
		'WITH (
		FIELDTERMINATOR = ''	'',
		FIRSTROW = 2
		)'
	
	EXEC SP_EXECUTESQL @BulkInsert
	
	DECLARE @ICDCode NVARCHAR(6)
	DECLARE @ICDName NVARCHAR(255)
	DECLARE C CURSOR LOCAL FORWARD_ONLY FOR SELECT ICDCode,ICDName FROM #tempICD
	
	OPEN C
	FETCH NEXT FROM C INTO @ICDCode,@ICDName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF EXISTS(SELECT ICDCode FROM tblICDCodes WHERE ICDCode COLLATE DATABASE_DEFAULT = @ICDCode  COLLATE DATABASE_DEFAULT AND ValidityTo IS NULL)
			BEGIN
				INSERT INTO tblICDCodes(ICDCode,ICDName,LegacyID,ValidityTo,AuditUserID)
				SELECT ICDCode,ICDName,ICDID,GETDATE(),@AuditUserID FROM tblICDCodes WHERE ICDCode  COLLATE DATABASE_DEFAULT = @ICDCode  COLLATE DATABASE_DEFAULT AND ValidityTo IS NULL;
				
				UPDATE tblICDCodes SET ICDName = @ICDName,ValidityFrom = GETDATE(),AuditUserID = @AuditUserID WHERE ICDCode  COLLATE DATABASE_DEFAULT = @ICDCode  COLLATE DATABASE_DEFAULT AND ValidityTo IS NULL
			END
		ELSE
			BEGIN
				INSERT INTO tblICDCodes(ICDCode,ICDName,AuditUserID)
				VALUES(@ICDCode,@ICDName,@AuditUserID)
			END		
			
		FETCH NEXT FROM C INTO @ICDCode,@ICDName
	END

	IF @DeleteRecord = 1
	BEGIN
		INSERT INTO tblICDCodes (ICDCode,ICDName,LegacyID,ValidityTo,AuditUserID)
		SELECT I.ICDCode,I.ICDName,I.ICDID,GETDATE(),@AuditUserID
		FROM tblICDCodes I FULL OUTER JOIN #tempICD t ON I.ICDCode COLLATE DATABASE_DEFAULT = t.ICDCode COLLATE DATABASE_DEFAULT
		WHERE t.ICDCode IS NULL AND I.ValidityTo IS NULL

		UPDATE tblICDCodes SET ValidityTo = GETDATE(), AuditUserID = @AuditUserID 
		FROM tblICDCodes I FULL OUTER JOIN #tempICD t ON I.ICDCode COLLATE DATABASE_DEFAULT = t.ICDCode COLLATE DATABASE_DEFAULT
		WHERE t.ICDCode IS NULL AND I.ValidityTo IS NULL
	END
	
	CLOSE C
	DEALLOCATE C
	

END



GO
