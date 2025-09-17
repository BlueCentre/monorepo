output "name" {
  value = (
    var.disable ?
    null :
    google_container_node_pool.node_pool[0].name
  )
}
