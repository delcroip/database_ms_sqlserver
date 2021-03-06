/****** Object:  Table [dbo].[tblICDCodes]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblICDCodes](
	[ICDID] [int] IDENTITY(1,1) NOT NULL,
	[ICDCode] [nvarchar](6) NOT NULL,
	[ICDName] [nvarchar](255) NOT NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RowID] [timestamp] NULL,
 CONSTRAINT [PK_tblICDCodes] PRIMARY KEY CLUSTERED 
(
	[ICDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblICDCodes] ADD  CONSTRAINT [DF_tblICDCodes_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
