/****** Object:  Table [dbo].[tblIMISDefaults]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblIMISDefaults](
	[DefaultID] [int] IDENTITY(1,1) NOT NULL,
	[PolicyRenewalInterval] [int] NULL,
	[FTPHost] [nvarchar](50) NULL,
	[FTPUser] [nvarchar](50) NULL,
	[FTPPassword] [nvarchar](20) NULL,
	[FTPPort] [int] NULL,
	[FTPEnrollmentFolder] [nvarchar](255) NULL,
	[AssociatedPhotoFolder] [nvarchar](255) NULL,
	[FTPClaimFolder] [nvarchar](255) NULL,
	[FTPFeedbackFolder] [nvarchar](255) NULL,
	[FTPPolicyRenewalFolder] [nvarchar](255) NULL,
	[FTPPhoneExtractFolder] [nvarchar](255) NULL,
	[FTPOffLineExtractFolder] [nvarchar](255) NULL,
	[AppVersionBackEnd] [decimal](3, 1) NULL,
	[AppVersionEnquire] [decimal](3, 1) NULL,
	[AppVersionEnroll] [decimal](3, 1) NULL,
	[AppVersionRenewal] [decimal](3, 1) NULL,
	[AppVersionFeedback] [decimal](3, 1) NULL,
	[AppVersionClaim] [decimal](3, 1) NULL,
	[OffLineHF] [int] NULL,
	[WinRarFolder] [nvarchar](255) NULL,
	[DatabaseBackupFolder] [nvarchar](255) NULL,
	[OfflineCHF] [int] NULL,
	[SMSLink] [nvarchar](500) NULL,
	[SMSIP] [nvarchar](15) NULL,
	[SMSUserName] [nvarchar](15) NULL,
	[SMSPassword] [nvarchar](50) NULL,
	[SMSSource] [nvarchar](15) NULL,
	[SMSDlr] [int] NULL,
	[SMSType] [int] NULL,
	[AppVersionFeedbackRenewal] [decimal](3, 1) NULL,
	[AppVersionImis] [decimal](3, 1) NULL,
 CONSTRAINT [PK_tblIMISDefaults] PRIMARY KEY CLUSTERED 
(
	[DefaultID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblIMISDefaults] ADD  CONSTRAINT [DF_tblIMISDefaults_PolicyRenewalInterval]  DEFAULT ((14)) FOR [PolicyRenewalInterval]
GO
ALTER TABLE [dbo].[tblIMISDefaults] ADD  CONSTRAINT [DF_tblIMISDefaults_FTPPort]  DEFAULT ((21)) FOR [FTPPort]
GO
ALTER TABLE [dbo].[tblIMISDefaults] ADD  CONSTRAINT [DF_tblIMISDefaults_AppVersionEnquire]  DEFAULT ((1.0)) FOR [AppVersionEnquire]
GO
ALTER TABLE [dbo].[tblIMISDefaults] ADD  CONSTRAINT [DF_tblIMISDefaults_AppVersionEnroll]  DEFAULT ((1.0)) FOR [AppVersionEnroll]
GO
ALTER TABLE [dbo].[tblIMISDefaults] ADD  CONSTRAINT [DF_tblIMISDefaults_AppVersionRenewal]  DEFAULT ((1.0)) FOR [AppVersionRenewal]
GO
ALTER TABLE [dbo].[tblIMISDefaults] ADD  CONSTRAINT [DF_tblIMISDefaults_AppVersionFeedback]  DEFAULT ((1.0)) FOR [AppVersionFeedback]
GO
ALTER TABLE [dbo].[tblIMISDefaults] ADD  CONSTRAINT [DF_tblIMISDefaults_AppVersionClaim]  DEFAULT ((1.0)) FOR [AppVersionClaim]
GO
ALTER TABLE [dbo].[tblIMISDefaults] ADD  CONSTRAINT [DF_tblIMISDefaults_OffLineHF]  DEFAULT ((0)) FOR [OffLineHF]
GO
ALTER TABLE [dbo].[tblIMISDefaults] ADD  DEFAULT ((0)) FOR [OfflineCHF]
GO
