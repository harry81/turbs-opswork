bash "fetch repository" do
  user "deploy"
  cwd node.turbs.src_path

  code <<-BASH
  if [ ! -d turbs-backend ]; then
    git clone #{node.turbs.src_git_url}
    cd turbs-backend
  else
    cd turbs-backend
    git fetch -p
    git reset --hard origin/master
  fi
  BASH
  action :run
end

bash "pip install package" do
  user "deploy"
  cwd node.turbs.deploy_path
  code <<-BASH
  export HOME=/home/deploy
  if [ ! -d .venv-turbs ]; then
    virtualenv .venv-turbs
  fi
  source .venv-turbs/bin/activate
  pip install -r src/turbs-backend/requirements.txt
  BASH
  action :run
end

bash "migrate" do
  user "deploy"
  cwd node.turbs.deploy_path
  code <<-BASH
  export HOME=/home/deploy
  source .venv-turbs/bin/activate
  cd src/turbs-backend
  python manage.py collectstatic --noinput
  python manage.py migrate
  BASH
  action :run
end

bash "run uwsgi" do
  user "deploy"
  cwd node.turbs.deploy_path
  code <<-BASH
  export HOME=/home/deploy
  source .venv-turbs/bin/activate
  cd src/turbs-backend
  kill -9 $(pidof uwsgi)

  uwsgi --ini uwsgi-turbs.ini
  BASH
  action :run
end
