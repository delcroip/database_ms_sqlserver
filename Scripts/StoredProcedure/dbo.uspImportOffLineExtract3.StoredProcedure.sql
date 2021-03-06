/****** Object:  StoredProcedure [dbo].[uspImportOffLineExtract3]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspImportOffLineExtract3]
(

	@HFID as int = 0,
	@DistrictId INT = 0,
	@AuditUser as int = 0 ,
	@xtICDCodes dbo.xICDCodes READONLY,
	@xtHF dbo.xHF READONLY,
	@xtOfficers dbo.xOfficers READONLY,
	@xtPayers dbo.xPayers READONLY,
	@xtProduct dbo.xProduct READONLY,
	@xtProductItems dbo.xProductItems READONLY,
	@xtProductServices dbo.xProductServices READONLY,
	@xtRelDistr dbo.xRelDistr READONLY,
	@xtClaimAdmin dbo.xClaimAdmin READONLY,
	@xtVillageOfficer dbo.xOfficerVillages READONLY,
	@xGender as dbo.xGender READONLY,

	@ICDIns as bigint = 0 OUTPUT  ,
	@ICDUpd as bigint = 0 OUTPUT  ,
	@HFIns as bigint = 0 OUTPUT  ,
	@HFUpd as bigint  = 0 OUTPUT  ,
	@PayersIns as bigint = 0 OUTPUT  ,
	@PayersUpd as bigint  = 0 OUTPUT,
	@OfficersIns as bigint = 0 OUTPUT  ,
	@OfficersUpd as bigint  = 0 OUTPUT , 
	@ProductIns as bigint = 0 OUTPUT  ,
	@ProductUpd as bigint  = 0 OUTPUT,
	@ProductItemsIns as bigint = 0 OUTPUT  ,
	@ProductItemsUpd as bigint  = 0 OUTPUT,
	@ProductServicesIns as bigint = 0 OUTPUT  ,
	@ProductServicesUpd as bigint  = 0 OUTPUT,
	@RelDistrIns as bigint = 0 OUTPUT  ,
	@RelDistrUpd as bigint  = 0 OUTPUT,
	@ClaimAdminIns BIGINT = 0 OUTPUT,
	@ClaimAdminUpd BIGINT = 0 OUTPUT,
	@OfficerVillageIns BIGINT = 0 OUTPUT,
	@OfficerVillageUpd BIGINT = 0 OUTPUT

)
AS
BEGIN
	
	--**S ICD**
	SET NOCOUNT OFF
	UPDATE Src SET Src.ICDCode = Etr.ICDCode , Src.ICDName = Etr.ICDName , Src.ValidityFrom = Etr.ValidityFrom , Src.ValidityTo = Etr.ValidityTo , Src.LegacyID = Etr.LegacyID, Src.AuditUserID = @AuditUser  FROM tblICDCodes  Src , @xtICDCodes  Etr WHERE Src.ICDID  = Etr.ICDID   
	SET @ICDUpd  = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF;
	SET IDENTITY_INSERT [tblICDCodes] ON
	
	INSERT INTO tblICDCodes ([ICDID],[ICDCode],[ICDName],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID]) 
	SELECT [ICDID],[ICDCode],[ICDName],[ValidityFrom],[ValidityTo],[LegacyID],@AuditUser FROM @xtICDCodes  WHERE [ICDID] NOT IN 
	(SELECT ICDID FROM tblICDCodes)
	
	SET @ICDIns  = @@ROWCOUNT
	SET IDENTITY_INSERT [tblICDCodes] OFF
	SET NOCOUNT ON
	--**E ICD**
	
	--**S HF**
	SET NOCOUNT OFF
	UPDATE Src SET Src.HFCode = Etr.HFCode,Src.HFName=Etr.HFName,Src.LegalForm=Etr.LegalForm ,Src.HFLevel=Etr.HFLevel,Src.HFSublevel = Etr.HFSublevel ,Src.HFAddress=Etr.HFAddress,Src.LocationId=Etr.LocationId,Src.Phone=Etr.Phone,Src.Fax= Etr.Fax,Src.eMail=Etr.eMail,Src.HFCareType=Etr.HFCareType,Src.PLServiceID=Etr.PLServiceID,Src.PLItemID=Etr.PLItemID,Src.AccCode= Etr.AccCode ,Src.[OffLine] = Etr.[offLine] , Src.ValidityFrom = Etr.ValidityFrom , Src.ValidityTo = Etr.ValidityTo , Src.LegacyID = Etr.LegacyID, Src.AuditUserID = @AuditUser  FROM tblHF  Src , @xtHF  Etr WHERE Src.HFID  = Etr.HFID   
	SET @HFUpd  = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF;
	SET IDENTITY_INSERT [tblHF] ON
	
	INSERT INTO tblHF ([HfID],[HFCode],[HFName],[LegalForm],[HFLevel],[HFSublevel],[HFAddress],[LocationId],[Phone],[Fax],[eMail],[HFCareType],[PLServiceID],[PLItemID],[AccCode],[OffLine],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID])
	SELECT [HfID],[HFCode],[HFName],[LegalForm],[HFLevel],[HFSublevel],[HFAddress],[LocationId],[Phone],[Fax],[eMail],[HFCareType],[PLServiceID],[PLItemID],[AccCode],[OffLine],[ValidityFrom],[ValidityTo],[LegacyID],@AuditUser 
	FROM @xtHF  WHERE [HFID]  NOT IN
	(SELECT HfID from tblHF)
	
	SET @HFIns = @@ROWCOUNT
	SET IDENTITY_INSERT [tblHF] OFF
	SET NOCOUNT ON
	--**E HF**
	
	--**S Officers**
	SET NOCOUNT OFF
	UPDATE Src  SET Src.Code= Etr.Code ,Src.LastName= Etr.LastName ,Src.OtherNames = Etr.OtherNames ,Src.DOB =Etr.DOB ,Src.Phone = Etr.Phone ,Src.LocationId = Etr.LocationId ,Src.OfficerIDSubst = Etr.OfficerIDSubst ,Src.WorksTo = Etr.WorksTo ,Src.VEOCode = Etr.VEOCode ,Src.VEOLastName = Etr.VEOLastName ,Src.VEOOtherNames = Etr.VEOOtherNames ,Src.VEODOB = Etr.VEODOB ,Src.VEOPhone = Etr.VEOPhone ,Src.ValidityFrom = Etr.ValidityFrom , Src.ValidityTo = Etr.ValidityTo , Src.LegacyID = Etr.LegacyID, Src.AuditUserID = @AuditUser,Src.EmailId = Etr.EmailId, Src.PhoneCommunication = Etr.PhoneCommunication, Src.PermanentAddress=Etr.PermanentAddress  FROM tblOfficer Src , @xtOfficers Etr WHERE Src.OfficerID   = Etr.OfficerID   
	SET @OfficersUpd = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF;
	SET IDENTITY_INSERT [tblOfficer] ON
	
	INSERT INTO tblOfficer ([OfficerID],[Code],[LastName],[OtherNames],[DOB],[Phone],[LocationId],[OfficerIDSubst],[WorksTo],[VEOCode],[VEOLastName],[VEOOtherNames],[VEODOB],[VEOPhone],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID],EmailId, [PhoneCommunication],[PermanentAddress])
	SELECT [OfficerID],[Code],[LastName],[OtherNames],[DOB],[Phone],[LocationId],[OfficerIDSubst],[WorksTo],[VEOCode],[VEOLastName],[VEOOtherNames],[VEODOB],[VEOPhone],[ValidityFrom],[ValidityTo],[LegacyID],@AuditUser,EmailId, PhoneCommunication,PermanentAddress
	FROM @xtOfficers WHERE [OfficerID] NOT IN
	(SELECT OfficerID FROM tblOfficer)
	--AND (DistrictID = @DistrictId OR @DistrictId = 0) 'To do: Insuree can belong to different district.So his/her family's policy's officers belonging to another district should not be ruled out. 
	
	SET @OfficersIns = @@ROWCOUNT
	SET IDENTITY_INSERT [tblOfficer] OFF
	SET NOCOUNT ON
	--**E Offciers**
	
	--**S Payers**
	SET NOCOUNT OFF
	UPDATE Src  SET Src.PayerType = Etr.PayerType ,Src.PayerName = Etr.PayerName ,Src.PayerAddress = Etr.PayerAddress ,Src.LocationId = Etr.LocationId ,Src.Phone = Etr.Phone ,Src.Fax = Etr.Fax ,Src.eMail = Etr.eMail ,Src.ValidityFrom = Etr.ValidityFrom , Src.ValidityTo = Etr.ValidityTo , Src.LegacyID = Etr.LegacyID, Src.AuditUserID = @AuditUser  FROM tblPayer Src , @xtpayers Etr WHERE Src.PayerID   = Etr.PayerID   
	SET @PayersUpd = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF;
	SET IDENTITY_INSERT [tblPayer] ON
	
	INSERT INTO tblPayer ([PayerID],[PayerType],[PayerName],[PayerAddress],[LocationId],[Phone],[Fax],[eMail],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID])
	SELECT [PayerID],[PayerType],[PayerName],[PayerAddress],[LocationId],[Phone],[Fax],[eMail],[ValidityFrom],[ValidityTo],[LegacyID],@AuditUser FROM @xtPayers  WHERE [PayerID]  NOT IN
	(SELECT PayerID From tblPayer)
	--AND (DistrictID = @DistrictId OR DistrictId IS NULL)
	
	SET @PayersIns = @@ROWCOUNT
	SET IDENTITY_INSERT [tblPayer] OFF
	SET NOCOUNT ON
	--**E Payers**
	
	--**S Product**
	SET NOCOUNT OFF
	UPDATE Src SET Src.ProductCode = Etr.ProductCode ,Src.ProductName = Etr.ProductName ,Src.LocationId = Etr.LocationId ,Src.InsurancePeriod = Etr.InsurancePeriod ,Src.DateFrom = Etr.DateFrom ,Src.DateTo = Etr.DateTo ,Src.ConversionProdID = Etr.ConversionProdID ,Src.LumpSum = Etr.LumpSum ,Src.MemberCount = Etr.MemberCount ,Src.PremiumAdult = Etr.PremiumAdult ,Src.PremiumChild = Etr.PremiumChild ,Src.DedInsuree = Etr.DedInsuree ,Src.DedOPInsuree = Etr.DedOPInsuree ,Src.DedIPInsuree = Etr.DedIPInsuree ,Src.MaxInsuree = Etr.MaxInsuree ,Src.MaxOPInsuree = Etr.MaxOPInsuree ,Src.MaxIPInsuree = Etr.MaxIPInsuree ,Src.PeriodRelPrices = Etr.PeriodRelPrices  ,Src.PeriodRelPricesOP = Etr.PeriodRelPricesOP ,Src.PeriodRelPricesIP = Etr.PeriodRelPricesIP ,Src.AccCodePremiums = Etr.AccCodePremiums ,Src.AccCodeRemuneration = Etr.AccCodeRemuneration ,Src.DedTreatment = Etr.DedTreatment ,Src.DedOPTreatment = Etr.DedOPTreatment ,Src.DedIPTreatment = Etr.DedIPTreatment ,Src.MaxTreatment = Etr.MaxTreatment ,Src.MaxOPTreatment = Etr.MaxOPTreatment ,Src.MaxIPTreatment = Etr.MaxIPTreatment ,Src.DedPolicy = Etr.DedPolicy ,Src.DedOPPolicy = Etr.DedOPPolicy ,Src.DedIPPolicy = Etr.DedIPPolicy ,Src.MaxPolicy = Etr.MaxPolicy ,Src.MaxOPPolicy = Etr.MaxOPPolicy ,Src.MaxIPPolicy = Etr.MaxIPPolicy ,Src.GracePeriod = Etr.GracePeriod ,Src.ValidityFrom = Etr.ValidityFrom , Src.ValidityTo = Etr.ValidityTo , Src.LegacyID = Etr.LegacyID, Src.AuditUserID = @AuditUser,Src.RegistrationLumpSum = Etr.RegistrationLumpSum,Src.RegistrationFee = Etr.RegistrationFee,Src.GeneralAssemblyLumpSum = Etr.GeneralAssemblyLumpSum,Src.GeneralAssemblyFee = Etr.GeneralAssemblyFee,Src.StartCycle1 = Etr.StartCycle1,Src.StartCycle2 = Etr.StartCycle2,Src.MaxNoConsultation = Etr.MaxNoConsultation,Src.MaxNoSurgery = Etr.MaxNoSurgery,Src.MaxNoDelivery = Etr.MaxNoDelivery,Src.MaxNoHospitalizaion = Etr.MaxNoHospitalizaion,Src.MaxNoVisits = Etr.MaxNoVisits,Src.MaxAmountConsultation = Etr.MaxAmountConsultation,Src.MaxAmountSurgery = Etr.MaxAmountSurgery,Src.MaxAmountDelivery = Etr.MaxAmountDelivery,Src.MaxAmountHospitalization = Etr.MaxAmountHospitalization,Src.GracePeriodRenewal = Etr.GracePeriodRenewal, Src.MaxInstallments = Etr.MaxInstallments,Src.WaitingPeriod = Etr.WaitingPeriod,src.RenewalDiscountPerc = Etr.RenewalDiscountPerc,Src.RenewalDiscountPeriod = Etr.RenewalDiscountPeriod,Src.StartCycle3 = Etr.StartCycle3,Src.StartCycle4 = Etr.StartCycle4,Src.AdministrationPeriod = Etr.AdministrationPeriod,Src.Threshold = Etr.Threshold
		,Src.MaxPolicyExtraMember = Etr.MaxPolicyExtraMember,Src.MaxPolicyExtraMemberIP = Etr.MaxPolicyExtraMemberIP,Src.MaxPolicyExtraMemberOP = Etr.MaxPolicyExtraMemberOP,Src.MaxCeilingPolicy = Etr.MaxCeilingPolicy,Src.MaxCeilingPolicyIP = Etr.MaxCeilingPolicyIP,Src.MaxCeilingPolicyOP = Etr.MaxCeilingPolicyOP, Src.EnrolmentDiscountPerc = Etr.EnrolmentDiscountPerc, Src.EnrolmentDiscountPeriod = Etr.EnrolmentDiscountPeriod,Src.MaxAmountAntenatal = Etr.MaxAmountAntenatal,Src.MaxNoAntenatal = Etr.MaxNoAntenatal
		,Src.CeilingInterpretation = Etr.CeilingInterpretation,
		Src.Level1=Etr.Level1,
		Src.Sublevel1=Etr.Sublevel1,
		Src.Level2=Etr.Sublevel2,
		Src.Level3=Etr.Sublevel3,
		Src.Level4=Etr.Sublevel4,
		Src.ShareContribution=Etr.Sublevel1,
	Src.WeightPopulation=Etr.WeightPopulation,
	Src.WeightNumberFamilies =Etr.WeightNumberFamilies,
	Src.WeightInsuredPopulation=Etr.WeightInsuredPopulation,
	Src.WeightNumberInsuredFamilies=Etr.WeightNumberInsuredFamilies,
	Src.WeightNumberVisits=Etr.WeightNumberVisits,
	Src.WeightAdjustedAmount=Etr.WeightAdjustedAmount
		 FROM tblProduct Src , @xtProduct  Etr 
		WHERE Src.ProdID = Etr.ProdID   
	SET @ProductUpd = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF;
	SET IDENTITY_INSERT [tblProduct] ON
	
	INSERT INTO tblProduct ([ProdID],[ProductCode],[ProductName],[LocationId],[InsurancePeriod],[DateFrom],[DateTo],[ConversionProdID],[LumpSum],[MemberCount],[PremiumAdult],[PremiumChild],[DedInsuree],[DedOPInsuree],[DedIPInsuree],[MaxInsuree],[MaxOPInsuree],[MaxIPInsuree],[PeriodRelPrices],[PeriodRelPricesOP],[PeriodRelPricesIP],[AccCodePremiums],[AccCodeRemuneration],[DedTreatment],[DedOPTreatment],[DedIPTreatment],[MaxTreatment],[MaxOPTreatment],[MaxIPTreatment],[DedPolicy],[DedOPPolicy],[DedIPPolicy],[MaxPolicy],[MaxOPPolicy],[MaxIPPolicy],[GracePeriod],[ValidityFrom],[ValidityTo],[LegacyID],[AuditUserID],RegistrationLumpSum,RegistrationFee,GeneralAssemblyLumpSum,GeneralAssemblyFee,StartCycle1,StartCycle2,MaxNoConsultation,MaxNoSurgery,MaxNoDelivery,MaxNoHospitalizaion,MaxNoVisits,MaxAmountConsultation,MaxAmountSurgery,MaxAmountDelivery,MaxAmountHospitalization,GracePeriodRenewal,MaxInstallments,WaitingPeriod,RenewalDiscountPerc,RenewalDiscountPeriod,StartCycle3,StartCycle4,AdministrationPeriod,Threshold
		,MaxPolicyExtraMember,MaxPolicyExtraMemberIP,MaxPolicyExtraMemberOP,MaxCeilingPolicy,MaxCeilingPolicyIP,MaxCeilingPolicyOP, EnrolmentDiscountPerc, EnrolmentDiscountPeriod,MaxAmountAntenatal,MaxNoAntenatal,CeilingInterpretation, [Level1],[Sublevel1],[Level2] ,[Sublevel2] ,[Level3] ,[Sublevel3] ,[Level4] ,[Sublevel4] ,[ShareContribution],[WeightPopulation],[WeightNumberFamilies],[WeightInsuredPopulation] ,[WeightNumberInsuredFamilies] ,[WeightNumberVisits] ,[WeightAdjustedAmount] )
	SELECT [ProdID],[ProductCode],[ProductName],[LocationId],[InsurancePeriod],[DateFrom],[DateTo],[ConversionProdID],[LumpSum],[MemberCount],[PremiumAdult],[PremiumChild],[DedInsuree],[DedOPInsuree],[DedIPInsuree],[MaxInsuree],[MaxOPInsuree],[MaxIPInsuree],[PeriodRelPrices],[PeriodRelPricesOP],[PeriodRelPricesIP],[AccCodePremiums],[AccCodeRemuneration],[DedTreatment],[DedOPTreatment],[DedIPTreatment],[MaxTreatment],[MaxOPTreatment],[MaxIPTreatment],[DedPolicy],[DedOPPolicy],[DedIPPolicy],[MaxPolicy],[MaxOPPolicy],[MaxIPPolicy],[GracePeriod],[ValidityFrom],[ValidityTo],[LegacyID],@AuditUser,RegistrationLumpSum,RegistrationFee,GeneralAssemblyLumpSum,GeneralAssemblyFee,StartCycle1,StartCycle2,MaxNoConsultation,MaxNoSurgery,MaxNoDelivery,MaxNoHospitalizaion,MaxNoVisits,MaxAmountConsultation,MaxAmountSurgery,MaxAmountDelivery,MaxAmountHospitalization,GracePeriodRenewal,MaxInstallments,WaitingPeriod,RenewalDiscountPerc,RenewalDiscountPeriod,StartCycle3,StartCycle4,AdministrationPeriod,Threshold
		,MaxPolicyExtraMember,MaxPolicyExtraMemberIP,MaxPolicyExtraMemberOP,MaxCeilingPolicy,MaxCeilingPolicyIP,MaxCeilingPolicyOP, EnrolmentDiscountPerc, EnrolmentDiscountPeriod,MaxAmountAntenatal,MaxNoAntenatal,CeilingInterpretation, [Level1],[Sublevel1],[Level2] ,[Sublevel2] ,[Level3] ,[Sublevel3] ,[Level4] ,[Sublevel4] ,[ShareContribution],[WeightPopulation],[WeightNumberFamilies],[WeightInsuredPopulation] ,[WeightNumberInsuredFamilies] ,[WeightNumberVisits] ,[WeightAdjustedAmount]  FROM @xtProduct  
		WHERE [ProdID]  NOT IN (SELECT ProdID FROM tblProduct)
	--AND ((DistrictID = @DistrictId OR @DistrictId = 0) OR DistrictID IS NULL)
	
	SET @ProductIns = @@ROWCOUNT
	SET IDENTITY_INSERT [tblProduct] OFF
	SET NOCOUNT ON
	--**E Product**
	
	--**S ProductItems**
	SET NOCOUNT OFF
	UPDATE Src  SET Src.ProdID = Etr.ProdID ,Src.ItemID = Etr.ItemID ,Src.LimitationType = Etr.LimitationType ,Src.PriceOrigin = Etr.PriceOrigin ,Src.LimitAdult = Etr.LimitAdult ,Src.LimitChild = Etr.LimitChild  ,Src.ValidityFrom = Etr.ValidityFrom , Src.ValidityTo = Etr.ValidityTo , Src.LegacyID = Etr.LegacyID, Src.AuditUserID = @AuditUser,Src.WaitingPeriodAdult = Etr.WaitingPeriodAdult,Src.WaitingPeriodChild = Etr.WaitingPeriodChild,Src.LimitNoAdult = Etr.LimitNoChild,Src.LimitationTypeR = Etr.LimitationTypeR,Src.LimitationTypeE = Etr.LimitationTypeE,Src.LimitAdultR = Etr.LimitAdultR,Src.LimitAdultE = Etr.LimitAdultE,Src.LimitChildR = Etr.LimitChildR,Src.LimitChildE = Etr.LimitChildE,Src.CeilingExclusionAdult = Etr.CeilingExclusionAdult,Src.CeilingExclusionChild = Etr.CeilingExclusionChild  FROM tblProductItems Src , @xtProductItems Etr WHERE Src.ProdItemID = Etr.ProdItemID   
	SET @ProductItemsUpd = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF;
	SET IDENTITY_INSERT [tblProductItems] ON
	
	INSERT INTO tblProductItems ([ProdItemID],[tblProductItems].[ProdID],[ItemID],[LimitationType],[PriceOrigin],[LimitAdult],[LimitChild],[tblProductItems].[ValidityFrom] ,[tblProductItems].[ValidityTo],[tblProductItems].[LegacyID],[AuditUserID],WaitingPeriodAdult,WaitingPeriodChild,LimitNoAdult,LimitNoChild,LimitationTypeR,LimitationTypeE,LimitAdultR,LimitAdultE,LimitChildR,LimitChildE,CeilingExclusionAdult,CeilingExclusionChild)
	SELECT [ProdItemID],[ProdID],[ItemID],[LimitationType],[PriceOrigin],[LimitAdult],[LimitChild],[ValidityFrom] ,[ValidityTo],[LegacyID],@AuditUser,WaitingPeriodAdult,WaitingPeriodChild,LimitNoAdult,LimitNoChild,LimitationTypeR,LimitationTypeE,LimitAdultR,LimitAdultE,LimitChildR,LimitChildE,CeilingExclusionAdult,CeilingExclusionChild FROM @xtProductItems   WHERE [ProdItemID] NOT IN
	(SELECT ProdItemID FROM tblProductItems)
	AND ProdID IN (SELECT ProdID FROM tblProduct)
	
	SET @ProductItemsIns = @@ROWCOUNT
	SET IDENTITY_INSERT [tblProductItems] OFF
	SET NOCOUNT ON
	--**E ProductItems**
	
	--**S ProductServices**
	SET NOCOUNT OFF
	UPDATE Src  SET Src.ProdID = Etr.ProdID ,Src.ServiceID = Etr.ServiceID ,Src.LimitationType = Etr.LimitationType ,Src.PriceOrigin = Etr.PriceOrigin ,Src.LimitAdult = Etr.LimitAdult ,Src.LimitChild = Etr.LimitChild  ,Src.ValidityFrom = Etr.ValidityFrom , Src.ValidityTo = Etr.ValidityTo , Src.LegacyID = Etr.LegacyID, Src.AuditUserID = @AuditUser,Src.WaitingPeriodAdult = Etr.WaitingPeriodAdult,Src.WaitingPeriodChild = Etr.WaitingPeriodChild,Src.LimitNoAdult = Etr.LimitNoChild,Src.LimitationTypeR = Etr.LimitationTypeR,Src.LimitationTypeE = Etr.LimitationTypeE,Src.LimitAdultR = Etr.LimitAdultR,Src.LimitAdultE = Etr.LimitAdultE,Src.LimitChildR = Etr.LimitChildR,Src.LimitChildE = Etr.LimitChildE,Src.CeilingExclusionAdult = Etr.CeilingExclusionAdult,Src.CeilingExclusionChild = Etr.CeilingExclusionChild  FROM tblProductServices Src , @xtProductServices Etr WHERE Src.ProdServiceID = Etr.ProdServiceID   
	SET @ProductServicesUpd = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF;
	SET IDENTITY_INSERT [tblProductServices] ON
	
	INSERT INTO tblProductServices ([ProdServiceID],[tblProductServices].[ProdID],[ServiceID],[LimitationType],[PriceOrigin],[LimitAdult],[LimitChild],[tblProductServices].[ValidityFrom] ,[tblProductServices].[ValidityTo],[tblProductServices].[LegacyID],[AuditUserID],WaitingPeriodAdult,WaitingPeriodChild,LimitNoAdult,LimitNoChild,LimitationTypeR,LimitationTypeE,LimitAdultR,LimitAdultE,LimitChildR,LimitChildE,CeilingExclusionAdult,CeilingExclusionChild )
	SELECT [ProdServiceID],[ProdID],[ServiceID],[LimitationType],[PriceOrigin],[LimitAdult],[LimitChild],[ValidityFrom] ,[ValidityTo],[LegacyID],@AuditUser,WaitingPeriodAdult,WaitingPeriodChild,LimitNoAdult,LimitNoChild,LimitationTypeR,LimitationTypeE,LimitAdultR,LimitAdultE,LimitChildR,LimitChildE,CeilingExclusionAdult,CeilingExclusionChild   FROM @xtProductServices  WHERE [ProdServiceID] NOT IN
	(SELECT ProdServiceID FROM tblProductServices)
	AND ProdID IN (SELECT ProdID FROM tblProduct)
	
	SET @ProductServicesIns = @@ROWCOUNT
	SET IDENTITY_INSERT [tblProductServices] OFF
	SET NOCOUNT ON
	--**E ProductServices**
	
	--**S RelDistr**
	SET NOCOUNT OFF
	UPDATE Src  SET Src.DistrType = Etr.DistrType ,Src.DistrCareType = Etr.DistrCareType ,Src.ProdID =Etr.ProdID ,Src.Period = Etr.Period ,Src.DistrPerc = Etr.DistrPerc ,Src.ValidityFrom = Etr.ValidityFrom , Src.ValidityTo = Etr.ValidityTo , Src.LegacyID = Etr.LegacyID, Src.AuditUserID = @AuditUser  FROM tblRelDistr Src , @xtRelDistr Etr WHERE Src.DistrID = Etr.DistrID  
	SET @RelDistrUpd  = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF;
	SET IDENTITY_INSERT [tblRelDistr] ON
	
	INSERT INTO tblRelDistr ([DistrID],[DistrType] ,[DistrCareType],[dbo].[tblRelDistr].[ProdID],[Period],[DistrPerc],[dbo].[tblRelDistr].[ValidityFrom],[dbo].[tblRelDistr].[ValidityTo],[dbo].[tblRelDistr].[LegacyID],[dbo].[tblRelDistr].[AuditUserID])
	SELECT [DistrID],[DistrType] ,[DistrCareType],[ProdID],[Period],[DistrPerc],[ValidityFrom],[ValidityTo],[LegacyID],@AuditUser FROM @xtRelDistr WHERE [DistrID] NOT IN
	(SELECT DistrID FROM tblRelDistr)
	AND (DistrID = @DistrictId OR @DistrictId = 0)
	
	SET @RelDistrIns  = @@ROWCOUNT
	SET IDENTITY_INSERT [tblRelDistr] OFF
	SET NOCOUNT ON
	--**E RelDistr**
	
		
	--*S ClaimAdmin**
	SET NOCOUNT OFF
	UPDATE Src SET Src.ClaimAdminCode = Etr.ClaimAdminCode,Src.LastName = Etr.LastName,Src.OtherNames = Etr.OtherNames,Src.DOB = Etr.DOB,Src.Phone = Etr.Phone,Src.HFId = Etr.HFId,Src.ValidityFrom = Etr.ValidityFrom,Src.ValidityTo = Etr.ValidityTo,Src.LegacyId = Etr.LegacyId,Src.AuditUserId = Etr.AuditUserId,Src.EmailId = Etr.EmailId FROM tblClaimAdmin Src,@xtClaimAdmin Etr WHERE Src.ClaimAdminId = Etr.ClaimAdminId
	SET @ClaimAdminUpd = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF
	SET IDENTITY_INSERT[tblClaimAdmin] ON
	
	INSERT INTO tblClaimAdmin(ClaimAdminId,ClaimAdminCode,LastName,OtherNames,DOB,Phone,HFId,ValidityFrom,ValidityTo,LegacyId,AuditUserId,EmailId)
	SELECT ClaimAdminId,ClaimAdminCode,LastName,OtherNames,DOB,Phone,HFId,ValidityFrom,ValidityTo,LegacyId,@AuditUser,EmailId FROM @xtClaimAdmin 
	WHERE ClaimAdminId NOT IN(SELECT ClaimAdminId From tblClaimAdmin)
	AND HFId IN (SELECT HFId FROM tblHF)

	SET @ClaimAdminIns = @@ROWCOUNT
	SET IDENTITY_INSERT[tblClaimAdmin] OFF
	SET NOCOUNT ON;
	
	--*E ClaimAdmin**		
	
	
	--*S tblOfficerVillages**
	SET NOCOUNT OFF
	UPDATE Src SET  Src.OfficerId = Etr.OfficerId,Src.LocationId=Etr.LocationId,Src.AuditUserId=Etr.AuditUserId,Src.LegacyId=Etr.LegacyId,Src.ValidityFrom=Etr.ValidityFrom,Src.ValidityTo=Etr.ValidityTo FROM tblOfficerVillages Src,@xtVillageOfficer Etr WHERE Src.OfficerVillageId = Etr.OfficerVillageId
	SET @OfficerVillageUpd = @@ROWCOUNT
	SET NOCOUNT ON
	
	SET NOCOUNT OFF
	SET IDENTITY_INSERT[tblOfficerVillages] ON
	
	INSERT INTO tblOfficerVillages (OfficerVillageId,OfficerId,LocationId,ValidityFrom,ValidityTo,LegacyId,AuditUserId)
	SELECT OfficerVillageId,OfficerId,LocationId,ValidityFrom,ValidityTo,LegacyId,AuditUserId FROM @xtVillageOfficer
	WHERE OfficerVillageId NOT IN (SELECT OfficerVillageId FROM tblOfficerVillages)

	SET @OfficerVillageIns = @@ROWCOUNT
	SET IDENTITY_INSERT[tblOfficerVillages] OFF
	SET NOCOUNT ON;
	--*E tblOfficerVillages**		
	
	--Import Genders
	IF NOT EXISTS(SELECT 1 FROM tblGender)
	INSERT INTO tblGender(Code, Gender, AltLanguage, SortOrder)
	SELECT Code, Gender, AltLanguage, SortOrder FROM @xGender	
END


GO
