# Vulnerability Management (VulnMan) - Ansible

This repository contains Ansible playbooks,roles and docker compose files to automate deploy of [vulman-nuclei-orchestrator](https://github.com/SOCCER-Project-DEP/vulnman-nuclei-orchestrator) and [vulman-domain-discovery](https://github.com/SOCCER-Project-DEP/vulnman-domain-discovery).

## How it works

1. The Ansible playbook installs all necessary dependencies on the target machine.
2. You run domain_dicovery, which takes a **target** domain and tries to find as many subdomains/IP addresses and their ports as possible.
3. You run nuclei-scheduled, which takes a **config file** and scans all the subdomains/IP addresses and their ports for vulnerabilities.
4. The results are stored in a PostgreSQL database. You can view them using `psql` or any other PostgreSQL client. Optionally, you can send the results to the GitLab repository, which will create issues for each finding. The tool handles duplicate issues.

## Requirements

Ansible is meant to run on clean Ubuntu and other distributions have not been tested. 
This Ansible depends on the APT package manager and will not work on other package managers.

If you do not have a clean Ubuntu machine, you can use docker standalone setup.

## Usage docker

Ansible setup is recommended because it sets up other useful features like systemd timers for continuous scanning.

```bash
# start postgres db
docker compose -f /opt/postgres_db/postgres.compose.yml up -d

# Run the domain discovery
docker compose -f domain_discovery.compose.yml --env-file vulnman.env up 

# Run the nuclei orchestrator
docker compose -f nuclei_orchestrator.compose.yml --env-file vulnman.env up

# Now to setup continuous scanning, create either a systemd timer or a cron job to run domain_discovery and nuclei-scheduled periodically
```

## Usage ansible

```bash
# Update the inventory file with the scanner machine IP
nano inventory.yml  # Edit and save
# Configure the environment file
nano vulnman.env  # Edit and save
# Review the configuration file
# If you do not have GitLab, set:
# dont-process-results = true
nano nuclei_orchestrator_configs/scheduled-config.toml  # Edit and save

# Run the Ansible playbook to deploy everything
ansible-playbook -i inventory.yml playbooks/deploy-all.yml # -kK for password prompt

ssh <your_machine> # Or 'vagrant ssh' if you are using Vagrant
sudo systemctl start domain_discovery.service

export PGPASSWORD=<YOUR_POSTGRES_PASSWORD>

psql -U postgres -h localhost -d scan-db -c "SELECT name, port FROM domains"

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

To enable periodic scanning, (optionally reconfigure) and enable following systemd timers:
- `sudo systemctl enable domain_discovery.timer`
- `sudo systemctl enable nuclei-scheduled.timer`

## Additional information

- This repository is being developed as a part of the [SOCCER](https://soccer.agh.edu.pl/en/) project.
- Developed by the cybersecurity team of [Masaryk University](https://www.muni.cz/en). 
- This project is a "mirror" of the original repository hosted on university Gitlab. New features and fixes here are being added upon new releases of the original repository.

## Help

Are you missing something? Do you have any suggestions or problems? Please create an issue.
Or ask us at `csirt-info@muni.cz`; we are happy to help you, answer your questions, or discuss your ideas.

