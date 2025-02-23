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

## Setup

```bash
# Create project on GitLab and get new project token with API access and reporter permissions
# Update the inventory file with the scanner machine IP
nano inventory.yml  # Edit and save
# Configure the environment file
nano vulnman.env  # Edit and save
# Review the configuration file
nano nuclei_orchestrator_configs/scheduled-config.toml  # Edit and save

# Run the Ansible playbook to deploy everything
ansible-playbook -i inventory.yml playbooks/deploy-all.yml # -kK for password prompt
```

## Usage

```bash
ssh <your_machine> 
sudo systemctl start domain_discovery.service

export PGPASSWORD=<YOUR_POSTGRES_PASSWORD>

psql -U postgres -h localhost -d scan-db -c "SELECT name, port FROM domains"

# Start the scanning service
sudo systemctl start nuclei-scheduled.service

# Check the status of the scanning service
# sudo journalctl -u nuclei-scheduled.service --follow

# View scan results in the database
psql -U postgres -h localhost -d scan-db -c "SELECT * FROM findings"
```

## Setup docker

Ansible setup is recommended because it sets up other useful features like systemd timers for continuous scanning.

```bash
# Setup configuration files as described above
# Start postgres db
docker compose -f /opt/postgres_db/postgres.compose.yml up -d

# Run the domain discovery
docker compose -f domain_discovery.compose.yml --env-file vulnman.env up 

# Run the nuclei orchestrator
docker compose -f nuclei_orchestrator.compose.yml --env-file vulnman.env up

# Now to setup continuous scanning, create either a systemd timer or a cron job to run domain_discovery and nuclei-scheduled periodically
```

## Configuration

Both domain_discovery and nuclei-scheduled can be configured using cli arguments or configuration files.

To see all available options, run the tools with the `--help` flag.
```bash
# nuclei-orchestrator
sudo docker run -it --entrypoint sh vulnman/nuclei-orchestrator:latest
poetry run nuclei-scan-runner -h
# domain_discovery
docker run -it vulnman/domain-discovery poetry run python src/main.py --help
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

