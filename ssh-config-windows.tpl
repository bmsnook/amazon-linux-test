add-content -path "$${env:HOMEDRIVE}$${env:HOMEPATH}/.ssh/config" -value @'

# AWS Instance: ${hostip}
Host ${host}
    HostName ${hostname}
    User ${user}
    IdentityFile ${identityfile}
    StrictHostKeyChecking
'@