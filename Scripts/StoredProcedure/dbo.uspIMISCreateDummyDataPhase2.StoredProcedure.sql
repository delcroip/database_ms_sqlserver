/****** Object:  StoredProcedure [dbo].[uspIMISCreateDummyDataPhase2]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Batch submitted through debugger: SQLQuery11.sql|7|0|C:\Users\Hans2\AppData\Local\Temp\~vsF4E7.sql
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspIMISCreateDummyDataPhase2]
	-- Add the parameters for the stored procedure here
	
	@ICDCount int = 500,
	@BatchCountPerHF int = 52,
	@ClaimsPerBatch int = 200,
	@InPatientClaimsOneinX int = 15, 
	@ItemsinClaim int = 2,
	@ServicesinClaim int = 2,
	@CurrentUserID int = 1

	

AS
BEGIN
	SET NOCOUNT ON;
	
	
	DECLARE @Counter1 int
	DECLARE @Counter2 int
	DECLARE @Counter3 int
	DECLARE @Counter4 int
	DECLARE @DUMMYCODE1 as nvarchar(25)
	DECLARE @DUMMYCODE2 as nvarchar(25)		
	DECLARE @ID1 int
	
	DECLARE @BatchDate as Date
	DECLARE @BatchStatus int
	DECLARE @BatchID as int 
	
	SET @Counter1 = 1
	WHILE @Counter1 <= @ICDCount 
	BEGIN
		INSERT INTO [dbo].[tblICDCodes]
           ([ICDCode]
           ,[ICDName]
           ,[AuditUserID])
	    VALUES
           (RIGHT ('00000' + CAST(@Counter1 as nvarchar(6)) ,6)
           ,'Disease Code ' + CAST(@Counter1 as nvarchar(6))
           ,@CurrentUserID
           )

		SET @Counter1 = @Counter1 + 1
	END
	DECLARE @ArBatchStatus TABLE (Stat int)
	INSERT INTO @ArBatchStatus VALUES (2)
	INSERT INTO @ArBatchStatus VALUES (4)
	INSERT INTO @ArBatchStatus VALUES (8)
	INSERT INTO @ArBatchStatus VALUES (16)
	
	DECLARE LOOP1 CURSOR LOCAL FORWARD_ONLY FOR SELECT HFID FROM tblHF
	OPEN LOOP1
	FETCH NEXT FROM LOOP1 INTO @ID1
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Counter1 = 1
		WHILE @Counter1 <= @BatchCountPerHF 
		BEGIN
			SELECT TOP 1 @BatchStatus = Stat FROM @ArBatchStatus ORDER BY NewID()
			
			INSERT INTO [dbo].[tblBatch]
           ([BatchCode]
           ,[HfID]
           ,[PeriodFrom]
           ,[PeriodTo]
           ,[BatchStatus]
           ,[ReviewVariance]
           ,[ReviewValue]
           ,[ReviewRandom]
           ,[FeedbackVariance]
           ,[FeedbackValue]
           ,[FeedbackRandom]
           ,[BatchDate]
           ,[AuditUserID])
		   VALUES
           (RIGHT ('0000000' + CAST(@Counter1 as nvarchar(8)) ,8)
           ,@ID1
           ,DATEADD (dd,-@Counter1,GETDATE())
           ,DATEADD (dd,-@Counter1,GETDATE())
           ,@BatchStatus
           ,0
           ,40000
           ,0
           ,0
           ,40000
           ,0
           ,DATEADD (dd,-@Counter1,GETDATE())
           ,@CurrentUserID)
         	SET @Counter1 = @Counter1 + 1
		END	
		FETCH NEXT FROM LOOP1 INTO @ID1
	END
	
	UPDATE tblbatch SET BatchSubmissionDate = BatchDate WHERE BatchStatus > 2 
	
	CLOSE LOOP1
	DEALLOCATE LOOP1
	
	
	DECLARE @DistrictID as int 
	DECLARE @HFCode as nvarchar(100)
	DECLARE @HFID as int 
	DECLARE @PriceListItemsID as int 
	DECLARE @PriceListServicesID as int 
	DECLARE @ICD as int 
	DECLARE @InsureeID as int 
	DECLARE @FamilyID as int 

	DECLARE @DateTo as date 
	DECLARE @DateFrom as date 
	DECLARE @HFLevel as CHAR(1)
	DECLARE LOOP1 CURSOR LOCAL FORWARD_ONLY FOR SELECT BatchID ,BatchStatus, BatchDate, HFId FROM dbo.tblBatch
	OPEN LOOP1
	FETCH NEXT FROM LOOP1 INTO @BatchID ,@BatchStatus, @BatchDate, @HFID 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @HFCode = HFCode FROM tblHF WHERE HfID = @HFID 
		SELECT @HFLevel = HFLevel FROM tblHF WHERE HfID = @HFID 
		SELECT @DistrictID = DistrictID FROM tblHF WHERE HfID = @HFID 
		
		SET @Counter1 = 1
		SET @Counter2 = 1
		WHILE @Counter1 <= @ClaimsPerBatch 
		BEGIN
			SELECT TOP 1 @ICD = ICDID FROM dbo.tblICDCodes ORDER BY NewID()
			SELECT TOP 1 @FamilyID = tblFamilies.FamilyID FROM tblFamilies INNER JOIN tblPolicy ON tblPolicy.FamilyID = tblFamilies.FamilyID WHERE DistrictID = @DistrictID AND @BatchDate between StartDate AND ExpiryDate ORDER BY NewID()
			SELECT TOP 1 @InsureeID = InsureeID FROM dbo.tblInsuree WHERE FamilyID = @FamilyID ORDER BY NewID()
			IF ISNULL(@InsureeID,0) = 0 
			BEGIN
				--no insuree could be found with a valid policy for this period 
				SELECT TOP 1 @InsureeID = InsureeID FROM dbo.tblInsuree ORDER BY NewID()
			END
			
			If @Counter2 = @InPatientClaimsOneinX AND @HFLevel = 'H'
			BEGIN
				
				SET @Counter2 = 1
				SET @DateFrom = DATEADD(ww  ,-1, @BatchDate)
				SET @Dateto = @BatchDate
			END
			ELSE
			BEGIN
				
				SET @DateFrom = @BatchDate
				SET @DateTo  = NULL
			END
			
				
			INSERT INTO [dbo].[tblClaim]
			   ([InsureeID]
			   ,[BatchID]
			   ,[ClaimCode]
			   ,[DateFrom]
			   ,[DateTo]
			   ,[ICDID]
			 
			   ,[ClaimStatus]
			   ,[DateClaimed]
			   ,[Explanation]
			   ,[AuditUserID])
			VALUES
			   (@InsureeID
			   ,@BatchID
			   ,RIGHT ('0000000' + CAST(@Counter1 as nvarchar(8)) ,8)
			   ,@DateFrom
			   ,@DateTo
			   ,@ICD
	
			   ,2
			   ,@BatchDate
			   ,'Claim ' + RIGHT ('0000000' + CAST(@Counter1 as nvarchar(8)) ,8) + ' from HF: ' +  @HFCode  
			   ,@CurrentUserID)
				
			SET @Counter1 = @Counter1 + 1
			SET @Counter2 = @Counter2 + 1
		END
		FETCH NEXT FROM LOOP1 INTO @BatchID ,@BatchStatus, @BatchDate, @HFID 
	END
	CLOSE LOOP1
	DEALLOCATE LOOP1
	
	--Now change the statusses of the claims 
	DECLARE @ClaimID as int 
	DECLARE @ProductID as int 
	DECLARE @ClaimDate as date 
	DECLARE @ItemID as int 
	DECLARE @ItemValue as decimal(18,2)
	DECLARE @ServiceID as int 
	DECLARE @ServiceValue as decimal(18,2)
	DECLARE LOOP1 CURSOR LOCAL FORWARD_ONLY FOR SELECT ClaimID ,InsureeID, DateClaimed, HFId FROM dbo.tblClaim INNER JOIN TblBatch ON TblBatch.BatchID = TblClaim.BatchID 
	OPEN LOOP1
	FETCH NEXT FROM LOOP1 INTO @ClaimID, @InsureeID , @ClaimDate, @HFID 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @FamilyID = FamilyID FROM tblInsuree Where InsureeID = @InsureeID 
		SELECT @PriceListItemsID = PLItemID FROM tblHF WHERE HfID = @HFID 
		SELECT @PriceListServicesID = PLServiceID FROM tblHF WHERE HfID = @HFID 
		SELECT TOP 1 @ProductID = ProdID FROm tblPolicy WHERE FamilyID = @FamilyID AND @ClaimDate Between StartDate AND ExpiryDate
		IF ISNULL(@ProductID,0) = 0 
		BEGIN
			SELECT TOP 1 @ProductID = ProdID FROm tblPolicy WHERE FamilyID = @FamilyID
		END
		--now insert claim items 
		SET @Counter1 = 1
		WHILE @Counter1 <= @ItemsinClaim 
		BEGIN
			SELECT TOP 1 @ItemID = ItemID FROM dbo.tblPLItemsDetail WHERE PLItemID = @PriceListItemsID ORDER BY NewID()
			-- we do not look at the overule price for now
			SELECT @ItemValue = ItemPrice FROM tblItems WHERE ItemID = @ItemID
			INSERT INTO [dbo].[tblClaimItems]
			   ([ClaimID]
			   ,[ItemID]
			   ,[ProdID]
			   ,[ClaimItemStatus]
			   ,[Availability]
			   ,[QtyProvided]
			   ,[PriceAsked]
			   ,[AuditUserID]
			   )
		   VALUES
			   (@ClaimID
			   ,@ItemID
			   ,@ProductID 
			   ,1
			   ,1
			   ,Cast(((5 + 1) - 1) * Rand() + 1 As tinyint)
			   ,@ItemValue
			   ,@CurrentUserID
			   )
			SET @Counter1 = @Counter1 + 1 
		END
		
		--now insert claim services 
		SET @Counter1 = 1
		WHILE @Counter1 <= @ServicesinClaim 
		BEGIN
			SELECT TOP 1 @ServiceID = ServiceID FROM dbo.tblPLServicesDetail  WHERE PLServiceID = @PriceListServicesID  ORDER BY NewID()
			-- we do not look at the overule price for now
			SELECT @ServiceValue = ServPrice FROM tblServices  WHERE ServiceID = @ServiceID
			INSERT INTO [dbo].[tblClaimServices] 
			   ([ClaimID]
			   ,[ServiceID]
			   ,[ProdID]
			   ,[ClaimServiceStatus] 
			   ,[QtyProvided]
			   ,[PriceAsked]
			   ,[AuditUserID]
			   )
		   VALUES
			   (@ClaimID
			   ,@ServiceID
			   ,@ProductID 
			   ,1
			   ,Cast(((5 + 1) - 1) * Rand() + 1 As tinyint)
			   ,@ServiceValue
			   ,@CurrentUserID
			   )
			SET @Counter1 = @Counter1 + 1 
		END
		
		FETCH NEXT FROM LOOP1 INTO @ClaimID, @InsureeID , @ClaimDate, @HFID 
	END
	CLOSE LOOP1
	DEALLOCATE LOOP1
	
	
END

GO
