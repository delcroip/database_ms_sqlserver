/****** Object:  Table [dbo].[tblOfficer]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblOfficer](
	[OfficerID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](8) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[OtherNames] [nvarchar](100) NOT NULL,
	[DOB] [date] NULL,
	[Phone] [nvarchar](50) NULL,
	[LocationId] [int] NULL,
	[OfficerIDSubst] [int] NULL,
	[WorksTo] [smalldatetime] NULL,
	[VEOCode] [nvarchar](8) NULL,
	[VEOLastName] [nvarchar](100) NULL,
	[VEOOtherNames] [nvarchar](100) NULL,
	[VEODOB] [date] NULL,
	[VEOPhone] [nvarchar](25) NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RowID] [timestamp] NULL,
	[EmailId] [nvarchar](200) NULL,
	[PhoneCommunication] [bit] NULL,
	[permanentaddress] [nvarchar](100) NULL,
 CONSTRAINT [PK_tblOfficer] PRIMARY KEY CLUSTERED 
(
	[OfficerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblOfficer] ADD  CONSTRAINT [DF_tblOfficer_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblOfficer] ADD  DEFAULT ((0)) FOR [PhoneCommunication]
GO
ALTER TABLE [dbo].[tblOfficer]  WITH CHECK ADD  CONSTRAINT [FK_tblOfficer_tblLocations] FOREIGN KEY([LocationId])
REFERENCES [dbo].[tblLocations] ([LocationId])
GO
ALTER TABLE [dbo].[tblOfficer] CHECK CONSTRAINT [FK_tblOfficer_tblLocations]
GO
ALTER TABLE [dbo].[tblOfficer]  WITH NOCHECK ADD  CONSTRAINT [FK_tblOfficer_tblOfficer] FOREIGN KEY([OfficerIDSubst])
REFERENCES [dbo].[tblOfficer] ([OfficerID])
GO
ALTER TABLE [dbo].[tblOfficer] CHECK CONSTRAINT [FK_tblOfficer_tblOfficer]
GO
