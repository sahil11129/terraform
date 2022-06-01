
resource null_resource write_outputs {
  provisioner "local-exec" {
    command = "echo \"$${OUTPUT}\" > gitops-output.json"

    environment = {
      OUTPUT = jsonencode({
        name        = module.cp-watson-assistant.name
        inst_name   = module.cp-watson-assistant.inst_name
        sub_chart   = module.cp-watson-assistant.sub_chart
        sub_name   = module.cp-watson-assistant.sub_name 
        operator_namespace = module.cp-watson-assistant.operator_namespace
        cpd_namespace= module.cp-watson-assistant.cpd_namespace
        branch      = module.cp-watson-assistant.branch
        namespace   = module.cp-watson-assistant.namespace
        server_name = module.cp-watson-assistant.server_name
        layer       = module.cp-watson-assistant.layer
        layer_dir   = module.cp-watson-assistant.layer == "infrastructure" ? "1-infrastructure" : (module.cp-watson-assistant.layer == "services" ? "2-services" : "3-applications")
        type        = module.cp-watson-assistant.type
      })
    }
  }
}
