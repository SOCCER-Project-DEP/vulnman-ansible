job "nuclei_orchestrator" {
    type = "batch"

    group "nuclei_orchestrator_group" {
        task "nuclei_orchestrator_task" {
            driver = "docker"
            
            env {
                DB_CONNECTION_STRING = "postgresql://postgres:postgres@postgres_db:5432/scan-db"
                GL_TOKEN = "<your-gitlab-token>"
            }
            
            config {
                image   = "ghcr.io/soccer-project-dep/vulnman-nuclei-orchestrator:main"
                command = "poetry"
                args    = ["run", "nuclei-scan-runner", "--config", "./configs/testing-config.toml"]
            }
            
            resources {
                cpu    = 500   # Adjust CPU resources as needed.
                memory = 256   # Adjust memory resources as needed.
            }
        }
    }
}