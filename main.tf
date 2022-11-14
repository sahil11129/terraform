locals {
  name          = "ibm-cpd-wa-instance"
  bin_dir       = module.setup_clis.bin_dir
  operandrequest_name  = "ibm-cpd-wa-operandrequest"
  operandrequest_yaml_dir = "${path.cwd}/.tmp/${local.name}/chart/${local.operandrequest_name}"
  subscription_name  = "ibm-cpd-wa-subcription"
  subscription_yaml_dir = "${path.cwd}/.tmp/${local.name}/chart/${local.subscription_name}"
  instance_yaml_dir = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  ingress_host  = "${local.name}-${var.namespace}.${var.cluster_ingress_hostname}"
  ingress_url   = "https://${local.ingress_host}"
  service_url   = "http://${local.name}.${var.namespace}"

  operandrequest_content = {
    common_services_namespace = var.common_services_namespace
    cpd_namespace = var.cpd_namespace      
  } 
  
  subscription_content = {
    name = "ibm-watson-assistant-operator-subscription"
    operator_namespace = var.operator_namespace
    syncwave = var.sub_syncwave
    spec = {
      channel = var.operator_channel
      installPlanApproval = var.install_plan
      name = "ibm-watson-assistant-operator"
      source = "ibm-operator-catalog"
      sourceNamespace = "openshift-marketplace"        
    }       
  }   
  
  instance_content = {
    name = "wa"
    version = var.instance_version
    cpd_namespace = var.cpd_namespace  
    storage_class = var.storage_class
    syncwave = var.inst_syncwave      
  }

  layer = "services"
  operator_type  = "operators"
  type  = "instances"
  application_branch = "main"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_operandrequest_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.operandrequest_name}' '${local.operandrequest_yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.operandrequest_content)
    }
  }
}

resource null_resource setup_gitops_operandrequest {
  depends_on = [null_resource.create_operandrequest_yaml]

  triggers = {
    name = local.operandrequest_name
    namespace = var.namespace
    yaml_dir = local.operandrequest_yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.operator_type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}

resource null_resource create_subcription_yaml {
  depends_on = [null_resource.setup_gitops_operandrequest]
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.subscription_name}' '${local.subscription_yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.subscription_content)
    }
  }
}

resource null_resource setup_gitops_subscription {
  depends_on = [null_resource.create_subcription_yaml]

  triggers = {
    name = local.subscription_name
    namespace = var.namespace
    yaml_dir = local.subscription_yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.operator_type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}

resource null_resource create_instance_yaml {
  depends_on = [null_resource.setup_gitops_subscription]

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.instance_yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.instance_content)
    }
  }
}

resource null_resource setup_gitops_instance {
  depends_on = [null_resource.create_instance_yaml]

  triggers = {
    name = local.name
    namespace = var.namespace
    yaml_dir = local.instance_yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}
  
  module "cp-watson-assistant" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-cp-watson-assistant.git"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.gitops_namespace.name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  operator_namespace= module.gitops_cp4d_operator.namespace
  cpd_namespace = module.cp4d-instance.namespace
}
}
