from random import randint

from libs.calculator.calculator import Calculator

my_calculator = Calculator()

def hello():
  num1 = randint(0, 100)
  num2 = randint(0, 100)
  message = "Did you know {} + {} = {}?".format(num1, num2, my_calculator.add(num1, num2))
  print(message)

if __name__ == '__main__':
  hello()
