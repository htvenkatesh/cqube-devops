#!/bin/bash

if [ `whoami` != root ]; then
    tput setaf 1; echo "Please run this script using sudo"; tput sgr0
  exit
else
    if [[ "$HOME" != "/root" ]]; then
        tput setaf 1; echo "Please run this script using normal user with 'sudo' privilege,  not as 'root'"; tput sgr0
    fi
fi

#Running script to install the basic softwares
chmod u+x shell_scripts/basic_requirements.sh
. "shell_scripts/upgrade_basic_requirements.sh"


storage_type=$(awk ''/^storage_type:' /{ if ($2 !~ /#.*/) {print $2}}' upgradation_config.yml)

chmod u+x shell_scripts/install_aws_cli.sh
. "shell_scripts/install_aws_cli.sh"

chmod u+x shell_scripts/install_azure_cli.sh
. "shell_scripts/install_aws_azure.sh"


#Running script to validate and genarat config file
chmod u+x shell_scripts/upgradation_config_file_generator.sh
echo -e "\e[0;36m${bold}NOTE: We are going through a process of generating a configuration file. Please refer to the hints provided and enter the correct value${normal}"
. "shell_scripts/upgradation_config_file_generator.sh"

if [[ $storage_type == "local" ]]; then
chmod u+x shell_scripts/minio/install_minio.sh
. "shell_scripts/minio/install_minio.sh"
chmod u+x shell_scripts/minio/install_mc_client.sh
. "shell_scripts/minio/install_mc_client.sh"

fi

chmod u+x shell_scripts/program_selector.sh
. "shell_scripts/program_selector.sh"

#Running script to clone ingestion, spec repository
chmod u+x shell_scripts/repository_clone.sh
. "shell_scripts/repository_clone.sh"

if [ -e /etc/ansible/ansible.cfg ]; then
    sudo sed -i 's/^#log_path/log_path/g' /etc/ansible/ansible.cfg
fi

echo '127.0.0.0' >> /etc/ansible/hosts

if [ ! $? = 0 ]; then
tput setaf 1; echo "Error there is a problem installing Ansible"; tput sgr0
exit
fi

ansible-playbook ansible/upgrade.yml
ansible-playbook ansible/upgrade_compose.yml

if [ $? = 0 ]; then
echo -e "\e[0;32m${bold}cQube installed successfully!!${normal}"
fi

#Running script to display important links
chmod u+x shell_scripts/generate_access_links.sh
. "shell_scripts/generate_access_links.sh"