/****** Object:  UserDefinedTableType [dbo].[xGender]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xGender] AS TABLE(
	[Code] [char](1) NULL,
	[Gender] [nvarchar](50) NULL,
	[AltLanguage] [nvarchar](50) NULL,
	[SortOrder] [int] NULL
)
GO
