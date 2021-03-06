/****** Object:  UserDefinedTableType [dbo].[xOfficers]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xOfficers] AS TABLE(
	[OfficerID] [int] NULL,
	[Code] [nvarchar](8) NULL,
	[LastName] [nvarchar](100) NULL,
	[OtherNames] [nvarchar](100) NULL,
	[DOB] [date] NULL,
	[Phone] [nvarchar](50) NULL,
	[LocationId] [int] NULL,
	[OfficerIDSubst] [int] NULL,
	[WorksTo] [smalldatetime] NULL,
	[VEOCode] [nvarchar](25) NULL,
	[VEOLastName] [nvarchar](100) NULL,
	[VEOOtherNames] [nvarchar](100) NULL,
	[VEODOB] [date] NULL,
	[VEOPhone] [nvarchar](25) NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[EmailId] [nvarchar](200) NULL,
	[PhoneCommunication] [bit] NULL,
	[PermanentAddress] [nvarchar](100) NULL
)
GO
