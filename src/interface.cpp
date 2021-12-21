#include <string.h>
#include <yaml-cpp/yaml.h>
#include <iostream>

#include "hostCode.h"

int main(int argc, char *argv[])
{
	YAML::Node config = YAML::LoadFile("./config/config.yml");

	const std::string version = config["version"].as<std::string>();
	std::cout << "version: " << version << "\n";

	Params params(1024, 1024);
	params.virusNtr = config["ntr"].as<double>();
	params.virusEnvSupport = config["v_env"].as<double>();

	printf("\n -- running virus simulator --\n");

	runVS(&params);
	return 0;
}
