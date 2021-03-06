/****** Object:  Table [dbo].[tblLogins]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblLogins](
	[LoginId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NULL,
	[LogTime] [datetime] NULL,
	[LogAction] [int] NULL,
 CONSTRAINT [PK_tblLogins] PRIMARY KEY CLUSTERED 
(
	[LoginId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblLogins]  WITH CHECK ADD  CONSTRAINT [FK_tblLogins_tblUsers] FOREIGN KEY([UserId])
REFERENCES [dbo].[tblUsers] ([UserID])
GO
ALTER TABLE [dbo].[tblLogins] CHECK CONSTRAINT [FK_tblLogins_tblUsers]
GO
