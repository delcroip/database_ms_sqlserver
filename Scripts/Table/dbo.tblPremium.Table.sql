/****** Object:  Table [dbo].[tblPremium]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPremium](
	[PremiumId] [int] IDENTITY(1,1) NOT NULL,
	[PolicyID] [int] NOT NULL,
	[PayerID] [int] NULL,
	[Amount] [decimal](18, 2) NOT NULL,
	[Receipt] [nvarchar](50) NOT NULL,
	[PayDate] [date] NOT NULL,
	[PayType] [char](1) NOT NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RowID] [timestamp] NULL,
	[isPhotoFee] [bit] NULL,
	[isOffline] [bit] NULL,
	[ReportingId] [int] NULL,
 CONSTRAINT [PK_tblPremium] PRIMARY KEY CLUSTERED 
(
	[PremiumId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPremium] ADD  CONSTRAINT [DF_tblPremium_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblPremium] ADD  CONSTRAINT [DF_tblPremium_PayCategory]  DEFAULT ((0)) FOR [isPhotoFee]
GO
ALTER TABLE [dbo].[tblPremium] ADD  CONSTRAINT [DF__tblPremiu__isOff__104C4D90]  DEFAULT ((0)) FOR [isOffline]
GO
ALTER TABLE [dbo].[tblPremium]  WITH CHECK ADD  CONSTRAINT [FK_tblPremium_tblPayer] FOREIGN KEY([PayerID])
REFERENCES [dbo].[tblPayer] ([PayerID])
GO
ALTER TABLE [dbo].[tblPremium] CHECK CONSTRAINT [FK_tblPremium_tblPayer]
GO
ALTER TABLE [dbo].[tblPremium]  WITH CHECK ADD  CONSTRAINT [FK_tblPremium_tblPolicy] FOREIGN KEY([PolicyID])
REFERENCES [dbo].[tblPolicy] ([PolicyID])
GO
ALTER TABLE [dbo].[tblPremium] CHECK CONSTRAINT [FK_tblPremium_tblPolicy]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'R: Registration Fee
G: General Assembly Fee
P: Premium' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblPremium', @level2type=N'COLUMN',@level2name=N'isPhotoFee'
GO
