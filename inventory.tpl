[vpn]
%{ for _, instance in instances ~}
${instance.hostname}
%{ endfor ~}

[vpn:vars]
ansible_python_interpreter=/usr/bin/python3
