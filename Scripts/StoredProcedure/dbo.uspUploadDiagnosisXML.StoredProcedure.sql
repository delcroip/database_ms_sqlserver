/****** Object:  StoredProcedure [dbo].[uspUploadDiagnosisXML]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspUploadDiagnosisXML]
(
	--@File NVARCHAR(300),
	@XML XML,
	@StrategyId INT,	--1	: Insert Only,	2: Update Only	3: Insert & Update	7: Insert, Update & Delete
	@AuditUserID INT = -1,
	@DryRun BIT=0,
	@DiagnosisSent INT = 0 OUTPUT,
	@Inserts INT  = 0 OUTPUT,
	@Updates INT  = 0 OUTPUT,
	@Deletes INT = 0 OUTPUT
)
AS
BEGIN

	/* Result type in @tblResults
	-------------------------------
		E	:	Error
		C	:	Conflict
		FE	:	Fatal Error

	Return Values
	------------------------------
		0	:	All Okay
		-1	:	Fatal error
	*/
	

	DECLARE @InsertOnly INT = 1,
			@UpdateOnly INT = 2,
			@Delete INT= 4

	SET @Inserts = 0;
	SET @Updates = 0;
	SET @Deletes = 0;

	DECLARE @Query NVARCHAR(500)
	--DECLARE @XML XML
	DECLARE @tblDiagnosis TABLE(ICDCode nvarchar(50),  ICDName NVARCHAR(255), IsValid BIT)
	DECLARE @tblDeleted TABLE(Id INT, Code NVARCHAR(8));
	DECLARE @tblResult TABLE(Result NVARCHAR(Max), ResultType NVARCHAR(2))

	BEGIN TRY

		IF @AuditUserID IS NULL
			SET @AuditUserID=-1

		--SET @Query = (N'SELECT @XML = CAST(X as XML) FROM OPENROWSET(BULK  '''+ @File +''' ,SINGLE_BLOB) AS T(X)')

		--EXECUTE SP_EXECUTESQL @Query,N'@XML XML OUTPUT',@XML OUTPUT

		IF ( @XML.exist('(Diagnoses/Diagnosis/DiagnosisCode)')=1)
			BEGIN
				--GET ALL THE DIAGNOSES	 FROM THE XML
				INSERT INTO @tblDiagnosis(ICDCode,ICDName, IsValid)
				SELECT 
				T.F.value('(DiagnosisCode)[1]','NVARCHAR(12)'),
				T.F.value('(DiagnosisName)[1]','NVARCHAR(255)'),
				1 IsValid
				FROM @XML.nodes('Diagnoses/Diagnosis') AS T(F)

				SELECT @DiagnosisSent=@@ROWCOUNT
			END
		ELSE
			BEGIN
				RAISERROR (N'-200', 16, 1);
			END
	

	
		/*========================================================================================================
		VALIDATION STARTS
		========================================================================================================*/	

			--Invalidate empty code or empty name 
			IF EXISTS(
				SELECT 1
				FROM @tblDiagnosis D 
				WHERE LEN(ISNULL(D.ICDCode, '')) = 0
			)
			INSERT INTO @tblResult(Result, ResultType)
			SELECT CONVERT(NVARCHAR(3), COUNT(D.ICDCode)) + N' Diagnosis have empty Diagnosis code', N'E'
			FROM @tblDiagnosis D 
			WHERE LEN(ISNULL(D.ICDCode, '')) = 0

			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Diagnosis Code ' + QUOTENAME(D.ICDCode) + N' has empty name field', N'E'
			FROM @tblDiagnosis D 
			WHERE LEN(ISNULL(D.ICDName, '')) = 0


			UPDATE D SET IsValid = 0
			FROM @tblDiagnosis D 
			WHERE LEN(ISNULL(D.ICDCode, '')) = 0 OR LEN(ISNULL(D.ICDName, '')) = 0

			--Check if any ICD Code is greater than 6 characters
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Length of the Diagnosis Code ' + QUOTENAME(D.ICDCode) + ' is greater than 6 characters', N'E'
			FROM @tblDiagnosis D
			WHERE LEN(D.ICDCode) > 6;

			UPDATE D SET IsValid = 0
			FROM @tblDiagnosis D
			WHERE LEN(D.ICDCode) > 6;

			--Check if any ICD code is duplicated in the file
			INSERT INTO @tblResult(Result, ResultType)
			SELECT QUOTENAME(D.ICDCode) + ' found  ' + CONVERT(NVARCHAR(3), COUNT(D.ICDCode)) + ' times in the file', N'C'
			FROM @tblDiagnosis D
			GROUP BY D.ICDCode
			HAVING COUNT(D.ICDCode) > 1;
	
			UPDATE D SET IsValid = 0
			FROM @tblDiagnosis D
			WHERE D.ICDCode IN (
				SELECT ICDCode FROM @tblDiagnosis GROUP BY ICDCode HAVING COUNT(ICDCode) > 1
			)

		
		--Get the counts
		--To be deleted
		IF (@StrategyId & @Delete) > 0
		BEGIN
			--Get the list of ICDs which can't be deleted
			INSERT INTO @tblResult(Result, ResultType)
			SELECT QUOTENAME(D.ICDCode) + ' is used in claim. Can''t delete' Result, N'E' ResultType
			FROM tblClaim C
			INNER JOIN (
					SELECT D.ICDID Id, D.ICDCode
					FROM tblICDCodes D
					LEFT OUTER JOIN @tblDiagnosis temp ON D.ICDCode = temp.ICDCode
					WHERE D.ValidityTo IS NULL
					AND temp.ICDCode IS NULL
					
			) D ON C.ICDID = D.Id OR C.ICDID1 = D.Id OR C.ICDID2 = D.Id OR C.ICDID3 = D.Id OR C.ICDID4 = D.Id
			GROUP BY D.ICDCode;

			SELECT @Deletes = COUNT(1)
			FROM tblICDCodes D
			LEFT OUTER JOIN @tblDiagnosis temp ON D.ICDCode = temp.ICDCode AND temp.IsValid = 1
			LEFT OUTER JOIN tblClaim C ON C.ICDID = D.ICDID OR C.ICDID1 = D.ICDID OR C.ICDID2 = D.ICDID OR C.ICDID3 = D.ICDID OR C.ICDID4 = D.ICDID
			WHERE D.ValidityTo IS NULL
			AND temp.ICDCode IS NULL
			AND C.ClaimId IS NULL;
		END	
		
		--To be udpated
		IF (@StrategyId & @UpdateOnly) > 0
		BEGIN

			--Failed ICD
			IF @StrategyId=@UpdateOnly
				BEGIN
					INSERT INTO @tblResult(Result, ResultType)
					SELECT N'Diagnosis Code ' + QUOTENAME(D.ICDCode) + N' does not exists in Database', N'FI'
					FROM  @tblDiagnosis D
					LEFT OUTER JOIN tblICDCodes ICD ON ICD.ICDCode = D.ICDCode
					WHERE 
					ICD.ValidityTo IS NULL
					AND D.IsValid = 1
					AND ICD.ICDCode IS NULL
				END
			SELECT @Updates = COUNT(1)
			FROM tblICDCodes ICD
			INNER JOIN @tblDiagnosis D ON ICD.ICDCode = D.ICDCode
			WHERE ICD.ValidityTo IS NULL
			AND D.IsValid = 1
		END
		
		--To be  Inserted
		IF (@StrategyId & @InsertOnly) > 0
		BEGIN
			--Failed ICD
			IF(@StrategyId=@InsertOnly)
				BEGIN
					INSERT INTO @tblResult(Result, ResultType)
					SELECT 'Diagnosis Code '+  QUOTENAME(D.ICDCode) +' already exists in Database',N'FI' FROM @tblDiagnosis D
					INNER JOIN tblICDCodes ICD ON D.ICDCode=ICD.ICDCode WHERE ICD.ValidityTo IS NULL AND  D.IsValid=1
				END
			SELECT @Inserts = COUNT(1)
			FROM @tblDiagnosis D
			LEFT OUTER JOIN tblICDCodes ICD ON D.ICDCode = ICD.ICDCode AND ICD.ValidityTo IS NULL
			WHERE D.IsValid = 1
			AND ICD.ICDCode IS NULL
		END
		/*========================================================================================================
		VALIDATION ENDS
		========================================================================================================*/	

		IF @DryRun = 0
		BEGIN
			BEGIN TRAN UPLOAD

			/*========================================================================================================
			DELETE STARTS
			========================================================================================================*/	
				IF (@StrategyId & @Delete) > 0
				BEGIN
					
					
					INSERT INTO @tblDeleted(Id, Code)
					SELECT D.ICDID, D.ICDCode
					FROM tblICDCodes D
					LEFT OUTER JOIN @tblDiagnosis temp ON D.ICDCode = temp.ICDCode
					WHERE D.ValidityTo IS NULL
					AND temp.ICDCode IS NULL;


					--Check if any of the ICDCodes are used in Claims and remove them from the temporory table
					DELETE D
					FROM tblClaim C
					INNER JOIN @tblDeleted D ON C.ICDID = D.Id OR C.ICDID1 = D.Id OR C.ICDID2 = D.Id OR C.ICDID3 = D.Id OR C.ICDID4 = D.Id
	


					--Insert a copy of the to be deleted records
					INSERT INTO tblICDCodes(ICDCode, ICDName, ValidityFrom, ValidityTo, LegacyId, AuditUserId)
					OUTPUT QUOTENAME(inserted.ICDCode), N'D' INTO @tblResult
					SELECT ICD.ICDCode, ICD.ICDName, ICD.ValidityFrom, GETDATE() ValidityTo, ICD.ICDID LegacyId, @AuditUserID AuditUserId 
					FROM tblICDCodes ICD
					INNER JOIN @tblDeleted D ON ICD.ICDID = D.Id

					--Update the ValidtyFrom Flag to mark as deleted
					UPDATE ICD SET ValidityTo = GETDATE()
					FROM tblICDCodes ICD
					INNER JOIN @tblDeleted D ON ICD.ICDID = D.Id;
					
					SELECT @Deletes=@@ROWCOUNT;
				END
								
			/*========================================================================================================
			DELETE ENDS
			========================================================================================================*/	



			/*========================================================================================================
			UDPATE STARTS
			========================================================================================================*/	

				IF  (@StrategyId & @UpdateOnly) > 0
				BEGIN

				--Make a copy of the original record
					INSERT INTO tblICDCodes(ICDCode, ICDName, ValidityFrom, ValidityTo, LegacyId, AuditUserId)
					SELECT ICD.ICDCode, ICD.ICDName, ICD.ValidityFrom, GETDATE() ValidityTo, ICD.ICDID LegacyId, @AuditUserID AuditUserId 
					FROM tblICDCodes ICD
					INNER JOIN @tblDiagnosis D ON ICD.ICDCode = D.ICDCode
					WHERE ICD.ValidityTo IS NULL
					AND D.IsValid = 1;

					SELECT @Updates = @@ROWCOUNT;

				--Upadte the record
					UPDATE ICD SET ICDName = D.ICDName, ValidityFrom = GETDATE(), AuditUserID = @AuditUserID
					OUTPUT QUOTENAME(deleted.ICDCode), N'U' INTO @tblResult
					FROM tblICDCodes ICD
					INNER JOIN @tblDiagnosis D ON ICD.ICDCode = D.ICDCode
					WHERE ICD.ValidityTo IS NULL
					AND D.IsValid = 1;


				END

			/*========================================================================================================
			UPDATE ENDS
			========================================================================================================*/	

			/*========================================================================================================
			INSERT STARTS
			========================================================================================================*/	

				IF (@StrategyId & @InsertOnly) > 0
				BEGIN
					INSERT INTO tblICDCodes(ICDCode, ICDName, ValidityFrom, AuditUserId)
					OUTPUT QUOTENAME(inserted.ICDCode), N'I' INTO @tblResult
					SELECT D.ICDCode, D.ICDName, GETDATE() ValidityFrom, @AuditUserId AuditUserId
					FROM @tblDiagnosis D
					LEFT OUTER JOIN tblICDCodes ICD ON D.ICDCode = ICD.ICDCode AND ICD.ValidityTo IS NULL
					WHERE D.IsValid = 1
					AND ICD.ICDCode IS NULL;
	
					SELECT @Inserts = @@ROWCOUNT;
				END

			/*========================================================================================================
			INSERT ENDS
			========================================================================================================*/	


			COMMIT TRAN UPLOAD
			
		END
	END TRY
	BEGIN CATCH
		DECLARE @InvalidXML NVARCHAR(100)
		IF ERROR_NUMBER()=9436
			BEGIN 
				SET @InvalidXML='Invalid XML file, end tag does not match start tag'
				INSERT INTO @tblResult(Result, ResultType)
				SELECT @InvalidXML, N'FE';
			END
		ELSE IF  ERROR_MESSAGE()=N'-200'
			BEGIN
				INSERT INTO @tblResult(Result, ResultType)
			SELECT'Invalid Diagnosis XML file', N'FE';
			END
		ELSE
				INSERT INTO @tblResult(Result, ResultType)
				SELECT'Invalid XML file', N'FE';
			
		IF @@TRANCOUNT > 0 ROLLBACK TRAN UPLOAD;
		SELECT * FROM @tblResult;
		RETURN -1;
	END CATCH

	SELECT * FROM @tblResult;
	RETURN 0;
END


GO
