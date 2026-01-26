build:
	cd ansible && ansible-playbook -vK -i hosts build.yml

directories:
	cd ansible && ansible-playbook -v -i hosts directories.yml
