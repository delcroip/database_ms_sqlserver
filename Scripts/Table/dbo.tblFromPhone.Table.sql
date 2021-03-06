/****** Object:  Table [dbo].[tblFromPhone]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFromPhone](
	[FromPhoneId] [int] IDENTITY(1,1) NOT NULL,
	[DocType] [nvarchar](3) NOT NULL,
	[DocName] [nvarchar](200) NOT NULL,
	[DocStatus] [nvarchar](3) NULL,
	[LandedDate] [datetime] NOT NULL,
	[OfficerCode] [nvarchar](8) NULL,
	[CHFID] [nvarchar](12) NULL,
	[PhotoSumittedDate] [datetime] NULL,
	[ClaimId] [int] NULL,
 CONSTRAINT [PK_tblFromPhone] PRIMARY KEY CLUSTERED 
(
	[FromPhoneId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblFromPhone] ADD  CONSTRAINT [DF_tblFromPhone_LandedDate]  DEFAULT (getdate()) FOR [LandedDate]
GO
ALTER TABLE [dbo].[tblFromPhone]  WITH CHECK ADD  CONSTRAINT [chk_DocType] CHECK  (([DocType]=N'C' OR [DocType]=N'F' OR [DocType]=N'R' OR [DocType]=N'E'))
GO
ALTER TABLE [dbo].[tblFromPhone] CHECK CONSTRAINT [chk_DocType]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'E: Enrolment
R: Policy Renewal
F: Feedback
C: Claim' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblFromPhone', @level2type=N'COLUMN',@level2name=N'DocType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'A: Accepted
R: Rejected
P: Pending
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblFromPhone', @level2type=N'COLUMN',@level2name=N'DocStatus'
GO
