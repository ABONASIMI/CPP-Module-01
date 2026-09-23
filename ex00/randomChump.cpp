#include "zombie.hpp"

void randomChump(std::string name)
{
    Zombie a(name);
    a.announce();
}