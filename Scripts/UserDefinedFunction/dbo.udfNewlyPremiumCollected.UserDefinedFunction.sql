/****** Object:  UserDefinedFunction [dbo].[udfNewlyPremiumCollected]    Script Date: 19.09.2018 15:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udfNewlyPremiumCollected]
(
	@ProdID INT = 0,
	@LocationId INT = 0,
	@Month INT,
	@Year INT,
	@Mode INT	--1:Product Base, 2:Officer Base
)
RETURNS @Result TABLE(ProdId INT, PremiumCollection FLOAT,Officer NVARCHAR(50),LastName NVARCHAR(50),OtherNames NVARCHAR(50))
AS
BEGIN
IF @Mode = 1
	INSERT INTO @Result(ProdId,PremiumCollection)	
	SELECT PL.ProdID,SUM(PR.Amount)PremiumCollection
	FROM tblPolicy PL 
	INNER JOIN tblFamilies Fam ON PL.FamilyID = Fam.FamilyId
	INNER JOIN tblVillages V ON V.VillageId = Fam.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	LEFT OUTER JOIN tblPremium PR ON PL.PolicyID = PR.PolicyID 
	WHERE PR.ValidityTo IS NULL
	AND (PL.ProdID = @ProdID OR @ProdID = 0)
	AND (D.Region = @LocationId OR D.DistrictId = @LocationId OR @LocationId = 0)
	AND MONTH(PR.PayDate) = @Month AND YEAR(PR.PayDate) = @Year
	GROUP BY PL.ProdID
ELSE IF @Mode = 2
	INSERT INTO @Result(ProdId,PremiumCollection,Officer,LastName,OtherNames)
	SELECT PL.ProdID,SUM(PR.Amount)PremiumCollection,O.Code,O.LastName,O.OtherNames
	FROM tblPolicy PL 
	INNER JOIN tblFamilies Fam ON PL.FamilyID = Fam.FamilyId
	INNER JOIN tblVillages V ON V.VillageId = Fam.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	INNER JOIN tblOfficer O ON PL.OfficerID = O.OfficerID
	LEFT OUTER JOIN tblPremium PR ON PL.PolicyID = PR.PolicyID 
	WHERE PR.ValidityTo IS NULL
	AND (D.Region = @LocationId OR D.DistrictId = @LocationId OR @LocationId = 0)
	AND (PL.ProdID = @ProdID OR @ProdID = 0)
	AND (D.Region = @LocationId OR D.DistrictId = @LocationId OR @LocationId = 0)
	AND MONTH(PR.PayDate) = @Month AND YEAR(PR.PayDate) = @Year
	GROUP BY PL.ProdID,O.Code,O.LastName,O.OtherNames
	
RETURN
END

GO
