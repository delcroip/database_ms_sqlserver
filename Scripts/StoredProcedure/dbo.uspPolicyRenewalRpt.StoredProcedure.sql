/****** Object:  StoredProcedure [dbo].[uspPolicyRenewalRpt]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspPolicyRenewalRpt]
	
	@RangeFrom date = getdate,
	@RangeTo date= getdate,
	@IntervalType as tinyint = 1 ,     -- 1 = Prompt Date in prompting table ; 2 = Expiry Date search in prompting table ; 3 = Dynamic report on expiry in future 
	@OfficerID int = 0,
	@LocationId as int = 0,
	@VillageID as int = 0, 
	@WardID as int = 0 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF @IntervalType = 1 --Prompting date
	BEGIN 
		SELECT     tblPolicyRenewals.RenewalID,tblPolicyRenewals.RenewalPromptDate , tblPolicyRenewals.RenewalDate, tblPolicyRenewals.PhoneNumber, tblDistricts.DistrictName, tblVillages.VillageName, 
							  tblWards.WardName, tblInsuree.CHFID, tblInsuree.LastName, tblInsuree.OtherNames, tblProduct.ProductCode, tblProduct.ProductName, 
							  tblPolicyRenewals.RenewalWarnings, tblInsuree_1.CHFID AS PhotoCHFID, tblInsuree_1.LastName AS PhotoLastName, tblInsuree_1.OtherNames AS PhotoOtherNames, tblPolicyRenewals.SMSStatus 
							  
		FROM         tblInsuree AS tblInsuree_1 RIGHT OUTER JOIN
							  tblPolicyRenewalDetails ON tblInsuree_1.InsureeID = tblPolicyRenewalDetails.InsureeID RIGHT OUTER JOIN
							  tblPolicyRenewals INNER JOIN
							  tblInsuree ON tblPolicyRenewals.InsureeID = tblInsuree.InsureeID INNER JOIN
							  tblPolicy ON tblPolicyRenewals.PolicyID = tblPolicy.PolicyID INNER JOIN
							  tblFamilies ON tblPolicy.FamilyID = tblFamilies.FamilyID INNER JOIN
							  tblVillages ON tblFamilies.LocationId = tblVillages.VillageID INNER JOIN
							  tblWards ON tblWards.WardID = tblVillages.WardID INNER JOIN
							  tblDistricts ON tblWards.DistrictID = tblDistricts.DistrictID INNER JOIN
							  tblProduct ON tblPolicy.ProdID = tblProduct.ProdID ON tblPolicyRenewalDetails.RenewalID = tblPolicyRenewals.RenewalID
		WHERE     (tblPolicyRenewals.RenewalPromptDate BETWEEN @RangeFrom AND @RangeTo) 
				AND CASE @LocationId WHEN 0 THEN 0 ELSE tblDistricts.DistrictID  END = @LocationId
				AND CASE @WardID WHEN 0 THEN 0 ELSE tblWards.WardID  END = @WardID
				AND CASE @VillageID WHEN 0 THEN 0 ELSE tblVillages.VillageID  END = @VillageID
				AND CASE @OfficerID WHEN 0 THEN 0 ELSE tblPolicy.OfficerID   END = @OfficerID
	END
	IF @IntervalType = 2 --Expiry/Renewal date
	BEGIN 
		SELECT     tblPolicyRenewals.RenewalID,tblPolicyRenewals.RenewalPromptDate , tblPolicyRenewals.RenewalDate, tblPolicyRenewals.PhoneNumber, tblDistricts.DistrictName, tblVillages.VillageName, 
							  tblWards.WardName, tblInsuree.CHFID, tblInsuree.LastName, tblInsuree.OtherNames, tblProduct.ProductCode, tblProduct.ProductName, 
							  tblPolicyRenewals.RenewalWarnings, tblInsuree_1.CHFID AS PhotoCHFID, tblInsuree_1.LastName AS PhotoLastName, tblInsuree_1.OtherNames AS PhotoOtherNames, tblPolicyRenewals.SMSStatus 
							  
		FROM         tblInsuree AS tblInsuree_1 RIGHT OUTER JOIN
							  tblPolicyRenewalDetails ON tblInsuree_1.InsureeID = tblPolicyRenewalDetails.InsureeID RIGHT OUTER JOIN
							  tblPolicyRenewals INNER JOIN
							  tblInsuree ON tblPolicyRenewals.InsureeID = tblInsuree.InsureeID INNER JOIN
							  tblPolicy ON tblPolicyRenewals.PolicyID = tblPolicy.PolicyID INNER JOIN
							  tblFamilies ON tblPolicy.FamilyID = tblFamilies.FamilyID INNER JOIN
							  tblVillages ON tblFamilies.LocationId = tblVillages.VillageID INNER JOIN
							  tblWards ON tblVillages.WardID = tblWards.WardID INNER JOIN
							  tblDistricts ON tblWards.DistrictID = tblDistricts.DistrictID INNER JOIN
							  tblProduct ON tblPolicy.ProdID = tblProduct.ProdID ON tblPolicyRenewalDetails.RenewalID = tblPolicyRenewals.RenewalID
		WHERE     (tblPolicyRenewals.RenewalDate  BETWEEN @RangeFrom AND @RangeTo) 
				AND CASE @LocationId WHEN 0 THEN 0 ELSE tblDistricts.DistrictID  END = @LocationId
				AND CASE @WardID WHEN 0 THEN 0 ELSE tblWards.WardID  END = @WardID
				AND CASE @VillageID WHEN 0 THEN 0 ELSE tblVillages.VillageID  END = @VillageID
				AND CASE @OfficerID WHEN 0 THEN 0 ELSE tblPolicy.OfficerID   END = @OfficerID
	END
	
END
GO
