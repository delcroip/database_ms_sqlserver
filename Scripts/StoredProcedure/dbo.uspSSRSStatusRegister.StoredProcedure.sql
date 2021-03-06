/****** Object:  StoredProcedure [dbo].[uspSSRSStatusRegister]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspSSRSStatusRegister]
(
	@LocationId INT = 0
)
AS
BEGIN

	SET ARITHABORT OFF;

	IF @LocationId = -1
		SET @LocationId = NULL;

	DECLARE @tblResult TABLE(
		LocationId INT,
		ParentLocationId INT,
		LocationType NVARCHAR(1),
		LocationName NVARCHAR(100),
		TotalActiveOfficers INT,
		TotalNonActiveOfficers INT,
		TotalUsers INT,
		TotalProducts INT,
		TotalHealthFacilities INT,
		TotalItemPriceLists INT,
		TotalServicePriceLists INT,
		TotalItems INT,
		TotalServices INT,
		TotalPayers INT
	);

	;WITH LocationsAll AS
		(
		SELECT -1 LocationId, N'National' LocationName, NULL ParentLocationId, NULL LocationType
		UNION
		SELECT LocationId,LocationName, ISNULL(ParentLocationId, -1)ParentLocationId, LocationType FROM tblLocations WHERE LocationType IN ('D', 'R') AND ValidityTo IS NULL AND (LocationId = @LocationId OR CASE WHEN @LocationId IS NULL THEN ISNULL(ParentLocationId, 0) ELSE 0 END = ISNULL(@LocationId, 0))
		UNION ALL
		SELECT L.LocationId, L.LocationName, L.ParentLocationId, L.LocationType
		FROM tblLocations L 
		INNER JOIN LocationsAll ON LocationsAll.LocationId = L.ParentLocationId
		WHERE L.ValidityTo IS NULL
		AND L.LocationType = N'D'
		),Locations AS(
			SELECT Locationid, LocationName, ParentLocationId, LocationType
			FROM LocationsAll
			GROUP BY LocationID, LocationName, ParentLocationId, LocationType
		)


		INSERT INTO @tblResult(LocationId, ParentLocationId, LocationType, LocationName, TotalActiveOfficers, TotalNonActiveOfficers, TotalUsers, TotalProducts, TotalHealthFacilities, TotalItemPriceLists, TotalServicePriceLists, TotalItems, TotalServices, TotalPayers)
	
		SELECT Locations.LocationId, NULLIF(Locations.ParentLocationId, -1)ParentLocationId, Locations.LocationType ,Locations.LocationName,ActiveOfficers.TotalEnrollmentOfficers TotalActiveOfficers
		, NonActiveOfficers.TotalEnrollmentOfficers TotalNonActiveOfficers 
		,Users.TotalUsers,TotalProducts ,HF.TotalHealthFacilities ,PLItems.TotalItemPriceLists,PLServices.TotalServicePriceLists ,
		PLItemDetails.TotalItems,PLServiceDetails.TotalServices,Payers.TotalPayers
		FROM
		(SELECT COUNT(O.OfficerId)TotalEnrollmentOfficers,ISNULL(L.LocationId, -1)LocationId 
		FROM Locations L
		LEFT OUTER JOIN tblOfficer O ON ISNULL(O.LocationId, -1) = L.LocationId AND O.ValidityTo IS NULL
		WHERE ISNULL(CAST(WorksTo AS DATE) , DATEADD(DAY, 1, GETDATE())) > CAST(GETDATE() AS DATE) 
		GROUP BY L.LocationId) ActiveOfficers INNER JOIN Locations ON Locations.LocationId = ActiveOfficers.LocationId 

		LEFT OUTER JOIN
		(SELECT COUNT(O.OfficerId)TotalEnrollmentOfficers,ISNULL(L.LocationId, -1)LocationId 
		FROM Locations L
		LEFT OUTER JOIN tblOfficer O ON ISNULL(O.LocationId, -1) = L.LocationId AND O.ValidityTo IS NULL
		WHERE CAST(WorksTo AS DATE) <= CAST(GETDATE() AS DATE) 
		GROUP BY L.LocationId
		) NonActiveOfficers ON Locations.LocationId = NonActiveOfficers.LocationId

		LEFT OUTER JOIN
		(SELECT COUNT(U.UserID) TotalUsers,ISNULL(L.LocationId, -1)LocationId 
		FROM tblUsers U 
		INNER JOIN tblUsersDistricts UD ON U.UserID = UD.UserID AND U.ValidityTo IS NULL AND UD.ValidityTo IS NULL
		RIGHT OUTER JOIN Locations L ON L.LocationId = UD.LocationId
		GROUP BY L.LocationId)Users ON Locations.LocationId = Users.LocationId

		LEFT OUTER JOIN 
		(SELECT COUNT(Prod.ProdId)TotalProducts, ISNULL(L.LocationId, -1)LocationId 
		FROM Locations L
		LEFT OUTER JOIN tblProduct Prod ON ISNULL(Prod.Locationid, -1) = L.LocationId AND Prod.ValidityTo IS NULL 
		GROUP BY L.LocationId) Products ON Locations.LocationId = Products.LocationId

		LEFT OUTER JOIN 
		(SELECT COUNT(HF.HfID)TotalHealthFacilities, ISNULL(L.LocationId, -1)LocationId 
		FROM Locations L
		LEFT OUTER JOIN tblHF HF ON ISNULL(HF.LocationId, -1) = L.LocationId AND HF.ValidityTo IS NULL
		GROUP BY L.LocationId) HF ON Locations.LocationId = HF.LocationId

		LEFT OUTER JOIN 
		(SELECT COUNT(PLI.PLItemID) TotalItemPriceLists, ISNULL(L.LocationId, -1)LocationId 
		FROM Locations L
		LEFT OUTER JOIN tblPLItems PLI ON ISNULL(PLI.LocationId, -1) = L.LocationId AND PLI.ValidityTo IS NULL
		GROUP BY L.LocationId) PLItems ON Locations.LocationId = PLItems.LocationId

		LEFT OUTER JOIN
		(SELECT COUNT(PLS.PLServiceID) TotalServicePriceLists,ISNULL(L.LocationId, -1)LocationId 
		FROM Locations L
		LEFT OUTER JOIN tblPLServices PLS ON ISNULL(PLS.LocationId, -1) = L.LocationId AND PLS.ValidityTo IS NULL 
		GROUP BY L.LocationId) PLServices ON Locations.LocationId = PLServices.LocationId

		LEFT OUTER JOIN
		(SELECT COUNT(ItemId)TotalItems, LocationId
		FROM (
			SELECT I.ItemID, ISNULL(L.LocationId, -1)LocationId
			FROM Locations L
			LEFT OUTER JOIN tblPLItems PL ON ISNULL(PL.LocationId, -1) = L.LocationId AND PL.ValidityTo IS NULL
			LEFT OUTER JOIN tblPLItemsDetail I ON I.PLItemID = PL.PLItemID
			GROUP BY I.ItemId, L.LocationId
		)x
		GROUP BY LocationId)PLItemDetails ON Locations.LocationId = PLItemDetails.LocationId

		LEFT OUTER JOIN
		(SELECT COUNT(ServiceID)TotalServices, LocationId
		FROM (
			SELECT S.ServiceId, ISNULL(L.LocationId, -1)LocationId
			FROM Locations L
			LEFT OUTER JOIN tblPLServices PL ON ISNULL(PL.LocationId, -1) = L.LocationId AND PL.ValidityTo IS NULL
			LEFT OUTER JOIN tblPLServicesDetail S ON S.PLServiceID = PL.PLServiceID 
			GROUP BY S.ServiceID, L.LocationId
		)x
		GROUP BY LocationId)PLServiceDetails ON Locations.LocationId = PLServiceDetails.LocationId

		LEFT OUTER JOIN
		(SELECT COUNT(P.PayerId)TotalPayers,ISNULL(L.LocationId, -1)LocationId 
		FROM Locations L 
		LEFT OUTER JOIN tblPayer P ON ISNULL(P.LocationId, -1) = L.LocationId AND P.ValidityTo IS NULL 
		GROUP BY L.LocationId)Payers ON Locations.LocationId = Payers.LocationId

	IF @LocationId = 0
	BEGIN
		;WITH Results AS
		(
			SELECT 0 [Level],LocationId, ParentLocationId, Locationname, LocationType,
			TotalActiveOfficers, TotalNonActiveOfficers, TotalUsers, TotalProducts, TotalHealthFacilities, TotalItemPriceLists, TotalServicePriceLists, TotalItems, TotalServices, TotalPayers
			FROM @tblResult 
			UNION ALL
			SELECT Results.[Level] + 1, R.LocationId, R.ParentLocationId, R.LocationName, R.LocationType,
			Results.TotalActiveOfficers, Results.TotalNonActiveOfficers, Results.TotalUsers, Results.TotalProducts, Results.TotalHealthFacilities, Results.TotalItemPriceLists, Results.TotalServicePriceLists, Results.TotalItems, Results.TotalServices, Results.TotalPayers
			FROM @tblResult R
			INNER JOIN Results ON R.LocationId = Results.ParentLocationId
		)
		SELECT LocationId, LocationName
		, NULLIF(SUM(TotalActiveOfficers), 0) TotalActiveOfficers
		, NULLIF(SUM(TotalNonActiveOfficers), 0)TotalNonActiveOfficers
		, NULLIF(SUM(TotalUsers), 0)TotalUsers
		, NULLIF(SUM(TotalProducts), 0)TotalProducts
		, NULLIF(SUM(TotalHealthFacilities), 0) TotalHealthFacilities
		, NULLIF(SUM(TotalItemPriceLists) , 0)TotalItemPriceLists
		, NULLIF(SUM(TotalServicePriceLists), 0) TotalServicePriceLists
		, NULLIF(SUM(TotalItems), 0)TotalItems
		, NULLIF(SUM(TotalServices), 0) TotalServices
		, NULLIF(SUM(TotalPayers), 0)TotalPayers

		FROM Results
		WHERE LocationType = 'R' OR LocationType IS NULL
		GROUP BY LocationId, LocationName
		ORDER BY LocationId
	END
	ELSE
	BEGIN
		SELECT LocationId, LocationName, NULLIF(TotalActiveOfficers, 0)TotalActiveOfficers, NULLIF(TotalNonActiveOfficers, 0)TotalNonActiveOfficers, NULLIF(TotalUsers, 0)TotalUsers, NULLIF(TotalProducts, 0)TotalProducts, NULLIF(TotalHealthFacilities, 0)TotalHealthFacilities, NULLIF(TotalItemPriceLists, 0)TotalItemPriceLists, NULLIF(TotalServicePriceLists, 0)TotalServicePriceLists, NULLIF(TotalItems, 0)TotalItems, NULLIF(TotalServices, 0)TotalServices, NULLIF(TotalPayers, 0)TotalPayers  
		FROM @tblResult
		WHERE LocationId <> -1;
	END
END
GO
