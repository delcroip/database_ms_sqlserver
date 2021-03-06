/****** Object:  StoredProcedure [dbo].[uspExportOffLineExtract3]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspExportOffLineExtract3]
	 @RegionId INT = 0,
	 @DistrictId INT = 0,
	 @RowID as bigint = 0,
	 @isFullExtract bit=0
	
AS
BEGIN
	SET NOCOUNT ON
	
	--**tblICDCodes**
	SELECT [ICDID],[ICDCode],[ICDName],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID] FROM [dbo].[tblICDCodes] WHERE RowID > @RowID 
	
	--**HF**
	SELECT [HfID],[HFCode],[HFName],[LegalForm],[HFLevel],[HFSublevel],[HFAddress],[LocationId],[Phone],[Fax],[eMail],[HFCareType],[PLServiceID],[PLItemID],[AccCode],[OffLine],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID] FROM [dbo].[tblHF] WHERE RowID > @RowID --AND (CASE @LocationId  WHEN 0 THEN 0 ELSE [DistrictID]  END) = @LocationId
	
	
	;WITH Family AS (
	SELECT F.[FamilyID]
	FROM [dbo].[tblFamilies] F 
	INNER JOIN tblVillages V ON V.VillageID = F.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	WHERE F.RowID > @RowID 
	
	AND (@RegionId =0 or (
	((CASE @DistrictId  WHEN 0 THEN 0 ELSE D.[DistrictID]  END) = @DistrictId) AND
	((CASE @DistrictId  WHEN 0 THEN  D.Region  ELSE @RegionId END) = @RegionId)
	))
	UNION 
	SELECT F.[FamilyID]
	FROM tblFamilies F 
	INNER JOIN tblInsuree I ON F.FamilyId = I.FamilyID
	INNER JOIN tblHF HF ON I.HFId = HF.HfID
	WHERE F.RowID > @RowID 
	AND (CASE @DistrictId  WHEN 0 THEN 0 ELSE HF.[LocationId]  END) = @DistrictId 
	)
	SELECT * INTO #FamiliesWProd From Family



	--**tblPayer**
	; WITH Payers As(
	SELECT [PayerID],[PayerType],[PayerName],[PayerAddress],P.[LocationId],[Phone],[Fax],[eMail],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID] FROM [dbo].[tblPayer]  p
	LEFT JOIN uvwLocations L ON L.LocationId = p.LocationId
	WHERE RowID > @RowID  
		  AND ( L.RegionId = @RegionId OR @RegionId =0 OR P.LocationId IS NULL )  
		  AND (L.DistrictId =@DistrictId OR L.DistrictId IS NULL OR @DistrictId =0 )
	UNION ALL
	SELECT Pay.[PayerID],[PayerType],[PayerName],[PayerAddress],Pay.[LocationId],[Phone],[Fax],[eMail],Pay.[ValidityFrom], Pay.[ValidityTo], Pay.[LegacyID], Pay.[AuditUserID] 
	FROM [dbo].[tblPayer] Pay
	INNER JOIN tblPremium PR ON PR.PayerID = Pay.PayerID OR  PR.PayerID = Pay.LegacyID
	INNER JOIN tblPolicy PL ON PL.PolicyId = PR.PolicyId
	INNER JOIN tblFamilies F ON F.FamilyId = PL.FamilyID
	INNER JOIN tblVillages V ON V.VillageId = F.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictID = W.DistrictId
	WHERE  Pay.RowID > @RowID 
		AND (((CASE @DistrictId  WHEN 0 THEN 0 ELSE D.[DistrictId]  END) = @DistrictId) OR D.Region = @RegionId) 
	
	)
	SELECT * FROM Payers Pay
	GROUP BY Pay.[PayerID],[PayerType],[PayerName],[PayerAddress],Pay.[LocationId],[Phone],[Fax],[eMail],Pay.[ValidityFrom], Pay.[ValidityTo], Pay.[LegacyID], Pay.[AuditUserID]
	

	--**tblOfficer**
	--SELECT [OfficerID],[Code],[LastName],[OtherNames],[DOB],[Phone],[DistrictID],[OfficerIDSubst],[WorksTo],[VEOCode],[VEOLastName],[VEOOtherNames],[VEODOB],[VEOPhone],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID],EmailId FROM [dbo].[tblOfficer]  WHERE RowID > @RowID AND (CASE @LocationId  WHEN 0 THEN 0 ELSE [DistrictID]  END) = @LocationId
	; WITH Officer AS (
	SELECT [OfficerID],[Code],[LastName],[OtherNames],[DOB],[Phone],[LocationId],[OfficerIDSubst],[WorksTo],[VEOCode],[VEOLastName],[VEOOtherNames],[VEODOB],[VEOPhone],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID],EmailId, PhoneCommunication,PermanentAddress FROM [dbo].[tblOfficer] 
	WHERE RowID > @RowID 
	AND (CASE @DistrictId  WHEN 0 THEN 0 ELSE [LocationId]  END) = @DistrictId
	UNION ALL
	 SELECT O.[OfficerID],[Code],O.[LastName],O.[OtherNames],O.[DOB],O.[Phone],O.[LocationId],[OfficerIDSubst],[WorksTo],[VEOCode],[VEOLastName],[VEOOtherNames],[VEODOB],[VEOPhone],O.[ValidityFrom],O.[ValidityTo],O.[LegacyID],O.[AuditUserID],EmailId, O.PhoneCommunication,O.PermanentAddress FROM [dbo].[tblOfficer] O 
	INNER JOIN tblPolicy P ON P.OfficerID = O.OfficerID
	INNER JOIN #FamiliesWProd F ON F.FamilyID =P.FamilyID
	UNION  ALL
	SELECT O.[OfficerID],[Code],[LastName],[OtherNames],[DOB],[Phone],O.[LocationId],[OfficerIDSubst],[WorksTo],[VEOCode],[VEOLastName],[VEOOtherNames],[VEODOB],[VEOPhone],O.[ValidityFrom], O.[ValidityTo], O.[LegacyID], O.[AuditUserID],EmailId, PhoneCommunication,PermanentAddress
	FROM [dbo].[tblOfficer]  O 
	INNER JOIN tblPolicy PL ON PL.OfficerId = O.OfficerID
	INNER JOIN tblFamilies F ON F.Familyid = PL.FamilyID
	INNER JOIN tblVillages V ON V.VillageID = F.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	WHERE O.RowID > @RowID AND ((CASE @DistrictId  WHEN 0 THEN 0 ELSE D.[DistrictID]  END) = @DistrictId OR D.Region =@RegionId)
	 )
	SELECT * FROM Officer O
	GROUP BY O.[OfficerID],[Code],O.[LastName],O.[OtherNames],O.[DOB],O.[Phone],O.[LocationId],[OfficerIDSubst],[WorksTo],[VEOCode],[VEOLastName],[VEOOtherNames],[VEODOB],[VEOPhone],O.[ValidityFrom],O.[ValidityTo],O.[LegacyID],O.[AuditUserID],EmailId, PhoneCommunication,PermanentAddress
	

	--**Product  Changed on 11.11.2017**
	

	; WITH Product AS (
	  SELECT [ProdID],[ProductCode],[ProductName],P.[LocationId],[InsurancePeriod],[DateFrom],[DateTo],[ConversionProdID],[LumpSum],[MemberCount],[PremiumAdult],[PremiumChild],[DedInsuree],[DedOPInsuree],[DedIPInsuree],[MaxInsuree],[MaxOPInsuree],[MaxIPInsuree],[PeriodRelPrices],[PeriodRelPricesOP],[PeriodRelPricesIP],[AccCodePremiums],[AccCodeRemuneration],[DedTreatment],[DedOPTreatment],[DedIPTreatment],[MaxTreatment],[MaxOPTreatment],[MaxIPTreatment],[DedPolicy],[DedOPPolicy],[DedIPPolicy],[MaxPolicy],[MaxOPPolicy],[MaxIPPolicy],[GracePeriod],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID],[RegistrationLumpSum],[RegistrationFee],[GeneralAssemblyLumpSum],[GeneralAssemblyFee],[StartCycle1],[StartCycle2],[MaxNoConsultation],[MaxNoSurgery],[MaxNoDelivery],[MaxNoHospitalizaion],[MaxNoVisits],[MaxAmountConsultation],[MaxAmountSurgery],[MaxAmountDelivery],[MaxAmountHospitalization],[GracePeriodRenewal],[MaxInstallments],[WaitingPeriod]
		,RenewalDiscountPerc,RenewalDiscountPeriod,StartCycle3,StartCycle4,AdministrationPeriod,Threshold
		,MaxPolicyExtraMember,MaxPolicyExtraMemberIP,MaxPolicyExtraMemberOP,MaxCeilingPolicy,MaxCeilingPolicyIP,MaxCeilingPolicyOP, EnrolmentDiscountPeriod, EnrolmentDiscountPerc,MaxAmountAntenatal,MaxNoAntenatal,CeilingInterpretation,[Level1],[Sublevel1],[Level2],[Sublevel2],[Level3],[Sublevel3],[Level4],[Sublevel4],[ShareContribution],[WeightPopulation],WeightNumberFamilies,[WeightInsuredPopulation],[WeightNumberInsuredFamilies],[WeightNumberVisits],[WeightAdjustedAmount] FROM [dbo].[tblProduct]  P
		INNER JOIN uvwLocations L ON ISNULL(L.LocationId,0) = ISNULL(P.LocationId,0)
		WHERE  RowID > @RowID  
		AND (L.RegionId = @RegionId OR @RegionId =0 OR L.LocationId =0  )  
		AND (L.DistrictId =@DistrictId OR L.DistrictId IS NULL OR @DistrictId =0 )
		
		UNION  ALL
		
		SELECT Prod.[ProdID],[ProductCode],[ProductName],[LocationId],[InsurancePeriod],[DateFrom],[DateTo],[ConversionProdID],[LumpSum],[MemberCount],[PremiumAdult],[PremiumChild],[DedInsuree],[DedOPInsuree],[DedIPInsuree],[MaxInsuree],[MaxOPInsuree],[MaxIPInsuree],[PeriodRelPrices],[PeriodRelPricesOP],[PeriodRelPricesIP],[AccCodePremiums],[AccCodeRemuneration],[DedTreatment],[DedOPTreatment],[DedIPTreatment],[MaxTreatment],[MaxOPTreatment],[MaxIPTreatment],[DedPolicy],[DedOPPolicy],[DedIPPolicy],[MaxPolicy],[MaxOPPolicy],[MaxIPPolicy],[GracePeriod],Prod.[ValidityFrom],Prod.[ValidityTo],Prod.[LegacyID],Prod.[AuditUserID],[RegistrationLumpSum],[RegistrationFee],[GeneralAssemblyLumpSum],[GeneralAssemblyFee],[StartCycle1],[StartCycle2],[MaxNoConsultation],[MaxNoSurgery],[MaxNoDelivery],[MaxNoHospitalizaion],[MaxNoVisits],[MaxAmountConsultation],[MaxAmountSurgery],[MaxAmountDelivery],[MaxAmountHospitalization],[GracePeriodRenewal],[MaxInstallments],[WaitingPeriod]
		,RenewalDiscountPerc,RenewalDiscountPeriod,StartCycle3,StartCycle4,AdministrationPeriod,Threshold
		,MaxPolicyExtraMember,MaxPolicyExtraMemberIP,MaxPolicyExtraMemberOP,MaxCeilingPolicy,MaxCeilingPolicyIP,MaxCeilingPolicyOP, EnrolmentDiscountPeriod, EnrolmentDiscountPerc,MaxAmountAntenatal,MaxNoAntenatal,CeilingInterpretation,[Level1],[Sublevel1],[Level2],[Sublevel2],[Level3],[Sublevel3],[Level4],[Sublevel4],[ShareContribution],[WeightPopulation],WeightNumberFamilies,[WeightInsuredPopulation],[WeightNumberInsuredFamilies],[WeightNumberVisits],[WeightAdjustedAmount]
		 FROM tblProduct Prod
		INNER JOIN tblPolicy P ON Prod.ProdID = P.ProdID
		INNER JOIN #FamiliesWProd F ON F.FamilyID = P.FamilyID
	)
	SELECT * FROM Product Prod

	--ADDED
	UNION
	SELECT 
	Prod.[ProdID],[ProductCode],[ProductName],Prod.[LocationId],[InsurancePeriod],[DateFrom],[DateTo],[ConversionProdID],[LumpSum],[MemberCount],[PremiumAdult],[PremiumChild],[DedInsuree],[DedOPInsuree],[DedIPInsuree],[MaxInsuree],[MaxOPInsuree],[MaxIPInsuree],[PeriodRelPrices],[PeriodRelPricesOP],[PeriodRelPricesIP],[AccCodePremiums],[AccCodeRemuneration],[DedTreatment],[DedOPTreatment],[DedIPTreatment],[MaxTreatment],[MaxOPTreatment],[MaxIPTreatment],[DedPolicy],[DedOPPolicy],[DedIPPolicy],[MaxPolicy],[MaxOPPolicy],[MaxIPPolicy],[GracePeriod], Prod.[ValidityFrom], Prod.[ValidityTo], Prod.[LegacyID], Prod.[AuditUserID],[RegistrationLumpSum],[RegistrationFee],[GeneralAssemblyLumpSum],[GeneralAssemblyFee],[StartCycle1],[StartCycle2],[MaxNoConsultation],[MaxNoSurgery],[MaxNoDelivery],[MaxNoHospitalizaion],[MaxNoVisits],[MaxAmountConsultation],[MaxAmountSurgery],[MaxAmountDelivery],[MaxAmountHospitalization],[GracePeriodRenewal],[MaxInstallments],[WaitingPeriod]
	,RenewalDiscountPerc,RenewalDiscountPeriod,StartCycle3,StartCycle4,AdministrationPeriod,Threshold
	,MaxPolicyExtraMember,MaxPolicyExtraMemberIP,MaxPolicyExtraMemberOP,MaxCeilingPolicy,MaxCeilingPolicyIP,MaxCeilingPolicyOP, EnrolmentDiscountPeriod, EnrolmentDiscountPerc,MaxAmountAntenatal,MaxNoAntenatal,CeilingInterpretation,[Level1],[Sublevel1],[Level2],[Sublevel2],[Level3],[Sublevel3],[Level4],[Sublevel4],[ShareContribution],[WeightPopulation],WeightNumberFamilies,[WeightInsuredPopulation],[WeightNumberInsuredFamilies],[WeightNumberVisits],[WeightAdjustedAmount]
	 FROM tblProduct Prod WHERE ProdID IN (	SELECT ConversionProdID FROM Product WHERE NOT ConversionProdID IS NULL)
	 --END ADDED

	GROUP BY  Prod.[ProdID],[ProductCode],[ProductName],Prod.[LocationId],[InsurancePeriod],[DateFrom],[DateTo],[ConversionProdID],[LumpSum],[MemberCount],[PremiumAdult],[PremiumChild],[DedInsuree],[DedOPInsuree],[DedIPInsuree],[MaxInsuree],[MaxOPInsuree],[MaxIPInsuree],[PeriodRelPrices],[PeriodRelPricesOP],[PeriodRelPricesIP],[AccCodePremiums],[AccCodeRemuneration],[DedTreatment],[DedOPTreatment],[DedIPTreatment],[MaxTreatment],[MaxOPTreatment],[MaxIPTreatment],[DedPolicy],[DedOPPolicy],[DedIPPolicy],[MaxPolicy],[MaxOPPolicy],[MaxIPPolicy],[GracePeriod], Prod.[ValidityFrom], Prod.[ValidityTo], Prod.[LegacyID], Prod.[AuditUserID],[RegistrationLumpSum],[RegistrationFee],[GeneralAssemblyLumpSum],[GeneralAssemblyFee],[StartCycle1],[StartCycle2],[MaxNoConsultation],[MaxNoSurgery],[MaxNoDelivery],[MaxNoHospitalizaion],[MaxNoVisits],[MaxAmountConsultation],[MaxAmountSurgery],[MaxAmountDelivery],[MaxAmountHospitalization],[GracePeriodRenewal],[MaxInstallments],[WaitingPeriod]
	,RenewalDiscountPerc,RenewalDiscountPeriod,StartCycle3,StartCycle4,AdministrationPeriod,Threshold
	,MaxPolicyExtraMember,MaxPolicyExtraMemberIP,MaxPolicyExtraMemberOP,MaxCeilingPolicy,MaxCeilingPolicyIP,MaxCeilingPolicyOP, EnrolmentDiscountPeriod, EnrolmentDiscountPerc,MaxAmountAntenatal,MaxNoAntenatal,CeilingInterpretation,[Level1],[Sublevel1],[Level2],[Sublevel2],[Level3],[Sublevel3],[Level4],[Sublevel4],[ShareContribution],[WeightPopulation],WeightNumberFamilies,[WeightInsuredPopulation],[WeightNumberInsuredFamilies],[WeightNumberVisits],[WeightAdjustedAmount]
	
	--**End Product
	--**ProductItems**
	SELECT [ProdItemID],[tblProductItems].[ProdID],[ItemID],[LimitationType],[PriceOrigin],[LimitAdult],[LimitChild],[tblProductItems].[ValidityFrom] ,[tblProductItems].[ValidityTo],[tblProductItems].[LegacyID],[tblProductItems].[AuditUserID],[WaitingPeriodAdult],[WaitingPeriodChild],[LimitNoAdult],[LimitNoChild],LimitationTypeR,LimitationTypeE,LimitAdultR,LimitAdultE,LimitChildR,LimitChildE,CeilingExclusionAdult,CeilingExclusionChild FROM [dbo].[tblProductItems] 
	INNER JOIN [dbo].[tblProduct] P ON P.ProdID = tblProductItems.ProdID  
	INNER JOIN uvwLocations L ON ISNULL(L.LocationId,0) = ISNULL(P.LocationId,0)
	WHERE tblProductItems.RowID  > @RowID 
	    AND (L.RegionId = @RegionId OR @RegionId =0 OR L.LocationId =0  )  
		AND (L.DistrictId =@DistrictId OR L.DistrictId IS NULL OR @DistrictId =0 )

	--**ProductServices**
	SELECT [ProdServiceID],[dbo].[tblProductServices].[ProdID],[ServiceID],[LimitationType],[PriceOrigin],[LimitAdult],[LimitChild],[dbo].[tblProductServices].[ValidityFrom],[dbo].[tblProductServices].[ValidityTo],[dbo].[tblProductServices].[LegacyID],[dbo].[tblProductServices].[AuditUserID],[WaitingPeriodAdult],[WaitingPeriodChild],[LimitNoAdult],[LimitNoChild],LimitationTypeR,LimitationTypeE,LimitAdultR,LimitAdultE,LimitChildR,LimitChildE,CeilingExclusionAdult,CeilingExclusionChild FROM [dbo].[tblProductServices]
	 INNER JOIN [dbo].[tblProduct] P ON P.ProdID = tblProductServices.ProdID  
	 INNER JOIN uvwLocations L ON ISNULL(L.LocationId,0) = ISNULL(P.LocationId,0)
	WHERE tblProductServices.RowID  > @RowID 
	    AND (L.RegionId = @RegionId OR @RegionId =0 OR L.LocationId =0  )  
		AND (L.DistrictId =@DistrictId OR L.DistrictId IS NULL OR @DistrictId =0 ) 

	--**Product-RelDistr**
	SELECT [DistrID],[DistrType] ,[DistrCareType],[dbo].[tblRelDistr].[ProdID],[Period],[DistrPerc],[dbo].[tblRelDistr].[ValidityFrom],[dbo].[tblRelDistr].[ValidityTo],[dbo].[tblRelDistr].[LegacyID],[dbo].[tblRelDistr].[AuditUserID] 
	FROM [dbo].[tblRelDistr] 
	INNER JOIN [dbo].[tblProduct] P ON P.ProdID = tblRelDistr.ProdID   
	INNER JOIN uvwLocations L ON ISNULL(L.LocationId,0) = ISNULL(P.LocationId,0)
	WHERE [tblRelDistr].RowID  > @RowID 
	    AND (L.RegionId = @RegionId OR @RegionId =0 OR L.LocationId =0  )  
		AND (L.DistrictId =@DistrictId OR L.DistrictId IS NULL OR @DistrictId =0 ) 

	--**tblClaimAdmin**
	SELECT ClaimAdminId,ClaimAdminCode,LastName,OtherNames,DOB,CA.Phone,CA.HFId,CA.ValidityFrom,CA.ValidityTo,CA.LegacyId,CA.AuditUserId,EmailId 
	FROM tblClaimAdmin CA 
	INNER JOIN tblHF HF ON CA.HFId = HF.HfID 
	WHERE CA.RowId > @RowID
	AND (HF.LocationId = @DistrictId OR @DistrictId = 0)



	--********S tblOfficerVillage 
; WITH OfficerVillage AS (
	SELECT [OfficerID],[Code],[LastName],[OtherNames],[DOB],[Phone],[LocationId],[OfficerIDSubst],[WorksTo],[VEOCode],[VEOLastName],[VEOOtherNames],[VEODOB],[VEOPhone],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID],EmailId, PhoneCommunication,PermanentAddress FROM [dbo].[tblOfficer] 
	WHERE RowID > @RowID 
	AND (CASE @DistrictId  WHEN 0 THEN 0 ELSE [LocationId]  END) = @DistrictId
	UNION ALL
	 SELECT O.[OfficerID],[Code],O.[LastName],O.[OtherNames],O.[DOB],O.[Phone],O.[LocationId],[OfficerIDSubst],[WorksTo],[VEOCode],[VEOLastName],[VEOOtherNames],[VEODOB],[VEOPhone],O.[ValidityFrom],O.[ValidityTo],O.[LegacyID],O.[AuditUserID],EmailId, O.PhoneCommunication,O.PermanentAddress FROM [dbo].[tblOfficer] O 
	INNER JOIN tblPolicy P ON P.OfficerID = O.OfficerID
	INNER JOIN #FamiliesWProd F ON F.FamilyID =P.FamilyID
	UNION  ALL
	SELECT O.[OfficerID],[Code],[LastName],[OtherNames],[DOB],[Phone],O.[LocationId],[OfficerIDSubst],[WorksTo],[VEOCode],[VEOLastName],[VEOOtherNames],[VEODOB],[VEOPhone],O.[ValidityFrom], O.[ValidityTo], O.[LegacyID], O.[AuditUserID],EmailId, PhoneCommunication,PermanentAddress
	FROM [dbo].[tblOfficer]  O 
	INNER JOIN tblPolicy PL ON PL.OfficerId = O.OfficerID
	INNER JOIN tblFamilies F ON F.Familyid = PL.FamilyID
	INNER JOIN tblVillages V ON V.VillageID = F.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
	WHERE O.RowID > @RowID AND ((CASE @DistrictId  WHEN 0 THEN 0 ELSE D.[DistrictID]  END) = @DistrictId OR D.Region =@RegionId)
	 )
	SELECT OV.OfficerVillageId, OV.OfficerId, OV.LocationId, OV.ValidityFrom, OV.ValidityTo, OV.LegacyId, OV.AuditUserId FROM  tblOfficerVillages OV
	INNER JOIN OfficerVillage O ON O.OfficerID = OV.OfficerId
	GROUP BY OV.OfficerVillageId, OV.OfficerId, OV.LocationId, OV.ValidityFrom, OV.ValidityTo, OV.LegacyId, OV.AuditUserId
	
	DROP TABLE #FamiliesWProd

	--*******E tblOffficerVillage

	--Get Genders
	SELECT Code, Gender, AltLanguage,SortOrder FROM tblGender WHERE @isFullExtract = 1
END

GO
