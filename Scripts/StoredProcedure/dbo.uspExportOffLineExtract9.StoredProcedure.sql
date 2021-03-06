/****** Object:  StoredProcedure [dbo].[uspExportOffLineExtract9]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspExportOffLineExtract9]
@RegionId INT = 0,
	 @DistrictId INT = 0,
	 @RowID as bigint = 0,
	 
	--updated by Amani 22/09/2017
	@WithInsuree as bit = 0
AS
BEGIN
	SET NOCOUNT ON
	
	
	
	; WITH InsureePolicy AS (
	SELECT Ip.InsureePolicyId,IP.InsureeId,IP.PolicyId,IP.EnrollmentDate,Ip.StartDate,IP.EffectiveDate,IP.ExpiryDate,IP.ValidityFrom,IP.ValidityTo,IP.LegacyId,IP.AuditUserId,IP.isOffline
	FROM tblInsureePolicy IP RIGHT OUTER JOIN tblInsuree I ON IP.InsureeId = I.InsureeID
	LEFT OUTER JOIN tblFamilies F ON F.FamilyID = I.FamilyID
	INNER JOIN tblVillages V ON V.VillageID = F.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	WHERE 
	 --IP.ValidityTo IS NULL AND F.ValidityTo IS NULL
	--AND (D.DistrictID = @DistrictId OR @DistrictId = 0 OR D.Region =@RegionId)Commented by Rogers
	 ((CASE @DistrictId  WHEN 0 THEN 0 ELSE D.[DistrictID]  END) = @DistrictId OR @DistrictId =0)  --added by Rogers 0n 10.11.2017
	AND ((CASE @DistrictId  WHEN 0 THEN  D.Region  ELSE @RegionId END) = @RegionId OR @RegionId =0)
	AND IP.RowId > @RowID
	AND D.[DistrictId]= CASE WHEN @WithInsuree=0 THEN NULL ELSE D.[DistrictId] END --ADDED 25/09
	UNION ALL
	SELECT Ip.InsureePolicyId,IP.InsureeId,IP.PolicyId,IP.EnrollmentDate,Ip.StartDate,IP.EffectiveDate,IP.ExpiryDate,IP.ValidityFrom,IP.ValidityTo,IP.LegacyId,IP.AuditUserId ,IP.isOffline
	FROM tblInsureePolicy IP RIGHT OUTER JOIN tblInsuree I ON IP.InsureeId = I.InsureeID
	LEFT OUTER JOIN tblFamilies F ON F.FamilyID = I.FamilyID
	INNER JOIN tblHF HF ON I.HFId = HF.HfID
	WHERE IP.RowID > @RowID 
	AND (CASE @DistrictId  WHEN 0 THEN 0 ELSE HF.[LocationId]  END) = @DistrictId 
	AND HF.[LocationId] = CASE WHEN @WithInsuree=0 THEN NULL ELSE HF.LocationId END --ADDED 25/09
	)
	SELECT * FROM InsureePolicy IP 
	GROUP BY IP.InsureePolicyId,IP.InsureeId,IP.PolicyId,IP.EnrollmentDate,Ip.StartDate,IP.EffectiveDate,IP.ExpiryDate,IP.ValidityFrom,IP.ValidityTo,IP.LegacyId,IP.AuditUserId,IP.isOffline 

END
GO
