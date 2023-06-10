# Overview

The DevOps library demonstrates the use of an [abstract factory pattern](https://github.com/faif/python-patterns/blob/master/patterns/creational/abstract_factory.py).

This particular implementation abstracts the creation of a devops and
does so depending on the factory we chose (InfrastructureEngineer, 
DeveloperExperienceEngineer, DataEngineer, or random_platform, etc).
This works because our child classes (InfrastructureEngineer, 
DeveloperExperienceEngineer, DataEngineer, and random_platform, etc) 
respect a common interface (callable for creation and .speak()).
Now the application can create devops abstractly and decide later,
based on your own criteria, which flavor of devops you wish to call.

## Reference Concepts

- https://www.w3schools.com/python/python_inheritance.asp
- https://www.w3schools.com/python/python_polymorphism.asp
- https://github.com/faif/python-patterns/blob/master/patterns/creational/abstract_factory.py
