/****** Object:  Table [dbo].[tblInsureePolicy]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblInsureePolicy](
	[InsureePolicyId] [int] IDENTITY(1,1) NOT NULL,
	[InsureeId] [int] NULL,
	[PolicyId] [int] NULL,
	[EnrollmentDate] [date] NULL,
	[StartDate] [date] NULL,
	[EffectiveDate] [date] NULL,
	[ExpiryDate] [date] NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyId] [int] NULL,
	[AuditUserId] [int] NULL,
	[isOffline] [bit] NULL,
	[RowId] [timestamp] NULL,
 CONSTRAINT [PK_tblInsureePolicy] PRIMARY KEY CLUSTERED 
(
	[InsureePolicyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblInsureePolicy] ADD  CONSTRAINT [DF_tblInsureePolicy_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblInsureePolicy] ADD  CONSTRAINT [DF_tblInsureePolicy_isOffline]  DEFAULT ((0)) FOR [isOffline]
GO
ALTER TABLE [dbo].[tblInsureePolicy]  WITH CHECK ADD  CONSTRAINT [FK_tblInsureePolicy_tblInsuree] FOREIGN KEY([InsureeId])
REFERENCES [dbo].[tblInsuree] ([InsureeID])
GO
ALTER TABLE [dbo].[tblInsureePolicy] CHECK CONSTRAINT [FK_tblInsureePolicy_tblInsuree]
GO
ALTER TABLE [dbo].[tblInsureePolicy]  WITH CHECK ADD  CONSTRAINT [FK_tblInsureePolicy_tblPolicy] FOREIGN KEY([PolicyId])
REFERENCES [dbo].[tblPolicy] ([PolicyID])
GO
ALTER TABLE [dbo].[tblInsureePolicy] CHECK CONSTRAINT [FK_tblInsureePolicy_tblPolicy]
GO
