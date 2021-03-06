/****** Object:  UserDefinedTableType [dbo].[xPhotos]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xPhotos] AS TABLE(
	[PhotoID] [int] NULL,
	[InsureeID] [int] NULL,
	[CHFID] [char](12) NULL,
	[PhotoFolder] [nvarchar](255) NULL,
	[PhotoFileName] [nvarchar](250) NULL,
	[OfficerID] [int] NULL,
	[PhotoDate] [date] NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[AuditUserID] [int] NULL
)
GO
