#include <fstream>
#include <string>
#include <vector>

int main(int argc, char *argv[]) {
  std::vector<std::string> arguments(argv + 1, argv + argc);
  for (const auto &file : arguments) {
    std::ofstream outfile{
        file, std::fstream::in | std::fstream::out | std::fstream::app};
    outfile.close();
  }
  return 0;
}