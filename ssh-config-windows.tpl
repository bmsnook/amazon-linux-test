add-content -path "$${env:HOMEDRIVE}$${env:HOMEPATH}/.ssh/config" -value @'

Host ${host}
    # IP ${hostip}
    HostName ${hostname}
    User ${user}
    IdentityFile ${identityfile}
    StrictHostKeyChecking
'@