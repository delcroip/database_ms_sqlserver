/****** Object:  Table [dbo].[tblControls]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblControls](
	[FieldName] [nvarchar](50) NOT NULL,
	[Adjustibility] [nvarchar](1) NOT NULL,
	[Usage] [nvarchar](200) NULL,
 CONSTRAINT [PK_tblControls] PRIMARY KEY CLUSTERED 
(
	[FieldName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'N: Not Used	O: Optional	M: Mandatory' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblControls', @level2type=N'COLUMN',@level2name=N'Usage'
GO
