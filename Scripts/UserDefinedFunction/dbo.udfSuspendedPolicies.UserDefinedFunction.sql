/****** Object:  UserDefinedFunction [dbo].[udfSuspendedPolicies]    Script Date: 19.09.2018 15:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udfSuspendedPolicies]
(
	@ProdID INT = 0,
	@LocationId INT ,
	@Month INT,
	@Year INT,
	@Mode INT	--1:Product base 2: Officer Base
)
RETURNS @Result TABLE(ProdId INT,SuspendedPolicies INT,Officer NVARCHAR(50),LastName NVARCHAR(50), OtherNames NVARCHAR(50))
AS
BEGIN

IF @Mode = 1
	INSERT INTO @Result(ProdId,SuspendedPolicies)
	SELECT  PL.ProdID,COUNT(PL.PolicyID)SuspendedPolicies
	FROM tblPolicy PL 
	INNER JOIN tblFamilies F ON F.FamilyId = PL.FamilyId
	INNER JOIN tblVillages V ON V.VillageId = F.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	
	WHERE PL.ValidityTo IS NULL 
	AND F.ValidityTo IS NULL
	AND PL.PolicyStatus = 4
	AND (PL.ProdID = @ProdID OR @ProdID = 0)
	AND MONTH(PL.ValidityFrom) = @Month AND YEAR(PL.ValidityFrom) = @Year 
	AND (D.Region = @LocationId OR D.DistrictId= @LocationId OR @LocationId = 0)
	GROUP BY PL.ProdID
ELSE IF @Mode = 2
	INSERT INTO @Result(ProdId,SuspendedPolicies,Officer,LastName,OtherNames)
	SELECT  PL.ProdID,COUNT(PL.PolicyID)SuspendedPolicies,O.Code,O.LastName,O.OtherNames
	FROM tblPolicy PL 
	INNER JOIN tblFamilies F ON F.FamilyId = PL.FamilyId
	INNER JOIN tblVillages V ON V.VillageId = F.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	INNER JOIN tblOfficer O ON PL.OfficerID = O.OfficerID
	WHERE PL.ValidityTo IS NULL
	AND F.ValidityTo IS NULL
	AND PL.PolicyStatus = 4
	AND (PL.ProdID = @ProdID OR @ProdID = 0)
	AND MONTH(PL.ValidityFrom) = @Month AND YEAR(PL.ValidityFrom) = @Year 
	AND (D.Region = @LocationId OR D.DistrictId= @LocationId OR @LocationId = 0)
	GROUP BY PL.ProdID,O.Code,O.LastName,O.OtherNames
	
RETURN
END
GO
