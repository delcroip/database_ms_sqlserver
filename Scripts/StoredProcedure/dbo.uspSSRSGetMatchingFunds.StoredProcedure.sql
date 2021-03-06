/****** Object:  StoredProcedure [dbo].[uspSSRSGetMatchingFunds]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspSSRSGetMatchingFunds]
(
	@LocationId INT = NULL, 
	@ProdId INT = NULL,
	@PayerId INT = NULL,
	@StartDate DATE = NULL,
	@EndDate DATE = NULL,
	@ReportingId INT = NULL,
	@ErrorMessage NVARCHAR(200) = N'' OUTPUT
)
AS
BEGIN

/*=======Return Values
	0	= All OK
   -1	= Error Occured
	1	= District is missing
	2	= Product is missing
	3	= StartDate is missing
	4	= End Date is missing
	
*/

	DECLARE @RecordFound INT = 0

	--Create new entries only if reportingId is not provided

	IF @ReportingId IS NULL
	BEGIN

		IF @LocationId IS NULL RETURN 1;
		IF @ProdId IS NULL RETURN 2;
		IF @StartDate IS NULL RETURN 3;
		IF @EndDate IS NULL RETURN 4;
		
		BEGIN TRY
			BEGIN TRAN
				--Insert the entry into the reporting table
				INSERT INTO tblReporting(ReportingDate,LocationId, ProdId, PayerId, StartDate, EndDate, RecordFound)
				SELECT GETDATE(),@LocationId, @ProdId, @PayerId, @StartDate, @EndDate, 0;

				--Get the last inserted reporting Id
				SELECT @ReportingId =  SCOPE_IDENTITY();

	
				--Update the premium table with the new reportingid

				UPDATE tblPremium SET ReportingId = @ReportingId
				WHERE PremiumId IN (
				SELECT Pr.PremiumId--,Prod.ProductCode, Prod.ProductName, D.DistrictName, W.WardName, V.VillageName, Ins.CHFID, Ins.LastName + ' ' + Ins.OtherNames InsName, 
				--Ins.DOB, Ins.IsHead, PL.EnrollDate, Pr.Paydate, Pr.Receipt,CASE WHEN Ins.IsHead = 1 THEN Pr.Amount ELSE 0 END Amount, Payer.PayerName
				FROM tblPremium Pr INNER JOIN tblPolicy PL ON Pr.PolicyID = PL.PolicyID
				INNER JOIN tblProduct Prod ON PL.ProdID = Prod.ProdID
				INNER JOIN tblFamilies F ON PL.FamilyID = F.FamilyID
				INNER JOIN tblVillages V ON V.VillageId = F.LocationId
				INNER JOIN tblWards W ON W.WardId = V.WardId
				INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
				LEFT OUTER JOIN tblPayer Payer ON Pr.PayerId = Payer.PayerID 

				WHERE Pr.ValidityTo IS NULL 
				AND PL.ValidityTo IS NULL
				AND Prod.ValidityTo IS NULL
				AND F.ValidityTo IS NULL
				AND D.ValidityTo IS NULL
				AND W.ValidityTo IS NULL
				AND V.ValidityTo IS NULL
				AND Payer.ValidityTo IS NULL

				AND D.DistrictID = @LocationId
				AND PayDate BETWEEN @StartDate AND @EndDate
				AND Prod.ProdID = @ProdId
				AND (ISNULL(Payer.PayerID,0) = ISNULL(@PayerId,0) OR @PayerId IS NULL)
				AND Pr.ReportingId IS NULL
				AND PR.PayType <> N'F'
				)

				SELECT @RecordFound = @@ROWCOUNT;

				UPDATE tblReporting SET RecordFound = @RecordFound WHERE ReportingId = @ReportingId;

			COMMIT TRAN;
		END TRY
		BEGIN CATCH
			SELECT @ErrorMessage = ERROR_MESSAGE();
			ROLLBACK;
			RETURN -1
		END CATCH
	END
	
	SELECT Pr.PremiumId,Prod.ProductCode, Prod.ProductName,F.FamilyID, D.DistrictName, W.WardName, V.VillageName, Ins.CHFID, Ins.LastName + ' ' + Ins.OtherNames InsName, 
	Ins.DOB, Ins.IsHead, PL.EnrollDate, Pr.Paydate, Pr.Receipt,CASE WHEN Ins.IsHead = 1 THEN Pr.Amount ELSE 0 END Amount, Payer.PayerName
	FROM tblPremium Pr INNER JOIN tblPolicy PL ON Pr.PolicyID = PL.PolicyID
	INNER JOIN tblProduct Prod ON PL.ProdID = Prod.ProdID
	INNER JOIN tblFamilies F ON PL.FamilyID = F.FamilyID
	INNER JOIN tblVillages V ON V.VillageId = F.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	INNER JOIN tblInsuree Ins ON F.FamilyID = Ins.FamilyID  AND Ins.ValidityTo IS NULL
	LEFT OUTER JOIN tblPayer Payer ON Pr.PayerId = Payer.PayerID 
	WHERE Pr.ReportingId = @ReportingId
	ORDER BY PremiumId DESC, IsHead DESC;

	SET @ErrorMessage = N''

	RETURN 0;

END
GO
