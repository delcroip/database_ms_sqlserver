/****** Object:  StoredProcedure [dbo].[uspExportOffLineExtract6]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspExportOffLineExtract6]
	 @RegionId INT = 0,
	 @DistrictId INT = 0,
	 @RowID as bigint = 0,
	 
	--updated by Amani 22/09/2017
	@WithInsuree as bit = 0
AS
BEGIN
	SET NOCOUNT ON
	
	
	;WITH Insurees AS (
	SELECT [dbo].[tblInsuree].[InsureeID],PhotoID
	FROM [dbo].[tblInsuree] INNER JOIN tblFamilies ON tblFamilies.FamilyID = tblInsuree.FamilyID 
	INNER JOIN tblVillages V ON V.VillageID = tblFamilies.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	WHERE tblInsuree.RowID > @RowID 
	--AND ((CASE @DistrictId  WHEN 0 THEN 0 ELSE D.[DistrictID]  END) = @DistrictId OR D.Region = @RegionId) Commented by Rogers
	AND ((CASE @DistrictId  WHEN 0 THEN 0 ELSE D.[DistrictID]  END) = @DistrictId OR @DistrictId =0)  --added by Rogers 0n 10.11.2017
	AND ((CASE @DistrictId  WHEN 0 THEN  D.Region  ELSE @RegionId END) = @RegionId OR @RegionId =0)
	AND[tblInsuree].[InsureeID] =  CASE WHEN	@WithInsuree=0 THEN NULL ELSE [tblInsuree].[InsureeID] END
	--Amani 22/09/2017 change to this------>AND[tblInsuree].[InsureeID] =  CASE WHEN	@WithInsuree=0 THEN NULL END
	UNION ALL
 	SELECT I.[InsureeID],PhotoID
	FROM tblFamilies F INNER JOIN tblInsuree I ON F.FamilyId = I.FamilyID
	INNER JOIN tblHF HF ON I.HFId = HF.HfID
	WHERE I.RowID > @RowID 
	AND (CASE @DistrictId  WHEN 0 THEN 0 ELSE HF.[LocationId]  END) = @DistrictId
	AND I.[InsureeID] =  CASE WHEN	@WithInsuree=0 THEN NULL ELSE I.[InsureeID] END
	)
	--select * from Insurees 

	SELECT P.PhotoID, P.InsureeID, P.CHFID, P.PhotoFolder, P.PhotoFileName, P.OfficerID, P.PhotoDate,P.ValidityFrom, P.ValidityTo, P.AuditUserID
	FROM (SELECT Insurees.InsureeID,Insurees.PhotoID FROM Insurees  Group BY InsureeID,PhotoID) I 
	INNER JOIN tblPhotos P ON I.PhotoID = P.PhotoID --AND I.InsureeID=P.InsureeID
	GROUP BY P.PhotoID, P.InsureeID, P.CHFID, P.PhotoFolder, P.PhotoFileName, P.OfficerID, P.PhotoDate,P.ValidityFrom, P.ValidityTo, P.AuditUserID
END



GO
