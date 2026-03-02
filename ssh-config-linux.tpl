cat << EOF >> ~/.ssh/config

Host ${host}
    # IP ${hostip}
    HostName ${hostname}
    User ${user}
    IdentityFile ${identityfile}
    StrictHostKeyChecking no

EOF