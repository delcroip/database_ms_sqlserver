/****** Object:  StoredProcedure [dbo].[uspImportOffLineExtract1]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspImportOffLineExtract1]
	@AuditUser as int = 0 ,
	@xLocations as dbo.xLocations READONLY,
	@LocationsIns as bigint = 0 OUTPUT,  
	@LocationsUpd as bigint  = 0 OUTPUT
	
AS
BEGIN
	--SELECT * INTO REGIONS FROM @xtRegions
	--RETURN
	--**S Locations**
	
	SET NOCOUNT OFF
	UPDATE Src  SET Src.LocationCode = Etr.LocationCode ,Src.LocationName = Etr.LocationName,Src.ParentLocationId = Etr.ParentLocationId, 
	Src.LocationType = Etr.LocationType , Src.ValidityFrom = Etr.ValidityFrom , Src.ValidityTo = Etr.ValidityTo, Src.LegacyId = Etr.LegacyId,
	Src.AuditUserId = @AuditUser
	FROM tblLocations Src , @xLocations Etr
	WHERE Src.LocationId = Etr.LocationId
	
	SET @LocationsUpd = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF;
	SET IDENTITY_INSERT tblLocations ON
	--INSERT INTO [dbo].[tblRegions](RegionId,RegionName,RegionCode,[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID])   
	INSERT INTO tblLocations(LocationId, LocationCode, LocationName, ParentLocationId, LocationType, ValidityFrom, ValidityTo, Legacyid, AuditUserId)
	SELECT LocationId,LocationCode,LocationName, ParentLocationId, LocationType,[ValidityFrom],[ValidityTo],[LegacyID],@AuditUser 
	FROM @xLocations 
	WHERE LocationId NOT IN 
	(SELECT LocationId FROM tblLocations)
 

	SET @LocationsIns  = @@ROWCOUNT
	SET IDENTITY_INSERT tblLocations OFF
	SET NOCOUNT ON
	--**E Locations*
	 
END
GO
