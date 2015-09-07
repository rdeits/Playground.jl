function activate(config::Config; dir::AbstractString="", name::AbstractString="")
    init(config)

    root_path = get_playground_dir(config, dir, name)
    log_path = joinpath(root_path, "log")
    bin_path = joinpath(root_path, "bin")
    pkg_path = joinpath(root_path, "packages")

    Logging.configure(level=Logging.DEBUG, filename=joinpath(log_path, "playground.log"))

    Logging.info("Setting PATH variable to using to look in playground bin dir first")
    ENV["PATH"] = "$(bin_path):" * ENV["PATH"]
    Logging.info("Setting the JULIA_PKGDIR variable to using the playground packages dir")
    ENV["JULIA_PKGDIR"] = pkg_path

    if config.isolated_julia_history
        ENV["JULIA_HISTORY"] = joinpath(root_path, ".julia_history")
    end

    Logging.info("Executing a playground shell")
    run_shell(config.activated_prompt)
end


@windows_only begin
    function run_shell(prompt)
        run(`cmd /K prompt $(prompt)`)
    end
end


@unix_only begin
    function run_shell(prompt)
        ENV["PS1"] = prompt
        if haskey(ENV, "SHELL")
            run(`$(ENV["SHELL"])`)
        else
            run(`sh -i`)
        end
    end
end