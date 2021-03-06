/****** Object:  StoredProcedure [dbo].[uspProcessSingleClaimStep2]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspProcessSingleClaimStep2]
	
	@AuditUser as int = 0,
	@ClaimID as int,
	@InsureeID as int,
	@HFLevel as Char(1),   --check later with Jiri --> will not be used anymore
	@RowID as int = 0,
	@AdultChild as Char(1),
	@Hospitalization as BIT,
	@IsProcess as BIT = 1,
	@RtnStatus as int = 0 OUTPUT
	
		
	/*
	Rejection reasons:
	0 = NOT REJECTED
	1 = Item/Service not in Registers
	2 = Item/Service not in HF Pricelist 
	3 = Item/Service not in Covering Product
	4 = Item/Service Limitation Fail
	5 = Item/Service Frequency Fail
	6 = Item/Service DUPLICATD
	7 = CHFID Not valid / Family Not Valid 
	8 = ICD Code not in current ICD list 
	9 = Target date provision invalid
	10= Care type not consistant with Facility 
	11=
	12=
	*/
	
AS
BEGIN
	
	DECLARE @oReturnValue as int
	SET @oReturnValue = 0 
		
	DECLARE @ProductID as int   
	DECLARE @PolicyID as int 
	DECLARE @Ceiling as decimal(18,2)
	DECLARE @Deductable as decimal(18,2)
	DECLARE @PrevDeducted as Decimal(18,2)
	DECLARE @Deducted as decimal(18,2)
	DECLARE @PrevRemunerated as decimal(18,2)
	DECLARE @Remunerated as decimal(18,2)
	
	DECLARE @DeductableType as Char(1)
	DECLARE @CeilingType as Char(1)
	
	DECLARE @ClaimItemID as int 
	DECLARE @ClaimServiceID as int
	DECLARE @PriceAsked as decimal(18,2)
	DECLARE @PriceApproved as decimal(18,2)
	DECLARE @PriceAdjusted as decimal(18,2)
	DECLARE @PLPrice as decimal(18,2)
	DECLARE @PriceOrigin as Char(1)
	DECLARE @Limitation as Char(1)
	DECLARE @Limitationvalue as Decimal(18,2)
	DECLARE @ItemQty as decimal(18,2)
	DECLARE @ServiceQty as decimal(18,2)
	DECLARE @QtyProvided as decimal(18,2) 
	DECLARE @QtyApproved as decimal(18,2)
	DECLARE @SetPriceValuated as decimal(18,2)
	DECLARE @SetPriceAdjusted as decimal(18,2)
	DECLARE @SetPriceRemunerated as decimal(18,2)
	DECLARE @SetPriceDeducted as decimal(18,2)	
	DECLARE @ExceedCeilingAmount as decimal(18,2)
	
	DECLARE @ExceedCeilingAmountCategory as decimal(18,2)
	

	DECLARE @WorkValue as decimal(18,2)
	--declare all ceilings and deductables from the cursor on product
	DECLARE @DedInsuree as decimal(18,2) 
	DECLARE @DedOPInsuree as decimal(18,2) 
	DECLARE @DedIPInsuree as decimal(18,2) 
	DECLARE @MaxInsuree as decimal(18,2)  
	DECLARE @MaxOPInsuree as decimal(18,2) 
	DECLARE @MaxIPInsuree as decimal(18,2) 
	DECLARE @DedTreatment as decimal(18,2)  
	DECLARE @DedOPTreatment as decimal(18,2)  
	DECLARE @DedIPTreatment as decimal(18,2)  
	DECLARE @MaxIPTreatment as decimal(18,2) 
	DECLARE @MaxTreatment as decimal(18,2) 
	DECLARE @MaxOPTreatment as decimal(18,2) 
	DECLARE @DedPolicy as decimal(18,2) 
	DECLARE @DedOPPolicy as decimal(18,2) 
	DECLARE @DedIPPolicy as decimal(18,2) 
	DECLARE @MaxPolicy as decimal(18,2) 
	DECLARE @MaxOPPolicy as decimal(18,2) 
	DECLARE @MaxIPPolicy as decimal(18,2) 
	
	DECLARE @CeilingConsult as Decimal(18,2) = 0 
	DECLARE @CeilingSurgery as Decimal(18,2) = 0 
	DECLARE @CeilingHospitalization as Decimal(18,2) = 0 
	DECLARE @CeilingDelivery as Decimal(18,2) = 0 
	DECLARE @CeilingAntenatal as decimal(18,2) =0 

	DECLARE @PrevRemuneratedConsult as decimal(18,2) = 0 
	DECLARE @PrevRemuneratedSurgery as decimal(18,2) = 0 
	DECLARE @PrevRemuneratedHospitalization as decimal(18,2) = 0 
	DECLARE @PrevRemuneratedDelivery as decimal(18,2) = 0 
	DECLARE @PrevRemuneratedAntenatal as decimal(18,2) = 0 

	DECLARE @RemuneratedConsult as decimal(18,2) = 0 
	DECLARE @RemuneratedSurgery as decimal(18,2) = 0 
	DECLARE @RemuneratedHospitalization as decimal(18,2) = 0 
	DECLARE @RemuneratedDelivery as decimal(18,2) = 0 
	DECLARE @RemuneratedAntenatal as decimal(18,2) = 0

	DECLARE @Treshold as INT
	DECLARE @MaxPolicyExtraMember decimal(18,2) = 0 
	DECLARE @MaxPolicyExtraMemberIP decimal(18,2) = 0 
	DECLARE @MaxPolicyExtraMemberOP decimal(18,2) = 0 
	DECLARE @MaxCeilingPolicy decimal (18,2) = 0 
	DECLARE @MaxCeilingPolicyIP decimal (18,2) = 0 
	DECLARE @MaxCeilingPolicyOP decimal (18,2) = 0 
	
	DECLARE @ServCategory as CHAR
	DECLARE @ClaimDateFrom as datetime
	DECLARE @ClaimDateTo as datetime
	

	DECLARE @RelativePrices as int = 0 
	DECLARE @PolicyMembers as int = 0 
	
	DECLARE @BaseCategory as CHAR(1)  = 'V'
	DECLARE @CeilingInterpretation as Char

	BEGIN TRY 
	
	--check first if this is a hospital claim falling under the hospitalization category
	--check first if this is a hospital claim falling under the hospitalization category
	
	-- S = Surgery
	-- D = Delivery
	-- A = Antenatal care
	-- H = Hospitalization
	-- C = Consultation
	-- O = Other
	-- V = Visit 

	SELECT @ClaimDateFrom = DateFrom,  @ClaimDateTo = DateTo FROM tblClaim Where ClaimID = @ClaimID 

	IF  EXISTS (SELECT tblClaimServices.ClaimServiceID FROM tblClaim INNER JOIN tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID INNER JOIN tblServices ON tblClaimServices.ServiceID = tblServices.ServiceID
		WHERE        (tblClaim.ClaimID = @ClaimID) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimServices.ValidityTo IS NULL) AND (tblServices.ServCategory = 'S') AND 
							 (tblServices.ValidityTo IS NULL))
	BEGIN
		SET @BaseCategory = 'S'
	END
	ELSE
	BEGIN
		IF  EXISTS (SELECT tblClaimServices.ClaimServiceID FROM tblClaim INNER JOIN tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID INNER JOIN tblServices ON tblClaimServices.ServiceID = tblServices.ServiceID
		WHERE        (tblClaim.ClaimID = @ClaimID) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimServices.ValidityTo IS NULL) AND (tblServices.ServCategory = 'D') AND 
							 (tblServices.ValidityTo IS NULL))
		BEGIN
			SET @BaseCategory = 'D'
		END
		ELSE
		BEGIN
			IF  EXISTS (SELECT tblClaimServices.ClaimServiceID FROM tblClaim INNER JOIN tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID INNER JOIN tblServices ON tblClaimServices.ServiceID = tblServices.ServiceID
			WHERE        (tblClaim.ClaimID = @ClaimID) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimServices.ValidityTo IS NULL) AND (tblServices.ServCategory = 'A') AND 
								 (tblServices.ValidityTo IS NULL))
			BEGIN
				SET @BaseCategory = 'A'
			END
			ELSE
			BEGIN
				
				
				IF ISNULL(@ClaimDateTo,@ClaimDateFrom) <> @ClaimDateFrom 
				BEGIN
					SET @BaseCategory = 'H'
				END
				ELSE
				BEGIN
					IF  EXISTS (SELECT tblClaimServices.ClaimServiceID FROM tblClaim INNER JOIN tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID INNER JOIN tblServices ON tblClaimServices.ServiceID = tblServices.ServiceID
					WHERE        (tblClaim.ClaimID = @ClaimID) AND (tblClaim.ValidityTo IS NULL) AND (tblClaimServices.ValidityTo IS NULL) AND (tblServices.ServCategory = 'C') AND 
										 (tblServices.ValidityTo IS NULL))
					BEGIN
						SET @BaseCategory = 'C'
					END
					ELSE
					BEGIN
						SET @BaseCategory = 'V'
					END
				END
			END
		END
	END

	/*PREPARE HISTORIC TABLE WITh RELEVANT ITEMS AND SERVICES*/

	DECLARE @TargetDate as Date

	
	SELECT @TargetDate = ISNULL(TblClaim.DateTo,TblClaim.DateFrom) FROM TblClaim WHERE ClaimID = @ClaimID 

	DECLARE @FamilyID INT 
	SELECT @FamilyID = FamilyID from tblInsuree where InsureeID = @InsureeID 
	


	DECLARE  @DTBL_ITEMS TABLE (
							[ItemID] [int] NOT NULL,
							[ItemCode] [nvarchar](6) NOT NULL,
							[ItemType] [char](1) NOT NULL,
							[ItemPrice] [decimal](18, 2) NOT NULL,
							[ItemCareType] [char](1) NOT NULL,
							[ItemFrequency] [smallint] NULL,
							[ItemPatCat] [tinyint] NOT NULL
							)

	INSERT INTO @DTBL_ITEMS (ItemID , ItemCode, ItemType , ItemPrice, ItemCaretype ,ItemFrequency, ItemPatCat) 
	SELECT ItemID , ItemCode, ItemType , ItemPrice, ItemCaretype ,ItemFrequency, ItemPatCat FROM 
	(SELECT  ROW_NUMBER() OVER(PARTITION BY ItemId ORDER BY ValidityFrom DESC)RNo,AllItems.* FROM
	(
	SELECT Sub1.* FROM
	(
	SELECT ItemID , ItemCode, ItemType , ItemPrice, ItemCaretype ,ItemFrequency, ItemPatCat , ValidityFrom, ValidityTo, LegacyID from tblitems Where (ValidityTo IS NULL) OR ((NOT ValidityTo IS NULL) AND (LegacyID IS NULL))
	UNION ALL
	SELECT  LegacyID as ItemID , ItemCode, ItemType , ItemPrice, ItemCaretype ,ItemFrequency, ItemPatCat , ValidityFrom,ValidityTo, LegacyID  FROM tblItems Where  (NOT ValidityTo IS NULL) AND (NOT LegacyID IS NULL)
	
	) Sub1
	INNER JOIN 
	(
	SELECT        tblClaimItems.ItemID
	FROM            tblClaimItems 
	WHERE        (tblClaimItems.ValidityTo IS NULL) AND tblClaimItems.ClaimID = @ClaimID
	) Sub2 ON Sub1.ItemID = Sub2.ItemID 
	)  AllItems 
	WHERE CONVERT(date,ValidityFrom,103) <= @TargetDate 
	)Result
	WHERE Rno = 1 AND ((ValidityTo IS NULL) OR (NOT ValidityTo IS NULL AND NOT LegacyID IS NULL ))  	



	DECLARE  @DTBL_SERVICES TABLE (
							[ServiceID] [int] NOT NULL,
							[ServCode] [nvarchar](6) NOT NULL,
							[ServType] [char](1) NOT NULL,
							[ServLevel] [char](1) NOT NULL,
							[ServPrice] [decimal](18, 2) NOT NULL,
							[ServCareType] [char](1) NOT NULL,
							[ServFrequency] [smallint] NULL,
							[ServPatCat] [tinyint] NOT NULL,
							[ServCategory] [char](1) NULL
							)

	INSERT INTO @DTBL_SERVICES (ServiceID , ServCode, ServType , ServLevel, ServPrice, ServCaretype ,ServFrequency, ServPatCat, ServCategory ) 
	SELECT ServiceID , ServCode, ServType , ServLevel ,ServPrice, ServCaretype ,ServFrequency, ServPatCat,ServCategory FROM 
	(SELECT  ROW_NUMBER() OVER(PARTITION BY ServiceId ORDER BY ValidityFrom DESC)RNo,AllServices.* FROM
	(
	SELECT Sub1.* FROM
	(
	SELECT ServiceID , ServCode, ServType , ServLevel  ,ServPrice, ServCaretype ,ServFrequency, ServPatCat , ServCategory ,ValidityFrom, ValidityTo, LegacyID from tblServices WHere (ValidityTo IS NULL) OR ((NOT ValidityTo IS NULL) AND (LegacyID IS NULL))
	UNION ALL
	SELECT  LegacyID as ServiceID , ServCode, ServType , ServLevel  ,ServPrice, ServCaretype ,ServFrequency, ServPatCat , ServCategory , ValidityFrom, ValidityTo, LegacyID FROM tblServices Where  (NOT ValidityTo IS NULL) AND (NOT LegacyID IS NULL)
	) Sub1
	INNER JOIN 
	(
	SELECT        tblClaimServices.ServiceID 
	FROM            tblClaim INNER JOIN
							 tblClaimServices ON tblClaim.ClaimID = tblClaimServices.ClaimID
	WHERE        (tblClaimServices.ValidityTo IS NULL) AND tblClaim.ClaimID = @ClaimID
	) Sub2 ON Sub1.ServiceID = Sub2.ServiceID 
	)  AllServices 
	WHERE CONVERT(date,ValidityFrom,103) <= @TargetDate
	)Result
	WHERE Rno = 1 AND ((ValidityTo IS NULL) OR (NOT ValidityTo IS NULL AND NOT LegacyID IS NULL ))  
	
	DECLARE PRODUCTLOOP CURSOR LOCAL FORWARD_ONLY FOR	
													SELECT Policies.ProdID, Policies.PolicyID,	ISNULL(DedInsuree,0), ISNULL(DedOPInsuree,0), ISNULL(DedIPInsuree,0), ISNULL(MaxInsuree,0), ISNULL(MaxOPInsuree,0), 
																								ISNULL(MaxIPInsuree,0), ISNULL(DedTreatment,0), ISNULL(DedOPTreatment,0), ISNULL(DedIPTreatment,0), ISNULL(MaxIPTreatment,0), 
																								ISNULL(MaxTreatment,0), ISNULL(MaxOPTreatment,0), ISNULL(DedPolicy,0), ISNULL(DedOPPolicy,0), ISNULL(DedIPPolicy,0), 
																								ISNULL(MaxPolicy,0), ISNULL(MaxOPPolicy,0) , ISNULL(MaxIPPolicy,0),ISNULL(MaxAmountConsultation ,0),ISNULL(MaxAmountSurgery,0),ISNULL(MaxAmountHospitalization ,0),ISNULL(MaxAmountDelivery ,0), ISNULL(MaxAmountAntenatal  ,0),
																								ISNULL(Threshold,0), ISNULL(MaxPolicyExtraMember,0),ISNULL(MaxPolicyExtraMemberIP,0),ISNULL(MaxPolicyExtraMemberOP,0),ISNULL(MaxCeilingPolicy,0),ISNULL(MaxCeilingPolicyIP,0),ISNULL(MaxCeilingPolicyOP,0), ISNULL(CeilingInterpretation,'I')
																		  FROM 
													(
													SELECT     tblClaimItems.ProdID, tblClaimItems.PolicyID
													FROM         tblClaimItems INNER JOIN
																		  @DTBL_ITEMS Items ON tblClaimItems.ItemID = Items.ItemID
													WHERE     (tblClaimItems.ClaimID = @ClaimID) AND (tblClaimItems.ValidityTo IS NULL) AND (tblClaimItems.RejectionReason = 0)
																										
													UNION 
													SELECT     tblClaimServices.ProdID, tblClaimServices.PolicyID
													FROM         tblClaimServices INNER JOIN
																		  @DTBL_SERVICES Serv ON tblClaimServices.ServiceID = Serv.ServiceID
													WHERE     (tblClaimServices.ClaimID = @ClaimID) AND (tblClaimServices.ValidityTo IS NULL) AND (tblClaimServices.RejectionReason = 0)
													) Policies 
													INNER JOIN 
													(
													SELECT     ProdID, DedInsuree, DedOPInsuree, DedIPInsuree, MaxInsuree, MaxOPInsuree, MaxIPInsuree, DedTreatment, DedOPTreatment, DedIPTreatment, MaxIPTreatment, 
																MaxTreatment, MaxOPTreatment, DedPolicy, DedOPPolicy, DedIPPolicy, MaxPolicy, MaxOPPolicy, MaxIPPolicy, MaxAmountConsultation ,MaxAmountSurgery ,MaxAmountHospitalization ,MaxAmountDelivery , MaxAmountAntenatal,
																Threshold, MaxPolicyExtraMember , MaxPolicyExtraMemberIP , MaxPolicyExtraMemberOP, MaxCeilingPolicy, MaxCeilingPolicyIP ,MaxCeilingPolicyOP ,ValidityTo, CeilingInterpretation  FROM tblProduct
													WHERE     (ValidityTo IS NULL)
													) Product ON Product.ProdID = Policies.ProdID
													
	OPEN PRODUCTLOOP
	FETCH NEXT FROM PRODUCTLOOP INTO	@ProductID, @PolicyID,@DedInsuree,@DedOPInsuree,@DedIPInsuree,@MaxInsuree,@MaxOPInsuree,@MaxIPInsuree,@DedTreatment,@DedOPTreatment,@DedIPTreatment,
										@MaxIPTreatment,@MaxTreatment,@MaxOPTreatment,@DedPolicy,@DedOPPolicy,@DedIPPolicy,@MaxPolicy,@MaxOPPolicy,@MaxIPPolicy,@CeilingConsult,@CeilingSurgery,@CeilingHospitalization,@CeilingDelivery,@CeilingAntenatal,
										@Treshold, @MaxPolicyExtraMember,@MaxPolicyExtraMemberIP,@MaxPolicyExtraMemberOP,@MaxCeilingPolicy,@MaxCeilingPolicyIP,@MaxCeilingPolicyOP,@CeilingInterpretation
	
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		--FIRST CHECK GENERAL 
		
		--DECLARE @PrevDeducted as Decimal(18,2)
		--DECLARE @PrevRemunerated as decimal(18,2)
		--DECLARE @Deducted as decimal(18,2)
		
		SET @Ceiling = 0 
		SET @Deductable = 0 
		SET @Deducted = 0  --reset to zero 
		SET @Remunerated = 0 
		SET @RemuneratedConsult = 0 
		SET @RemuneratedDelivery = 0 
		SET @RemuneratedHospitalization = 0 
		SET @RemuneratedSurgery = 0 
		SET @RemuneratedAntenatal  = 0 

		SELECT @PolicyMembers =  COUNT(InsureeID) FROM tblInsureePolicy WHERE tblInsureePolicy.PolicyId = @PolicyID  AND  (NOT (EffectiveDate IS NULL)) AND  ( @ClaimDateTo BETWEEN EffectiveDate And ExpiryDate  )   AND   (ValidityTo IS NULL)

		IF ISNULL(@CeilingConsult,0) > 0 
		BEGIN
			SELECT @PrevRemuneratedConsult = 0 --SUM(RemConsult) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID AND InsureeID = @InsureeID And ClaimID <> @ClaimID 
		END
		IF ISNULL(@CeilingSurgery,0) > 0 
		BEGIN
			SELECT @PrevRemuneratedSurgery  = 0 -- SUM(RemSurgery ) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID AND InsureeID = @InsureeID And ClaimID <> @ClaimID 
		END
		IF ISNULL(@CeilingHospitalization,0)  > 0 
		BEGIN
			--check first if this is a hospital claim falling under the hospitalization category
			IF @Hospitalization = 1 

			--SELECT @ClaimDateFrom = DateFrom,  @ClaimDateTo = DateTo FROM tblClaim Where ClaimID = @ClaimID 
			--IF ISNULL(@ClaimDateTo,@ClaimDateFrom) <> @ClaimDateFrom 
			BEGIN
				--SET @Hospitalization = 1 
				SELECT @PrevRemuneratedHospitalization = 0 -- SUM(RemHospitalization) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID AND InsureeID = @InsureeID And ClaimID <> @ClaimID 
			END
		END

		IF ISNULL(@CeilingDelivery,0)  > 0 
		BEGIN
			SELECT @PrevRemuneratedDelivery  = 0 -- SUM(RemDelivery ) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID AND InsureeID = @InsureeID And ClaimID <> @ClaimID 
		END

		IF ISNULL(@PrevRemuneratedAntenatal ,0)  > 0 
		BEGIN
			SELECT @PrevRemuneratedAntenatal  = 0 --  SUM(RemAntenatal ) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID AND InsureeID = @InsureeID And ClaimID <> @ClaimID 
		END


		IF ISNULL(@DedTreatment,0) <> 0 
		BEGIN
			SET @Deductable = @DedTreatment
			SET @DeductableType = 'G'
			SET @PrevDeducted = 0 
		END
		
		IF ISNULL(@DedInsuree,0) <> 0
		BEGIN
			SET @Deductable = @DedInsuree
			SET @DeductableType = 'G'
			SELECT @PrevDeducted = SUM(DedG) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID AND InsureeID = @InsureeID And ClaimID <> @ClaimID 
		END
		
		IF ISNULL(@DedPolicy,0) <> 0
		BEGIN
			SET @Deductable = @DedPolicy
			SET @DeductableType = 'G'
			SELECT @PrevDeducted = SUM(DedG) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID And ClaimID <> @ClaimID 
		END
		
		IF ISNULL(@MaxTreatment,0) <> 0
		BEGIN
			SET @Ceiling = @MaxTreatment
			SET @CeilingType  = 'G'
			SET @PrevRemunerated = 0 
		END
		
		IF ISNULL(@MaxInsuree,0) <> 0
		BEGIN
			SET @Ceiling = @MaxInsuree
			SET @CeilingType  = 'G'
			SELECT @PrevRemunerated = SUM(RemG) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID AND InsureeID = @InsureeID And ClaimID <> @ClaimID 
		END
		IF ISNULL(@MaxPolicy,0) <> 0
		BEGIN
		    --check with the amount of members if we go over the treshold --> if so lets calculate 
			IF @PolicyMembers > @Treshold
			BEGIN
				SET @Ceiling = @MaxPolicy + ((@PolicyMembers - @Treshold) * @MaxPolicyExtraMember) 
				IF @Ceiling > @MaxCeilingPolicy
					SET @Ceiling = ISNULL(NULLIF(@MaxCeilingPolicy, 0), @Ceiling)
			END
			ELSE
			BEGIN
				SET @Ceiling = @MaxPolicy
			END

			SET @CeilingType  = 'G'
			SELECT @PrevRemunerated = SUM(RemG) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID And ClaimID <> @ClaimID  
		END
				
		--NOW CHECK FOR IP DEDUCTABLES --> if hospital
		IF @Deductable = 0 
		BEGIN 
			IF (@CeilingInterpretation = 'I' AND  @Hospitalization = 1) OR (@CeilingInterpretation = 'H' AND @HFLevel = 'H' ) --@HFLevel = 'H' This was a claim with a hospital stay 
			BEGIN
				--Hospital IP
				IF @DedIPTreatment <> 0 
				BEGIN
					SET @Deductable = @DedIPTreatment
					SET @DeductableType = 'I'
					SET @PrevDeducted = 0 
				END
				
				IF @DedIPInsuree  <> 0
				BEGIN
					SET @Deductable = @DedIPInsuree
					SET @DeductableType = 'I'
					SELECT @PrevDeducted = SUM(DedIP) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID AND InsureeID = @InsureeID And ClaimID <> @ClaimID 
					
				END
				
				IF @DedIPPolicy <> 0
				BEGIN
					SET @Deductable = @DedIPPolicy
					SET @DeductableType = 'I'
					SELECT @PrevDeducted = SUM(DedIP) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID And ClaimID <> @ClaimID 
				END	
			END
			ELSE
			BEGIN
				--Non hospital OP
				--Hospital IP
				IF @DedOPTreatment <> 0 
				BEGIN
					SET @Deductable = @DedOPTreatment
					SET @DeductableType = 'O'
					SET @PrevDeducted = 0 
				END
				
				IF @DedIPInsuree  <> 0
				BEGIN
					SET @Deductable = @DedOPInsuree
					SET @DeductableType = 'O'
					SELECT @PrevDeducted = SUM(DedOP) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID AND InsureeID = @InsureeID And ClaimID <> @ClaimID 
					
				END
				
				IF @DedIPPolicy <> 0
				BEGIN
					SET @Deductable = @DedOPPolicy
					SET @DeductableType = 'O'
					SELECT @PrevDeducted = SUM(DedOP) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID And ClaimID <> @ClaimID 
				END	
			END
		END
		
		--NOW CHECK FOR IP CEILINGS --> if hospital
		IF @Ceiling = 0  
		BEGIN
		--- HANS HERE CHANGE DEPENDING ON NEW FIELD IN PRODUCT
			IF (@CeilingInterpretation = 'I' AND  @Hospitalization = 1) OR (@CeilingInterpretation = 'H' AND @HFLevel = 'H' )
			BEGIN
				--Hospital IP
				IF @MaxIPTreatment <> 0 
				BEGIN
					SET @Ceiling  = @MaxIPTreatment
					SET @CeilingType = 'I'
					SET @PrevRemunerated = 0 
				END
				
				IF @MaxIPInsuree  <> 0
				BEGIN
					SET @Ceiling  = @MaxIPInsuree 
					SET @CeilingType = 'I'
					SELECT @PrevRemunerated = SUM(RemIP) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID AND InsureeID = @InsureeID And ClaimID <> @ClaimID 
					
				END
				
				IF @MaxIPPolicy <> 0
				BEGIN
					
					IF @PolicyMembers > @Treshold
					BEGIN
						SET @Ceiling = @MaxIPPolicy + ((@PolicyMembers - @Treshold) * @MaxPolicyExtraMemberIP ) 
						IF @Ceiling > @MaxCeilingPolicyIP 
							SET @Ceiling = ISNULL(NULLIF(@MaxCeilingPolicyIP, 0), @Ceiling)
					END
					ELSE
					BEGIN
						SET @Ceiling = @MaxIPPolicy 
					END
					SET @CeilingType = 'I'
					SELECT @PrevRemunerated = SUM(RemIP) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID And ClaimID <> @ClaimID 
				END	
			END
			ELSE
			BEGIN
				--Non hospital OP
				IF @MaxOPTreatment <> 0 
				BEGIN
					SET @Ceiling  = @MaxOPTreatment
					SET @CeilingType = 'O'
					SET @PrevRemunerated = 0 
				END
				
				IF @MaxOPInsuree  <> 0
				BEGIN
					SET @Ceiling  = @MaxOPInsuree 
					SET @CeilingType = 'O'
					SELECT @PrevRemunerated = SUM(RemOP) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID AND InsureeID = @InsureeID And ClaimID <> @ClaimID 
					
				END
				
				IF @MaxOPPolicy <> 0
				BEGIN
					IF @PolicyMembers > @Treshold
					BEGIN
						SET @Ceiling = @MaxOPPolicy + ((@PolicyMembers - @Treshold) * @MaxPolicyExtraMemberOP ) 
						IF @Ceiling > @MaxCeilingPolicyOP 
							SET @Ceiling = ISNULL(NULLIF(@MaxCeilingPolicyOP, 0), @Ceiling)
					END
					ELSE
					BEGIN
						SET @Ceiling = @MaxOPPolicy 
					END
					 
					SET @CeilingType = 'O'
					SELECT @PrevRemunerated = SUM(RemOP) FROM dbo.tblClaimDedRem WHERE PolicyID = @PolicyID And ClaimID <> @ClaimID 
				END	
			END
		END
		
		--Make sure that we have zero in case of NULL
		SET @PrevRemunerated = ISNULL(@PrevRemunerated,0)
		SET @PrevDeducted = ISNULL(@PrevDeducted,0)
		SET @PrevRemuneratedConsult = ISNULL(@PrevRemuneratedConsult,0)
		SET @PrevRemuneratedSurgery  = ISNULL(@PrevRemuneratedSurgery ,0)
		SET @PrevRemuneratedHospitalization  = ISNULL(@PrevRemuneratedHospitalization ,0)
		SET @PrevRemuneratedDelivery  = ISNULL(@PrevRemuneratedDelivery ,0)
		SET @PrevRemuneratedantenatal   = ISNULL(@PrevRemuneratedantenatal ,0)

		
		DECLARE @CeilingExclusionAdult NVARCHAR(1)
		DECLARE @CeilingExclusionChild NVARCHAR(1)
		

		--FIRST GET all items 
		DECLARE CLAIMITEMLOOP CURSOR LOCAL FORWARD_ONLY FOR 
															SELECT     tblClaimItems.ClaimItemID, tblClaimItems.QtyProvided, tblClaimItems.QtyApproved, tblClaimItems.PriceAsked, tblClaimItems.PriceApproved,  
																		ISNULL(tblPLItemsDetail.PriceOverule,Items.ItemPrice) as PLPrice, tblClaimItems.PriceOrigin, tblClaimItems.Limitation, tblClaimItems.LimitationValue, tblProductItems.CeilingExclusionAdult, tblProductItems.CeilingExclusionChild 
															FROM         tblPLItemsDetail INNER JOIN
																		  @DTBL_ITEMS Items ON tblPLItemsDetail.ItemID = Items.ItemID INNER JOIN
																		  tblClaimItems INNER JOIN
																		  tblClaim ON tblClaimItems.ClaimID = tblClaim.ClaimID INNER JOIN
																		  tblHF ON tblClaim.HFID = tblHF.HfID INNER JOIN
																		  tblPLItems ON tblHF.PLItemID = tblPLItems.PLItemID ON tblPLItemsDetail.PLItemID = tblPLItems.PLItemID AND Items.ItemID = tblClaimItems.ItemID
																		  INNER JOIN tblProductItems ON tblClaimItems.ItemID = tblProductItems.ItemID AND tblProductItems.ProdID = tblClaimItems.ProdID 
															WHERE     (tblClaimItems.ClaimID = @ClaimID) AND (tblClaimItems.ValidityTo IS NULL) AND (tblClaimItems.ClaimItemStatus = 1) AND (tblClaimItems.ProdID = @ProductID) AND 
																		  (tblClaimItems.PolicyID = @PolicyID) AND (tblPLItems.ValidityTo IS NULL) AND (tblPLItemsDetail.ValidityTo IS NULL) AND (tblProductItems.ValidityTo IS NULL)
															ORDER BY tblClaimItems.ClaimItemID
		OPEN CLAIMITEMLOOP
		FETCH NEXT FROM CLAIMITEMLOOP INTO @ClaimItemId, @QtyProvided, @QtyApproved ,@PriceAsked, @PriceApproved, @PLPrice, @PriceOrigin, @Limitation, @Limitationvalue,@CeilingExclusionAdult,@CeilingExclusionChild
		WHILE @@FETCH_STATUS = 0 
		BEGIN
			--SET @Deductable = @DedOPTreatment
			--SET @DeductableType = 'O'
			--SET @PrevDeducted = 0 
			
			--DeductableAmount
			--RemuneratedAmount
			--ExceedCeilingAmount
			--ProcessingStatus
			
			--CHECK first if any amount is still to be deducted 
			--SELECT @ClaimExclusionAdult = CeilingEx FROM tblProductItems WHERE ProdID = @ProductID AND ItemID = @ItemID AND ValidityTo IS NULL

			
			SET @ItemQty = ISNULL(@QtyApproved,@QtyProvided) 
			SET @WorkValue = 0 
			SET @SetPriceDeducted = 0 
			SET @ExceedCeilingAmount = 0 
			SET @ExceedCeilingAmountCategory = 0 

			IF @PriceOrigin = 'O' 
				SET @SetPriceAdjusted = ISNULL(@PriceApproved,@PriceAsked)
			ELSE
				--HVH check if this is the case
				SET @SetPriceAdjusted = ISNULL(@PriceApproved,@PLPrice)
			
			SET @WorkValue = (@ItemQty * @SetPriceAdjusted)
			
			IF @Deductable - @PrevDeducted - @Deducted > 0 
			BEGIN
				IF (@Deductable - @PrevDeducted - @Deducted) >= ( @ItemQty * @SetPriceAdjusted)
				BEGIN
					SET @SetPriceDeducted = ( @ItemQty * @SetPriceAdjusted)
					SET @Deducted = @Deducted + ( @ItemQty * @SetPriceAdjusted)
					SET @Remunerated = @Remunerated + 0 
					SET @SetPriceValuated = 0 
					SET @SetPriceRemunerated = 0 
					GOTO NextItem
				END
				ELSE
				BEGIN
					--partial coverage 
					SET @SetPriceDeducted = (@Deductable - @PrevDeducted - @Deducted)
					SET @WorkValue = (@ItemQty * @SetPriceAdjusted) - @SetPriceDeducted
					SET @Deducted = @Deducted + (@Deductable - @PrevDeducted - @Deducted)
					
					--go next stage --> valuation considering the ceilings 
				END
			END
			
			--DEDUCTABLES ARE ALREADY TAKEN OUT OF VALUE AND STORED IN VARS
			
			IF @Limitation = 'F' AND ((@ItemQty * @Limitationvalue) < @WorkValue)
				SET @WorkValue =(@ItemQty * @Limitationvalue)
			
			IF @Limitation = 'C' 
				SET @WorkValue = (@Limitationvalue/100) * @WorkValue  
				
			
			IF @BaseCategory <> 'V'
			BEGIN
				IF (ISNULL(@CeilingSurgery  ,0) > 0) AND @BaseCategory = 'S'  --  Ceiling check for Surgery
				BEGIN
					IF @WorkValue + @PrevRemuneratedSurgery  + @RemuneratedSurgery   <= @CeilingSurgery  
					BEGIN
						--we are still under the ceiling for hospitalization and can be fully covered 
						SET @RemuneratedSurgery   =  @RemuneratedSurgery   + @WorkValue
					END
					ELSE
					BEGIN
						IF @PrevRemuneratedSurgery  + @RemuneratedSurgery  >= @CeilingSurgery 
						BEGIN
							--Nothing can be covered already reached ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue
							SET @RemuneratedSurgery  = @RemuneratedSurgery    + 0
							SET @WorkValue = 0 
						END
						ELSE
						BEGIN
							--claim service can partially be covered , we are over the ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue + @PrevRemuneratedSurgery   + @RemuneratedSurgery    - @CeilingSurgery   
							SET @WorkValue = @WorkValue - @ExceedCeilingAmountCategory
							SET @RemuneratedSurgery    =  @RemuneratedSurgery    + @WorkValue   -- we only add the value that could be covered up to the ceiling
						END
					END
				END

				IF (ISNULL(@CeilingDelivery  ,0) > 0) AND @BaseCategory = 'D'  --  Ceiling check for Delivery
				BEGIN
					IF @WorkValue + @PrevRemuneratedDelivery  + @RemuneratedDelivery   <= @CeilingDelivery  
					BEGIN
						--we are still under the ceiling for hospitalization and can be fully covered 
						SET @RemuneratedDelivery   =  @RemuneratedDelivery   + @WorkValue
					END
					ELSE
					BEGIN
						IF @PrevRemuneratedDelivery  + @RemuneratedDelivery  >= @CeilingDelivery 
						BEGIN
							--Nothing can be covered already reached ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue
							SET @RemuneratedDelivery  = @RemuneratedDelivery    + 0
							SET @WorkValue = 0 
						END
						ELSE
						BEGIN
							--claim service can partially be covered , we are over the ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue + @PrevRemuneratedDelivery   + @RemuneratedDelivery    - @CeilingDelivery   
							SET @WorkValue = @WorkValue - @ExceedCeilingAmountCategory
							SET @RemuneratedDelivery    =  @RemuneratedDelivery    + @WorkValue   -- we only add the value that could be covered up to the ceiling
						END
					END
				END
				
				IF (ISNULL(@CeilingAntenatal  ,0) > 0) AND @BaseCategory = 'A'  --  Ceiling check for Antenatal
				BEGIN
					IF @WorkValue + @PrevRemuneratedAntenatal  + @RemuneratedAntenatal   <= @CeilingAntenatal  
					BEGIN
						--we are still under the ceiling for hospitalization and can be fully covered 
						SET @RemuneratedAntenatal   =  @RemuneratedAntenatal   + @WorkValue
					END
					ELSE
					BEGIN
						IF @PrevRemuneratedAntenatal  + @RemuneratedAntenatal  >= @CeilingAntenatal 
						BEGIN
							--Nothing can be covered already reached ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue
							SET @RemuneratedAntenatal  = @RemuneratedAntenatal    + 0
							SET @WorkValue = 0 
						END
						ELSE
						BEGIN
							--claim service can partially be covered , we are over the ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue + @PrevRemuneratedAntenatal   + @RemuneratedAntenatal    - @CeilingAntenatal   
							SET @WorkValue = @WorkValue - @ExceedCeilingAmountCategory
							SET @RemuneratedAntenatal    =  @RemuneratedAntenatal    + @WorkValue   -- we only add the value that could be covered up to the ceiling
						END
					END
				END

				IF (ISNULL(@CeilingHospitalization ,0) > 0) AND @BaseCategory = 'H'  --  Ceiling check for Hospital
				BEGIN
					IF @WorkValue + @PrevRemuneratedHospitalization + @RemuneratedHospitalization  <= @CeilingHospitalization 
					BEGIN
						--we are still under the ceiling for hospitalization and can be fully covered 
						SET @RemuneratedHospitalization  =  @RemuneratedHospitalization  + @WorkValue
					END
					ELSE
					BEGIN
						IF @PrevRemuneratedHospitalization  + @RemuneratedHospitalization  >= @CeilingHospitalization 
						BEGIN
							--Nothing can be covered already reached ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue
							SET @RemuneratedHospitalization  = @RemuneratedHospitalization    + 0
							SET @WorkValue = 0 
						END
						ELSE
						BEGIN
							--claim service can partially be covered , we are over the ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue + @PrevRemuneratedHospitalization   + @RemuneratedHospitalization    - @CeilingHospitalization   
							SET @WorkValue = @WorkValue - @ExceedCeilingAmountCategory
							SET @RemuneratedHospitalization    =  @RemuneratedHospitalization    + @WorkValue   -- we only add the value that could be covered up to the ceiling
						END
					END
				END

				IF (ISNULL(@CeilingConsult   ,0) > 0) AND @BaseCategory = 'C'  --  Ceiling check for Consult
				BEGIN
					IF @WorkValue + @PrevRemuneratedConsult  + @RemuneratedConsult   <= @CeilingConsult  
					BEGIN
						--we are still under the ceiling for hospitalization and can be fully covered 
						SET @RemuneratedConsult   =  @RemuneratedConsult   + @WorkValue
					END
					ELSE
					BEGIN
						IF @PrevRemuneratedConsult  + @RemuneratedConsult  >= @CeilingConsult 
						BEGIN
							--Nothing can be covered already reached ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue
							SET @RemuneratedConsult  = @RemuneratedConsult    + 0
							SET @WorkValue = 0 
						END
						ELSE
						BEGIN
							--claim service can partially be covered , we are over the ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue + @PrevRemuneratedConsult   + @RemuneratedConsult    - @CeilingConsult   
							SET @WorkValue = @WorkValue - @ExceedCeilingAmountCategory
							SET @RemuneratedConsult    =  @RemuneratedConsult    + @WorkValue   -- we only add the value that could be covered up to the ceiling
						END
					END
				END

			END 

		
			IF (@AdultChild = 'A' AND (((@CeilingInterpretation = 'I' AND  @Hospitalization = 1) OR (@CeilingInterpretation = 'H' AND @HFLevel = 'H' ))) AND (@CeilingExclusionAdult = 'B' OR @CeilingExclusionAdult = 'H'))  OR
			   (@AdultChild = 'A' AND (NOT ((@CeilingInterpretation = 'I' AND  @Hospitalization = 1) OR (@CeilingInterpretation = 'H' AND @HFLevel = 'H' ))) AND (@CeilingExclusionAdult = 'B' OR @CeilingExclusionAdult = 'N')) OR
			   (@AdultChild = 'C' AND (((@CeilingInterpretation = 'I' AND  @Hospitalization = 1) OR (@CeilingInterpretation = 'H' AND @HFLevel = 'H' ))) AND (@CeilingExclusionChild = 'B' OR @CeilingExclusionChild  = 'H')) OR
			   (@AdultChild = 'C' AND (NOT ((@CeilingInterpretation = 'I' AND  @Hospitalization = 1) OR (@CeilingInterpretation = 'H' AND @HFLevel = 'H' ))) AND (@CeilingExclusionChild = 'B' OR @CeilingExclusionChild  = 'N')) 
			BEGIN
				--NO CEILING WILL BE AFFECTED
				SET @ExceedCeilingAmount = 0
				SET @Remunerated = @Remunerated + 0 --here in this case we do notr add the amount to be added to the ceiling --> so exclude from the actual value to be entered against the insert into tblClaimDedRem in the end of the prod loop 
				SET @SetPriceValuated = @WorkValue
				SET @SetPriceRemunerated = @WorkValue
				GOTO NextItem
			END
			ELSE
			BEGIN
				IF @Ceiling > 0 --CEILING HAS BEEN DEFINED 
				BEGIN	
					IF (@Ceiling - @PrevRemunerated  - @Remunerated)  > 0
					BEGIN
						--we have not reached the ceiling
						IF (@Ceiling - @PrevRemunerated  - @Remunerated) >= @WorkValue
						BEGIN
							--full amount of workvalue can be paid out as it under the limit
							SET @ExceedCeilingAmount = 0
							SET @SetPriceValuated = @WorkValue
							SET @SetPriceRemunerated = @WorkValue
							SET @Remunerated = @Remunerated + @WorkValue
							GOTO NextItem
						END
						ELSE
						BEGIN
							SET @ExceedCeilingAmount = @WorkValue - (@Ceiling - @PrevRemunerated  - @Remunerated)			
							SET @SetPriceValuated = (@Ceiling - @PrevRemunerated  - @Remunerated)
							SET @SetPriceRemunerated = (@Ceiling - @PrevRemunerated  - @Remunerated)
							SET @Remunerated = @Remunerated + (@Ceiling - @PrevRemunerated  - @Remunerated)			
							GOTO NextItem
						END
					
					END
					ELSE
					BEGIN
						SET @ExceedCeilingAmount = @WorkValue
						SET @Remunerated = @Remunerated + 0
						SET @SetPriceValuated = 0
						SET @SetPriceRemunerated = 0
						GOTO NextItem
					END
				END
				ELSE
				BEGIN
					-->
					SET @ExceedCeilingAmount = 0
					SET @Remunerated = @Remunerated + @WorkValue
					SET @SetPriceValuated = @WorkValue
					SET @SetPriceRemunerated = @WorkValue
					GOTO NextItem
				END

			END
	
			
