[${label}]
%{ for _, instance in instances ~}
${instance.hostname}
%{ endfor ~}

[${label}:vars]
ansible_python_interpreter=/usr/bin/python3
