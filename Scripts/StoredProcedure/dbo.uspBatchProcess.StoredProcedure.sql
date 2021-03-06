/****** Object:  StoredProcedure [dbo].[uspBatchProcess]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspBatchProcess]
	
	@AuditUser as int = 0,
	@LocationId as int, 
	@Period as int,
	@Year as int,
	@RtnStatus as int = 0 OUTPUT 
	
	--@RtnStatus 0=OK --> 1 General fault  --> 2 = Already run before 
AS
BEGIN
	DECLARE @tblClaimIDs TABLE(ClaimID INT)

	IF @LocationId=-1
	BEGIN
	SET @LocationId=NULL
	END

	DECLARE @oReturnValue as INT
	SET @oReturnValue = 0 	
	
	DECLARE @InTopIsolation as bit 
	
	SET @InTopIsolation = -1 
	
	BEGIN TRY 
	
	
	
	IF @@TRANCOUNT = 0 	
		SET @InTopIsolation =0
	ELSE
		SET @InTopIsolation =1
	IF @InTopIsolation = 0
	BEGIN
		--SELECT 'SET ISOLATION TNX ON'
		SET TRANSACTION  ISOLATION LEVEL SERIALIZABLE
		BEGIN TRANSACTION PROCESSCLAIMS
	END

	DECLARE @CLAIMID as INT
	DECLARE @HFLevel as Char(1)
	DECLARE @ProdID as int 
	DECLARE @RP_G as Char(1)
	DECLARE @RP_IP as Char(1)
	DECLARE @RP_OP as Char(1)
	DECLARE @RP_Period as int
	DECLARE @RP_Year as int 
	DECLARE @Index as decimal(18,4)
	
	DECLARE @TargetMonth as int
	DECLARE @TargetQuarter as int
	DECLARE @TargetYear as int
	
	
	SELECT @RP_Period = RunMonth FROM tblBatchRun WHERE RunYear = @Year AND RunMonth = @Period AND ISNULL(LocationId,-1) = ISNULL(@LocationId,-1) AND ValidityTo IS NULL
	
	IF ISNULL(@RP_Period,0) <> 0 
	BEGIN
		SET @oReturnValue = 2 
		SELECT 'Already Run'
		IF @InTopIsolation = 0 ROLLBACK TRANSACTION PROCESSCLAIMS
		RETURN @oReturnValue
	END
	
	
	EXEC @oReturnValue = [uspRelativeIndexCalculationMonthly] 12, @Period, @Year , @LocationId, 0, @AuditUser, @RtnStatus
	
	IF @Period = 3 
		EXEC @oReturnValue = [uspRelativeIndexCalculationMonthly] 4, 1, @Year , @LocationId, 0, @AuditUser, @RtnStatus
	IF @Period = 6 
		EXEC @oReturnValue = [uspRelativeIndexCalculationMonthly] 4, 2, @Year , @LocationId, 0, @AuditUser, @RtnStatus
	IF @Period = 9 
		EXEC @oReturnValue = [uspRelativeIndexCalculationMonthly] 4, 3, @Year , @LocationId, 0, @AuditUser, @RtnStatus
	IF @Period = 12
	BEGIN 
		EXEC @oReturnValue = [uspRelativeIndexCalculationMonthly] 4, 4, @Year , @LocationId, 0, @AuditUser, @RtnStatus
		EXEC @oReturnValue = [uspRelativeIndexCalculationMonthly] 1, 1, @Year , @LocationId, 0, @AuditUser, @RtnStatus
	END
	
	DECLARE PRODUCTLOOPITEMS CURSOR LOCAL FORWARD_ONLY FOR 
					SELECT    tblHF.HFLevel, tblProduct.ProdID, tblProduct.PeriodRelPrices, tblProduct.PeriodRelPricesOP, tblProduct.PeriodRelPricesIP,ISNULL(MONTH(tblClaim.ProcessStamp) ,-1) 
										  AS Period, ISNULL(YEAR(tblClaim.ProcessStamp ), -1) AS [Year]
					FROM         tblClaim INNER JOIN
										  tblClaimItems ON tblClaim.ClaimID = tblClaimItems.ClaimID INNER JOIN
										  tblHF ON tblClaim.HFID = tblHF.HfID INNER JOIN
										  tblProduct ON tblClaimItems.ProdID = tblProduct.ProdID
					WHERE     (tblClaim.ClaimStatus = 8) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimItems.ValidityTo IS NULL) AND (tblClaimItems.ClaimItemStatus = 1) AND 
										  (tblClaimItems.PriceOrigin = 'R') and ISNULL(tblProduct.LocationId,-1) = ISNULL(@LocationId,-1) 
					GROUP BY tblHF.HFLevel, tblProduct.ProdID ,tblProduct.PeriodRelPrices, tblProduct.PeriodRelPricesOP, tblProduct.PeriodRelPricesIP, ISNULL(MONTH(tblClaim.ProcessStamp) ,-1)
										  , ISNULL(YEAR(tblClaim.ProcessStamp ), -1) 

	--DECLARE @Test as decimal(18,2)
	OPEN PRODUCTLOOPITEMS
	FETCH NEXT FROM PRODUCTLOOPITEMS INTO @HFLevel,@ProdID,@RP_G,@RP_OP,@RP_IP,@RP_Period,@RP_Year
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		
		--IF @ProdID = 108 
		--BEGIN
		--	SET @Test = 0
		--END
		
		SET @Index = -1
		--Determine the actual index for this combination 
		SET @TargetMonth = @RP_Period 
		SET @TargetYear = @RP_Year

		IF @RP_Period = 1 or @RP_Period = 2 OR @RP_Period = 3 
			SET @TargetQuarter = 1
		IF @RP_Period = 4 or @RP_Period = 5 OR @RP_Period = 6 
			SET @TargetQuarter = 2
		IF @RP_Period = 7 or @RP_Period = 8 OR @RP_Period = 9 
			SET @TargetQuarter = 3
		IF @RP_Period = 10 or @RP_Period = 11 OR @RP_Period = 12 
			SET @TargetQuarter = 4
		
		
		IF ISNULL(@RP_G,'') <> '' 
		BEGIN
			IF @RP_G = 'M' 
				SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'B' AND RelType = 12 AND RelPeriod = @TargetMonth  AND RelYear = @TargetYear AND ValidityTo IS NULL  
			IF @RP_G = 'Q' 
				SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'B' AND RelType = 4 AND RelPeriod = @TargetQuarter   AND RelYear = @TargetYear AND ValidityTo IS NULL
			IF @RP_G = 'Y' 
				SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'B' AND RelType = 1 AND RelPeriod = 1  AND RelYear = @TargetYear AND ValidityTo IS NULL
				
		END 	
		ELSE
		BEGIN
					
			IF @HFLevel = 'H' AND ISNULL(@RP_IP,'') <> ''
			BEGIN
				IF @RP_IP = 'M' 
					SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'I' AND RelType = 12 AND RelPeriod = @TargetMonth  AND RelYear = @TargetYear AND ValidityTo IS NULL  
				IF @RP_IP = 'Q' 
					SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'I' AND RelType = 4 AND RelPeriod = @TargetQuarter   AND RelYear = @TargetYear AND ValidityTo IS NULL
				IF @RP_IP = 'Y' 
					SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'I' AND RelType = 1 AND RelPeriod = 1  AND RelYear = @TargetYear AND ValidityTo IS NULL
			END
			
			IF @HFLevel <> 'H' AND ISNULL(@RP_OP,'') <> ''
			BEGIN
				IF @RP_OP = 'M' 
					SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'O' AND RelType = 12 AND RelPeriod = @TargetMonth  AND RelYear = @TargetYear AND ValidityTo IS NULL  
				IF @RP_OP = 'Q' 
					SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'O' AND RelType = 4 AND RelPeriod = @TargetQuarter   AND RelYear = @TargetYear AND ValidityTo IS NULL
				IF @RP_OP = 'Y' 
					SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'O' AND RelType = 1 AND RelPeriod = 1  AND RelYear = @TargetYear AND ValidityTo IS NULL
			END
		END
		
		--IF ISNULL(@Index,-1) = -1 
		--	SET @Index = 1   --> set index to use = 1 if no index could be found !
		
			--update claim items
		IF ISNULL(@Index,-1) > -1 
		BEGIN
			--IF @Index > 1 
				--SET @Index = 1   --> simply never pay more than claimed although index is higher than 1
			
			UPDATE tblClaimItems SET RemuneratedAmount = @Index * PriceValuated 
			OUTPUT Deleted.ClaimID into @tblClaimIDs
			FROM         tblClaim INNER JOIN
										  tblClaimItems ON tblClaim.ClaimID = tblClaimItems.ClaimID INNER JOIN
										  tblHF ON tblClaim.HFID = tblHF.HfID INNER JOIN
										  tblProduct ON tblClaimItems.ProdID = tblProduct.ProdID
					WHERE     (tblClaim.ClaimStatus = 8) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimItems.ValidityTo IS NULL) AND (tblClaimItems.ClaimItemStatus = 1) AND 
										  (tblClaimItems.PriceOrigin = 'R') and ISNULL(tblProduct.LocationId,-1) = ISNULL(@LocationId ,-1)
										  AND HFLevel = @HFLevel AND tblProduct.ProdID  = @ProdID 
										  AND ISNULL(MONTH(tblClaim.ProcessStamp) , -1) = @RP_Period
										  AND ISNULL(YEAR(tblClaim.ProcessStamp) , -1) = @RP_Year;


		

		END 
		
		
NextProdItems:
		FETCH NEXT FROM PRODUCTLOOPITEMS INTO @HFLevel,@ProdID,@RP_G,@RP_OP,@RP_IP,@RP_Period,@RP_Year
	END
	CLOSE PRODUCTLOOPITEMS
	DEALLOCATE PRODUCTLOOPITEMS
	
	--NOW RUN SERVICES 

	DECLARE PRODUCTLOOPSERVICES CURSOR LOCAL FORWARD_ONLY FOR 
					SELECT    tblHF.HFLevel, tblProduct.ProdID, tblProduct.PeriodRelPrices, tblProduct.PeriodRelPricesOP, tblProduct.PeriodRelPricesIP, ISNULL(MONTH(tblClaim.ProcessStamp) , -1) 
										  AS Period, ISNULL(YEAR(tblClaim.ProcessStamp), -1) AS [Year]
					FROM         tblClaim INNER JOIN
										  tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID INNER JOIN
										  tblHF ON tblClaim.HFID = tblHF.HfID INNER JOIN
										  tblProduct ON tblClaimServices.ProdID = tblProduct.ProdID
					WHERE     (tblClaim.ClaimStatus = 8) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimServices.ValidityTo IS NULL) AND (tblClaimServices.ClaimServiceStatus = 1) AND 
										  (tblClaimServices.PriceOrigin = 'R') and ISNULL(tblProduct.LocationId,-1) = ISNULL(@LocationId ,-1)
					GROUP BY tblHF.HFLevel, tblProduct.ProdID ,tblProduct.PeriodRelPrices, tblProduct.PeriodRelPricesOP, tblProduct.PeriodRelPricesIP, ISNULL(MONTH(tblClaim.ProcessStamp) , -1) 
										  , ISNULL(YEAR(tblClaim.ProcessStamp), -1)

	OPEN PRODUCTLOOPSERVICES
	FETCH NEXT FROM PRODUCTLOOPSERVICES INTO @HFLevel,@ProdID,@RP_G,@RP_OP,@RP_IP,@RP_Period,@RP_Year
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		--IF @ProdID = 108 
		--BEGIN
		--	SET @Test = 0
		--END
		SET @Index = -1
		--Determine the actual index for this combination 
		SET @TargetMonth = @RP_Period 
		SET @TargetYear = @RP_Year

		IF @RP_Period = 1 or @RP_Period = 2 OR @RP_Period = 3 
			SET @TargetQuarter = 1
		IF @RP_Period = 4 or @RP_Period = 5 OR @RP_Period = 6 
			SET @TargetQuarter = 2
		IF @RP_Period = 7 or @RP_Period = 8 OR @RP_Period = 9 
			SET @TargetQuarter = 3
		IF @RP_Period = 10 or @RP_Period = 11 OR @RP_Period = 12 
			SET @TargetQuarter = 4
		
		
		IF ISNULL(@RP_G,'') <> '' 
		BEGIN
			IF @RP_G = 'M' 
				SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'B' AND RelType = 12 AND RelPeriod = @TargetMonth  AND RelYear = @TargetYear AND ValidityTo IS NULL  
			IF @RP_G = 'Q' 
				SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'B' AND RelType = 4 AND RelPeriod = @TargetQuarter   AND RelYear = @TargetYear AND ValidityTo IS NULL
			IF @RP_G = 'Y' 
				SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'B' AND RelType = 1 AND RelPeriod = 1  AND RelYear = @TargetYear AND ValidityTo IS NULL
					
		END 	
		ELSE
		BEGIN
					
			IF @HFLevel = 'H' AND ISNULL(@RP_IP,'') <> ''
			BEGIN
				IF @RP_IP = 'M' 
					SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'I' AND RelType = 12 AND RelPeriod = @TargetMonth  AND RelYear = @TargetYear AND ValidityTo IS NULL  
				IF @RP_IP = 'Q' 
					SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'I' AND RelType = 4 AND RelPeriod = @TargetQuarter   AND RelYear = @TargetYear AND ValidityTo IS NULL
				IF @RP_IP = 'Y' 
					SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'I' AND RelType = 1 AND RelPeriod = 1  AND RelYear = @TargetYear AND ValidityTo IS NULL
			END
			
			IF @HFLevel <> 'H' AND ISNULL(@RP_OP,'') <> ''
			BEGIN
				IF @RP_OP = 'M' 
					SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'O' AND RelType = 12 AND RelPeriod = @TargetMonth  AND RelYear = @TargetYear AND ValidityTo IS NULL  
				IF @RP_OP = 'Q' 
					SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'O' AND RelType = 4 AND RelPeriod = @TargetQuarter   AND RelYear = @TargetYear AND ValidityTo IS NULL
				IF @RP_OP = 'Y' 
					SELECT @Index = RelIndex FROM dbo.tblRelIndex WHERE ProdID = @ProdID AND RelCareType = 'O' AND RelType = 1 AND RelPeriod = 1  AND RelYear = @TargetYear AND ValidityTo IS NULL
			END
		END
		
		--IF ISNULL(@Index,-1) = -1 
		--	SET @Index = 1   --> set index to use = 1 if no index could be found !
		IF ISNULL(@Index,-1) > -1 
		BEGIN
			
			--IF @Index > 1 
				--SET @Index = 1   --> simply never pay more than claimed altehough index is higher than 1
				
				
			UPDATE tblClaimServices SET RemuneratedAmount = @Index * PriceValuated 
			OUTPUT Deleted.ClaimID into @tblClaimIDs
			FROM         tblClaim INNER JOIN
										  tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID INNER JOIN
										  tblHF ON tblClaim.HFID = tblHF.HfID INNER JOIN
										  tblProduct ON tblClaimServices.ProdID = tblProduct.ProdID
					
					WHERE     (tblClaim.ClaimStatus = 8) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimServices.ValidityTo IS NULL) AND (tblClaimServices.ClaimServiceStatus = 1) AND 
										  (tblClaimServices.PriceOrigin = 'R') and ISNULL(tblProduct.LocationId,-1) = ISNULL(@LocationId , -1)
										  AND HFLevel = @HFLevel AND tblProduct.ProdID  = @ProdID 
										  AND ISNULL(MONTH(tblClaim.ProcessStamp) , -1) = @RP_Period
										  AND ISNULL(YEAR(tblClaim.ProcessStamp) , -1) = @RP_Year;


			
		
		END

NextProdServices:
		FETCH NEXT FROM PRODUCTLOOPSERVICES INTO @HFLevel,@ProdID,@RP_G,@RP_OP,@RP_IP,@RP_Period,@RP_Year
	END
	CLOSE PRODUCTLOOPSERVICES
	DEALLOCATE PRODUCTLOOPSERVICES


	--Get all the claims in valuated state with no Relative index /Services

	INSERT INTO @tblClaimIDs(ClaimID)

	SELECT tblClaim.ClaimId
	FROM  tblClaim 
	INNER JOIN 	tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID 
	INNER JOIN 	tblProduct ON tblClaimServices.ProdID = tblProduct.ProdID
	WHERE (tblClaim.ClaimStatus = 16) 
	AND (tblClaim.ValidityTo IS NULL) 
	AND (tblClaimServices.ValidityTo IS NULL) 
	AND (tblClaimServices.ClaimServiceStatus = 1) 
	AND (tblClaimServices.PriceOrigin <> 'R') 
	and ISNULL(tblProduct.LocationId,-1) = ISNULL(@LocationId ,-1)
	AND tblClaim.RunId IS NULL
	AND ISNULL(MONTH(tblClaim.ProcessStamp) , -1) = @Period
	AND ISNULL(YEAR(tblClaim.ProcessStamp) , -1) = @Year
	GROUP BY tblClaim.ClaimID

	UNION

	SELECT tblClaim.ClaimId
	FROM  tblClaim 
	INNER JOIN 	tblClaimItems ON tblClaim.ClaimID = tblClaimItems.ClaimID 
	INNER JOIN 	tblProduct ON tblClaimItems.ProdID = tblProduct.ProdID
	WHERE (tblClaim.ClaimStatus = 16) 
	AND (tblClaim.ValidityTo IS NULL) 
	AND (tblClaimItems.ValidityTo IS NULL) 
	AND (tblClaimItems.ClaimItemStatus = 1) 
	AND (tblClaimItems.PriceOrigin <> 'R') 
	and ISNULL(tblProduct.LocationId,-1) = ISNULL(@LocationId ,-1)
	AND tblClaim.RunId IS NULL
	AND ISNULL(MONTH(tblClaim.ProcessStamp) , -1) = @Period
	AND ISNULL(YEAR(tblClaim.ProcessStamp) , -1) = @Year
	GROUP BY tblClaim.ClaimID;


	
	--NOW UPDATE the status of all Claims that have all remunerations values updated ==> set to 16
	UPDATE tblClaim SET ClaimStatus = 16 FROM tblClaim 
	INNER JOIN @tblClaimIDs UpdClaims on UpdClaims.ClaimID = tblClaim.ClaimID  WHERE ClaimStatus = 8 AND tblClaim.ValidityTo IS NULL AND
	tblClaim.ClaimID NOT IN 
	(SELECT tblClaim.ClaimID FROM tblClaim INNER JOIN tblClaimItems ON tblClaim.ClaimID = tblClaimItems.ClaimID INNER JOIN tblProduct ON tblClaimItems.ProdID = tblProduct.ProdID 
	 WHERE tblClaim.ValidityTo IS NULL AND ISNULL(LocationId,-1) = ISNULL(@LocationId,-1) AND tblClaimItems.RemuneratedAmount IS NULL AND tblClaim.ClaimStatus = 8 AND tblClaimItems.ValidityTo IS NULL
	 AND tblClaimItems.ClaimItemStatus = 1
	 GROUP BY tblClaim.ClaimID 
	)
	AND 
	tblClaim.ClaimID NOT IN 
	(SELECT tblClaim.ClaimID FROM tblClaim
	INNER JOIN tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID 
	INNER JOIN tblProduct  ON tblClaimServices.ProdID = tblProduct.ProdID  
	 WHERE tblClaim.ValidityTo IS NULL AND ISNULL(LocationId,-1) = ISNULL(@LocationId,-1) AND tblClaimServices.RemuneratedAmount IS NULL AND tblClaim.ClaimStatus = 8 AND tblClaimServices.ValidityTo IS NULL
	 AND tblClaimServices.ClaimServiceStatus  = 1
	 GROUP BY tblClaim.ClaimID  
	)
	
	--NOW insert a new batch run record and keep latest ID in memory
	INSERT INTO tblBatchRun
           ([LocationId],[RunYear],[RunMonth],[RunDate],[AuditUserID])
    VALUES (@LocationId ,@Year, @Period , GETDATE() ,@AuditUser )
    
    DECLARE @RunID as int
    
    SELECT @RunID = SCOPE_IDENTITY ()
    
	DECLARE @MStart as INT  = 0 
	DECLARE @MEnd as INT = 0 

	
	IF @Period = 3 
	BEGIN
		SET @MStart = 1 
		SET @MEnd = 3 
	END
	IF @Period = 6 
	BEGIN
		SET @MStart = 4
		SET @MEnd = 6
	END
	IF @Period = 9
	BEGIN
		SET @MStart = 7
		SET @MEnd = 9
	END
	IF @Period = 12
	BEGIN
		SET @MStart = 1
		SET @MEnd = 12
	END
	
	
	


	UPDATE tblClaim SET RunID = @RunID FROM tblClaim inner join @tblClaimIDs UpdClaims on UpdClaims.ClaimID = tblClaim.ClaimID
    WHERE tblClaim.ValidityTo IS NULL AND ClaimStatus = 16 AND RunID IS NULL AND ISNULL(MONTH(tblClaim.ProcessStamp) , -1) = @Period
										  AND ISNULL(YEAR(tblClaim.ProcessStamp) , -1) = @Year

	IF @MStart > 0 
	BEGIN
		-- we are running multiple batches e.g Quarterly or Yearly
		UPDATE tblClaim SET RunID = @RunID FROM tblClaim inner join @tblClaimIDs UpdClaims on UpdClaims.ClaimID = tblClaim.ClaimID
		WHERE tblClaim.ValidityTo IS NULL AND ClaimStatus = 16 AND RunID IS NULL AND (ISNULL(MONTH(tblClaim.ProcessStamp) , -1) BETWEEN @MStart  AND @MEnd )  AND ISNULL(YEAR(tblClaim.ProcessStamp) , -1) = @Year
	END
	
FINISH:
	IF @InTopIsolation = 0 COMMIT TRANSACTION PROCESSCLAIMS
	SET @oReturnValue = 0 
	RETURN @oReturnValue

	END TRY
	BEGIN CATCH
		SET @oReturnValue = 1 
		SELECT ERROR_MESSAGE () as ErrorMessage
		IF @InTopIsolation = 0 ROLLBACK TRANSACTION PROCESSCLAIMS
		RETURN @oReturnValue
		
	END CATCH
	
ERR_HANDLER:

	SELECT ERROR_MESSAGE () as ErrorMessage
	IF @InTopIsolation = 0 ROLLBACK TRANSACTION PROCESSCLAIMS
	RETURN @oReturnValue

	
END
GO
