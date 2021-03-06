/****** Object:  StoredProcedure [dbo].[uspRelativeIndexCalculationMonthly]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspRelativeIndexCalculationMonthly]
(
@RelType INT,   --Month = 12 Quarter = 4 Year = 1    
@Period INT,    --M 1--12  Q 1--4  Y --1 
@Year INT,
@LocationId INT = 0,
@ProductID INT = 0,
@AuditUser int = -1,
@RtnStatus as int = 0 OUTPUT
)

AS
BEGIN
	DECLARE @oReturnValue as int 
	SET @oReturnValue = 0 
	BEGIN TRY
	
	DECLARE @MStart as int
	DECLARE @MEnd as int 
	DECLARE @Month as int
	DECLARE @PrdID as int 
	DECLARE @PrdValue as decimal(18,2)
	
	--!!!! Check first if not existing in the meantime !!!!!!!
	
	CREATE TABLE #Numerator (
						LocationId int,
						ProdID int,
						Value decimal(18,2),
						WorkValue bit 
						)
	
	
	--first include the right period for processing
	IF @RelType = 12
	BEGIN
		SET @MStart = @Period 
		SET @MEnd = @Period 
		
	END
	
	IF @RelType = 4
	BEGIN
		IF @Period = 1 
		BEGIN
			SET @MStart = 1 
			SET @MEnd = 3 
		END
		IF @Period = 2 
		BEGIN
			SET @MStart = 4
			SET @MEnd = 6
		END
		IF @Period = 3
		BEGIN
			SET @MStart = 7
			SET @MEnd = 9
		END
		IF @Period = 4
		BEGIN
			SET @MStart = 10
			SET @MEnd = 12
		END
	END
	
	IF @RelType = 1
	BEGIN
		SET @MStart = 1
		SET @MEnd = 12
		
	END
	
	DECLARE @Date date
	DECLARE @DaysInMonth int 
	DECLARE @EndDate date
	
	SET @Month = @MStart 
	WHILE @Month <= @MEnd
	BEGIN
		
		SELECT @Date = CAST(CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + '01' AS DATE)
		SELECT @DaysInMonth = DATEDIFF(DAY,@Date,DATEADD(MONTH,1,@Date))
		SELECT @EndDate = CAST(CONVERT(VARCHAR(4),@Year) + '-' + CONVERT(VARCHAR(2),@Month ) + '-' + CONVERT(VARCHAR(2),@DaysInMonth) AS DATE)

		INSERT INTO #Numerator (LocationId,ProdID,Value,WorkValue ) 
		
		
		--Get all the payment falls under the current month and assign it to Allocated
		
					SELECT NumValue.LocationId, NumValue.ProdID, ISNULL(SUM(NumValue.Allocated),0) Allocated , 1  
		FROM 
		(	
		SELECT L.LocationId  ,Prod.ProdID ,
		CASE 
		WHEN MONTH(DATEADD(D,-1,PL.ExpiryDate)) = @Month AND YEAR(DATEADD(D,-1,PL.ExpiryDate)) = @Year AND (DAY(PL.ExpiryDate)) > 1
			THEN CASE WHEN DATEDIFF(D,CASE WHEN PR.PayDate < @Date THEN @Date ELSE PR.PayDate END,PL.ExpiryDate) = 0 THEN 1 ELSE DATEDIFF(D,CASE WHEN PR.PayDate < @Date THEN @Date ELSE PR.PayDate END,PL.ExpiryDate) END  * ((SUM(PR.Amount))/(CASE WHEN (DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,PL.ExpiryDate)) <= 0 THEN 1 ELSE DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,PL.ExpiryDate) END))
		WHEN MONTH(CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END) = @Month AND YEAR(CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END) = @Year
			THEN ((@DaysInMonth + 1 - DAY(CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END)) * ((SUM(PR.Amount))/CASE WHEN DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,PL.ExpiryDate) <= 0 THEN 1 ELSE DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,PL.ExpiryDate) END)) 
		WHEN PL.EffectiveDate < @Date AND PL.ExpiryDate > @EndDate AND PR.PayDate < @Date
			THEN @DaysInMonth * (SUM(PR.Amount)/CASE WHEN (DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,DATEADD(D,-1,PL.ExpiryDate))) <= 0 THEN 1 ELSE DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,PL.ExpiryDate) END)
		END Allocated
		FROM tblPremium PR INNER JOIN tblPolicy PL ON PR.PolicyID = PL.PolicyID
		INNER JOIN tblProduct Prod ON PL.ProdID = Prod.ProdID 
		LEFT JOIN tblLocations L ON ISNULL(Prod.LocationId,-1) = ISNULL(L.LocationId,-1)
		WHERE PR.ValidityTo IS NULL
		AND PL.ValidityTo IS NULL
		AND Prod.ValidityTo IS  NULL
		AND ISNULL(Prod.LocationId,-1) = ISNULL(@LocationId,-1) 
		AND (Prod.ProdID = @ProductID OR @ProductId = 0)
		AND PL.PolicyStatus <> 1
		AND PR.PayDate <= PL.ExpiryDate
		
		--AND ((MONTH(PR.PayDate) = @Counter OR MONTH(PL.EffectiveDate) = @Counter)
		--	OR (YEAR(PR.PayDate) = @Year OR YEAR(PL.EffectiveDate) = @Year))
		GROUP BY L.LocationId ,Prod.ProdID ,PR.Amount,PR.PayDate,PL.ExpiryDate,PL.EffectiveDate
		) NumValue
		
		GROUP BY LocationId,ProdID
																								
		SET @Month = @Month + 1 
	END
	
	--Now sum up the collected values 
	INSERT INTO #Numerator (LocationId,ProdID,Value,WorkValue) 
			SELECT LocationId, ProdID, ISNULL(SUM(Value),0) Allocated , 0 
			FROM #Numerator GROUP BY LocationId,ProdID
			
	DELETE FROM #Numerator WHERE WorkValue = 1
	
	DECLARE @Test as decimal(18,2)
	--SELECT @Test = SUM(Value) FROM #Numerator WHERE ProdID = 108
	
	
	-- Now fetch the product percentage for relative prices --If not found then assume 1 = 100%
	DECLARE @DistrType as char(1)
	DECLARE @DistrPerc as decimal(18,2)
	DECLARE @ClaimValueItems as decimal(18,2)
	DECLARE @ClaimValueservices as decimal(18,2)
	DECLARE @RelIndex as decimal(18,4)
	--DECLARE @ClaimValueG as decimal(18,2)
	--DECLARE @ClaimValueIP as decimal(18,2)
	--DECLARE @ClaimValueOP as decimal(18,2)
	
	DECLARE PRDLOOP CURSOR LOCAL FORWARD_ONLY FOR SELECT ProdID,Value FROM #Numerator 
	OPEN PRDLOOP
	FETCH NEXT FROM PRDLOOP INTO @PrdID , @PrdValue 
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		
		--IF @PrdID = 108
		--BEGIN
		--	SET @Test = @PrdValue
		--END
		
MonthG:
		IF @RelType = 12
		BEGIN
			--G general 
			SELECT @DistrType = ISNULL(PeriodRelPrices,'') FROM dbo.tblProduct Where ProdID = @PrdID 
			IF @DistrType <> 'M' 
				--SET @DistrPerc = 1
				GOTO MonthIP
			ELSE	
				SELECT @DistrPerc = ISNULL(DistrPerc,1) FROM dbo.tblRelDistr WHERE ProdID = @PrdID AND Period = @Period AND DistrType = @RelType AND DistrCareType = 'B' AND ValidityTo IS NULL
			
			SELECT @ClaimValueItems = ISNULL(SUM(tblClaimItems.PriceValuated),0) 
										FROM tblClaim INNER JOIN
										tblClaimItems ON tblClaim.ClaimID = tblClaimItems.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimItems.ClaimItemStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimItems.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND (ISNULL(MONTH(tblClaim.ProcessStamp) ,-1) = @Period) AND
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimItems.ProdID = @PrdID) --AND (tblHF.HFLevel = 'H') 
			
			SELECT @ClaimValueservices = ISNULL(SUM(tblClaimServices.PriceValuated) ,0)
										FROM tblClaim INNER JOIN
										tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimServices.ClaimServiceStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimServices.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND (ISNULL(MONTH(tblClaim.ProcessStamp) ,-1) = @Period) AND 
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimServices.ProdID = @PrdID) --AND (tblHF.HFLevel = 'H') 
			
			
			IF @ClaimValueItems + @ClaimValueservices = 0 
			BEGIN
				--basically all 100% is available
				SET @RelIndex = 1 
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'B',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END
			ELSE
			BEGIN
				SET @RelIndex = CAST((@PrdValue * @DistrPerc) as Decimal(18,4)) / (@ClaimValueItems + @ClaimValueservices)
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId)
				VALUES (@PrdID,@RelType,'B',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END

MonthIP:			
			--Inpatient
			SELECT @DistrType = ISNULL(PeriodRelPricesIP,'') FROM dbo.tblProduct Where ProdID = @PrdID 
			IF @DistrType <> 'M' 
				--SET @DistrPerc  = 1
				GOTO MonthOP
			ELSE	
				SELECT @DistrPerc  = ISNULL(DistrPerc,1) FROM dbo.tblRelDistr WHERE ProdID = @PrdID AND Period = @Period AND DistrType = @RelType AND DistrCareType = 'I' AND ValidityTo IS NULL
			
			SELECT @ClaimValueItems = ISNULL(SUM(tblClaimItems.PriceValuated),0) 
										FROM tblClaim INNER JOIN
										tblClaimItems ON tblClaim.ClaimID = tblClaimItems.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimItems.ClaimItemStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimItems.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND (ISNULL(MONTH(tblClaim.ProcessStamp) ,-1) = @Period) AND 
										(ISNULL(YEAR(tblClaim.ProcessStamp) , -1) = @Year) AND
										(tblClaimItems.ProdID = @PrdID) AND (tblHF.HFLevel = 'H') 
			 
			SELECT @ClaimValueservices = ISNULL(SUM(tblClaimServices.PriceValuated),0)
										FROM tblClaim INNER JOIN
										tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimServices.ClaimServiceStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimServices.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND (ISNULL(MONTH(tblClaim.ProcessStamp) ,-1) = @Period) AND 
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimServices.ProdID = @PrdID) AND (tblHF.HFLevel = 'H') 
			
			IF @ClaimValueItems + @ClaimValueservices = 0 
			BEGIN
				--basically all 100% is available
				SET @RelIndex = 1 
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'I',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END
			ELSE
			BEGIN
				SET @RelIndex = CAST((@PrdValue * @DistrPerc) as Decimal(18,4))/ (@ClaimValueItems + @ClaimValueservices)
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'I',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END
			
MonthOP:			
			--Outpatient
			SELECT @DistrType = ISNULL(PeriodRelPricesOP,'') FROM dbo.tblProduct Where ProdID = @PrdID 
			IF @DistrType <> 'M' 
				GOTO QuarterG
				--SET @DistrPerc  = 1
			ELSE	
				SELECT @DistrPerc  = ISNULL(DistrPerc,1) FROM dbo.tblRelDistr WHERE ProdID = @PrdID AND Period = @Period AND DistrType = @RelType AND DistrCareType = 'O' AND ValidityTo IS NULL
			
			SELECT @ClaimValueItems = ISNULL(SUM(tblClaimItems.PriceValuated),0)
										FROM tblClaim INNER JOIN
										tblClaimItems ON tblClaim.ClaimID = tblClaimItems.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimItems.ClaimItemStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimItems.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND (ISNULL(MONTH(tblClaim.ProcessStamp) ,-1) = @Period) AND 
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimItems.ProdID = @PrdID) AND (tblHF.HFLevel <> 'H') 

			SELECT @ClaimValueservices = ISNULL(SUM(tblClaimServices.PriceValuated),0)
										FROM tblClaim INNER JOIN
										tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimServices.ClaimServiceStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimServices.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND (ISNULL(MONTH(tblClaim.ProcessStamp) ,-1) = @Period) AND 
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimServices.ProdID = @PrdID) AND (tblHF.HFLevel <> 'H') 
			
			IF @ClaimValueItems + @ClaimValueservices = 0 
			BEGIN
				--basically all 100% is available
				SET @RelIndex = 1 
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'O',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END
			ELSE
			BEGIN
				SET @RelIndex = CAST((@PrdValue * @DistrPerc) as Decimal(18,4)) / (@ClaimValueItems + @ClaimValueservices)
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'O',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END
		END

QuarterG:

		IF @RelType = 4
		BEGIN
			--G general 
			SELECT @DistrType = ISNULL(PeriodRelPrices,'') FROM dbo.tblProduct Where ProdID = @PrdID 
			IF @DistrType <> 'Q' 
				--SET @DistrPerc = 1
				GOTO QuarterIP
			ELSE	
				SELECT @DistrPerc = ISNULL(DistrPerc,1) FROM dbo.tblRelDistr WHERE ProdID = @PrdID AND Period = @Period AND DistrType = @RelType AND DistrCareType = 'B' AND ValidityTo IS NULL
			
			SELECT @ClaimValueItems = ISNULL(SUM(tblClaimItems.PriceValuated),0) 
										FROM tblClaim INNER JOIN
										tblClaimItems ON tblClaim.ClaimID = tblClaimItems.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimItems.ClaimItemStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimItems.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND (ISNULL(MONTH(tblClaim.ProcessStamp) ,-1) Between @MStart AND @MEnd) AND
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimItems.ProdID = @PrdID) --AND (tblHF.HFLevel = 'H') 
			
			SELECT @ClaimValueservices = ISNULL(SUM(tblClaimServices.PriceValuated) ,0)
										FROM tblClaim INNER JOIN
										tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimServices.ClaimServiceStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimServices.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND (ISNULL(MONTH(tblClaim.ProcessStamp) ,-1)  Between @MStart AND @MEnd) AND 
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimServices.ProdID = @PrdID) --AND (tblHF.HFLevel = 'H') 
			
			
			IF @ClaimValueItems + @ClaimValueservices = 0 
			BEGIN
				--basically all 100% is available
				SET @RelIndex = 1 
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'B',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId)
			END
			ELSE
			BEGIN
				SET @RelIndex = CAST( (@PrdValue * @DistrPerc) as decimal(18,4)) / (@ClaimValueItems + @ClaimValueservices)
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'B',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END
QuarterIP:			
			--Inpatient
			SELECT @DistrType = ISNULL(PeriodRelPricesIP,'') FROM dbo.tblProduct Where ProdID = @PrdID 
			IF @DistrType <> 'Q' 
				GOTO QuarterOP
				--SET @DistrPerc  = 1
			ELSE	
				SELECT @DistrPerc  = ISNULL(DistrPerc,1) FROM dbo.tblRelDistr WHERE ProdID = @PrdID AND Period = @Period AND DistrType = @RelType AND DistrCareType = 'I' AND ValidityTo IS NULL
			
			SELECT @ClaimValueItems = ISNULL(SUM(tblClaimItems.PriceValuated),0) 
										FROM tblClaim INNER JOIN
										tblClaimItems ON tblClaim.ClaimID = tblClaimItems.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimItems.ClaimItemStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimItems.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND (ISNULL(MONTH(tblClaim.ProcessStamp) ,-1) Between @MStart AND @MEnd) AND 
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimItems.ProdID = @PrdID) AND (tblHF.HFLevel = 'H') 
			 
			SELECT @ClaimValueservices = ISNULL(SUM(tblClaimServices.PriceValuated),0)
										FROM tblClaim INNER JOIN
										tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimServices.ClaimServiceStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimServices.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND (ISNULL(MONTH(tblClaim.ProcessStamp) ,-1) Between @MStart AND @MEnd) AND 
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimServices.ProdID = @PrdID) AND (tblHF.HFLevel = 'H') 
			
			IF @ClaimValueItems + @ClaimValueservices = 0 
			BEGIN
				--basically all 100% is available
				SET @RelIndex = 1 
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'I',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END
			ELSE
			BEGIN
				SET @RelIndex = CAST((@PrdValue * @DistrPerc) as decimal(18,4)) / (@ClaimValueItems + @ClaimValueservices)
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'I',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END
			
QuarterOP:
			--Outpatient
			SELECT @DistrType = ISNULL(PeriodRelPricesOP,'') FROM dbo.tblProduct Where ProdID = @PrdID 
			IF @DistrType <> 'Q' 
				GOTO YearG
				--SET @DistrPerc  = 1
			ELSE	
				SELECT @DistrPerc  = ISNULL(DistrPerc,1) FROM dbo.tblRelDistr WHERE ProdID = @PrdID AND Period = @Period AND DistrType = @RelType AND DistrCareType = 'O' AND ValidityTo IS NULL
			
			SELECT @ClaimValueItems = ISNULL(SUM(tblClaimItems.PriceValuated),0)
										FROM tblClaim INNER JOIN
										tblClaimItems ON tblClaim.ClaimID = tblClaimItems.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimItems.ClaimItemStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimItems.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND (ISNULL(MONTH(tblClaim.ProcessStamp) ,-1) Between @MStart AND @MEnd) AND 
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimItems.ProdID = @PrdID) AND (tblHF.HFLevel <> 'H') 

			SELECT @ClaimValueservices = ISNULL(SUM(tblClaimServices.PriceValuated),0)
										FROM tblClaim INNER JOIN
										tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimServices.ClaimServiceStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimServices.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND (ISNULL(MONTH(tblClaim.ProcessStamp) ,-1) Between @MStart AND @MEnd) AND 
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimServices.ProdID = @PrdID) AND (tblHF.HFLevel <> 'H') 
			
			IF @ClaimValueItems + @ClaimValueservices = 0 
			BEGIN
				--basically all 100% is available
				SET @RelIndex = 1 
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'O',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END
			ELSE
			BEGIN
				SET @RelIndex = CAST((@PrdValue * @DistrPerc) as decimal(18,4)) / (@ClaimValueItems + @ClaimValueservices)
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'O',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END
		END
		
YearG:
		IF @RelType = 1
		BEGIN
			--G general 
			SELECT @DistrType = ISNULL(PeriodRelPrices,'') FROM dbo.tblProduct Where ProdID = @PrdID 
			IF @DistrType <> 'Y' 
				GOTO YearIP
				--SET @DistrPerc = 1
			ELSE	
				SELECT @DistrPerc = ISNULL(DistrPerc,1) FROM dbo.tblRelDistr WHERE ProdID = @PrdID AND Period = @Period AND DistrType = @RelType AND DistrCareType = 'B' AND ValidityTo IS NULL
			
			SELECT @ClaimValueItems = ISNULL(SUM(tblClaimItems.PriceValuated),0) 
										FROM tblClaim INNER JOIN
										tblClaimItems ON tblClaim.ClaimID = tblClaimItems.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimItems.ClaimItemStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimItems.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimItems.ProdID = @PrdID) --AND (tblHF.HFLevel = 'H') 
			
			SELECT @ClaimValueservices = ISNULL(SUM(tblClaimServices.PriceValuated) ,0)
										FROM tblClaim INNER JOIN
										tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimServices.ClaimServiceStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimServices.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND 
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimServices.ProdID = @PrdID) --AND (tblHF.HFLevel = 'H') 
			
			
			IF @ClaimValueItems + @ClaimValueservices = 0 
			BEGIN
				--basically all 100% is available
				SET @RelIndex = 1 
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'B',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END
			ELSE
			BEGIN
				SET @RelIndex = CAST((@PrdValue * @DistrPerc) as decimal(18,4)) / (@ClaimValueItems + @ClaimValueservices)
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'B',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END
YearIP:			
			--Inpatient
			SELECT @DistrType = ISNULL(PeriodRelPricesIP,'') FROM dbo.tblProduct Where ProdID = @PrdID 
			IF @DistrType <> 'Y' 
				GOTO YearOP
				--SET @DistrPerc  = 1
			ELSE	
				SELECT @DistrPerc  = ISNULL(DistrPerc,1) FROM dbo.tblRelDistr WHERE ProdID = @PrdID AND Period = @Period AND DistrType = @RelType AND DistrCareType = 'I' AND ValidityTo IS NULL
			
			SELECT @ClaimValueItems = ISNULL(SUM(tblClaimItems.PriceValuated),0) 
										FROM tblClaim INNER JOIN
										tblClaimItems ON tblClaim.ClaimID = tblClaimItems.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimItems.ClaimItemStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimItems.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND  
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimItems.ProdID = @PrdID) AND (tblHF.HFLevel = 'H') 
			 
			SELECT @ClaimValueservices = ISNULL(SUM(tblClaimServices.PriceValuated),0)
										FROM tblClaim INNER JOIN
										tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimServices.ClaimServiceStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimServices.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND 
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimServices.ProdID = @PrdID) AND (tblHF.HFLevel = 'H') 
			
			IF @ClaimValueItems + @ClaimValueservices = 0 
			BEGIN
				--basically all 100% is available
				SET @RelIndex = 1 
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'I',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END
			ELSE
			BEGIN
				SET @RelIndex = CAST((@PrdValue * @DistrPerc) as decimal(18,4))/ (@ClaimValueItems + @ClaimValueservices)
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'I',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END
			
YearOP:
			--Outpatient
			SELECT @DistrType = ISNULL(PeriodRelPricesOP,'') FROM dbo.tblProduct Where ProdID = @PrdID 
			IF @DistrType <> 'Y' 
				GOTO NextProduct
				--SET @DistrPerc  = 1
			ELSE	
				SELECT @DistrPerc  = ISNULL(DistrPerc,1) FROM dbo.tblRelDistr WHERE ProdID = @PrdID AND Period = @Period AND DistrType = @RelType AND DistrCareType = 'O' AND ValidityTo IS NULL
			
			SELECT @ClaimValueItems = ISNULL(SUM(tblClaimItems.PriceValuated),0)
										FROM tblClaim INNER JOIN
										tblClaimItems ON tblClaim.ClaimID = tblClaimItems.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimItems.ClaimItemStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimItems.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND 
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimItems.ProdID = @PrdID) AND (tblHF.HFLevel <> 'H') 

			SELECT @ClaimValueservices = ISNULL(SUM(tblClaimServices.PriceValuated),0)
										FROM tblClaim INNER JOIN
										tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID INNER JOIN
										tblHF ON tblClaim.HFID = tblHF.HfID
										WHERE     (tblClaimServices.ClaimServiceStatus = 1) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimServices.ValidityTo IS NULL) AND (tblClaim.ClaimStatus = 16 OR
										tblClaim.ClaimStatus = 8) AND 
										(ISNULL(YEAR(tblClaim.ProcessStamp) ,-1) = @Year) AND
										(tblClaimServices.ProdID = @PrdID) AND (tblHF.HFLevel <> 'H') 
			
			IF @ClaimValueItems + @ClaimValueservices = 0 
			BEGIN
				--basically all 100% is available
				SET @RelIndex = 1 
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'O',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END
			ELSE
			BEGIN
				SET @RelIndex = CAST( (@PrdValue * @DistrPerc) as decimal(18,4)) / (@ClaimValueItems + @ClaimValueservices)
				INSERT INTO [tblRelIndex] ([ProdID],[RelType],[RelCareType],[RelYear],[RelPeriod],[CalcDate],[RelIndex],[AuditUserID],LocationId )
				VALUES (@PrdID,@RelType,'O',@Year,@Period,GETDATE(),@RelIndex,@AuditUser,@LocationId )
			END
		END
		
NextProduct:
		-- GET the total Claim Value 
		
		--Now insert into the relative index table 
		
		FETCH NEXT FROM PRDLOOP INTO @PrdID , @PrdValue
	END
	CLOSE PRDLOOP
	DEALLOCATE PRDLOOP
	
	SET @RtnStatus = 0
FINISH:
	
	RETURN @oReturnValue
	END TRY
	
	BEGIN CATCH
		SELECT 'Unexpected error encountered'
		SET @oReturnValue = 1 
		SET @RtnStatus = 1
		RETURN @oReturnValue
		
	END CATCH
	
END

SET ANSI_NULLS ON

GO
