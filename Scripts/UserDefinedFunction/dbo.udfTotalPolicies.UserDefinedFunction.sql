/****** Object:  UserDefinedFunction [dbo].[udfTotalPolicies]    Script Date: 19.09.2018 15:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[udfTotalPolicies] 
(
	@ProdID INT = 0,
	@LocationId INT = 0,
	@LastDay DATE,
	@Mode INT	--1: ON Product, 2: On Officer
)
RETURNS @Result TABLE(ProdId INT, Male INT,Female INT, Other INT, Officer NVARCHAR(8),LastName NVARCHAR(50),OtherNames NVARCHAR(50))
AS
BEGIN
IF @Mode = 1
	INSERT INTO @Result(ProdId,Male,Female, Other)
	SELECT ProdId, [M], [F], [O]
	FROM
	(
		SELECT Prod.ProdID, Ins.Gender, Ins.InsureeID
		FROM tblPolicy PL 
		INNER JOIN tblProduct Prod ON Prod.ProdId = PL.ProdID
		INNER JOIN tblFamilies Fam ON Fam.FamilyId = PL.FamilyID
		INNER JOIN tblInsuree Ins ON Ins.InsureeId = Fam.InsureeID
		INNER JOIN uvwLocations L ON L.VillageId = Fam.LocationId

		WHERE PL.ValidityTo IS NULL
		AND Prod.ValidityTo IS NULL
		AND Fam.ValidityTo IS NULL
		AND Ins.ValidityTo IS NULL
		AND PL.PolicyStatus > 1
		AND PL.EffectiveDate <= @LastDay
		AND PL.ExpiryDate >  @LastDay
		AND (Prod.ProdId = @ProdId OR @ProdId = 0)
		AND (L.RegionId = @LocationId OR L.DistrictId = @LocationId OR ISNULL(@LocationId, 0) = 0 OR @LocationId = 0) --@LocationId = 0 Added to get Country data
	)Base
	PIVOT
	(
		COUNT(InsureeId) FOR Gender IN ([M], [F], [O])
	)TotalPolicies

ELSE IF @Mode = 2
	INSERT INTO @Result(ProdId,Male,Female, Other,Officer,LastName,OtherNames)
	SELECT ProdId, [M], [F], [O], Officer, LastName, OtherNames
	FROM
	(
		SELECT Prod.ProdID, Ins.Gender, Ins.InsureeID, O.Code Officer, O.LastName, O.OtherNames
		FROM tblPolicy PL 
		INNER JOIN tblProduct Prod ON Prod.ProdId = PL.ProdID
		INNER JOIN tblOfficer O ON O.OfficerId = PL.OfficerID
		INNER JOIN tblFamilies Fam ON Fam.FamilyId = PL.FamilyID
		INNER JOIN tblInsuree Ins ON Ins.InsureeId = Fam.InsureeID
		INNER JOIN uvwLocations L ON L.VillageId = Fam.LocationId

		WHERE PL.ValidityTo IS NULL
		AND Prod.ValidityTo IS NULL
		AND Fam.ValidityTo IS NULL
		AND Ins.ValidityTo IS NULL
		AND PL.PolicyStatus > 1
		AND PL.EffectiveDate <= @LastDay
		AND PL.ExpiryDate >  @LastDay
		AND (Prod.ProdId = @ProdId OR @ProdId = 0)
		AND (L.RegionId = @LocationId OR L.DistrictId = @LocationId OR ISNULL(@LocationId, 0) = 0 OR @LocationId = 0)
	)Base
	PIVOT
	(
		COUNT(InsureeId) FOR Gender IN ([M], [F], [O])
	)TotalPolicies
	
	RETURN
	
END
GO
