CREATE TABLE [RS].[SSRSConfig] (
    [ServerName]                   NVARCHAR (128) NOT NULL,
    [InstanceName]                 NVARCHAR (128) NULL,
    [DatabaseServerName]           NVARCHAR (128) NULL,
    [IsDefaultInstance]            NVARCHAR (128) NULL,
    [PathName]                     NVARCHAR (256) NULL,
    [DatabaseName]                 NVARCHAR (128) NULL,
    [DatabaseLogonAccount]         NVARCHAR (128) NULL,
    [DatabaseLogonTimeout]         SMALLINT       NULL,
    [DatabaseQueryTimeout]         SMALLINT       NULL,
    [ConnectionPoolSize]           SMALLINT       NULL,
    [IsInitialized]                BIT            NULL,
    [IsReportManagerEnabled]       BIT            NULL,
    [IsSharePointIntegrated]       BIT            NULL,
    [IsWebServiceEnabled]          BIT            NULL,
    [IsWindowsServiceEnabled]      BIT            NULL,
    [SecureConnectionLevel]        SMALLINT       NULL,
    [SendUsingSMTPServer]          BIT            NULL,
    [SMTPServer]                   NVARCHAR (128) NULL,
    [SenderEmailAddress]           NVARCHAR (128) NULL,
    [UnattendedExecutionAccount]   NVARCHAR (128) NULL,
    [ServiceName]                  NVARCHAR (128) NULL,
    [WindowsServiceIdentityActual] NVARCHAR (128) NULL,
    [DateAdded]                    SMALLDATETIME  NULL,
    [RSCID]                        INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_SSRSConfig]
    ON [RS].[SSRSConfig]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [RSCID] ASC) WITH (FILLFACTOR = 85);

