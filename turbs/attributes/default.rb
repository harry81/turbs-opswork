default["turbs"]["deploy"] = "deploy"
default["turbs"]["deploy_path"] = "/home/#{node.turbs.deploy}"
default["turbs"]["src_path"] = "#{node.turbs.deploy_path}/src"
default["turbs"]["src_git_url"]="git@bitbucket.org:tubrs/turbs-backend.git"

node.default['postgresql']['version']="9.4"
node.default['postgresql']['password']['postgres']="turbs81"
node.default['postgresql']['config']['port']=5432
