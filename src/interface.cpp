#include <string.h>
#include <yaml-cpp/yaml.h>
#include <iostream>

#include "interface.h"

int main(int argc, char *argv[])
{
	YAML::Node config = YAML::LoadFile("./config/config.yml");

	const std::string version = config["version"].as<std::string>();
	std::cout << "version: " << version << "\n";

	AParams PARAMS;
	setDefaults(&PARAMS);

	printf("\n -- running virus simulator --\n");

	runVS(&PARAMS);
	return 0;
}

int setDefaults(AParams *PARAMS)
{
	PARAMS->height = 1024;
	PARAMS->width = 1024;
	PARAMS->sizePopulation = 1024 * 1024; // = 1,048,576

	return 0;
}