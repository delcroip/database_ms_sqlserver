/****** Object:  Table [dbo].[tblRelations]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRelations](
	[RelationId] [smallint] NOT NULL,
	[Relation] [nvarchar](50) NOT NULL,
	[SortOrder] [int] NULL,
	[AltLanguage] [nvarchar](50) NULL,
 CONSTRAINT [PK_Relation] PRIMARY KEY CLUSTERED 
(
	[RelationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
