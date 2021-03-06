/****** Object:  View [dw].[uvwPopulation]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dw].[uvwPopulation]
AS
	SELECT RegionName Region,	DistrictName District,WardName Ward, VillageName Village, MalePopulation Male, FemalePopulation	Female, OtherPopulation others , Families	Households,	Year(GETDATE()) YEAR 
	FROM tblVillages V
	INNER JOIN tblWards W ON V.WardId = W.WardId
	INNER JOIN tblDistricts D ON D.DistrictId =W.DistrictId
	INNER JOIN tblRegions R ON R.RegionId = D.Region
	WHERE V.ValidityTo IS NULL
	AND W.ValidityTo  IS NULL 
	AND D.ValidityTo   IS NULL
	AND R.ValidityTo   IS NULL
GO
