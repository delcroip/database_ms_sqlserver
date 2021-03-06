/****** Object:  Table [dbo].[tblPhotos]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPhotos](
	[PhotoID] [int] IDENTITY(1,1) NOT NULL,
	[InsureeID] [int] NULL,
	[CHFID] [nvarchar](12) NULL,
	[PhotoFolder] [nvarchar](255) NOT NULL,
	[PhotoFileName] [nvarchar](250) NULL,
	[OfficerID] [int] NOT NULL,
	[PhotoDate] [date] NOT NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[AuditUserID] [int] NULL,
	[RowID] [timestamp] NULL,
 CONSTRAINT [PK_tblPhotos] PRIMARY KEY CLUSTERED 
(
	[PhotoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPhotos] ADD  CONSTRAINT [DF_tblPhotos_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblPhotos] ADD  CONSTRAINT [DF_tblPhotos_AudiitUser]  DEFAULT ((0)) FOR [AuditUserID]
GO
