#include "FileReplacer.hpp"
#include <fstream>
#include <iostream>
#include <sstream>

FileReplacer::FileReplacer(std::string filename, std::string oldString,
                           std::string newString)
    : filename(filename), oldString(oldString), newString(newString)
{
}

bool FileReplacer::replace()
{
    if (oldString.empty())
    {
        std::cout << "Error: search string cannot be empty" << std::endl;
        return false;
    }

    std::ifstream input(filename.c_str(), std::ios::in | std::ios::binary);
    if (!input.is_open())
    {
        std::cout << "Error: cannot open input file" << std::endl;
        return false;
    }

    std::ostringstream buffer;
    buffer << input.rdbuf();
    if (input.bad() || buffer.bad())
    {
        std::cout << "Error: cannot read input file" << std::endl;
        return false;
    }
    const std::string content = buffer.str();
    input.close();

    const std::string outputName = filename + ".replace";
    std::ofstream output(outputName.c_str(), std::ios::out | std::ios::binary | std::ios::trunc);
    if (!output.is_open())
    {
        std::cout << "Error: cannot create output file" << std::endl;
        return false;
    }

    std::string::size_type start = 0;
    std::string::size_type match;
    while ((match = content.find(oldString, start)) != std::string::npos)
    {
        output << content.substr(start, match - start);
        output << newString;
        start = match + oldString.length();
    }
    output << content.substr(start);
    output.close();

    if (!output)
    {
        std::cout << "Error: cannot write output file" << std::endl;
        return false;
    }
    return true;
}
