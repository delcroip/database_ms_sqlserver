/****** Object:  UserDefinedTableType [dbo].[xCareType]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xCareType] AS TABLE(
	[Code] [char](1) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[AltLanguage] [nvarchar](50) NULL
)
GO
