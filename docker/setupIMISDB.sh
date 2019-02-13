if [ -f /var/opt/mssql/data/IMIS.mdf ]
then
        echo "IMIS database already setup"
else
        #echo "launching MS SQL server in single user mode"
        #/opt/mssql/bin/sqlservr -m --accept-eula &
        #echo $!  > pid.file
		#wait until mssql fully loaded
        #sleep 20
        wget https://github.com/openimis/database_ms_sqlserver/raw/master/Empty%20databases/SQLServer2017/openIMIS_ONLINE_v1.2.0.bak -P /tmp
        echo "load the database dump"
        /opt/mssql-tools/bin/sqlcmd -S lpc:$HOSTNAME\\MSSQLSERVER -U SA -P $SA_PASSWORD  -Q "RESTORE DATABASE [IMIS] FROM DISK = N'/tmp/openIMIS_ONLINE_v1.2.0.bak' WITH MOVE N'CH_CENTRAL' TO '/var/opt/mssql/data/IMIS.mdf', MOVE N'CH_CENTRAL_log' TO '/var/opt/mssql/data/IMIS_log.ldf'"
        echo "execute the stored procedure SETUP-IMIS"
        rm /tmp/openIMIS_ONLINE_v1.2.0.bak
        /opt/mssql-tools/bin/sqlcmd -S lpc:$HOSTNAME\\MSSQLSERVER -U SA -P $SA_PASSWORD -Q 'EXECUTE [SETUP-IMIS]'
        echo "allow remote connection"
        /opt/mssql-tools/bin/sqlcmd -S lpc:$HOSTNAME\\MSSQLSERVER -U SA -P $SA_PASSWORD -Q "sp_configure 'remote admin connections', 1"
        /opt/mssql-tools/bin/sqlcmd -S lpc:$HOSTNAME\\MSSQLSERVER -U SA -P $SA_PASSWORD -Q "RECONFIGURE"
        echo 'database loaded'
        # ask to change to database password
        echo ' run this command to change the SA account database password'
        echo "/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '" $SA_PASSWORDT "' -Q 'ALTER LOGIN SA WITH PASSWORD=\"<YourNewStrong!Passw0rd>\""
        #kill 9 < pid.file
fi
