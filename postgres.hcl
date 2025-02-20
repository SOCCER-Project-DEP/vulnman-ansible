job "postgres" {
  type        = "service"
       
  group "postgres_group" {
    count = 1

    network {
      port "postgres" {
        to = 5432
      }
    }

    task "postgres_task" {
      driver = "docker"

      env = {
        POSTGRES_USER     = "postgres"
        POSTGRES_PASSWORD = "postgres"
        POSTGRES_DB       = "scan-db"
      }
      config {
        image = "postgres:17.0"
        ports = ["postgres"]
      }

      resources {
        cpu    = 500
        memory = 1024
      }

    }
  }
}