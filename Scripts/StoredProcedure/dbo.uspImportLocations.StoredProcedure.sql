/****** Object:  StoredProcedure [dbo].[uspImportLocations]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspImportLocations]
(

	@RegionsFile NVARCHAR(255),
	@DistrictsFile NVARCHAR(255),
	@WardsFile NVARCHAR(255),
	@VillagesFile NVARCHAR(255)
)
AS
BEGIN
BEGIN TRY
	--CREATE TEMP TABLE FOR REGION
	IF OBJECT_ID('tempdb..#tempRegion') IS NOT NULL DROP TABLE #tempRegion
	CREATE TABLE #tempRegion(RegionCode NVARCHAR(50), RegionName NVARCHAR(50))

	--CREATE TEMP TABLE FOR DISTRICTS
	IF OBJECT_ID('tempdb..#tempDistricts') IS NOT NULL DROP TABLE #tempDistricts
	CREATE TABLE #tempDistricts(RegionCode NVARCHAR(50),DistrictCode NVARCHAR(50),DistrictName NVARCHAR(50))

	--CREATE TEMP TABLE FOR WARDS
	IF OBJECT_ID('tempdb..#tempWards') IS NOT NULL DROP TABLE #tempWards
	CREATE TABLE #tempWards(DistrictCode NVARCHAR(50),WardCode NVARCHAR(50),WardName NVARCHAR(50))

	--CREATE TEMP TABLE FOR VILLAGES
	IF OBJECT_ID('tempdb..#tempVillages') IS NOT NULL DROP TABLE #tempVillages
	CREATE TABLE #tempVillages(WardCode NVARCHAR(50),VillageCode NVARCHAR(50), VillageName NVARCHAR(50),MalePopulation INT,FemalePopulation INT, OtherPopulation INT, Families INT)



	--INSERT REGION IN TEMP TABLE
	DECLARE @InsertRegion NVARCHAR(2000)
	SET @InsertRegion = N'BULK INSERT #tempRegion FROM ''' + @RegionsFile + '''' +
		'WITH (
		FIELDTERMINATOR = ''	'',
		FIRSTROW = 2
		)'
	EXEC SP_EXECUTESQL @InsertRegion


	--INSERT DISTRICTS IN TEMP TABLE
	DECLARE @InsertDistricts NVARCHAR(2000)
	SET @InsertDistricts = N'BULK INSERT #tempDistricts FROM ''' + @DistrictsFile + '''' +
		'WITH (
		FIELDTERMINATOR = ''	'',
		FIRSTROW = 2
		)'
	EXEC SP_EXECUTESQL @InsertDistricts

	--INSERT WARDS IN TEMP TABLE
	DECLARE @InsertWards NVARCHAR(2000)
	SET @InsertWards = N'BULK INSERT #tempWards FROM ''' + @WardsFile + '''' +
		'WITH (
		FIELDTERMINATOR = ''	'',
		FIRSTROW = 2
		)'
	EXEC SP_EXECUTESQL @InsertWards


	
	--INSERT VILLAGES IN TEMP TABLE
	DECLARE @InsertVillages NVARCHAR(2000)
	SET @InsertVillages = N'BULK INSERT #tempVillages FROM ''' + @VillagesFile + '''' +
		'WITH (
		FIELDTERMINATOR = ''	'',
		FIRSTROW = 2
		)'
	EXEC SP_EXECUTESQL @InsertVillages
    
	--check if the location is null or empty space
	IF EXISTS(
	SELECT 1 FROM #tempRegion WHERE RegionCode IS NULL OR RegionName IS NULL
	UNION
	SELECT 1FROM #tempDistricts WHERE (RegionCode IS NULL OR LEN(RegionCode)=0) OR (DistrictCode IS NULL OR LEN(DistrictCode)=0) OR (DistrictName IS NULL OR LEN(DistrictName)=0)
	UNION
	SELECT 1 FROM #tempWards WHERE (DistrictCode IS NULL OR LEN(DistrictCode)=0) OR (WardCode IS NULL OR LEN(WardCode)=0) OR (WardName IS NULL OR LEN(WardName)=0)
	UNION
	SELECT 1 FROM #tempVillages WHERE (WardCode IS NULL OR LEN(WardCode)=0) OR (VillageCode IS NULL OR LEN(VillageCode)=0) OR (VillageName IS NULL OR  LEN(VillageName)=0)
	)
	RAISERROR ('LocationCode Or LocationName is Missing in excel', 16, 1)



	--check if the population is numeric
	IF EXISTS(
		SELECT * FROM #tempVillages WHERE   (ISNUMERIC(MalePopulation)=0 AND LEN(MalePopulation)>0) OR  (ISNUMERIC(FemalePopulation)=0  AND LEN(FemalePopulation)>0) OR  (ISNUMERIC(OtherPopulation)=0 AND LEN(OtherPopulation)>0) OR  (ISNUMERIC(Families)=0 AND LEN(Families)>0)
	)
	RAISERROR ('Village population must be numeric in excel', 16, 1)



	DECLARE @AllCodes AS TABLE(LocationCode NVARCHAR(8))
	;WITH AllCodes AS
	(
		SELECT RegionCode LocationCode FROM #tempRegion
		UNION ALL
		SELECT DistrictCode FROM #tempDistricts
		UNION ALL
		SELECT WardCode FROM #tempWards
		UNION ALL
		SELECT VillageCode FROM #tempVillages
	)
	INSERT INTO @AllCodes(LocationCode)
	SELECT LocationCode
	FROM AllCodes

	IF EXISTS(SELECT LocationCode FROM @AllCodes GROUP BY LocationCode HAVING COUNT(1) > 1)
		BEGIN
			SELECT LocationCode FROM @AllCodes GROUP BY LocationCode HAVING COUNT(1) > 1;
			RAISERROR ('Duplicate in excel', 16, 1)
		END

	--;WITH AllLocations AS
	--(
	--	SELECT RegionCode LocationCode, RegionName LocationName FROM tblRegions
	--	UNION ALL
	--	SELECT DistrictCode, DistrictName FROM tblDistricts
	--	UNION ALL
	--	SELECT WardCode, WardName FROM tblWards
	--	UNION ALL
	--	SELECT VillageCode, VillageName FROM tblVillages
	--)
	--SELECT AC.LocationCode ExistingCodenNDB, AL.LocationName ExistingNameInDB
	--FROM @AllCodes AC
	--INNER JOIN AllLocations AL ON AC.LocationCode COLLATE DATABASE_DEFAULT = AL.LocationCode COLLATE DATABASE_DEFAULT

	--IF @@ROWCOUNT > 0
	--	RAISERROR ('One or more location codes are already existing in database', 16, 1)
	
	--DELETE EXISTING LOCATIONS
	DELETE Temp
	OUTPUT deleted.RegionCode OmmitedRegionCode, deleted.RegionName OmmitedRegionName
	FROM #tempRegion Temp
	INNER JOIN tblLocations L ON Temp.RegionCode COLLATE DATABASE_DEFAULT = L.LocationCode COLLATE DATABASE_DEFAULT
	WHERE L.ValidityTo IS NULL;

	DELETE Temp
	OUTPUT deleted.DistrictCode OmmitedDistrictCode, deleted.DistrictName OmmitedDistrictName
	FROM #tempDistricts Temp
	INNER JOIN tblLocations L ON Temp.DistrictCode COLLATE DATABASE_DEFAULT = L.LocationCode COLLATE DATABASE_DEFAULT
	WHERE L.ValidityTo IS NULL;

	DELETE Temp
	OUTPUT deleted.WardCode OmmitedWardCode, deleted.WardName OmmitedWardName
	FROM #tempWards Temp
	INNER JOIN tblLocations L ON Temp.WardCode COLLATE DATABASE_DEFAULT = L.LocationCode COLLATE DATABASE_DEFAULT
	WHERE L.ValidityTo IS NULL;

	DELETE Temp
	OUTPUT deleted.VillageCode OmmitedVillageCode, deleted.VillageName OmmitedVillageName
	FROM #tempVillages Temp
	INNER JOIN tblLocations L ON Temp.VillageCode COLLATE DATABASE_DEFAULT = L.LocationCode COLLATE DATABASE_DEFAULT
	WHERE L.ValidityTo IS NULL;


	BEGIN TRAN
	
 
	--INSERT REGION IN DATABASE
	IF EXISTS(SELECT * FROM tblRegions
			 INNER JOIN #tempRegion ON tblRegions.RegionCode COLLATE DATABASE_DEFAULT = #tempRegion.RegionCode COLLATE DATABASE_DEFAULT)
		BEGIN
			ROLLBACK TRAN

			--RETURN -4
		END
	ELSE
		INSERT INTO tblLocations(LocationCode, LocatioNname, LocationType, AuditUserId)
		SELECT TR.RegionCode, REPLACE(TR.RegionName,CHAR(12),''),'R',-1 
		FROM #tempRegion TR
		--LEFT OUTER JOIN tblRegions R ON TR.RegionCode COLLATE DATABASE_DEFAULT = R.RegionCode COLLATE DATABASE_DEFAULT AND R.ValidityTo IS NULL
		WHERE TR.RegionName IS NOT NULL
		--AND R.RegionCode IS NULL;

		
	--INSERT DISTRICTS IN DATABASE
	IF EXISTS(SELECT * FROM tblDistricts
			 INNER JOIN #tempDistricts ON tblDistricts.DistrictCode COLLATE DATABASE_DEFAULT = #tempDistricts.DistrictCode COLLATE DATABASE_DEFAULT)
		BEGIN
			ROLLBACK TRAN
			--RETURN -1
		END
	ELSE
		--INSERT INTO tblDistricts(Region,DistrictName,DistrictCode,AuditUserID)
		INSERT INTO tblLocations(LocationCode, LocationName, ParentLocationId, LocationType, AuditUserId)
		SELECT #tempDistricts.DistrictCode, REPLACE(#tempDistricts.DistrictName,CHAR(9),''),tblRegions.RegionId,'D', -1
		FROM #tempDistricts 
		INNER JOIN tblRegions ON #tempDistricts.RegionCode COLLATE DATABASE_DEFAULT = tblRegions.RegionCode COLLATE DATABASE_DEFAULT
		--LEFT OUTER JOIN tblDistricts D ON #tempDistricts.DistrictCode COLLATE DATABASE_DEFAULT = D.DistrictCode COLLATE DATABASE_DEFAULT AND D.ValidityTo IS NULL
		WHERE #tempDistricts.DistrictName is NOT NULL
		--AND D.DistrictCode IS NULL;
		 
		
	--INSERT WARDS IN DATABASE
	IF EXISTS (SELECT * 
				FROM tblWards 
				INNER JOIN tblDistricts ON tblWards.DistrictID = tblDistricts.DistrictID
				INNER JOIN #tempWards ON tblWards.WardCode COLLATE DATABASE_DEFAULT = #tempWards.WardCode COLLATE DATABASE_DEFAULT
									AND tblDistricts.DistrictCode COLLATE DATABASE_DEFAULT = #tempWards.DistrictCode COLLATE DATABASE_DEFAULT)	
		BEGIN
			ROLLBACK TRAN
			--RETURN -2
		END
	ELSE
		--INSERT INTO tblWards(DistrictID,WardName,WardCode,AuditUserID)
		INSERT INTO tblLocations(LocationCode, LocationName, ParentLocationId, LocationType, AuditUserId)
		SELECT #tempWards.WardCode, REPLACE(#tempWards.WardName,CHAR(9),''),tblDistricts.DistrictID,'W',-1
		FROM #tempWards 
		INNER JOIN tblDistricts ON #tempWards.DistrictCode COLLATE DATABASE_DEFAULT = tblDistricts.DistrictCode COLLATE DATABASE_DEFAULT
		--LEFT OUTER JOIN tblWards W ON #tempWards.WardCode COLLATE DATABASE_DEFAULT = W.WardCode COLLATE DATABASE_DEFAULT AND W.ValidityTo IS NULL
		WHERE #tempWards.WardName is NOT NULL
		


	--INSERT VILLAGES IN DATABASE
	IF EXISTS (SELECT * FROM 
				tblVillages 
				INNER JOIN tblWards ON tblVillages.WardID = tblWards.WardID
				INNER JOIN tblDistricts ON tblDistricts.DistrictID = tblWards.DistrictID
				INNER JOIN #tempVillages ON #tempVillages.VillageCode COLLATE DATABASE_DEFAULT = tblVillages.VillageCode COLLATE DATABASE_DEFAULT
										AND #tempVillages.WardCode COLLATE DATABASE_DEFAULT = tblWards.WardCode COLLATE DATABASE_DEFAULT
				)
		BEGIN
			ROLLBACK TRAN
			--RETURN -3
		END
	ELSE
		--INSERT INTO tblVillages(WardID,VillageName,VillageCode,AuditUserID)
		INSERT INTO tblLocations(LocationCode, LocationName, ParentLocationId, LocationType, MalePopulation,FemalePopulation,OtherPopulation,Families, AuditUserId)
		SELECT VillageCode,REPLACE(#tempVillages.VillageName,CHAR(9),''),tblWards.WardID,'V', MalePopulation,FemalePopulation,OtherPopulation,Families,-1
		FROM #tempVillages 
		INNER JOIN tblWards ON #tempVillages.WardCode COLLATE DATABASE_DEFAULT = tblWards.WardCode COLLATE DATABASE_DEFAULT 
		--LEFT OUTER JOIN tblVillages V ON #tempVillages.VillageCode COLLATE DATABASE_DEFAULT = V.VillageCode COLLATE DATABASE_DEFAULT AND V.ValidityTo IS  NULL
		WHERE VillageName IS NOT NULL
	
	COMMIT TRAN				
	
		--DROP ALL THE TEMP TABLES
		DROP TABLE #tempRegion
		DROP TABLE #tempDistricts
		DROP TABLE #tempWards
		DROP TABLE #tempVillages
	
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
		THROW SELECT ERROR_MESSAGE();
	END CATCH
	
END
GO
