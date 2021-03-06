/****** Object:  UserDefinedFunction [dbo].[udfPolicyRenewal]    Script Date: 19.09.2018 15:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udfPolicyRenewal]
(
	@ProdID INT = 0,
	@LocationId INT = 0,
	@Month INT,
	@Year INT,
	@Mode INT	--1: Product Base, 2:Officer Base
)
RETURNS @Result TABLE(ProdId INT, Renewals INT, Officer NVARCHAR(50),LastName NVARCHAR(50),OtherNames NVARCHAR(50))
AS
BEGIN
IF @Mode = 1
	INSERT INTO @Result(ProdId,Renewals)
	SELECT PL.ProdId, COUNT(PL.PolicyId)Renewals
	FROM tblPolicy PL 
	INNER JOIN tblFamilies Fam ON PL.FamilyID = Fam.FamilyId
	INNER JOIN tblVillages V ON V.VillageId = Fam.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	WHERE PL.ValidityTo IS NULL
	AND Fam.ValidityTo IS NULL
	AND PL.PolicyStatus > 1
	AND PL.PolicyStage = N'R'
	AND (PL.ProdId = @ProdID OR @ProdID = 0)
	AND (D.DistrictId = @LocationId OR D.Region = @LocationId OR @LocationId = 0)
	AND MONTH(PL.EnrollDate) = @Month
	AND YEAR(PL.EnrollDate) = @Year
	GROUP BY PL.ProdID

ELSE IF @Mode = 2
	INSERT INTO @Result(ProdId,Renewals,Officer,LastName,OtherNames)
	SELECT PL.ProdId, COUNT(PL.PolicyId)Renewals, O.Code Officer, O.LastName, O.OtherNames
	FROM tblPolicy PL 
	INNER JOIN tblFamilies Fam ON PL.FamilyID = Fam.FamilyId
	INNER JOIN tblVillages V ON V.VillageId = Fam.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	INNER JOIN tblOfficer O ON O.OfficerId = PL.OfficerId

	WHERE PL.ValidityTo IS NULL
	AND Fam.ValidityTo IS NULL
	AND PL.PolicyStatus > 1
	AND PL.PolicyStage = N'R'
	AND (PL.ProdId = @ProdID OR @ProdID = 0)
	AND (D.DistrictId = @LocationId OR D.Region = @LocationId OR @LocationId = 0)
	AND MONTH(PL.EnrollDate) = @Month
	AND YEAR(PL.EnrollDate) = @Year
	GROUP BY PL.ProdID, O.Code , O.LastName, O.OtherNames
	RETURN
	
	END
GO
