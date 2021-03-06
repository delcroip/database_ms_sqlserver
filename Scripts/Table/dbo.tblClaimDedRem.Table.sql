/****** Object:  Table [dbo].[tblClaimDedRem]    Script Date: 19.09.2018 15:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblClaimDedRem](
	[ExpenditureID] [int] IDENTITY(1,1) NOT NULL,
	[PolicyID] [int] NOT NULL,
	[InsureeID] [int] NOT NULL,
	[ClaimID] [int] NOT NULL,
	[DedG] [decimal](18, 2) NULL,
	[DedOP] [decimal](18, 2) NULL,
	[DedIP] [decimal](18, 2) NULL,
	[RemG] [decimal](18, 2) NULL,
	[RemIP] [decimal](18, 2) NULL,
	[RemOP] [decimal](18, 2) NULL,
	[RemConsult] [decimal](18, 2) NULL,
	[RemSurgery] [decimal](18, 2) NULL,
	[RemDelivery] [decimal](18, 2) NULL,
	[RemHospitalization] [decimal](18, 2) NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RemAntenatal] [decimal](18, 2) NULL,
 CONSTRAINT [PK_tblClaimDedRem] PRIMARY KEY CLUSTERED 
(
	[ExpenditureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblClaimDedRem] ADD  CONSTRAINT [DF_tblClaimDedRem_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblClaimDedRem]  WITH CHECK ADD  CONSTRAINT [FK_tblClaimDedRem_tblInsuree] FOREIGN KEY([InsureeID])
REFERENCES [dbo].[tblInsuree] ([InsureeID])
GO
ALTER TABLE [dbo].[tblClaimDedRem] CHECK CONSTRAINT [FK_tblClaimDedRem_tblInsuree]
GO
ALTER TABLE [dbo].[tblClaimDedRem]  WITH CHECK ADD  CONSTRAINT [FK_tblClaimDedRem_tblPolicy] FOREIGN KEY([PolicyID])
REFERENCES [dbo].[tblPolicy] ([PolicyID])
GO
ALTER TABLE [dbo].[tblClaimDedRem] CHECK CONSTRAINT [FK_tblClaimDedRem_tblPolicy]
GO
