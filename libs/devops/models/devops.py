# See:
# - https://www.w3schools.com/python/python_inheritance.asp
# - https://github.com/faif/python-patterns/blob/master/patterns/creational/abstract_factory.py
# Example:
# - https://github.com/Netflix/dispatch/blob/master/tests/factories.py

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
        print("How would you like your cloud today?")

class DeveloperExperienceEngineer(DevOps):
    def __str__(self) -> str:
        return f"DeveloperExperienceEngineer<{self.name}>"

    def speak(self) -> None:
        print("How is your CI/CD today?")

class DataEngineer(DevOps):
    def __str__(self) -> str:
        return f"DataEngineer<{self.name}>"

    def speak(self) -> None:
        print("How do you like your data today?")

class MachineLearningEngineer(DevOps):
    def __str__(self) -> str:
        return f"MachineLearningEngineer<{self.name}>"

    def speak(self) -> None:
        print("How do you like them unicorn?")

class WebEngineer(DevOps):
    def __str__(self) -> str:
        return f"WebEngineer<{self.name}>"

    def speak(self) -> None:
        print("What feature should be build today?")

class ReliabilityEngineer(DevOps):
    def __str__(self) -> str:
        return f"ReliabilityEngineer<{self.name}>"

    def speak(self) -> None:
        print("scale")

class PlatformEngineer(DevOps):
    """Fullstack Platform Engineer"""

    def __str__(self) -> str:
        return f"PlatformEngineer<{self.name}>"

    def speak(self) -> None:
        print("internal product")
        print("very rare")


# Factory
class PlatformOrganization:
    """Platform Organization"""

    def __init__(self, platform_factory: Type[DevOps]) -> None:
        """devops_factory is our abstract factory.  We can set it at will."""

        self.devops_factory = platform_factory

    def request_devops(self, name: str) -> DevOps:
        """Creates and shows a devops using the abstract factory"""

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
def main() -> None:
    """
    # A PlatformOrganization that staffs only infrastructure engineers
    >>> infrastructureengineer_platformorganization = PlatformOrganization(InfrastructureEngineer)
    >>> devops = infrastructureengineer_platformorganization.request_devops("Cloud")
    Here is your lovely InfrastructureEngineer<Cloud>
    >>> devops.speak()
    cloud

    # A PlatformOrganization that staffs random platform engineers
    >>> platformorganization = PlatformOrganization(random_platform)
    >>> for name in ["Cloud", "Data", "MachineLearning"]:
    ...    devops = PlatformOrganization.request_platform(name)
    ...    devops.speak()
    ...    print("=" * 20)
    Here is your lovely InfrastructureEngineer<Cloud>
    meow
    ====================
    Here is your lovely DataEngineer<Data>
    woof
    ====================
    Here is your lovely MachineLearningEngineer<MachineLearning>
    woof
    ====================
    """


if __name__ == "__main__":
    # for deterministic doctest outputs
    random.seed(1234)

    platform = PlatformOrganization(random_platform)
    import doctest

    doctest.testmod()
