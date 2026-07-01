resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.environment}-${var.project}-db-credentials"
  description             = "Database credentials"
  recovery_window_in_days = var.recover_window

  lifecycle {
    // prevent accidental destroy
    prevent_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    engine   = var.engine
    host     = var.db_host
    port     = var.db_port
    dbname   = var.db_name
  })
}
