/****** Object:  Table [dbo].[tblOfficerVillages]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblOfficerVillages](
	[OfficerVillageId] [int] IDENTITY(1,1) NOT NULL,
	[OfficerId] [int] NULL,
	[LocationId] [int] NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyId] [int] NULL,
	[AuditUserId] [int] NULL,
	[RowId] [timestamp] NOT NULL,
 CONSTRAINT [PK_tblOfficerVillages] PRIMARY KEY CLUSTERED 
(
	[OfficerVillageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblOfficerVillages] ADD  CONSTRAINT [DF_tblOfficerVillages]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblOfficerVillages]  WITH CHECK ADD  CONSTRAINT [FK_tblOfficerVillages_tblLocations] FOREIGN KEY([LocationId])
REFERENCES [dbo].[tblLocations] ([LocationId])
GO
ALTER TABLE [dbo].[tblOfficerVillages] CHECK CONSTRAINT [FK_tblOfficerVillages_tblLocations]
GO
ALTER TABLE [dbo].[tblOfficerVillages]  WITH CHECK ADD  CONSTRAINT [FK_tblOfficerVillages_tblOfficer] FOREIGN KEY([OfficerId])
REFERENCES [dbo].[tblOfficer] ([OfficerID])
GO
ALTER TABLE [dbo].[tblOfficerVillages] CHECK CONSTRAINT [FK_tblOfficerVillages_tblOfficer]
GO
