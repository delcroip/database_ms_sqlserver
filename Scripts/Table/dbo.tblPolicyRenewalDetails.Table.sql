/****** Object:  Table [dbo].[tblPolicyRenewalDetails]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPolicyRenewalDetails](
	[RenewalDetailID] [int] IDENTITY(1,1) NOT NULL,
	[RenewalID] [int] NOT NULL,
	[InsureeID] [int] NOT NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditCreateUser] [int] NOT NULL,
 CONSTRAINT [PK_tblPolicyRenewalDetails] PRIMARY KEY CLUSTERED 
(
	[RenewalDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPolicyRenewalDetails] ADD  CONSTRAINT [DF_tblPolicyRenewalDetails_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblPolicyRenewalDetails]  WITH CHECK ADD  CONSTRAINT [FK_tblPolicyRenewalDetails_tblInsuree] FOREIGN KEY([InsureeID])
REFERENCES [dbo].[tblInsuree] ([InsureeID])
GO
ALTER TABLE [dbo].[tblPolicyRenewalDetails] CHECK CONSTRAINT [FK_tblPolicyRenewalDetails_tblInsuree]
GO
ALTER TABLE [dbo].[tblPolicyRenewalDetails]  WITH CHECK ADD  CONSTRAINT [FK_tblPolicyRenewalDetails_tblPolicyRenewals] FOREIGN KEY([RenewalID])
REFERENCES [dbo].[tblPolicyRenewals] ([RenewalID])
GO
ALTER TABLE [dbo].[tblPolicyRenewalDetails] CHECK CONSTRAINT [FK_tblPolicyRenewalDetails_tblPolicyRenewals]
GO
