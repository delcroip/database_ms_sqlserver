/****** Object:  Table [dbo].[tblPolicy]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPolicy](
	[PolicyID] [int] IDENTITY(1,1) NOT NULL,
	[FamilyID] [int] NOT NULL,
	[EnrollDate] [date] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EffectiveDate] [date] NULL,
	[ExpiryDate] [date] NULL,
	[PolicyStatus] [tinyint] NULL,
	[PolicyValue] [decimal](18, 2) NULL,
	[ProdID] [int] NOT NULL,
	[OfficerID] [int] NULL,
	[PolicyStage] [char](1) NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RowID] [timestamp] NULL,
	[isOffline] [bit] NULL,
 CONSTRAINT [PK_tblPolicy] PRIMARY KEY CLUSTERED 
(
	[PolicyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPolicy] ADD  CONSTRAINT [DF_tblPolicy_PolicyStatus]  DEFAULT ((1)) FOR [PolicyStatus]
GO
ALTER TABLE [dbo].[tblPolicy] ADD  CONSTRAINT [DF_tblPolicy_PolicyStage]  DEFAULT ('N') FOR [PolicyStage]
GO
ALTER TABLE [dbo].[tblPolicy] ADD  CONSTRAINT [DF_tblPolicy_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblPolicy] ADD  CONSTRAINT [DF__tblPolicy__isOff__0F582957]  DEFAULT ((0)) FOR [isOffline]
GO
ALTER TABLE [dbo].[tblPolicy]  WITH CHECK ADD  CONSTRAINT [FK_tblPolicy_tblFamilies-FamilyID] FOREIGN KEY([FamilyID])
REFERENCES [dbo].[tblFamilies] ([FamilyID])
GO
ALTER TABLE [dbo].[tblPolicy] CHECK CONSTRAINT [FK_tblPolicy_tblFamilies-FamilyID]
GO
ALTER TABLE [dbo].[tblPolicy]  WITH CHECK ADD  CONSTRAINT [FK_tblPolicy_tblOfficer-OfficerID] FOREIGN KEY([OfficerID])
REFERENCES [dbo].[tblOfficer] ([OfficerID])
GO
ALTER TABLE [dbo].[tblPolicy] CHECK CONSTRAINT [FK_tblPolicy_tblOfficer-OfficerID]
GO
ALTER TABLE [dbo].[tblPolicy]  WITH CHECK ADD  CONSTRAINT [FK_tblPolicy_tblProduct-ProductID] FOREIGN KEY([ProdID])
REFERENCES [dbo].[tblProduct] ([ProdID])
GO
ALTER TABLE [dbo].[tblPolicy] CHECK CONSTRAINT [FK_tblPolicy_tblProduct-ProductID]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1=Idle 2=active 4=suspended 8=Expired' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblPolicy', @level2type=N'COLUMN',@level2name=N'PolicyStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'N = New Policy
 R = Renewed Policy' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblPolicy', @level2type=N'COLUMN',@level2name=N'PolicyStage'
GO
