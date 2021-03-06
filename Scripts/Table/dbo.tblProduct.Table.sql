/****** Object:  Table [dbo].[tblProduct]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProduct](
	[ProdID] [int] IDENTITY(1,1) NOT NULL,
	[ProductCode] [nvarchar](8) NOT NULL,
	[ProductName] [nvarchar](100) NOT NULL,
	[LocationId] [int] NULL,
	[InsurancePeriod] [tinyint] NOT NULL,
	[DateFrom] [smalldatetime] NOT NULL,
	[DateTo] [smalldatetime] NOT NULL,
	[ConversionProdID] [int] NULL,
	[LumpSum] [decimal](18, 2) NOT NULL,
	[MemberCount] [smallint] NOT NULL,
	[PremiumAdult] [decimal](18, 2) NULL,
	[PremiumChild] [decimal](18, 2) NULL,
	[DedInsuree] [decimal](18, 2) NULL,
	[DedOPInsuree] [decimal](18, 2) NULL,
	[DedIPInsuree] [decimal](18, 2) NULL,
	[MaxInsuree] [decimal](18, 2) NULL,
	[MaxOPInsuree] [decimal](18, 2) NULL,
	[MaxIPInsuree] [decimal](18, 2) NULL,
	[PeriodRelPrices] [char](1) NULL,
	[PeriodRelPricesOP] [char](1) NULL,
	[PeriodRelPricesIP] [char](1) NULL,
	[AccCodePremiums] [nvarchar](25) NULL,
	[AccCodeRemuneration] [nvarchar](25) NULL,
	[DedTreatment] [decimal](18, 2) NULL,
	[DedOPTreatment] [decimal](18, 2) NULL,
	[DedIPTreatment] [decimal](18, 2) NULL,
	[MaxTreatment] [decimal](18, 2) NULL,
	[MaxOPTreatment] [decimal](18, 2) NULL,
	[MaxIPTreatment] [decimal](18, 2) NULL,
	[DedPolicy] [decimal](18, 2) NULL,
	[DedOPPolicy] [decimal](18, 2) NULL,
	[DedIPPolicy] [decimal](18, 2) NULL,
	[MaxPolicy] [decimal](18, 2) NULL,
	[MaxOPPolicy] [decimal](18, 2) NULL,
	[MaxIPPolicy] [decimal](18, 2) NULL,
	[GracePeriod] [int] NOT NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RowID] [timestamp] NULL,
	[RegistrationLumpSum] [decimal](18, 2) NULL,
	[RegistrationFee] [decimal](18, 2) NULL,
	[GeneralAssemblyLumpSum] [decimal](18, 2) NULL,
	[GeneralAssemblyFee] [decimal](18, 2) NULL,
	[StartCycle1] [nvarchar](5) NULL,
	[StartCycle2] [nvarchar](5) NULL,
	[MaxNoConsultation] [int] NULL,
	[MaxNoSurgery] [int] NULL,
	[MaxNoDelivery] [int] NULL,
	[MaxNoHospitalizaion] [int] NULL,
	[MaxNoVisits] [int] NULL,
	[MaxAmountConsultation] [decimal](18, 2) NULL,
	[MaxAmountSurgery] [decimal](18, 2) NULL,
	[MaxAmountDelivery] [decimal](18, 2) NULL,
	[MaxAmountHospitalization] [decimal](18, 2) NULL,
	[GracePeriodRenewal] [int] NULL,
	[MaxInstallments] [int] NULL,
	[WaitingPeriod] [int] NULL,
	[Threshold] [int] NULL,
	[RenewalDiscountPerc] [int] NULL,
	[RenewalDiscountPeriod] [int] NULL,
	[StartCycle3] [nvarchar](5) NULL,
	[StartCycle4] [nvarchar](5) NULL,
	[AdministrationPeriod] [int] NULL,
	[MaxPolicyExtraMember] [decimal](18, 2) NULL,
	[MaxPolicyExtraMemberIP] [decimal](18, 2) NULL,
	[MaxPolicyExtraMemberOP] [decimal](18, 2) NULL,
	[MaxCeilingPolicy] [decimal](18, 2) NULL,
	[MaxCeilingPolicyIP] [decimal](18, 2) NULL,
	[MaxCeilingPolicyOP] [decimal](18, 2) NULL,
	[EnrolmentDiscountPerc] [int] NULL,
	[EnrolmentDiscountPeriod] [int] NULL,
	[MaxAmountAntenatal] [decimal](18, 2) NULL,
	[MaxNoAntenatal] [int] NULL,
	[CeilingInterpretation] [char](1) NULL,
	[Level1] [char](1) NULL,
	[Sublevel1] [char](1) NULL,
	[Level2] [char](1) NULL,
	[Sublevel2] [char](1) NULL,
	[Level3] [char](1) NULL,
	[Sublevel3] [char](1) NULL,
	[Level4] [char](1) NULL,
	[Sublevel4] [char](1) NULL,
	[ShareContribution] [decimal](5, 2) NULL,
	[WeightPopulation] [decimal](5, 2) NULL,
	[WeightNumberFamilies] [decimal](5, 2) NULL,
	[WeightInsuredPopulation] [decimal](5, 2) NULL,
	[WeightNumberInsuredFamilies] [decimal](5, 2) NULL,
	[WeightNumberVisits] [decimal](5, 2) NULL,
	[WeightAdjustedAmount] [decimal](5, 2) NULL,
 CONSTRAINT [PK_tblProduct_1] PRIMARY KEY CLUSTERED 
(
	[ProdID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_InsurancePeriod]  DEFAULT ((12)) FOR [InsurancePeriod]
GO
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_GracePeriod]  DEFAULT ((0)) FOR [GracePeriod]
GO
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblProduct] ADD  DEFAULT ((0)) FOR [RenewalDiscountPerc]
GO
ALTER TABLE [dbo].[tblProduct] ADD  DEFAULT ((0)) FOR [RenewalDiscountPeriod]
GO
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_ShareContribution]  DEFAULT ((100.00)) FOR [ShareContribution]
GO
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_WeightPopulation]  DEFAULT ((0.00)) FOR [WeightPopulation]
GO
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_WeightNumberFamilies]  DEFAULT ((0.00)) FOR [WeightNumberFamilies]
GO
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_WeightInsuredPopulation]  DEFAULT ((100.00)) FOR [WeightInsuredPopulation]
GO
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_WeightNumberInsuredFamilies]  DEFAULT ((0.00)) FOR [WeightNumberInsuredFamilies]
GO
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_WeightNumberVisits]  DEFAULT ((0.00)) FOR [WeightNumberVisits]
GO
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_WeightAdjustedAmount]  DEFAULT ((0.00)) FOR [WeightAdjustedAmount]
GO
ALTER TABLE [dbo].[tblProduct]  WITH CHECK ADD  CONSTRAINT [FK_tblHFSublevel_tblProduct_1] FOREIGN KEY([Sublevel1])
REFERENCES [dbo].[tblHFSublevel] ([HFSublevel])
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [FK_tblHFSublevel_tblProduct_1]
GO
ALTER TABLE [dbo].[tblProduct]  WITH CHECK ADD  CONSTRAINT [FK_tblHFSublevel_tblProduct_2] FOREIGN KEY([Sublevel2])
REFERENCES [dbo].[tblHFSublevel] ([HFSublevel])
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [FK_tblHFSublevel_tblProduct_2]
GO
ALTER TABLE [dbo].[tblProduct]  WITH CHECK ADD  CONSTRAINT [FK_tblHFSublevel_tblProduct_3] FOREIGN KEY([Sublevel3])
REFERENCES [dbo].[tblHFSublevel] ([HFSublevel])
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [FK_tblHFSublevel_tblProduct_3]
GO
ALTER TABLE [dbo].[tblProduct]  WITH CHECK ADD  CONSTRAINT [FK_tblHFSublevel_tblProduct_4] FOREIGN KEY([Sublevel4])
REFERENCES [dbo].[tblHFSublevel] ([HFSublevel])
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [FK_tblHFSublevel_tblProduct_4]
GO
ALTER TABLE [dbo].[tblProduct]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_tblCeilingInterpretation] FOREIGN KEY([CeilingInterpretation])
REFERENCES [dbo].[tblCeilingInterpretation] ([CeilingIntCode])
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [FK_tblProduct_tblCeilingInterpretation]
GO
ALTER TABLE [dbo].[tblProduct]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_tblLocation] FOREIGN KEY([LocationId])
REFERENCES [dbo].[tblLocations] ([LocationId])
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [FK_tblProduct_tblLocation]
GO
ALTER TABLE [dbo].[tblProduct]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_tblProduct] FOREIGN KEY([ConversionProdID])
REFERENCES [dbo].[tblProduct] ([ProdID])
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [FK_tblProduct_tblProduct]
GO
ALTER TABLE [dbo].[tblProduct]  WITH NOCHECK ADD  CONSTRAINT [CHK_Weight] CHECK  (([ValidityTo] IS NOT NULL OR [ValidityTo] IS NULL AND isnull(nullif(((((isnull([WeightPopulation],(0))+isnull([WeightNumberFamilies],(0)))+isnull([WeightInsuredPopulation],(0)))+isnull([WeightNumberInsuredFamilies],(0)))+isnull([WeightNumberVisits],(0)))+isnull([WeightAdjustedAmount],(0)),(0)),(100))=(100)))
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [CHK_Weight]
GO
