/****** Object:  Table [dbo].[tblClaimAdmin]    Script Date: 19.09.2018 15:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblClaimAdmin](
	[ClaimAdminId] [int] IDENTITY(1,1) NOT NULL,
	[ClaimAdminCode] [nvarchar](8) NULL,
	[LastName] [nvarchar](100) NULL,
	[OtherNames] [nvarchar](100) NULL,
	[DOB] [date] NULL,
	[Phone] [nvarchar](50) NULL,
	[HFId] [int] NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyId] [int] NULL,
	[AuditUserId] [int] NULL,
	[RowId] [timestamp] NULL,
	[EmailId] [nvarchar](200) NULL,
 CONSTRAINT [PK_tblClaimAdmin] PRIMARY KEY CLUSTERED 
(
	[ClaimAdminId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblClaimAdmin]  WITH CHECK ADD  CONSTRAINT [FK_tblClaimAdmin_tblHF] FOREIGN KEY([HFId])
REFERENCES [dbo].[tblHF] ([HfID])
GO
ALTER TABLE [dbo].[tblClaimAdmin] CHECK CONSTRAINT [FK_tblClaimAdmin_tblHF]
GO
