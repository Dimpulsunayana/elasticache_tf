resource "aws_security_group" "redis" {
  name        = "${var.env}-reds_segrp"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.main_vpc

  ingress {
    description      = "redis"
    from_port        = 6379
    to_port          = 6379
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags       = merge(
    local.common_tags,
    { Name = "${var.env}-redis_segrp" }
  )
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.env}-redis_subnetgrp"
  subnet_ids = var.subnet_ids

  tags       = merge(
    local.common_tags,
    { name = "${var.env}-redis_subnetgrp" }
  )
}

resource "aws_elasticache_cluster" "example" {
  cluster_id        = "${var.env}-redis"
  description                 = "example description"
  node_type                   = var.node_type
  engine_version       = var.engine_version
  port                        = 6379
  num_node_groups         = 1
  replicas_per_node_group = 1

  subnet_group_name = aws_elasticache_subnet_group.redis.name
  security_group_ids = [aws_security_group.redis.id]

  tags       = merge(
    local.common_tags,
    { name = "${var.env}-redis" }
  )
}