Capistrano::Configuration.instance(:must_exist).load do
  before "deploy" do
    logger.info "Pushing git repo for branch #{branch}"
    run_locally(source.scm("push", "origin", branch))

    next if ENV["RSPEC"] == "0"

    logger.info "Running tests"

    results = system("rspec ./")
    unless results
      raise Capistrano::Error.new("Test failure, deploy aborted")
    end
  end

  before "bundle:install" do
    logger.info "Loading submodules"
    run "cd #{latest_release} && git submodule init && git submodule update && chown -R deploy:deploy #{latest_release}/shared"
  end

  after "deploy:update_code" do
    unless ENV["RECOMPILE"] == "1"
      commits = run_locally(source.scm("log", "--name-only", "#{previous_revision}..#{latest_revision}"))
      unless commits =~ /app\/assets/i
        logger.info "No asset changes, copying previous data over instead"
        run "cp -r #{previous_release}/public/assets #{latest_release}/public/assets", :roles => [:app]
        next
      end
    end

    run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} RAILS_GROUPS=assets assets:precompile", :roles => [:app]
  end

  after "deploy:create_symlink" do
    if ENV["FORCEBUST"] != "1" and ENV["RECOMPILE"] != "1"
      commits = run_locally(source.scm("log", "--name-only", "#{previous_revision}..#{latest_revision}"))
      unless commits =~ /app\/assets\/(javascripts|stylesheets)/i
        logger.info "No portfolio asset changes"
        next
      end

      if commits =~ /app\/assets\/javascripts/i and commits =~ /app\/assets\/stylesheets/i
        type = "all"
      elsif commits =~ /app\/assets\/javascripts/i
        type = "js"
      elsif commits =~ /app\/assets\/stylesheets/i
        type = "css"
      end
    end

    run "cd #{latest_release} && RAILS_ENV=#{rails_env} ruby script/bust-assets #{type || "all"}", :roles => [:app], :once => true
  end

  after "deploy" do
    run "curl -s http://portfolio.cdn.zapfol.io > null"
  end
end