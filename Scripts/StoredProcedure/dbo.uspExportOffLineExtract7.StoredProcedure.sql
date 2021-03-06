/****** Object:  StoredProcedure [dbo].[uspExportOffLineExtract7]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspExportOffLineExtract7]
	 @RegionId INT = 0,
	 @DistrictId INT = 0,
	 @RowID as bigint = 0,
	 
	--updated by Amani 22/09/2017
	@WithInsuree as bit = 0
AS
BEGIN
	SET NOCOUNT ON
	
	; WITH Policy AS(
	SELECT [PolicyID],[dbo].[tblPolicy].[FamilyID],[EnrollDate],[StartDate],[EffectiveDate],[ExpiryDate],[PolicyStatus],[PolicyValue],[ProdID],[OfficerID],[dbo].[tblPolicy].[PolicyStage],[dbo].[tblPolicy].[ValidityFrom],[dbo].[tblPolicy].[ValidityTo],[dbo].[tblPolicy].[LegacyID],[dbo].[tblPolicy].[AuditUserID]  ,[dbo].[tblPolicy].isOffline
	FROM [dbo].[tblPolicy]             INNER JOIN tblFamilies ON tblFamilies.FamilyID = tblPolicy.FamilyID 
	INNER JOIN tblVillages V ON V.VillageID = tblFamilies.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	WHERE tblPolicy .RowID > @RowID 
	--AND ((CASE @DistrictId  WHEN 0 THEN 0 ELSE D.[DistrictID]  END) = @DistrictId OR D.Region =@RegionId) Commented by Rogers
	AND ((CASE @DistrictId  WHEN 0 THEN 0 ELSE D.[DistrictID]  END) = @DistrictId OR @DistrictId =0)  --added by Rogers 0n 10.11.2017
	AND ((CASE @DistrictId  WHEN 0 THEN  D.Region  ELSE @RegionId END) = @RegionId OR @RegionId =0)
	AND D.[DistrictId]=CASE WHEN @WithInsuree =0 THEN NULL ELSE D.[DistrictId] END --ADDED 25/09
	UNION ALL
	SELECT [PolicyID],[dbo].[tblPolicy].[FamilyID],[EnrollDate],[StartDate],[EffectiveDate],[ExpiryDate],[PolicyStatus],[PolicyValue],[ProdID],[OfficerID],[dbo].[tblPolicy].[PolicyStage],[dbo].[tblPolicy].[ValidityFrom],[dbo].[tblPolicy].[ValidityTo],[dbo].[tblPolicy].[LegacyID],[dbo].[tblPolicy].[AuditUserID] ,[dbo].[tblPolicy].isOffline 
	FROM [dbo].[tblPolicy] INNER JOIN tblFamilies ON tblFamilies.FamilyID = tblPolicy.FamilyID 
	INNER JOIN tblInsuree ON tblFamilies.FamilyId = tblInsuree.FamilyID
	INNER JOIN tblHF HF ON tblInsuree.HFId = HF.HfID
	WHERE tblPolicy .RowID > @RowID 
	AND (CASE @DistrictId  WHEN 0 THEN 0 ELSE HF.[LocationId]  END) = @DistrictId 
	AND HF.LocationId =CASE WHEN @WithInsuree=0 THEN NULL ELSE HF.LocationId END --ADDED 25/09
	)
	SELECT * FROM Policy P 
	GROUP BY p.[PolicyID],P.[FamilyID],[EnrollDate],[StartDate],[EffectiveDate],[ExpiryDate],[PolicyStatus],[PolicyValue],[ProdID],[OfficerID],P.[PolicyStage],P.[ValidityFrom],P.[ValidityTo],P.[LegacyID],P.[AuditUserID],P.isOffline
END
GO
