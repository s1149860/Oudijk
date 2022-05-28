#!/bin/bash

printf "Welcome to the self-service portal, made by Justin Oudijk (s1149860)!\n\n"

# Client's name:
read -p "Enter your customer name: " customer_name

if [[ -d /home/student/Oudijk/customers/$customer_name ]]
then
	printf "Welcome back, "$customer_name"!\n\n"
	printf "redirecting to your customer folder...\n\n"
	cd /home/student/Oudijk/customers/$customer_name
else
	mkdir -p /home/student/Oudijk/customers/$customer_name
	cd /home/student/Oudijk/customers/$customer_name
	printf "Your customer folder has been made, "$customer_name"!\n\n"
	printf "let's get started!\n\n"
fi


# What to do with environment?
printf "What would you like to do? Pick one of the following options:\n"
printf "Roll out a new environment: [new]\n"
printf "Change RAM of current environment: [current]\n"
printf "Delete an environment: [delete]\n"
printf "Close the self-service portal: [exit]\n" 
read -p "Choose option: " environment
printf "\n\n"

while [[ "$environment" != "new" && $environment != "current" && $environment != "delete" && $environment != "exit" ]]
do
	echo "We think you've made a typo. Let's try that again."
	read -p "Choose option: " environment
	printf "\n\n"
done

# Create new environment
if [[ "$environment" = "new" ]]
then

	# Which environment
	printf "Choose your environment:\n"
	printf "production environment: [production]\n"
	printf "acceptance environment: [acceptance]\n"
	printf "test environment: [test]\n"
	read -p "Choose option: " server_name
	printf "\n\n"

	while [[ "$server_name" != "production" && "$server_name" != "acceptance" && "$server_name" != "test" ]] 
	do
		echo "We think you've made a typo. Let's try that again."
		read -p "Choose option: " server_name
		printf "\n\n"
	done

	if [[ "$server_name" = "production" || "$server_name" = "acceptance" || "$server_name" = "test" ]]
	then
		mkdir -p /home/student/Oudijk/customers/$customer_name/$server_name
		cd /home/student/Oudijk/customers/$customer_name/$server_name

		cp /home/student/Oudijk/portal/templates/Vagrantfile /home/student/Oudijk/customers/$customer_name/$server_name/Vagrantfile
		sed -i "s/customer_name/$customer_name/g" Vagrantfile
		sed -i "s/environment/$customer_name/g" Vagrantfile

		cp /home/student/Oudijk/portal/templates/inventory.ini /home/student/Oudijk/customers/$customer_name/$server_name/inventory.ini
		sed -i "s/customer_name/$customer_name/g" inventory.ini
		sed -i "s/environment/$customer_name/g" inventory.ini

		read -p "Choose an available network (1-50): " setnet
		sed -i "s/setnet/$setnet/g" Vagrantfile
		sed -i "s/setnet/$setnet/g" inventory.ini

		cp /home/student/Oudijk/portal/templates/ansible.cfg /home/student/Oudijk/customers/$customer_name/$server_name/ansible.cfg
		vagrant plugin repair
		vagrant up

		echo "192.168.$setnet.11 $customer_name-WS01" | sudo tee -a /etc/hosts
		echo "192.168.$setnet.12 $customer_name-WS02" | sudo tee -a /etc/hosts
		echo "192.168.$setnet.20 $customer_name-LB01" | sudo tee -a /etc/hosts
		echo "192.168.$setnet.30 $customer_name-DB01" | sudo tee -a /etc/hosts

		ssh-keyscan 192.168."$setnet".11 "$customer_name"-WS01 >> ~/.ssh/known_hosts
		ssh-keyscan 192.168."$setnet".12 "$customer_name"-WS02 >> ~/.ssh/known_hosts
		ssh-keyscan 192.168."$setnet".20 "$customer_name"-LB01 >> ~/.ssh/known_hosts
		ssh-keyscan 192.168."$setnet".30 "$customer_name"-DB01 >> ~/.ssh/known_hosts

		cd /home/student/Oudijk/portal/templates/playbooks/roles
		ansible-playbook -i /home/student/Oudijk/customers/$customer_name/$server_name/inventory.ini serversetup.yml
	fi
fi

# Change RAM
if [[ "$environment" = "current" ]]
then

	#ask what type of enviroment to change
	printf "which environment would you like to change the RAM of? \n"
	printf "production environment: [production] \n"
	printf "acceptance environment: [acceptance] \n"
	printf "test environment: [test] \n"
	read -p "your option: " changetype
	printf "\n\n"

	while [[ $changetype != "production" && $changetype != "acceptance" && $changetype != "test" ]]
	do
		echo "We think you've made a typo. Let's try that again."
		read -p "Choose option: " changetype
		printf "\n\n"	
	
	done

	if [[ $changetype = "production" || $changetype = "acceptance" || $changetype = "test" ]] 
	then
		cd /home/student/Oudijk/customers/$customer_name/$changetype
		read -p "How much RAM would you like to assign to the $changetype environment? [in MB] : " ramount
		sed -i 's/^vb.memory .*$/	vb.memory = "'"$ramount"'"/g' Vagrantfile
		vagrant reload
	fi
fi

# Delete environment
if [[ "$environment" = "delete" ]]
then

	#ask what type of enviroment to change
	printf "which environment would you like to delete? \n"
	printf "production environment: [production] \n"
	printf "acceptance environment: [acceptance] \n"
	printf "test environment: [test] \n"
	read -p "your option: " delenv
	printf "\n\n"

	while [[ $delenv != "production" && $delenv != "acceptance" && $delenv != "test" ]]
	do
		echo "We think you've made a typo. Let's try that again."
		read -p "Choose option: " delenv		
	
	done

	if [[ $delenv = "production" || $delenv = "acceptance" || $delenv = "test" ]] 
	then
		cd /home/student/Oudijk/customers/$customer_name/$delenv
		vagrant destroy -f
		cd /home/student/VirtualBox VMs/


		cd /home/student/Oudijk/customers/$customer_name/
		rm -rf $delenv/
		sed -i "/$customer_name-$delenv-/d" /etc/hosts
	fi
fi

if [[ $environment = "exit" ]]
then
	printf "\n"
	#skip to the end
fi

printf "\n"
printf "Thanks for using the self-service portal! We hope we've helped you accordingly.\n"
printf "Copyright Justin Oudijk // Windesheim University of Applied Sciences.\n"
printf "All rights reserved.\n"
