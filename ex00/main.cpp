#include "Zombie.hpp"

int main()
{
    randomChump("Bob");

    Zombie *zombie = newZombie("Jack");
    zombie->announce();

    delete zombie;

    return 0;
}