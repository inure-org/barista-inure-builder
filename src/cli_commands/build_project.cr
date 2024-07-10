class BuildProject < ACON::Command
	include Barista::Behaviors::Software::OS::Information

	@@default_name = "build"

	getter :project_map

	def initialize(@project_map : Hash(String, Barista::Behaviors::Omnibus::Project));
		super()
	end

	protected def execute(input : ACON::Input::Interface, ouput : ACON::Output::Interface) : ACON::Command::Status
		edition = input.argument("edition") || "inure-ce"
		workers = input.option("workers", Int32?) || memory.cpus.try(&.-(1)) || 1
		version = input.option("build") || "master"

		project = project_map[edition]?

		unless project
			output.puts("<warn>#{edition} não é suportado<warn>")

			return ACON::Command::Status::FAILURE
		end

		begin
			project.build(version: version, workers: workers)
	
			ACON::Command::Status::SUCCESS
		rescue ex
			output.puts("<error>build falhou: #{ex.message}</error>")

			ACON::Command::Status::FAILURE
		end
	end

	def configure : Nil
		self
			.description("constrói uma edição do inure")
			.argument("edition", :optional, "a edição a ser construída [#{project_map.keys.join("|")}] (padrão inure-ce)")
			.option("build", "b", :optional, "a versão da edição a ser construída (padrão master)")
			.option("workers", "w", :optional, "o número de workers da build concorrente (padrão #{memory.cpus.try(&.-(1)) || 1})")
	end
end
