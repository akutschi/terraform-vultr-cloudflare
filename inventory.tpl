[wireguard]
%{ for _, instance in instances ~}
${instance.hostname}
%{ endfor ~}

[wireguard:vars]
ansible_python_interpreter=/usr/bin/python3
