/****** Object:  StoredProcedure [dbo].[uspExportOffLineExtract8]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspExportOffLineExtract8]
	 @RegionId INT = 0,
	 @DistrictId INT = 0,
	 @RowID as bigint = 0,
	 
	--updated by Amani 22/09/2017
	@WithInsuree as bit = 0
AS
BEGIN
	SET NOCOUNT ON
	
	
	;WITH Premium AS(
	SELECT tblPremium.PremiumId, tblPremium.PolicyID, tblPremium.PayerID, tblPremium.Amount, tblPremium.Receipt, tblPremium.PayDate, tblPremium.PayType,tblPremium.ValidityFrom, tblPremium.ValidityTo, tblPremium.LegacyID, tblPremium.AuditUserID ,tblPremium.isPhotoFee,tblPremium.ReportingId,tblPremium.isOffline
	FROM tblPremium INNER JOIN tblPolicy ON tblPremium.PolicyID = tblPolicy.PolicyID 
	INNER JOIN tblFamilies ON tblPolicy.FamilyID = tblFamilies.FamilyID 
	INNER JOIN tblVillages V ON V.VillageID = tblFamilies.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	WHERE tblPremium.RowID > @RowID 
	--AND ((CASE @DistrictId  WHEN 0 THEN 0 ELSE D.[DistrictID]  END) = @DistrictId OR D.Region =@RegionId) Commented by Rogers
	AND ((CASE @DistrictId  WHEN 0 THEN 0 ELSE D.[DistrictID]  END) = @DistrictId OR @DistrictId =0) --added by Rogers 0n 10.11.2017
	AND ((CASE @DistrictId  WHEN 0 THEN  D.Region  ELSE @RegionId END) = @RegionId OR @RegionId =0)
	AND D.[DistrictId] = CASE WHEN @WithInsuree=0 THEN NULL ELSE D.[DistrictId] END --ADDED 25/09
	UNION ALL
	SELECT tblPremium.PremiumId, tblPremium.PolicyID, tblPremium.PayerID, tblPremium.Amount, tblPremium.Receipt, tblPremium.PayDate, tblPremium.PayType,tblPremium.ValidityFrom, tblPremium.ValidityTo, tblPremium.LegacyID, tblPremium.AuditUserID ,tblPremium.isPhotoFee,tblPremium.ReportingId,tblPremium.isOffline
	FROM tblPremium INNER JOIN tblPolicy ON tblPremium.PolicyID = tblPolicy.PolicyID 
	INNER JOIN tblFamilies ON tblPolicy.FamilyID = tblFamilies.FamilyID 
	INNER JOIN tblInsuree ON tblFamilies.FamilyId = tblInsuree.FamilyID
	INNER JOIN tblHF HF ON tblInsuree.HFId = HF.HfID
	WHERE tblPremium.RowID > @RowID 
	AND (CASE @DistrictId  WHEN 0 THEN 0 ELSE HF.[LocationId]  END) = @DistrictId 
	AND HF.[LocationId] = CASE WHEN @WithInsuree =0 THEN NULL ELSE HF.[LocationId] END --ADDED 25/09
	)
	SELECT * FROM Premium P 
	GROUP BY P.PremiumId, P.PolicyID, P.PayerID, P.Amount, P.Receipt, P.PayDate, P.PayType,P.ValidityFrom, P.ValidityTo, P.LegacyID, P.AuditUserID ,P.isPhotoFee,P.ReportingId,P.isOffline
	
END
GO
