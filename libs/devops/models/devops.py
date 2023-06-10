# See:
# - https://www.w3schools.com/python/python_inheritance.asp
# - https://github.com/faif/python-patterns/blob/master/patterns/creational/abstract_factory.py

import random
from typing import Type

# Parent Class
class DevOps:
    def __init__(self, name: str) -> None:
        self.name = name

    def __str__(self) -> str:
        raise NotImplementedError

    def speak(self) -> None:
        raise NotImplementedError

    def responsibility(self) -> None:
        raise NotImplementedError


# Child Classes
class InfrastructureEngineer(DevOps):
    def __str__(self) -> str:
        return f"InfrastructureEngineer<{self.name}>"

    def speak(self) -> None:
        print("cloud")

class DeveloperExperienceEngineer(DevOps):
    def __str__(self) -> str:
        return f"DeveloperExperienceEngineer<{self.name}>"

    def speak(self) -> None:
        print("build")

class DataEngineer(DevOps):
    def speak(self) -> None:
        print("data")

    def __str__(self) -> str:
        return f"DataEngineer<{self.name}>"

class MachineLearningEngineer(DevOps):
    def speak(self) -> None:
        print("unicorn")

    def __str__(self) -> str:
        return f"MachineLearningEngineer<{self.name}>"

class WebEngineer(DevOps):
    def speak(self) -> None:
        print("feature")

    def __str__(self) -> str:
        return f"WebEngineer<{self.name}>"

class ReliabilityEngineer(DevOps):
    def speak(self) -> None:
        print("scale")

    def __str__(self) -> str:
        return f"ReliabilityEngineer<{self.name}>"

class PlatformEngineer(DevOps):
    """Fullstack Platform Engineer"""

    def speak(self) -> None:
        print("internal product")
        print("very rare")

    def __str__(self) -> str:
        return f"PlatformEngineer<{self.name}>"


# Factory
class PlatformOrganization:
    """Platform Organization"""

    def __init__(self, platform_factory: Type[DevOps]) -> None:
        """devops_factory is our abstract factory.  We can set it at will."""

        self.devops_factory = platform_factory

    def request_devops(self, name: str) -> DevOps:
        """Creates and shows a pet using the abstract factory"""

        devops = self.devops_factory(name)
        print(f"Here is your awesome {devops}")
        return devops


# Additional factories:

# Create a random platform
def random_platform(name: str) -> DevOps:
    """Let's be dynamic!"""
    return random.choice([
        InfrastructureEngineer, 
        DeveloperExperienceEngineer, 
        DataEngineer, 
        MachineLearningEngineer, 
        WebEngineer, 
        ReliabilityEngineer, 
        PlatformEngineer])(name)


# Show devops with various factories
# def main() -> None:
#     """
#     # A Shop that sells only cats
#     >>> cat_shop = PetShop(Cat)
#     >>> pet = cat_shop.buy_pet("Lucy")
#     Here is your lovely Cat<Lucy>
#     >>> pet.speak()
#     meow

#     # A shop that sells random animals
#     >>> shop = PetShop(random_animal)
#     >>> for name in ["Max", "Jack", "Buddy"]:
#     ...    pet = shop.buy_pet(name)
#     ...    pet.speak()
#     ...    print("=" * 20)
#     Here is your lovely Cat<Max>
#     meow
#     ====================
#     Here is your lovely Dog<Jack>
#     woof
#     ====================
#     Here is your lovely Dog<Buddy>
#     woof
#     ====================
#     """


# if __name__ == "__main__":
#     # for deterministic doctest outputs
#     random.seed(1234)

#     shop = PlatformOrganization(random_platform)
#     import doctest

#     doctest.testmod()
