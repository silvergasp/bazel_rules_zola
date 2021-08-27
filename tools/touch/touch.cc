#include <fstream>
#include <iostream>
#include <string>
#include <vector>

int main(int argc, char *argv[]) {
  std::vector<std::string> arguments(argv + 1, argv + argc);
  for (const auto &file : arguments) {
    std::ofstream outfile{
        file, std::fstream::in | std::fstream::out | std::fstream::app};
    if (!outfile.is_open()) {
      std::cerr << "Failed to touch file: " << file << std::endl;
      return -1;
    }
  }
  return 0;
}