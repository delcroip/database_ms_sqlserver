/****** Object:  UserDefinedFunction [dbo].[udfNewPolicies]    Script Date: 19.09.2018 15:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[udfNewPolicies]
(
	@ProdID INT,
	@LocationId INT = 0,
	@Month INT,
	@Year INT,
	@Mode INT	--1: Product Base, 2: Enrollment Officer Base
)
RETURNS @Result TABLE(ProdId INT, Male INT,Female INT,Other INT, Officer VARCHAR(50),LastName NVARCHAR(50),OtherNames NVARCHAR(50))
AS
BEGIN
IF @Mode = 1
	INSERT INTO @Result(ProdId,Male,Female,Other)
	SELECT ProdId, M Male, F Female, O Other
	FROM
	(SELECT PL.ProdId, I.Gender, I.InsureeId
	FROM tblPolicy PL 
	INNER JOIN tblFamilies Fam ON PL.FamilyID = Fam.FamilyId
	INNER JOIN tblVillages V ON V.VillageId = Fam.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	INNER JOIN tblRegions R ON R.RegionId = D.Region
	INNER JOIN tblInsuree I ON I.InsureeId = Fam.InsureeID
	WHERE PL.ValidityTo IS NULL
	AND Fam.ValidityTo IS NULL
	AND V.ValidityTo IS NULL
	AND W.ValidityTo IS NULL
	AND D.ValidityTo IS NULL
	AND R.ValidityTo IS NULL
	AND I.ValidityTo IS NULL
	AND PL.PolicyStatus > 1
	AND PL.PolicyStage = N'N'
	AND (PL.ProdId = @ProdID OR @ProdID = 0)
	AND (R.RegionId = @LocationId OR D.DistrictId = @LocationId OR @LocationId = 0)
	AND MONTH(PL.EnrollDate) = @Month
	AND YEAR(PL.EnrollDate) = @Year
	) NewPolicies
	PIVOT
	(
		COUNT(InsureeId) FOR Gender IN (M, F, O)
	)pvt
	
ELSE IF @Mode = 2
	INSERT INTO @Result(ProdId,Male,Female,Other,Officer,LastName,OtherNames)
	SELECT ProdId, M Male, F Female, O Other, Officer, LastName, OtherNames
FROM
	(SELECT PL.ProdId, I.Gender, O.Code Officer, O.LastName, O.OtherNames, I.InsureeId
	FROM tblPolicy PL 
	INNER JOIN tblFamilies Fam ON PL.FamilyID = Fam.FamilyId
	INNER JOIN tblVillages V ON V.VillageId = Fam.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	INNER JOIN tblRegions R ON R.RegionId = D.Region
	INNER JOIN tblInsuree I ON I.InsureeId = Fam.InsureeID
	INNER JOIN tblOfficer O ON O.OfficerId = PL.OfficerID
	WHERE PL.ValidityTo IS NULL
	AND Fam.ValidityTo IS NULL
	AND V.ValidityTo IS NULL
	AND W.ValidityTo IS NULL
	AND D.ValidityTo IS NULL
	AND R.ValidityTo IS NULL
	AND I.ValidityTo IS NULL
	AND O.ValidityTo IS NULL
	AND PL.PolicyStatus > 1
	AND PL.PolicyStage = N'N'
	AND (PL.ProdId = @ProdID OR @ProdID = 0)
	AND (R.RegionId = @LocationId OR D.DistrictId = @LocationId OR @LocationId = 0)
	AND MONTH(PL.EnrollDate) = @Month
	AND YEAR(PL.EnrollDate) = @Year
	) NewPolicies
	PIVOT
	(
		COUNT(InsureeId) FOR Gender IN (M, F, O)
	)pvt
	
	RETURN
END	
GO