NextItem:
			IF @IsProcess = 1 
			BEGIN
				IF @PriceOrigin = 'R'
				BEGIN
					UPDATE tblClaimItems SET PriceAdjusted = @SetPriceAdjusted , PriceValuated = @SetPriceValuated , DeductableAmount = @SetPriceDeducted , ExceedCeilingAmount = @ExceedCeilingAmount , @ExceedCeilingAmountCategory  = @ExceedCeilingAmountCategory WHERE ClaimItemID = @ClaimItemID 
					SET @RelativePrices = 1 
				END
				ELSE
				BEGIN
					UPDATE tblClaimItems SET PriceAdjusted = @SetPriceAdjusted , PriceValuated = @SetPriceValuated , DeductableAmount = @SetPriceDeducted ,ExceedCeilingAmount = @ExceedCeilingAmount,  @ExceedCeilingAmountCategory  = @ExceedCeilingAmountCategory, RemuneratedAmount = @SetPriceRemunerated WHERE ClaimItemID = @ClaimItemID 
				END
			END
			
			FETCH NEXT FROM CLAIMITEMLOOP INTO @ClaimItemId, @QtyProvided, @QtyApproved ,@PriceAsked, @PriceApproved, @PLPrice, @PriceOrigin, @Limitation, @Limitationvalue,@CeilingExclusionAdult,@CeilingExclusionChild
		END
		CLOSE CLAIMITEMLOOP
		DEALLOCATE CLAIMITEMLOOP 
			
		-- !!!!!! SECONDLY GET all SERVICES !!!!!!!
			
		DECLARE CLAIMSERVICELOOP CURSOR LOCAL FORWARD_ONLY FOR 
															SELECT     tblClaimServices.ClaimServiceID, tblClaimServices.QtyProvided, tblClaimServices.QtyApproved, tblClaimServices.PriceAsked, tblClaimServices.PriceApproved,  
																		ISNULL(tblPLServicesDetail.PriceOverule,Serv.ServPrice) as PLPrice, tblClaimServices.PriceOrigin, tblClaimServices.Limitation, tblClaimServices.LimitationValue, Serv.ServCategory , tblProductServices.CeilingExclusionAdult, tblProductServices.CeilingExclusionChild 
															FROM         tblPLServicesDetail INNER JOIN
																		  @DTBL_Services Serv ON tblPLServicesDetail.ServiceID = Serv.ServiceID INNER JOIN
																		  tblClaimServices INNER JOIN
																		  tblClaim ON tblClaimServices.ClaimID = tblClaim.ClaimID INNER JOIN
																		  tblHF ON tblClaim.HFID = tblHF.HfID INNER JOIN
																		  tblPLServices ON tblHF.PLServiceID = tblPLServices.PLServiceID ON tblPLServicesDetail.PLServiceID = tblPLServices.PLServiceID AND Serv.ServiceID = tblClaimServices.ServiceID
																		  INNER JOIN tblProductServices ON tblClaimServices.ServiceID  = tblProductServices.ServiceID  AND tblProductServices.ProdID = tblClaimServices.ProdID 
															WHERE     (tblClaimServices.ClaimID = @ClaimID) AND (tblClaimServices.ValidityTo IS NULL) AND (tblClaimServices.ClaimServiceStatus = 1) AND (tblClaimServices.ProdID = @ProductID) AND 
																		  (tblClaimServices.PolicyID = @PolicyID) AND (tblPLServices.ValidityTo IS NULL) AND (tblPLServicesDetail.ValidityTo IS NULL)  AND (tblProductServices.ValidityTo IS NULL)
															ORDER BY tblClaimServices.ClaimServiceID
		OPEN CLAIMSERVICELOOP
		FETCH NEXT FROM CLAIMSERVICELOOP INTO @ClaimServiceId, @QtyProvided, @QtyApproved ,@PriceAsked, @PriceApproved, @PLPrice, @PriceOrigin, @Limitation, @Limitationvalue,@ServCategory,@CeilingExclusionAdult,@CeilingExclusionChild
		WHILE @@FETCH_STATUS = 0 
		BEGIN
			--SET @Deductable = @DedOPTreatment
			--SET @DeductableType = 'O'
			--SET @PrevDeducted = 0 
			
			--DeductableAmount
			--RemuneratedAmount
			--ExceedCeilingAmount
			--ProcessingStatus
			
			--CHECK first if any amount is still to be deducted 
			SET @ServiceQty = ISNULL(@QtyApproved,@QtyProvided) 
			SET @WorkValue = 0 
			SET @SetPriceDeducted = 0 
			SET @ExceedCeilingAmount = 0 
			SET @ExceedCeilingAmountCategory = 0 
			


			IF @PriceOrigin = 'O' 
				SET @SetPriceAdjusted = ISNULL(@PriceApproved,@PriceAsked)
			ELSE
				--HVH check if this is the case
				SET @SetPriceAdjusted = ISNULL(@PriceApproved,@PLPrice)
			
			SET @WorkValue = (@ServiceQty * @SetPriceAdjusted)
			
			IF @Deductable - @PrevDeducted - @Deducted > 0 
			BEGIN
				IF (@Deductable - @PrevDeducted - @Deducted) >= ( @ServiceQty * @SetPriceAdjusted)
				BEGIN
					SET @SetPriceDeducted = ( @ServiceQty * @SetPriceAdjusted)
					SET @Deducted = @Deducted + ( @ServiceQty * @SetPriceAdjusted)
					SET @Remunerated = @Remunerated + 0 
					SET @SetPriceValuated = 0 
					SET @SetPriceRemunerated = 0 
					GOTO NextService
				END
				ELSE
				BEGIN
					--partial coverage 
					SET @SetPriceDeducted = (@Deductable - @PrevDeducted - @Deducted)
					SET @WorkValue = (@ServiceQty * @SetPriceAdjusted) - @SetPriceDeducted
					SET @Deducted = @Deducted + (@Deductable - @PrevDeducted - @Deducted)
					
					--go next stage --> valuation considering the ceilings 
				END
			END
			
			--DEDUCTABLES ARE ALREADY TAKEN OUT OF VALUE AND STORED IN VARS
			
			IF @Limitation = 'F' AND ((@ServiceQty * @Limitationvalue) < @WorkValue)
				SET @WorkValue =(@ServiceQty * @Limitationvalue)
			
			IF @Limitation = 'C' 
				SET @WorkValue = (@Limitationvalue/100) * @WorkValue  
				
			
			--now capping in case of category constraints
			
			IF @BaseCategory <> 'V'
			BEGIN
				IF @BaseCategory = 'S' AND (ISNULL(@CeilingSurgery ,0) > 0)  --  Ceiling check for category Surgery
				BEGIN
					IF @WorkValue + @PrevRemuneratedSurgery + @RemuneratedSurgery   <= @CeilingSurgery
					BEGIN
						--we are still under the ceiling for surgery and can be fully covered 
						SET @RemuneratedSurgery =  @RemuneratedSurgery + @WorkValue
					END
					ELSE
					BEGIN
						IF @PrevRemuneratedSurgery + @RemuneratedSurgery >= @CeilingSurgery 
						BEGIN
							--Nothing can be covered already reached ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue
							SET @RemuneratedSurgery  = @RemuneratedSurgery  + 0
							SET @WorkValue = 0 
						END
						ELSE
						BEGIN
							--claim service can partially be covered , we are over the ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue + @PrevRemuneratedSurgery  + @RemuneratedSurgery  - @CeilingSurgery 
							SET @WorkValue = @WorkValue - @ExceedCeilingAmountCategory
							SET @RemuneratedSurgery  =  @RemuneratedSurgery  + @WorkValue   -- we only add the value that could be covered up to the ceiling
						END
					END
				END

				IF @BaseCategory = 'D' AND (ISNULL(@CeilingDelivery ,0) > 0)  --  Ceiling check for category Deliveries 
				BEGIN
					IF @WorkValue + @PrevRemuneratedDelivery  + @RemuneratedDelivery    <= @CeilingDelivery 
					BEGIN
						--we are still under the ceiling for Delivery and can be fully covered 
						SET @RemuneratedDelivery  =  @RemuneratedDelivery  + @WorkValue
					END
					ELSE
					BEGIN
						IF @PrevRemuneratedDelivery  + @RemuneratedDelivery  >= @CeilingDelivery 
						BEGIN
							--Nothing can be covered already reached ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue
							SET @RemuneratedDelivery  = @RemuneratedDelivery   + 0
							SET @WorkValue = 0 
						END
						ELSE
						BEGIN
							--claim service can partially be covered , we are over the ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue + @PrevRemuneratedDelivery   + @RemuneratedDelivery   - @CeilingDelivery  
							SET @WorkValue = @WorkValue - @ExceedCeilingAmountCategory
							SET @RemuneratedDelivery   =  @RemuneratedDelivery   + @WorkValue   -- we only add the value that could be covered up to the ceiling
						END
					END
				END
				
				IF @BaseCategory = 'A' AND (ISNULL(@CeilingAntenatal  ,0) > 0)  --  Ceiling check for category Antenatal 
				BEGIN
					IF @WorkValue + @PrevRemuneratedAntenatal  + @RemuneratedAntenatal    <= @CeilingAntenatal 
					BEGIN
						--we are still under the ceiling for Antenatal and can be fully covered 
						SET @RemuneratedAntenatal  =  @RemuneratedAntenatal  + @WorkValue
					END
					ELSE
					BEGIN
						IF @PrevRemuneratedAntenatal  + @RemuneratedAntenatal  >= @CeilingAntenatal 
						BEGIN
							--Nothing can be covered already reached ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue
							SET @RemuneratedAntenatal  = @RemuneratedAntenatal   + 0
							SET @WorkValue = 0 
						END
						ELSE
						BEGIN
							--claim service can partially be covered , we are over the ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue + @PrevRemuneratedAntenatal   + @RemuneratedAntenatal   - @CeilingAntenatal  
							SET @WorkValue = @WorkValue - @ExceedCeilingAmountCategory
							SET @RemuneratedAntenatal   =  @RemuneratedAntenatal   + @WorkValue   -- we only add the value that could be covered up to the ceiling
						END
					END
				END

				IF  @BaseCategory  = 'H' AND (ISNULL(@CeilingHospitalization ,0) > 0)   --  Ceiling check for category Hospitalization 
				BEGIN
					IF @WorkValue + @PrevRemuneratedHospitalization + @RemuneratedHospitalization  <= @CeilingHospitalization 
					BEGIN
						--we are still under the ceiling for hospitalization and can be fully covered 
						SET @RemuneratedHospitalization  =  @RemuneratedHospitalization  + @WorkValue
					END
					ELSE
					BEGIN
						IF @PrevRemuneratedHospitalization  + @RemuneratedHospitalization  >= @CeilingHospitalization 
						BEGIN
							--Nothing can be covered already reached ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue
							SET @RemuneratedHospitalization  = @RemuneratedHospitalization    + 0
							SET @WorkValue = 0 
						END
						ELSE
						BEGIN
							--claim service can partially be covered , we are over the ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue + @PrevRemuneratedHospitalization   + @RemuneratedHospitalization    - @CeilingHospitalization   
							SET @WorkValue = @WorkValue - @ExceedCeilingAmountCategory
							SET @RemuneratedHospitalization    =  @RemuneratedHospitalization    + @WorkValue   -- we only add the value that could be covered up to the ceiling
						END
					END
				END

				IF @BaseCategory  = 'C' AND (ISNULL(@CeilingConsult,0) > 0)  --  Ceiling check for category Consult 
				BEGIN
					IF @WorkValue + @PrevRemuneratedConsult + @RemuneratedConsult  <= @CeilingConsult 
					BEGIN
						--we are still under the ceiling for consult and can be fully covered 
						SET @RemuneratedConsult =  @RemuneratedConsult + @WorkValue
					END
					ELSE
					BEGIN
						IF @PrevRemuneratedConsult + @RemuneratedConsult >= @CeilingConsult
						BEGIN
							--Nothing can be covered already reached ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue
							SET @RemuneratedConsult  = @RemuneratedConsult + 0
							SET @WorkValue = 0 
						END
						ELSE
						BEGIN
							--claim service can partially be covered , we are over the ceiling
							SET @ExceedCeilingAmountCategory = @WorkValue + @PrevRemuneratedConsult + @RemuneratedConsult - @CeilingConsult
							SET @WorkValue = @WorkValue - @ExceedCeilingAmountCategory
							SET @RemuneratedConsult =  @RemuneratedConsult + @WorkValue   -- we only add the value that could be covered up to the ceiling
						END
					END
 				END


			END

			IF (@AdultChild = 'A' AND (((@CeilingInterpretation = 'I' AND  @Hospitalization = 1) OR (@CeilingInterpretation = 'H' AND @HFLevel = 'H' ))) AND (@CeilingExclusionAdult = 'B' OR @CeilingExclusionAdult = 'H'))  OR
			   (@AdultChild = 'A' AND (NOT ((@CeilingInterpretation = 'I' AND  @Hospitalization = 1) OR (@CeilingInterpretation = 'H' AND @HFLevel = 'H' ))) AND (@CeilingExclusionAdult = 'B' OR @CeilingExclusionAdult = 'N')) OR
			   (@AdultChild = 'C' AND (((@CeilingInterpretation = 'I' AND  @Hospitalization = 1) OR (@CeilingInterpretation = 'H' AND @HFLevel = 'H' ))) AND (@CeilingExclusionChild = 'B' OR @CeilingExclusionChild  = 'H')) OR
			   (@AdultChild = 'C' AND (NOT ((@CeilingInterpretation = 'I' AND  @Hospitalization = 1) OR (@CeilingInterpretation = 'H' AND @HFLevel = 'H' ))) AND (@CeilingExclusionChild = 'B' OR @CeilingExclusionChild  = 'N')) 
			BEGIN
				--NO CEILING WILL BE AFFECTED
				SET @ExceedCeilingAmount = 0
				SET @Remunerated = @Remunerated + 0  --(we do not add any value to the running sum for renumerated values as we do not coulnt this service for any ceiling calculation 
				SET @SetPriceValuated = @WorkValue
				SET @SetPriceRemunerated = @WorkValue
				GOTO NextService
				
			END
			ELSE
			BEGIN
				IF @Ceiling > 0 --CEILING HAS BEEN DEFINED 
				BEGIN	
					IF (@Ceiling - @PrevRemunerated  - @Remunerated)  > 0
					BEGIN
						--we have not reached the ceiling
						IF (@Ceiling - @PrevRemunerated  - @Remunerated) >= @WorkValue
						BEGIN
							--full amount of workvalue can be paid out as it under the limit
							SET @ExceedCeilingAmount = 0
							SET @SetPriceValuated = @WorkValue
							SET @SetPriceRemunerated = @WorkValue
							SET @Remunerated = @Remunerated + @WorkValue
							GOTO NextService
						END
						ELSE
						BEGIN
							SET @ExceedCeilingAmount = @WorkValue - (@Ceiling - @PrevRemunerated  - @Remunerated)			
							SET @SetPriceValuated = (@Ceiling - @PrevRemunerated  - @Remunerated)
							SET @SetPriceRemunerated = (@Ceiling - @PrevRemunerated  - @Remunerated)
							SET @Remunerated = @Remunerated + (@Ceiling - @PrevRemunerated  - @Remunerated)			
							GOTO NextService
						END
					
					END
					ELSE
					BEGIN
						SET @ExceedCeilingAmount = @WorkValue
						SET @Remunerated = @Remunerated + 0
						SET @SetPriceValuated = 0
						SET @SetPriceRemunerated = 0
						GOTO NextService
					END
				END
				ELSE
				BEGIN
					-->
					SET @ExceedCeilingAmount = 0
					SET @Remunerated = @Remunerated + @WorkValue
					SET @SetPriceValuated = @WorkValue
					SET @SetPriceRemunerated = @WorkValue
					GOTO NextService
				END

			END

NextService:
			IF @IsProcess = 1 
			BEGIN
				IF @PriceOrigin = 'R'
				BEGIN
					UPDATE tblClaimServices SET PriceAdjusted = @SetPriceAdjusted , PriceValuated = @SetPriceValuated , DeductableAmount = @SetPriceDeducted , ExceedCeilingAmount = @ExceedCeilingAmount , @ExceedCeilingAmountCategory  = @ExceedCeilingAmountCategory  WHERE ClaimServiceID = @ClaimServiceID 
					SET @RelativePrices = 1 
				END
				ELSE
				BEGIN
					UPDATE tblClaimServices SET PriceAdjusted = @SetPriceAdjusted , PriceValuated = @SetPriceValuated , DeductableAmount = @SetPriceDeducted ,ExceedCeilingAmount = @ExceedCeilingAmount, @ExceedCeilingAmountCategory  = @ExceedCeilingAmountCategory, RemuneratedAmount = @SetPriceRemunerated WHERE ClaimServiceID = @ClaimServiceID 
				END
			END
			
			FETCH NEXT FROM CLAIMSERVICELOOP INTO @ClaimServiceId, @QtyProvided, @QtyApproved ,@PriceAsked, @PriceApproved, @PLPrice, @PriceOrigin, @Limitation, @Limitationvalue,@ServCategory,@CeilingExclusionAdult,@CeilingExclusionChild
		END
		CLOSE CLAIMSERVICELOOP
		DEALLOCATE CLAIMSERVICELOOP 
		
		
		FETCH NEXT FROM PRODUCTLOOP INTO	@ProductID, @PolicyID,@DedInsuree,@DedOPInsuree,@DedIPInsuree,@MaxInsuree,@MaxOPInsuree,@MaxIPInsuree,@DedTreatment,@DedOPTreatment,@DedIPTreatment,
											@MaxIPTreatment,@MaxTreatment,@MaxOPTreatment,@DedPolicy,@DedOPPolicy,@DedIPPolicy,@MaxPolicy,@MaxOPPolicy,@MaxIPPolicy,@CeilingConsult,@CeilingSurgery,@CeilingHospitalization,@CeilingDelivery,@CeilingAntenatal,
											@Treshold, @MaxPolicyExtraMember,@MaxPolicyExtraMemberIP,@MaxPolicyExtraMemberOP,@MaxCeilingPolicy,@MaxCeilingPolicyIP,@MaxCeilingPolicyOP,@CeilingInterpretation
	
	END
	CLOSE PRODUCTLOOP
	DEALLOCATE PRODUCTLOOP 
	
	--Now insert the total renumerations and deductions on this claim 
	
	If @IsProcess = 1 
	BEGIN
		--delete first the policy entry in the table tblClaimDedRem as it was a temporary booking
		DELETE FROM tblClaimDedRem WHERE ClaimID = @ClaimID -- AND PolicyID = @PolicyID AND InsureeID = @InsureeID 
	END

	IF (@CeilingInterpretation = 'I' AND  @Hospitalization = 1) OR (@CeilingInterpretation = 'H' AND @HFLevel = 'H' )
	BEGIN 
		INSERT INTO tblClaimDedRem ([PolicyID],[InsureeID],[ClaimID],[DedG],[RemG],[DedIP],[RemIP],[RemConsult],[RemSurgery] ,[RemHospitalization] ,[RemDelivery] , [RemAntenatal] , [AuditUserID]) VALUES (@PolicyID,@InsureeID , @ClaimID , @Deducted ,@Remunerated ,@Deducted ,@Remunerated , @RemuneratedConsult  , @RemuneratedSurgery  ,@RemuneratedHospitalization , @RemuneratedDelivery  , @RemuneratedAntenatal,@AuditUser) 
	END
	ELSE
	BEGIN 
		INSERT INTO tblClaimDedRem ([PolicyID],[InsureeID],[ClaimID],[DedG],[RemG],[DedOP],[RemOP], [RemConsult],[RemSurgery] ,[RemHospitalization] ,[RemDelivery], [RemAntenatal] ,  [AuditUserID]) VALUES (@PolicyID,@InsureeID , @ClaimID , @Deducted ,@Remunerated ,@Deducted ,@Remunerated , @RemuneratedConsult  , @RemuneratedSurgery  ,@RemuneratedHospitalization , @RemuneratedDelivery , @RemuneratedAntenatal ,@AuditUser) 
	END
	
	If @IsProcess = 1 
	BEGIN
		IF @RelativePrices = 0
		BEGIN
			--update claim in total and set to Valuated
			UPDATE tblClaim SET ClaimStatus = 16, AuditUserIDProcess = @AuditUser, ProcessStamp = GETDATE(), DateProcessed = GETDATE() WHERE ClaimID = @ClaimID 
			SET @RtnStatus = 4
		END
		ELSE
		BEGIN
			--update claim in total and set to Processed --> awaiting one or more Services for relative prices
			UPDATE tblClaim SET ClaimStatus = 8, AuditUserIDProcess = @AuditUser, ProcessStamp = GETDATE(), DateProcessed = GETDATE() WHERE ClaimID = @ClaimID 
			SET @RtnStatus = 3
		END  
	
		UPDATE tblClaim SET FeedbackStatus = 16 WHERE ClaimID = @ClaimID AND FeedbackStatus = 4 
		UPDATE tblClaim SET ReviewStatus = 16 WHERE ClaimID = @ClaimID AND ReviewStatus = 4 
	END


	
FINISH:
	RETURN @oReturnValue
	
	END TRY
	
	BEGIN CATCH
		SELECT 'Unexpected error encountered'
		SET @oReturnValue = 1 
		RETURN @oReturnValue
		
	END CATCH
END







GO
