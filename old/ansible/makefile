api:
	ansible-playbook -vJK api.yml

app:
	ansible-playbook -vJK app.yml

build:
	ansible-playbook -vJK build.yml -i hosts

cleanup:
	ansible-playbook -vJK cleanup_microk8s.yml -i hosts

database:
	ansible-playbook -vJ database.yml

k8s:
	ansible-playbook -vJK kubernetes.yml

migrations:
	ansible-playbook -vJ migrations.yml

monitoring:
	ansible-playbook -vJ monitoring.yml

queue:
	ansible-playbook -vJ queue.yml

storage:
	ansible-playbook -vJ storage.yml
