#include "FileReplacer.hpp"
#include <sstream>

FileReplacer::FileReplacer(std::string filename,
                           std::string oldString,
                           std::string newString)
    : filename(filename), oldString(oldString), newString(newString)
{
}

bool FileReplacer::replace()
{
    if (oldString.empty())
    {
        std::cout << "Error: old string cannot be empty" << std::endl;
        return false;
    }

    std::ifstream input(filename.c_str(), std::ios::binary);

    if (!input.is_open())
    {
        std::cout << "Error: cannot open file" << std::endl;
        return false;
    }

    std::ostringstream buffer;
    buffer << input.rdbuf();

    if (input.bad())
    {
        std::cout << "Error: cannot read file" << std::endl;
        return false;
    }

    const std::string content = buffer.str();
    const std::string outputName = filename + ".replace";

    std::ofstream output(outputName.c_str(), std::ios::binary);

    if (!output.is_open())
    {
        std::cout << "Error: cannot create file" << std::endl;
        return false;
    }

    std::string::size_type pos = 0;
    std::string::size_type found;

    while ((found = content.find(oldString, pos)) != std::string::npos)
    {
        output << content.substr(pos, found - pos);
        output << newString;
        pos = found + oldString.length();
    }

    output << content.substr(pos);
    output.close();

    if (!output)
    {
        std::cout << "Error: cannot write output file" << std::endl;
        return false;
    }

    return true;
}
