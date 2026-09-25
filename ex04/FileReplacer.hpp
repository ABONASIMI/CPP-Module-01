#ifndef FILEREPLACER_HPP
#define FILEREPLACER_HPP

#include <fstream>
#include <string>
#include <iostream>

class FileReplacer
{
private:
    std::string filename;
    std::string oldString;
    std::string newString;

public:
    FileReplacer(std::string filename,
                 std::string oldString,
                 std::string newString);

    bool replace();
};

#endif