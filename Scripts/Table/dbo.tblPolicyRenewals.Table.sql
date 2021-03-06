/****** Object:  Table [dbo].[tblPolicyRenewals]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPolicyRenewals](
	[RenewalID] [int] IDENTITY(1,1) NOT NULL,
	[RenewalPromptDate] [date] NOT NULL,
	[RenewalDate] [date] NOT NULL,
	[NewOfficerID] [int] NULL,
	[PhoneNumber] [nvarchar](25) NULL,
	[SMSStatus] [tinyint] NOT NULL,
	[InsureeID] [int] NOT NULL,
	[PolicyID] [int] NOT NULL,
	[NewProdID] [int] NOT NULL,
	[RenewalWarnings] [tinyint] NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditCreateUser] [int] NULL,
	[ResponseStatus] [int] NULL,
	[ResponseDate] [datetime] NULL,
 CONSTRAINT [PK_tblPolicyRenewals] PRIMARY KEY CLUSTERED 
(
	[RenewalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPolicyRenewals] ADD  CONSTRAINT [DF_tblPolicyRenewals_IsSMSSent]  DEFAULT ((0)) FOR [SMSStatus]
GO
ALTER TABLE [dbo].[tblPolicyRenewals] ADD  CONSTRAINT [DF_tblPolicyRenewals_RenewalWarnings]  DEFAULT ((0)) FOR [RenewalWarnings]
GO
ALTER TABLE [dbo].[tblPolicyRenewals] ADD  CONSTRAINT [DF_tblPolicyRenewals_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblPolicyRenewals]  WITH CHECK ADD  CONSTRAINT [FK_tblPolicyRenewals_tblInsuree] FOREIGN KEY([InsureeID])
REFERENCES [dbo].[tblInsuree] ([InsureeID])
GO
ALTER TABLE [dbo].[tblPolicyRenewals] CHECK CONSTRAINT [FK_tblPolicyRenewals_tblInsuree]
GO
ALTER TABLE [dbo].[tblPolicyRenewals]  WITH CHECK ADD  CONSTRAINT [FK_tblPolicyRenewals_tblOfficer] FOREIGN KEY([NewOfficerID])
REFERENCES [dbo].[tblOfficer] ([OfficerID])
GO
ALTER TABLE [dbo].[tblPolicyRenewals] CHECK CONSTRAINT [FK_tblPolicyRenewals_tblOfficer]
GO
ALTER TABLE [dbo].[tblPolicyRenewals]  WITH CHECK ADD  CONSTRAINT [FK_tblPolicyRenewals_tblPolicy] FOREIGN KEY([PolicyID])
REFERENCES [dbo].[tblPolicy] ([PolicyID])
GO
ALTER TABLE [dbo].[tblPolicyRenewals] CHECK CONSTRAINT [FK_tblPolicyRenewals_tblPolicy]
GO
ALTER TABLE [dbo].[tblPolicyRenewals]  WITH CHECK ADD  CONSTRAINT [FK_tblPolicyRenewals_tblProduct] FOREIGN KEY([NewProdID])
REFERENCES [dbo].[tblProduct] ([ProdID])
GO
ALTER TABLE [dbo].[tblPolicyRenewals] CHECK CONSTRAINT [FK_tblPolicyRenewals_tblProduct]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0: Not yet sent
1: Renewal is submitted
2: Declined (Insuree didn''t want to renew)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblPolicyRenewals', @level2type=N'COLUMN',@level2name=N'ResponseStatus'
GO
