/****** Object:  StoredProcedure [dbo].[uspExportOffLineExtract4]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspExportOffLineExtract4]
     @RegionId INT = 0,
	 @DistrictId INT = 0,
	 @RowID as bigint = 0,
	 
	--updated by Amani 22/09/2017
	@WithInsuree as bit = 0
AS
BEGIN
	SET NOCOUNT ON
	
	--**Families**
	--SELECT [FamilyID],[InsureeID],[DistrictID],[VillageID],[WardID],[Poverty],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID],[FamilyType],[FamilyAddress],Ethnicity,ConfirmationNo FROM [dbo].[tblFamilies] WHERE RowID > @RowID AND (CASE @LocationId  WHEN 0 THEN 0 ELSE [DistrictID]  END) = @LocationId
	;WITH Family AS (
	SELECT F.[FamilyID],F.[InsureeID],F.[LocationId],[Poverty],F.[ValidityFrom],F.[ValidityTo],F.[LegacyID],F.[AuditUserID],[FamilyType],[FamilyAddress],Ethnicity,isOffline ,ConfirmationNo,F.ConfirmationType 
	FROM [dbo].[tblFamilies] F 
	INNER JOIN tblVillages V ON V.VillageID = F.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	WHERE F.RowID > @RowID 
	--AND ((CASE @DistrictId  WHEN 0 THEN 0 ELSE D.[DistrictID]  END) = @DistrictId OR D.Region = @RegionId) Commented by Rogers
	AND (@RegionId =0 or (
	((CASE @DistrictId  WHEN 0 THEN 0 ELSE D.[DistrictID]  END) = @DistrictId) AND
	((CASE @DistrictId  WHEN 0 THEN  D.Region  ELSE @RegionId END) = @RegionId)
	))
	
	AND D.[DistrictID] =  CASE WHEN	@WithInsuree=0 THEN NULL ELSE D.[DistrictID] END --ADDED BY AMANI
	UNION ALL
	SELECT F.[FamilyID],F.[InsureeID],F.[LocationId],[Poverty],F.[ValidityFrom],F.[ValidityTo],F.[LegacyID],F.[AuditUserID],[FamilyType],[FamilyAddress],Ethnicity,F.isOffline,ConfirmationNo,F.ConfirmationType 
	FROM tblFamilies F 
	INNER JOIN tblInsuree I ON F.FamilyId = I.FamilyID
	INNER JOIN tblHF HF ON I.HFId = HF.HfID
	WHERE F.RowID > @RowID 
	AND (CASE @DistrictId  WHEN 0 THEN 0 ELSE HF.[LocationId]  END) = @DistrictId 
	AND HF.[LocationId] =  CASE WHEN	@WithInsuree=0 THEN NULL ELSE HF.[LocationId] END --ADDED BY AMANI

	)
	SELECT * FROM Family F 
	GROUP BY F.[FamilyID],F.[InsureeID],F.[LocationId],[Poverty],F.[ValidityFrom],F.[ValidityTo],F.[LegacyID],F.[AuditUserID],[FamilyType],[FamilyAddress],Ethnicity,ConfirmationNo,F.ConfirmationType,F.isOffline

END
GO
