/****** Object:  StoredProcedure [dbo].[uspUploadLocationsXML]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspUploadLocationsXML]
(
		--@File NVARCHAR(500),
		@XML XML,
		@StrategyId INT,	--1	: Insert Only,	2: Update Only	3: Insert & Update	7: Insert, Update & Delete
		@DryRun BIT,
		@AuditUserId INT,
		@SentRegion INT =0 OUTPUT,  
		@SentDistrict INT =0  OUTPUT, 
		@SentWard INT =0  OUTPUT, 
		@SentVillage INT =0  OUTPUT, 
		@InsertRegion INT =0  OUTPUT, 
		@InsertDistrict INT =0  OUTPUT, 
		@InsertWard INT =0  OUTPUT, 
		@InsertVillage INT =0 OUTPUT, 
		@UpdateRegion INT =0  OUTPUT, 
		@UpdateDistrict INT =0  OUTPUT, 
		@UpdateWard INT =0  OUTPUT, 
		@UpdateVillage INT =0  OUTPUT
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

		SET @SentRegion = 0
		SET @SentDistrict = 0
		SET @SentWard = 0
		SET @SentVillage = 0
		SET @InsertRegion = 0
		SET @InsertDistrict = 0
		SET @InsertWard = 0
		SET @InsertVillage = 0
		SET @UpdateRegion = 0
		SET @UpdateDistrict = 0
		SET @UpdateWard = 0
		SET @UpdateVillage = 0

		DECLARE @Query NVARCHAR(500)
		--DECLARE @XML XML
		DECLARE @tblResult TABLE(Result NVARCHAR(Max), ResultType NVARCHAR(2))
		DECLARE @tempRegion TABLE(RegionCode NVARCHAR(100), RegionName NVARCHAR(100), IsValid BIT )
		DECLARE @tempLocation TABLE(LocationCode NVARCHAR(100))
		DECLARE @tempDistricts TABLE(RegionCode NVARCHAR(100),DistrictCode NVARCHAR(100),DistrictName NVARCHAR(100), IsValid BIT )
		DECLARE @tempWards TABLE(DistrictCode NVARCHAR(100),WardCode NVARCHAR(100),WardName NVARCHAR(100), IsValid BIT )
		DECLARE @tempVillages TABLE(WardCode NVARCHAR(100),VillageCode NVARCHAR(100), VillageName NVARCHAR(100),MalePopulation INT,FemalePopulation INT, OtherPopulation INT, Families INT, IsValid BIT )

		BEGIN TRY
	
			--SET @Query = (N'SELECT @XML = CAST(X as XML) FROM OPENROWSET(BULK  '''+ @File +''' ,SINGLE_BLOB) AS T(X)')

			--EXECUTE SP_EXECUTESQL @Query,N'@XML XML OUTPUT',@XML OUTPUT
			
			
			IF ( @XML.exist('(Locations/Regions/Region)')=1 AND  @XML.exist('(Locations/Districts/District)')=1 AND  @XML.exist('(Locations/Municipalities/Municipality)')=1 AND  @XML.exist('(Locations/Villages/Village)')=1)
				BEGIN
					--GET ALL THE REGIONS FROM THE XML
					INSERT INTO @tempRegion(RegionCode,RegionName,IsValid)
					SELECT 
					NULLIF(T.R.value('(RegionCode)[1]','NVARCHAR(100)'),''),
					NULLIF(T.R.value('(RegionName)[1]','NVARCHAR(100)'),''),
					1
					FROM @XML.nodes('Locations/Regions/Region') AS T(R)
		
					SELECT @SentRegion=@@ROWCOUNT

					--GET ALL THE DISTRICTS FROM THE XML
					INSERT INTO @tempDistricts(RegionCode, DistrictCode, DistrictName,IsValid)
					SELECT 
					NULLIF(T.R.value('(RegionCode)[1]','NVARCHAR(100)'),''),
					NULLIF(T.R.value('(DistrictCode)[1]','NVARCHAR(100)'),''),
					NULLIF(T.R.value('(DistrictName)[1]','NVARCHAR(100)'),''),
					1
					FROM @XML.nodes('Locations/Districts/District') AS T(R)

					SELECT @SentDistrict=@@ROWCOUNT

					--GET ALL THE WARDS FROM THE XML
					INSERT INTO @tempWards(DistrictCode,WardCode, WardName,IsValid)
					SELECT 
					NULLIF(T.R.value('(DistrictCode)[1]','NVARCHAR(100)'),''),
					NULLIF(T.R.value('(MunicipalityCode)[1]','NVARCHAR(100)'),''),
					NULLIF(T.R.value('(MunicipalityName)[1]','NVARCHAR(100)'),''),
					1
					FROM @XML.nodes('Locations/Municipalities/Municipality') AS T(R)
		
					SELECT @SentWard = @@ROWCOUNT

					--GET ALL THE VILLAGES FROM THE XML
					INSERT INTO @tempVillages(WardCode, VillageCode, VillageName, MalePopulation, FemalePopulation, OtherPopulation, Families, IsValid)
					SELECT 
					NULLIF(T.R.value('(MunicipalityCode)[1]','NVARCHAR(100)'),''),
					NULLIF(T.R.value('(VillageCode)[1]','NVARCHAR(100)'),''),
					NULLIF(T.R.value('(VillageName)[1]','NVARCHAR(100)'),''),
					NULLIF(T.R.value('(MalePopulation)[1]','INT'),0),
					NULLIF(T.R.value('(FemalePopulation)[1]','INT'),0),
					NULLIF(T.R.value('(OtherPopulation)[1]','INT'),0),
					NULLIF(T.R.value('(Families)[1]','INT'),0),
					1
					FROM @XML.nodes('Locations/Villages/Village') AS T(R)
		
					SELECT @SentVillage=@@ROWCOUNT
				END
			ELSE
				BEGIN
					RAISERROR (N'-200', 16, 1);
				END


			--SELECT * INTO tempRegion from @tempRegion
			--SELECT * INTO tempDistricts from @tempDistricts
			--SELECT * INTO tempWards from @tempWards
			--SELECT * INTO tempVillages from @tempVillages

			--RETURN

			/*========================================================================================================
			VALIDATION STARTS
			========================================================================================================*/	
			/********************************CHECK THE DUPLICATE LOCATION CODE******************************/
				INSERT INTO @tempLocation(LocationCode)
				SELECT RegionCode FROM @tempRegion
				INSERT INTO @tempLocation(LocationCode)
				SELECT DistrictCode FROM @tempDistricts
				INSERT INTO @tempLocation(LocationCode)
				SELECT WardCode FROM @tempWards
				INSERT INTO @tempLocation(LocationCode)
				SELECT VillageCode FROM @tempVillages
			
				INSERT INTO @tblResult(Result, ResultType)
				SELECT N'Location Code ' + QUOTENAME(LocationCode) + '  has already being used in a file ', N'C' FROM @tempLocation GROUP BY LocationCode HAVING COUNT(LocationCode)>1

				UPDATE @tempRegion  SET IsValid=0 WHERE RegionCode IN (SELECT LocationCode FROM @tempLocation GROUP BY LocationCode HAVING COUNT(LocationCode)>1)
				UPDATE @tempDistricts  SET IsValid=0 WHERE DistrictCode IN (SELECT LocationCode FROM @tempLocation GROUP BY LocationCode HAVING COUNT(LocationCode)>1)
				UPDATE @tempWards  SET IsValid=0 WHERE WardCode IN (SELECT LocationCode FROM @tempLocation GROUP BY LocationCode HAVING COUNT(LocationCode)>1)
				UPDATE @tempVillages  SET IsValid=0 WHERE VillageCode IN (SELECT LocationCode FROM @tempLocation GROUP BY LocationCode HAVING COUNT(LocationCode)>1)


			/********************************REGION STARTS******************************/
			--check if the regioncode is null 
			IF EXISTS(
			SELECT 1 FROM @tempRegion WHERE  LEN(ISNULL(RegionCode,''))=0 
			)
			INSERT INTO @tblResult(Result, ResultType)
			SELECT  CONVERT(NVARCHAR(3), COUNT(1)) + N' Region(s) have empty code', N'E' FROM @tempRegion WHERE  LEN(ISNULL(RegionCode,''))=0 
		
			UPDATE @tempRegion SET IsValid=0  WHERE  LEN(ISNULL(RegionCode,''))=0 
		
			--check if the regionname is null 
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Region Code ' + QUOTENAME(RegionCode) + N' has empty name', N'E' FROM @tempRegion WHERE  LEN(ISNULL(RegionName,''))=0 
		
			UPDATE @tempRegion SET IsValid=0  WHERE RegionName  IS NULL OR LEN(ISNULL(RegionName,''))=0 

			--Check for Duplicates in file
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Region Code ' + QUOTENAME(RegionCode) + ' found  ' + CONVERT(NVARCHAR(3), COUNT(RegionCode)) + ' times in the file', N'C'  FROM @tempRegion GROUP BY RegionCode HAVING COUNT(RegionCode) >1 
		
			UPDATE R SET IsValid = 0 FROM @tempRegion R
			WHERE RegionCode in (SELECT RegionCode from @tempRegion GROUP BY RegionCode HAVING COUNT(RegionCode) >1)
		
			--check the length of the regionCode
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'length of the Region Code ' + QUOTENAME(RegionCode) + N' is greater than 50', N'E' FROM @tempRegion WHERE  LEN(ISNULL(RegionCode,''))>50
		
			UPDATE @tempRegion SET IsValid=0  WHERE LEN(ISNULL(RegionCode,''))>50

			--check the length of the regionname
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'length of the Region Name ' + QUOTENAME(RegionCode) + N' is greater than 50', N'E' FROM @tempRegion WHERE  LEN(ISNULL(RegionName,''))>50
		
			UPDATE @tempRegion SET IsValid=0  WHERE LEN(ISNULL(RegionName,''))>50
		
		

			/********************************REGION ENDS******************************/

			/********************************DISTRICT STARTS******************************/
			--check if the district has regioncode
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'District Code ' + QUOTENAME(DistrictCode) + N' has empty Region Code', N'E' FROM @tempDistricts WHERE  LEN(ISNULL(RegionCode,''))=0 
		
			UPDATE @tempDistricts SET IsValid=0  WHERE  LEN(ISNULL(RegionCode,''))=0 

			--check if the district has valid regioncode
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'District Code ' + QUOTENAME(DistrictCode) + N' has invalid Region Code', N'E' FROM @tempDistricts TD
			LEFT OUTER JOIN @tempRegion TR ON TR.RegionCode=TD.RegionCode
			LEFT OUTER JOIN tblLocations L ON L.LocationCode=TD.RegionCode AND L.LocationType='R' 
			WHERE L.ValidityTo IS NULL
			AND L.LocationCode IS NULL
			AND TR.RegionCode IS NULL
			AND LEN(TD.RegionCode)>0

			UPDATE TD SET TD.IsValid=0 FROM @tempDistricts TD
			LEFT OUTER JOIN @tempRegion TR ON TR.RegionCode=TD.RegionCode
			LEFT OUTER JOIN tblLocations L ON L.LocationCode=TD.RegionCode AND L.LocationType='R' 
			WHERE L.ValidityTo IS NULL
			AND L.LocationCode IS NULL
			AND TR.RegionCode IS NULL
			AND LEN(TD.RegionCode)>0

			--check if the districtcode is null 
			IF EXISTS(
			SELECT  1 FROM @tempDistricts WHERE  LEN(ISNULL(DistrictCode,''))=0 
			)
			INSERT INTO @tblResult(Result, ResultType)
			SELECT  CONVERT(NVARCHAR(3), COUNT(1)) + N' District(s) have empty District code', N'E' FROM @tempDistricts WHERE  LEN(ISNULL(DistrictCode,''))=0 
		
			UPDATE @tempDistricts SET IsValid=0  WHERE  LEN(ISNULL(DistrictCode,''))=0 
		
			--check if the districtname is null 
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'District Code ' + QUOTENAME(DistrictCode) + N' has empty name', N'E' FROM @tempDistricts WHERE  LEN(ISNULL(DistrictName,''))=0 
		
			UPDATE @tempDistricts SET IsValid=0  WHERE  LEN(ISNULL(DistrictName,''))=0 
		
			--Check for Duplicates in file
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'District Code ' + QUOTENAME(DistrictCode) + ' found  ' + CONVERT(NVARCHAR(3), COUNT(DistrictCode)) + ' times in the file', N'C'  FROM @tempDistricts GROUP BY DistrictCode HAVING COUNT(DistrictCode) >1 
		
			UPDATE D SET IsValid = 0 FROM @tempDistricts D
			WHERE DistrictCode in (SELECT DistrictCode from @tempDistricts GROUP BY DistrictCode HAVING COUNT(DistrictCode) >1)

			--check the length of the DistrictCode
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'length of the District Code ' + QUOTENAME(DistrictCode) + N' is greater than 50', N'E' FROM @tempDistricts WHERE  LEN(ISNULL(DistrictCode,''))>50
		
			UPDATE @tempDistricts SET IsValid=0  WHERE LEN(ISNULL(DistrictCode,''))>50

			--check the length of the regionname
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'length of the District Name ' + QUOTENAME(DistrictName) + N' is greater than 50', N'E' FROM @tempDistricts WHERE  LEN(ISNULL(DistrictName,''))>50
		
			UPDATE @tempDistricts SET IsValid=0  WHERE LEN(ISNULL(DistrictName,''))>50

			--Validate Parent Location
			IF (@StrategyId & @UpdateOnly) > 0
				BEGIN
					INSERT INTO @tblResult(Result, ResultType)
					SELECT N'Region Code ' + QUOTENAME(TD.RegionCode) + ' for the District Code ' + QUOTENAME(TD.DistrictCode) + ' does not match with the database', N'FD'
					FROM @tempDistricts TD
					INNER JOIN tblDistricts D ON TD.DistrictCode = D.DistrictCode
					LEFT OUTER JOIN tblRegions R ON TD.RegionCode = R.RegionCode
					WHERE D.ValidityTo IS NULL
					AND R.ValidityTo IS NULL
					AND D.Region != R.RegionId;

					UPDATE TD SET IsValid = 0
					FROM @tempDistricts TD
					INNER JOIN tblDistricts D ON TD.DistrictCode = D.DistrictCode
					LEFT OUTER JOIN tblRegions R ON TD.RegionCode = R.RegionCode
					WHERE D.ValidityTo IS NULL
					AND R.ValidityTo IS NULL
					AND D.Region != R.RegionId;

				END
		
			/********************************DISTRICT ENDS******************************/

			/********************************WARDS STARTS******************************/
			--check if the ward has districtcode
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Municipality Code ' + QUOTENAME(WardCode) + N' has empty District Code', N'E' FROM @tempWards WHERE  LEN(ISNULL(DistrictCode,''))=0 
		
			UPDATE @tempWards SET IsValid=0  WHERE  LEN(ISNULL(DistrictCode,''))=0 

			--check if the ward has valid districtCode
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Municipality Code ' + QUOTENAME(WardCode) + N' has invalid District Code', N'E' 
			FROM @tempWards TW
			LEFT OUTER JOIN @tempDistricts TD ON  TD.DistrictCode=TW.DistrictCode
			LEFT OUTER JOIN tblLocations L ON L.LocationCode=TW.DistrictCode AND L.LocationType='D' 
			WHERE L.ValidityTo IS NULL
			AND L.LocationCode IS NULL
			AND TD.DistrictCode IS NULL
			AND LEN(TW.DistrictCode)>0

			UPDATE TW SET TW.IsValid=0 FROM @tempWards TW
			LEFT OUTER JOIN @tempDistricts TD ON  TD.DistrictCode=TW.DistrictCode
			LEFT OUTER JOIN tblLocations L ON L.LocationCode=TW.DistrictCode AND L.LocationType='D' 
			WHERE L.ValidityTo IS NULL
			AND L.LocationCode IS NULL
			AND TD.DistrictCode IS NULL
			AND LEN(TW.DistrictCode)>0

			--check if the wardcode is null 
			IF EXISTS(
			SELECT  1 FROM @tempWards WHERE  LEN(ISNULL(WardCode,''))=0 
			)
			INSERT INTO @tblResult(Result, ResultType)
			SELECT  CONVERT(NVARCHAR(3), COUNT(1)) + N' Ward(s) have empty Municipality Code', N'E' FROM @tempWards WHERE  LEN(ISNULL(WardCode,''))=0 
		
			UPDATE @tempWards SET IsValid=0  WHERE  LEN(ISNULL(WardCode,''))=0 
		
			--check if the wardname is null 
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Municipality Code ' + QUOTENAME(WardCode) + N' has empty name', N'E' FROM @tempWards WHERE  LEN(ISNULL(WardName,''))=0 
		
			UPDATE @tempWards SET IsValid=0  WHERE  LEN(ISNULL(WardName,''))=0 
		
			--Check for Duplicates in file
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Municipality Code ' + QUOTENAME(WardCode) + ' found  ' + CONVERT(NVARCHAR(3), COUNT(WardCode)) + ' times in the file', N'C'  FROM @tempWards GROUP BY WardCode HAVING COUNT(WardCode) >1 
		
			UPDATE W SET IsValid = 0 FROM @tempWards W
			WHERE WardCode in (SELECT WardCode from @tempWards GROUP BY WardCode HAVING COUNT(WardCode) >1)

			--check the length of the wardcode
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'length of the Municipality Code ' + QUOTENAME(WardCode) + N' is greater than 50', N'E' FROM @tempWards WHERE  LEN(ISNULL(WardCode,''))>50
		
			UPDATE @tempWards SET IsValid=0  WHERE LEN(ISNULL(WardCode,''))>50

			--check the length of the wardname
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'length of the Municipality Name ' + QUOTENAME(WardName) + N' is greater than 50', N'E' FROM @tempWards WHERE  LEN(ISNULL(WardName,''))>50
		
			UPDATE @tempWards SET IsValid=0  WHERE LEN(ISNULL(WardName,''))>50;

			--Validate the parent location
			IF (@StrategyId & @UpdateOnly) > 0
				BEGIN
					INSERT INTO @tblResult(Result, ResultType)
					SELECT N'District Code ' + QUOTENAME(TW.DistrictCode) + ' for the Municipality Code ' + QUOTENAME(TW.WardCode) + ' does not match with the database', N'FM'
					FROM @tempWards TW
					INNER JOIN tblWards W ON TW.WardCode = W.WardCode
					LEFT OUTER JOIN tblDistricts D ON TW.DistrictCode = D.DistrictCode
					WHERE W.ValidityTo IS NULL
					AND D.ValidityTo IS NULL
					AND W.DistrictId != D.DistrictId;

					UPDATE TW SET IsValid = 0
					FROM @tempWards TW
					INNER JOIN tblWards W ON TW.WardCode = W.WardCode
					LEFT OUTER JOIN tblDistricts D ON TW.DistrictCode = D.DistrictCode
					WHERE W.ValidityTo IS NULL
					AND D.ValidityTo IS NULL
					AND W.DistrictId != D.DistrictId;

				END

		
			/********************************WARDS ENDS******************************/

			/********************************VILLAGE STARTS******************************/
			--check if the village has Wardcoce
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Village Code ' + QUOTENAME(VillageCode) + N' has empty Municipality Code', N'E' FROM @tempVillages WHERE  LEN(ISNULL(WardCode,''))=0 
		
			UPDATE @tempVillages SET IsValid=0  WHERE  LEN(ISNULL(WardCode,''))=0 

			--check if the village has valid wardcode

			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Village Code ' + QUOTENAME(VillageCode) + N' has invalid Municipality Code', N'E' 
			FROM @tempVillages TV
			LEFT OUTER JOIN @tempWards TW ON TV.WardCode = TW.WardCode
			LEFT OUTER JOIN tblWards W ON TV.WardCode = W.WardCode
			WHERE W.ValidityTo IS NULL
			AND TW.WardCode IS NULL 
			AND W.WardCode IS NULL
			AND LEN(TV.WardCode)>0
			AND LEN(TV.VillageCode) >0;

			UPDATE TV SET TV.IsValid=0 
			FROM @tempVillages TV
			LEFT OUTER JOIN @tempWards TW ON TV.WardCode = TW.WardCode
			LEFT OUTER JOIN tblWards W ON TV.WardCode = W.WardCode
			WHERE W.ValidityTo IS NULL
			AND TW.WardCode IS NULL 
			AND W.WardCode IS NULL
			AND LEN(TV.WardCode)>0
			AND LEN(TV.VillageCode) >0;

			--check if the villagecode is null 
			IF EXISTS(
			SELECT  1 FROM @tempVillages WHERE  LEN(ISNULL(VillageCode,''))=0 
			)
			INSERT INTO @tblResult(Result, ResultType)
			SELECT  CONVERT(NVARCHAR(3), COUNT(1)) + N' Village(s) have empty Village code', N'E' FROM @tempVillages WHERE  LEN(ISNULL(VillageCode,''))=0 
		
			UPDATE @tempVillages SET IsValid=0  WHERE  LEN(ISNULL(VillageCode,''))=0 
		
			--check if the villageName is null 
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Village Code ' + QUOTENAME(VillageCode) + N' has empty name', N'E' FROM @tempVillages WHERE  LEN(ISNULL(VillageName,''))=0 
		
			UPDATE @tempVillages SET IsValid=0  WHERE  LEN(ISNULL(VillageName,''))=0 
		
			--Check for Duplicates in file
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'Village Code ' + QUOTENAME(VillageCode) + ' found  ' + CONVERT(NVARCHAR(3), COUNT(VillageCode)) + ' times in the file', N'C'  FROM @tempVillages GROUP BY VillageCode HAVING COUNT(VillageCode) >1 
		
			UPDATE V SET IsValid = 0 FROM @tempVillages V
			WHERE VillageCode in (SELECT VillageCode from @tempVillages GROUP BY VillageCode HAVING COUNT(VillageCode) >1)

			--check the length of the VillageCode
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'length of the Village Code ' + QUOTENAME(VillageCode) + N' is greater than 50', N'E' FROM @tempVillages WHERE  LEN(ISNULL(VillageCode,''))>50
		
			UPDATE @tempVillages SET IsValid=0  WHERE LEN(ISNULL(VillageCode,''))>50

			--check the length of the VillageName
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'length of the Village Name ' + QUOTENAME(VillageName) + N' is greater than 50', N'E' FROM @tempVillages WHERE  LEN(ISNULL(VillageName,''))>50
		
			UPDATE @tempVillages SET IsValid=0  WHERE LEN(ISNULL(VillageName,''))>50

			--check the validity of the malepopulation
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'The Village Code' + QUOTENAME(VillageCode) + N' has invalid Male polulation', N'E' FROM @tempVillages WHERE  MalePopulation<0
		
			UPDATE @tempVillages SET IsValid=0  WHERE MalePopulation<0

			--check the validity of the female population
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'The Village Code' + QUOTENAME(VillageCode) + N' has invalid Female polulation', N'E' FROM @tempVillages WHERE  FemalePopulation<0
		
			UPDATE @tempVillages SET IsValid=0  WHERE FemalePopulation<0

			--check the validity of the OtherPopulation
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'The Village Code' + QUOTENAME(VillageCode) + N' has invalid Others polulation', N'E' FROM @tempVillages WHERE  OtherPopulation<0
		
			UPDATE @tempVillages SET IsValid=0  WHERE OtherPopulation<0

			--check the validity of the number of families
			INSERT INTO @tblResult(Result, ResultType)
			SELECT N'The Village Code' + QUOTENAME(VillageCode) + N' has invalid Number of  Families', N'E' FROM @tempVillages WHERE  Families<0
		
			UPDATE @tempVillages SET IsValid=0  WHERE Families < 0;

			--Validate the parent location
			IF (@StrategyId & @UpdateOnly) > 0
				BEGIN
					INSERT INTO @tblResult(Result, ResultType)
					SELECT N'Municipality Code ' + QUOTENAME(TV.WardCode) + ' for the Village Code ' + QUOTENAME(TV.VillageCode) + ' does not match with the database', N'FV'
					FROM @tempVillages TV
					INNER JOIN tblVillages V ON TV.VillageCode = V.VillageCode
					LEFT OUTER JOIN tblWards W ON TV.WardCode = W.WardCode
					WHERE V.ValidityTo IS NULL
					AND W.ValidityTo IS NULL
					AND V.WardId != W.WardId;

					UPDATE TV SET IsValid = 0
					FROM @tempVillages TV
					INNER JOIN tblVillages V ON TV.VillageCode = V.VillageCode
					LEFT OUTER JOIN tblWards W ON TV.WardCode = W.WardCode
					WHERE V.ValidityTo IS NULL
					AND W.ValidityTo IS NULL
					AND V.WardId != W.WardId;

				END

		
			/********************************VILLAGE ENDS******************************/
			/*========================================================================================================
			VALIDATION ENDS
			========================================================================================================*/	
	
			/*========================================================================================================
			COUNTS START
			========================================================================================================*/	
					--updates counts	
					IF (@StrategyId & @UpdateOnly) > 0
					BEGIN
							--Failed Locations
							IF (@StrategyId = @UpdateOnly)
							BEGIN
								--Failed Regions
								INSERT INTO @tblResult(Result, ResultType)
								SELECT 'Region Code ' + QUOTENAME(TR.RegionCode) + ' does not exists in database', N'FR'
								FROM @tempRegion TR
								LEFT OUTER JOIN tblRegions R ON TR.RegionCode = R.RegionCode
								WHERE R.ValidityTo IS NULL 
								--AND TR.IsValid=1
								AND R.RegionCode IS NULL;

								--Failed District
								INSERT INTO @tblResult(Result, ResultType)
								SELECT 'District Code ' + QUOTENAME(TD.DistrictCode) + ' does not exists in database', N'FD'
								FROM @tempDistricts TD
								LEFT OUTER JOIN tblDistricts D ON TD.DistrictCode = D.DistrictCode
								WHERE D.ValidityTo IS NULL 
								--AND TD.IsValid=1
								AND D.DistrictCode IS NULL;

								--Failed Municipality
								INSERT INTO @tblResult(Result, ResultType)
								SELECT 'Municipality Code ' + QUOTENAME(TM.WardCode) + ' does not exists in database', N'FM'
								FROM @tempWards TM
								LEFT OUTER JOIN tblWards W ON TM.WardCode= W.WardCode
								WHERE W.ValidityTo IS NULL 
								--AND TM.IsValid=1
								AND W.WardCode IS NULL;

								--Failed Villages
								INSERT INTO @tblResult(Result, ResultType)
								SELECT 'Village Code ' + QUOTENAME(TV.VillageCode) + ' does not exists in database', N'FV'
								FROM @tempVillages TV
								LEFT OUTER JOIN tblVillages V ON TV.VillageCode=V.VillageCode
								WHERE V.ValidityTo IS NULL 
								--AND TV.IsValid=1
								AND V.VillageCode IS NULL;


							END
						--Regions updates
							SELECT @UpdateRegion=COUNT(1) FROM @tempRegion TR 
							INNER JOIN tblLocations L ON L.LocationCode=TR.RegionCode AND L.LocationType='R'
							WHERE
							TR.IsValid=1
							AND L.ValidityTo IS NULL
							
						--Districts updates
							SELECT @UpdateDistrict=COUNT(1) FROM @tempDistricts TD 
							INNER JOIN tblLocations L ON L.LocationCode=TD.DistrictCode AND L.LocationType='D'
							WHERE
							TD.IsValid=1
							AND L.ValidityTo IS NULL

						--Wards updates
							SELECT @UpdateWard=COUNT(1) FROM @tempWards TW 
							INNER JOIN tblLocations L ON L.LocationCode=TW.WardCode AND L.LocationType='W'
							WHERE
							TW.IsValid=1
							AND L.ValidityTo IS NULL

						--Villages updates
							SELECT @UpdateVillage=COUNT(1) FROM @tempVillages TV 
							INNER JOIN tblLocations L ON L.LocationCode=TV.VillageCode AND L.LocationType='V'
							WHERE
							TV.IsValid=1
							AND L.ValidityTo IS NULL
					END

					--To be inserted
					IF (@StrategyId & @InsertOnly) > 0
						BEGIN
							
							--Failed Region
							IF (@StrategyId = @InsertOnly)
							BEGIN
								INSERT INTO @tblResult(Result, ResultType)
								SELECT 'Region Code' + QUOTENAME(TR.RegionCode) + ' is already exists in database', N'FR'
								FROM @tempRegion TR
								INNER JOIN tblLocations L ON TR.RegionCode = L.LocationCode
								WHERE L.ValidityTo IS NULL 
								--AND TR.IsValid=1;
							END
							--Regions insert
							SELECT @InsertRegion=COUNT(1) FROM @tempRegion TR 
							LEFT OUTER JOIN tblLocations L ON L.LocationCode=TR.RegionCode AND L.LocationType='R'
							WHERE
							TR.IsValid=1 AND
							L.ValidityTo IS NULL
							AND L.LocationCode IS NULL

							--Failed Districts
							IF (@StrategyId = @InsertOnly)
							BEGIN
								INSERT INTO @tblResult(Result, ResultType)
								SELECT 'District Code' + QUOTENAME(TD.DistrictCode) + ' is already exists in database', N'FD'
								FROM @tempDistricts TD
								INNER JOIN tblLocations L ON TD.DistrictCode = L.LocationCode
								WHERE L.ValidityTo IS NULL 
								--AND TD.IsValid=1;
							END
							--Districts insert
							SELECT @InsertDistrict=COUNT(1) FROM @tempDistricts TD 
							LEFT OUTER JOIN tblLocations L ON L.LocationCode=TD.DistrictCode AND L.LocationType='D'
							LEFT  OUTER JOIN tblRegions R ON TD.RegionCode = R.RegionCode AND R.ValidityTo IS NULL
							LEFT OUTER JOIN @tempRegion TR ON TD.RegionCode = TR.RegionCode
							WHERE
							TD.IsValid=1
							AND TR.IsValid = 1
							AND L.ValidityTo IS NULL
							AND L.LocationCode IS NULL
							
							--Failed Municipalities
							IF (@StrategyId = @InsertOnly)
							BEGIN
								INSERT INTO @tblResult(Result, ResultType)
								SELECT 'Municipality Code' + QUOTENAME(TW.WardCode) + ' is already exists in database', N'FM'
								FROM @tempWards TW
								INNER JOIN tblLocations L ON TW.WardCode = L.LocationCode
								WHERE L.ValidityTo IS NULL 
								--AND TW.IsValid=1;
							END
							--Wards insert
							SELECT @InsertWard=COUNT(1) FROM @tempWards TW 
							LEFT OUTER JOIN tblLocations L ON L.LocationCode=TW.WardCode AND L.LocationType='W'
							LEFT  OUTER JOIN tblDistricts D ON TW.DistrictCode = D.DistrictCode AND D.ValidityTo IS NULL
							LEFT OUTER JOIN @tempDistricts TD ON TD.DistrictCode = TW.DistrictCode
							WHERE
							TW.IsValid=1
							AND TD.IsValid = 1
							AND L.ValidityTo IS NULL
							AND L.LocationCode IS NULL

							--Failed Village
							IF (@StrategyId = @InsertOnly)
							BEGIN
								INSERT INTO @tblResult(Result, ResultType)
								SELECT 'Village Code' + QUOTENAME(TV.VillageCode) + ' is already exists in database', N'FV'
								FROM @tempVillages TV
								INNER JOIN tblLocations L ON TV.VillageCode= L.LocationCode
								WHERE L.ValidityTo IS NULL 
								--AND TV.IsValid=1;
							END
							--Villages insert
							SELECT @InsertVillage=COUNT(1) FROM @tempVillages TV 
							LEFT OUTER JOIN tblLocations L ON L.LocationCode=TV.VillageCode AND L.LocationType='V'
							LEFT  OUTER JOIN tblWards W ON TV.WardCode = W.WardCode AND W.ValidityTo IS NULL
							LEFT OUTER JOIN @tempWards TW ON TV.WardCode = TW.WardCode
							WHERE
							TV.IsValid=1
							AND TW.IsValid = 1
							AND L.ValidityTo IS NULL
							AND L.LocationCode IS NULL
						END
			


			/*========================================================================================================
			COUNTS ENDS
			========================================================================================================*/	
		
			
				IF @DryRun =0
					BEGIN
						BEGIN TRAN UPLOAD

						
			/*========================================================================================================
			UPDATE STARTS
			========================================================================================================*/	
					IF (@StrategyId & @UpdateOnly) > 0
							BEGIN
							/********************************REGIONS******************************/
								--insert historocal record(s)
									INSERT INTO [tblLocations]
										([LocationCode],[LocationName],[ParentLocationId],[LocationType],[ValidityFrom],[ValidityTo] ,[LegacyId],[AuditUserId],[MalePopulation] ,[FemalePopulation],[OtherPopulation],[Families])
									SELECT L.LocationCode, L.LocationName,L.ParentLocationId,L.LocationType, L.ValidityFrom,GETDATE(),L.LocationId,@AuditUserId AuditUserId, L.MalePopulation, L.FemalePopulation, L.OtherPopulation,L.Families 
									FROM @tempRegion TR 
									INNER JOIN tblLocations L ON L.LocationCode=TR.RegionCode AND L.LocationType='R'
									WHERE TR.IsValid=1 AND L.ValidityTo IS NULL

								--update
									UPDATE L SET  L.LocationName=TR.RegionName, ValidityFrom=GETDATE(),L.AuditUserId=@AuditUserId
									OUTPUT QUOTENAME(deleted.LocationCode), N'UR' INTO @tblResult
									FROM @tempRegion TR 
									INNER JOIN tblLocations L ON L.LocationCode=TR.RegionCode AND L.LocationType='R'
									WHERE TR.IsValid=1 AND L.ValidityTo IS NULL;

									SELECT @UpdateRegion = @@ROWCOUNT;

									/********************************DISTRICTS******************************/
								--Insert historical records
									INSERT INTO [tblLocations]
										([LocationCode],[LocationName],[ParentLocationId],[LocationType],[ValidityFrom],[ValidityTo] ,[LegacyId],[AuditUserId],[MalePopulation] ,[FemalePopulation],[OtherPopulation],[Families])
										SELECT L.LocationCode, L.LocationName,L.ParentLocationId,L.LocationType, L.ValidityFrom,GETDATE(),L.LocationId,@AuditUserId AuditUserId, L.MalePopulation, L.FemalePopulation, L.OtherPopulation,L.Families 
										FROM @tempDistricts TD 
										INNER JOIN tblLocations L ON L.LocationCode=TD.DistrictCode AND L.LocationType='D'
										WHERE TD.IsValid=1 AND L.ValidityTo IS NULL

									--update
										UPDATE L SET L.LocationName=TD.DistrictName, ValidityFrom=GETDATE(),L.AuditUserId=@AuditUserId
										OUTPUT QUOTENAME(deleted.LocationCode), N'UD' INTO @tblResult
										FROM @tempDistricts TD 
										INNER JOIN tblLocations L ON L.LocationCode=TD.DistrictCode AND L.LocationType='D'
										WHERE TD.IsValid=1 AND L.ValidityTo IS NULL;

										SELECT @UpdateDistrict = @@ROWCOUNT;

										/********************************WARD******************************/
								--Insert historical records
									INSERT INTO [tblLocations]
										([LocationCode],[LocationName],[ParentLocationId],[LocationType],[ValidityFrom],[ValidityTo] ,[LegacyId],[AuditUserId],[MalePopulation] ,[FemalePopulation],[OtherPopulation],[Families])
										SELECT L.LocationCode, L.LocationName,L.ParentLocationId,L.LocationType, L.ValidityFrom,GETDATE(),L.LocationId,@AuditUserId AuditUserId, L.MalePopulation, L.FemalePopulation, L.OtherPopulation,L.Families 
										FROM @tempWards TW 
										INNER JOIN tblLocations L ON L.LocationCode=TW.WardCode AND L.LocationType='W'
										WHERE TW.IsValid=1 AND L.ValidityTo IS NULL

								--Update
									UPDATE L SET L.LocationName=TW.WardName, ValidityFrom=GETDATE(),L.AuditUserId=@AuditUserId
										OUTPUT QUOTENAME(deleted.LocationCode), N'UM' INTO @tblResult
										FROM @tempWards TW 
										INNER JOIN tblLocations L ON L.LocationCode=TW.WardCode AND L.LocationType='W'
										WHERE TW.IsValid=1 AND L.ValidityTo IS NULL;

										SELECT @UpdateWard = @@ROWCOUNT;
									  
										/********************************VILLAGES******************************/
								--Insert historical records
									INSERT INTO [tblLocations]
										([LocationCode],[LocationName],[ParentLocationId],[LocationType],[ValidityFrom],[ValidityTo] ,[LegacyId],[AuditUserId],[MalePopulation] ,[FemalePopulation],[OtherPopulation],[Families])
										SELECT L.LocationCode, L.LocationName,L.ParentLocationId,L.LocationType, L.ValidityFrom,GETDATE(),L.LocationId,@AuditUserId AuditUserId, L.MalePopulation, L.FemalePopulation, L.OtherPopulation,L.Families 
										FROM @tempVillages TV 
										INNER JOIN tblLocations L ON L.LocationCode=TV.VillageCode AND L.LocationType='V'
										WHERE TV.IsValid=1 AND L.ValidityTo IS NULL

								--Update
									UPDATE L  SET L.LocationName=TV.VillageName, L.MalePopulation=TV.MalePopulation, L.FemalePopulation=TV.FemalePopulation, L.OtherPopulation=TV.OtherPopulation, L.Families=TV.Families, ValidityFrom=GETDATE(),L.AuditUserId=@AuditUserId
										OUTPUT QUOTENAME(deleted.LocationCode), N'UV' INTO @tblResult
										FROM @tempVillages TV 
										INNER JOIN tblLocations L ON L.LocationCode=TV.VillageCode AND L.LocationType='V'
										WHERE TV.IsValid=1 AND L.ValidityTo IS NULL;

										SELECT @UpdateVillage = @@ROWCOUNT;

							END
			/*========================================================================================================
			UPDATE ENDS
			========================================================================================================*/	

			/*========================================================================================================
			INSERT STARTS
			========================================================================================================*/	
					IF (@StrategyId & @InsertOnly) > 0
							BEGIN
								--insert Region(s)
									INSERT INTO [tblLocations]
										([LocationCode],[LocationName],[LocationType],[ValidityFrom],[AuditUserId])
									OUTPUT QUOTENAME(inserted.LocationCode), N'IR' INTO @tblResult
									SELECT TR.RegionCode, TR.RegionName,'R',GETDATE(), @AuditUserId AuditUserId 
									FROM @tempRegion TR 
									LEFT OUTER JOIN tblLocations L ON L.LocationCode=TR.RegionCode AND L.LocationType='R'
									WHERE
									TR.IsValid=1
									AND L.ValidityTo IS NULL
									AND L.LocationCode IS NULL;

									SELECT @InsertRegion = @@ROWCOUNT;


								--Insert District(s)
									INSERT INTO [tblLocations]
										([LocationCode],[LocationName],[ParentLocationId],[LocationType],[ValidityFrom],[AuditUserId])
									OUTPUT QUOTENAME(inserted.LocationCode), N'ID' INTO @tblResult
									SELECT TD.DistrictCode, TD.DistrictName, R.RegionId, 'D', GETDATE(), @AuditUserId AuditUserId 
									FROM @tempDistricts TD
									INNER JOIN tblRegions R ON TD.RegionCode = R.RegionCode
									LEFT OUTER JOIN tblDistricts D ON TD.DistrictCode = D.DistrictCode
									WHERE R.ValidityTo IS NULL
									AND D.ValidityTo IS NULL 
									AND D.DistrictId IS NULL;

									SELECT @InsertDistrict = @@ROWCOUNT;
									
								--Insert Wards
								INSERT INTO [tblLocations]
									([LocationCode],[LocationName],[ParentLocationId],[LocationType],[ValidityFrom],[AuditUserId])
								OUTPUT QUOTENAME(inserted.LocationCode), N'IM' INTO @tblResult
								SELECT TW.WardCode, TW.WardName, D.DistrictId, 'W',GETDATE(), @AuditUserId AuditUserId 
								FROM @tempWards TW
								INNER JOIN tblDistricts D ON TW.DistrictCode = D.DistrictCode
								LEFT OUTER JOIN tblWards W ON TW.WardCode = W.WardCode
								WHERE D.ValidityTo IS NULL
								AND W.ValidityTo IS NULL 
								AND W.WardId IS NULL;

									SELECT @InsertWard = @@ROWCOUNT;
									

							--insert  villages
								INSERT INTO [tblLocations]
									([LocationCode],[LocationName],[ParentLocationId],[LocationType], [MalePopulation],[FemalePopulation],[OtherPopulation],[Families], [ValidityFrom],[AuditUserId])
								OUTPUT QUOTENAME(inserted.LocationCode), N'IV' INTO @tblResult
								SELECT TV.VillageCode,TV.VillageName,W.WardId,'V',TV.MalePopulation,TV.FemalePopulation,TV.OtherPopulation,TV.Families,GETDATE(), @AuditUserId AuditUserId
								FROM @tempVillages TV
								INNER JOIN tblWards W ON TV.WardCode = W.WardCode
								LEFT OUTER JOIN tblVillages V ON TV.VillageCode = V.VillageCode
								WHERE W.ValidityTo IS NULL
								AND V.ValidityTo IS NULL 
								AND V.VillageId IS NULL;

									SELECT @InsertVillage = @@ROWCOUNT;

							END
			/*========================================================================================================
			INSERT ENDS
			========================================================================================================*/	
							

						COMMIT TRAN UPLOAD
					END
		
			
		
		END TRY
		BEGIN CATCH
			DECLARE @InvalidXML NVARCHAR(100)
			IF ERROR_NUMBER()=245 
				BEGIN
					SET @InvalidXML='Invalid input in either MalePopulation, FemalePopulation, OtherPopulation or Number of Families '
					INSERT INTO @tblResult(Result, ResultType)
					SELECT @InvalidXML, N'FE';
				END
			ELSE  IF ERROR_NUMBER()=9436 
				BEGIN
					SET @InvalidXML='Invalid XML file, end tag does not match start tag'
					INSERT INTO @tblResult(Result, ResultType)
					SELECT @InvalidXML, N'FE';
				END
			ELSE IF  ERROR_MESSAGE()=N'-200'
				BEGIN
					INSERT INTO @tblResult(Result, ResultType)
				SELECT'Invalid Locations XML file', N'FE';
			END
			ELSE
				INSERT INTO @tblResult(Result, ResultType)
				SELECT'Invalid XML file', N'FE';

			IF @@TRANCOUNT > 0 ROLLBACK TRAN UPLOAD;
			SELECT * FROM @tblResult
			RETURN -1;
				
		END CATCH
		SELECT * FROM @tblResult
		RETURN 0;
	END






GO
