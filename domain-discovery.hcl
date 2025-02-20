job "domain_discovery" {
    type        = "batch"

  group "domain_discovery_group" {
    task "domain_discovery_task" {
      driver = "docker"
        env {
          DB_CONN_STR = "postgresql://postgres:postgres@postgres_db:5432/scan-db"
        }
      config {
        image          = "ghcr.io/soccer-project-dep/vulnman-domain-discovery:main"
        command        = "poetry"
        args          = ["run", "python", "src/main.py","--target","pentest01.csirt.muni.cz"]
      }

      resources {
        cpu    = 500 # Adjust CPU resources as needed.
        memory = 256 # Adjust memory resources as needed.
      }

    }
  }
}
