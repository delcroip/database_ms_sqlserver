/****** Object:  UserDefinedFunction [dw].[udfNumberOfPoliciesExpired]    Script Date: 19.09.2018 15:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dw].[udfNumberOfPoliciesExpired]()
	RETURNS @Result TABLE(ExpiredPolicy INT, MonthTime INT, QuarterTime INT, YearTime INT, Age INT, Gender CHAR(1),Region NVARCHAR(20), InsureeDistrictName NVARCHAR(50), WardName NVARCHAR(50), VillageName NVARCHAR(50), ProdDistrictName NVARCHAR(50), ProductCode NVARCHAR(15), ProductName NVARCHAR(100), OfficeDistrict NVARCHAR(20), OfficerCode NVARCHAR(15), LastName NVARCHAR(100), OtherNames NVARCHAR(100), ProdRegion NVARCHAR(50))
AS
BEGIN

	DECLARE @tbl TABLE(MonthId INT, YearId INT)
	INSERT INTO @tbl
	SELECT DISTINCT MONTH(ExpiryDate),YEAR(ExpiryDate) FROM tblPolicy WHERE ValidityTo IS NULL ORDER BY YEAR(ExpiryDate),MONTH(ExpiryDate)


	INSERT INTO @Result(ExpiredPolicy,MonthTime,QuarterTime,YearTime,Age,Gender,Region,InsureeDistrictName,WardName,VillageName,
				ProdDistrictName,ProductCode,ProductName, OfficeDistrict, OfficerCode,LastName,OtherNames, ProdRegion)
			
	SELECT COUNT(PL.PolicyID)ExpiredPolicy, MONTH(PL.ExpiryDate)MonthTime, DATENAME(Q,PL.ExpiryDate) QuarterTime, YEAR(PL.ExpiryDate)YearTime,
	DATEDIFF(YEAR,I.DOB,PL.ExpiryDate)Age, I.Gender, R.RegionName Region,D.DistrictName, W.WardName,V.VillageName,
	D.DistrictName ProdDistrictName,PR.ProductCode, PR.ProductName, 
	ODist.DistrictName OfficerDistrict,O.Code, O.LastName,O.OtherNames, R.RegionName ProdRegion


	FROM tblPolicy PL  INNER JOIN TblProduct PR ON PL.ProdID = PR.ProdID
	INNER JOIN tblOfficer O ON PL.OfficerID = O.OfficerID
	INNER JOIN tblInsuree I ON PL.FamilyID = I.FamilyID
	INNER JOIN tblFamilies F ON I.FamilyID = F.FamilyID
	INNER JOIN tblVillages V ON V.VillageID = F.LocationId
	INNER JOIN tblWards W ON W.WardID = V.WardID
	INNER JOIN tblDistricts D ON D.DistrictID = W.DistrictID
	INNER JOIN tblDistricts ODist ON O.LocationId = ODist.DistrictID
	INNER JOIN tblRegions R ON R.RegionId = D.Region
	CROSS APPLY @tbl t

	WHERE PL.ValidityTo IS NULL 
	AND PR.ValidityTo IS NULL 
	AND I.ValidityTo IS NULL 
	AND O.ValidityTo IS NULL
	AND I.IsHead = 1
	AND MONTH(PL.ExpiryDate) = t.MonthId AND YEAR(PL.ExpiryDate) = t.YearId
	AND PL.PolicyStatus > 1

	GROUP BY MONTH(PL.ExpiryDate),DATENAME(Q,PL.ExpiryDate), YEAR(PL.ExpiryDate), DATEDIFF(YEAR,I.DOB,PL.ExpiryDate),
	I.Gender, R.RegionName,D.DistrictName, W.WardName,V.VillageName ,PR.ProductCode, PR.ProductName, 
	ODist.DistrictName,O.Code, O.LastName,O.OtherNames

	RETURN;
END
GO
