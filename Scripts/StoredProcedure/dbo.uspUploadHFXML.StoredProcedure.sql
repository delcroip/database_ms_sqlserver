/****** Object:  StoredProcedure [dbo].[uspUploadHFXML]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspUploadHFXML]
(
	--@File NVARCHAR(300),
	@XML XML,
	@StrategyId INT,	--1	: Insert Only,	2: Update Only	3: Insert & Update	7: Insert, Update & Delete
	@AuditUserID INT = -1,
	@DryRun BIT=0,
	@SentHF INT = 0 OUTPUT,
	@Inserts INT  = 0 OUTPUT,
	@Updates INT  = 0 OUTPUT,
	@sentCatchment INT =0 OUTPUT,
	@InsertCatchment INT =0 OUTPUT,
	@UpdateCatchment INT =0 OUTPUT
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
	SET @InsertCatchment=0;
	SET @UpdateCatchment =0;
	
	DECLARE @Query NVARCHAR(500)
	--DECLARE @XML XML
	DECLARE @tblHF TABLE(LegalForms NVARCHAR(15), [Level] NVARCHAR(15)  NULL, SubLevel NVARCHAR(15), Code NVARCHAR (50) NULL, Name NVARCHAR (101) NULL, [Address] NVARCHAR (101), DistrictCode NVARCHAR (50) NULL,Phone NVARCHAR (51), Fax NVARCHAR (51), Email NVARCHAR (51), CareType CHAR (15) NULL, AccountCode NVARCHAR (26),ItemPriceListName NVARCHAR(120),ServicePriceListName NVARCHAR(120), IsValid BIT )
	DECLARE @tblResult TABLE(Result NVARCHAR(Max), ResultType NVARCHAR(2))
	DECLARE @tblCatchment TABLE(HFCode NVARCHAR(50), VillageCode NVARCHAR(50),Percentage INT, IsValid BIT )

	BEGIN TRY
		IF @AuditUserID IS NULL
			SET @AuditUserID=-1

		--SET @Query = (N'SELECT @XML = CAST(X as XML) FROM OPENROWSET(BULK  '''+ @File +''' ,SINGLE_BLOB) AS T(X)')

		--EXECUTE SP_EXECUTESQL @Query,N'@XML XML OUTPUT',@XML OUTPUT

		IF ( @XML.exist('(HealthFacilities/HealthFacilityDetails)')=1 AND @XML.exist('(HealthFacilities/CatchmentDetails)')=1 )
			BEGIN
				--GET ALL THE HF FROM THE XML
				INSERT INTO @tblHF(LegalForms,[Level],SubLevel,Code,Name,[Address],DistrictCode,Phone,Fax,Email,CareType,AccountCode, ItemPriceListName, ServicePriceListName, IsValid)
				SELECT 
				NULLIF(T.F.value('(LegalForm)[1]','NVARCHAR(15)'),''),
				NULLIF(T.F.value('(Level)[1]','NVARCHAR(15)'),''),
				NULLIF(T.F.value('(SubLevel)[1]','NVARCHAR(15)'),''),
				T.F.value('(Code)[1]','NVARCHAR(50)'),
				T.F.value('(Name)[1]','NVARCHAR(101)'),
				T.F.value('(Address)[1]','NVARCHAR(101)'),
				NULLIF(T.F.value('(DistrictCode)[1]','NVARCHAR(50)'),''),
				T.F.value('(Phone)[1]','NVARCHAR(51)'),
				T.F.value('(Fax)[1]','NVARCHAR(51)'),
				T.F.value('(Email)[1]','NVARCHAR(51)'),
				NULLIF(T.F.value('(CareType)[1]','NVARCHAR(15)'),''),
				T.F.value('(AccountCode)[1]','NVARCHAR(26)'),
				NULLIF(T.F.value('(ItemPriceListName)[1]','NVARCHAR(26)'), ''),
				NULLIF(T.F.value('(ServicePriceListName)[1]','NVARCHAR(26)'), ''),
				1
				FROM @XML.nodes('HealthFacilities/HealthFacilityDetails/HealthFacility') AS T(F)

				SELECT @SentHF=@@ROWCOUNT


				INSERT INTO @tblCatchment(HFCode,VillageCode,Percentage,IsValid)
				SELECT 
				C.CT.value('(HFCode)[1]','NVARCHAR(50)'),
				C.CT.value('(VillageCode)[1]','NVARCHAR(50)'),
				C.CT.value('(Percentage)[1]','FLOAT'),
				1
				FROM @XML.nodes('HealthFacilities/CatchmentDetails/Catchment') AS C(CT)

				SELECT @sentCatchment=@@ROWCOUNT
			END
		ELSE
			BEGIN
				RAISERROR (N'-200', 16, 1);
			END
			
			
		--SELECT * INTO tempHF FROM @tblHF;
		--SELECT * INTO tempCatchment FROM @tblCatchment;

		--RETURN;

		/*========================================================================================================
		VALIDATION STARTS
		========================================================================================================*/	
		--Invalidate empty code or empty name 
			IF EXISTS(
				SELECT 1
				FROM @tblHF HF 
				WHERE LEN(ISNULL(HF.Code, '')) = 0
			)
			INSERT INTO @tblResult(Result, ResultType)
			SELECT CONVERT(NVARCHAR(3), COUNT(HF.Code)) + N' HF(s) have empty code', N'E'
			FROM @tblHF HF 
			WHERE LEN(ISNULL(HF.Code, '')) = 0

			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'HF Code ' + QUOTENAME(HF.Code) + N' has empty name field', N'E'
			FROM @tblHF HF
			WHERE LEN(ISNULL(HF.Name, '')) = 0


			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE LEN(ISNULL(HF.Name, '')) = 0 OR LEN(ISNULL(HF.Code, '')) = 0

			--Ivalidate empty Legal Forms
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'HF Code ' + QUOTENAME(HF.Code) + N' has empty LegaForms field', N'E'
			FROM @tblHF HF
			WHERE LEN(ISNULL(HF.LegalForms, '')) = 0

			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE LEN(ISNULL(HF.LegalForms, '')) = 0 


			--Ivalidate empty Level
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'HF Code ' + QUOTENAME(HF.Code) + N' has empty Level field', N'E'
			FROM @tblHF HF
			WHERE LEN(ISNULL(HF.Level, '')) = 0

			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE LEN(ISNULL(HF.Level, '')) = 0 

			--Ivalidate empty District Code
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'HF Code ' + QUOTENAME(HF.Code) + N' has empty District Code field', N'E'
			FROM @tblHF HF
			WHERE LEN(ISNULL(HF.DistrictCode, '')) = 0

			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE LEN(ISNULL(HF.DistrictCode, '')) = 0 OR LEN(ISNULL(HF.Code, '')) = 0

				--Ivalidate empty Care Type
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'HF Code ' + QUOTENAME(HF.Code) + N' has empty Care Type field', N'E'
			FROM @tblHF HF
			WHERE LEN(ISNULL(HF.CareType, '')) = 0

			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE LEN(ISNULL(HF.CareType, '')) = 0 OR LEN(ISNULL(HF.Code, '')) = 0


			--Invalidate HF with duplicate Codes
			IF EXISTS(SELECT 1 FROM @tblHF  GROUP BY Code HAVING COUNT(Code) >1)
			INSERT INTO @tblResult(Result, ResultType)
			SELECT QUOTENAME(Code) + ' found  ' + CONVERT(NVARCHAR(3), COUNT(Code)) + ' times in the file', N'C'
			FROM @tblHF  GROUP BY Code HAVING COUNT(Code) >1

			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE code in (SELECT code from @tblHF GROUP BY Code HAVING COUNT(Code) >1)

			--Invalidate HF with invalid Legal Forms
			INSERT INTO @tblResult(Result,ResultType)
			SELECT 'HF Code '+QUOTENAME(Code) +' has invalid Legal Form', N'E'  FROM @tblHF HF LEFT OUTER JOIN tblLegalForms LF ON HF.LegalForms = LF.LegalFormCode 	WHERE LF.LegalFormCode IS NULL AND NOT HF.LegalForms IS NULL
			
			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE Code IN (SELECT Code FROM @tblHF HF LEFT OUTER JOIN tblLegalForms LF ON HF.LegalForms = LF.LegalFormCode 	WHERE LF.LegalFormCode IS NULL AND NOT HF.LegalForms IS NULL)


			--Ivalidate HF with invalid Disrict Code
			IF EXISTS(SELECT 1  FROM @tblHF HF 	LEFT OUTER JOIN tblLocations L ON L.LocationCode=HF.DistrictCode AND L.ValidityTo IS NULL	WHERE	L.LocationCode IS NULL AND NOT HF.DistrictCode IS NULL)
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'HF Code ' + QUOTENAME(HF.Code) + N' has invalid District Code', N'E'
			FROM @tblHF HF 	LEFT OUTER JOIN tblLocations L ON L.LocationCode=HF.DistrictCode AND L.ValidityTo IS NULL	WHERE L.LocationCode IS NULL AND NOT HF.DistrictCode IS NULL
	
			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE HF.DistrictCode IN (SELECT HF.DistrictCode  FROM @tblHF HF 	LEFT OUTER JOIN tblLocations L ON L.LocationCode=HF.DistrictCode AND L.ValidityTo IS NULL WHERE  L.LocationCode IS NULL)

			--Invalidate HF with invalid Level
			INSERT INTO @tblResult(Result,ResultType)
			SELECT N'HF Code '+ QUOTENAME(HF.Code)+' has invalid Level', N'E'   FROM @tblHF HF LEFT OUTER JOIN (SELECT HFLevel FROM tblHF WHERE ValidityTo IS NULL GROUP BY HFLevel) L ON HF.Level = L.HFLevel WHERE L.HFLevel IS NULL AND NOT HF.Level IS NULL
			
			UPDATE HF SET IsValid = 0
			FROM @tblHF HF 
			WHERE Code IN (SELECT Code FROM @tblHF HF LEFT OUTER JOIN (SELECT HFLevel FROM tblHF WHERE ValidityTo IS NULL GROUP BY HFLevel) L ON HF.Level = L.HFLevel WHERE L.HFLevel IS NULL AND NOT HF.Level IS NULL)
			
			--Invalidate HF with invalid SubLevel
			INSERT INTO @tblResult(Result,ResultType)
			SELECT N'HF Code '+QUOTENAME(HF.Code) +' has invalid SubLevel' ,N'E'  FROM @tblHF HF LEFT OUTER JOIN tblHFSublevel HSL ON HSL.HFSublevel= HF.SubLevel WHERE HSL.HFSublevel IS NULL AND NOT HF.SubLevel IS NULL
			UPDATE HF SET IsValid = 0
			FROM @tblHF HF 
			WHERE Code IN (SELECT Code FROM @tblHF HF LEFT OUTER JOIN tblHFSublevel HSL ON HSL.HFSublevel= HF.SubLevel WHERE HSL.HFSublevel IS NULL AND NOT HF.SubLevel IS NULL)

			--Remove HF with invalid CareType
			INSERT INTO @tblResult(Result,ResultType)
			SELECT N'HF Code '+QUOTENAME(HF.Code) +' has invalid CareType',N'E'   FROM @tblHF HF LEFT OUTER JOIN (SELECT HFCareType FROM tblHF WHERE ValidityTo IS NULL GROUP BY HFCareType) CT ON HF.CareType = CT.HFCareType WHERE CT.HFCareType IS NULL AND NOT HF.CareType IS NULL
			UPDATE HF SET IsValid = 0
			FROM @tblHF HF 
			WHERE Code IN (SELECT Code FROM @tblHF HF LEFT OUTER JOIN (SELECT HFCareType FROM tblHF WHERE ValidityTo IS NULL GROUP BY HFCareType) CT ON HF.CareType = CT.HFCareType WHERE CT.HFCareType IS NULL)


			--Check if any HF Code is greater than 8 characters
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Length of the HF Code ' + QUOTENAME(HF.Code) + ' is greater than 8 characters', N'E'
			FROM @tblHF HF
			WHERE LEN(HF.Code) > 8;

			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE LEN(HF.Code) > 8;

			--Check if any HF Name is greater than 100 characters
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Length of the HF Name ' + QUOTENAME(HF.Code) + ' is greater than 100 characters', N'E'
			FROM @tblHF HF
			WHERE LEN(HF.Name) > 100;

			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE LEN(HF.Name) > 100;


			--Check if any HF Address is greater than 100 characters
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Length of the HF Address ' + QUOTENAME(HF.Code) + ' is greater than 100 characters', N'E'
			FROM @tblHF HF
			WHERE LEN(HF.Address) > 100;

			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE LEN(HF.Address) > 100;

			--Check if any HF Phone is greater than 50 characters
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Length of the HF Phone ' + QUOTENAME(HF.Code) + ' is greater than 50 characters', N'E'
			FROM @tblHF HF
			WHERE LEN(HF.Phone) > 50;

			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE LEN(HF.Phone) > 50;

			--Check if any HF Fax is greater than 50 characters
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Length of the HF Fax ' + QUOTENAME(HF.Code) + ' is greater than 50 characters', N'E'
			FROM @tblHF HF
			WHERE LEN(HF.Fax) > 50;

			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE LEN(HF.Fax) > 50;

			--Check if any HF Email is greater than 50 characters
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Length of the HF Email ' + QUOTENAME(HF.Code) + ' is greater than 50 characters', N'E'
			FROM @tblHF HF
			WHERE LEN(HF.Email) > 50;

			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE LEN(HF.Email) > 50;

			--Check if any HF AccountCode is greater than 25 characters
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Length of the HF Account Code ' + QUOTENAME(HF.Code) + ' is greater than 50 characters', N'E'
			FROM @tblHF HF
			WHERE LEN(HF.AccountCode) > 25;

			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE LEN(HF.AccountCode) > 25;

			--Invalidate HF with invalid Item Price List Name
			INSERT INTO @tblResult(Result,ResultType)
			SELECT N'HF Code '+QUOTENAME(HF.Code) +' has invalid Item Price List Name' ,N'E'  
			FROM @tblHF HF
			INNER JOIN tblDistricts D ON HF.DistrictCode = D.DistrictCode
			LEFT OUTER JOIN tblPLItems PLI ON HF.ItemPriceListName = PLI.PLItemName 
			WHERE PLI.ValidityTo IS NULL 
			AND NOT(PLI.LocationId = D.DistrictId OR PLI.LocationId = D.Region)
			AND HF.ItemPriceListName IS NOT NULL;

			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			INNER JOIN tblDistricts D ON HF.DistrictCode = D.DistrictCode
			LEFT OUTER JOIN tblPLItems PLI ON HF.ItemPriceListName = PLI.PLItemName 
			WHERE PLI.ValidityTo IS NULL 
			AND NOT(PLI.LocationId = D.DistrictId OR PLI.LocationId = D.Region)
			AND HF.ItemPriceListName IS NOT NULL;

			--Invalidate HF with invalid Service Price List Name
			INSERT INTO @tblResult(Result,ResultType)
			SELECT N'HF Code '+QUOTENAME(HF.Code) +' has invalid Service Price List Name' ,N'E'  
			FROM @tblHF HF
			INNER JOIN tblDistricts D ON HF.DistrictCode = D.DistrictCode
			LEFT OUTER JOIN tblPLServices PLS ON HF.ServicePriceListName = PLS.PLServName 
			WHERE PLS.ValidityTo IS NULL 
			AND NOT(PLS.LocationId = D.DistrictId OR PLS.LocationId = D.Region)
			AND HF.ServicePriceListName IS NOT NULL;

			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			INNER JOIN tblDistricts D ON HF.DistrictCode = D.DistrictCode
			LEFT OUTER JOIN tblPLServices PLS ON HF.ServicePriceListName = PLS.PLServName 
			WHERE PLS.ValidityTo IS NULL 
			AND NOT(PLS.LocationId = D.DistrictId OR PLS.LocationId = D.Region)
			AND HF.ServicePriceListName IS NOT NULL;

			--Check if any ItemPriceList is greater than 100 characters
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Length of the ItemPriceListName ' + QUOTENAME(HF.Code) + ' is greater than 100 characters', N'E'
			FROM @tblHF HF
			WHERE LEN(HF.ItemPriceListName) > 100;

			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE LEN(HF.ItemPriceListName) > 100;

			--Check if any ServicePriceListName is greater than 100 characters
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Length of the ServicePriceListName ' + QUOTENAME(HF.Code) + ' is greater than 100 characters', N'E'
			FROM @tblHF HF
			WHERE LEN(HF.ServicePriceListName) > 100;

			UPDATE HF SET IsValid = 0
			FROM @tblHF HF
			WHERE LEN(HF.ServicePriceListName) > 100;

			--Invalidate Catchment with empy HFCode
			IF EXISTS(SELECT  1 FROM @tblCatchment WHERE LEN(ISNULL(HFCode,''))=0)
			INSERT INTO @tblResult(Result,ResultType)
			SELECT  CONVERT(NVARCHAR(3), COUNT(HFCode)) + N' Catchment(s) have empty HFcode', N'E' FROM @tblCatchment WHERE LEN(ISNULL(HFCode,''))=0
			UPDATE @tblCatchment SET IsValid = 0 WHERE LEN(ISNULL(HFCode,''))=0

			--Invalidate Catchment with invalid HFCode
			INSERT INTO @tblResult(Result,ResultType)
			SELECT N'Invalid HF Code ' + QUOTENAME(C.HFCode) + N' in catchment section', N'E' FROM @tblCatchment C 
			LEFT OUTER JOIN @tblHF tempHF ON C.HFCode=tempHF.Code
			LEFT OUTER JOIN tblHF HF ON C.HFCode=HF.HFCode 
			WHERE (tempHF.Code IS NULL AND HF.HFCode IS NULL)
			AND HF.ValidityTo IS NULL
			--AND tempHF.IsValid=1

			UPDATE C SET C.IsValid =0 FROM @tblCatchment C 
			LEFT OUTER JOIN @tblHF tempHF ON C.HFCode=tempHF.Code
			LEFT OUTER JOIN tblHF HF ON C.HFCode=HF.HFCode 
			WHERE (tempHF.Code IS NULL AND HF.HFCode IS NULL)
			AND HF.ValidityTo IS NULL
			--AND tempHF.IsValid=1
		
			--Invalidate Catchment with empy VillageCode
			INSERT INTO @tblResult(Result,ResultType)
			SELECT N'HF Code ' + QUOTENAME(HFCode) + N' in catchment section has an empty VillageCode', N'E' FROM @tblCatchment WHERE LEN(ISNULL(VillageCode,''))=0
			UPDATE @tblCatchment SET IsValid = 0 WHERE LEN(ISNULL(VillageCode,''))=0

			--Invalidate Catchment with invalid VillageCode
			INSERT INTO @tblResult(Result,ResultType)
			SELECT N'Invalid Village Code ' + QUOTENAME(C.VillageCode) + N' in catchment section', N'E' FROM @tblCatchment C LEFT OUTER JOIN tblLocations L ON L.LocationCode=C.VillageCode WHERE L.ValidityTo IS NULL AND L.LocationCode IS NULL AND LEN(ISNULL(VillageCode,''))>0
			UPDATE C SET IsValid=0 FROM @tblCatchment C LEFT OUTER JOIN tblLocations L ON L.LocationCode=C.VillageCode WHERE L.ValidityTo IS NULL AND L.LocationCode IS NULL
		
			--Invalidate Catchment with empty percentage
			INSERT INTO @tblResult(Result,ResultType)
			SELECT  N'HF Code ' + QUOTENAME(HFCode) + N' in catchment section has an empty or invalid percentage', N'E' FROM @tblCatchment WHERE Percentage=0
			UPDATE @tblCatchment SET IsValid = 0 WHERE Percentage=0

			--Invalidate Catchment with invalid percentage
			INSERT INTO @tblResult(Result,ResultType)
			SELECT  N'HF Code ' + QUOTENAME(HFCode) + N' in catchment section has invalid percentage', N'E' FROM @tblCatchment WHERE Percentage < 0 OR Percentage > 100
			UPDATE @tblCatchment SET IsValid = 0 WHERE Percentage<0 OR Percentage >100

			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Village Code ' + QUOTENAME(C.VillageCode) + ' found ' + CAST(COUNT(C.VillageCode) AS NVARCHAR(4)) + ' time(s) in the Catchement for the HF Code ' + QUOTENAME(C.HFCode), 'C'
			FROM @tblCatchment C
			GROUP BY C.HFCode, C.VillageCode
			HAVING COUNT(C.VillageCode) > 1;

			UPDATE C SET IsValid = 0
			FROM @tblCatchment C
			 WHERE C.VillageCode IN (
			SELECT C.VillageCode
			FROM @tblCatchment C
			GROUP BY C.HFCode, C.VillageCode
			HAVING COUNT(C.VillageCode) > 1
			 )

			--UPDATE HF SET IsValid = 0
			--FROM @tblHF HF
			--INNER JOIN @tblCatchment C ON HF.Code = C.HFCode
			-- WHERE C.HFCode IN (
			--SELECT C.HFCode
			--FROM @tblCatchment C
			--GROUP BY C.HFCode, C.VillageCode
			--HAVING COUNT(C.VillageCode) > 1
			-- )

			


			--Get the counts
			--To be udpated
			IF (@StrategyId & @UpdateOnly) > 0
				BEGIN
					
					--Failed HF
					IF (@StrategyId=@UpdateOnly)
						BEGIN
							INSERT INTO @tblResult(Result,ResultType)
							SELECT 'HF Code '+  QUOTENAME(tempHF.Code) +' does not exists in Database',N'FH'  FROM @tblHF tempHF
							LEFT OUTER JOIN tblHF HF ON HF.HFCode=tempHF.Code
							WHERE 
							--tempHF.IsValid=1 AND
							HF.ValidityTo IS NULL
							AND HF.HFCode IS NULL
						END

					SELECT @Updates=COUNT(1) FROM @tblHF TempHF
					INNER JOIN tblHF HF ON HF.HFCode=TempHF.Code 
					WHERE TempHF.IsValid=1 AND
					 HF.ValidityTo IS NULL

					SELECT @UpdateCatchment =COUNT(1) 
					FROM @tblCatchment C 
					INNER JOIN tblHF HF ON C.HFCode=HF.HFCode
					INNER JOIN tblLocations L ON L.LocationCode=C.VillageCode
					INNER JOIN tblHFCatchment HFC ON HFC.LocationId=L.LocationId AND HFC.HFID=HF.HfID
					WHERE 
					C.IsValid =1
					AND L.ValidityTo IS NULL
					AND HF.ValidityTo IS NULL
					AND HFC.ValidityTo IS NULL
				END
			
			--To be Inserted
			IF (@StrategyId & @InsertOnly) > 0
				BEGIN
				
				--Failed HF
					IF(@StrategyId=@InsertOnly)
						BEGIN
							INSERT INTO @tblResult(Result,ResultType)
							SELECT 'HF Code '+  QUOTENAME(tempHF.Code) +' already exists in Database',N'FH' 
							FROM @tblHF tempHF
							INNER JOIN tblHF HF ON tempHF.Code=HF.HFCode 
							WHERE HF.ValidityTo IS NULL 
							--AND  tempHF.IsValid=1
						END

					SELECT @Inserts=COUNT(1) FROM @tblHF TempHF
					LEFT OUTER JOIN tblHF HF ON HF.HFCode=TempHF.Code AND HF.ValidityTo IS NULL
					WHERE TempHF.IsValid=1
					AND HF.HFCode IS NULL

					SELECT @InsertCatchment=COUNT(1) FROM @tblCatchment C 
					LEFT OUTER JOIN tblHF HF ON C.HFCode=HF.HFCode
					LEFT OUTER JOIN @tblHF tempHF ON tempHF.Code=C.HFCode
					INNER JOIN tblLocations L ON L.LocationCode=C.VillageCode
					LEFT OUTER JOIN tblHFCatchment HFC ON HFC.LocationId=L.LocationId AND HFC.HFID=HF.HfID
					WHERE 
					C.IsValid =1
					AND L.ValidityTo IS NULL
					AND HF.ValidityTo IS NULL
					AND HFC.ValidityTo IS NULL
					AND HFC.LocationId IS NULL
					AND HFC.HFID IS NULL
					AND (tempHF.Code IS NOT NULL OR HF.HFCode IS NOT NULL)
				END
			
		/*========================================================================================================
		VALIDATION ENDS
		========================================================================================================*/	
		IF @DryRun=0
		BEGIN
			BEGIN TRAN UPLOAD
				
			/*========================================================================================================
			UDPATE HF  STARTS
			========================================================================================================*/	
			IF  (@StrategyId & @UpdateOnly) > 0
				BEGIN

					--HF
					--Make a copy of the original record
					INSERT INTO tblHF(HFCode, HFName,[LegalForm],[HFLevel],[HFSublevel],[HFAddress],[LocationId],[Phone],[Fax],[eMail],[HFCareType],[PLServiceID],[PLItemID],[AccCode],[OffLine],[ValidityFrom],[ValidityTo],LegacyID, AuditUserId)
					SELECT HF.[HFCode] ,HF.[HFName],HF.[LegalForm],HF.[HFLevel],HF.[HFSublevel],HF.[HFAddress],HF.[LocationId],HF.[Phone],HF.[Fax],HF.[eMail],HF.[HFCareType],HF.[PLServiceID],HF.[PLItemID],HF.[AccCode],HF.[OffLine],[ValidityFrom],GETDATE()[ValidityTo],HF.HfID, @AuditUserID AuditUserId 
					FROM tblHF HF
					INNER JOIN @tblHF TempHF  ON TempHF.Code=HF.HFCode
					WHERE HF.ValidityTo IS NULL
					AND TempHF.IsValid = 1;

					SELECT @Updates = @@ROWCOUNT;
				--Upadte the record
					UPDATE HF SET HF.HFName = TempHF.Name, HF.LegalForm=TempHF.LegalForms,HF.HFLevel=TempHF.Level, HF.HFSublevel=TempHF.SubLevel,HF.HFAddress=TempHF.Address,HF.LocationId=L.LocationId, HF.Phone=TempHF.Phone, HF.Fax=TempHF.Fax, HF.eMail=TempHF.Email,HF.HFCareType=TempHF.CareType, HF.AccCode=TempHF.AccountCode, HF.PLItemID=PLI.PLItemID, HF.PLServiceID=PLS.PLServiceID, HF.OffLine=0, HF.ValidityFrom=GETDATE(), AuditUserID = @AuditUserID
					OUTPUT QUOTENAME(deleted.HFCode), N'U' INTO @tblResult
					FROM tblHF HF
					INNER JOIN @tblHF TempHF  ON HF.HFCode=TempHF.Code
					INNER JOIN tblLocations L ON L.LocationCode=TempHF.DistrictCode
					LEFT OUTER JOIN tblPLItems PLI ON PLI.PLItemName= tempHF.ItemPriceListName AND (PLI.LocationId = L.LocationId OR PLI.LocationId = L.ParentLocationId)
					LEFT OUTER JOIN tblPLServices PLS ON PLS.PLServName=tempHF.ServicePriceListName  AND (PLS.LocationId = L.LocationId OR PLS.LocationId = L.ParentLocationId)
					WHERE HF.ValidityTo IS NULL
					AND L.ValidityTo IS NULL
					AND PLI.ValidityTo IS NULL
					AND PLS.ValidityTo IS NULL
					AND TempHF.IsValid = 1;

				END
			/*========================================================================================================
			UPDATE HF ENDS
			========================================================================================================*/	



			/*========================================================================================================
			INSERT HF STARTS
			========================================================================================================*/	

			--INSERT HF
			IF (@StrategyId & @InsertOnly) > 0
				BEGIN
					
					INSERT INTO tblHF(HFCode, HFName,[LegalForm],[HFLevel],[HFSublevel],[HFAddress],[LocationId],[Phone],[Fax],[eMail],[HFCareType],[AccCode],[PLItemID],[PLServiceID], [OffLine],[ValidityFrom],AuditUserId)
					OUTPUT QUOTENAME(inserted.HFCode), N'I' INTO @tblResult
					SELECT TempHF.[Code] ,TempHF.[Name],TempHF.[LegalForms],TempHF.[Level],TempHF.[Sublevel],TempHF.[Address],L.LocationId,TempHF.[Phone],TempHF.[Fax],TempHF.[Email],TempHF.[CareType],TempHF.[AccountCode], PLI.PLItemID, PLS.PLServiceID,0 [OffLine],GETDATE()[ValidityFrom], @AuditUserID AuditUserId 
					FROM @tblHF TempHF 
					LEFT OUTER JOIN tblHF HF  ON TempHF.Code=HF.HFCode
					INNER JOIN tblLocations L ON L.LocationCode=TempHF.DistrictCode
					LEFT OUTER JOIN tblPLItems PLI ON PLI.PLItemName= tempHF.ItemPriceListName  AND (PLI.LocationId = L.LocationId OR PLI.LocationId = L.ParentLocationId)
					LEFT OUTER JOIN tblPLServices PLS ON PLS.PLServName=tempHF.ServicePriceListName  AND (PLS.LocationId = L.LocationId OR PLS.LocationId = L.ParentLocationId)
					WHERE HF.ValidityTo IS NULL
					AND L.ValidityTo IS NULL
					AND HF.HFCode IS NULL
					AND PLI.ValidityTo IS NULL AND PLS.ValidityTo IS NULL
					AND TempHF.IsValid = 1;
	
					SELECT @Inserts = @@ROWCOUNT;

				END
				

			/*========================================================================================================
			INSERT HF ENDS
			========================================================================================================*/	

			
			/*========================================================================================================
			UDPATE CATCHMENT  STARTS
			========================================================================================================*/	
			IF  (@StrategyId & @UpdateOnly) > 0
				BEGIN

			--CATCHMENT
					--Make a copy of the original record
					INSERT INTO [tblHFCatchment]([HFID],[LocationId],[Catchment],[ValidityFrom],ValidityTo,[LegacyId],AuditUserId)		
					SELECT HFC.HfID,HFC.LocationId, HFC.Catchment,HFC.ValidityFrom, GETDATE() ValidityTo,HFC.HFCatchmentId, HFC.AuditUserId FROM @tblCatchment C 
					INNER JOIN tblHF HF ON C.HFCode=HF.HFCode
					INNER JOIN tblLocations L ON L.LocationCode=C.VillageCode
					INNER JOIN @tblHF tempHF ON tempHF.Code=C.HFCode
					INNER JOIN tblHFCatchment HFC ON HFC.LocationId=L.LocationId AND HFC.HFID=HF.HfID
					WHERE 
					C.IsValid =1
					AND tempHF.IsValid=1
					AND L.ValidityTo IS NULL
					AND HF.ValidityTo IS NULL
					AND HFC.ValidityTo IS NULL

					SELECT @UpdateCatchment =@@ROWCOUNT
					
					INSERT INTO @tblResult(Result,ResultType)
					SELECT CONVERT(NVARCHAR(3), @UpdateCatchment) , N'UC'

					--Upadte the record
					UPDATE HFC SET HFC.HFID= HF.HfID,HFC.LocationId= L.LocationId, HFC.Catchment =C.Percentage,HFC.ValidityFrom=GETDATE(),  HFC.AuditUserId=@AuditUserID FROM @tblCatchment C 
					INNER JOIN tblHF HF ON C.HFCode=HF.HFCode
					INNER JOIN tblLocations L ON L.LocationCode=C.VillageCode
					INNER JOIN @tblHF tempHF ON tempHF.Code=C.HFCode
					INNER JOIN tblHFCatchment HFC ON HFC.LocationId=L.LocationId AND HFC.HFID=HF.HfID
					WHERE 
					C.IsValid =1
					AND tempHF.IsValid=1
					AND L.ValidityTo IS NULL
					AND HF.ValidityTo IS NULL
					AND HFC.ValidityTo IS NULL
				END
			/*========================================================================================================
			UDPATE CATCHMENT  STARTS
			========================================================================================================*/	

			/*========================================================================================================
			INSERT CATCHMENT  STARTS
			========================================================================================================*/	
				--INSERT HF
			IF (@StrategyId & @InsertOnly) > 0
				BEGIN
					
					--INSERT CATCHMENT
					INSERT INTO [tblHFCatchment]([HFID],[LocationId],[Catchment],[ValidityFrom],[AuditUserId])
					SELECT HF.HfID,L.LocationId, C.Percentage, GETDATE() ValidityFrom, @AuditUserId FROM @tblCatchment C 
					INNER JOIN tblHF HF ON C.HFCode=HF.HFCode
					INNER JOIN tblLocations L ON L.LocationCode=C.VillageCode
					INNER JOIN @tblHF tempHF ON tempHF.Code=C.HFCode
					LEFT OUTER JOIN tblHFCatchment HFC ON HFC.LocationId=L.LocationId AND HFC.HFID=HF.HfID
					WHERE 
					C.IsValid =1
					AND tempHF.IsValid=1
					AND L.ValidityTo IS NULL
					AND HF.ValidityTo IS NULL
					AND HFC.ValidityTo IS NULL
					AND HFC.LocationId IS NULL
					AND HFC.HFID IS NULL
				
					SELECT @InsertCatchment=@@ROWCOUNT

					INSERT INTO @tblResult(Result,ResultType)
					SELECT CONVERT(NVARCHAR(3), @InsertCatchment) , N'IC'
				END
			/*========================================================================================================
			INSERT CATCHMENT  STARTS
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
		ELSE IF ERROR_NUMBER()=8114 
			BEGIN
				SET @InvalidXML='Invalid input in percentage '
				INSERT INTO @tblResult(Result, ResultType)
				SELECT @InvalidXML, N'FE';
			END
		ELSE IF  ERROR_MESSAGE()=N'-200'
			BEGIN
				INSERT INTO @tblResult(Result, ResultType)
			SELECT'Invalid HF XML file', N'FE';
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
