/****** Object:  View [dw].[uvwPremiumCollection]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dw].[uvwPremiumCollection]
AS
	SELECT SUM(PR.Amount)Amount,PR.PayType,Pay.PayerType,Pay.PayerName,R.RegionName Region,FD.DistrictName,Prod.ProductCode,Prod.ProductName,
	O.Code,O.LastName,O.OtherNames,DO.DistrictName OfficerDistrict,MONTH(PR.PayDate)MonthTime,DATENAME(Q,PR.PayDate)QuarterTime,YEAR(PR.PayDate)YearTime
	FROM tblPremium PR LEFT OUTER JOIN tblPayer Pay ON PR.PayerId = Pay.PayerId
	INNER JOIN tblPolicy PL ON PR.PolicyID = PL.PolicyID
	INNER JOIN tblProduct Prod ON PL.ProdID = Prod.ProdId
	INNER JOIN tblOfficer O ON PL.OfficerID = O.OfficerID
	INNER JOIN tblDistricts DO ON O.LocationId = DO.DistrictID
	INNER JOIN tblFamilies F ON PL.FamilyID = F.FamilyID
	INNER JOIN tblVillages V ON V.VillageId = F.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts FD ON FD.DistrictID = W.DistrictID
	INNER JOIN tblRegions R ON R.RegionId = FD.Region
	WHERE PR.ValidityTo IS NULL AND Pay.ValidityTo IS NULL AND PL.ValidityTo IS NULL AND F.ValidityTo IS NULL
	GROUP BY PR.PayType,Pay.PayerType,Pay.PayerName, R.RegionName,Prod.ProductCode,Prod.ProductName,
	O.Code,O.LastName,O.OtherNames,DO.DistrictName,MONTH(PR.PayDate),DATENAME(Q,PR.PayDate),YEAR(PR.PayDate),
	FD.DistrictName
GO
