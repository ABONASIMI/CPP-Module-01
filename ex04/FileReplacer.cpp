#include "FileReplacer.hpp"

FileReplacer::FileReplacer(std::string filename,
                           std::string oldString,
                           std::string newString)
{
    this->filename = filename;
    this->oldString = oldString;
    this->newString = newString;
}

bool FileReplacer::replace()
{
    std::ifstream file(filename.c_str());

    if (!file.is_open())
    {
        std::cout << "Error: cannot open file" << std::endl;
        return false;
    }

    std::string outputName = filename + ".replace";
    std::ofstream file2(outputName.c_str());

    if (!file2.is_open())
    {
        std::cout << "Error: cannot create file" << std::endl;
        return false;
    }

    if (oldString.empty())
    {
        std::cout << "Error: old string cannot be empty" << std::endl;
        return false;
    }

    std::string line;

    while (std::getline(file, line))
    {
        std::string::size_type pos = 0;
        std::string::size_type found;

        while ((found = line.find(oldString, pos)) != std::string::npos)
        {
            file2 << line.substr(pos, found - pos);
            file2 << newString;

            pos = found + oldString.length();
        }

        file2 << line.substr(pos);

        if (!file.eof())
            file2 << std::endl;
    }

    file.close();
    file2.close();

    return true;
}