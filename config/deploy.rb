# frozen_string_literal: true

require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina_sidekiq/tasks'
require 'mina/puma'

# Install https://github.com/mina-deploy/mina-version_managers for rbenv and rvm tasks
require 'mina/version_managers/rbenv'  # for rbenv support. (https://rbenv.org)
# require 'mina/version_managers/rvm'    # for rvm support. (https://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :application_name, :price_web_parser
set :domain, 'yury@5.188.119.172'
set :port, 1693
set :deploy_to, '/home/yury/PriceWebParser'
set :repository, 'git@github.com:Winter-Silence/PriceWebParser.git'
set :branch, 'main'
set :rbenv_path, '$HOME/.rbenv'
set :bundler_path, '/home/yury/.rbenv/shims/bundler'
set :init_system, :systemd
set :service_unit_path, '/home/yury/.config/systemd/user'
set :systemctl_command, 'systemctl --user'
set :service_unit_name, 'sidekiq-yury.service'

# Optional settings:
#   set :user, 'foobar'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
# set :shared_dirs, fetch(:shared_dirs, []).push('public/assets')
# set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')

set :shared_files, fetch(:shared_files, []).push('log', 'config/database.yml', 'config/secrets.yml', 'db/production.sqlite3', 'tmp/pids', 'tmp/sockets')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  invoke :'rbenv:load'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  in_path(fetch(:shared_path)) do
    # command %[mkdir -p log]
    # command %[chmod g+rx,u+rwx log]
    #
    # command %[mkdir -p config]
    # command %[chmod g+rx,u+rwx config]
    #
    # command %[touch config/database.yml]
    # command %[touch config/secrets.yml]
    # command %[echo "-----> Be sure to edit 'config/database.yml' and 'secrets.yml'."]
    # command %[mkdir -p tmp/sockets]
    # command %[chmod g+rx,u+rwx tmp/sockets]
    # command %[mkdir -p tmp/pids]
    # command %[chmod g+rx,u+rwx tmp/pids]

    # command %(
    #   repo_host=`echo $repo | sed -e 's/.*@//g' -e 's/:.*//g'` &&
    #   repo_port=`echo $repo | grep -o ':[0-9]*' | sed -e 's/://g'` &&
    #   if [ -z "${repo_port}" ]; then repo_port=22; fi &&
    #   ssh-keyscan -p $repo_port -H $repo_host >> ~/.ssh/known_hosts
    # )
  end
end

namespace :puma do
  set :puma_cmd,       -> { "#{fetch(:bundle_prefix)} puma" }
  set :pumactl_cmd,    -> { "#{fetch(:bundle_prefix)} pumactl" }

  desc 'Start puma'
  task :start do
    puma_port_option = "-p #{fetch(:puma_port)}" if set?(:puma_port)

    comment 'Starting Puma...'
    command %[
      if [ -e "#{fetch(:puma_pid)}"  ] && kill -0 "$(cat #{fetch(:puma_pid)})" 2> /dev/null; then
        echo 'Puma is already running!';
      else
echo '#{fetch(:puma_root_path)} && #{fetch(:puma_cmd)} -qe #{fetch(:puma_env)} -C #{fetch(:puma_config)}'
        if [ -e "#{fetch(:puma_config)}" ]; then
          cd #{fetch(:puma_root_path)} && #{fetch(:puma_cmd)} -qe #{fetch(:puma_env)} -C #{fetch(:puma_config)}
        else
          cd #{fetch(:puma_root_path)} && #{fetch(:puma_cmd)} -q -d -e #{fetch(:puma_env)} -b "unix://#{fetch(:puma_socket)}" #{puma_port_option} -S #{fetch(:puma_state)} --pidfile #{fetch(:puma_pid)} --control 'unix://#{fetch(:pumactl_socket)}' --redirect-stdout "#{fetch(:puma_stdout)}" --redirect-stderr "#{fetch(:puma_stderr)}"
        fi
      fi
    ]
  end

  def pumactl_restart_command(command)
    puma_port_option = "-p #{fetch(:puma_port)}" if set?(:puma_port)

    cmd =  %{
      if [ -e "#{fetch(:puma_pid)}"  ] && kill -0 "$(cat #{fetch(:puma_pid)})" 2> /dev/null; then
        if [ -e "#{fetch(:puma_config)}" ]; then
          cd #{fetch(:puma_root_path)} && #{fetch(:pumactl_cmd)} -F #{fetch(:puma_config)} #{command}
        else
          cd #{fetch(:puma_root_path)} && #{fetch(:pumactl_cmd)} -S #{fetch(:puma_state)} -C "unix://#{fetch(:pumactl_socket)}" --pidfile #{fetch(:puma_pid)} #{command}
        fi
      else
        echo "Puma is not running, restarting";
        if [ -e "#{fetch(:puma_config)}" ]; then
          cd #{fetch(:puma_root_path)} && #{fetch(:puma_cmd)} -qe #{fetch(:puma_env)} -C #{fetch(:puma_config)}
        else
          cd #{fetch(:puma_root_path)} && #{fetch(:puma_cmd)} -q -d -e #{fetch(:puma_env)} -b "unix://#{fetch(:puma_socket)}" #{puma_port_option} -S #{fetch(:puma_state)} --pidfile #{fetch(:puma_pid)} --control 'unix://#{fetch(:pumactl_socket)}' --redirect-stdout "#{fetch(:puma_stdout)}" --redirect-stderr "#{fetch(:puma_stderr)}"
        fi
      fi
    }
    command cmd
  end
end

desc 'Deploys the current version to the server.'
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'sidekiq:restart'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
        # command %{whenever —set «path=`pwd`» -w}
        # invoke :'sidekiq:restart'
        # command %{sv restart roulette_sidekiq}
      end
      invoke :'puma:smart_restart'
    end
  end

  # you can use `run :local` to run tasks on local machine before or after the deploy scripts
  # run(:local){ say 'done' }
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
