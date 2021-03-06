/****** Object:  UserDefinedTableType [dbo].[xPremium]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xPremium] AS TABLE(
	[PremiumId] [int] NULL,
	[PolicyID] [int] NULL,
	[PayerID] [int] NULL,
	[Amount] [decimal](18, 2) NULL,
	[Receipt] [nvarchar](50) NULL,
	[PayDate] [date] NULL,
	[PayType] [char](1) NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NULL,
	[isPhotoFee] [bit] NULL,
	[ReportingId] [int] NULL,
	[isOffline] [bit] NULL
)
GO
