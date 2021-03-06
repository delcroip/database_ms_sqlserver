/****** Object:  StoredProcedure [dbo].[uspCreateEncryptionSet]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspCreateEncryptionSet]
AS
	--Create master key which is required to encrypt the certificate
	IF NOT EXISTS(
	SELECT * FROM SYS.SYMMETRIC_KEYS  WHERE SYMMETRIC_KEY_ID = 101
	)
	CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ExactProtecttion'

	--GO

	--Create certificate which will be used to create key 
	IF NOT EXISTS(
	SELECT * FROM sys.certificates WHERE name = 'EncryptData'
	)
	CREATE CERTIFICATE EncryptData 
	WITH Subject = 'Encrypt Data'

	--GO

	--Create symmetric key which will be used to encrypt and decrypt data
	IF NOT EXISTS(
	SELECT * FROM sys.symmetric_keys WHERE name = 'EncryptionKey'
	)
	CREATE SYMMETRIC KEY EncryptionKey
	WITH ALGORITHM = TRIPLE_DES, 
	KEY_SOURCE = 'Exact Key Source',
	IDENTITY_VALUE = 'Exact Identity Value'
	ENCRYPTION BY CERTIFICATE EncryptData
	--GO


	/*
	--To backup master key 
	BACKUP MASTER KEY TO FILE = 'C:\MasterKey\AnyNameYouWant'
	ENCRYPTION BY PASSWORD = 'SetYourSecurePassword'

	--To Restore master key
	Restore MASTER KEY 
	FROM FILE = 'C:\MasterKey\AnyNameYouWant'
	DECRYPTION BY PASSWORD = 'SetYourSecurePassword'--Password used to while backing up
	ENCRYPTION BY PASSWORD = 'ExactProtecttion' --Password to encrypt data
	
	
	TO RUN IF DB HAS NOT YET ENCRYPTED COLUMNS AND YOU WANT TO APPLY ENCRYPTION  	
	--sp_rename 'tblUsers.[password]', 'Password1', 'COLUMN'
	--alter table tblusers add [password] varbinary(256)
	open symmetric key EncryptionKey decryption by certificate EncryptData
	update  tblusers set [password] = ENCRYPTBYKEY(key_GUID('EncryptionKey'),dummyPwd)
	--Alter Table tblusers drop column password1
	close symmetric key EncryptionKey

	
	
	*/

GO
