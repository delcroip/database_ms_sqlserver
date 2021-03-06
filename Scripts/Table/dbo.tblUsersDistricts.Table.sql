/****** Object:  Table [dbo].[tblUsersDistricts]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUsersDistricts](
	[UserDistrictID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[LocationId] [int] NOT NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
 CONSTRAINT [PK_tblUsersDistricts] PRIMARY KEY CLUSTERED 
(
	[UserDistrictID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblUsersDistricts] ADD  CONSTRAINT [DF_tblUsersDistricts_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblUsersDistricts]  WITH CHECK ADD  CONSTRAINT [FK_tblUsersDistricts_tblLocations] FOREIGN KEY([LocationId])
REFERENCES [dbo].[tblLocations] ([LocationId])
GO
ALTER TABLE [dbo].[tblUsersDistricts] CHECK CONSTRAINT [FK_tblUsersDistricts_tblLocations]
GO
ALTER TABLE [dbo].[tblUsersDistricts]  WITH CHECK ADD  CONSTRAINT [FK_tblUsersDistricts_tblUsers] FOREIGN KEY([UserID])
REFERENCES [dbo].[tblUsers] ([UserID])
GO
ALTER TABLE [dbo].[tblUsersDistricts] CHECK CONSTRAINT [FK_tblUsersDistricts_tblUsers]
GO
