# Vulnerability Management (VulnMan) - Ansible

This repository contains Ansible playbooks and roles to automate deploy of [vulman-nuclei-orchestrator](https://github.com/SOCCER-Project-DEP/vulnman-nuclei-orchestrator) and [vulman-domain-discovery](https://github.com/SOCCER-Project-DEP/vulnman-domain-discovery).

## How it works

1. The Ansible playbook installs all necessary dependencies on the target machine.
2. You run domain_dicovery, which takes a **target** domain and tries to find as many subdomains/IP addresses and their ports as possible.
3. You run nuclei-scheduled, which takes a **config file** and scans all the subdomains/IP addresses and their ports for vulnerabilities.
4. The results are stored in a PostgreSQL database. You can view them using `psql` or any other PostgreSQL client. Optionally, you can send the results to the GitLab repository, which will create issues for each finding. The tool handles duplicate issues.

## Requirements

Ansible is meant to run on clean Ubuntu and other distributions have not been tested. 
This Ansible depends on the APT package manager and will not work on other package managers.

If you do not have a clean Ubuntu machine, you can use Vagrant to create one using VirtualBox.

```bash
# Install VirtualBox and Vagrant
# Then run the following commands
vagrant up --provision
# Run the Ansible playbook to deploy everything on the Vagrant machine
ansible-playbook -i inventory-vagrant.yml playbooks/deploy-all.yml
```

## Usage

```bash
# Update the inventory file with the scanner machine IP
nano inventory.yml  # Edit and save

# Set the target domain in the configuration file
nano roles/domain_discovery/defaults/main.yml  # Update 'target'

# Run the Ansible playbook to deploy everything
ansible-playbook -i inventory.yml playbooks/deploy-all.yml

# Connect to the machine and populate the database with subdomains
ssh <your_machine> # Or 'vagrant ssh' if you are using Vagrant, and do not forget to switch to user 'ubuntu'
sudo systemctl start domain_discovery.service
# Wait for the discovery to finish
# sudo systemctl status domain_discovery.service

# Load the database password for psql client
export PGPASSWORD=$(cat /opt/db/db_pass)
# Verify the database is populated
psql -U postgres -h localhost -d scan-db -c "SELECT name, port FROM domains"

# Review the configuration file for scheduled scans
nano /home/ubuntu/vulnman-nuclei/configs/scheduled-config.toml
# If you do not have GitLab, set:
# dont-process-results = true

# Start the scanning service
sudo systemctl start nuclei-scheduled.service

# Check the status of the scanning service
# sudo systemctl status nuclei-scheduled.service

# View scan results in the database
psql -U postgres -h localhost -d scan-db -c "SELECT * FROM findings"
# Consider setting up a some kind of GUI service to view the results in the DB like pgAdmin
# By default, results are sent to GitLab, but you can configure a GUI service for easier browsing.
```

## Continuous scanning

To enable periodic scanning, enable following systemd timers:
- `sudo systemctl enable domain_discovery.timer`
- `sudo systemctl enable nuclei-scheduled.timer`

## Additional information

- This repository is being developed as a part of the [SOCCER](https://soccer.agh.edu.pl/en/) project.
- Developed by the cybersecurity team of [Masaryk University](https://www.muni.cz/en). 
- This project is a "mirror" of the original repository hosted on university Gitlab. New features and fixes here are being added upon new releases of the original repository.

## Help

Are you missing something? Do you have any suggestions or problems? Please create an issue.
Or ask us at `csirt-info@muni.cz`; we are happy to help you, answer your questions, or discuss your ideas.

