/****** Object:  Table [dbo].[tblUsers]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUsers](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[LanguageID] [nvarchar](2) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[OtherNames] [nvarchar](100) NOT NULL,
	[Phone] [nvarchar](50) NULL,
	[LoginName] [nvarchar](25) NOT NULL,
	[RoleID] [int] NOT NULL,
	[HFID] [int] NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[password] [varbinary](256) NULL,
	[DummyPwd] [nvarchar](25) NULL,
	[EmailId] [nvarchar](200) NULL,
 CONSTRAINT [PK_tblUsers] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblUsers] ADD  CONSTRAINT [DF_tblUsers_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblUsers]  WITH CHECK ADD  CONSTRAINT [FK_tblLanguages_tblUsers] FOREIGN KEY([LanguageID])
REFERENCES [dbo].[tblLanguages] ([LanguageCode])
GO
ALTER TABLE [dbo].[tblUsers] CHECK CONSTRAINT [FK_tblLanguages_tblUsers]
GO
