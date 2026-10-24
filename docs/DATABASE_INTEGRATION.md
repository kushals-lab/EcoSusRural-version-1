# Local PostgreSQL integration

Express startup and `/ready` execute only `SELECT 1`; runtime startup no
longer creates or alters tables. The optional FastAPI AI `/compute` service
currently does not query PostgreSQL.

## Private inventory

In your own terminal, let `psql` prompt for the administrator password:

```powershell
& 'C:\Program Files\PostgreSQL\18\bin\psql.exe' -h 127.0.0.1 -p 5432 -U YOUR_ADMIN_ROLE -d postgres -W -f 'database\ecosusrural_mvp_provision.psql'
```

This prints whether `ecosusrural_mvp` and `ecosusrural_app` exist and the
role capability flags. The provisioning file is read-only by default.
Review existing objects and data before enabling either conditional create
statement. For a newly created role, set its password in your private `psql`
session with `\password ecosusrural_app`. Do not share the password.

## Current inventory: role exists, database absent

You reported that `ecosusrural_app` exists and `ecosusrural_mvp` does not.
Check the role capability flags in the inventory output. If it is a LOGIN
role with all elevated flags false, you can create the new database from
your private administrator terminal:

```powershell
& 'C:\Program Files\PostgreSQL\18\bin\psql.exe' -h 127.0.0.1 -p 5432 -U YOUR_ADMIN_ROLE -d postgres -W -f 'database\create_ecosusrural_mvp.psql'
```

The script checks role capabilities, creates the database only if absent,
removes default PUBLIC database privileges, and grants the existing role
CONNECT. If the database appears between inventory and execution, it leaves
the existing database and grants alone. It never changes a role password or
any existing database. Run it only after reviewing the file.

## Authenticated application-role test

```powershell
& 'C:\Program Files\PostgreSQL\18\bin\psql.exe' -h 127.0.0.1 -p 5432 -U ecosusrural_app -d ecosusrural_mvp -W -c 'SELECT current_database(), current_user, inet_server_addr(), inet_server_port();'
```

For Express, privately set `PGHOST=127.0.0.1`, `PGPORT=5432`,
`PGDATABASE=ecosusrural_mvp`, and `PGUSER=ecosusrural_app`. Supply
`PGPASSWORD` only through your private local secret handling method. For a
temporary local test, in a private PowerShell terminal after the authenticated
`psql` test succeeds:

```powershell
$dbCredential = Get-Credential -UserName ecosusrural_app -Message 'Local EcoSusRural database login'
$env:PGHOST = '127.0.0.1'
$env:PGPORT = '5432'
$env:PGDATABASE = 'ecosusrural_mvp'
$env:PGUSER = 'ecosusrural_app'
$env:PGPASSWORD = $dbCredential.GetNetworkCredential().Password
Set-Location backend
npm.cmd start
```

Do not paste a password into a command or chat. This temporary environment
variable is inherited by the backend process; clear it with
`Remove-Item Env:PGPASSWORD` after stopping the backend. Use a managed secret
store for deployment, not a persistent environment variable or `.env` file.
Request `http://127.0.0.1:5000/ready` from another local terminal.
HTTP 200 with `database: available` proves a fresh authenticated query;
HTTP 503 indicates unavailable connectivity without revealing credentials.
`/health` is liveness, not a substitute for `/ready`.

The application role needs CONNECT for current startup/readiness. Add table
permissions only as actual database-backed routes are introduced, using a
separate migration role. Local SCRAM authentication can work without TLS;
production requires certificate-validated PostgreSQL TLS on a private network.
