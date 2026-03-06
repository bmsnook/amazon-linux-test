cat << EOF >> ~/.ssh/config

# AWS Instance: ${hostip}
Host ${host}
    HostName ${hostname}
    User ${user}
    IdentityFile ${identityfile}
    StrictHostKeyChecking no

EOF